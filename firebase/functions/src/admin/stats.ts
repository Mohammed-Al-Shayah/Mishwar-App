import { Timestamp, type Firestore } from 'firebase-admin/firestore';
import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import { getFirestore } from 'firebase-admin/firestore';
import { earningsDay } from '../rides/fees.js';

type Ride = Record<string, unknown>;
type Counters = Record<string, number>;
export const emptyDailyStats = { requested: 0, completed: 0, cancelledByRider: 0, cancelledByDriver: 0, cancelledBySystem: 0, noDrivers: 0, revenueFils: 0, discountFils: 0, promoUses: 0, parcels: 0, airport: 0, scheduled: 0 };
export interface Contribution { marker: string; day: string; counters: Counters; promoCode?: string }
function stamp(value: unknown, fallback: Timestamp): Timestamp {
  return value && typeof (value as Timestamp).toMillis === 'function' ? value as Timestamp : fallback;
}
function fils(value: unknown): number {
  return typeof value === 'number' && Number.isFinite(value) && value >= 0 ? Math.round(value * 1000) : 0;
}
/** One count per ride/category. Re-dispatch is a driver cancellation, not a new request. */
export function rideContributions(ride: Ride, eventTime: Timestamp): Contribution[] {
  const created = stamp(ride.createdAt, eventTime);
  const contributions: Contribution[] = [{ marker: 'requested', day: earningsDay(created), counters: {
    requested: 1, parcels: ride.serviceType === 'parcel' ? 1 : 0, airport: ride.serviceType === 'airport' ? 1 : 0, scheduled: ride.scheduledFor ? 1 : 0,
  } }];
  if (ride.driverCancelledAt) contributions.push({ marker: 'cancelledByDriver', day: earningsDay(stamp(ride.driverCancelledAt, eventTime)), counters: { cancelledByDriver: 1 } });
  if (ride.status === 'completed') {
    const fare = ride.fare as Record<string, unknown> | undefined, promo = ride.promo as Record<string, unknown> | undefined;
    const discountFils = fils(fare?.discount);
    const promoCode = promo?.applied === true && typeof promo.code === 'string' && /^[A-Z0-9]{3,20}$/.test(promo.code) ? promo.code : undefined;
    contributions.push({ marker: 'completed', day: earningsDay(stamp(ride.completedAt, eventTime)), counters: {
      completed: 1, revenueFils: fils(fare?.final), discountFils, promoUses: promoCode ? 1 : 0,
    }, promoCode });
  } else if (ride.status === 'cancelled') {
    const marker = ride.cancelledBy === 'rider' ? 'cancelledByRider' : ride.cancelledBy === 'driver' ? 'cancelledByDriver' : 'cancelledBySystem';
    if (!contributions.some(c => c.marker === marker)) contributions.push({ marker, day: earningsDay(stamp(ride.cancelledAt, eventTime)), counters: { [marker]: 1 } });
  } else if (ride.status === 'no_drivers') {
    contributions.push({ marker: 'noDrivers', day: earningsDay(stamp(ride.noDriversAt ?? ride.searchExpiresAt, eventTime)), counters: { noDrivers: 1 } });
  }
  return contributions;
}
export async function countRideStats(db: Firestore, rideId: string, before: Ride | undefined, after: Ride | undefined, eventTime: Timestamp) {
  if (!after || (before && before.status === after.status)) return;
  const contributions = rideContributions(after, eventTime);
  await db.runTransaction(async tx => {
    const ref = db.doc(`rides/${rideId}`), current = await tx.get(ref);
    if (!current.exists) return;
    const counted = new Set<string>(current.data()?.statsCountedFor ?? []);
    const pending = contributions.filter(c => !counted.has(c.marker));
    if (!pending.length) return;
    const updates = new Map<string, { counters: Counters; promos: Counters }>();
    for (const c of pending) {
      const path = `stats/${c.day}`, update = updates.get(path) ?? { counters: {}, promos: {} };
      for (const [key, value] of Object.entries(c.counters)) update.counters[key] = (update.counters[key] ?? 0) + value;
      if (c.promoCode) {
        update.promos[c.promoCode] = (update.promos[c.promoCode] ?? 0) + 1;
        updates.set(`stats/promos/${c.promoCode}/${c.day}`, { counters: { uses: 1 }, promos: {} });
      }
      updates.set(path, update);
      counted.add(c.marker);
    }
    // Read every aggregate before writing; transactions serialize competing rides and retries.
    const snapshots = await Promise.all([...updates.keys()].map(path => tx.get(db.doc(path))));
    for (const snapshot of snapshots) {
      const update = updates.get(snapshot.ref.path)!, previous = snapshot.data() ?? {};
      const next: Record<string, unknown> = { ...(snapshot.ref.path.split('/').length === 2 ? emptyDailyStats : {}), ...previous };
      for (const [key, value] of Object.entries(update.counters)) next[key] = (previous[key] ?? 0) + value;
      const promoUsesByCode = { ...previous.promoUsesByCode };
      for (const [key, value] of Object.entries(update.promos)) promoUsesByCode[key] = (promoUsesByCode[key] ?? 0) + value;
      if (Object.keys(promoUsesByCode).length) next.promoUsesByCode = promoUsesByCode;
      tx.set(snapshot.ref, next);
    }
    tx.update(ref, { statsCountedFor: [...counted] });
  });
}
export const onRideStatsWritten = onDocumentWritten({ region: 'europe-west1', document: 'rides/{rideId}', retry: true }, async event => {
  await countRideStats(getFirestore(), event.params.rideId, event.data?.before.data(), event.data?.after.data(), Timestamp.fromDate(new Date(event.time)));
});
