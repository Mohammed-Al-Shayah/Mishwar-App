import { doc, setDoc, getDoc, getDocs, collection, updateDoc, deleteDoc, serverTimestamp, deleteField } from 'firebase/firestore';
import { suite, now, test, assertSucceeds, assertFails } from './helpers.mjs';
const s = suite(), path = 'users/owner/trustedContacts/contact';
const contact = { name: 'Person', phone: '+962781234567', createdAt: now };
test('trusted contacts: owner CRUD and list', async () => {
  const ref = doc(s.db(), path);
  await assertSucceeds(setDoc(ref, { ...contact, createdAt: serverTimestamp() }));
  await assertSucceeds(getDoc(ref));
  await assertSucceeds(getDocs(collection(s.db(), 'users/owner/trustedContacts')));
  await assertSucceeds(updateDoc(ref, { name: 'Updated', phone: '+962791234567', createdAt: serverTimestamp() }));
  await assertSucceeds(deleteDoc(ref));
});
for (const actor of ['anonymous','other','admin']) for (const operation of ['get','list','create','update','delete']) {
  test(`trusted contacts: ${actor} ${operation}`, async () => {
    if (operation !== 'create') await s.seed({ [path]: contact });
    const ref = doc(s.db(actor), path);
    const actions = { get: () => getDoc(ref), list: () => getDocs(collection(s.db(actor), 'users/owner/trustedContacts')),
      create: () => setDoc(ref, { ...contact, createdAt: serverTimestamp() }), update: () => updateDoc(ref, { name: 'Changed', createdAt: serverTimestamp() }), delete: () => deleteDoc(ref) };
    await (actor === 'admin' && ['get','list'].includes(operation) ? assertSucceeds : assertFails)(actions[operation]());
  });
}
for (const patch of [{ name: '' },{ name: 'x'.repeat(41) },{ name: 1 },{ phone: '0781234567' },{ phone: '+0123' },{ phone: '+1' },{ phone: '+'+'1'.repeat(20) },{ phone: '+962781234567\n' },{ createdAt: now },{ extra: true }]) {
  for (const operation of ['create','update']) test(`trusted contacts: invalid ${JSON.stringify(patch)} ${operation}`, async () => {
    if (operation === 'update') await s.seed({ [path]: contact });
    const ref = doc(s.db(), path), data = { ...contact, createdAt: serverTimestamp(), ...patch };
    await assertFails(operation === 'create' ? setDoc(ref, data) : updateDoc(ref, data));
  });
}
test('trusted contacts: required keys cannot be removed', async () => {
  await s.seed({ [path]: contact });
  for (const key of ['name','phone','createdAt']) await assertFails(updateDoc(doc(s.db(), path), { [key]: deleteField() }));
});
for (const actor of ['anonymous','owner','other','admin']) test(`shares: ${actor} has no client access, including descendants`, async () => {
  for (const path of ['shares/'+'a'.repeat(24), 'shares/token/private/data']) {
    await s.seed({ [path]: { rideId: 'secret' } });
    const ref = doc(s.db(actor), path);
    await assertFails(getDoc(ref)); await assertFails(setDoc(ref, { rideId: 'forged' })); await assertFails(deleteDoc(ref));
  }
  await assertFails(getDocs(collection(s.db(actor), 'shares')));
});
