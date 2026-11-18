import { test } from 'node:test';
import assert from 'node:assert/strict';
import { Timestamp } from 'firebase-admin/firestore';
import { FakeFirestore } from './fake-firestore.mjs';
import { createSupportTicketHandler as create, replySupportTicketHandler as reply, setSupportTicketStatusHandler as status, supportMessageCreatedHandler as trigger } from '../lib/support/handlers.js';
const request = (data, uid = 'u', admin = false) => ({ auth: { uid, token: { admin } }, data });
const seed = () => new FakeFirestore({ 'users/u': { role: 'rider' }, 'rides/r': { riderId: 'u', driverId: 'd' } });
const input = { category: 'fare', message: 'Please check my fare', rideId: 'r' };
test('support create validates auth, category, text, IDs and ownership', async () => {
  for (const data of [{}, { ...input, category: 'invalid' }, { ...input, message: '' }, { ...input, message: ' '.repeat(5) }, { ...input, message: 'a'.repeat(1001) }, { ...input, rideId: '../r' }]) {
    await assert.rejects(create(request(data), seed()), { code: 'invalid-argument' });
  }
  await assert.rejects(create({ data: input }, seed()), { code: 'unauthenticated' });
  const db = seed(); db.records.get('rides/r').riderId = 'foreign';
  await assert.rejects(create(request(input), db), { code: 'permission-denied' });
  await assert.rejects(create(request({ ...input, rideId: 'missing' }), seed()), { code: 'permission-denied' });
});
test('support create writes exact ticket and first message, derives role/subject and accepts driver rides', async () => {
  for (const role of ['rider', 'driver']) {
    const db = seed(); db.records.get('users/u').role = role; db.records.get('rides/r').driverId = 'u';
    const { ticketId } = await create(request({ ...input, role: 'admin', subject: 'forged' }), db);
    const ticket = db.records.get(`supportTickets/${ticketId}`);
    assert.equal(ticket.role, role); assert.equal(ticket.subject, 'السعر'); assert.equal(ticket.status, 'open');
    assert.equal(ticket.uid, 'u'); assert.equal(ticket.userUnread, false); assert.equal(ticket.lastMessageBy, 'user');
    assert.deepEqual(Object.keys(ticket).sort(), ['uid','role','rideId','category','subject','status','createdAt','updatedAt','lastMessageAt','lastMessageBy','userUnread'].sort());
    const messages = [...db.records].filter(([path]) => path.startsWith(`supportTickets/${ticketId}/messages/`));
    assert.equal(messages.length, 1); assert.equal(messages[0][1].text, input.message);
    assert.deepEqual(Object.keys(messages[0][1]).sort(), ['from','text','createdAt'].sort());
  }
});
test('support cap counts open and in_progress, ignores closed; concurrent creates stop at five', async () => {
  const db = seed();
  db.records.set('supportTickets/closed', { uid: 'u', status: 'closed' });
  const results = await Promise.allSettled(Array.from({ length: 9 }, () => create(request({ category: 'other', message: 'help' }), db)));
  assert.equal(results.filter(r => r.status === 'fulfilled').length, 5);
  for (const r of results.filter(r => r.status === 'rejected')) {
    assert.equal(r.reason.code, 'failed-precondition'); assert.equal(r.reason.details.reason, 'too-many-open');
  }
  const first = results.find(r => r.status === 'fulfilled').value.ticketId;
  db.records.get(`supportTickets/${first}`).status = 'in_progress';
  await assert.rejects(create(request(input), db), { code: 'failed-precondition' });
  db.records.get(`supportTickets/${first}`).status = 'closed';
  await create(request(input), db);
});
test('support reply updates unread/status, message, push and audit; failures do not duplicate reply', async () => {
  const db = seed(), { ticketId } = await create(request(input), db); const pushes = [];
  await reply(request({ ticketId, text: 'We can help' }, 'a', true), db, async (...args) => pushes.push(args));
  assert.deepEqual(pushes, [['u','rider',ticketId]]);
  const ticket = db.records.get(`supportTickets/${ticketId}`);
  assert.equal(ticket.userUnread, true); assert.equal(ticket.lastMessageBy, 'admin'); assert.equal(ticket.status, 'in_progress');
  assert.equal([...db.records.values()].filter(d => d.from === 'admin').length, 1);
  assert.equal([...db.records.values()].filter(d => d.action === 'replySupportTicket' && d.by === 'a').length, 1);
  await reply(request({ ticketId, text: 'Again' }, 'a', true), db, async () => { throw Error('offline'); });
  assert.equal([...db.records.values()].filter(d => d.from === 'admin').length, 2);
});
test('support admin validation, status changes and non-admin rejection', async () => {
  const db = seed(), { ticketId } = await create(request(input), db);
  for (const req of [request({ ticketId, text: 'reply', status: 'closed' }), { data: { ticketId } }]) {
    await assert.rejects(reply(req, db, async () => {}), { code: 'permission-denied' });
    await assert.rejects(status(req, db), { code: 'permission-denied' });
  }
  for (const data of [{ ticketId, text: '' }, { ticketId, text: 'a'.repeat(1001) }, { ticketId: 'bad/path', text: 'hello' }])
    await assert.rejects(reply(request(data, 'a', true), db, async () => {}), { code: 'invalid-argument' });
  await assert.rejects(status(request({ ticketId, status: 'bogus' }, 'a', true), db), { code: 'invalid-argument' });
  await assert.rejects(status(request({ ticketId: 'missing', status: 'closed' }, 'a', true), db), { code: 'not-found' });
  for (const next of ['in_progress', 'closed', 'open', 'closed']) {
    await status(request({ ticketId, status: next }, 'a', true), db);
    assert.equal(db.records.get(`supportTickets/${ticketId}`).status, next);
  }
  assert.equal([...db.records.values()].filter(d => d.action === 'setSupportTicketStatus').length, 4);
  await assert.rejects(reply(request({ ticketId, text: 'hello' }, 'a', true), db, async () => {}), { code: 'failed-precondition' });
});
test('support trigger preserves status/unread and newer metadata, handles duplicate/out-of-order delivery', async () => {
  const db = seed(), { ticketId } = await create(request(input), db), ticket = db.records.get(`supportTickets/${ticketId}`);
  ticket.status = 'in_progress'; ticket.userUnread = true;
  const at = Timestamp.fromMillis(ticket.lastMessageAt.toMillis() + 1000);
  await trigger(db, ticketId, { from: 'user', createdAt: at });
  assert.equal(db.records.get(`supportTickets/${ticketId}`).lastMessageAt, at);
  assert.equal(db.records.get(`supportTickets/${ticketId}`).status, 'in_progress');
  assert.equal(db.records.get(`supportTickets/${ticketId}`).userUnread, true);
  for (const msg of [{ from: 'user', createdAt: at }, { from: 'user', createdAt: Timestamp.fromMillis(1) }, { from: 'admin', createdAt: Timestamp.fromMillis(at.toMillis() + 1) }]) await trigger(db, ticketId, msg);
  assert.equal(db.records.get(`supportTickets/${ticketId}`).lastMessageAt, at);
  await trigger(db, 'missing', { from: 'user', createdAt: at });
});
