import process from 'node:process';
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { FakeFirestore } from './fake-firestore.mjs';
import { sendOfferNotification } from '../lib/notifications/send_offer_notification.js';

const seed = () => new FakeFirestore({ 'users/d': { fcmToken: 'token', role: 'driver' },
  'rides/r': { pickup: { name: 'عمان' }, fare: { estimated: 2.5 } } });
const send = (db, messaging, log = () => {}) => sendOfferNotification(db, messaging, 'd', 'r', log);
test('offer payload and 15 second lifetime', async () => {
  const before = Math.floor(Date.now() / 1000);
  let payload;
  await send(seed(), { send: async (p) => { payload = p; } });
  assert.deepEqual(payload.data, { type: 'ride_offer', rideId: 'r' });
  assert.equal(payload.token, 'token');
  assert.deepEqual(payload.notification, { title: 'طلب مشوار جديد', body: 'عمان · JD 2.50' });
  assert.deepEqual(payload.android, { priority: 'high', ttl: 15000, notification: { channelId: 'ride_offers', sound: 'default' } });
  assert.equal(payload.apns.headers['apns-priority'], '10');
  const expiry = Number(payload.apns.headers['apns-expiration']);
  assert.ok(expiry >= before + 15 && expiry <= Math.floor(Date.now() / 1000) + 15);
  assert.deepEqual(payload.apns.payload, { aps: { sound: 'default' } });
});
test('missing token skips messaging', async () => {
  await send(new FakeFirestore(), { send: () => assert.fail('must skip') });
});

test('scheduled notifications reuse token delivery and emulator logging', async () => {
  let payload;
  const body = 'مشوارك المجدول الساعة ٣:٣٠ م';
  await sendOfferNotification(seed(), { send: async message => { payload = message; } }, 'd', 'r', () => {}, body);
  assert.deepEqual(payload.data, { type: 'scheduled_ride', rideId: 'r' });
  assert.equal(payload.notification.body, body);
  const previous = process.env.FUNCTIONS_EMULATOR;
  process.env.FUNCTIONS_EMULATOR = 'true';
  try {
    const logs = [];
    await sendOfferNotification({}, {}, 'd', 'r', message => logs.push(message), body);
    assert.equal(logs.length, 1); assert.ok(logs[0].includes(body));
  } finally {
    if (previous === undefined) delete process.env.FUNCTIONS_EMULATOR;
    else process.env.FUNCTIONS_EMULATOR = previous;
  }
});
for (const code of ['messaging/registration-token-not-registered', 'messaging/invalid-registration-token']) {
  test(code + ' cleans up only the token used', async () => {
    const db = seed();
    await send(db, { send: async () => { throw { code }; } });
    assert.deepEqual(db.records.get('users/d'), { role: 'driver' });
  });
  test(code + ' preserves a refreshed token', async () => {
    const db = seed();
    await send(db, { send: async () => {
      db.records.set('users/d', { fcmToken: 'new' }); throw { code };
    } });
    assert.equal(db.records.get('users/d').fcmToken, 'new');
  });
}
test('read/send/cleanup/log errors never escape', async () => {
  await send({ doc: () => { throw Error('read'); } }, {}, () => { throw Error('log'); });
  const db = seed(); const logs = [];
  await send(db, { send: async () => { throw Error('network'); } }, (m) => logs.push(m));
  assert.equal(logs.length, 1);
  assert.equal(db.records.get('users/d').fcmToken, 'token');
  db.runTransaction = async () => { throw Error('cleanup'); };
  await send(db, { send: async () => { throw { code: 'messaging/invalid-registration-token' }; } });
});
test('emulator logs without Firestore or FCM', async () => {
  const previous = process.env.FUNCTIONS_EMULATOR;
  process.env.FUNCTIONS_EMULATOR = 'true';
  try {
    const logs = [];
    await send({}, {}, (m) => logs.push(m));
    assert.deepEqual(logs, ['[fcm:emulator] offer r → d']);
  } finally {
    if (previous === undefined) delete process.env.FUNCTIONS_EMULATOR;
    else process.env.FUNCTIONS_EMULATOR = previous;
  }
});
