import { Timestamp, type Firestore } from 'firebase-admin/firestore';
import { HttpsError, type CallableRequest } from 'firebase-functions/v2/https';
import * as v from '../lib/validate.js';

const subjects: Record<string, string> = { lost_item: 'أغراض منسية', fare: 'السعر', safety: 'الأمان', other: 'غير ذلك' };
const statuses = ['open', 'in_progress', 'closed'];
function id(value: unknown): string {
  const result = v.string(value, 1, 128);
  if (result.includes('/')) v.invalid();
  return result;
}
function user(request: CallableRequest): string {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in required.');
  return request.auth.uid;
}
function admin(request: CallableRequest): string {
  if (request.auth?.token.admin !== true) throw new HttpsError('permission-denied', 'Admin claim required.');
  return request.auth.uid;
}
export async function createSupportTicketHandler(request: CallableRequest, db: Firestore) {
  const uid = user(request), data = v.object(request.data);
  const category = v.string(data.category, 1, 20), message = v.string(data.message, 1, 1000);
  if (!Object.hasOwn(subjects, category)) v.invalid();
  const rideId = data.rideId === undefined ? undefined : id(data.rideId);
  const ref = db.collection('supportTickets').doc();
  const first = db.collection(`${ref.path}/messages`).doc();
  await db.runTransaction(async tx => {
    const profile = (await tx.get(db.doc(`users/${uid}`))).data();
    if (!profile || !['rider', 'driver'].includes(profile.role)) throw new HttpsError('failed-precondition', 'Select a role.');
    if (rideId) {
      const ride = (await tx.get(db.doc(`rides/${rideId}`))).data();
      if (!ride || ![ride.riderId, ride.driverId].includes(uid)) {
        throw new HttpsError('permission-denied', 'Ride does not belong to caller.');
      }
    }
    // Serialize even simultaneous first tickets (an empty query locks no documents).
    const lock = db.doc(`users/${uid}/meta/support`), mutex = (await tx.get(lock)).data();
    const open = await tx.get(db.collection('supportTickets').where('uid', '==', uid)
      .where('status', 'in', ['open', 'in_progress']).limit(5));
    if (open.docs.length >= 5) throw new HttpsError('failed-precondition', 'Too many open tickets.', { reason: 'too-many-open' });
    const at = Timestamp.now();
    tx.set(lock, { version: (mutex?.version ?? 0) + 1 });
    tx.create(ref, { uid, role: profile.role, ...(rideId ? { rideId } : {}), category,
      subject: subjects[category], status: 'open', createdAt: at, updatedAt: at,
      lastMessageAt: at, lastMessageBy: 'user', userUnread: false });
    tx.create(first, { from: 'user', text: message, createdAt: at });
  });
  return { ticketId: ref.id };
}

export type SupportPush = (uid: string, role: string, ticketId: string) => Promise<void>;
export async function replySupportTicketHandler(request: CallableRequest, db: Firestore, push: SupportPush) {
  const by = admin(request), data = v.object(request.data), ticketId = id(data.ticketId), text = v.string(data.text, 1, 1000);
  const ref = db.doc(`supportTickets/${ticketId}`), message = db.collection(`${ref.path}/messages`).doc();
  const log = db.collection('adminLog').doc();
  const ticket = await db.runTransaction(async tx => {
    const ticket = (await tx.get(ref)).data();
    if (!ticket) throw new HttpsError('not-found', 'Ticket not found.');
    if (ticket.status === 'closed') throw new HttpsError('failed-precondition', 'Ticket is closed.');
    const at = Timestamp.now();
    tx.create(message, { from: 'admin', text, createdAt: at });
    tx.update(ref, { userUnread: true, status: ticket.status === 'open' ? 'in_progress' : ticket.status,
      lastMessageAt: at, lastMessageBy: 'admin', updatedAt: at });
    tx.create(log, { action: 'replySupportTicket', target: ticketId, by, at, details: { messageId: message.id } });
    return ticket;
  });
  // Push failures must not cause a retry that duplicates the committed reply.
  try { await push(ticket.uid, ticket.role, ticketId); } catch { /* Best effort. */ }
  return { ok: true };
}
export async function setSupportTicketStatusHandler(request: CallableRequest, db: Firestore) {
  const by = admin(request), data = v.object(request.data), ticketId = id(data.ticketId), status = v.string(data.status, 1, 20);
  if (!statuses.includes(status)) v.invalid();
  const ref = db.doc(`supportTickets/${ticketId}`), log = db.collection('adminLog').doc();
  await db.runTransaction(async tx => {
    const ticket = (await tx.get(ref)).data();
    if (!ticket) throw new HttpsError('not-found', 'Ticket not found.');
    const at = Timestamp.now();
    tx.update(ref, { status, updatedAt: at });
    tx.create(log, { action: 'setSupportTicketStatus', target: ticketId, by, at, details: { from: ticket.status, to: status } });
  });
  return { ok: true };
}
export async function supportMessageCreatedHandler(db: Firestore, ticketId: string, message: Record<string, unknown>) {
  if (message.from !== 'user' || !(message.createdAt instanceof Timestamp)) return;
  const at = message.createdAt, ref = db.doc(`supportTickets/${ticketId}`);
  await db.runTransaction(async tx => {
    const ticket = (await tx.get(ref)).data();
    if (!ticket || (ticket.lastMessageAt instanceof Timestamp && ticket.lastMessageAt.toMillis() >= at.toMillis())) return;
    tx.update(ref, { lastMessageAt: at, lastMessageBy: 'user',
      updatedAt: ticket.updatedAt instanceof Timestamp && ticket.updatedAt.toMillis() > at.toMillis() ? ticket.updatedAt : at });
  });
}
