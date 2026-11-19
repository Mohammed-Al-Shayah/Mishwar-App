import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { limitOtpSms } from '../lib/auth/otpLimits.js';
import { FakeFirestore } from './fake-firestore.mjs';
import { getIPV6Address } from '../lib/auth/ip.js';
import { callableOptions, enforceAppCheck } from '../lib/lib/callable.js';

const hour = 3600000, day = 24 * hour, start = 1700000000000;
const request = (phone = '+970591234567', ip = '192.0.2.1') => ({ additionalUserInfo: { phoneNumber: phone }, ipAddress: ip });
const limited = error => error.code === 'resource-exhausted';
test('number: 3/hour, 5/day, exact sliding-window rollover', async () => {
  const db = new FakeFirestore(), event = request();
  for (let n = 0; n < 3; n++) await limitOtpSms(event, db, start + n);
  await assert.rejects(limitOtpSms(event, db, start + hour - 1), limited);
  await limitOtpSms(event, db, start + hour);
  await limitOtpSms(event, db, start + hour + 1);
  await assert.rejects(limitOtpSms(event, db, start + 2 * hour), limited);
  await limitOtpSms(event, db, start + day);
  assert.equal([...db.records.values()][0].sends.length, 5);
});
test('IP: ten across numbers, denial changes neither counter, and rollover', async () => {
  const db = new FakeFirestore();
  for (let n = 0; n < 10; n++) await limitOtpSms(request('+96279000000' + n), db, start);
  const snapshot = JSON.stringify([...db.records]);
  await assert.rejects(limitOtpSms(request('+970561234567'), db, start + hour - 1), limited);
  assert.equal(JSON.stringify([...db.records]), snapshot);
  await limitOtpSms(request('+970561234567'), db, start + hour);
});
test('concurrent requests cannot exceed number limit', async () => {
  const db = new FakeFirestore();
  const results = await Promise.allSettled(Array.from({ length: 12 }, () => limitOtpSms(request(), db, start)));
  assert.equal(results.filter(r => r.status === 'fulfilled').length, 3);
});
test('phone/IP are SHA256 domain-separated; documents contain only times and expiry', async () => {
  const db = new FakeFirestore();
  await limitOtpSms(request(), db, start);
  for (const [kind, value] of [['phone', '+970591234567'], ['ip', '192.0.2.1']]) {
    const id = createHash('sha256').update(kind + ':' + value).digest('hex');
    const data = db.records.get('otpLimits/' + id);
    assert.deepEqual(Object.keys(data).sort(), ['expiresAt', 'sends']);
    assert.deepEqual(data.sends, [start]);
  }
  assert.equal(JSON.stringify([...db.records]).includes('+970'), false);
});
test('unsupported phones/missing IP fail closed; both countries allowed', async () => {
  const db = new FakeFirestore();
  for (const phone of ['+12025550123', '+962761234567', '+970581234567', '+970591234567\n', '']) {
    await assert.rejects(limitOtpSms(request(phone), db, start), error => error.code === 'invalid-argument');
  }
  await assert.rejects(limitOtpSms(request('+970591234567', ''), db, start));
  assert.equal(db.records.size, 0);
  await limitOtpSms(request('+962771234567'), db, start);
  await limitOtpSms(request('+970561234567'), db, start);
});
test('canonical IP spelling cannot bypass counters', () => {
  assert.equal(getIPV6Address('2001:0db8:0000:0000:0000:0000:0000:0001'), '2001:db8::1');
  assert.equal(getIPV6Address('::ffff:192.0.2.1'), '192.0.2.1');
});
test('shared callable options always carry enforcement param, including maps secrets', () => {
  const secret = {};
  assert.equal(callableOptions().enforceAppCheck, enforceAppCheck);
  assert.deepEqual(callableOptions({ secrets: [secret] }).secrets, [secret]);
});
