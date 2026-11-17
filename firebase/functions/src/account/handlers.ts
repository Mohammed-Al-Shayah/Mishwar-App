import { type Firestore } from 'firebase-admin/firestore';
import { HttpsError, type CallableRequest } from 'firebase-functions/v2/https';
import { authenticated } from '../lib/maps.js';
import { declineRideHandler } from '../rides/offers.js';
import { type MatchingDeps } from '../rides/matching.js';

export interface AccountDeps {
  matching: MatchingDeps;
  deleteFiles: (prefix: string) => Promise<unknown>;
  deleteUser: (uid: string) => Promise<unknown>;
}
function busy(): never {
  throw new HttpsError('failed-precondition', 'Finish the current ride first.', { reason: 'busy' });
}
// Serializes the busy check and offline change with acceptRide/requestRide.
async function prepare(request: CallableRequest, db: Firestore, role?: 'rider' | 'driver') {
  const uid = request.auth!.uid;
  return db.runTransaction(async tx => {
    const userRef = db.doc(`users/${uid}`), driverRef = db.doc(`drivers/${uid}`);
    const user = (await tx.get(userRef)).data();
    const driver = (await tx.get(driverRef)).data();
    const leavingDriver = role !== 'driver' || user?.role === 'driver';
    if (user?.activeRideId || user?.pendingRatingRideId || driver?.pendingRatingRideId ||
        (leavingDriver && driver?.currentRideId)) busy();
    if (role && (!user || user.accountDeleting)) throw new HttpsError('failed-precondition', 'Account unavailable.');
    if (user?.role === 'admin') throw new HttpsError('permission-denied', 'Admin account cannot change role.');
    if (user) tx.update(userRef, role ? { role } : { accountDeleting: true });
    if (leavingDriver && driver) tx.update(driverRef, { isOnline: false });
    return leavingDriver ? driver?.offer?.rideId as string | undefined : undefined;
  });
}
async function clearOffer(request: CallableRequest, db: Firestore, deps: MatchingDeps, id?: string) {
  if (!id) return;
  await declineRideHandler({ ...request, data: { rideId: id } }, db, deps);
  // Also remove expired/stale offers that decline correctly leaves untouched.
  const ref = db.doc(`drivers/${request.auth!.uid}`);
  await db.runTransaction(async tx => {
    const driver = (await tx.get(ref)).data();
    if (driver?.offer?.rideId === id) tx.update(ref, { offer: null });
  });
}
export async function switchRoleHandler(request: CallableRequest, db: Firestore, deps: MatchingDeps) {
  authenticated(request);
  const role = request.data?.role;
  if (role !== 'rider' && role !== 'driver') throw new HttpsError('invalid-argument', 'Invalid role.');
  const offer = await prepare(request, db, role);
  await clearOffer(request, db, deps, offer);
  return { ok: true };
}
export async function deleteAccountHandler(request: CallableRequest, db: Firestore, deps: AccountDeps) {
  authenticated(request);
  const uid = request.auth!.uid;
  const offer = await prepare(request, db);
  await clearOffer(request, db, deps.matching, offer);
  for (const side of ['rider', 'driver']) {
    const rides = await db.collection('rides').where(`${side}Id`, '==', uid).get();
    for (let start = 0; start < rides.docs.length; start += 500) {
      const batch = db.batch();
      for (const ride of rides.docs.slice(start, start + 500)) {
        batch.update(ride.ref, { [`${side}Info.name`]: 'deleted', [`${side}Info.phone`]: null });
      }
      await batch.commit();
    }
  }
  while (true) {
    const earnings = await db.collection(`drivers/${uid}/earnings`).limit(500).get();
    if (earnings.empty) break;
    const batch = db.batch();
    for (const doc of earnings.docs) batch.delete(doc.ref);
    await batch.commit();
  }
  await deps.deleteFiles(`drivers/${uid}/`);
  const batch = db.batch();
  batch.delete(db.doc(`drivers/${uid}`));
  batch.delete(db.doc(`users/${uid}`));
  await batch.commit();
  try { await deps.deleteUser(uid); } catch (error) {
    if ((error as { code?: string }).code !== 'auth/user-not-found') throw error;
  }
  return { ok: true };
}
