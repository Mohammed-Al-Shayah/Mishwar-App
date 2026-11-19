import { test } from 'node:test';
import assert from 'node:assert/strict';
import { evaluatePromo } from '../lib/promos/evaluate.js';
import { normalizePromo, validatePromoHandler } from '../lib/promos/handlers.js';
import { scheduleRideHandler } from '../lib/rides/scheduled.js';
import { requestRideHandler } from '../lib/rides/handlers.js';
import { updateRideStatusHandler } from '../lib/rides/lifecycle.js';
import { harness, ride, driver, ts } from './ride-fixtures.mjs';
const promo = (patch = {}) => ({ type: 'percent', value: 50, maxDiscount: 2, firstRideOnly: true,
  usedCount: 0, usageLimit: 1000, active: true, validFrom: ts(0), validUntil: ts(9999999999999), ...patch });
const context = (patch = {}) => ({ fareJod: 3.45, uid: 'rider', isFirstRide: true, userRedemptions: 0, now: ts(1000), ...patch });
test('all rejection reasons', () => {
  for (const [p,c,reason] of [[undefined,{},'not-found'], [promo({active:false}),{},'inactive'],
    [promo({validFrom:ts(1001)}),{},'not-started'], [promo({validUntil:ts(999)}),{},'expired'],
    [promo({usedCount:1000}),{},'limit-reached'], [promo(),{userRedemptions:1},'user-limit'],
    [promo(),{isFirstRide:false},'first-ride-only'], [promo({minFare:3.5}),{},'min-fare']]) {
    assert.deepEqual(evaluatePromo(p,context(c)),{ok:false,reason});
  }
});
test('percent cap, fixed cap, integer rounding and inclusive time boundaries', () => {
  for (const [p,c,discountJod] of [[promo(),{},1.7], [promo(),{fareJod:10},2],
    [promo({type:'fixed',value:10}),{},3.45], [promo({value:10}),{fareJod:3.5},0.35],
    [promo({value:100}),{fareJod:0.049},0], [promo({value:0.9999,maxDiscount:100}),{fareJod:1000},9.95], [promo({validFrom:ts(1000),validUntil:ts(1000)}),{},1.7],
    [promo({perUserLimit:2}),{userRedemptions:1},1.7]]) assert.deepEqual(evaluatePromo(p,context(c)),{ok:true,discountJod});
  assert.equal(normalizePromo(' welcome50 '),'WELCOME50');
  for (const code of ['ab','abc/def','????',null,'A'.repeat(21)]) assert.throws(()=>normalizePromo(code));
});
const point = {lat:31.95,lng:35.91,name:'Place',address:'Street'};
const req = (data = {}) => ({auth:{uid:'rider'},data:{code:' welcome50 ',vehicleType:'economy',pickup:point,dropoff:point,paymentMethod:'cash',...data}});
const estimate = async () => ({ route:{distanceMeters:5000,durationSeconds:600,polyline:''},fares:[{vehicleType:'economy',amount:3.45,currency:'JOD'}] });
const setup = () => harness({'users/rider':{role:'rider'},'promos/WELCOME50':promo()});
test('validate server quote and ten-check window, including invalid attempts',async()=>{
  const h=setup();
  assert.deepEqual(await validatePromoHandler(req(),h.db,'',estimate,h.deps.now),{market:'JO',currency:'JOD',code:'WELCOME50',discount:1.7,fareBefore:3.45,fareAfter:1.75});
  for(let i=0;i<9;i++) await assert.rejects(validatePromoHandler(req({code:'bad'}),h.db,'',estimate,h.deps.now),e=>e.details.reason==='not-found');
  await assert.rejects(validatePromoHandler(req(),h.db,'',estimate,h.deps.now),e=>e.code==='resource-exhausted');
  h.setTime(601000); await validatePromoHandler(req(),h.db,'',estimate,h.deps.now);
  assert.equal(h.db.records.get('promos/WELCOME50').usedCount,0);
});
test('auth, rider restriction, completed-ride lookup, min fare details',async()=>{
  const h=setup();
  await assert.rejects(validatePromoHandler({data:{}},h.db,''),e=>e.code==='unauthenticated');
  await assert.rejects(validatePromoHandler({...req(),auth:{uid:'a'}},h.db,''),e=>e.code==='permission-denied');
  h.db.records.set('rides/old',ride({status:'completed'}));
  await assert.rejects(validatePromoHandler(req(),h.db,'',estimate,h.deps.now),e=>e.details.reason==='first-ride-only');
  h.db.records.delete('rides/old');h.db.records.set('promos/WELCOME50',promo({minFare:4}));
  await assert.rejects(validatePromoHandler(req(),h.db,'',estimate,h.deps.now),e=>e.details.reason==='min-fare'&&e.details.minFare===4);
});
test('request rejects invalid promo and stores preview without redemption',async()=>{
  const h=setup();h.db.records.delete('rides/x');
  await assert.rejects(requestRideHandler(req({promoCode:'missing'}),h.db,'',estimate,h.deps.now),e=>e.details.reason==='not-found');
  const result=await requestRideHandler(req({promoCode:'welcome50'}),h.db,'',estimate,h.deps.now);
  assert.deepEqual(h.db.records.get('rides/'+result.rideId).promo,{code:'WELCOME50',discountPreview:1.7});
  assert.equal(h.db.records.get('promos/WELCOME50').usedCount,0);
});
const completing = (extra={}) => ride({status:'in_progress',driverId:'a',startedAt:ts(1000),route:{distanceMeters:5000},fare:{estimated:3.45,currency:'JOD'},promo:{code:'WELCOME50',discountPreview:1.7},...extra});
const complete=(h,id='x',uid='a')=>updateRideStatusHandler({auth:{uid},data:{rideId:id,status:'completed'}},h.db,h.deps.now);
test('completion uses final fare, creation window, earnings and idempotent redemption',async()=>{
  const h=setup();h.db.records.set('rides/x',completing());h.db.records.set('drivers/a',driver(0,{currentRideId:'x'}));
  h.db.records.set('promos/WELCOME50',promo({validUntil:ts(1)}));h.setTime(2401000);
  await complete(h);await complete(h);
  const r=h.db.records.get('rides/x');assert.equal(r.promo.applied,true);assert.equal(r.fare.discount,2);assert.equal(r.fare.final,2);
  assert.equal(h.db.records.get('promos/WELCOME50').usedCount,1);assert.equal(h.db.records.get('promos/WELCOME50/redemptions/rider').count,1);
  assert.equal([...h.db.records].find(([p])=>p.startsWith('drivers/a/earnings/'))[1].total,2);
});
test('two completions on last slot grant one discount, loser pays full fare',async()=>{
  const h=setup();h.db.records.set('promos/WELCOME50',promo({firstRideOnly:false,usageLimit:1}));
  h.db.records.set('rides/x',completing());h.db.records.set('drivers/a',driver(0,{currentRideId:'x'}));
  h.db.records.set('rides/y',completing({riderId:'other',driverId:'b'}));h.db.records.set('users/other',{});h.db.records.set('drivers/b',driver(0,{currentRideId:'y'}));
  await Promise.all([complete(h),complete(h,'y','b')]);
  const rides=['x','y'].map(id=>h.db.records.get('rides/'+id));
  assert.equal(rides.filter(r=>r.promo.applied).length,1);assert.equal(rides.find(r=>!r.promo.applied).fare.discount,0);
  assert.equal(rides.find(r=>!r.promo.applied).fare.final,3.45);assert.equal(h.db.records.get('promos/WELCOME50').usedCount,1);
});

