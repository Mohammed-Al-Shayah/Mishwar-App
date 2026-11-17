import { FieldValue, GeoPoint, Timestamp, type Firestore } from 'firebase-admin/firestore';
import { HttpsError, type CallableRequest } from 'firebase-functions/v2/https';
import { fareEstimatesHandler } from '../getFareEstimates.js';
import { authenticated } from '../lib/maps.js';
import * as v from '../lib/validate.js';
import { type VehicleType } from '../pricing.js';
import { dispatchRide, offeredDriver, offerIsLive, type MatchingDeps } from './matching.js';

export const activeStatuses = ['searching', 'accepted', 'arriving', 'arrived', 'in_progress'];
const cancellable = ['searching', 'accepted', 'arriving', 'arrived'];
function place(value: unknown) {
  const data = v.object(value);
  return { ...v.point(data), name: v.string(data.name, 1, 120), address: v.string(data.address, 1, 200) };
}
export async function requestRideHandler(request: CallableRequest, db: Firestore, key: string,
  estimate = fareEstimatesHandler, now = () => Timestamp.now()) {
  authenticated(request);
  const uid = request.auth!.uid;
  const data = v.object(request.data);
  const pickup = place(data.pickup), dropoff = place(data.dropoff);
  if (!['economy', 'comfort', 'van'].includes(data.vehicleType as string) || data.paymentMethod !== 'cash') v.invalid();
  const vehicleType = data.vehicleType as VehicleType;
  const userRef = db.doc(`users/${uid}`);
  if ((await userRef.get()).data()?.role !== 'rider') throw new HttpsError('permission-denied', 'Rider role required.');
  // Only validated coordinates go to the server route/pricing implementation.
  const estimates = await estimate({ ...request, data: { origin: pickup, destination: dropoff } }, key);
  const estimated = estimates.fares.find((fare) => fare.vehicleType === vehicleType)!.amount;
  const rideRef = db.collection('rides').doc();
  await db.runTransaction(async (tx) => {
    const user = await tx.get(userRef);
    if (user.data()?.accountDeleting || user.data()?.role !== 'rider') throw new HttpsError('permission-denied', 'Rider role required.');
    const active = await tx.get(db.collection('rides').where('riderId', '==', uid).where('status', 'in', activeStatuses).limit(1));
    if (!active.empty) throw new HttpsError('failed-precondition', 'An active ride already exists.', { activeRideId: active.docs[0].id });
    const storedPlace = (p: ReturnType<typeof place>) => ({ name: p.name, address: p.address, geopoint: new GeoPoint(p.lat, p.lng) });
    tx.create(rideRef, {
      riderId: uid, driverId: null, status: 'searching', vehicleType,
      pickup: storedPlace(pickup), dropoff: storedPlace(dropoff), route: estimates.route,
      fare: { estimated, final: null, currency: 'JOD' }, paymentMethod: 'cash',
      offeredTo: null, offerExpiresAt: null, offerSeq: 0, offerDistanceMeters: null,
      declinedBy: [], createdAt: FieldValue.serverTimestamp(),
      searchExpiresAt: Timestamp.fromMillis(now().toMillis() + 120000),
    });
    // This document also serializes concurrent requests from the same rider.
    tx.update(userRef, { activeRideId: rideRef.id });
  });
  return { rideId: rideRef.id };
}
export function rideId(value: unknown) {
  const id = v.string(v.object(value).rideId, 1, 1500);
  if (id.includes('/')) v.invalid();
  return id;
}
export async function cancelRideHandler(request: CallableRequest, db: Firestore, deps?: MatchingDeps) {
  authenticated(request);
  const ref = db.doc(`rides/${rideId(request.data)}`);
  const redispatched = await db.runTransaction(async (tx) => {
    const ride = await tx.get(ref);
    if (!ride.exists) throw new HttpsError('not-found', 'Ride not found.');
    const data = ride.data()!;
    const uid = request.auth!.uid;
    if (data.driverId === uid && data.riderId !== uid) {
      if (!['accepted', 'arriving', 'arrived'].includes(data.status)) {
        throw new HttpsError('failed-precondition', 'Ride cannot be cancelled.', { reason: 'invalid-transition' });
      }
      if (!deps) throw new HttpsError('internal', 'Matching dependencies required.');
      const driverRef = db.doc(`drivers/${uid}`);
      const driver = (await tx.get(driverRef)).data();
      if (driver?.currentRideId !== ref.id) throw new HttpsError('failed-precondition', 'Ride is not active.', { reason: 'invalid-transition' });
      tx.update(ref, { status: 'searching', driverId: null, driverInfo: FieldValue.delete(),
        acceptedAt: FieldValue.delete(), arrivingAt: FieldValue.delete(), arrivedAt: FieldValue.delete(),
        declinedBy: FieldValue.arrayUnion(uid), searchExpiresAt: Timestamp.fromMillis(deps.now().toMillis() + 120000),
        offeredTo: null, offerExpiresAt: null, offerDistanceMeters: null });
      tx.update(driverRef, { currentRideId: null, cancelCount: (driver.cancelCount ?? 0) + 1 });
      return true;
    }
    if (data.riderId !== uid) throw new HttpsError('permission-denied', 'Ride participant required.');
    const userRef = db.doc(`users/${data.riderId}`);
    const user = await tx.get(userRef);
    if (data.status !== 'cancelled' && !cancellable.includes(data.status)) throw new HttpsError('failed-precondition', 'Ride cannot be cancelled.');
    const offered = await offeredDriver(db, tx, data);
    const assigned = data.driverId ? await tx.get(db.doc(`drivers/${data.driverId}`)) : undefined;
    if (data.status !== 'cancelled') tx.update(ref, { status: 'cancelled', cancelledBy: 'rider', cancelledAt: FieldValue.serverTimestamp(),
      offeredTo: null, offerExpiresAt: null, offerDistanceMeters: null });
    if (offered?.data()?.offer?.rideId === ref.id) tx.update(offered.ref, { offer: null });
    if (assigned?.data()?.currentRideId === ref.id) tx.update(assigned.ref, { currentRideId: null });
    // A repeated cancellation must never clear a newer ride.
    if (user.data()?.activeRideId === ref.id) tx.update(userRef, { activeRideId: FieldValue.delete() });
    return false;
  });
  if (redispatched) await dispatchRide(db, ref.id, deps!);
  return { ok: true, redispatched };
}
export async function expireSearchingRidesHandler(db: Firestore, now = Timestamp.now(), deps?: MatchingDeps) {
  while (true) {
    const page = await db.collection('rides').where('status', '==', 'searching').where('searchExpiresAt', '<', now).limit(200).get();
    if (page.empty) break;
    for (const document of page.docs) {
      await db.runTransaction(async (tx) => {
        const ride = await tx.get(document.ref);
        const data = ride.data();
        if (!data || data.status !== 'searching' || data.searchExpiresAt.toMillis() >= now.toMillis()) return;
        const userRef = db.doc(`users/${data.riderId}`);
        const user = await tx.get(userRef);
        const offered = await offeredDriver(db, tx, data);
        tx.update(document.ref, { status: 'no_drivers', offeredTo: null, offerExpiresAt: null, offerDistanceMeters: null });
        if (offered?.data()?.offer?.rideId === document.id) tx.update(offered.ref, { offer: null });
        if (user.data()?.activeRideId === document.id) tx.update(userRef, { activeRideId: FieldValue.delete() });
      });
    }
  }
  if (deps) {
    const searching = await db.collection('rides').where('status', '==', 'searching').get();
    for (const ride of searching.docs) {
      const data = ride.data();
      if (data.searchExpiresAt?.toMillis?.() > now.toMillis() &&
          data.createdAt?.toMillis() < now.toMillis() - 20000 && !offerIsLive(data, now)) {
        await dispatchRide(db, ride.id, deps);
      }
    }
  }
}
