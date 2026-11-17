import { FieldValue, Timestamp, type Firestore } from 'firebase-admin/firestore';
import { HttpsError, type CallableRequest } from 'firebase-functions/v2/https';
import * as v from '../lib/validate.js';
import { parsePricing, type PricingTable } from '../pricing.js';
import { activeStatuses, rideId } from '../rides/handlers.js';
import { dispatchRide, type MatchingDeps } from '../rides/matching.js';

function admin(request: CallableRequest): string {
  if (request.auth?.token.admin !== true) throw new HttpsError('permission-denied', 'Admin claim required.');
  return request.auth.uid;
}
function id(value: unknown): string {
  const result = v.string(value, 1, 128);
  if (result.includes('/')) v.invalid();
  return result;
}
function invalidTransition(): never { throw new HttpsError('failed-precondition', 'Invalid transition.'); }
const transitions: Record<string, Record<string, string>> = {
  pending: { approve: 'approved', reject: 'rejected' },
  approved: { suspend: 'suspended' }, suspended: { reactivate: 'approved' }, rejected: { approve: 'approved' },
};
export async function reviewDriverHandler(request: CallableRequest, db: Firestore, deps: MatchingDeps) {
  const by = admin(request), data = v.object(request.data), uid = id(data.uid);
  const decision = v.string(data.decision, 1, 20);
  if (!['approve', 'reject', 'suspend', 'reactivate'].includes(decision)) v.invalid();
  const reason = data.reason === undefined ? '' : v.string(data.reason, 0, 200);
  if (['reject', 'suspend'].includes(decision) && !reason) v.invalid();
  const ref = db.doc(`drivers/${uid}`), log = db.collection('adminLog').doc();
  const redispatch = await db.runTransaction(async tx => {
    const driver = (await tx.get(ref)).data();
    if (!driver) throw new HttpsError('not-found', 'Driver not found.');
    const status = transitions[driver.status]?.[decision];
    if (!status) invalidTransition();
    const offerId = decision === 'suspend' ? driver.offer?.rideId : undefined;
    const rideRef = offerId ? db.doc(`rides/${id(offerId)}`) : undefined;
    const ride = rideRef ? (await tx.get(rideRef)).data() : undefined;
    const at = deps.now();
    const decline = rideRef && ride?.status === 'searching' && ride.offeredTo === uid;
    tx.update(ref, { status, reviewedAt: at, reviewedBy: by,
      ...(decision === 'reject' ? { rejectionReason: reason } : {}),
      ...(decision === 'suspend' ? { suspensionReason: reason, isOnline: false, offer: null } : {}),
      ...(status === 'approved' ? { rejectionReason: FieldValue.delete(), suspensionReason: FieldValue.delete() } : {}) });
    if (decline) tx.update(rideRef, { declinedBy: FieldValue.arrayUnion(uid), offeredTo: null,
      offerExpiresAt: null, offerDistanceMeters: null });
    tx.create(log, { action: 'reviewDriver', target: uid, by, at, details: { decision, reason, from: driver.status, to: status } });
    return decline ? offerId as string : undefined;
  });
  if (redispatch) await dispatchRide(db, redispatch, deps);
  return { ok: true };
}
export async function updatePricingHandler(request: CallableRequest, db: Firestore) {
  const by = admin(request), data = v.object(request.data);
  let pricing: PricingTable;
  try {
    pricing = parsePricing(data);
    for (const type of ['economy', 'comfort', 'van'] as const) {
      for (const field of ['base', 'perKm', 'perMin', 'minimum'] as const) {
        const value = pricing[type][field];
        if (!(value > 0 && value <= 50)) v.invalid();
      }
    }
  } catch { return v.invalid(); }
  const clean = Object.fromEntries(['economy', 'comfort', 'van'].map(type => [type,
    Object.fromEntries(['base', 'perKm', 'perMin', 'minimum'].map(field => [field, v.object(data[type])[field]]))]));
  const at = Timestamp.now(), log = db.collection('adminLog').doc();
  await db.runTransaction(async tx => {
    tx.set(db.doc('config/pricing'), { ...clean, updatedAt: at, updatedBy: by });
    tx.create(log, { action: 'updatePricing', target: 'config/pricing', by, at, details: clean });
  });
  return { ok: true };
}
export async function adminCancelRideHandler(request: CallableRequest, db: Firestore) {
  const by = admin(request), data = v.object(request.data), target = rideId(data), reason = v.string(data.reason, 1, 200);
  const ref = db.doc(`rides/${target}`), log = db.collection('adminLog').doc();
  await db.runTransaction(async tx => {
    const ride = (await tx.get(ref)).data();
    if (!ride) throw new HttpsError('not-found', 'Ride not found.');
    if (!activeStatuses.includes(ride.status)) invalidTransition();
    const userRef = db.doc(`users/${ride.riderId}`), user = (await tx.get(userRef)).data();
    const drivers = await Promise.all([...new Set([ride.driverId, ride.offeredTo].filter(Boolean))]
      .map(uid => tx.get(db.doc(`drivers/${uid}`))));
    const at = Timestamp.now();
    tx.update(ref, { status: 'cancelled', cancelledBy: 'system', cancellationReason: reason, cancelledAt: at,
      offeredTo: null, offerExpiresAt: null, offerDistanceMeters: null });
    if (user?.activeRideId === target) tx.update(userRef, { activeRideId: FieldValue.delete() });
    for (const driver of drivers) {
      const d = driver.data();
      const changes = { ...(d?.currentRideId === target ? { currentRideId: null } : {}),
        ...(d?.offer?.rideId === target ? { offer: null } : {}) };
      if (Object.keys(changes).length) tx.update(driver.ref, changes);
    }
    tx.create(log, { action: 'adminCancelRide', target, by, at, details: { reason, from: ride.status } });
  });
  return { ok: true };
}
