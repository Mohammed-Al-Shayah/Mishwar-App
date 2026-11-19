import { test } from 'node:test';
import assert from 'node:assert/strict';
import { reviewDriverHandler, updatePricingHandler, adminCancelRideHandler } from '../lib/admin/handlers.js';
import { DEFAULT_PRICING } from '../lib/pricing.js';
import { harness, driver } from './ride-fixtures.mjs';
import { dispatchRide } from '../lib/rides/matching.js';
const request = data => ({ auth: { uid: 'admin', token: { admin: true } }, data });
const logs = h => [...h.db.records].filter(([p]) => p.startsWith('adminLog/')).map(([, d]) => d);
const code = expected => e => e.code === expected;

test('each callable requires the strict boolean admin claim', async () => {
  const h = harness();
  for (const handler of [reviewDriverHandler, updatePricingHandler, adminCancelRideHandler]) {
    for (const auth of [undefined, { uid: 'r', token: {} }, { uid: 'r', token: { admin: 'true' } }, { uid: 'r', token: { admin: false } }]) {
      await assert.rejects(handler({ auth, data: {} }, h.db, h.deps), code('permission-denied'));
    }
  }
  assert.equal(logs(h).length, 0);
});
test('review transitions are exhaustive and audit is atomic', async () => {
  const transitions = { pending: { approve: 'approved', reject: 'rejected' }, approved: { suspend: 'suspended' }, suspended: { reactivate: 'approved' }, rejected: { approve: 'approved' } };
  for (const from of Object.keys(transitions)) for (const decision of ['approve', 'reject', 'suspend', 'reactivate']) {
    const h = harness({ 'drivers/a': { ...driver(), status: from } });
    const call = reviewDriverHandler(request({ uid: 'a', decision, reason: 'review reason' }), h.db, h.deps);
    if (!transitions[from][decision]) { await assert.rejects(call, code('failed-precondition')); assert.equal(logs(h).length, 0); continue; }
    await call;
    const d = h.db.records.get('drivers/a');
    assert.equal(d.status, transitions[from][decision]); assert.equal(d.reviewedBy, 'admin'); assert.ok(d.reviewedAt);
    if (decision === 'reject') assert.equal(d.rejectionReason, 'review reason');
    if (decision === 'suspend') { assert.equal(d.suspensionReason, 'review reason'); assert.equal(d.isOnline, false); }
    assert.equal(logs(h)[0].action, 'reviewDriver'); assert.equal(logs(h)[0].target, 'a'); assert.equal(logs(h)[0].by, 'admin');
  }
});
test('review rejects malformed inputs and missing drivers without logs', async () => {
  for (const data of [{ uid: 'a', decision: 'reject' }, { uid: 'a', decision: 'suspend', reason: ' ' }, { uid: 'a', decision: 'approve', reason: 'x'.repeat(201) }, { uid: '../a', decision: 'approve' }, { uid: 'a', decision: 'unknown' }]) {
    const h = harness(); await assert.rejects(reviewDriverHandler(request(data), h.db, h.deps), code('invalid-argument')); assert.equal(logs(h).length, 0);
  }
  const h = harness(); await assert.rejects(reviewDriverHandler(request({ uid: 'missing', decision: 'approve' }), h.db, h.deps), code('not-found'));
});
test('suspension declines offer and dispatches the next eligible driver', async () => {
  const h = harness({ 'drivers/a': driver(), 'drivers/b': driver(0.01) });
  await dispatchRide(h.db, 'x', h.deps);
  assert.equal(h.db.records.get('rides/x').offeredTo, 'a');
  await reviewDriverHandler(request({ uid: 'a', decision: 'suspend', reason: 'documents' }), h.db, h.deps);
  assert.equal(h.db.records.get('drivers/a').offer, null);
  assert.equal(h.db.records.get('drivers/a').isOnline, false);
  assert.deepEqual(h.db.records.get('rides/x').declinedBy, ['a']);
  assert.equal(h.db.records.get('rides/x').offeredTo, 'b');
  assert.equal(logs(h).length, 1);
});
test('pricing bounds, finite numbers and whole fils validation; metadata cannot be forged', async () => {
  for (const value of [0, -1, 50.001, Infinity, NaN, '1', 0.0001, null]) {
    const h = harness(), data = { ...DEFAULT_PRICING, economy: { ...DEFAULT_PRICING.economy } }; data.economy.base = value;
    await assert.rejects(updatePricingHandler(request(data), h.db), code('invalid-argument')); assert.equal(logs(h).length, 0);
  }
  const h = harness();
  await updatePricingHandler(request({ ...DEFAULT_PRICING, updatedBy: 'forged', economy: { ...DEFAULT_PRICING.economy, base: 50, extra: 'ignored' } }), h.db);
  const data = h.db.records.get('config/pricing'); assert.equal(data.updatedBy, 'admin'); assert.ok(data.updatedAt);
  assert.equal(data.JO.economy.base, 50); assert.equal(data.JO.economy.extra, undefined); assert.equal(logs(h)[0].target, 'config/pricing');
});
test('cancel all active statuses; clear only matching pointers and append audit', async () => {
  for (const status of ['searching', 'accepted', 'arriving', 'arrived', 'in_progress']) {
    const h = harness({ 'rides/x': { status, riderId: 'r', driverId: 'a', offeredTo: 'b' },
      'users/r': { activeRideId: 'x' }, 'drivers/a': { currentRideId: 'x' }, 'drivers/b': { offer: { rideId: 'x' } } });
    await adminCancelRideHandler(request({ rideId: 'x', reason: 'support' }), h.db);
    assert.equal(h.db.records.get('rides/x').status, 'cancelled'); assert.equal(h.db.records.get('rides/x').cancelledBy, 'system');
    assert.equal(h.db.records.get('rides/x').offeredTo, null); assert.equal(h.db.records.get('drivers/b').offer, null);
    assert.equal(h.db.records.get('drivers/a').currentRideId, null); assert.equal(h.db.records.get('users/r').activeRideId, undefined);
    assert.equal(logs(h)[0].details.reason, 'support'); assert.ok(logs(h)[0].at);
  }
  for (const status of ['completed', 'cancelled', 'no_drivers']) {
    const h = harness({ 'rides/x': { status } });
    await assert.rejects(adminCancelRideHandler(request({ rideId: 'x', reason: 'support' }), h.db), code('failed-precondition')); assert.equal(logs(h).length, 0);
  }
  const h = harness({ 'rides/x': { status: 'accepted', riderId: 'r', driverId: 'a' }, 'users/r': { activeRideId: 'new' }, 'drivers/a': { currentRideId: 'new', offer: { rideId: 'new' } } });
  for (const reason of ['', ' ', 'x'.repeat(201), 5]) await assert.rejects(adminCancelRideHandler(request({ rideId: 'x', reason }), h.db), code('invalid-argument'));
  await adminCancelRideHandler(request({ rideId: 'x', reason: 'support' }), h.db);
  assert.equal(h.db.records.get('users/r').activeRideId, 'new'); assert.equal(h.db.records.get('drivers/a').currentRideId, 'new');
  assert.equal(h.db.records.get('drivers/a').offer.rideId, 'new');
});
