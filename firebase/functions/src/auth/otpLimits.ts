import { createHash } from 'node:crypto';
import { getIPV6Address } from './ip.js';
import { Timestamp, type Firestore } from 'firebase-admin/firestore';
import { HttpsError, type AuthBlockingEvent } from 'firebase-functions/v2/identity';

const hour = 60 * 60 * 1000;
const day = 24 * hour;
const hash = (kind: string, value: string) => createHash('sha256').update(`${kind}:${value}`).digest('hex');

/** Sliding windows prevent bursts across boundaries. Never log the event or PII. */
export async function limitOtpSms(event: Pick<AuthBlockingEvent, 'additionalUserInfo' | 'ipAddress'>,
  db: Firestore, now = Date.now()): Promise<void> {
  const phone = event.additionalUserInfo?.phoneNumber;
  const ip = getIPV6Address(event.ipAddress);
  if (!phone || phone.length !== 13 || !/^\+(9627[789]|9705[69])[0-9]{7}$/.test(phone)) {
    throw new HttpsError('invalid-argument', 'Only Palestine and Jordan mobile numbers are supported.');
  }
  if (!ip) throw new HttpsError('invalid-argument', 'Unable to verify SMS request.');
  const phoneRef = db.doc(`otpLimits/${hash('phone', phone)}`);
  const ipRef = db.doc(`otpLimits/${hash('ip', ip)}`);
  await db.runTransaction(async tx => {
    const [numberDoc, ipDoc] = await Promise.all([tx.get(phoneRef), tx.get(ipRef)]);
    const recent = (values: unknown, window: number): number[] => Array.isArray(values)
      ? values.filter((value): value is number => typeof value === 'number' && value > now - window) : [];
    const numberSends = recent(numberDoc.data()?.sends, day);
    const ipSends = recent(ipDoc.data()?.sends, hour);
    if (numberSends.length >= 5 || recent(numberSends, hour).length >= 3 || ipSends.length >= 10) {
      throw new HttpsError('resource-exhausted', 'حاولت كثير، جرّب بعد شوي');
    }
    tx.set(phoneRef, { sends: [...numberSends, now], expiresAt: Timestamp.fromMillis(now + day) });
    tx.set(ipRef, { sends: [...ipSends, now], expiresAt: Timestamp.fromMillis(now + hour) });
  });
}
