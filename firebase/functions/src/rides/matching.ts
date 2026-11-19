import { findMarket } from '../markets.js';
import { FieldValue, Timestamp, type DocumentData, type Firestore, type Transaction } from 'firebase-admin/firestore';
import { distanceBetween, geohashQueryBounds } from 'geofire-common';

export interface OfferTask { rideId: string; seq: number | 'retry' }
export interface MatchingDeps {
  now: () => Timestamp;
  enqueue: (data: OfferTask, scheduleDelaySeconds: number) => Promise<void>;
  notify: (uid: string, rideId: string) => Promise<void>;
}
export const offerIsLive = (data: DocumentData, now: Timestamp) =>
  !!data.offeredTo && data.offerExpiresAt?.toMillis() > now.toMillis();

function searchable(data: DocumentData | undefined, now: Timestamp): data is DocumentData {
  // Malformed rides (e.g. written by an admin tool without a deadline) are ignored, never crash the trigger.
  const deadline = data?.searchExpiresAt;
  return data?.status === 'searching' && deadline instanceof Timestamp && now.toMillis() < deadline.toMillis()
    && !!data.pickup?.geopoint;
}
function distance(driver: DocumentData, ride: DocumentData) {
  const point = driver.location?.geopoint, pickup = ride.pickup.geopoint;
  return point ? distanceBetween([point.latitude, point.longitude], [pickup.latitude, pickup.longitude]) * 1000 : Infinity;
}
function eligible(uid: string, driver: DocumentData | undefined, ride: DocumentData, now: Timestamp, app?: Record<string, unknown>) {
  const point = driver?.location?.geopoint;
  return point && findMarket({ lat: point.latitude, lng: point.longitude }, app) === (ride.market ?? 'JO') && driver && driver.isOnline === true && driver.status === 'approved' &&
    driver.vehicle?.type === ride.vehicleType && !driver.currentRideId &&
    (!driver.offer || driver.offer.expiresAt?.toMillis() <= now.toMillis()) &&
    driver.lastSeenAt?.toMillis() >= now.toMillis() - 60000 &&
    !(ride.declinedBy ?? []).includes(uid) && uid !== ride.offeredTo && uid !== ride.riderId &&
    distance(driver, ride) <= 5000;
}

// Read before any transaction writes; never clear an offer belonging to another ride.
export async function offeredDriver(db: Firestore, tx: Transaction, ride: DocumentData) {
  return ride.offeredTo ? tx.get(db.doc(`drivers/${ride.offeredTo}`)) : undefined;
}

export async function dispatchRide(db: Firestore, rideId: string, deps: MatchingDeps) {
  const ref = db.doc(`rides/${rideId}`);
  const initial = (await ref.get()).data(), startedAt = deps.now();
  if (!searchable(initial, startedAt) || offerIsLive(initial, startedAt)) return;
  const app = (await db.doc('config/app').get()).data();
  const sequence = initial.offerSeq ?? 0;
  const pickup = initial.pickup.geopoint;
  const bounds = geohashQueryBounds([pickup.latitude, pickup.longitude], 5000);
  const snapshots = await Promise.all(bounds.map(([start, end]) => db.collection('drivers')
    .orderBy('location.geohash').startAt(start).endAt(end).get()));
  const unique = new Map(snapshots.flatMap((snapshot) => snapshot.docs).map((doc) => [doc.id, doc]));
  const candidates = [...unique.values()].filter((doc) => eligible(doc.id, doc.data(), initial, startedAt, app))
    .sort((a, b) => distance(a.data(), initial) - distance(b.data(), initial) || a.id.localeCompare(b.id)).slice(0, 10);

  for (const candidate of candidates) {
    const assigned = await db.runTransaction(async (tx) => {
      const ride = (await tx.get(ref)).data(), now = deps.now();
      if (!searchable(ride, now) || (ride.offerSeq ?? 0) !== sequence || offerIsLive(ride, now)) return false;
      const driver = await tx.get(candidate.ref);
      if (!eligible(driver.id, driver.data(), ride, now, (await tx.get(db.doc('config/app'))).data())) return false;
      const previous = await offeredDriver(db, tx, ride);
      const expiresAt = Timestamp.fromMillis(now.toMillis() + 15000);
      tx.update(ref, { offeredTo: driver.id, offerExpiresAt: expiresAt, offerSeq: sequence + 1,
        offerDistanceMeters: Math.round(distance(driver.data()!, ride)),
        ...(ride.offeredTo ? { declinedBy: FieldValue.arrayUnion(ride.offeredTo) } : {}) });
      if (previous?.data()?.offer?.rideId === rideId) tx.update(previous.ref, { offer: null });
      tx.update(driver.ref, { offer: { rideId, expiresAt, seq: sequence + 1, serviceType: ride.serviceType ?? 'ride' } });
      return true;
    });
    if (assigned) {
      await deps.enqueue({ rideId, seq: sequence + 1 }, 16);
      await deps.notify(candidate.id, rideId);
      return;
    }
  }
  const retry = await db.runTransaction(async (tx) => {
    const ride = (await tx.get(ref)).data(), now = deps.now();
    if (!searchable(ride, now) || (ride.offerSeq ?? 0) !== sequence || offerIsLive(ride, now)) return false;
    const previous = await offeredDriver(db, tx, ride);
    if (ride.offeredTo) {
      tx.update(ref, { offeredTo: null, offerExpiresAt: null, offerDistanceMeters: null,
        declinedBy: FieldValue.arrayUnion(ride.offeredTo) });
      if (previous?.data()?.offer?.rideId === rideId) tx.update(previous.ref, { offer: null });
    }
    return now.toMillis() + 10000 < ride.searchExpiresAt.toMillis();
  });
  if (retry) await deps.enqueue({ rideId, seq: 'retry' }, 10);
}

const wait = (ms: number) => new Promise<void>((resolve) => setTimeout(resolve, ms));

export async function offerTimeoutHandler(db: Firestore, task: OfferTask, deps: MatchingDeps, sleep = wait) {
  const ride = (await db.doc(`rides/${task.rideId}`).get()).data();
  if (!ride || (task.seq !== 'retry' && ride.offerSeq !== task.seq)) return;
  // Cloud Tasks delivers on schedule in production; the local emulator delivers immediately,
  // so wait out a still-live offer (bounded to one offer window) instead of dropping the timeout.
  const remaining = task.seq === 'retry' ? 0 : (ride.offerExpiresAt?.toMillis() ?? 0) - deps.now().toMillis();
  if (remaining > 0 && remaining <= 16000) await sleep(remaining + 250);
  await dispatchRide(db, task.rideId, deps);
}
