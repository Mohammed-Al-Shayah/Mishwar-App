import { test } from 'node:test';
import assert from 'node:assert/strict';
import { Timestamp, GeoPoint } from 'firebase-admin/firestore';
import { requestRideHandler, cancelRideHandler, expireSearchingRidesHandler, activeStatuses } from '../lib/rides/handlers.js';

import { FakeFirestore } from './fake-firestore.mjs';
const point = { lat: 31.95, lng: 35.91, name: 'Place', address: 'Address' };
const input = { pickup: point, dropoff: { ...point, lat: 32 }, vehicleType: 'economy', paymentMethod: 'cash' };
const req = (data = input, uid = 'rider') => ({ auth: { uid }, data });
const route = { polyline: 'abc', distanceMeters: 5000, durationSeconds: 600 };
const estimate = async (request) => {
  assert.equal(request.data.fare, undefined);
  assert.deepEqual(request.data.origin, point);
  return { route, fares: [{ vehicleType: 'economy', amount: 2.5, currency: 'JOD' }] };
};
const db = () => new FakeFirestore({ 'users/rider': { role: 'rider' } });
const rejects = (promise, code) => assert.rejects(promise, (e) => e.code === code);

test('request requires auth and rider profile before calling maps', async () => {
  await rejects(requestRideHandler({ data: input }, db(), '', estimate), 'unauthenticated');
  for (const profile of [undefined, { role: 'driver' }, { role: 'admin' }]) {
    const store = db(); if (profile) store.records.set('users/rider', profile); else store.records.delete('users/rider');
    await rejects(requestRideHandler(req(), store, '', () => { throw Error('maps must not run'); }), 'permission-denied');
  }
});
test('validates coordinates, place lengths, payment and vehicle', async () => {
  for (const data of [{ ...input, pickup: { ...point, lat: 91 } }, { ...input, pickup: { ...point, name: 'a'.repeat(121) } },
    { ...input, dropoff: { ...point, address: 'a'.repeat(201) } }, { ...input, vehicleType: 'bike' },
    { ...input, paymentMethod: 'card' }, { ...input, pickup: null }]) {
    await rejects(requestRideHandler(req(data), db(), '', estimate), 'invalid-argument');
  }
});
test('request stores server route, price, timestamps and active ride atomically', async () => {
  const store = db();
  const { rideId } = await requestRideHandler(req({ ...input, fare: 0.01 }), store, '', estimate, () => Timestamp.fromMillis(1000));
  const ride = store.records.get('rides/' + rideId);
  assert.deepEqual(ride.fare, { estimated: 2.5, final: null, currency: 'JOD' });
  assert.deepEqual(ride.route, route); assert.equal(ride.status, 'searching');
  assert.equal(ride.searchExpiresAt.toMillis(), 121000); assert(ride.createdAt instanceof Timestamp);
  assert(ride.pickup.geopoint instanceof GeoPoint); assert.equal(ride.driverId, null);
  assert.equal(store.records.get('users/rider').activeRideId, rideId);
});
test('every active status blocks requests, including legacy rides without pointer', async () => {
  for (const status of activeStatuses) {
    const store = db(); store.records.set('rides/existing', { riderId: 'rider', status });
    await assert.rejects(requestRideHandler(req(), store, '', estimate), (e) => e.code === 'failed-precondition' && e.details.activeRideId === 'existing');
    assert.equal(store.records.size, 2);
  }
});
test('simultaneous requests create exactly one ride', async () => {
  const store = db();
  const results = await Promise.allSettled([requestRideHandler(req(), store, '', estimate), requestRideHandler(req(), store, '', estimate)]);
  assert.equal(results.filter((r) => r.status === 'fulfilled').length, 1);
});
test('cancel checks ownership and status; cancellation is idempotent', async () => {
  for (const status of ['searching', 'accepted', 'arriving', 'arrived', 'cancelled']) {
    const store = db(); store.records.set('rides/x', { riderId: 'rider', status });
    store.records.set('users/rider', { role: 'rider', activeRideId: 'x' });
    await rejects(cancelRideHandler(req({ rideId: 'x' }, 'other'), store), 'permission-denied');
    await cancelRideHandler(req({ rideId: 'x' }), store);
    const first = store.records.get('rides/x');
    assert.equal(first.status, 'cancelled'); assert.equal(store.records.get('users/rider').activeRideId, undefined);
    await cancelRideHandler(req({ rideId: 'x' }), store);
    assert.deepEqual(store.records.get('rides/x'), first);
  }
  for (const status of ['in_progress', 'completed', 'no_drivers']) {
    const store = db(); store.records.set('rides/x', { riderId: 'rider', status });
    await rejects(cancelRideHandler(req({ rideId: 'x' }), store), 'failed-precondition');
    assert.equal(store.records.get('rides/x').status, status);
  }
});
test('cancel validates id, requires auth, handles missing document and preserves newer pointer', async () => {
  const store = db();
  await rejects(cancelRideHandler({ data: { rideId: 'x' } }, store), 'unauthenticated');
  await rejects(cancelRideHandler(req({ rideId: 'a/b' }), store), 'invalid-argument');
  await rejects(cancelRideHandler(req({ rideId: 'missing' }), store), 'not-found');
  store.records.set('rides/x', { riderId: 'rider', status: 'cancelled' });
  store.records.set('users/rider', { role: 'rider', activeRideId: 'new' });
  await cancelRideHandler(req({ rideId: 'x' }), store);
  assert.equal(store.records.get('users/rider').activeRideId, 'new');
});
test('expiry only changes searching rides strictly past deadline, preserving newer active ids', async () => {
  const store = db();
  for (const [id, status, time] of [['expired', 'searching', 999], ['boundary', 'searching', 1000],
    ['future', 'searching', 1001], ['accepted', 'accepted', 1]]) {
    store.records.set('rides/' + id, { riderId: 'rider', status, searchExpiresAt: Timestamp.fromMillis(time) });
  }
  store.records.set('users/rider', { role: 'rider', activeRideId: 'expired' });
  await expireSearchingRidesHandler(store, Timestamp.fromMillis(1000));
  assert.equal(store.records.get('rides/expired').status, 'no_drivers');
  assert.equal(store.records.get('users/rider').activeRideId, undefined);
  for (const id of ['boundary', 'future']) assert.equal(store.records.get('rides/' + id).status, 'searching');
  assert.equal(store.records.get('rides/accepted').status, 'accepted');
  store.records.set('users/rider', { activeRideId: 'new' });
  await expireSearchingRidesHandler(store, Timestamp.fromMillis(1002));
  assert.equal(store.records.get('users/rider').activeRideId, 'new');
});
