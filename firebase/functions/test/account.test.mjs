import { test } from 'node:test';
import assert from 'node:assert/strict';
import { switchRoleHandler, deleteAccountHandler } from '../lib/account/handlers.js';
import { harness, driver } from './ride-fixtures.mjs';
import { dispatchRide } from '../lib/rides/matching.js';
import { acceptRideHandler } from '../lib/rides/offers.js';

const request = (role = 'rider') => ({ auth: { uid: 'a' }, data: { role } });
const setup = (seed = {}) => harness({ 'users/a': { name: 'A', role: 'driver' }, 'drivers/a': driver(), ...seed });
const busy = promise => assert.rejects(promise, e => e.code === 'failed-precondition' && e.details.reason === 'busy');
function deletion(h, overrides = {}) {
  const files = [], auth = [];
  return { files, auth, deps: { matching: h.deps,
    deleteFiles: async prefix => { files.push(prefix); },
    deleteUser: async uid => { auth.push(uid); assert.equal(h.db.records.has('users/' + uid), false); }, ...overrides } };
}
test('switch role both directions, setting departing driver offline', async () => {
  const h = setup();
  await switchRoleHandler(request(), h.db, h.deps);
  assert.equal(h.db.records.get('users/a').role, 'rider');
  assert.equal(h.db.records.get('drivers/a').isOnline, false);
  await switchRoleHandler(request('driver'), h.db, h.deps);
  assert.equal(h.db.records.get('users/a').role, 'driver');
});
test('authentication required; admin and invalid roles rejected', async () => {
  const h = setup();
  for (const role of ['admin', null, '', 5]) await assert.rejects(switchRoleHandler(request(role), h.db, h.deps), e => e.code === 'invalid-argument');
  for (const handler of [switchRoleHandler, deleteAccountHandler]) await assert.rejects(handler({ data: {} }, h.db, h.deps), e => e.code === 'unauthenticated');
  h.db.records.get('users/a').role = 'admin';
  await assert.rejects(switchRoleHandler(request('rider'), h.db, h.deps), e => e.code === 'permission-denied');
});
test('all busy pointers block deletion and switching away without mutations', async () => {
  for (const [path, field] of [['users/a', 'activeRideId'], ['users/a', 'pendingRatingRideId'], ['drivers/a', 'currentRideId'], ['drivers/a', 'pendingRatingRideId']]) {
    for (const action of ['switch', 'delete']) {
      const h = setup(); h.db.records.get(path)[field] = 'ride';
      const before = JSON.stringify([...h.db.records]);
      const d = deletion(h);
      await busy(action === 'switch' ? switchRoleHandler(request(), h.db, h.deps) : deleteAccountHandler(request(), h.db, d.deps));
      assert.equal(JSON.stringify([...h.db.records]), before);
      assert.deepEqual(d.auth, []); assert.deepEqual(d.files, []);
    }
  }
  for (const field of ['activeRideId', 'pendingRatingRideId']) {
    const h = setup({ 'users/a': { role: 'rider', [field]: 'ride' } });
    await busy(switchRoleHandler(request('driver'), h.db, h.deps));
  }
});
test('switching away declines a live offer and dispatches the next driver', async () => {
  const h = setup({ 'drivers/b': driver(0.01) });
  await dispatchRide(h.db, 'x', h.deps);
  assert.equal(h.db.records.get('rides/x').offeredTo, 'a');
  await switchRoleHandler(request(), h.db, h.deps);
  assert.equal(h.db.records.get('rides/x').offeredTo, 'b');
  assert.equal(h.db.records.get('drivers/a').offer, null);
  assert.equal(h.db.records.get('drivers/a').isOnline, false);
  assert.deepEqual(h.db.records.get('rides/x').declinedBy, ['a']);
});
test('stale offer clears without changing another driver offer', async () => {
  const h = setup();
  h.db.records.get('drivers/a').offer = { rideId: 'x' };
  h.db.records.get('rides/x').offeredTo = 'b';
  await switchRoleHandler(request(), h.db, h.deps);
  assert.equal(h.db.records.get('drivers/a').offer, null);
  assert.equal(h.db.records.get('rides/x').offeredTo, 'b');
});
test('switch and accept serialize: a busy driver cannot switch and a departed driver cannot accept', async () => {
  for (const acceptFirst of [true, false]) {
    const h = setup();
    await dispatchRide(h.db, 'x', h.deps);
    const accept = () => acceptRideHandler({ auth: { uid: 'a' }, data: { rideId: 'x' } }, h.db, h.deps);
    const change = () => switchRoleHandler(request(), h.db, h.deps);
    const results = await Promise.allSettled(acceptFirst ? [accept(), change()] : [change(), accept()]);
    assert.equal(results[0].status, 'fulfilled');
    assert.equal(results[1].status, 'rejected');
    assert.equal(results[1].reason.details.reason, acceptFirst ? 'busy' : 'driver-busy');
  }
});
test('delete clears a live offer and matching continues, even with a missing user document', async () => {
  const h = setup({ 'drivers/b': driver(0.01) });
  await dispatchRide(h.db, 'x', h.deps);
  const d = deletion(h);
  h.db.records.delete('users/a');
  await deleteAccountHandler(request(), h.db, d.deps);
  assert.equal(h.db.records.get('rides/x').offeredTo, 'b');
  assert.equal(h.db.records.has('drivers/a'), false);
  assert.deepEqual(d.auth, ['a']);
});
test('delete removes docs, earnings, storage and Auth; anonymizes own snapshots in bounded batches and is idempotent', async () => {
  const h = setup();
  for (let i = 0; i < 1003; i++) {
    h.db.records.set('drivers/a/earnings/' + i, { total: i });
    h.db.records.set('rides/past-' + i, { status: 'completed', riderId: i % 2 ? 'a' : 'other', driverId: i % 2 ? 'other' : 'a',
      riderInfo: { name: 'Rider', phone: '123', rating: 4 }, driverInfo: { name: 'Driver', phone: '456', vehicle: { plate: 'keep' } }, fare: { final: 5 } });
  }
  const d = deletion(h);
  await deleteAccountHandler(request(), h.db, d.deps);
  assert.equal(h.db.records.has('users/a'), false); assert.equal(h.db.records.has('drivers/a'), false);
  assert.equal([...h.db.records.keys()].some(p => p.startsWith('drivers/a/earnings/')), false);
  assert.deepEqual(d.files, ['drivers/a/']); assert.deepEqual(d.auth, ['a']);
  for (let i = 0; i < 1003; i++) {
    const r = h.db.records.get('rides/past-' + i), side = i % 2 ? 'riderInfo' : 'driverInfo';
    assert.equal(r[side].name, 'deleted'); assert.equal(r[side].phone, null);
    assert.equal(r[side === 'riderInfo' ? 'driverInfo' : 'riderInfo'].name, i % 2 ? 'Driver' : 'Rider');
    assert.equal(r.driverInfo.vehicle.plate, 'keep'); assert.equal(r.riderInfo.rating, 4); assert.equal(r.fare.final, 5);
  }
  await deleteAccountHandler(request(), h.db, { ...d.deps, deleteUser: async () => { throw { code: 'auth/user-not-found' }; } });
});
test('deletion retries after storage and Auth failures', async () => {
  const h = setup(), d = deletion(h);
  await assert.rejects(deleteAccountHandler(request(), h.db, { ...d.deps, deleteFiles: async () => { throw Error('offline'); } }));
  assert.equal(h.db.records.get('users/a').accountDeleting, true);
  await assert.rejects(switchRoleHandler(request('driver'), h.db, h.deps));
  await assert.rejects(deleteAccountHandler(request(), h.db, { ...d.deps, deleteUser: async () => { throw Error('auth offline'); } }));
  await deleteAccountHandler(request(), h.db, d.deps);
});
