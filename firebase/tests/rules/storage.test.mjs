import { ref, uploadBytes, getBytes, deleteObject, listAll, updateMetadata } from 'firebase/storage';
import { suite, actors, test, assertFails, assertSucceeds } from './helpers.mjs';
const s = suite({ storage: true });
const path = 'drivers/owner/license.jpg';
const upload = (storage, target = path, size = 10, contentType = 'image/jpeg') => uploadBytes(ref(storage, target), new Uint8Array(size), { contentType });
for (const actor of actors) for (const operation of ['read', 'create', 'update', 'delete']) test(`storage: ${actor} ${operation}`, async () => {
  if (operation !== 'create') await s.seedStorage((storage) => upload(storage));
  const storage = s.storage(actor);
  const action = { read: () => getBytes(ref(storage, path)), create: () => upload(storage), update: () => upload(storage), delete: () => deleteObject(ref(storage, path)) }[operation];
  const allowed = operation === 'read' ? ['owner', 'admin'].includes(actor) : ['create', 'update'].includes(operation) && actor === 'owner';
  await (allowed ? assertSucceeds : assertFails)(action());
});
for (const [size, allowed] of [[5 * 1024 * 1024 - 1, true], [5 * 1024 * 1024, false], [5 * 1024 * 1024 + 1, false]]) test(`storage: size ${size}`, () => (allowed ? assertSucceeds : assertFails)(upload(s.storage(), path, size)));
for (const [type, allowed] of [['image/png', true], ['image/webp', true], ['text/plain', false], ['application/octet-stream', false], ['', false]]) test(`storage: content type ${type || '(empty)'}`, () => (allowed ? assertSucceeds : assertFails)(upload(s.storage(), path, 10, type)));
for (const target of ['drivers/other/license.jpg', 'drivers/owner/nested/license.jpg', 'users/owner/photo.jpg', 'unknown/file']) for (const actor of ['owner', 'admin', 'anonymous']) {
  for (const operation of ['read', 'create', 'delete']) test(`storage catch-all: ${actor} ${operation} ${target}`, async () => {
    if (operation !== 'create') await s.seedStorage((storage) => upload(storage, target));
    const action = operation === 'read' ? getBytes(ref(s.storage(actor), target)) : operation === 'delete' ? deleteObject(ref(s.storage(actor), target)) : upload(s.storage(actor), target);
    // Admin can read another driver's direct file, but not unmatched paths.
    await (actor === 'admin' && operation === 'read' && target === 'drivers/other/license.jpg' ? assertSucceeds : assertFails)(action);
  });
}
test('storage: owner can list own direct files, foreign listing denied', async () => {
  await s.seedStorage((storage) => upload(storage));
  await assertSucceeds(listAll(ref(s.storage(), 'drivers/owner')));
  await assertFails(listAll(ref(s.storage('other'), 'drivers/owner')));
  await assertFails(listAll(ref(s.storage(), 'drivers')));
});
test('storage: metadata cannot change an image into non-image', async () => {
  await s.seedStorage((storage) => upload(storage));
  await assertFails(updateMetadata(ref(s.storage(), path), { contentType: 'text/plain' }));
});
test('storage: admin cannot upload even own license', () => assertFails(upload(s.context('owner', { admin: true }).storage('gs://demo-mishwar.appspot.com'))));
