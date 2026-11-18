import { Timestamp, type Firestore } from 'firebase-admin/firestore';
import { HttpsError, type CallableRequest } from 'firebase-functions/v2/https';
import * as v from '../lib/validate.js';

function admin(request: CallableRequest): string {
  if (request.auth?.token.admin !== true) throw new HttpsError('permission-denied', 'Admin claim required.');
  return request.auth.uid;
}
function id(value: unknown): string {
  const result = v.string(value, 1, 128);
  if (!/^[a-zA-Z0-9_-]+$/.test(result)) v.invalid();
  return result;
}
function order(value: unknown): number {
  if (typeof value !== 'number' || !Number.isSafeInteger(value)) return v.invalid();
  return value;
}
function boolean(value: unknown): boolean {
  if (typeof value !== 'boolean') return v.invalid();
  return value;
}
function https(value: unknown): string {
  const result = v.string(value, 1, 2048);
  try {
    const url = new URL(result);
    if (url.protocol !== 'https:' || !url.hostname || url.username || url.password) v.invalid();
  } catch { return v.invalid(); }
  return result;
}
export async function upsertBannerHandler(request: CallableRequest, db: Firestore) {
  const by = admin(request), data = v.object(request.data);
  const ref = data.id === undefined ? db.collection('banners').doc() : db.doc(`banners/${id(data.id)}`);
  const action = v.string(data.action, 1, 20);
  if (!['open_search', 'open_promo', 'url'].includes(action)) v.invalid();
  const date = typeof data.validUntil === 'string' ? Date.parse(data.validUntil) : NaN;
  if (!Number.isFinite(date)) v.invalid();
  if (typeof data.validUntil !== 'string'
    || !/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?Z$/.test(data.validUntil)
    || new Date(date).toISOString().slice(0, 19) !== data.validUntil.slice(0, 19)) v.invalid();
  const clean = { title: v.string(data.title, 1, 60), subtitle: v.string(data.subtitle, 0, 120),
    imageUrl: https(data.imageUrl), action, order: order(data.order), active: boolean(data.active),
    validUntil: Timestamp.fromMillis(date),
    ...(action === 'open_promo' ? { promoCode: v.string(data.promoCode, 1, 40).toUpperCase() } : {}),
    ...(action === 'url' ? { url: https(data.url) } : {}) };
  const at = Timestamp.now(), log = db.collection('adminLog').doc();
  await db.runTransaction(async tx => {
    tx.set(ref, clean);
    tx.create(log, { action: 'upsertBanner', target: ref.path, by, at, details: clean });
  });
  return { id: ref.id };
}
export async function deleteBannerHandler(request: CallableRequest, db: Firestore) {
  const by = admin(request), data = v.object(request.data), target = `banners/${id(data.id)}`;
  const ref = db.doc(target), log = db.collection('adminLog').doc(), at = Timestamp.now();
  await db.runTransaction(async tx => {
    if (!(await tx.get(ref)).exists) throw new HttpsError('not-found', 'Banner not found.');
    tx.delete(ref);
    tx.create(log, { action: 'deleteBanner', target, by, at, details: {} });
  });
  return { ok: true };
}

export async function updateServicesHandler(request: CallableRequest, db: Firestore) {
  const by = admin(request), data = v.object(request.data);
  const ids = ['ride', 'schedule', 'parcel', 'airport'];
  if (!Array.isArray(data.services) || data.services.length !== ids.length) return v.invalid();
  const services = data.services.map(value => {
    const service = v.object(value), serviceId = v.string(service.id, 1, 20);
    if (!ids.includes(serviceId)) v.invalid();
    return { id: serviceId, enabled: boolean(service.enabled), order: order(service.order) };
  });
  if (new Set(services.map(service => service.id)).size !== ids.length) v.invalid();
  const at = Timestamp.now(), log = db.collection('adminLog').doc();
  await db.runTransaction(async tx => {
    tx.set(db.doc('config/app'), { services, updatedAt: at, updatedBy: by }, { merge: true });
    tx.create(log, { action: 'updateServices', target: 'config/app', by, at, details: { services } });
  });
  return { ok: true };
}
