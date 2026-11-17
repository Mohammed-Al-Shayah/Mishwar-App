import assert from 'node:assert/strict';
import { doc, setDoc, updateDoc, getDoc, collection, collectionGroup, query, where, orderBy, limit, startAfter, getDocs, serverTimestamp, deleteField } from 'firebase/firestore';
import { suite, matrix, ride, point, now, test, assertFails, assertSucceeds, actors } from './helpers.mjs';
const s = suite();
matrix(s, 'rides/trip', ride, { read: ['rider', 'driver', 'offered', 'admin'] });
matrix(s, 'rides/trip/live/driver', { geopoint: point, heading: 90, updatedAt: serverTimestamp() }, { read: ['rider', 'driver', 'admin'], create: ['driver'] }, { 'rides/trip': ride });
const live = (patch = {}) => ({ geopoint: point, heading: 90, updatedAt: serverTimestamp(), ...patch });
for (const actor of actors) test(`live: valid update ${actor}`, async () => {
  await s.seed({ 'rides/trip': ride, 'rides/trip/live/driver': { geopoint: point, updatedAt: now } });
  await (actor === 'driver' ? assertSucceeds : assertFails)(updateDoc(doc(s.db(actor), 'rides/trip/live/driver'), live()));
});
for (const status of ['searching', 'accepted', 'arriving', 'arrived', 'in_progress', 'completed', 'cancelled', 'no_drivers']) {
  for (const operation of ['create', 'update']) test(`live: ${operation} during ${status}`, async () => {
    await s.seed({ 'rides/trip': { ...ride, status }, ...(operation === 'update' ? { 'rides/trip/live/driver': { geopoint: point, updatedAt: now } } : {}) });
    const ref = doc(s.db('driver'), 'rides/trip/live/driver');
    await (['accepted', 'arriving', 'arrived', 'in_progress'].includes(status) ? assertSucceeds : assertFails)(operation === 'create' ? setDoc(ref, live()) : updateDoc(ref, live()));
  });
}
for (const [index, patch] of [{ heading: -1 }, { heading: 361 }, { heading: '90' }, { heading: null }, { geopoint: 'point' }, { updatedAt: now }, { updatedAt: 'bad' }, { extra: true }, { driverId: 'driver' }].entries()) test(`live: malformed field ${index}`, async () => {
  await s.seed({ 'rides/trip': ride });
  await assertFails(setDoc(doc(s.db('driver'), 'rides/trip/live/driver'), live(patch)));
});
test('live: heading optional with inclusive bounds', async () => {
  await s.seed({ 'rides/trip': ride });
  for (const heading of [undefined, 0, 360]) await assertSucceeds(setDoc(doc(s.db('driver'), 'rides/trip/live/driver'), { geopoint: point, updatedAt: serverTimestamp(), ...(heading === undefined ? {} : { heading }) }));
});
test('live: requires parent ride and required fields', async () => {
  await assertFails(setDoc(doc(s.db('driver'), 'rides/missing/live/driver'), live()));
  await s.seed({ 'rides/trip': ride });
  for (const field of ['geopoint', 'updatedAt']) { const data = live(); delete data[field]; await assertFails(setDoc(doc(s.db('driver'), 'rides/trip/live/driver'), data)); }
});
for (const field of ['status', 'driverId', 'offeredTo', 'fare.final', 'riderRating', 'driverRating']) test(`rides: server-owned ${field}`, async () => {
  await s.seed({ 'rides/trip': ride });
  await assertFails(updateDoc(doc(s.db('rider'), 'rides/trip'), { [field]: field === 'fare.final' ? 0 : 'forged' }));
});
for (const actor of actors) test(`rides: unrestricted list ${actor}`, async () => {
  await s.seed({ 'rides/trip': ride, 'rides/foreign': { ...ride, riderId: 'foreign', driverId: 'foreign', offeredTo: null } });
  await (actor === 'admin' ? assertSucceeds : assertFails)(getDocs(collection(s.db(actor), 'rides')));
});
for (const [actor, field] of [['rider', 'riderId'], ['driver', 'driverId']]) test(`rides: app ${actor} history filters, descending pagination`, async () => {
  await s.seed({ 'rides/first': { ...ride, status: 'completed' }, 'rides/second': { ...ride, status: 'cancelled', createdAt: now }, 'rides/foreign': { ...ride, riderId: 'foreign', driverId: 'foreign', offeredTo: null, status: 'completed' } });
  const history = query(collection(s.db(actor), 'rides'), where(field, '==', actor), where('status', 'in', ['completed', 'cancelled', 'no_drivers']), orderBy('createdAt', 'desc'), limit(1));
  const page = await assertSucceeds(getDocs(history)); assert.equal(page.size, 1);
  const next = await assertSucceeds(getDocs(query(history, startAfter(page.docs[0])))); assert.equal(next.size, 1);
});
for (const actor of actors) test(`rides: list foreign rider history ${actor}`, async () => {
  await s.seed({ 'rides/trip': ride });
  await (['rider', 'admin'].includes(actor) ? assertSucceeds : assertFails)(getDocs(query(collection(s.db(actor), 'rides'), where('riderId', '==', 'rider'))));
});
test('rides: offered driver gets document but cannot list offers', async () => {
  await s.seed({ 'rides/trip': ride });
  await assertSucceeds(getDoc(doc(s.db('offered'), 'rides/trip')));
  await assertFails(getDocs(query(collection(s.db('offered'), 'rides'), where('offeredTo', '==', 'offered'))));
});
test('rides: collection-group live query cannot expose foreign locations', () => assertFails(getDocs(collectionGroup(s.db('rider'), 'live'))));
test('live: admin assigned as driver still cannot write', async () => {
  await s.seed({ 'rides/trip': ride });
  const ref = doc(s.context('driver', { admin: true }).firestore(), 'rides/trip/live/driver');
  await assertFails(setDoc(ref, live()));
});
