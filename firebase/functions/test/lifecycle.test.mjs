import { test } from 'node:test';
import assert from 'node:assert/strict';
import { GeoPoint } from 'firebase-admin/firestore';
import { updateRideStatusHandler } from '../lib/rides/lifecycle.js';
import { cancelRideHandler } from '../lib/rides/handlers.js';
import { harness, ride, driver, ts } from './ride-fixtures.mjs';
import { DEFAULT_PRICING } from '../lib/pricing.js';
const req = (status, uid = 'a') => ({ auth: { uid }, data: { rideId: 'x', status } });
const setup = (status = 'accepted', extra = {}) => harness({
  'rides/x': ride({ status, driverId: 'a', route: { distanceMeters: 5000 }, fare: { estimated: 2.5, final: null, currency: 'JOD' }, startedAt: ts(1000), ...extra }),
  'drivers/a': driver(0, { currentRideId: 'x' }), 'users/rider': { activeRideId: 'x' },
});
const reject = (p, reason, code = 'failed-precondition') => assert.rejects(p, e => e.code === code && (!reason || e.details?.reason === reason));
const update = (h, status, uid) => updateRideStatusHandler(req(status, uid), h.db, h.deps.now);
test('all forward transitions and idempotent repeats including completion', async () => {
  const h = setup();
  for (const [status, stamp] of [['arriving', 'arrivingAt'], ['arrived', 'arrivedAt'], ['in_progress', 'startedAt'], ['completed', 'completedAt']]) {
    assert.deepEqual(await update(h, status), { ok: true });
    assert.equal(h.db.records.get('rides/x').status, status);
    assert.deepEqual(h.db.records.get('rides/x')[stamp], ts(1000));
    const before = new Map(h.db.records); h.setTime(2000);
    await update(h, status); assert.deepEqual(h.db.records, before); h.setTime(1000);
  }
});
test('all invalid, skipped, backwards and terminal transitions are atomic', async () => {
  const next = { accepted: 'arriving', arriving: 'arrived', arrived: 'in_progress', in_progress: 'completed' };
  const targets = ['arriving', 'arrived', 'in_progress', 'completed', 'accepted', 'searching', 'cancelled', 'no_drivers', 'scheduled', 'constructor', null, 4];
  for (const from of ['accepted', 'arriving', 'arrived', 'in_progress', 'completed', 'cancelled', 'no_drivers', 'searching', 'scheduled']) for (const to of targets) {
    if (next[from] === to || from === to) continue;
    const h = setup(from), before = new Map(h.db.records);
    await reject(update(h, to), 'invalid-transition'); assert.deepEqual(h.db.records, before);
  }
});
test('auth, input, caller, missing ride and inactive assignment', async () => {
  const h = setup();
  await reject(updateRideStatusHandler({ data: { rideId: 'x', status: 'arriving' } }, h.db), null, 'unauthenticated');
  for (const uid of ['rider', 'b']) await reject(update(h, 'arriving', uid), null, 'permission-denied');
  for (const rideId of ['', 'x/y', 4]) await reject(updateRideStatusHandler({ ...req('arriving'), data: { rideId, status: 'arriving' } }, h.db), null, 'invalid-argument');
  h.db.records.get('drivers/a').currentRideId = 'new'; await reject(update(h, 'arriving'), 'invalid-transition');
  h.db.records.delete('rides/x'); await reject(update(h, 'arriving'), 'invalid-transition');
});
test('arrival checks 200m distance and freshness including exact 60s boundary', async () => {
  for (const extra of [{ location: { geopoint: new GeoPoint(32, 36) } }, { lastSeenAt: ts(-59001) }, { lastSeenAt: ts(1001) }, { location: null }, { lastSeenAt: null }]) {
    const h = setup('arriving'); Object.assign(h.db.records.get('drivers/a'), extra);
    const before = new Map(h.db.records); await reject(update(h, 'arrived'), 'too-far'); assert.deepEqual(h.db.records, before);
  }
  const h = setup('arriving'); h.db.records.get('drivers/a').lastSeenAt = ts(-59000); await update(h, 'arrived');
});
test('fare floor, duration, cap, rounding and configured vehicle rates', async () => {
  for (const [seconds, expected] of [[0, 2.5], [1200, 3], [6000, 3.75], [1230, 3.05]]) {
    const h = setup('in_progress'); h.setTime(1000 + seconds * 1000); await update(h, 'completed');
    assert.equal(h.db.records.get('rides/x').fare.final, expected);
  }
  const h = setup('in_progress', { vehicleType: 'comfort' });
  h.db.records.set('config/pricing', { ...DEFAULT_PRICING, comfort: { base: 3.025, perKm: 0, perMin: 0, minimum: 0 } });
  await update(h, 'completed'); assert.equal(h.db.records.get('rides/x').fare.final, 3.05);
});
test('completion clears pointers, sets ratings and increments earnings once using Amman day', async () => {
  const now = Date.parse('2026-11-16T22:00:00Z');
  const h = setup('in_progress', { startedAt: ts(now - 1200000) }); h.setTime(now);
  h.db.records.set('drivers/a/earnings/2026-11-17', { total: 0.1, trips: 2 });
  await Promise.all([update(h, 'completed'), update(h, 'completed')]);
  assert.equal(h.db.records.get('users/rider').activeRideId, undefined);
  assert.equal(h.db.records.get('users/rider').pendingRatingRideId, 'x');
  assert.equal(h.db.records.get('drivers/a').currentRideId, null);
  assert.equal(h.db.records.get('drivers/a').pendingRatingRideId, 'x');
  assert.deepEqual(h.db.records.get('drivers/a/earnings/2026-11-17'), { total: 3.1, trips: 3, updatedAt: ts(now) });
  const other = setup('in_progress'); other.db.records.get('users/rider').activeRideId = 'new';
  await update(other, 'completed'); assert.equal(other.db.records.get('users/rider').activeRideId, 'new');
});
test('invalid pricing and missing start roll back', async () => {
  for (const badPricing of [false, true]) {
    const h = setup('in_progress');
    if (badPricing) h.db.records.set('config/pricing', {}); else delete h.db.records.get('rides/x').startedAt;
    const before = new Map(h.db.records); await assert.rejects(update(h, 'completed')); assert.deepEqual(h.db.records, before);
  }
});
test('driver cancel re-dispatches, excludes driver, preserves sequence and counts once', async () => {
  for (const status of ['accepted', 'arriving', 'arrived']) {
    const h = setup(status, { driverInfo: { name: 'Old' }, arrivingAt: ts(1), arrivedAt: ts(2), offerSeq: 7 });
    h.db.records.get('drivers/a').cancelCount = 2;
    assert.deepEqual(await cancelRideHandler(req(), h.db, h.deps), { ok: true, redispatched: true });
    const r = h.db.records.get('rides/x');
    assert.equal(r.status, 'searching'); assert.equal(r.driverId, null); assert.equal(r.driverInfo, undefined);
    assert.equal(r.arrivingAt, undefined); assert.equal(r.arrivedAt, undefined);
    assert.equal(r.searchExpiresAt.toMillis(), 121000); assert.equal(r.offerSeq, 7); assert.equal(r.offeredTo, null);
    assert.deepEqual(r.declinedBy, ['a']); assert.equal(h.db.records.get('drivers/a').cancelCount, 3);
    assert.equal(h.db.records.get('drivers/a').currentRideId, null); assert.equal(h.db.records.get('users/rider').activeRideId, 'x');
    assert.equal(h.tasks[0].data.seq, 'retry');
    await reject(cancelRideHandler(req(), h.db, h.deps), null, 'permission-denied');
  }
  const h = setup(); h.db.records.set('drivers/b', driver(0.001));
  await cancelRideHandler(req(), h.db, h.deps); assert.equal(h.db.records.get('rides/x').offeredTo, 'b');
  assert.equal(h.notifications[0].uid, 'b');
});
test('no cancel in progress or completed; rider cancellation frees assigned driver', async () => {
  for (const status of ['in_progress', 'completed']) for (const uid of ['a', 'rider']) {
    const h = setup(status); await reject(cancelRideHandler(req(undefined, uid), h.db, h.deps), null);
  }
  for (const status of ['accepted', 'arriving', 'arrived']) {
    const h = setup(status);
    assert.deepEqual(await cancelRideHandler(req(undefined, 'rider'), h.db, h.deps), { ok: true, redispatched: false });
    assert.equal(h.db.records.get('rides/x').status, 'cancelled'); assert.equal(h.db.records.get('drivers/a').currentRideId, null);
  }
});
test('repeat accepted is a no-op and arrival radius rejects just beyond 200m', async () => {
  const h = setup(), before = new Map(h.db.records);
  await update(h, 'accepted'); assert.deepEqual(h.db.records, before);
  for (const [meters, allowed] of [[199.9, true], [200.1, false]]) {
    const h = setup('arriving');
    h.db.records.get('drivers/a').location.geopoint = new GeoPoint(31.9539 + meters / 6371000 * 180 / Math.PI, 35.9106);
    if (allowed) await update(h, 'arrived'); else await reject(update(h, 'arrived'), 'too-far');
  }
});
test('cap rounding preserves an exact half-up tie in fils', async () => {
  const h = setup('in_progress', { fare: { estimated: 2.55, final: null, currency: 'JOD' } });
  h.setTime(6000000); await update(h, 'completed');
  assert.equal(h.db.records.get('rides/x').fare.final, 3.85);
});
