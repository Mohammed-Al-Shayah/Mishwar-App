import { doc, getDoc, setDoc } from 'firebase/firestore';
import { ref, uploadBytes, getBytes, deleteObject } from 'firebase/storage';
import { suite, actors, test, assertFails, assertSucceeds, matrix, ride } from './helpers.mjs';
const s = suite({ storage: true });
matrix(s, 'rides/x/private/rider', { deliveryCode: '4821' }, { read: ['rider'] }, { 'rides/x': ride });
test('rider cannot read another private subdocument', async () => {
  await s.seed({ 'rides/x': ride, 'rides/x/private/other': { secret: true } });
  await assertFails(getDoc(doc(s.db('rider'), 'rides/x/private/other')));
  await assertFails(setDoc(doc(s.db('rider'), 'rides/x/private/other'), { deliveryCode: '1111' }));
});
const path = 'parcels/owner/photo.jpg';
const upload = (storage, size = 10, type = 'image/jpeg', target = path) => uploadBytes(ref(storage, target), new Uint8Array(size), { contentType: type });
for (const actor of actors) test(`parcel storage owner-only: ${actor}`, async () => {
  await s.seedStorage(storage => upload(storage));
  await (actor === 'owner' ? assertSucceeds : assertFails)(getBytes(ref(s.storage(actor), path)));
  await (actor === 'owner' ? assertSucceeds : assertFails)(upload(s.storage(actor)));
  await assertFails(deleteObject(ref(s.storage(actor), path)));
});
for (const [size, type, allowed] of [[5 * 1024 * 1024, 'image/jpeg', true], [5 * 1024 * 1024 + 1, 'image/jpeg', false], [10, 'text/plain', false]]) {
  test(`parcel storage size/type ${size} ${type}`, () => (allowed ? assertSucceeds : assertFails)(upload(s.storage(), size, type)));
}
test('parcel nested and foreign paths denied', async () => {
  for (const path of ['parcels/other/photo.jpg', 'parcels/owner/nested/photo.jpg']) await assertFails(upload(s.storage(), 10, 'image/jpeg', path));
});
