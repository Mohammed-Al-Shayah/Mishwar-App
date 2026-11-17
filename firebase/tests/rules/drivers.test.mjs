import { doc, setDoc, getDoc, updateDoc, deleteField, serverTimestamp, getDocs, collection, query, orderBy } from 'firebase/firestore';
import { suite, matrix, application, vehicle, point, now, test, assertFails, assertSucceeds, actors } from './helpers.mjs';
const s = suite();
matrix(s, 'drivers/owner', application, { read: ['owner', 'admin'], create: ['owner'] });
matrix(s, 'drivers/owner/earnings/2026-11-17', { total: 3, trips: 1 }, { read: ['owner', 'admin'] });
const presence = (extra = {}) => ({ isOnline: true, location: { geohash: 'sv9twm84q', geopoint: point }, heading: 90, lastSeenAt: serverTimestamp(), ...extra });
const approved = { ...application, status: 'approved' };
test('drivers: owner may read missing application', () => assertSucceeds(getDoc(doc(s.db(), 'drivers/owner'))));
for (const status of ['pending', 'rejected']) {
  test(`drivers: ${status} edits vehicle/license with server time`, async () => {
    await s.seed({ 'drivers/owner': { ...application, status } });
    await assertSucceeds(updateDoc(doc(s.db(), 'drivers/owner'), { vehicle: { ...vehicle, make: 'Honda' }, licensePhotoPath: 'drivers/owner/new.jpg', updatedAt: serverTimestamp() }));
  });
  for (const target of ['pending', 'rejected', 'approved', 'suspended']) test(`drivers: status ${status} to ${target}`, async () => {
    await s.seed({ 'drivers/owner': { ...application, status } });
    await ((target === status || status === 'rejected' && target === 'pending') ? assertSucceeds : assertFails)(updateDoc(doc(s.db(), 'drivers/owner'), { status: target }));
  });
}
for (const [field, value] of Object.entries({ offer: null, currentRideId: null, cancelCount: 0, pendingRatingRideId: 'ride', rating: 5, ratingCount: 1, accountDeleting: true, rejectionReason: 'forged', unknown: true, location: { geohash: 'a', geopoint: point } })) {
  test(`drivers: create rejects ${field}`, () => assertFails(setDoc(doc(s.db(), 'drivers/owner'), { ...application, [field]: value })));
  for (const status of ['pending', 'approved']) for (const removal of [false, true]) test(`drivers: ${status} cannot ${removal ? 'remove' : 'set'} ${field}`, async () => {
    await s.seed({ 'drivers/owner': { ...application, status, ...(removal ? { [field]: value } : {}) } });
    await (status === 'approved' && field === 'location' && !removal ? assertSucceeds : assertFails)(updateDoc(doc(s.db(), 'drivers/owner'), { ...(status === 'approved' ? presence() : {}), [field]: removal ? deleteField() : value }));
  });
}
for (const field of ['make', 'model', 'color', 'plate']) {
  for (const [index, value] of ['', 1, null, 'x'.repeat(field === 'plate' ? 16 : 41), deleteField()].entries()) {
    for (const operation of ['create', 'update']) test(`drivers: invalid vehicle.${field} ${index} ${operation}`, async () => {
      const badVehicle = { ...vehicle }; if (index === 4) delete badVehicle[field]; else badVehicle[field] = value;
      if (operation === 'update') await s.seed({ 'drivers/owner': application });
      await assertFails(operation === 'create' ? setDoc(doc(s.db(), 'drivers/owner'), { ...application, vehicle: badVehicle }) : updateDoc(doc(s.db(), 'drivers/owner'), { vehicle: badVehicle }));
    });
  }
}
for (const type of ['economy', 'comfort', 'van', 'bus', 1]) test(`drivers: vehicle type ${type}`, () =>
  (['economy', 'comfort', 'van'].includes(type) ? assertSucceeds : assertFails)(setDoc(doc(s.db(), 'drivers/owner'), { ...application, vehicle: { ...vehicle, type } })));
