import { collection, getDocs } from 'firebase/firestore';
import { suite, matrix, actors, test, assertFails, assertSucceeds } from './helpers.mjs';
const s = suite();
matrix(s, 'config/pricing', { economy: { base: 0.5, perKm: 0.3 } }, { read: ['admin'] });
for (const actor of actors) test(`config: list ${actor}`, () => (actor === 'admin' ? assertSucceeds : assertFails)(getDocs(collection(s.db(actor), 'config'))));
