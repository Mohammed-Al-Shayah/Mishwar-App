import { formatMoney, toMinor } from '../money.js';
import { FieldValue, type Firestore } from 'firebase-admin/firestore';
import type { Messaging } from 'firebase-admin/messaging';

type Log = (message: string) => void;

// Push is best-effort, including cleanup and logging failures.
export async function sendOfferNotification(
  db: Firestore, messaging: Pick<Messaging, 'send'>, uid: string, rideId: string, log: Log, body?: string,
): Promise<void> {
  const safeLog = (message: string) => { try { log(message); } catch { /* Best effort. */ } };
  try {
    if (process.env.FUNCTIONS_EMULATOR === 'true') {
      safeLog(`[fcm:emulator] ${body ? 'scheduled' : 'offer'} ${rideId} → ${uid}${body ? `: ${body}` : ''}`);
      return;
    }
    const userRef = db.doc(`users/${uid}`);
    const token = (await userRef.get()).data()?.fcmToken;
    if (typeof token !== 'string' || !token) return;
    const ride = (await db.doc(`rides/${rideId}`).get()).data();
    if (!ride) return;
    try {
      await messaging.send({
        token, data: { type: body ? 'scheduled_ride' : 'ride_offer', rideId },
        notification: { title: body ? 'مشوارك المجدول' : 'طلب مشوار جديد', body: body ?? `${ride.pickup.name} · ${formatMoney(toMinor(ride.fare.estimated, ride.fare.currency ?? 'JOD'), ride.fare.currency ?? 'JOD')}` },
        android: { priority: 'high', ttl: 15000, notification: { channelId: 'ride_offers', sound: 'default' } },
        apns: { headers: { 'apns-priority': '10', 'apns-expiration': String(Math.floor(Date.now() / 1000) + 15) },
          payload: { aps: { sound: 'default' } } },
      });
    } catch (error) {
      const code = (error as { code?: string } | null)?.code;
      safeLog(`[fcm] offer ${rideId} → ${uid} failed (${code ?? 'unknown'})`);
      if (code === 'messaging/registration-token-not-registered' || code === 'messaging/invalid-registration-token') {
        await db.runTransaction(async (tx) => {
          const current = await tx.get(userRef);
          if (current.data()?.fcmToken === token) tx.update(userRef, { fcmToken: FieldValue.delete() });
        });
      }
    }
  } catch {
    safeLog(`[fcm] offer ${rideId} → ${uid} failed`);
  }
}
