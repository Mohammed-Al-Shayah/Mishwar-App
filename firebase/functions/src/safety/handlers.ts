import { randomBytes } from 'node:crypto';
import { Timestamp, type Firestore } from 'firebase-admin/firestore';
import { HttpsError, type CallableRequest } from 'firebase-functions/v2/https';
import { authenticated } from '../lib/maps.js';
import { distanceBetween } from 'geofire-common';
import { rideId } from '../rides/handlers.js';

const active = ['accepted', 'arriving', 'arrived', 'in_progress'];
const tokenPattern = /^[A-Za-z0-9_-]{24}$/;
const millis = (value: unknown): number | undefined => {
  const time = value as { toMillis?: () => number } | undefined;
  return time?.toMillis?.();
};
export async function createShareLinkHandler(request: CallableRequest, db: Firestore, base: string,
  now = () => Timestamp.now(), token = () => randomBytes(18).toString('base64url')) {
  authenticated(request);
  const ref = db.doc(`rides/${rideId(request.data)}`);
  const result = await db.runTransaction(async tx => {
    const ride = (await tx.get(ref)).data();
    if (!ride) throw new HttpsError('not-found', 'Ride not found.');
    if (ride.riderId !== request.auth!.uid) throw new HttpsError('permission-denied', 'Rider required.');
    if (!active.includes(ride.status)) throw new HttpsError('failed-precondition', 'Active ride required.');
    if (typeof ride.shareToken === 'string' && tokenPattern.test(ride.shareToken)) {
      const share = (await tx.get(db.doc(`shares/${ride.shareToken}`))).data();
      if (share?.rideId === ref.id && (millis(share.expiresAt) ?? 0) > now().toMillis()) return ride.shareToken;
    }
    const value = token();
    const shareRef = db.doc(`shares/${value}`);
    if ((await tx.get(shareRef)).exists) throw new HttpsError('aborted', 'Retry token creation.');
    const createdAt = now();
    tx.create(shareRef, { rideId: ref.id, riderId: request.auth!.uid, createdAt,
      expiresAt: Timestamp.fromMillis(createdAt.toMillis() + 6 * 60 * 60 * 1000) });
    tx.update(ref, { shareToken: value });
    return value;
  });
  return { url: `${base.replace(/\/$/, '')}/t/${result}` };
}

export class ShareRateLimiter {
  private readonly requests = new Map<string, number>();
  allow(token: string, now: number) {
    const previous = this.requests.get(token);
    if (previous !== undefined && now - previous < 1000) return false;
    if (this.requests.size >= 10000) {
      for (const [key, time] of this.requests) if (now - time >= 1000) this.requests.delete(key);
      if (this.requests.size >= 10000) return false;
    }
    this.requests.set(token, now);
    return true;
  }
}
export async function sharedTripHandler(token: unknown, db: Firestore, limiter: ShareRateLimiter,
  now = Date.now()) {
  const error = (status: number) => ({ status, body: { error: status === 410 ? 'expired' : 'unavailable' } });
  if (typeof token !== 'string' || token.length !== 24 || !tokenPattern.test(token)) return error(404);
  if (!limiter.allow(token, now)) return error(429);
  const share = (await db.doc(`shares/${token}`).get()).data();
  if (!share || (millis(share.expiresAt) ?? 0) <= now) return error(404);
  const ride = (await db.doc(`rides/${share.rideId}`).get()).data();
  if (!ride || ride.shareToken !== token) return error(404);
  const ended = !active.includes(ride.status);
  const endAt = millis(ride.completedAt) ?? millis(ride.cancelledAt);
  if (ended && (endAt === undefined || now - endAt > 30 * 60 * 1000)) return error(ride.status === 'completed' ? 410 : 404);
  if (ended && !['completed', 'cancelled'].includes(ride.status)) return error(404);
  const live = !ended ? (await db.doc(`rides/${share.rideId}/live/driver`).get()).data() : undefined;
  const point = live?.geopoint;
  const currentDriverFix = (millis(live?.updatedAt) ?? 0) >= (millis(ride.acceptedAt) ?? 0);
  const driver = currentDriverFix && point && Number.isFinite(point.latitude) && Number.isFinite(point.longitude) ? {
    lat: point.latitude, lng: point.longitude, heading: Number.isFinite(live?.heading) ? live!.heading : 0,
    updatedAt: millis(live?.updatedAt) ?? null,
  } : null;
  const info = ride.driverInfo;
  const text = (v: unknown) => typeof v === 'string' ? v : '';
  const vehicle = info?.vehicle;
  return { status: 200, body: {
    status: text(ride.status), driverFirstName: text(info?.name).trim().split(/\s+/)[0],
    car: { make: text(vehicle?.make), model: text(vehicle?.model), color: text(vehicle?.color), plate: text(vehicle?.plate) },
    pickupName: text(ride.pickup?.name), dropoffName: text(ride.dropoff?.name), driver,
    etaMinutes: etaMinutes(ride, driver, ended, now),
    updatedAt: millis(live?.updatedAt) ?? endAt ?? millis(share.createdAt) ?? null,
  } };
}

// Same rule as the rider app: before pickup the ETA is the driver's distance to the
// pickup (~400 m/min); once arrived it is 0; on the trip it is the remaining route time.
function etaMinutes(ride: FirebaseFirestore.DocumentData, driver: { lat: number; lng: number } | null,
  ended: boolean, now: number): number {
  if (ended || ride.status === 'arrived') return 0;
  if (ride.status === 'in_progress') {
    const started = ride.startedAt?.toMillis?.() ?? now;
    const remaining = (Number(ride.route?.durationSeconds) || 0) - (now - started) / 1000;
    return Math.max(1, Math.ceil(remaining / 60));
  }
  const pickup = ride.pickup?.geopoint;
  if (!driver || !pickup) return Math.max(1, Math.ceil((Number(ride.offerDistanceMeters) || 0) / 400));
  const meters = distanceBetween([driver.lat, driver.lng], [pickup.latitude, pickup.longitude]) * 1000;
  return Math.max(1, Math.ceil(meters / 400));
}
