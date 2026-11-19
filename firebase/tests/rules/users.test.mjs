import { doc, getDoc, setDoc, updateDoc, deleteDoc, deleteField, serverTimestamp, collection, getDocs } from 'firebase/firestore';
import { suite, matrix, profile, now, test, assertSucceeds, assertFails } from './helpers.mjs';
const s = suite();
matrix(s, 'users/owner', profile, { read: ['owner', 'admin'], create: ['owner'] });
test('owner may read a missing profile', () => assertSucceeds(getDoc(doc(s.db(), 'users/owner'))));
test('role-less profile supports first role selection and deletion', async () => {
  await setDoc(doc(s.db(), 'users/owner'), { name: 'New User', phone: '+96278', createdAt: serverTimestamp(), photoUrl: null, fcmToken: null });
  await assertSucceeds(deleteDoc(doc(s.db(), 'users/owner')));
  await setDoc(doc(s.db(), 'users/owner'), { name: 'New User', phone: '+96278' });
  await assertSucceeds(updateDoc(doc(s.db(), 'users/owner'), { role: 'driver' }));
  await assertFails(deleteDoc(doc(s.db(), 'users/owner')));
});
for (const [field, value] of Object.entries({ balanceDueFils: 500, balanceDue: {ILS: 500, JOD: 0}, homeMarket: 'PS', market: 'PS', activeRideId: 'ride', pendingRatingRideId: 'ride', rating: 5, ratingCount: 1, accountDeleting: true, offer: null, currentRideId: null, cancelCount: 0, unknown: true })) {
  test(`users: cannot create server/unknown field ${field}`, () => assertFails(setDoc(doc(s.db(), 'users/owner'), { ...profile, [field]: value })));
  for (const removal of [false, true]) test(`users: cannot ${removal ? 'remove' : 'set'} ${field}`, async () => {
    await s.seed({ 'users/owner': { ...profile, ...(removal ? { [field]: value } : {}) } });
    await assertFails(updateDoc(doc(s.db(), 'users/owner'), { [field]: removal ? deleteField() : value }));
  });
}
for (const [field, values] of Object.entries({ name: ['', 'x', 'x'.repeat(41), 1, null], phone: ['x'.repeat(21), 123, null], role: ['admin', 'invalid', null], photoUrl: [123, 'x'.repeat(2049)], createdAt: ['yesterday', 123], fcmToken: [123, 'x'.repeat(4097)] })) {
  for (const [index, value] of values.entries()) for (const operation of ['create', 'update']) test(`users: invalid ${field} ${index} on ${operation}`, async () => {
    if (operation === 'update') await s.seed({ 'users/owner': profile });
    const data = { [field]: value, ...(field === 'fcmToken' ? { fcmTokenUpdatedAt: serverTimestamp() } : {}) };
    await assertFails(operation === 'create' ? setDoc(doc(s.db(), 'users/owner'), { ...profile, ...data }) : updateDoc(doc(s.db(), 'users/owner'), data));
  });
}
for (const role of ['driver', 'admin', deleteField()]) test(`users: existing role immutable ${String(role)}`, async () => {
  await s.seed({ 'users/owner': profile });
  await assertFails(updateDoc(doc(s.db(), 'users/owner'), { role }));
});
test('users: valid name/phone/photo bounds and unchanged server fields', async () => {
  await s.seed({ 'users/owner': { ...profile, rating: 4.9, ratingCount: 10, activeRideId: 'ride' } });
  for (const name of ['Ab', 'x'.repeat(40)]) await assertSucceeds(updateDoc(doc(s.db(), 'users/owner'), { name, phone: 'x'.repeat(20), photoUrl: 'x'.repeat(2048) }));
});
test('users: push token create/update/delete and maximum length', async () => {
  await assertSucceeds(setDoc(doc(s.db(), 'users/owner'), { ...profile, fcmToken: 'x'.repeat(4096), fcmTokenUpdatedAt: serverTimestamp() }));
  await assertSucceeds(updateDoc(doc(s.db(), 'users/owner'), { fcmToken: 'new-token', fcmTokenUpdatedAt: serverTimestamp() }));
  await assertSucceeds(updateDoc(doc(s.db(), 'users/owner'), { fcmToken: deleteField(), fcmTokenUpdatedAt: serverTimestamp() }));
});
for (const timestamp of [undefined, now, 'bad', deleteField()]) test(`users: push requires request.time ${String(timestamp)}`, async () => {
  await s.seed({ 'users/owner': profile });
  await assertFails(updateDoc(doc(s.db(), 'users/owner'), { fcmToken: 'token', ...(timestamp === undefined ? {} : { fcmTokenUpdatedAt: timestamp }) }));
});
test('users: name-only update works with an old token timestamp', async () => {
  await s.seed({ 'users/owner': { ...profile, fcmToken: 'token', fcmTokenUpdatedAt: now } });
  await assertSucceeds(updateDoc(doc(s.db(), 'users/owner'), { name: 'Updated' }));
});
test('users: role field or non-boolean claim never grants admin reads', async () => {
  await s.seed({ 'users/owner': profile, 'users/other': { ...profile, role: 'admin' } });
  await assertFails(getDoc(doc(s.db('other'), 'users/owner')));
  await assertFails(getDoc(doc(s.context('other', { admin: 'true' }).firestore(), 'users/owner')));
});
for (const actor of ['anonymous', 'owner', 'admin']) test(`users: list ${actor}`, async () => {
  await s.seed({ 'users/owner': profile, 'users/other': profile });
  await (actor === 'admin' ? assertSucceeds : assertFails)(getDocs(collection(s.db(actor), 'users')));
});
test('users: admin cannot create/update/delete even own role-less profile', async () => {
  const ref = doc(s.context('owner', { admin: true }).firestore(), 'users/owner');
  await assertFails(setDoc(ref, profile));
  await s.seed({ 'users/owner': { name: 'Admin User', phone: '+96278' } });
  await assertSucceeds(getDoc(ref));
  await assertFails(updateDoc(ref, { name: 'New Name' }));
  await assertFails(deleteDoc(ref));
});
