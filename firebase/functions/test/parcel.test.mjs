import { test } from 'node:test';
import assert from 'node:assert/strict';
import { FakeFirestore } from './fake-firestore.mjs';
import { requestRideHandler } from '../lib/rides/handlers.js';
import { scheduleRideHandler } from '../lib/rides/scheduled.js';
import { updateRideStatusHandler, adminCompleteParcelHandler } from '../lib/rides/lifecycle.js';
import { hashDeliveryCode, parcelPhotoUrlHandler } from '../lib/rides/parcel.js';
import { driver, ts } from './ride-fixtures.mjs';
import { dispatchRide } from '../lib/rides/matching.js';
const point = { lat: 31.95, lng: 35.91, name: 'Place', address: 'Address' };
const parcel = { recipientName: 'Recipient', recipientPhone: '+962781234567', description: 'Books', photoPath: 'parcels/rider/photo.jpg' };
const input = { pickup: point, dropoff: point, serviceType: 'parcel', parcel, vehicleType: 'economy', paymentMethod: 'cash' };
const req = (data = input, uid = 'rider', token = {}) => ({ auth: { uid, token }, data });
const estimate = async () => ({ route: { distanceMeters: 5000, durationSeconds: 600, polyline: 'abc' }, fares: [{ vehicleType: 'economy', amount: 2.5 }] });
function setup() {
  const db = new FakeFirestore({ 'users/rider': { role: 'rider' }, 'config/app': { services: [{ id: 'parcel', enabled: true }] } });
  const sent = [], sms = { send: async (to, text) => { sent.push({ to, text }); } };
  return { db, sent, sms };
}
const reject = (promise, reason, code = 'failed-precondition') => assert.rejects(promise, e => e.code === code && (!reason || e.details?.reason === reason));
test('parcel request validates fields, service type, phone, path and economy', async () => {
  for (const change of [{ serviceType: 'airport' }, { vehicleType: 'van' }, { parcel: null },
    ...[{ recipientName: '' }, { recipientName: 'a'.repeat(41) }, { recipientPhone: '0781234567' }, { recipientPhone: '+972781234567' },
      { description: '' }, { description: 'a'.repeat(201) }, { photoPath: 'parcels/other/a.jpg' }, { photoPath: 'parcels/rider/../a.jpg' }, { photoPath: 'https://photo' }].map(p => ({ parcel: { ...parcel, ...p } }))]) {
    const h = setup();
    await reject(requestRideHandler(req({ ...input, ...change }), h.db, '', estimate, () => ts(1000), h.sms), null, 'invalid-argument');
    assert.equal(h.sent.length, 0);
  }
});
test('missing and disabled parcel config fail closed for immediate and scheduled requests', async () => {
  for (const config of [undefined, { services: [{ id: 'parcel', enabled: false }] }]) {
    const h = setup(); h.db.records.delete('config/app'); if (config) h.db.records.set('config/app', config);
    await reject(requestRideHandler(req(), h.db, '', estimate, () => ts(1000), h.sms), 'service-disabled');
    await reject(scheduleRideHandler(req({ ...input, scheduledFor: 3600000 }), h.db, '', undefined, estimate, () => ts(1000), h.sms), 'service-disabled');
  }
});
async function created(scheduled = false) {
  const h = setup();
  const response = scheduled
    ? await scheduleRideHandler(req({ ...input, scheduledFor: 3600000 }), h.db, '', undefined, estimate, () => ts(1000), h.sms)
    : await requestRideHandler(req(), h.db, '', estimate, () => ts(1000), h.sms);
  return { ...h, ...response };
}
test('request and scheduling store only salted hash on ride, private code, and send recipient SMS', async () => {
  for (const scheduled of [false, true]) {
    const h = await created(scheduled), ride = h.db.records.get('rides/' + h.rideId);
    assert.match(h.deliveryCode, /^\d{4}$/);
    assert.equal(ride.serviceType, 'parcel'); assert.equal(ride.parcel.deliveryCode, undefined);
    assert.equal(ride.parcel.deliveryCodeHash, hashDeliveryCode(h.rideId, h.deliveryCode, ride.parcel.deliveryCodeSalt));
    assert.equal(ride.parcel.codeAttempts, 0);
    assert.deepEqual(h.db.records.get(`rides/${h.rideId}/private/rider`), { deliveryCode: h.deliveryCode });
    assert.deepEqual(h.sent, [{ to: parcel.recipientPhone, text: `مشوار: رمز استلام طردك ${h.deliveryCode}` }]);
  }
});
async function active() {
  const h = await created();
  Object.assign(h.db.records.get('rides/' + h.rideId), { driverId: 'driver', status: 'in_progress', startedAt: ts(1000) });
  h.db.records.set('drivers/driver', driver(0, { currentRideId: h.rideId }));
  return h;
}
const complete = (h, deliveryCode) => updateRideStatusHandler(req({ rideId: h.rideId, status: 'completed', deliveryCode }, 'driver'), h.db, () => ts(2000));
test('bad code attempts persist, correct code completes with normal fare and is idempotent', async () => {
  const h = await active();
  const wrong = h.deliveryCode === '0000' ? '0001' : '0000';
  await reject(complete(h, wrong), 'bad-code');
  assert.equal(h.db.records.get('rides/' + h.rideId).parcel.codeAttempts, 1);
  assert.equal(h.db.records.get('rides/' + h.rideId).status, 'in_progress');
  await complete(h, h.deliveryCode); await complete(h, h.deliveryCode);
  const ride = h.db.records.get('rides/' + h.rideId);
  assert.equal(ride.status, 'completed'); assert.equal(ride.fare.final, 2.5);
});
test('five concurrent bad attempts lock even the correct code; only admin can override, once and audited', async () => {
  const h = await active();
  const results = await Promise.allSettled(Array.from({ length: 5 }, () => complete(h, 'bad')));
  assert.equal(results.filter(r => r.reason?.details?.reason === 'code-locked').length, 1);
  assert.equal(h.db.records.get('rides/' + h.rideId).parcel.codeAttempts, 5);
  await reject(complete(h, h.deliveryCode), 'code-locked');
  await reject(adminCompleteParcelHandler(req({ rideId: h.rideId }, 'driver'), h.db), null, 'permission-denied');
  await adminCompleteParcelHandler(req({ rideId: h.rideId }, 'admin', { admin: true }), h.db, () => ts(2000));
  await adminCompleteParcelHandler(req({ rideId: h.rideId }, 'admin', { admin: true }), h.db, () => ts(2000));
  assert.equal(h.db.records.get('rides/' + h.rideId).status, 'completed');
  const logs = [...h.db.records.entries()].filter(([p]) => p.startsWith('adminLog/'));
  assert.equal(logs.length, 1); assert.equal(logs[0][1].action, 'adminCompleteParcel');
});
test('photo URL signs stored path for assigned driver only and expires in ten minutes', async () => {
  const h = await active(); const signed = [];
  const sign = async (...args) => { signed.push(args); return 'https://signed.example/photo'; };
  for (const uid of ['rider', 'other', 'admin']) await reject(parcelPhotoUrlHandler(req({ rideId: h.rideId }, uid, { admin: uid === 'admin' }), h.db, sign), null, 'permission-denied');
  assert.equal(signed.length, 0);
  assert.deepEqual(await parcelPhotoUrlHandler(req({ rideId: h.rideId }, 'driver'), h.db, sign, () => 1000), { url: 'https://signed.example/photo' });
  assert.deepEqual(signed, [[parcel.photoPath, 601000]]);
});
test('matching offers carry parcel type, without recipient code', async () => {
  const h = await created();
  h.db.records.set('drivers/driver', driver());
  await dispatchRide(h.db, h.rideId, { now: () => ts(1000), enqueue: async () => {}, notify: async () => {} });
  const offer = h.db.records.get('drivers/driver').offer;
  assert.equal(offer.serviceType, 'parcel');
  assert.equal(offer.deliveryCode, undefined);
});
test('parcel auth, optional photo, per-ride salt and admin override restrictions', async () => {
  const h = setup();
  await reject(requestRideHandler({ data: input }, h.db, '', estimate, () => ts(1000), h.sms), null, 'unauthenticated');
  const withoutPhoto = { ...parcel }; delete withoutPhoto.photoPath;
  const one = await scheduleRideHandler(req({ ...input, parcel: withoutPhoto, scheduledFor: 3600000 }), h.db, '', undefined, estimate, () => ts(1000), h.sms);
  const two = await scheduleRideHandler(req({ ...input, parcel: withoutPhoto, scheduledFor: 7200000 }), h.db, '', undefined, estimate, () => ts(1000), h.sms);
  assert.notEqual(h.db.records.get('rides/' + one.rideId).parcel.deliveryCodeSalt, h.db.records.get('rides/' + two.rideId).parcel.deliveryCodeSalt);
  assert.equal(h.db.records.get('rides/' + one.rideId).parcel.photoPath, undefined);
  await reject(adminCompleteParcelHandler(req({ rideId: one.rideId }, 'admin', { admin: true }), h.db), 'invalid-transition');
  const a = await active();
  a.db.records.get('rides/' + a.rideId).serviceType = 'ride';
  await reject(adminCompleteParcelHandler(req({ rideId: a.rideId }, 'admin', { admin: true }), a.db), 'invalid-transition');
  await reject(parcelPhotoUrlHandler({ data: { rideId: a.rideId } }, a.db, async () => 'url'), null, 'unauthenticated');
});
