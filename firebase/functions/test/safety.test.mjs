import { test } from 'node:test';
import assert from 'node:assert/strict';
import { GeoPoint, Timestamp } from 'firebase-admin/firestore';
import { createShareLinkHandler, sharedTripHandler, ShareRateLimiter } from '../lib/safety/handlers.js';
import { FakeFirestore } from './fake-firestore.mjs';
const time = 1700000000000;
const now = () => Timestamp.fromMillis(time);
const request = { auth: { uid: 'rider' }, data: { rideId: 'trip' } };
const token = 'a'.repeat(24);
const seed = () => new FakeFirestore({ 'rides/trip': {
  riderId: 'rider', status: 'in_progress', driverId: 'secret-id',
  driverInfo: { name: 'Ahmad Private', phone: '+962781234567', vehicle: { make: 'Toyota', model: 'Corolla', color: 'White', plate: '12-345' } },
  riderInfo: { name: 'Private rider' }, pickup: { name: 'Home', address: 'Private address' }, dropoff: { name: 'Work' },
  route: { durationSeconds: 600 },
}, 'rides/trip/live/driver': { geopoint: new GeoPoint(31.95, 35.91), heading: 90, updatedAt: now() } });
async function shared(db = seed()) {
  await createShareLinkHandler(request, db, 'http://127.0.0.1:5002', now, () => token);
  return db;
}
test('share tokens: secure 24-character URL-safe generation and six-hour expiry', async () => {
  const db = seed();
  const { url } = await createShareLinkHandler(request, db, 'https://example.test/', now);
  const generated = url.split('/').at(-1);
  assert.match(generated, /^[A-Za-z0-9_-]{24}$/);
  assert.equal(db.records.get('shares/' + generated).expiresAt.toMillis(), time + 21600000);
});
test('share tokens: concurrent creation is idempotent', async () => {
  const db = seed();
  const results = await Promise.all(Array.from({ length: 8 }, () => createShareLinkHandler(request, db, 'https://example.test', now)));
  assert.equal(new Set(results.map(r => r.url)).size, 1);
  assert.equal([...db.records.keys()].filter(k => k.startsWith('shares/')).length, 1);
});
test('share tokens: authentication, ownership, active status and input validation', async () => {
  for (const [req, code] of [[{ data: request.data }, 'unauthenticated'], [{ ...request, auth: { uid: 'other' } }, 'permission-denied'], [{ ...request, data: { rideId: '../trip' } }, 'invalid-argument']]) {
    await assert.rejects(createShareLinkHandler(req, seed(), 'https://example.test', now), { code });
  }
  for (const status of ['scheduled', 'searching', 'completed', 'cancelled', 'no_drivers']) {
    const db = seed(); db.records.get('rides/trip').status = status;
    await assert.rejects(createShareLinkHandler(request, db, 'https://example.test', now), { code: 'failed-precondition' });
  }
  await assert.rejects(createShareLinkHandler(request, new FakeFirestore(), 'https://example.test', now), { code: 'not-found' });
});
test('public payload has exact sanitized keys, first name only, location and car allowlists', async () => {
  const result = await sharedTripHandler(token, await shared(), new ShareRateLimiter(), time);
  assert.equal(result.status, 200);
  assert.deepEqual(Object.keys(result.body).sort(), ['status','driverFirstName','car','pickupName','dropoffName','driver','etaMinutes','updatedAt'].sort());
  assert.equal(result.body.driverFirstName, 'Ahmad');
  assert.deepEqual(Object.keys(result.body.car).sort(), ['make','model','color','plate'].sort());
  assert.deepEqual(Object.keys(result.body.driver).sort(), ['lat','lng','heading','updatedAt'].sort());
  assert.equal(JSON.stringify(result.body).includes('Private'), false);
  assert.equal(JSON.stringify(result.body).includes('+962'), false);
});
test('public link: invalid, unknown, expired, missing ride and superseded tokens return 404', async () => {
  for (const value of ['bad', undefined, ['a'], 'z'.repeat(24)]) assert.equal((await sharedTripHandler(value, await shared(), new ShareRateLimiter(), time)).status, 404);
  const db = await shared();
  assert.equal((await sharedTripHandler(token, db, new ShareRateLimiter(), time + 21600000)).status, 404);
  db.records.get('rides/trip').shareToken = 'b'.repeat(24);
  assert.equal((await sharedTripHandler(token, db, new ShareRateLimiter(), time)).status, 404);
  db.records.delete('rides/trip');
  assert.equal((await sharedTripHandler(token, db, new ShareRateLimiter(), time)).status, 404);
});
test('terminal rides: completed grace state then 410, cancelled grace then 404; no terminal location', async () => {
  for (const status of ['completed', 'cancelled']) {
    const db = await shared();
    Object.assign(db.records.get('rides/trip'), { status, [status === 'completed' ? 'completedAt' : 'cancelledAt']: now() });
    const recent = await sharedTripHandler(token, db, new ShareRateLimiter(), time + 1000);
    assert.equal(recent.status, 200); assert.equal(recent.body.driver, null);
    assert.equal((await sharedTripHandler(token, db, new ShareRateLimiter(), time + 1800001)).status, status === 'completed' ? 410 : 404);
  }
});
test('rate limit is per token and allows one request per second', async () => {
  const db = await shared(), limiter = new ShareRateLimiter();
  assert.equal((await sharedTripHandler(token, db, limiter, time)).status, 200);
  assert.equal((await sharedTripHandler(token, db, limiter, time + 999)).status, 429);
  assert.equal((await sharedTripHandler('b'.repeat(24), db, limiter, time)).status, 404);
  assert.equal((await sharedTripHandler(token, db, limiter, time + 1000)).status, 200);
});
test('location from a previous assignment is never published after redispatch', async () => {
  const db = await shared();
  db.records.get('rides/trip').acceptedAt = Timestamp.fromMillis(time + 1000);
  assert.equal((await sharedTripHandler(token, db, new ShareRateLimiter(), time + 1000)).body.driver, null);
});
test('expired active share is replaced and old link cannot track', async () => {
  const db = await shared();
  await createShareLinkHandler(request, db, 'https://example.test', () => Timestamp.fromMillis(time + 21600000), () => 'b'.repeat(24));
  assert.equal(db.records.get('rides/trip').shareToken, 'b'.repeat(24));
  assert.equal((await sharedTripHandler(token, db, new ShareRateLimiter(), time + 21600000)).status, 404);
});
