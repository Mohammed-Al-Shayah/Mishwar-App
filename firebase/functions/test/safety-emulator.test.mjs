import process from 'node:process';
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { initializeApp, deleteApp } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { createShareLinkHandler, sharedTripHandler, ShareRateLimiter } from '../lib/safety/handlers.js';

test('emulator: concurrent share creation retries the transaction and preserves one token', async () => {
  const host = process.env.FIRESTORE_EMULATOR_HOST ?? '127.0.0.1:8080';
  assert.match(host, /^(localhost|127\.0\.0\.1):[0-9]+$/);
  process.env.FIRESTORE_EMULATOR_HOST = host;
  const app = initializeApp({ projectId: 'demo-mishwar-safety' }, 'share-race');
  const db = getFirestore(app), id = 'share-' + process.pid, ref = db.doc('rides/' + id);
  try {
    await ref.set({ riderId: id, status: 'accepted' });
    const request = { auth: { uid: id }, data: { rideId: id } };
    const results = await Promise.all(Array.from({ length: 4 }, () => createShareLinkHandler(request, db, 'https://example.test')));
    assert.equal(new Set(results.map(result => result.url)).size, 1);
    const token = results[0].url.split('/').at(-1), share = await db.doc('shares/' + token).get();
    assert.equal(share.data().rideId, id);
    assert.equal((await sharedTripHandler(token, db, new ShareRateLimiter())).status, 200);
    await ref.update({ status: 'completed', completedAt: Timestamp.fromMillis(Date.now() - 1800001) });
    assert.equal((await sharedTripHandler(token, db, new ShareRateLimiter())).status, 410);
  } finally {
    const shares = await db.collection('shares').where('rideId', '==', id).get();
    const batch = db.batch(); batch.delete(ref);
    for (const doc of shares.docs) batch.delete(doc.ref);
    await batch.commit(); await deleteApp(app);
  }
});
