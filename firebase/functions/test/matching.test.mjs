import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { URL } from 'node:url';
import { geohashForLocation } from 'geofire-common';
import { dispatchRide, offerTimeoutHandler } from '../lib/rides/matching.js';
import { cancelRideHandler, expireSearchingRidesHandler } from '../lib/rides/handlers.js';
import { ts, ride, driver, harness } from './ride-fixtures.mjs';

test('geohash parity with every shared app fixture', () => {
  const fixtures = JSON.parse(readFileSync(new URL('./fixtures/geohash.json', import.meta.url)));
  for (const f of fixtures) assert.equal(geohashForLocation([f.lat, f.lng], f.precision), f.hash);
});
test('nearest eligible driver gets one offer, distance and delayed task', async () => {
  const h = harness({ 'drivers/far': driver(0.02), 'drivers/near': driver(0.001) });
  await dispatchRide(h.db, 'x', h.deps);
  const r = h.db.records.get('rides/x');
  assert.equal(r.offeredTo, 'near'); assert.equal(r.offerSeq, 1);
  assert.equal(r.offerExpiresAt.toMillis(), 16000);
  assert(r.offerDistanceMeters > 100 && r.offerDistanceMeters < 120);
  assert.deepEqual(h.db.records.get('drivers/near').offer, { rideId: 'x', expiresAt: ts(16000), seq: 1, serviceType: 'ride' });
  assert.deepEqual(h.tasks, [{ data: { rideId: 'x', seq: 1 }, delay: 16 }]);
  assert.deepEqual(h.notifications, [{ uid: 'near', rideId: 'x' }]);
  await dispatchRide(h.db, 'x', h.deps); assert.equal(h.tasks.length, 1);
});
test('eligibility filters exclude each ineligible driver', async () => {
  const cases = [driver(0, { isOnline: false }), driver(0, { status: 'pending' }),
    driver(0, { vehicle: { type: 'van' } }), driver(0, { currentRideId: 'other' }),
    driver(0, { offer: { rideId: 'other', expiresAt: ts(1001) } }),
    driver(0, { lastSeenAt: ts(-59001) }), driver(0.06)];
  for (const invalid of cases) {
    const h = harness({ 'drivers/invalid': invalid, 'drivers/good': driver(0.01) });
    await dispatchRide(h.db, 'x', h.deps);
    assert.equal(h.db.records.get('rides/x').offeredTo, 'good');
  }
  for (const [uid, fields] of [['rider', {}], ['declined', { declinedBy: ['declined'] }],
    ['previous', { offeredTo: 'previous', offerExpiresAt: ts(999) }]]) {
    const h = harness({ 'rides/x': ride(fields), ['drivers/' + uid]: driver(), 'drivers/good': driver(0.01) });
    await dispatchRide(h.db, 'x', h.deps); assert.equal(h.db.records.get('rides/x').offeredTo, 'good');
  }
});
test('timeout advances and records previous driver; stale timeout is ignored', async () => {
  const h = harness({ 'drivers/a': driver(), 'drivers/b': driver(0.01) });
  await dispatchRide(h.db, 'x', h.deps); h.setTime(17000);
  await offerTimeoutHandler(h.db, { rideId: 'x', seq: 1 }, h.deps);
  assert.equal(h.db.records.get('rides/x').offeredTo, 'b');
  assert.deepEqual(h.db.records.get('rides/x').declinedBy, ['a']);
  assert.equal(h.db.records.get('drivers/a').offer, null);
  await offerTimeoutHandler(h.db, { rideId: 'x', seq: 1 }, h.deps); assert.equal(h.tasks.length, 2);
});
test('early timeout delivery (emulator) waits out the live offer, then advances', async () => {
  const h = harness({ 'drivers/a': driver(), 'drivers/b': driver(0.01) });
  await dispatchRide(h.db, 'x', h.deps);
  const slept = [];
  await offerTimeoutHandler(h.db, { rideId: 'x', seq: 1 }, h.deps, async (ms) => { slept.push(ms); h.setTime(17000); });
  assert.ok(slept[0] > 0 && slept[0] <= 16250);
  assert.equal(h.db.records.get('rides/x').offeredTo, 'b');
});
test('no candidates clears expired offer and schedules retry before deadline only', async () => {
  const h = harness({ 'rides/x': ride({ offeredTo: 'a', offerExpiresAt: ts(999) }),
    'drivers/a': driver(0, { offer: { rideId: 'x', expiresAt: ts(999) } }) });
  await dispatchRide(h.db, 'x', h.deps);
  assert.equal(h.db.records.get('rides/x').offeredTo, null);
  assert.deepEqual(h.db.records.get('rides/x').declinedBy, ['a']);
  assert.equal(h.db.records.get('drivers/a').offer, null);
  assert.deepEqual(h.tasks, [{ data: { rideId: 'x', seq: 'retry' }, delay: 10 }]);
  h.setTime(110000); await dispatchRide(h.db, 'x', h.deps); assert.equal(h.tasks.length, 1);
  h.setTime(120000); await dispatchRide(h.db, 'x', h.deps); assert.equal(h.tasks.length, 1);
});
test('expired search and non-searching ride do nothing', async () => {
  for (const fields of [{ searchExpiresAt: ts(1000) }, { status: 'accepted' }]) {
    const h = harness({ 'rides/x': ride(fields), 'drivers/a': driver() });
    await dispatchRide(h.db, 'x', h.deps); assert.equal(h.tasks.length, 0);
    assert.equal(h.db.records.get('drivers/a').offer, null);
  }
});
test('concurrent dispatches reserve one driver for at most one ride', async () => {
  const h = harness({ 'rides/y': ride(), 'drivers/a': driver() });
  await Promise.all(['x', 'y'].map((id) => dispatchRide(h.db, id, h.deps)));
  assert.equal(['x', 'y'].filter((id) => h.db.records.get('rides/' + id).offeredTo === 'a').length, 1);
});
test('concurrent dispatches of same ride create one offer and one timeout', async () => {
  const h = harness({ 'drivers/a': driver(), 'drivers/b': driver(0.01) });
  await Promise.all([dispatchRide(h.db, 'x', h.deps), dispatchRide(h.db, 'x', h.deps)]);
  assert.equal(h.db.records.get('rides/x').offerSeq, 1);
  assert.equal(h.db.records.get('drivers/b').offer, null);
  assert.equal(h.tasks.length, 1);
});
test('expired offers elsewhere and freshness at 60 seconds remain eligible', async () => {
  const h = harness({ 'drivers/a': driver(0, { lastSeenAt: ts(-59000),
    offer: { rideId: 'other', expiresAt: ts(1000) } }) });
  await dispatchRide(h.db, 'x', h.deps);
  assert.equal(h.db.records.get('rides/x').offeredTo, 'a');
});
test('timeout cleanup preserves a previous driver offer for another ride', async () => {
  const h = harness({ 'rides/x': ride({ offeredTo: 'a', offerExpiresAt: ts(999) }),
    'drivers/a': driver(0, { offer: { rideId: 'other', expiresAt: ts(30000) } }) });
  await dispatchRide(h.db, 'x', h.deps);
  assert.equal(h.db.records.get('drivers/a').offer.rideId, 'other');
  assert.deepEqual(h.db.records.get('rides/x').declinedBy, ['a']);
});
test('candidate losing eligibility inside transaction advances to next driver', async () => {
  const h = harness({ 'drivers/a': driver(), 'drivers/b': driver(0.01) });
  const run = h.db.runTransaction.bind(h.db); let first = true;
  h.db.runTransaction = (body) => { if (first) { first = false; h.db.records.get('drivers/a').isOnline = false; } return run(body); };
  await dispatchRide(h.db, 'x', h.deps); assert.equal(h.db.records.get('rides/x').offeredTo, 'b');
});
test('cancel clears offers and assigned ride without clearing newer pointers', async () => {
  for (const newer of [false, true]) {
    const h = harness({ 'rides/x': ride({ offeredTo: 'a', driverId: 'b' }),
      'drivers/a': driver(0, { offer: { rideId: newer ? 'new' : 'x' } }),
      'drivers/b': driver(0, { currentRideId: newer ? 'new' : 'x' }) });
    await cancelRideHandler({ auth: { uid: 'rider' }, data: { rideId: 'x' } }, h.db);
    assert.equal(h.db.records.get('drivers/a').offer?.rideId ?? null, newer ? 'new' : null);
    assert.equal(h.db.records.get('drivers/b').currentRideId, newer ? 'new' : null);
    assert.equal(h.db.records.get('rides/x').offeredTo, null);
  }
});
test('expiry clears driver offer; safety net redispatches only old unexpired searches', async () => {
  const h = harness({ 'drivers/a': driver(0, { offer: { rideId: 'expired', expiresAt: ts(2000) } }),
    'rides/expired': ride({ searchExpiresAt: ts(2000), offeredTo: 'a' }),
    'rides/new': ride({ createdAt: ts(29000) }),
    'rides/live': ride({ offeredTo: 'z', offerExpiresAt: ts(40000) }) });
  h.setTime(30000); await expireSearchingRidesHandler(h.db, ts(30000), h.deps);
  assert.equal(h.db.records.get('rides/expired').status, 'no_drivers');
  assert.equal(h.db.records.get('rides/x').offeredTo, 'a');
  assert.equal(h.db.records.get('rides/new').offeredTo, null);
  assert.equal(h.db.records.get('rides/live').offeredTo, 'z');
  assert.equal(h.tasks.length, 1);
});
test('malformed searching ride (no deadline / pickup) is ignored, never throws', async () => {
  const h = harness({ 'rides/x': ride({ searchExpiresAt: undefined }), 'drivers/a': driver() });
  delete h.db.records.get('rides/x').searchExpiresAt;
  await dispatchRide(h.db, 'x', h.deps);
  assert.equal(h.db.records.get('rides/x').offeredTo, null);
  await expireSearchingRidesHandler(h.db, h.deps.now(), h.deps);
});
