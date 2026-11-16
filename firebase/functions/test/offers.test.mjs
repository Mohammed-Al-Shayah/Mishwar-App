import { test } from 'node:test';
import assert from 'node:assert/strict';
import { acceptRideHandler, declineRideHandler } from '../lib/rides/offers.js';
import { dispatchRide } from '../lib/rides/matching.js';
import { harness, driver, ts } from './ride-fixtures.mjs';

const request = (uid = 'a', rideId = 'x') => ({ auth: { uid }, data: { rideId } });
const offered = async () => {
  const h = harness({ 'drivers/a': driver(), 'drivers/b': driver(0.01) });
  await dispatchRide(h.db, 'x', h.deps); return h;
};
const failure = (promise, reason) => assert.rejects(promise,
  (error) => error.code === 'failed-precondition' && error.details.reason === reason);

test('accept atomically assigns ride and driver with server timestamp', async () => {
  const h = await offered();
  assert.deepEqual(await acceptRideHandler(request(), h.db, h.deps), { ok: true });
  const r = h.db.records.get('rides/x'), d = h.db.records.get('drivers/a');
  assert.equal(r.status, 'accepted'); assert.equal(r.driverId, 'a');
  assert.deepEqual(r.acceptedAt, ts(1000)); assert.equal(r.offeredTo, null);
  assert.deepEqual(r.driverInfo, { name: 'Driver A', phone: '+962780000002', rating: 5, vehicle: h.db.records.get('drivers/a').vehicle });
  assert.deepEqual(r.riderInfo, { name: 'Rider', phone: '+962780000001', rating: 5 });
  assert.equal(r.offerExpiresAt, null); assert.equal(d.currentRideId, 'x'); assert.equal(d.offer, null);
});
test('accept after expiry including exact boundary fails without mutations', async () => {
  for (const time of [16000, 17000]) {
    const h = await offered(); h.setTime(time);
    await failure(acceptRideHandler(request(), h.db, h.deps), 'offer-expired');
    assert.equal(h.db.records.get('rides/x').status, 'searching');
    assert.equal(h.db.records.get('drivers/a').currentRideId, null);
  }
});
test('accept requires offered driver, searching ride and matching driver offer', async () => {
  const h = await offered();
  await failure(acceptRideHandler(request('b'), h.db, h.deps), 'not-offered');
  await failure(acceptRideHandler(request('a', 'missing'), h.db, h.deps), 'not-offered');
  h.db.records.get('drivers/a').offer = { rideId: 'other' };
  await failure(acceptRideHandler(request(), h.db, h.deps), 'not-offered');
  h.db.records.get('rides/x').status = 'cancelled';
  await failure(acceptRideHandler(request(), h.db, h.deps), 'not-offered');
});
test('busy, offline, unapproved and missing drivers cannot accept', async () => {
  for (const extra of [{ currentRideId: 'other' }, { isOnline: false }, { status: 'pending' }, null]) {
    const h = await offered();
    if (extra) Object.assign(h.db.records.get('drivers/a'), extra); else h.db.records.delete('drivers/a');
    await failure(acceptRideHandler(request(), h.db, h.deps), 'driver-busy');
    assert.equal(h.db.records.get('rides/x').status, 'searching');
  }
});
test('two concurrent accepts of one offer yield exactly one success', async () => {
  const h = await offered();
  const results = await Promise.allSettled([acceptRideHandler(request(), h.db, h.deps), acceptRideHandler(request(), h.db, h.deps)]);
  assert.equal(results.filter((r) => r.status === 'fulfilled').length, 1);
  assert.equal(results.find((r) => r.status === 'rejected').reason.details.reason, 'not-offered');
  assert.equal(h.db.records.get('rides/x').driverId, 'a');
});
test('decline dispatches next driver and repeated/stale decline makes no changes', async () => {
  const h = await offered();
  assert.deepEqual(await declineRideHandler(request(), h.db, h.deps), { ok: true });
  assert.equal(h.db.records.get('rides/x').offeredTo, 'b');
  assert.deepEqual(h.db.records.get('rides/x').declinedBy, ['a']);
  assert.equal(h.db.records.get('drivers/a').offer, null);
  const before = new Map(h.db.records);
  await declineRideHandler(request(), h.db, h.deps);
  await declineRideHandler(request('a', 'missing'), h.db, h.deps);
  assert.deepEqual(h.db.records, before); assert.equal(h.tasks.length, 2);
});
test('decline preserves newer driver offer and cannot clear accepted ride', async () => {
  const h = await offered();
  h.db.records.get('drivers/a').offer = { rideId: 'new' };
  await declineRideHandler(request(), h.db, h.deps);
  assert.equal(h.db.records.get('drivers/a').offer.rideId, 'new');
  await acceptRideHandler(request('b'), h.db, h.deps);
  await declineRideHandler(request('b'), h.db, h.deps);
  assert.equal(h.db.records.get('rides/x').status, 'accepted');
  assert.equal(h.db.records.get('drivers/b').currentRideId, 'x');
});
test('callables require authentication and validate ride ids', async () => {
  const h = await offered();
  for (const handler of [acceptRideHandler, declineRideHandler]) {
    await assert.rejects(handler({ data: { rideId: 'x' } }, h.db, h.deps), (e) => e.code === 'unauthenticated');
    for (const rideId of ['', 'a/b', 42]) {
      await assert.rejects(handler(request('a', rideId), h.db, h.deps), (e) => e.code === 'invalid-argument');
    }
  }
});

test('party snapshots preserve ratings and exclude private fields', async () => {
  const h = await offered();
  Object.assign(h.db.records.get('users/rider'), { rating: 4.3, fcmToken: 'private' });
  await acceptRideHandler(request('a'), h.db, h.deps);
  assert.equal(h.db.records.get('rides/x').riderInfo.rating, 4.3);
  assert.equal(h.db.records.get('rides/x').riderInfo.fcmToken, undefined);
});
