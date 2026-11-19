import { createHash, randomBytes, randomInt, timingSafeEqual } from 'node:crypto';
import { type Firestore } from 'firebase-admin/firestore';
import { HttpsError, type CallableRequest } from 'firebase-functions/v2/https';
import { info } from 'firebase-functions/logger';
import { authenticated } from '../lib/maps.js';
import * as v from '../lib/validate.js';

export interface SmsSender { send(to: string, message: string): Promise<void> }
// TODO: Replace with a real SMS provider before enabling parcels in production.
// Never fall back to logging recipient codes in production.
export const emulatorSmsSender: SmsSender = {
  async send(to, message) {
    if (process.env.FUNCTIONS_EMULATOR !== 'true') throw new HttpsError('unavailable', 'SMS provider is not configured.');
    info(`[sms:emulator] to ${to} : ${message}`);
  },
};
export function requireSmsSender(sender: SmsSender) {
  if (sender === emulatorSmsSender && process.env.FUNCTIONS_EMULATOR !== 'true') {
    throw new HttpsError('unavailable', 'SMS provider is not configured.');
  }
}
export function parcelInput(data: Record<string, unknown>, uid: string) {
  const serviceType = data.serviceType ?? 'ride';
  if (serviceType !== 'ride' && serviceType !== 'parcel' && serviceType !== 'airport') v.invalid();
  if (serviceType !== 'parcel') {
    if (data.parcel !== undefined) v.invalid();
    return { serviceType };
  }
  const raw = v.object(data.parcel);
  const recipientPhone = v.mobilePhone(raw.recipientPhone);
  const photoPath = raw.photoPath === undefined ? undefined : v.string(raw.photoPath, 1, 1024);
  if (photoPath && (!photoPath.startsWith(`parcels/${uid}/`) ||
      !/^parcels\/[^/]+\/[^/]+$/.test(photoPath) || photoPath.split('/').some(p => p === '.' || p === '..'))) v.invalid();
  return { serviceType, parcel: {
    recipientName: v.string(raw.recipientName, 1, 40), recipientPhone,
    description: v.string(raw.description, 1, 200), ...(photoPath ? { photoPath } : {}),
  } };
}
export function hashDeliveryCode(id: string, code: string, salt: string) {
  return createHash('sha256').update(`${id}:${code}:${salt}`).digest('hex');
}
export function deliverySecret(id: string) {
  const deliveryCode = randomInt(0, 10000).toString().padStart(4, '0');
  const deliveryCodeSalt = randomBytes(32).toString('hex');
  return { deliveryCode, deliveryCodeSalt, deliveryCodeHash: hashDeliveryCode(id, deliveryCode, deliveryCodeSalt) };
}
export function validDeliveryCode(id: string, code: unknown, parcel: Record<string, unknown>) {
  if (typeof code !== 'string' || !/^\d{4}$/.test(code) || typeof parcel.deliveryCodeSalt !== 'string' ||
      typeof parcel.deliveryCodeHash !== 'string' || !/^[a-f0-9]{64}$/.test(parcel.deliveryCodeHash)) return false;
  return timingSafeEqual(Buffer.from(hashDeliveryCode(id, code, parcel.deliveryCodeSalt), 'hex'), Buffer.from(parcel.deliveryCodeHash, 'hex'));
}
export type PhotoSigner = (path: string, expires: number) => Promise<string>;
export async function parcelPhotoUrlHandler(request: CallableRequest, db: Firestore, sign: PhotoSigner, now = Date.now) {
  authenticated(request);
  const id = v.string(v.object(request.data).rideId, 1, 1500);
  if (id.includes('/')) v.invalid();
  const ride = (await db.doc(`rides/${id}`).get()).data();
  if (!ride || ride.driverId !== request.auth!.uid) throw new HttpsError('permission-denied', 'Assigned driver required.');
  const path = ride.parcel?.photoPath;
  if (ride.serviceType !== 'parcel' || typeof path !== 'string' || !path.startsWith(`parcels/${ride.riderId}/`)) {
    throw new HttpsError('not-found', 'Parcel photo not found.');
  }
  return { url: await sign(path, now() + 10 * 60000) };
}
