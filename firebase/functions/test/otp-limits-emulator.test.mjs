import process from 'node:process';
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { initializeApp, deleteApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { isSmsSendEvent, limitOtpSms } from '../lib/auth/otpLimits.js';

test('Firestore emulator: concurrent SMS transactions reserve exactly three and roll over', async () => {
  const host = process.env.FIRESTORE_EMULATOR_HOST ?? '127.0.0.1:8080';
  assert.match(host, /^(localhost|127\.0\.0\.1):[0-9]+$/);
  process.env.FIRESTORE_EMULATOR_HOST = host;
  const app = initializeApp({ projectId: 'demo-mishwar-otp' }, 'otp-' + process.pid);
  const db = getFirestore(app);
  const event = { additionalUserInfo: { phoneNumber: '+970591234567' }, ipAddress: '192.0.2.1' };
  const now = 1700000000000;
  try {
    await db.recursiveDelete(db.collection('otpLimits'));
    const results = await Promise.allSettled(Array.from({ length: 6 }, () => limitOtpSms(event, db, now)));
    assert.equal(results.filter(r => r.status === 'fulfilled').length, 3);
    for (const result of results.filter(r => r.status === 'rejected')) assert.equal(result.reason.code, 'resource-exhausted');
    await limitOtpSms(event, db, now + 3600000);
    const docs = await db.collection('otpLimits').get();
    assert.equal(docs.size, 2);
    for (const doc of docs.docs) { assert.match(doc.id, /^[a-f0-9]{64}$/); assert.equal(doc.data().sends.includes(now + 3600000), true); }
  } finally {
    await db.recursiveDelete(db.collection('otpLimits'));
    await deleteApp(app);
  }
});
test('only SMS-send events are limited; sign-in events from the emulator pass through', () => {
  assert.equal(isSmsSendEvent({ eventType: 'providers/cloud.auth/eventTypes/user.beforeSendSms' }), true);
  assert.equal(isSmsSendEvent({ smsType: 'SIGN_IN_OR_SIGN_UP' }), true);
  assert.equal(isSmsSendEvent({ eventType: 'providers/cloud.auth/eventTypes/user.beforeSignIn' }), false);
  assert.equal(isSmsSendEvent({}), false);
});
