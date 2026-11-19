/* global Response */
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { GeoPoint } from 'firebase-admin/firestore';
import { geohashForLocation } from 'geofire-common';
import { findMarket, resolveMarket, homeMarket, DEFAULT_MARKETS } from '../lib/markets.js';
import { formatMoney, roundMoney, toMinor } from '../lib/money.js';
import { pointInPolygon } from '../lib/lib/appConfig.js';
import { computeFare, PS_PRICING, marketPricing } from '../lib/pricing.js';
import { dispatchRide } from '../lib/rides/matching.js';
import { acceptRideHandler } from '../lib/rides/offers.js';
import { updateRideStatusHandler } from '../lib/rides/lifecycle.js';
import { fareEstimatesHandler } from '../lib/getFareEstimates.js';
import { scheduleRideHandler } from '../lib/rides/scheduled.js';
import { requestRideHandler, cancelRideHandler } from '../lib/rides/handlers.js';
import { feeConfigReader } from '../lib/rides/fees.js';
import { evaluatePromo } from '../lib/promos/evaluate.js';
import { countRideStats } from '../lib/admin/stats.js';
import { FakeFirestore } from './fake-firestore.mjs';
import { harness, ride, driver, ts } from './ride-fixtures.mjs';
import { checkTarget, migrateMarkets } from '../../scripts/migrate-markets.mjs';

test('pickup determines market across West Bank, Gaza, Jordan, sea and boundaries', () => {
  for (const [lat, lng, expected] of [[31.9038,35.2034,'PS'],[31.5017,34.4668,'PS'],[31.9539,35.9106,'JO'],[29.532,35.006,'JO'],[31.5,34,undefined],[32.5,35.05,undefined],[31.99,35.55,'PS'],[31.99,35.7,'JO']]) {
    assert.equal(findMarket({lat,lng}), expected, `${lat},${lng}`);
  }
  assert.throws(() => resolveMarket({lat:31.5,lng:34}), e => e.code === 'failed-precondition' && e.details.reason === 'out-of-service-area');
  const ps = JSON.parse(DEFAULT_MARKETS.PS.zone);
  assert.equal(pointInPolygon(31.9038,35.2034,ps),true);
  assert.equal(pointInPolygon(31.5017,34.4668,ps),true);
  assert.equal(findMarket({lat:31.9038,lng:35.2034}, {markets:{...DEFAULT_MARKETS,JO:{currency:'JOD',zone:DEFAULT_MARKETS.PS.zone}}}),'PS');
  assert.equal(homeMarket('+970599123456'),'PS');
  assert.equal(homeMarket('+962791234567'),'JO');
  assert.throws(() => homeMarket('+15551234567'));
});

test('minor units, formatting, half-up rounding and per-market prices', () => {
  assert.equal(toMinor(25.5,'ILS'),2550);
  assert.equal(toMinor(4.7,'JOD'),4700);
  assert.equal(formatMoney(2550,'ILS'),'₪ 25.50');
  assert.equal(formatMoney(4700,'JOD'),'JD 4.70');
  assert.equal(formatMoney(3405,'JOD'),'JD 3.41');
  assert.throws(() => toMinor(0.001,'ILS'));
  assert.equal(roundMoney(10.25,'ILS'),10.5);
  assert.equal(roundMoney(10.24,'ILS'),10);
  assert.equal(roundMoney(1.025,'JOD'),1.05);
  assert.equal(roundMoney(10.1,'ILS',25),10);
  assert.equal(computeFare(PS_PRICING.economy,3750,100,'ILS'),10.5);
  assert.equal(marketPricing({JO:{economy:{}},PS:PS_PRICING},'PS').economy.base,3);
});

const polygon = coordinates => JSON.stringify({type:'Polygon',coordinates:[coordinates]});
const borderApp = {markets:{PS:{currency:'ILS',zone:polygon([[35,31],[35.5,31],[35.5,33],[35,33],[35,31]])},JO:{currency:'JOD',zone:polygon([[35.5,31],[36,31],[36,33],[35.5,33],[35.5,31]])}}};
const located = (lat,lng,extra={}) => driver(0,{location:{geopoint:new GeoPoint(lat,lng),geohash:geohashForLocation([lat,lng])},...extra});
test('matching and acceptance isolate nearby drivers using current location, not phone', async () => {
  const h=harness({'config/app':borderApp,'rides/x':ride({market:'PS',pickup:{geopoint:new GeoPoint(31.95,35.499)}}),'drivers/a':located(31.95,35.501),'drivers/b':located(31.95,35.498)});
  await dispatchRide(h.db,'x',h.deps);
  assert.equal(h.db.records.get('rides/x').offeredTo,'b');
  h.db.records.get('drivers/b').location = located(31.95,35.501).location;
  await assert.rejects(acceptRideHandler({auth:{uid:'b'},data:{rideId:'x'}},h.db,h.deps),e=>e.details.reason==='not-offered');
});

