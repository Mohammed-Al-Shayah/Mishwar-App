import { FieldValue, type Firestore } from 'firebase-admin/firestore';
import { HttpsError, type CallableRequest } from 'firebase-functions/v2/https';
import { authenticated } from '../lib/maps.js';
import { rideId } from './handlers.js';
import { dispatchRide, type MatchingDeps } from './matching.js';

function precondition(reason: 'offer-expired' | 'not-offered' | 'driver-busy'): never {
  throw new HttpsError('failed-precondition', 'Offer cannot be accepted.', { reason });
}
export async function acceptRideHandler(request: CallableRequest, db: Firestore, deps: MatchingDeps) {
  authenticated(request);
  const uid = request.auth!.uid, id = rideId(request.data);
  const ref = db.doc(`rides/${id}`), driverRef = db.doc(`drivers/${uid}`);
  await db.runTransaction(async (tx) => {
    const ride = (await tx.get(ref)).data();
    const driver = (await tx.get(driverRef)).data();
    if (!ride || ride.status !== 'searching' || ride.offeredTo !== uid) precondition('not-offered');
    if (!ride.offerExpiresAt || ride.offerExpiresAt.toMillis() <= deps.now().toMillis()) precondition('offer-expired');
    if (!driver || driver.status !== 'approved' || driver.isOnline !== true || driver.currentRideId) precondition('driver-busy');
    if (driver.offer?.rideId !== id) precondition('not-offered');
    tx.update(ref, { status: 'accepted', driverId: uid, acceptedAt: FieldValue.serverTimestamp(),
      offeredTo: null, offerExpiresAt: null });
    tx.update(driverRef, { currentRideId: id, offer: null });
  });
  return { ok: true };
}

export async function declineRideHandler(request: CallableRequest, db: Firestore, deps: MatchingDeps) {
  authenticated(request);
  const uid = request.auth!.uid, id = rideId(request.data);
  const ref = db.doc(`rides/${id}`), driverRef = db.doc(`drivers/${uid}`);
  const declined = await db.runTransaction(async (tx) => {
    const ride = (await tx.get(ref)).data();
    if (!ride || ride.status !== 'searching' || ride.offeredTo !== uid) return false;
    const driver = (await tx.get(driverRef)).data();
    tx.update(ref, { declinedBy: FieldValue.arrayUnion(uid), offeredTo: null,
      offerExpiresAt: null, offerDistanceMeters: null });
    if (driver?.offer?.rideId === id) tx.update(driverRef, { offer: null });
    return true;
  });
  if (declined) await dispatchRide(db, id, deps);
  return { ok: true };
}
