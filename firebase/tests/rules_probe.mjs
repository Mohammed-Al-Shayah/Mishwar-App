// Probes Firestore/Storage emulator rules as a signed-in driver. Emulators only.
const AUTH = 'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1';
const FS = 'http://127.0.0.1:8080/v1/projects/demo-mishwar/databases/(default)/documents';
const ST = 'http://127.0.0.1:9199/v0/b/demo-mishwar.appspot.com/o';
const KEY = 'demo-api-key';
// A fresh number per run keeps the probe repeatable against a running emulator.
const phone = process.argv[2] ?? `+96278${String(Math.floor(Math.random() * 1e7)).padStart(7, '0')}`;

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

const ownerSeed = (path, fields) => fetch(FS + '/' + path, {
  method: 'PATCH', headers: { Authorization: 'Bearer owner', 'Content-Type': 'application/json' },
  body: JSON.stringify({ fields }),
}).then((r) => r.status);
const ownRide = { riderId: s(uid), status: s('searching'), fare: { mapValue: { fields: { estimated: { doubleValue: 2.5 } } } } };
const checks = [
  ['cannot create user with activeRideId', 403, () => fsReq('PATCH', 'users/' + uid, { role: s('rider'), activeRideId: s('forged') })],
  ['seed rider via Admin SDK equivalent', 200, () => ownerSeed('users/' + uid, { role: s('rider') })],
  ['cannot set activeRideId', 403, () => fsReq('PATCH', 'users/' + uid, { activeRideId: s('forged') }, ['activeRideId'])],
  ['cannot create ride', 403, () => fsReq('PATCH', 'rides/forged-' + uid, ownRide)],
  ['seed own ride via Admin SDK equivalent', 200, () => ownerSeed('rides/own-' + uid, ownRide)],
  ['read own server-created ride', 200, () => fsReq('GET', 'rides/own-' + uid)],
  ['cannot update ride status', 403, () => fsReq('PATCH', 'rides/own-' + uid, { status: s('cancelled') }, ['status'])],
  ['cannot delete ride', 403, () => fsReq('DELETE', 'rides/own-' + uid)],
  ['seed other rider ride', 200, () => ownerSeed('rides/other-' + uid, { ...ownRide, riderId: s('someoneElse') })],
  ['cannot read other rider ride', 403, () => fsReq('GET', 'rides/other-' + uid)],
  ['seed active pointer', 200, () => ownerSeed('users/' + uid, { role: s('rider'), activeRideId: s('own-' + uid) })],
  ['cannot clear activeRideId', 403, () => fsReq('PATCH', 'users/' + uid, {}, ['activeRideId'])],
  ['create driver doc as APPROVED', 403, () => fsReq('PATCH', `drivers/${uid}`, { ...base, status: s('approved') })],
  ['cannot create driver with offer even null', 403, () => fsReq('PATCH', `drivers/${uid}`, { ...base, status: s('pending'), offer: { nullValue: null } })],
  ['create driver doc as pending', 200, () => fsReq('PATCH', `drivers/${uid}`, { ...base, status: s('pending') })],
  ['self-approve', 403, () => fsReq('PATCH', `drivers/${uid}`, { status: s('approved') }, ['status'])],
  ['go online while pending', 403, () => fsReq('PATCH', `drivers/${uid}`, { isOnline: { booleanValue: true } }, ['isOnline'])],
  ['pending cannot write offer', 403, () => fsReq('PATCH', `drivers/${uid}`, { offer: { nullValue: null } }, ['offer'])],
  ['edit vehicle while pending', 200, () => fsReq('PATCH', `drivers/${uid}`, { vehicle }, ['vehicle'])],
  ['delete application', 403, () => fsReq('DELETE', `drivers/${uid}`)],
  ['read another driver', 403, () => fsReq('GET', 'drivers/someoneElse')],
  ['create own user doc as ADMIN', 403, () => fsReq('PATCH', `users/${uid}`, { name: s('x'), phone: s(phone), role: s('admin') })],
  ['upload own license image', 200, () => upload(`drivers/${uid}/license.jpg`, 'image/jpeg')],
  ['upload to another uid', 403, () => upload('drivers/other/x.jpg', 'image/jpeg')],
  ['upload a non-image', 403, () => upload(`drivers/${uid}/evil.exe`, 'application/octet-stream')],
];
// Commit transforms resolve to request.time, like FieldValue.serverTimestamp().
const presence = async (online, extra = {}, target = uid, serverTime = true, onlyFlag = false) => {
  const fields = onlyFlag ? { isOnline: { booleanValue: online } } : {
    isOnline: { booleanValue: online },
    location: { mapValue: { fields: { geohash: s('sv9twm84q'), geopoint: { geoPointValue: { latitude: 31.9539, longitude: 35.9106 } } } } },
    heading: { doubleValue: 90 },
    ...extra,
  };
  if (!serverTime) fields.lastSeenAt = { timestampValue: '2020-01-01T00:00:00Z' };
  return fetch(FS + ':commit', {
    method: 'POST', headers: { Authorization: 'Bearer ' + token, 'Content-Type': 'application/json' },
    body: JSON.stringify({ writes: [{
      update: { name: 'projects/demo-mishwar/databases/(default)/documents/drivers/' + target, fields },
      updateMask: { fieldPaths: Object.keys(fields) },
      ...(serverTime ? { updateTransforms: [{ fieldPath: 'lastSeenAt', setToServerValue: 'REQUEST_TIME' }] } : {}),
    }] }),
  }).then(r => r.status);
};
checks.push(
  ['seed ride offered to driver', 200, () => ownerSeed('rides/offered-' + uid, { ...ownRide, riderId: s('anotherRider'), offeredTo: s(uid) })],
  ['driver reads offered ride', 200, () => fsReq('GET', 'rides/offered-' + uid)],
  ['seed ride offered to other driver', 200, () => ownerSeed('rides/not-offered-' + uid, { ...ownRide, riderId: s('anotherRider'), offeredTo: s('otherDriver') })],
  ['driver cannot read another offer', 403, () => fsReq('GET', 'rides/not-offered-' + uid)],
  ['driver cannot set ride driverId', 403, () => fsReq('PATCH', 'rides/offered-' + uid, { driverId: s(uid) }, ['driverId'])],
  ['seed assigned ride', 200, () => ownerSeed('rides/assigned-' + uid, { ...ownRide, riderId: s('anotherRider'), driverId: s(uid) })],
  ['driver reads assigned ride', 200, () => fsReq('GET', 'rides/assigned-' + uid)],
  ['pending presence denied', 403, () => presence(true)],
  ['seed approved driver', 200, () => ownerSeed('drivers/' + uid, { ...base, status: s('approved') })],
  ['approved goes online with location', 200, () => presence(true)],
  ['approved cannot write own offer', 403, () => presence(true, { offer: { mapValue: { fields: { rideId: s('forged') } } } })],
  ['approved updates location', 200, () => presence(true, { location: { mapValue: { fields: { geohash: s('sv9twm84r'), geopoint: { geoPointValue: { latitude: 31.954, longitude: 35.911 } } } } }, heading: { doubleValue: 180 } })],
  ['approved goes offline', 200, () => presence(false)],
  ['offline merge with only isOnline', 200, () => presence(false, {}, uid, true, true)],
  ['presence cannot change status', 403, () => presence(true, { status: s('suspended') })],
  ['presence cannot assign ride', 403, () => presence(true, { currentRideId: s('forged') })],
  ['presence cannot change vehicle', 403, () => presence(true, { vehicle: { mapValue: { fields: { ...vehicle.mapValue.fields, make: s('Forged') } } } })],
  ['presence rejects client timestamp', 403, () => presence(true, {}, uid, false)],
  ['seed another approved driver', 200, () => ownerSeed('drivers/other-presence', { ...base, status: s('approved') })],
  ['presence cannot write another uid', 403, () => presence(true, {}, 'other-presence')],
  ['seed current ride as owner', 200, () => ownerSeed('drivers/' + uid, { ...base, status: s('approved'), currentRideId: s('server-ride') })],
  ['cannot go online with assigned ride', 403, () => presence(true)],
);
const pushToken = async (value, target = uid, serverTime = true) => fetch(FS + ':commit', {
  method: 'POST', headers: { Authorization: 'Bearer ' + token, 'Content-Type': 'application/json' },
  body: JSON.stringify({ writes: [{
    update: { name: 'projects/demo-mishwar/databases/(default)/documents/users/' + target,
      fields: { ...(value === undefined ? {} : { fcmToken: value }),
        ...(!serverTime ? { fcmTokenUpdatedAt: { timestampValue: '2020-01-01T00:00:00Z' } } : {}) } },
    updateMask: { fieldPaths: ['fcmToken', ...(!serverTime ? ['fcmTokenUpdatedAt'] : [])] },
    ...(serverTime ? { updateTransforms: [{ fieldPath: 'fcmTokenUpdatedAt', setToServerValue: 'REQUEST_TIME' }] } : {}),
  }] }),
}).then(r => r.status);
checks.push(
  ['own push token allowed', 200, () => pushToken(s('test-token'))],
  ['foreign push token denied', 403, () => pushToken(s('test-token'), 'someoneElse')],
  ['non-string push token denied', 403, () => pushToken({ integerValue: '123' })],
  ['oversized push token denied', 403, () => pushToken(s('x'.repeat(4097)))],
  ['client token timestamp denied', 403, () => pushToken(s('test-token'), uid, false)],
  ['push write cannot change role', 403, () => fsReq('PATCH', 'users/' + uid, { role: s('driver') }, ['role'])],
  ['push token deletion allowed', 200, () => pushToken(undefined)],
);
let failed = 0;
for (const [name, want, run] of checks) {
  const got = await run();
  const ok = got === want;
  if (!ok) failed++;
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${name}: got ${got}, want ${want}`);
}
console.log(failed ? `${failed} FAILED` : 'ALL PASS');

if (failed) process.exitCode = 1;
