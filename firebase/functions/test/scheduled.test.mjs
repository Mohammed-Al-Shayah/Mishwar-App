import { test } from 'node:test';
import assert from 'node:assert/strict';
import { Timestamp } from 'firebase-admin/firestore';
import { FakeFirestore } from './fake-firestore.mjs';
import { scheduleRideHandler, dispatchScheduledRidesHandler, defaultScheduling, schedulingReader } from '../lib/rides/scheduled.js';
import { cancelRideHandler } from '../lib/rides/handlers.js';
import { dispatchRide } from '../lib/rides/matching.js';

const clock = 1800000000000;
const now = () => Timestamp.fromMillis(clock);
const config = async () => defaultScheduling;
const point = { lat: 31.95, lng: 35.91, name: 'Place', address: 'Address' };
const input = { pickup: point, dropoff: point, vehicleType: 'economy', paymentMethod: 'cash' };
const req = (scheduledFor) => ({ auth: { uid: 'rider' }, data: { ...input, scheduledFor, fare: { estimated: 0 } } });
const estimate = async request => {
  assert.deepEqual(request.data, { origin: point, destination: point });
  return { route: { distanceMeters: 5000, durationSeconds: 600, polyline: 'abc' }, fares: [{ vehicleType: 'economy', amount: 2.5 }] };
};
const store = () => new FakeFirestore({ 'users/rider': { role: 'rider', activeRideId: 'current' } });
const book = (db, time) => scheduleRideHandler(req(time), db, '', config, estimate, now);
const scheduled = minutes => ({ riderId: 'rider', status: 'scheduled', scheduledFor: Timestamp.fromMillis(clock + minutes * 60000) });
function deps() {
  const notifications = [], matches = [];
  return { now, config, notifications, matches,
    notify: async (...args) => { notifications.push(args); }, dispatch: async id => { matches.push(id); } };
}
test('window is inclusive; accepts ISO and millis; rejects malformed, too soon and too far', async () => {
  for (const time of [clock + 1800000, new Date(clock + 30 * 86400000).toISOString()]) {
    const db = store(); const { rideId } = await book(db, time);
    const ride = db.records.get(`rides/${rideId}`);
    assert.equal(ride.status, 'scheduled'); assert.equal(ride.fare.estimated, 2.5);
    assert.equal(ride.searchExpiresAt, undefined); assert.equal(db.records.get('users/rider').activeRideId, 'current');
    assert(ride.scheduledFor instanceof Timestamp);
  }
  for (const time of [clock + 1799999, clock + 30 * 86400000 + 1, 'bad', null, Infinity, '2026-12-01']) {
    await assert.rejects(book(store(), time), e => e.code === 'invalid-argument');
  }
});
test('requires auth and rider; scheduled cap serializes concurrent bookings', async () => {
  await assert.rejects(scheduleRideHandler({ data: {} }, store(), ''), e => e.code === 'unauthenticated');
  const driver = new FakeFirestore({ 'users/rider': { role: 'driver' } });
  await assert.rejects(book(driver, clock + 1800000), e => e.code === 'permission-denied');
  const db = store(); db.records.set('rides/past', scheduled(-1));
  const results = await Promise.allSettled(Array.from({ length: 5 }, () => book(db, clock + 1800000)));
  assert.equal(results.filter(r => r.status === 'fulfilled').length, 3);
  for (const result of results.filter(r => r.status === 'rejected')) assert.equal(result.reason.details.reason, 'too-many-scheduled');
});
test('config defaults, partial overrides, and instance cache', async () => {
  const db = store(); db.records.set('config/app', { scheduling: { minLeadMinutes: 45, maxDaysAhead: -1 } });
  const read = schedulingReader(db);
  assert.deepEqual(await read(), { ...defaultScheduling, minLeadMinutes: 45 });
  db.records.delete('config/app'); assert.equal((await read()).minLeadMinutes, 45);
  assert.deepEqual(await schedulingReader(db)(), defaultScheduling);
});
test('reminder occurs once, inclusive at 60 minutes; concurrent runs dispatch once', async () => {
  const db = new FakeFirestore({ 'users/rider': { role: 'rider' }, 'rides/soon': scheduled(60), 'rides/later': scheduled(61) });
  const d = deps(); await Promise.all([dispatchScheduledRidesHandler(db, d), dispatchScheduledRidesHandler(db, d)]);
  assert.equal(d.notifications.length, 1); assert.match(d.notifications[0][2], /مشوارك المجدول الساعة/);
  assert.equal(d.matches.length, 0); assert.equal(db.records.get('rides/later').reminderSentAt, undefined);
  db.records.set('rides/soon', { ...db.records.get('rides/soon'), scheduledFor: scheduled(15).scheduledFor });
  await Promise.all([dispatchScheduledRidesHandler(db, d), dispatchScheduledRidesHandler(db, d)]);
  const ride = db.records.get('rides/soon'); assert.equal(ride.status, 'searching');
  assert.equal(ride.searchExpiresAt.toMillis(), clock + 20 * 60000);
  assert.equal(db.records.get('users/rider').activeRideId, 'soon'); assert.deepEqual(d.matches, ['soon']);
});
test('late dispatch gives two minutes; busy rider cancels with system reason and notification', async () => {
  for (const busy of [false, true]) {
    const db = new FakeFirestore({ 'users/rider': { role: 'rider', ...(busy ? { activeRideId: 'other' } : {}) }, 'rides/soon': scheduled(-10) });
    const d = deps(); await dispatchScheduledRidesHandler(db, d); await dispatchScheduledRidesHandler(db, d);
    const ride = db.records.get('rides/soon');
    if (busy) {
      assert.equal(ride.status, 'cancelled'); assert.equal(ride.cancelledBy, 'system'); assert.equal(ride.cancelReason, 'rider_busy');
      assert.equal(db.records.get('users/rider').activeRideId, 'other'); assert.equal(d.matches.length, 0); assert.equal(d.notifications.length, 2);
    } else assert.equal(ride.searchExpiresAt.toMillis(), clock + 120000);
  }
});
test('scheduled cancellation has no fee, preserves pointer and is idempotent; matching ignores scheduled', async () => {
  const db = store(); db.records.set('rides/soon', scheduled(30));
  await dispatchRide(db, 'soon', { now, enqueue: () => { throw Error('no matching'); }, notify: () => { throw Error('no push'); } });
  for (let i = 0; i < 2; i++) await cancelRideHandler({ auth: { uid: 'rider' }, data: { rideId: 'soon' } }, db);
  const ride = db.records.get('rides/soon'); assert.equal(ride.status, 'cancelled'); assert.equal(ride.cancelledBy, 'rider');
  assert.equal(ride.fare?.cancellationFee, undefined); assert.equal(db.records.get('users/rider').activeRideId, 'current');
  const d = deps(); await dispatchScheduledRidesHandler(db, d); assert.equal(d.notifications.length, 0);
});