test('ILS completion, balances, earnings and stats remain separate from JOD', async () => {
  const h=harness({'rides/x':ride({market:'PS',status:'in_progress',driverId:'a',startedAt:ts(1000),route:{distanceMeters:0},fare:{estimated:10,currency:'ILS'}}),'drivers/a':driver(0,{currentRideId:'x'}),'users/rider':{activeRideId:'x',balanceDue:{JOD:1500,ILS:250}}});
  await updateRideStatusHandler({auth:{uid:'a'},data:{rideId:'x',status:'completed'}},h.db,h.deps.now);
  const after=h.db.records.get('rides/x');
  assert.equal(after.fare.final,12.5);
  assert.deepEqual(h.db.records.get('users/rider').balanceDue,{JOD:1500,ILS:0});
  assert.equal(h.db.records.get('drivers/a/earnings/1970-01-01_PS').total,12.5);
  assert.equal(h.db.records.get('drivers/a/earnings/1970-01-01_PS').currency,'ILS');
  await countRideStats(h.db,'x',ride(),after,ts(1000));
  assert.equal(h.db.records.get('stats/1970-01-01_PS').revenueMinor,1250);
  assert.equal(h.db.records.has('stats/1970-01-01_JO'),false);
});

test('market fees and promos use agorot and cannot redeem a different market code', async () => {
  const h=harness({'config/app':{cancellationFee:{JO:{amount:0.5,afterSeconds:120},PS:{amount:2,afterSeconds:120}}},'rides/x':ride({market:'PS',status:'accepted',driverId:'a',acceptedAt:ts(0),fare:{estimated:10,currency:'ILS'}}),'drivers/a':driver(0,{currentRideId:'x'}),'users/rider':{balanceDue:{ILS:50,JOD:700}}});
  h.setTime(120001);
  await cancelRideHandler({auth:{uid:'rider'},data:{rideId:'x'}},h.db,h.deps,feeConfigReader(h.db));
  assert.equal(h.db.records.get('rides/x').fare.cancellationFee,2);
  assert.deepEqual(h.db.records.get('users/rider').balanceDue,{ILS:250,JOD:700});
  const promo={market:'PS',type:'percent',value:25,active:true,usedCount:0,firstRideOnly:false,validFrom:ts(0),validUntil:ts(100)};
  const context={market:'PS',fareJod:25,uid:'r',isFirstRide:true,userRedemptions:0,now:ts(1)};
  assert.deepEqual(evaluatePromo(promo,context),{ok:true,discountJod:6});
  assert.deepEqual(evaluatePromo(promo,{...context,market:'JO'}),{ok:false,reason:'wrong-market'});
});

test('migration guard rejects production and unsafe hosts before connecting', () => {
  for (const host of [undefined,'example.com:8080','127.0.0.1.evil:8080','http://localhost:8080']) assert.throws(()=>checkTarget(host,'demo-mishwar'));
  assert.throws(()=>checkTarget('127.0.0.1:8080','production'));
  assert.doesNotThrow(()=>checkTarget('127.0.0.1:8080','demo-mishwar-markets-test'));
  assert.equal(typeof migrateMarkets,'function');
});


test('PS estimates, immediate and scheduled rides use pickup despite Jordan phone', async () => {
  const pickup = {lat:31.9038,lng:35.2034,name:'Pickup',address:'Address'};
  const destination = {...pickup,lat:31.91};
  const estimate = (request, key) => fareEstimatesHandler(request,key,
    async () => Response.json({routes:[{distanceMeters:3750,duration:'100s',polyline:{encodedPolyline:'abc'}}]}),
    async () => ({PS:PS_PRICING}), async () => undefined);
  const db = new FakeFirestore({'users/rider':{role:'rider',phone:'+962791234567',homeMarket:'JO'}});
  const request = {auth:{uid:'rider'},data:{pickup,dropoff:destination,vehicleType:'economy',paymentMethod:'cash',market:'JO',fare:{estimated:0.01,currency:'JOD'}}};
  const estimates = await estimate({...request,data:{origin:pickup,destination}},'fake');
  assert.equal(estimates.market,'PS'); assert.equal(estimates.currency,'ILS');
  assert.equal(estimates.fares[0].amount,10.5);
  const immediate = await requestRideHandler(request,db,'fake',estimate,()=>ts(0));
  const scheduled = await scheduleRideHandler({...request,data:{...request.data,scheduledFor:1800000}},db,'fake',undefined,estimate,()=>ts(0));
  for (const {rideId} of [immediate,scheduled]) {
    const stored = db.records.get('rides/'+rideId);
    assert.equal(stored.market,'PS'); assert.deepEqual(stored.fare,{estimated:10.5,final:null,currency:'ILS'});
  }
  await assert.rejects(estimate({...request,data:{origin:{lat:31.5,lng:34},destination}},'fake'), e=>e.details.reason==='out-of-service-area');
});
