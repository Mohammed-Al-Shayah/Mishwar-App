import { validDeliveryCode } from './parcel.js';
import { FieldValue, Timestamp, type Firestore } from 'firebase-admin/firestore';
import { HttpsError, type CallableRequest } from 'firebase-functions/v2/https';
import { distanceBetween } from 'geofire-common';
import { authenticated } from '../lib/maps.js';
import * as v from '../lib/validate.js';
import { computeFare, DEFAULT_PRICING, parsePricing, roundFare, type VehicleType } from '../pricing.js';
import { readPromo } from '../promos/handlers.js';
import { earningsDay, parseFees, waitingFeeFils } from './fees.js';
import { rideId } from './handlers.js';

function invalid(): never {
  throw new HttpsError('failed-precondition', 'Ride transition is invalid.', { reason: 'invalid-transition' });
}
const transitions: Record<string, { from: string; timestamp: string }> = {
  arriving: { from: 'accepted', timestamp: 'arrivingAt' },
  arrived: { from: 'arriving', timestamp: 'arrivedAt' },
  in_progress: { from: 'arrived', timestamp: 'startedAt' },
  completed: { from: 'in_progress', timestamp: 'completedAt' },
};
export async function updateRideStatusHandler(request: CallableRequest, db: Firestore, now = () => Timestamp.now(), adminOverride = false) {
  authenticated(request);
  const uid = request.auth!.uid, id = rideId(request.data);
  const status = v.object(request.data).status;
  if (adminOverride && request.auth!.token?.admin !== true) throw new HttpsError('permission-denied', 'Admin claim required.');
  const ref = db.doc(`rides/${id}`);
  const log = adminOverride ? db.collection('adminLog').doc() : undefined;
  const result = await db.runTransaction(async (tx) => {
    const ride = (await tx.get(ref)).data();
    if (!ride) invalid();
    if (adminOverride && (ride.serviceType !== 'parcel' || status !== 'completed')) invalid();
    if (!adminOverride && ride.driverId !== uid) throw new HttpsError('permission-denied', 'Assigned driver required.');
    if (ride.status === status) return;
    if (typeof status !== 'string' || !Object.hasOwn(transitions, status)) invalid();
    const transition = transitions[status];
    if (ride.status !== transition.from) invalid();
    const driverRef = db.doc(`drivers/${ride.driverId}`);
    const driver = (await tx.get(driverRef)).data();
    if (!driver || driver.currentRideId !== id) invalid();
    const time = now();
    if (status === 'arrived') {
      const point = driver.location?.geopoint, pickup = ride.pickup?.geopoint;
      const age = time.toMillis() - (driver.lastSeenAt?.toMillis() ?? -Infinity);
      const distance = point && pickup ? distanceBetween([point.latitude, point.longitude],
        [pickup.latitude, pickup.longitude]) * 1000 : Infinity;
      if (age < 0 || age > 60000 || !Number.isFinite(distance) || distance > 200) {
        throw new HttpsError('failed-precondition', 'Driver must be near pickup with fresh location.', { reason: 'too-far' });
      }
    }
    if (status !== 'completed') {
      tx.update(ref, { status, [transition.timestamp]: time });
      return;
    }
    if (ride.serviceType === 'parcel' && !adminOverride) {
      if ((ride.parcel?.codeAttempts ?? 0) >= 5) return 'code-locked';
      if (!validDeliveryCode(id, v.object(request.data).deliveryCode, ride.parcel ?? {})) {
        const attempts = (ride.parcel?.codeAttempts ?? 0) + 1;
        tx.update(ref, { parcel: { ...ride.parcel, codeAttempts: attempts } });
        return attempts >= 5 ? 'code-locked' : 'bad-code';
      }
    }
    const userRef = db.doc(`users/${ride.riderId}`);
    const user = (await tx.get(userRef)).data();
    const settings = parseFees((await tx.get(db.doc('config/app'))).data());
    const waitingFils = waitingFeeFils(ride.arrivedAt, ride.startedAt, settings);
    const balanceFils = user?.balanceDueFils ?? 0;
    if (!Number.isSafeInteger(balanceFils) || balanceFils < 0) invalid();
    const pricingDocument = await tx.get(db.doc('config/pricing'));
    const pricing = pricingDocument.exists ? parsePricing(pricingDocument.data()) : DEFAULT_PRICING;
    const seconds = (time.toMillis() - (ride.startedAt?.toMillis() ?? NaN)) / 1000;
    if (!Number.isFinite(seconds) || seconds < 0 || !Number.isFinite(ride.fare?.estimated) || ride.fare.estimated < 0) invalid();
    const priced = computeFare(pricing[ride.vehicleType as VehicleType], ride.route.distanceMeters, seconds);
    const estimatedFils = Math.round(ride.fare.estimated * 1000);
    const cap = estimatedFils * 3 / 2000;
    let final = roundFare(Math.min(cap, Math.max(ride.fare.estimated, priced)));
    const checked = ride.promo ? await readPromo(db, tx, ride.promo.code, ride.riderId, final, ride.createdAt) : undefined;
    const discount = checked?.result.ok ? checked.result.discountJod : 0;
    final = roundFare(Math.max(0, (Math.round(final * 1000) - Math.round(discount * 1000)) / 1000));
    final = (Math.round(final * 1000) + waitingFils + balanceFils) / 1000;
    const day = earningsDay(time);
    const earningsRef = db.doc(`drivers/${ride.driverId}/earnings/${day}`);
    const earnings = (await tx.get(earningsRef)).data();
    if (checked?.result.ok) {
      tx.update(checked.ref, { usedCount: checked.promo!.usedCount + 1 });
      tx.set(checked.redemptionRef, { count: checked.count + 1, lastRideId: id, updatedAt: time });
    }
    // Earnings use the discounted fare for now; platform absorption comes with future payout logic.
    // Add integer fils, then persist a two-decimal JOD amount.
    const totalFils = Math.round((earnings?.total ?? 0) * 1000) + Math.round(final * 1000);
    if (log) tx.create(log, { action: 'adminCompleteParcel', target: id, by: uid, at: time });
    tx.update(ref, { status, completedAt: time, fare: { ...ride.fare, final, waitingFee: waitingFils / 1000, previousBalance: balanceFils / 1000, ...(ride.promo ? { discount } : {}) },
      ...(ride.promo ? { promo: { ...ride.promo, applied: checked!.result.ok } } : {}) });
    tx.update(userRef, { pendingRatingRideId: id, balanceDueFils: 0,
      ...(user?.activeRideId === id ? { activeRideId: FieldValue.delete() } : {}) });
    tx.update(driverRef, { currentRideId: null, pendingRatingRideId: id });
    tx.set(earningsRef, { ...earnings, total: Number((totalFils / 1000).toFixed(2)), trips: (earnings?.trips ?? 0) + 1, updatedAt: time });
  });
  if (result) throw new HttpsError('failed-precondition', 'Delivery code rejected.', { reason: result });
  return { ok: true };
}

export async function adminCompleteParcelHandler(request: CallableRequest, db: Firestore, now = () => Timestamp.now()) {
  return updateRideStatusHandler({ ...request, data: { ...v.object(request.data), status: 'completed' } }, db, now, true);
}
