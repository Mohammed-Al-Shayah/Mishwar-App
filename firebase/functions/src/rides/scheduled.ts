import { deliverySecret, emulatorSmsSender, requireSmsSender, type SmsSender } from './parcel.js';
import { Timestamp, type Firestore } from 'firebase-admin/firestore';
import { HttpsError, type CallableRequest } from 'firebase-functions/v2/https';
import { authenticated } from '../lib/maps.js';
import { fareEstimatesHandler } from '../getFareEstimates.js';
import { buildRide } from './handlers.js';
import { dispatchRide, type MatchingDeps } from './matching.js';

export const defaultScheduling = { minLeadMinutes: 30, maxDaysAhead: 30, dispatchBeforeMinutes: 15 };
export type Scheduling = typeof defaultScheduling;
// Cache only within this function instance; failed reads can be retried.
export function schedulingReader(db: Firestore) {
  let cached: Promise<Scheduling> | undefined;
  return () => cached ??= db.doc('config/app').get().then(snapshot => {
    const values = snapshot.data()?.scheduling;
    return Object.fromEntries(Object.entries(defaultScheduling).map(([name, fallback]) => {
      const value = values?.[name];
      return [name, typeof value === 'number' && Number.isFinite(value) && value > 0 ? value : fallback];
    })) as Scheduling;
  }).catch(error => { cached = undefined; throw error; });
}

export async function scheduleRideHandler(request: CallableRequest, db: Firestore, key: string,
  config = async () => defaultScheduling, estimate = fareEstimatesHandler, now = () => Timestamp.now(), sms: SmsSender = emulatorSmsSender) {
  authenticated(request);
  const settings = await config(), time = now();
  const raw = request.data?.scheduledFor;
  const millis = typeof raw === 'number' ? raw : typeof raw === 'string' && /^\d{4}-\d{2}-\d{2}T.*(?:Z|[+-]\d{2}:\d{2})$/.test(raw) ? Date.parse(raw) : NaN;
  if (!Number.isFinite(millis) || millis < time.toMillis() + settings.minLeadMinutes * 60000 ||
      millis > time.toMillis() + settings.maxDaysAhead * 86400000) {
    throw new HttpsError('invalid-argument', 'Scheduled time is outside the scheduling window.');
  }
  const ride = await buildRide(request, db, key, estimate);
  const ref = db.collection('rides').doc(), userRef = db.doc(`users/${request.auth!.uid}`);
  const secret = ride.parcel ? deliverySecret(ref.id) : undefined;
  if (secret) requireSmsSender(sms);
  await db.runTransaction(async tx => {
    const user = (await tx.get(userRef)).data();
    if (user?.role !== 'rider' || user.accountDeleting) throw new HttpsError('permission-denied', 'Rider role required.');
    const future = await tx.get(db.collection('rides').where('riderId', '==', request.auth!.uid)
      .where('status', '==', 'scheduled').where('scheduledFor', '>=', time).limit(3));
    if (future.docs.length >= 3) throw new HttpsError('failed-precondition', 'Too many scheduled rides.', { reason: 'too-many-scheduled' });
    tx.create(ref, { ...ride, ...(secret ? { parcel: { ...ride.parcel, deliveryCodeHash: secret.deliveryCodeHash, deliveryCodeSalt: secret.deliveryCodeSalt, codeAttempts: 0 } } : {}), status: 'scheduled', scheduledFor: Timestamp.fromMillis(millis) });
    if (secret) tx.create(db.doc(`rides/${ref.id}/private/rider`), { deliveryCode: secret.deliveryCode });
    // Serialize concurrent bookings on the rider document without changing activeRideId.
    tx.update(userRef, { scheduledRideUpdatedAt: time });
  });
  if (secret) await sms.send(ride.parcel!.recipientPhone, `مشوار: رمز استلام طردك ${secret.deliveryCode}`);
  return { rideId: ref.id, ...(secret ? { deliveryCode: secret.deliveryCode } : {}) };
}

export interface ScheduledDeps {
  now: () => Timestamp;
  config: () => Promise<Scheduling>;
  notify: (uid: string, rideId: string, body: string) => Promise<void>;
  dispatch: (rideId: string) => Promise<void>;
}
export function scheduledMatching(db: Firestore, matching: MatchingDeps) {
  return (id: string) => dispatchRide(db, id, matching);
}
export async function dispatchScheduledRidesHandler(db: Firestore, deps: ScheduledDeps) {
  const now = deps.now(), settings = await deps.config();
  const due = await db.collection('rides').where('status', '==', 'scheduled')
    .where('scheduledFor', '<=', Timestamp.fromMillis(now.toMillis() + Math.max(60, settings.dispatchBeforeMinutes) * 60000)).get();
  for (const snapshot of due.docs) {
    const result = await db.runTransaction(async tx => {
      const ride = (await tx.get(snapshot.ref)).data();
      if (ride?.status !== 'scheduled') return;
      const time = ride.scheduledFor.toMillis();
      const reminder = !ride.reminderSentAt && time - 3600000 <= now.toMillis();
      const dispatch = time - settings.dispatchBeforeMinutes * 60000 <= now.toMillis();
      const userRef = db.doc(`users/${ride.riderId}`);
      const user = dispatch ? (await tx.get(userRef)).data() : undefined;
      const busy = dispatch && (!user || user.accountDeleting || !!user.activeRideId);
      if (reminder) tx.update(snapshot.ref, { reminderSentAt: now });
      if (dispatch) {
        if (busy) tx.update(snapshot.ref, { status: 'cancelled', cancelledBy: 'system', cancelReason: 'rider_busy', cancelledAt: now });
        else {
          tx.update(snapshot.ref, { status: 'searching', searchExpiresAt: Timestamp.fromMillis(Math.max(now.toMillis() + 120000, time + 300000)) });
          tx.update(userRef, { activeRideId: snapshot.id });
        }
      }
      return { uid: ride.riderId as string, time, reminder, searching: dispatch && !busy, busy };
    });
    if (!result) continue;
    if (result.reminder) {
      const time = new Intl.DateTimeFormat('ar', { timeZone: 'Asia/Amman', hour: 'numeric', minute: '2-digit' }).format(new Date(result.time));
      await deps.notify(result.uid, snapshot.id, `مشوارك المجدول الساعة ${time}`);
    }
    if (result.busy) await deps.notify(result.uid, snapshot.id, 'تم إلغاء مشوارك المجدول لأن لديك مشواراً جارياً');
    if (result.searching) await deps.dispatch(snapshot.id);
  }
}
