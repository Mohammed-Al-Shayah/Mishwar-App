import { doc, setDoc, getDoc, getDocs, collection, updateDoc, deleteDoc, serverTimestamp } from 'firebase/firestore';
import { suite, point, now, test, assertSucceeds, assertFails } from './helpers.mjs';
const s = suite();
const path = 'users/owner/savedPlaces/home';
const place = { label: 'home', name: 'Home', address: 'Address', geopoint: point, updatedAt: now };

test('saved places: owner CRUD and list with server timestamps', async () => {
  const ref = doc(s.db(), path);
  await assertSucceeds(setDoc(ref, { ...place, updatedAt: serverTimestamp() }));
  await assertSucceeds(getDoc(ref));
  await assertSucceeds(getDocs(collection(s.db(), 'users/owner/savedPlaces')));
  await assertSucceeds(updateDoc(ref, { name: 'New home', updatedAt: serverTimestamp() }));
  await assertSucceeds(deleteDoc(ref));
  for (const [id, label] of [['work', 'work'], ['auto-id', 'other']]) {
    await assertSucceeds(setDoc(doc(s.db(), `users/owner/savedPlaces/${id}`), { ...place, label, updatedAt: serverTimestamp() }));
  }
});
for (const actor of ['anonymous', 'other', 'admin']) {
  for (const operation of ['read', 'list', 'create', 'update', 'delete']) {
    test(`saved places: ${actor} ${operation}`, async () => {
      if (operation !== 'create') await s.seed({ [path]: place });
      const ref = doc(s.db(actor), path);
      const action = {
        read: () => getDoc(ref), list: () => getDocs(collection(s.db(actor), 'users/owner/savedPlaces')),
        create: () => setDoc(ref, { ...place, updatedAt: serverTimestamp() }),
        update: () => updateDoc(ref, { name: 'Changed', updatedAt: serverTimestamp() }),
        delete: () => deleteDoc(ref),
      }[operation];
      await (actor === 'admin' && ['read', 'list'].includes(operation) ? assertSucceeds : assertFails)(action());
    });
  }
}
for (const patch of [
  { label: 'bad' }, { label: 'work' }, { label: 'other' },
  { name: '' }, { name: 'x'.repeat(41) }, { name: 1 },
  { address: 'x'.repeat(201) }, { geopoint: { lat: 1, lng: 2 } },
  { extra: true }, { updatedAt: now },
]) {
  for (const operation of ['create', 'update']) test(`saved places: invalid ${JSON.stringify(patch)} ${operation}`, async () => {
    if (operation === 'update') await s.seed({ [path]: place });
    const data = { ...place, updatedAt: serverTimestamp(), ...patch };
    await assertFails(operation === 'create' ? setDoc(doc(s.db(), path), data) : updateDoc(doc(s.db(), path), data));
  });
}
test('saved places: singleton labels require their fixed ids', async () => {
  for (const label of ['home', 'work']) await assertFails(setDoc(doc(s.db(), 'users/owner/savedPlaces/random'), { ...place, label, updatedAt: serverTimestamp() }));
});
test('saved places: admin cannot write their own collection', async () => {
  const ref = doc(s.context('owner', { admin: true }).firestore(), path);
  await assertFails(setDoc(ref, { ...place, updatedAt: serverTimestamp() }));
  await s.seed({ [path]: place });
  await assertSucceeds(getDoc(ref));
  await assertFails(updateDoc(ref, { name: 'Changed', updatedAt: serverTimestamp() }));
  await assertFails(deleteDoc(ref));
});
