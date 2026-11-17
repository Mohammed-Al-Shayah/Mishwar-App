// Emulator-only Firestore and Storage rules probes. No production endpoints.
import assert from 'node:assert/strict';
import { createRequire } from 'node:module';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { fileURLToPath } from 'node:url';
const require = createRequire(new URL('../functions/package.json', import.meta.url));
const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
process.env.FIREBASE_AUTH_EMULATOR_HOST = '127.0.0.1:9099';
initializeApp({ projectId: 'demo-mishwar' });
const auth = getAuth(), tag = `admin-probe-${Date.now()}`;
const FS = 'http://127.0.0.1:8080/v1/projects/demo-mishwar/databases/(default)/documents';
const ST = 'http://127.0.0.1:9199/v0/b/demo-mishwar.appspot.com/o';
const fetchLocal = (url, options = {}) => fetch(url, { ...options, signal: AbortSignal.timeout(5000) });
for (const url of [FS, ST]) {
  try { await fetchLocal(url); } catch { console.error('Emulators unavailable at 127.0.0.1:8080 / 9199. Probes not run.'); process.exit(2); }
}
const tokens = [];
const previousPricingResponse = await fetchLocal(`${FS}/config/pricing`, { headers: { Authorization: 'Bearer owner' } });
const previousPricing = previousPricingResponse.ok ? await previousPricingResponse.json() : null;
const paths = [`users/${tag}`, `drivers/${tag}`, `drivers/${tag}/earnings/day`, `rides/${tag}`, `rides/${tag}/live/driver`, 'config/pricing', `adminLog/${tag}`];
try {
  for (const admin of [false, true]) {
    const user = await auth.createUser({ email: `${tag}-${admin}@example.test`, password: 'probe-password-123' });
    if (admin) await promisify(execFile)(process.execPath, [fileURLToPath(new URL('../scripts/grant-admin.mjs', import.meta.url)), user.email]);
    const response = await fetchLocal('http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=demo-key', {
      method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ email: user.email, password: 'probe-password-123', returnSecureToken: true }),
    });
    const data = await response.json(); assert.ok(data.idToken); tokens.push({ uid: user.uid, token: data.idToken });
  }
  const [regular, admin] = tokens;
  const s = stringValue => ({ stringValue });
  for (const path of paths) {
    const seed = await fetchLocal(`${FS}/${path}`, { method: 'PATCH', headers: { Authorization: 'Bearer owner', 'Content-Type': 'application/json' }, body: JSON.stringify({ fields: { riderId: s(tag), status: s('pending'), role: s('rider') } }) });
    assert.equal(seed.status, 200, `seed ${path}`);
    for (const [who, expected] of [[admin, 200], [regular, 403]]) {
      const read = await fetchLocal(`${FS}/${path}`, { headers: { Authorization: `Bearer ${who.token}` } });
      assert.equal(read.status, expected, `read ${path}, admin=${who === admin}`);
    }
    for (const method of ['PATCH', 'DELETE']) {
      const write = await fetchLocal(`${FS}/${path}`, { method, headers: { Authorization: `Bearer ${admin.token}`, 'Content-Type': 'application/json' }, ...(method === 'PATCH' ? { body: JSON.stringify({ fields: { status: s('approved') } }) } : {}) });
      assert.equal(write.status, 403, `admin ${method} ${path}`);
    }
  }
  // Also deny writes to the admin's own profile, not only foreign records.
  const own = await fetchLocal(`${FS}/users/${admin.uid}`, { method: 'PATCH', headers: { Authorization: `Bearer ${admin.token}`, 'Content-Type': 'application/json' }, body: JSON.stringify({ fields: { name: s('forged') } }) });
  assert.equal(own.status, 403);
  const name = encodeURIComponent(`drivers/${tag}/license.jpg`);
  const upload = await fetchLocal(`${ST}?uploadType=media&name=${name}`, { method: 'POST', headers: { Authorization: 'Bearer owner', 'Content-Type': 'image/jpeg' }, body: 'probe-image' });
  assert.equal(upload.status, 200);
  for (const [who, expected] of [[admin, 200], [regular, 403]]) {
    const read = await fetchLocal(`${ST}/${name}?alt=media`, { headers: { Authorization: `Firebase ${who.token}` } });
    assert.equal(read.status, expected, `storage admin=${who === admin}`);
  }
  const write = await fetchLocal(`${ST}?uploadType=media&name=${name}`, { method: 'POST', headers: { Authorization: `Firebase ${admin.token}`, 'Content-Type': 'image/jpeg' }, body: 'forged' });
  assert.equal(write.status, 403);
  console.log('PASS: admin reads, denied admin writes, isolated non-admin reads, Storage license access.');
} finally {
  for (const path of paths) await fetchLocal(`${FS}/${path}`, { method: 'DELETE', headers: { Authorization: 'Bearer owner' } });
  if (previousPricing) await fetchLocal(`${FS}/config/pricing`, { method: 'PATCH', headers: { Authorization: 'Bearer owner', 'Content-Type': 'application/json' }, body: JSON.stringify({ fields: previousPricing.fields }) });
  await fetchLocal(`${ST}/${encodeURIComponent(`drivers/${tag}/license.jpg`)}`, { method: 'DELETE', headers: { Authorization: 'Bearer owner' } });
  await Promise.all(tokens.map(user => auth.deleteUser(user.uid)));
}
