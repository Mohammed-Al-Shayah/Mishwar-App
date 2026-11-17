import { FieldValue, Timestamp, type Firestore } from 'firebase-admin/firestore';
import { HttpsError, type CallableRequest } from 'firebase-functions/v2/https';
import { authenticated } from '../lib/maps.js';
import * as v from '../lib/validate.js';
import { rideId } from './handlers.js';
const driverTags = ['safe_driving', 'clean_car', 'friendly', 'knows_route', 'late', 'fast_driving', 'dirty_car', 'longer_route'];
const riderTags = ['friendly', 'on_time', 'respectful', 'late', 'rude'];
async function rating(request: CallableRequest, db: Firestore, skip: boolean) {
  authenticated(request);
  const uid = request.auth!.uid, id = rideId(request.data), data = v.object(request.data);
  const ref = db.doc('rides/' + id);
  await db.runTransaction(async tx => {
    const ride = (await tx.get(ref)).data();
    if (!ride) throw new HttpsError('not-found', 'Ride not found.');
    const isRider = ride.riderId === uid;
    if (!isRider && ride.driverId !== uid) throw new HttpsError('permission-denied', 'Ride participant required.');
    if (ride.status !== 'completed') throw new HttpsError('failed-precondition', 'Completed ride required.');
    const callerRef = db.doc((isRider ? 'users/' : 'drivers/') + uid);
    const caller = (await tx.get(callerRef)).data();
    if (!skip) {
      const { stars, comment = '', tags = [] } = data;
      if (typeof stars !== 'number' || !Number.isInteger(stars) || stars < 1 || stars > 5 ||
          typeof comment !== 'string' || comment.length > 300 || !Array.isArray(tags) || tags.length > 5 ||
          !tags.every(tag => typeof tag === 'string' && (isRider ? driverTags : riderTags).includes(tag))) v.invalid();
      const field = isRider ? 'driverRating' : 'riderRating';
      if (ride[field] != null) throw new HttpsError('already-exists', 'Already rated.');
      const targetRef = db.doc('users/' + (isRider ? ride.driverId : ride.riderId));
      const target = (await tx.get(targetRef)).data();
      const count = target?.ratingCount ?? 0, average = target?.rating ?? 5;
      tx.update(ref, { [field]: { stars, tags, comment, createdAt: Timestamp.now() } });
      tx.set(targetRef, { rating: Math.round(((average * count + stars) / (count + 1) + Number.EPSILON) * 100) / 100,
        ratingCount: count + 1 }, { merge: true });
    }
    if (caller?.pendingRatingRideId === id) tx.update(callerRef, { pendingRatingRideId: FieldValue.delete() });
  });
  return { ok: true };
}
export const rateRideHandler = (request: CallableRequest, db: Firestore) => rating(request, db, false);
export const skipRatingHandler = (request: CallableRequest, db: Firestore) => rating(request, db, true);
