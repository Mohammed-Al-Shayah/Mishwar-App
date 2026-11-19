import { test } from 'node:test';
import assert from 'node:assert/strict';
import { cancellationFeeFils, waitingFeeFils, defaultFees, feeConfigReader, earningsDay } from '../lib/rides/fees.js';
import { cancelRideHandler, cancellationQuoteHandler } from '../lib/rides/handlers.js';
import { updateRideStatusHandler } from '../lib/rides/lifecycle.js';
import { harness, ride, driver, ts } from './ride-fixtures.mjs';
const req = (uid = 'rider', rideId = 'x') => ({ auth: { uid }, data: { rideId } });

test('cancellation strict window, eligible statuses and late-driver ETA edges', () => {
  for (const status of ['accepted', 'arriving', 'arrived']) {
    const r = { status, acceptedAt: ts(0), offerDistanceMeters: 4000 };
    assert.equal(cancellationFeeFils(r, ts(120000)), 0);
    assert.equal(cancellationFeeFils(r, ts(120001)), 500);
    assert.equal(cancellationFeeFils(r, ts(1200000)), 500);
    assert.equal(cancellationFeeFils(r, ts(1200001)), status === 'arriving' ? 0 : 500);
  }
  for (const status of ['searching', 'scheduled', 'cancelled', 'in_progress', 'completed'])
    assert.equal(cancellationFeeFils({ status, acceptedAt: ts(0) }, ts(200000)), 0);
  assert.equal(cancellationFeeFils({ status: 'accepted' }, ts(200000)), 0);
  const r = { status: 'arriving', acceptedAt: ts(0), offerDistanceMeters: 1 };
  assert.equal(cancellationFeeFils(r, ts(600000)), 500);
  assert.equal(cancellationFeeFils(r, ts(600001)), 0);
});
test('waiting rounds chargeable time up, with zero at the free boundary', () => {
  for (const [seconds, expected] of [[0, 0], [179, 0], [180, 0], [181, 50], [240, 50], [241, 100], [1800, 1350]])
    assert.equal(waitingFeeFils(ts(0), ts(seconds * 1000)), expected);
  assert.equal(waitingFeeFils(undefined, ts(500000)), 0);
});
test('config defaults, overrides, invalid values, cache and failed-read retry', async () => {
  const h = harness();
  assert.deepEqual(await feeConfigReader(h.db)(), defaultFees);
  h.db.records.set('config/app', { cancellationFee: { afterSeconds: 0, amount: 0.73 }, waitingFee: { freeMinutes: -1, perMinute: 0.1 } });
  const read = feeConfigReader(h.db);
  const config = await read();
  assert.deepEqual(config, { cancellationFee: { afterSeconds: 0, amount: 0.73 }, waitingFee: { freeMinutes: 3, perMinute: 0.1 } });
  assert.equal(cancellationFeeFils({ status: 'accepted', acceptedAt: ts(0) }, ts(1), config), 750);
  h.db.records.delete('config/app');
  assert.deepEqual(await read(), config);
  let attempts = 0;
  const retry = feeConfigReader({ doc: () => ({ get: async () => { if (++attempts === 1) throw Error('offline'); return { data: () => ({}) }; } }) });
  await assert.rejects(retry());
  assert.deepEqual(await retry(), defaultFees);
});
test('quote matches cancellation; balance and driver credit are atomic and idempotent', async () => {
  const h = harness({ 'rides/x': ride({ status: 'accepted', driverId: 'a', acceptedAt: ts(0), fare: { estimated: 2.5 } }),
    'drivers/a': driver(0, { currentRideId: 'x' }), 'users/rider': { balanceDueFils: 100, activeRideId: 'x' } });
  h.setTime(120001);
  const quote = await cancellationQuoteHandler(req(), h.db, undefined, h.deps.now);
  assert.deepEqual(quote, { fee: 0.5, currency: 'JOD' });
  await Promise.all([cancelRideHandler(req(), h.db, h.deps), cancelRideHandler(req(), h.db, h.deps)]);
  assert.equal(h.db.records.get('rides/x').fare.cancellationFee, quote.fee);
  assert.equal(h.db.records.get('users/rider').balanceDue.JOD, 600);
  const earnings = h.db.records.get('drivers/a/earnings/' + earningsDay(h.deps.now()) + '_JO');
  assert.equal(earnings.total, 0.5); assert.equal(earnings.cancellationFees, 0.5); assert.equal(earnings.trips, 0);
  await assert.rejects(cancellationQuoteHandler(req('a'), h.db), e => e.code === 'permission-denied');
  await assert.rejects(cancellationQuoteHandler({ data: { rideId: 'x' } }, h.db), e => e.code === 'unauthenticated');
  await assert.rejects(cancellationQuoteHandler(req('rider', 'missing'), h.db), e => e.code === 'not-found');
});
test('completion combines promo trip-only discount, waiting and previous balance, then clears once', async () => {
  const h = harness({ 'rides/x': ride({ status: 'in_progress', driverId: 'a', arrivedAt: ts(0), startedAt: ts(241000), route: { distanceMeters: 0 }, fare: { estimated: 2.5, currency: 'JOD' }, promo: { code: 'HALF' } }),
    'drivers/a': driver(0, { currentRideId: 'x' }), 'users/rider': { activeRideId: 'x', balanceDueFils: 500 },
    'promos/HALF': { type: 'percent', value: 50, maxDiscount: 10, firstRideOnly: false, usedCount: 0, usageLimit: 100, active: true, validFrom: ts(0), validUntil: ts(9999999) } });
  h.setTime(241000);
  const complete = id => updateRideStatusHandler({ auth: { uid: 'a' }, data: { rideId: id, status: 'completed' } }, h.db, h.deps.now);
  await complete('x'); await complete('x');
  const fare = h.db.records.get('rides/x').fare;
  assert.equal(fare.discount, 1.25); assert.equal(fare.waitingFee, 0.1); assert.equal(fare.previousBalance, 0.5); assert.equal(fare.final, 1.85);
  assert.equal(h.db.records.get('users/rider').balanceDue.JOD, 0);
  const path = 'drivers/a/earnings/' + earningsDay(h.deps.now()) + '_JO';
  assert.equal(h.db.records.get(path).total, 1.85);
  h.db.records.set('rides/y', ride({ status: 'in_progress', driverId: 'a', startedAt: ts(241000), route: { distanceMeters: 0 }, fare: { estimated: 2.5 } }));
  h.db.records.get('drivers/a').currentRideId = 'y';
  await complete('y');
  assert.equal(h.db.records.get('rides/y').fare.previousBalance, 0);
  assert.equal(h.db.records.get(path).total, 4.35);
});

test('searching, scheduled and late-driver cancellation never add balance or earnings', async () => {
  for (const status of ['searching', 'scheduled', 'arriving']) {
    const h = harness({ 'rides/x': ride({ status, driverId: status === 'arriving' ? 'a' : null,
      acceptedAt: ts(0), offerDistanceMeters: 1000, fare: { estimated: 2.5 } }),
      'drivers/a': driver(0, { currentRideId: 'x' }) });
    h.setTime(600001);
    assert.deepEqual(await cancellationQuoteHandler(req(), h.db, undefined, h.deps.now), { fee: 0, currency: 'JOD' });
    await cancelRideHandler(req(), h.db, h.deps);
    assert.equal(h.db.records.get('rides/x').fare.cancellationFee, 0);
    assert.equal(h.db.records.get('users/rider').balanceDueFils, undefined);
    assert.equal([...h.db.records.keys()].some(p => p.includes('/earnings/')), false);
  }
});
