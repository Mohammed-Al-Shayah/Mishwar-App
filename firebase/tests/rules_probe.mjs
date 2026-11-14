// Probes Firestore/Storage emulator rules as a signed-in driver. Emulators only.
const AUTH = 'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1';
const FS = 'http://127.0.0.1:8080/v1/projects/demo-mishwar/databases/(default)/documents';
const ST = 'http://127.0.0.1:9199/v0/b/demo-mishwar.appspot.com/o';
const KEY = 'demo-api-key';
const phone = process.argv[2] ?? '+962781111111';

const post = (url, body) =>
  fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) }).then((r) => r.json());

const { sessionInfo } = await post(`${AUTH}/accounts:sendVerificationCode?key=${KEY}`, { phoneNumber: phone });
const codes = await fetch('http://127.0.0.1:9099/emulator/v1/projects/demo-mishwar/verificationCodes').then((r) => r.json());
const code = codes.verificationCodes.find((c) => c.sessionInfo === sessionInfo).code;
const { idToken: token, localId: uid } = await post(`${AUTH}/accounts:signInWithPhoneNumber?key=${KEY}`, { sessionInfo, code });
console.log('uid', uid);

const s = (v) => ({ stringValue: v });
const vehicle = { mapValue: { fields: { type: s('economy'), make: s('Toyota'), model: s('Corolla'), color: s('White'), plate: s('12-34567') } } };
const base = { vehicle, licensePhotoPath: s(`drivers/${uid}/license.jpg`), isOnline: { booleanValue: false } };
const fsReq = (method, path, fields, mask) =>
  fetch(`${FS}/${path}${mask ? `?${mask.map((m) => `updateMask.fieldPaths=${m}`).join('&')}` : ''}`, {
    method,
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    body: fields ? JSON.stringify({ fields }) : undefined,
  }).then((r) => r.status);
const upload = (name, type) =>
  fetch(`${ST}?uploadType=media&name=${encodeURIComponent(name)}`, { method: 'POST', headers: { Authorization: `Firebase ${token}`, 'Content-Type': type }, body: 'bytes' }).then((r) => r.status);

const checks = [
  ['create driver doc as APPROVED', 403, () => fsReq('PATCH', `drivers/${uid}`, { ...base, status: s('approved') })],
  ['create driver doc as pending', 200, () => fsReq('PATCH', `drivers/${uid}`, { ...base, status: s('pending') })],
  ['self-approve', 403, () => fsReq('PATCH', `drivers/${uid}`, { status: s('approved') }, ['status'])],
  ['go online while pending', 403, () => fsReq('PATCH', `drivers/${uid}`, { isOnline: { booleanValue: true } }, ['isOnline'])],
  ['edit vehicle while pending', 200, () => fsReq('PATCH', `drivers/${uid}`, { vehicle }, ['vehicle'])],
  ['delete application', 403, () => fsReq('DELETE', `drivers/${uid}`)],
  ['read another driver', 403, () => fsReq('GET', 'drivers/someoneElse')],
  ['create own user doc as ADMIN', 403, () => fsReq('PATCH', `users/${uid}`, { name: s('x'), phone: s(phone), role: s('admin') })],
  ['upload own license image', 200, () => upload(`drivers/${uid}/license.jpg`, 'image/jpeg')],
  ['upload to another uid', 403, () => upload('drivers/other/x.jpg', 'image/jpeg')],
  ['upload a non-image', 403, () => upload(`drivers/${uid}/evil.exe`, 'application/octet-stream')],
];
let failed = 0;
for (const [name, want, run] of checks) {
  const got = await run();
  const ok = got === want;
  if (!ok) failed++;
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${name}: got ${got}, want ${want}`);
}
console.log(failed ? `${failed} FAILED` : 'ALL PASS');
