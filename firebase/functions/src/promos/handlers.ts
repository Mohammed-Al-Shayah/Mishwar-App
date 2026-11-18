import { Timestamp, type Firestore, type Transaction } from 'firebase-admin/firestore';
import { HttpsError, type CallableRequest } from 'firebase-functions/v2/https';
import { fareEstimatesHandler } from '../getFareEstimates.js';
import { authenticated } from '../lib/maps.js';
import * as v from '../lib/validate.js';
import { evaluatePromo, type Promo } from './evaluate.js';

export function normalizePromo(value: unknown): string {
  if (typeof value !== 'string') throw new HttpsError('failed-precondition', 'Invalid promo.', { reason: 'not-found' });
  const code = value.trim().toUpperCase();
  if (!/^[A-Z0-9]{3,20}$/.test(code)) throw new HttpsError('failed-precondition', 'Invalid promo.', { reason: 'not-found' });
  return code;
}
// All reads precede writes so this helper can participate in ride completion.
export async function readPromo(db: Firestore, tx: Transaction, code: string, uid: string, fareJod: number, now: Timestamp) {
  const ref = db.doc(`promos/${code}`), redemptionRef = db.doc(`promos/${code}/redemptions/${uid}`);
  const promo = (await tx.get(ref)).data() as Promo | undefined;
  const count = (await tx.get(redemptionRef)).data()?.count ?? 0;
  const completed = await tx.get(db.collection('rides').where('riderId', '==', uid).where('status', '==', 'completed').limit(1));
  return { ref, redemptionRef, promo, count, result: evaluatePromo(promo, {
    fareJod, uid, isFirstRide: completed.empty, userRedemptions: count, now,
  }) };
}
export async function previewPromo(db: Firestore, code: string, uid: string, fare: number, now = Timestamp.now()) {
  return db.runTransaction(async tx => {
    const checked = await readPromo(db, tx, code, uid, fare, now);
    if (!checked.result.ok) throw new HttpsError('failed-precondition', 'Promo unavailable.', {
      reason: checked.result.reason, ...(checked.result.reason === 'min-fare' ? { minFare: checked.promo!.minFare } : {}),
    });
    return { code, discountPreview: checked.result.discountJod };
  });
}
export async function validatePromoHandler(request: CallableRequest, db: Firestore, key: string,
  estimate = fareEstimatesHandler, now = () => Timestamp.now()) {
  authenticated(request);
  const uid = request.auth!.uid, data = v.object(request.data);
  if ((await db.doc(`users/${uid}`).get()).data()?.role !== 'rider') throw new HttpsError('permission-denied', 'Rider role required.');
  // Invalid attempts count too, and the counter commits even when evaluation fails.
  await db.runTransaction(async tx => {
    const ref = db.doc(`users/${uid}/meta/promoChecks`), previous = (await tx.get(ref)).data();
    const time = now(), fresh = !previous || time.toMillis() - previous.windowStart.toMillis() >= 600000;
    const count = fresh ? 0 : previous.count;
    if (count >= 10) throw new HttpsError('resource-exhausted', 'Too many promo checks.', { reason: 'rate-limit' });
    tx.set(ref, { count: count + 1, windowStart: fresh ? time : previous!.windowStart });
  });
  const code = normalizePromo(data.code);
  if (!['economy', 'comfort', 'van'].includes(data.vehicleType as string)) v.invalid();
  const pickup = v.point(v.object(data.pickup)), dropoff = v.point(v.object(data.dropoff));
  const estimates = await estimate({ ...request, data: { origin: pickup, destination: dropoff } }, key);
  const fareBefore = estimates.fares.find(fare => fare.vehicleType === data.vehicleType)!.amount;
  const promo = await previewPromo(db, code, uid, fareBefore, now());
  return { code, discount: promo.discountPreview, fareBefore,
    fareAfter: (Math.round(fareBefore * 1000) - Math.round(promo.discountPreview * 1000)) / 1000 };
}
