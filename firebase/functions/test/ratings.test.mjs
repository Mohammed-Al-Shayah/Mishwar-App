import { test } from 'node:test';
import assert from 'node:assert/strict';
import { rateRideHandler, skipRatingHandler } from '../lib/rides/ratings.js';
import { harness, ride } from './ride-fixtures.mjs';
const setup = (extra = {}) => harness({ 'rides/x': ride({status: 'completed', driverId: 'a', ...extra}),
  'users/rider': {pendingRatingRideId: 'x'}, 'drivers/a': {pendingRatingRideId: 'x'}, 'users/a': {name: 'Driver'} });
const req = (uid = 'rider', data = {}) => ({auth: {uid}, data: {rideId: 'x', stars: 4, ...data}});
const reject = (promise, code) => assert.rejects(promise, e => e.code === code);
for (const uid of ['rider', 'a']) {
 test('rating side ' + uid + ' writes correct field and target, clears only caller', async () => {
   const h = setup(), isRider = uid === 'rider';
   await rateRideHandler(req(uid, {tags: ['friendly'], comment: 'Thanks'}), h.db);
   const r = h.db.records.get('rides/x');
   assert.equal(r[isRider ? 'driverRating' : 'riderRating'].stars, 4);
   assert.deepEqual(r[isRider ? 'driverRating' : 'riderRating'].tags, ['friendly']);
   assert.equal(r[isRider ? 'driverRating' : 'riderRating'].comment, 'Thanks');
   assert.ok(r[isRider ? 'driverRating' : 'riderRating'].createdAt.toMillis());
   const target = h.db.records.get('users/' + (isRider ? 'a' : 'rider'));
   assert.equal(target.rating, 4); assert.equal(target.ratingCount, 1);
   assert.equal(h.db.records.get(isRider ? 'users/rider' : 'drivers/a').pendingRatingRideId, undefined);
   assert.equal(h.db.records.get(isRider ? 'drivers/a' : 'users/rider').pendingRatingRideId, 'x');
   await reject(rateRideHandler(req(uid), h.db), 'already-exists');
   assert.equal(target.ratingCount, 1);
 });
 test('skip side ' + uid + ' only clears matching pointer and is repeatable', async () => {
   const h = setup();
   await skipRatingHandler(req(uid), h.db); await skipRatingHandler(req(uid), h.db);
   assert.equal(h.db.records.get(uid === 'rider' ? 'users/rider' : 'drivers/a').pendingRatingRideId, undefined);
   assert.equal(h.db.records.get('rides/x').driverRating, undefined);
   assert.equal(h.db.records.get('rides/x').riderRating, undefined);
   h.db.records.get(uid === 'rider' ? 'users/rider' : 'drivers/a').pendingRatingRideId = 'new';
   await skipRatingHandler(req(uid), h.db);
   assert.equal(h.db.records.get(uid === 'rider' ? 'users/rider' : 'drivers/a').pendingRatingRideId, 'new');
 });
}
test('concurrent duplicate submission counts once; both sides independently rate', async () => {
 const h=setup();
 const results=await Promise.allSettled([rateRideHandler(req(),h.db),rateRideHandler(req(),h.db)]);
 assert.equal(results.filter(r=>r.status==='fulfilled').length,1);
 assert.equal(results.find(r=>r.status==='rejected').reason.code,'already-exists');
 await rateRideHandler(req('a'),h.db);
 assert.equal(h.db.records.get('users/a').ratingCount,1);
 assert.equal(h.db.records.get('users/rider').ratingCount,1);
});
test('running average rounds to two decimals and preserves newer pending pointer', async()=>{
 const h=setup(); h.db.records.set('users/a',{rating:4.67,ratingCount:3});
 h.db.records.get('users/rider').pendingRatingRideId='new';
 await rateRideHandler(req('rider',{stars:2}),h.db);
 assert.equal(h.db.records.get('users/a').rating,4);
 assert.equal(h.db.records.get('users/a').ratingCount,4);
 assert.equal(h.db.records.get('users/rider').pendingRatingRideId,'new');
 const h2=setup(); h2.db.records.set('users/a',{rating:4.5,ratingCount:2});
 await rateRideHandler(req('rider',{stars:4}),h2.db);
 assert.equal(h2.db.records.get('users/a').rating,4.33);
});
test('auth, caller, completed status and missing ride checks apply to rate and skip', async()=>{
 for(const fn of [rateRideHandler,skipRatingHandler]) {
  const h=setup(); await reject(fn({data:{rideId:'x'}},h.db),'unauthenticated');
  await reject(fn(req('stranger'),h.db),'permission-denied');
  for(const status of ['searching','accepted','in_progress','cancelled']) {
   const h=setup({status}); await reject(fn(req(),h.db),'failed-precondition');
  }
  await reject(fn(req('rider',{rideId:'missing'}),h.db),'not-found');
  for(const rideId of ['',4,'x/y']) await reject(fn(req('rider',{rideId}),h.db),'invalid-argument');
 }
});
test('reject invalid stars, tags, comments atomically', async()=>{
 for(const uid of ['rider','a']) for(const data of [
  ...[0,6,1.5,'4',null].map(stars=>({stars})),
  {tags:['unknown']},{tags:'friendly'},{tags:Array(6).fill('friendly')},{tags:[4]},
  {tags:[uid==='rider'?'respectful':'clean_car']}, {comment:'x'.repeat(301)},{comment:2},{comment:null},
 ]) {
  const h=setup(),before=new Map(h.db.records);
  await reject(rateRideHandler(req(uid,data),h.db),'invalid-argument');assert.deepEqual(h.db.records,before);
 }
 for(const uid of ['rider','a']) for(const stars of [1,5]) {
  const h=setup(); await rateRideHandler(req(uid,{stars,comment:'x'.repeat(300)}),h.db);
 }
});
