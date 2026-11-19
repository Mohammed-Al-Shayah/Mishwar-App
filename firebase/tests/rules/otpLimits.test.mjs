import { collection, getDocs } from 'firebase/firestore';
import { suite, matrix, actors, test, assertFails } from './helpers.mjs';
const s = suite();
matrix(s, 'otpLimits/' + 'a'.repeat(64), { sends: [1700000000000] }, {});
matrix(s, 'otpLimits/hash/private/doc', { sends: [] }, {});
for (const actor of actors) test('OTP query denied: ' + actor,
  () => assertFails(getDocs(collection(s.db(actor), 'otpLimits'))));
