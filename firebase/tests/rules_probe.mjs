// Probes Firestore/Storage emulator rules as a signed-in driver. Emulators only.
const authHost = `http://127.0.0.1:${process.env.RULES_AUTH_PORT ?? 9099}`;
const AUTH = authHost + '/identitytoolkit.googleapis.com/v1';
const FS = `http://127.0.0.1:${process.env.RULES_FIRESTORE_PORT ?? 8080}/v1/projects/demo-mishwar/databases/(default)/documents`;
const ST = `http://127.0.0.1:${process.env.RULES_STORAGE_PORT ?? 9199}/v0/b/demo-mishwar.appspot.com/o`;
const KEY = 'demo-api-key';
// A fresh number per run keeps the probe repeatable against a running emulator.
const phone = process.argv[2] ?? `+96278${String(Math.floor(Math.random() * 1e7)).padStart(7, '0')}`;

const post = (url, body) =>
  fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) }).then((r) => r.json());

const { sessionInfo } = await post(`${AUTH}/accounts:sendVerificationCode?key=${KEY}`, { phoneNumber: phone });
const codes = await fetch(authHost + '/emulator/v1/projects/demo-mishwar/verificationCodes').then((r) => r.json());
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
  ...['rating', 'ratingCount'].map(field => ['cannot create user with ' + field, 403, () => fsReq('PATCH', 'users/' + uid, { role: s('rider'), [field]: { integerValue: '5' } })]),
  ['cannot create user with pending rating', 403, () => fsReq('PATCH', 'users/' + uid, { role: s('rider'), pendingRatingRideId: s('forged') })],
  ['cannot create user with activeRideId', 403, () => fsReq('PATCH', 'users/' + uid, { role: s('rider'), activeRideId: s('forged') })],
  ['seed rider via Admin SDK equivalent', 200, () => ownerSeed('users/' + uid, { role: s('rider') })],
  ['cannot set pending rating', 403, () => fsReq('PATCH', 'users/' + uid, { pendingRatingRideId: s('forged') }, ['pendingRatingRideId'])],
  ...['rating', 'ratingCount'].map(field => ['cannot self-set ' + field, 403, () => fsReq('PATCH', 'users/' + uid, { [field]: { integerValue: '5' } }, [field])]),
  ['seed pending rating', 200, () => ownerSeed('users/' + uid, { role: s('rider'), pendingRatingRideId: s('server') })],
  ['cannot delete pending rating', 403, () => fsReq('PATCH', 'users/' + uid, {}, ['pendingRatingRideId'])],
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
  ...['pendingRatingRideId', 'cancelCount'].map(field => ['cannot create driver with ' + field, 403, () => fsReq('PATCH', `drivers/${uid}`, { ...base, status: s('pending'), [field]: s('forged') })]),
  ['create driver doc as pending', 200, () => fsReq('PATCH', `drivers/${uid}`, { ...base, status: s('pending') })],
  ['self-approve', 403, () => fsReq('PATCH', `drivers/${uid}`, { status: s('approved') }, ['status'])],
  ['go online while pending', 403, () => fsReq('PATCH', `drivers/${uid}`, { isOnline: { booleanValue: true } }, ['isOnline'])],
  ...['pendingRatingRideId', 'cancelCount'].map(field => ['pending cannot set ' + field, 403, () => fsReq('PATCH', `drivers/${uid}`, { [field]: s('forged') }, [field])]),
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
  ...['pendingRatingRideId', 'cancelCount'].map(field => ['presence cannot set ' + field, 403, () => presence(true, { [field]: s('forged') })]),
  ['seed earnings', 200, () => ownerSeed(`drivers/${uid}/earnings/2026-11-17`, { total: { doubleValue: 3 }, trips: { integerValue: '1' } })],
  ['owner reads earnings', 200, () => fsReq('GET', `drivers/${uid}/earnings/2026-11-17`)],
  ['foreign earnings denied', 403, () => fsReq('GET', 'drivers/someoneElse/earnings/2026-11-17')],
  ['earnings create denied', 403, () => fsReq('PATCH', `drivers/${uid}/earnings/forged`, { total: { doubleValue: 100 } })],
  ['earnings update denied', 403, () => fsReq('PATCH', `drivers/${uid}/earnings/2026-11-17`, { total: { doubleValue: 100 } }, ['total'])],
  ['earnings delete denied', 403, () => fsReq('DELETE', `drivers/${uid}/earnings/2026-11-17`)],
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
// Trip locations are a separate participant-only channel.
const liveRide = 'live-' + uid;
const livePath = 'rides/' + liveRide + '/live/driver';
const liveWrite = (fields = {}, serverTime = true) => fetch(FS + ':commit', {
  method: 'POST', headers: { Authorization: 'Bearer ' + token, 'Content-Type': 'application/json' },
  body: JSON.stringify({ writes: [{
    update: { name: 'projects/demo-mishwar/databases/(default)/documents/' + livePath,
      fields: { geopoint: { geoPointValue: { latitude: 31.95, longitude: 35.91 } }, heading: { doubleValue: 90 },
        ...(!serverTime ? { updatedAt: { timestampValue: '2020-01-01T00:00:00Z' } } : {}), ...fields } },
    ...(serverTime ? { updateTransforms: [{ fieldPath: 'updatedAt', setToServerValue: 'REQUEST_TIME' }] } : {}),
  }] }),
}).then(r => r.status);
const seedLiveRide = (rider, driver, status) => ownerSeed('rides/' + liveRide, { riderId: s(rider), driverId: s(driver), status: s(status) });
checks.push(
  ['seed assigned live ride', 200, () => seedLiveRide('live-rider', uid, 'accepted')],
  ['assigned driver creates live location', 200, () => liveWrite()],
  ['assigned driver reads live location', 200, () => fsReq('GET', livePath)],
  ['assigned driver updates live location', 200, () => liveWrite()],
  ['invalid live heading denied', 403, () => liveWrite({ heading: { doubleValue: 361 } })],
  ['extra live field denied', 403, () => liveWrite({ driverId: s(uid) })],
  ['client live timestamp denied', 403, () => liveWrite({}, false)],
  ['live deletion denied', 403, () => fsReq('DELETE', livePath)],
  ['seed live rider identity', 200, () => seedLiveRide(uid, 'live-driver', 'arriving')],
  ['rider reads live location', 200, () => fsReq('GET', livePath)],
  ['rider cannot publish live location', 403, () => liveWrite()],
  ['seed foreign live ride', 200, () => seedLiveRide('live-rider', 'live-driver', 'in_progress')],
  ['other driver cannot publish live location', 403, () => liveWrite()],
  ['stranger cannot read live location', 403, () => fsReq('GET', livePath)],
  ['seed completed live ride', 200, () => seedLiveRide('live-rider', uid, 'completed')],
  ['completed trip location denied', 403, () => liveWrite()],
  ['seed online busy driver', 200, () => ownerSeed('drivers/' + uid, { ...base, status: s('approved'), isOnline: { booleanValue: true }, currentRideId: s(liveRide) })],
  ['assigned driver heartbeat allowed', 200, () => presence(true)],
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
