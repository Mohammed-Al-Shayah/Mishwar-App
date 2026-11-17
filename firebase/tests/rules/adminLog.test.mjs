import { collection, getDocs, query, orderBy, limit } from 'firebase/firestore';
import { suite, matrix, actors, now, test, assertFails, assertSucceeds } from './helpers.mjs';
const s = suite();
matrix(s, 'adminLog/entry', { action: 'reviewDriver', createdAt: now }, { read: ['admin'] });
for (const actor of actors) test(`adminLog: list ${actor}`, () => (actor === 'admin' ? assertSucceeds : assertFails)(getDocs(query(collection(s.db(actor), 'adminLog'), orderBy('createdAt', 'desc'), limit(20)))));
