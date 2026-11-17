import { collection, getDocs } from 'firebase/firestore';
import { suite, matrix, actors, test, assertFails } from './helpers.mjs';
const s = suite();
for (const path of ['unknown/document', 'users/owner/savedPlaces/home', 'drivers/owner/private/doc', 'rides/trip/live/other', 'config/pricing/private/doc']) matrix(s, path, { value: true }, {});
for (const actor of actors) test(`catch-all: unknown collection query ${actor}`, () => assertFails(getDocs(collection(s.db(actor), 'unknown'))));
