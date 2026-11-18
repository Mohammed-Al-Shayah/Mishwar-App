import { doc, getDoc, setDoc, updateDoc, deleteDoc, collection, query, where, getDocs, serverTimestamp, Timestamp } from 'firebase/firestore';
import { suite, matrix, test, assertSucceeds, assertFails, now } from './helpers.mjs';
const s = suite();
const ticket = { uid: 'owner', role: 'rider', category: 'fare', subject: 'السعر', status: 'open', createdAt: now, updatedAt: now, lastMessageAt: now, lastMessageBy: 'user', userUnread: true };
const message = { from: 'user', text: 'Help', createdAt: now };
matrix(s, 'supportTickets/t', ticket, { read: ['owner','admin'] });
matrix(s, 'supportTickets/t/messages/m', message, { read: ['owner','admin'] }, { 'supportTickets/t': ticket });
for (const status of ['open','in_progress','closed']) for (const actor of ['anonymous','owner','other','admin']) {
  test(`support message create ${actor} ${status}`, async () => {
    await s.seed({ 'supportTickets/t': { ...ticket, status } });
    await (actor === 'owner' && status !== 'closed' ? assertSucceeds : assertFails)(
      setDoc(doc(s.db(actor), 'supportTickets/t/messages/new'), { ...message, createdAt: serverTimestamp() }));
  });
}
for (const invalid of [{ from: 'admin' }, { text: '' }, { text: 'a'.repeat(1001) }, { text: 123 }, { createdAt: Timestamp.fromMillis(1) }, { extra: true }]) {
  test(`support invalid user message ${JSON.stringify(invalid).slice(0,60)}`, async () => {
    await s.seed({ 'supportTickets/t': ticket });
    await assertFails(setDoc(doc(s.db(), 'supportTickets/t/messages/new'), { ...message, createdAt: serverTimestamp(), ...invalid }));
  });
}
test('support required fields, boundary lengths and missing parent', async () => {
  await s.seed({ 'supportTickets/t': ticket });
  for (const key of ['from','text','createdAt']) {
    const value = { ...message, createdAt: serverTimestamp() }; delete value[key];
    await assertFails(setDoc(doc(s.db(), `supportTickets/t/messages/${key}`), value));
  }
  for (const length of [1,1000]) await assertSucceeds(setDoc(doc(s.db(), `supportTickets/t/messages/b${length}`), { ...message, text: 'a'.repeat(length), createdAt: serverTimestamp() }));
  await assertFails(setDoc(doc(s.db(), 'supportTickets/missing/messages/m'), { ...message, createdAt: serverTimestamp() }));
});
for (const actor of ['anonymous','owner','other','admin']) test(`support unread false ${actor}`, async () => {
  await s.seed({ 'supportTickets/t': ticket });
  await (actor === 'owner' ? assertSucceeds : assertFails)(updateDoc(doc(s.db(actor), 'supportTickets/t'), { userUnread: false }));
});
for (const change of [{ userUnread: true }, { userUnread: 0 }, { userUnread: false, status: 'closed' }, { uid: 'other' }, { lastMessageBy: 'admin' }]) test(`support rejects metadata ${JSON.stringify(change)}`, async () => {
  await s.seed({ 'supportTickets/t': { ...ticket, userUnread: false } });
  await assertFails(updateDoc(doc(s.db(), 'supportTickets/t'), change));
});
test('support owner queries own tickets and messages, admin all; unfiltered owner denied', async () => {
  await s.seed({ 'supportTickets/t': ticket, 'supportTickets/t/messages/m': message });
  await assertSucceeds(getDocs(query(collection(s.db(), 'supportTickets'), where('uid','==','owner'))));
  await assertSucceeds(getDocs(collection(s.db('admin'), 'supportTickets')));
  await assertFails(getDocs(collection(s.db(), 'supportTickets')));
  await assertSucceeds(getDocs(collection(s.db(), 'supportTickets/t/messages')));
  await assertFails(getDoc(doc(s.db('other'), 'supportTickets/t/messages/m')));
  await assertFails(deleteDoc(doc(s.db(), 'supportTickets/t')));
});