for (const value of ['', 123, null, 'drivers/other/license.jpg', 'drivers/owner/', 'drivers/owner/nested/license.jpg', 'x'.repeat(1025)]) test(`drivers: invalid license path ${String(value).slice(0, 45)}`, () => assertFails(setDoc(doc(s.db(), 'drivers/owner'), { ...application, licensePhotoPath: value })));
for (const patch of [{ status: 'approved' }, { status: 'rejected' }, { status: 'suspended' }, { isOnline: true }, { isOnline: 0 }, { vehicle: { ...vehicle, extra: true } }, { updatedAt: now }, { createdAt: 'bad' }]) test(`drivers: invalid creation ${JSON.stringify(patch)}`, () => assertFails(setDoc(doc(s.db(), 'drivers/owner'), { ...application, ...patch })));
test('drivers: maximum vehicle lengths and application timestamps', () => assertSucceeds(setDoc(doc(s.db(), 'drivers/owner'), { ...application, vehicle: { ...vehicle, make: 'x'.repeat(40), model: 'x'.repeat(40), color: 'x'.repeat(40), plate: 'x'.repeat(15) }, createdAt: serverTimestamp(), updatedAt: serverTimestamp() })));
for (const status of ['pending', 'rejected', 'suspended']) test(`drivers: ${status} cannot publish presence`, async () => {
  await s.seed({ 'drivers/owner': { ...application, status } });
  await assertFails(updateDoc(doc(s.db(), 'drivers/owner'), presence()));
});
for (const actor of actors) test(`drivers: approved presence by ${actor}`, async () => {
  await s.seed({ 'drivers/owner': approved });
  await (actor === 'owner' ? assertSucceeds : assertFails)(updateDoc(doc(s.db(actor), 'drivers/owner'), presence()));
});
for (const [index, patch] of [
  { heading: -1 }, { heading: 361 }, { heading: '90' }, { heading: null }, { lastSeenAt: now }, { lastSeenAt: deleteField() },
  { isOnline: 'true' }, { location: { geohash: '', geopoint: point } }, { location: { geohash: 'x'.repeat(13), geopoint: point } },
  { location: { geohash: 1, geopoint: point } }, { location: { geohash: 'a', geopoint: 'point' } },
  { location: { geohash: 'a', geopoint: point, extra: true } }, { status: 'suspended' }, { vehicle: { ...vehicle, make: 'Forged' } },
].entries()) test(`drivers: invalid presence ${index}`, async () => {
  await s.seed({ 'drivers/owner': approved });
  await assertFails(updateDoc(doc(s.db(), 'drivers/owner'), presence(patch)));
});
test('drivers: presence heading/geohash bounds, offline merge and busy heartbeat', async () => {
  await s.seed({ 'drivers/owner': approved });
  for (const heading of [0, 360]) for (const geohash of ['a', 'x'.repeat(12)]) await assertSucceeds(updateDoc(doc(s.db(), 'drivers/owner'), presence({ heading, location: { geohash, geopoint: point } })));
  await assertSucceeds(updateDoc(doc(s.db(), 'drivers/owner'), { isOnline: false, lastSeenAt: serverTimestamp() }));
  await s.seed({ 'drivers/owner': { ...approved, ...presence(), lastSeenAt: now, isOnline: true, currentRideId: 'ride' } });
  await assertSucceeds(updateDoc(doc(s.db(), 'drivers/owner'), presence()));
  await assertSucceeds(updateDoc(doc(s.db(), 'drivers/owner'), presence({ isOnline: false })));
  await assertFails(updateDoc(doc(s.db(), 'drivers/owner'), presence()));
});
for (const actor of actors) test(`earnings: history query ${actor}`, async () => {
  await s.seed({ 'drivers/owner/earnings/day': { total: 3, trips: 1 } });
  await (['owner', 'admin'].includes(actor) ? assertSucceeds : assertFails)(getDocs(query(collection(s.db(actor), 'drivers/owner/earnings'), orderBy('__name__'))));
});
for (const status of ['pending', 'rejected', 'approved', 'suspended']) for (const field of ['createdAt', 'rejectionReason', 'isOnline']) test(`drivers: ${status} cannot remove ${field}`, async () => {
  await s.seed({ 'drivers/owner': { ...application, status, createdAt: now, rejectionReason: 'server' } });
  await assertFails(updateDoc(doc(s.db(), 'drivers/owner'), { [field]: deleteField() }));
});
for (const status of ['approved', 'suspended']) test(`drivers: ${status} cannot edit application`, async () => {
  await s.seed({ 'drivers/owner': { ...application, status } });
  await assertFails(updateDoc(doc(s.db(), 'drivers/owner'), { vehicle: { ...vehicle, make: 'Honda' } }));
});
test('drivers: changing updatedAt requires server time', async () => {
  await s.seed({ 'drivers/owner': { ...application, updatedAt: now } });
  await assertFails(updateDoc(doc(s.db(), 'drivers/owner'), { updatedAt: 'bad' }));
  await assertFails(updateDoc(doc(s.db(), 'drivers/owner'), { updatedAt: deleteField() }));
  await assertSucceeds(updateDoc(doc(s.db(), 'drivers/owner'), { vehicle: { ...vehicle, make: 'Honda' } }));
});
test('drivers: admin cannot submit or publish own presence', async () => {
  const ref = doc(s.context('owner', { admin: true }).firestore(), 'drivers/owner');
  await assertFails(setDoc(ref, application));
  await s.seed({ 'drivers/owner': approved });
  await assertFails(updateDoc(ref, presence()));
});
test('drivers: presence without optional heading and no assignment works', async () => {
  await s.seed({ 'drivers/owner': { ...approved, currentRideId: null } });
  const data = presence(); delete data.heading;
  await assertSucceeds(updateDoc(doc(s.db(), 'drivers/owner'), data));
});
test('drivers: license prefix does not waive maximum length', async () => {
  await assertFails(setDoc(doc(s.db(), 'drivers/owner'), { ...application, licensePhotoPath: 'drivers/owner/' + 'x'.repeat(1024) }));
});
test('drivers: license owner prefix is literal even for regex characters in uid', async () => {
  const ref = doc(s.context('owner.*', {}).firestore(), 'drivers/owner.*');
  await assertFails(setDoc(ref, { ...application, licensePhotoPath: 'drivers/ownerZZ/license.jpg' }));
  await assertSucceeds(setDoc(ref, { ...application, licensePhotoPath: 'drivers/owner.*/license.jpg' }));
});
