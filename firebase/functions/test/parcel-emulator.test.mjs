import process from 'node:process';
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { initializeApp, deleteApp } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { requestRideHandler } from '../lib/rides/handlers.js';
import { updateRideStatusHandler, adminCompleteParcelHandler } from '../lib/rides/lifecycle.js';

test('emulator: concurrent bad-code attempts persist exactly five, then audited admin completion', async () => {
  const host = process.env.FIRESTORE_EMULATOR_HOST ?? '127.0.0.1:8080';
  assert.match(host, /^(localhost|127\.0\.0\.1):[0-9]+$/);
  process.env.FIRESTORE_EMULATOR_HOST = host;
  const app = initializeApp({ projectId: 'demo-mishwar-parcels' }, 'parcel-lock');
  const db = getFirestore(app), uid = 'parcel-' + process.pid, time = Timestamp.now();
  let id;
  try {
    await db.doc('config/app').set({ services: [{ id: 'parcel', enabled: true }] });
    await db.doc('users/' + uid).set({ role: 'rider' });
    const place = { lat: 31.95, lng: 35.91, name: 'Place', address: 'Address' };
    const sent = [];
    const response = await requestRideHandler({ auth: { uid }, data: {
      pickup: place, dropoff: place, vehicleType: 'economy', paymentMethod: 'cash', serviceType: 'parcel',
      parcel: { recipientName: 'Recipient', recipientPhone: '+962781234567', description: 'Books' },
    } }, db, '', async () => ({ route: { distanceMeters: 5000 }, fares: [{ vehicleType: 'economy', amount: 2.5 }] }), () => time,
    { send: async (...args) => { sent.push(args); } });
    id = response.rideId;
    assert.equal(sent.length, 1);
    assert.equal((await db.doc(`rides/${id}/private/rider`).get()).data().deliveryCode, response.deliveryCode);
    await db.doc('rides/' + id).update({ status: 'in_progress', driverId: uid, startedAt: time });
    await db.doc('drivers/' + uid).set({ currentRideId: id });
    const results = await Promise.allSettled(Array.from({ length: 8 }, () => updateRideStatusHandler({ auth: { uid }, data: { rideId: id, status: 'completed', deliveryCode: 'bad' } }, db, () => time)));
    assert.equal(results.filter(r => r.reason?.details?.reason === 'bad-code').length, 4);
    assert.equal(results.filter(r => r.reason?.details?.reason === 'code-locked').length, 4);
    const ride = (await db.doc('rides/' + id).get()).data();
    assert.equal(ride.parcel.codeAttempts, 5); assert.equal(ride.status, 'in_progress');
    assert.equal(ride.parcel.deliveryCode, undefined);
    await assert.rejects(updateRideStatusHandler({ auth: { uid }, data: { rideId: id, status: 'completed', deliveryCode: response.deliveryCode } }, db), e => e.details?.reason === 'code-locked');
    await adminCompleteParcelHandler({ auth: { uid: 'admin', token: { admin: true } }, data: { rideId: id } }, db, () => time);
    assert.equal((await db.doc('rides/' + id).get()).data().status, 'completed');
    assert.equal((await db.collection('adminLog').where('target', '==', id).get()).size, 1);
  } finally {
    if (id) {
      await db.recursiveDelete(db.doc('rides/' + id));
      const logs = await db.collection('adminLog').where('target', '==', id).get();
      for (const log of logs.docs) await log.ref.delete();
    }
    await db.recursiveDelete(db.doc('users/' + uid));
    await db.recursiveDelete(db.doc('drivers/' + uid));
    await db.doc('config/app').delete();
    await deleteApp(app);
  }
});
