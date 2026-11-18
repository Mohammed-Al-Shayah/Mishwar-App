/* global Response */
import process from 'node:process';
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { initializeApp, deleteApp } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { loadAppConfig } from '../lib/lib/appConfig.js';
import { fareEstimatesHandler } from '../lib/getFareEstimates.js';
import { requestRideHandler } from '../lib/rides/handlers.js';
import { scheduleRideHandler } from '../lib/rides/scheduled.js';
import { updateRideStatusHandler } from '../lib/rides/lifecycle.js';
import { DEFAULT_PRICING } from '../lib/pricing.js';

test('emulator: airport config, immediate/scheduled quotes, completion fees/promo and disabled pricing', async () => {
  const host = process.env.FIRESTORE_EMULATOR_HOST ?? '127.0.0.1:8080';
  assert.match(host, /^(localhost|127\.0\.0\.1):[0-9]+$/);
  process.env.FIRESTORE_EMULATOR_HOST = host;
  const app = initializeApp({ projectId: 'demo-mishwar-airport' }, 'airport-' + process.pid);
  const db = getFirestore(app), uid = 'airport-' + process.pid;
  const time = Timestamp.now();
  const zone = { type: 'Polygon', coordinates: [[[35.965,31.705],[36.015,31.705],[36.015,31.745],[35.965,31.745],[35.965,31.705]]] };
  const outside = { lat: 31.95, lng: 35.91, name: 'Amman', address: 'Amman' };
  const inside = { lat: 31.7226, lng: 35.9932, name: 'Airport', address: 'Arrivals' };
  const estimate = (req, key) => fareEstimatesHandler(req, key,
    async () => Response.json({ routes: [{ distanceMeters: 90000, duration: '9000s', polyline: { encodedPolyline: 'abc' } }] }),
    async () => DEFAULT_PRICING, () => loadAppConfig(db));
  const request = (pickup, dropoff, extra = {}) => ({ auth: { uid }, data: { pickup, dropoff, vehicleType: 'economy', paymentMethod: 'cash', ...extra } });
  const ids = [];
  try {
    await db.doc('config/app').set({ airport: { zone: JSON.stringify(zone), fixedFares: { economy: 12, comfort: 16, van: 20 }, pickupPoints: [{ id: 'gate1', name: 'Gate 1', lat: inside.lat, lng: inside.lng }] } });
    await db.doc('users/' + uid).set({ role: 'rider', balanceDueFils: 500 });
    await db.doc('promos/HALF').set({ type: 'percent', value: 50, maxDiscount: 10, firstRideOnly: false, perUserLimit: 5, usedCount: 0, usageLimit: 100, active: true,
      validFrom: Timestamp.fromMillis(time.toMillis() - 60000), validUntil: Timestamp.fromMillis(time.toMillis() + 86400000) });
    const immediate = await requestRideHandler(request(outside, inside, { flightNumber: ' rj 182 ', promoCode: 'HALF' }), db, '', estimate, () => time);
    ids.push(immediate.rideId);
    const ref = db.doc('rides/' + immediate.rideId);
    const stored = (await ref.get()).data();
    assert.equal(stored.fare.estimated, 12);
    assert.deepEqual(stored.airport, { direction: 'to_airport', flightNumber: 'RJ 182', fixedFare: true });
    const scheduled = await scheduleRideHandler(request(inside, outside, { vehicleType: 'van', scheduledFor: time.toMillis() + 3600000 }), db, '', undefined, estimate, () => time);
    ids.push(scheduled.rideId);
    const future = (await db.doc('rides/' + scheduled.rideId).get()).data();
    assert.equal(future.fare.estimated, 20);
    assert.equal(future.airport.direction, 'from_airport');
    assert.equal(future.airport.flightNumber, undefined);
    await ref.update({ driverId: uid, status: 'in_progress', arrivedAt: time, startedAt: Timestamp.fromMillis(time.toMillis() + 241000) });
    await db.doc('drivers/' + uid).set({ currentRideId: ref.id });
    await updateRideStatusHandler({ auth: { uid }, data: { rideId: ref.id, status: 'completed' } }, db, () => Timestamp.fromMillis(time.toMillis() + 3600000));
    const completed = (await ref.get()).data();
    assert.equal(completed.fare.final, 6.6);
    assert.equal(completed.fare.discount, 6);
    assert.equal(completed.fare.waitingFee, 0.1);
    assert.equal(completed.fare.previousBalance, 0.5);
    await db.doc('config/app').set({});
    const normal = await estimate({ auth: { uid }, data: { origin: outside, destination: inside } }, '');
    assert.equal(normal.airport, undefined);
    assert.ok(normal.fares[0].amount > 12);
  } finally {
    for (const id of ids) await db.recursiveDelete(db.doc('rides/' + id));
    await db.recursiveDelete(db.doc('users/' + uid));
    await db.recursiveDelete(db.doc('drivers/' + uid));
    await db.recursiveDelete(db.doc('promos/HALF'));
    await db.doc('config/app').delete();
    await deleteApp(app);
  }
});