test('scheduled rides re-evaluate and store preview without consuming limits',async()=>{
  const h=setup();
  const data=req({scheduledFor:2000000,promoCode:'welcome50'});
  const result=await scheduleRideHandler(data,h.db,'',undefined,estimate,h.deps.now);
  assert.equal(h.db.records.get('rides/'+result.rideId).promo.code,'WELCOME50');
  assert.equal(h.db.records.get('promos/WELCOME50').usedCount,0);
  await assert.rejects(scheduleRideHandler(req({scheduledFor:2000000,promoCode:'invalid'}),h.db,'',undefined,estimate,h.deps.now),e=>e.details.reason==='not-found');
});
test('completion rechecks first ride and per-user redemption without consuming again',async()=>{
  for(const seed of [{'rides/old':ride({status:'completed'})},{'promos/WELCOME50/redemptions/rider':{count:1}}]) {
    const h=setup();for(const [path,data] of Object.entries(seed))h.db.records.set(path,data);
    h.db.records.set('rides/x',completing());h.db.records.set('drivers/a',driver(0,{currentRideId:'x'}));
    await complete(h);
    assert.equal(h.db.records.get('rides/x').promo.applied,false);
    assert.equal(h.db.records.get('rides/x').fare.discount,0);
    assert.equal(h.db.records.get('rides/x').fare.final,3.45);
    assert.equal(h.db.records.get('promos/WELCOME50').usedCount,0);
  }
});
