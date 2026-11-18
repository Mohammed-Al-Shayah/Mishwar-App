import { Timestamp, type Firestore } from 'firebase-admin/firestore';
import { HttpsError, type CallableRequest } from 'firebase-functions/v2/https';
import * as v from '../lib/validate.js';
import { pointInPolygon, readAirport } from '../lib/appConfig.js';

function admin(request: CallableRequest): string {
  if (request.auth?.token.admin !== true) throw new HttpsError('permission-denied', 'Admin claim required.');
  return request.auth.uid;
}
function number(value: unknown, min: number, max: number, integer = false): number {
  if (typeof value !== 'number' || !Number.isFinite(value) || value < min || value > max || (integer && !Number.isSafeInteger(value))) return v.invalid();
  return value;
}
function boolean(value: unknown): boolean {
  if (typeof value !== 'boolean') return v.invalid();
  return value;
}
function code(value: unknown): string {
  if (typeof value !== 'string' || !/^[A-Z0-9]{3,20}$/.test(value)) return v.invalid();
  return value;
}
function date(value: unknown): Timestamp {
  if (typeof value !== 'string' || !/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?Z$/.test(value)) return v.invalid();
  const millis = Date.parse(value);
  if (!Number.isFinite(millis) || new Date(millis).toISOString().slice(0, 19) !== value.slice(0, 19)) return v.invalid();
  return Timestamp.fromMillis(millis);
}
export async function updateAppSettingsHandler(request: CallableRequest, db: Firestore) {
  const by = admin(request), data = v.object(request.data);
  const sections = ['cancellationFee', 'waitingFee', 'scheduling', 'airport'];
  if (!Object.keys(data).length || Object.keys(data).some(key => !sections.includes(key))) return v.invalid();
  const at = Timestamp.now(), log = db.collection('adminLog').doc();
  await db.runTransaction(async tx => {
    const ref = db.doc('config/app'), current = (await tx.get(ref)).data() ?? {};
    const clean: Record<string, unknown> = {};
    for (const section of Object.keys(data)) {
      const input = v.object(data[section]);
      const bounds: Record<string, [number, number, boolean?]> = section === 'cancellationFee'
        ? { amount: [0, 20], afterSeconds: [0, 1800, true] }
        : section === 'waitingFee' ? { freeMinutes: [0, 30, true], perMinute: [0, 2] }
          : section === 'scheduling' ? { minLeadMinutes: [15, 720, true], maxDaysAhead: [1, 60, true], dispatchBeforeMinutes: [5, 60, true] } : {};
      if (section !== 'airport') {
        if (!Object.keys(input).length || Object.keys(input).some(key => !(key in bounds))) return v.invalid();
        const defaults: Record<string, Record<string, number>> = { cancellationFee: { amount: 0.5, afterSeconds: 120 }, waitingFee: { freeMinutes: 3, perMinute: 0.05 }, scheduling: { minLeadMinutes: 30, maxDaysAhead: 30, dispatchBeforeMinutes: 15 } };
        const merged = { ...defaults[section], ...v.object(current[section] ?? {}), ...input };
        clean[section] = Object.fromEntries(Object.entries(bounds).map(([key, [min, max, integer]]) => [key, number(merged[key], min, max, integer)]));
      } else {
        if (!Object.keys(input).length || Object.keys(input).some(key => !['fixedFares', 'pickupPoints'].includes(key))) return v.invalid();
        const airport = readAirport(current);
        if (!airport) throw new HttpsError('failed-precondition', 'Configure an airport zone first.');
        const fares = { ...airport.fixedFares, ...(input.fixedFares === undefined ? {} : v.object(input.fixedFares)) };
        if (Object.keys(fares).some(key => !['economy', 'comfort', 'van'].includes(key))) return v.invalid();
        for (const type of ['economy', 'comfort', 'van'] as const) number(fares[type], 1, 100);
        const rawPoints = input.pickupPoints ?? airport.pickupPoints;
        if (!Array.isArray(rawPoints) || rawPoints.length > 10) return v.invalid();
        const points = rawPoints.map(raw => {
          const p = v.object(raw), lat = number(p.lat, -90, 90), lng = number(p.lng, -180, 180);
          const id = v.string(p.id, 1, 60);
          if (!/^[A-Za-z0-9_-]+$/.test(id) || !pointInPolygon(lat, lng, airport.zone)) return v.invalid();
          return { id, name: v.string(p.name, 1, 60), lat, lng };
        });
        if (new Set(points.map(p => p.id)).size !== points.length) return v.invalid();
        clean.airport = { ...v.object(current.airport), fixedFares: fares, pickupPoints: points };
      }
    }
    tx.set(ref, { ...clean, updatedAt: at, updatedBy: by }, { merge: true });
    tx.create(log, { action: 'updateAppSettings', target: ref.path, by, at, details: clean });
  });
  return { ok: true };
}
export async function upsertPromoHandler(request: CallableRequest, db: Firestore) {
  const by = admin(request), data = v.object(request.data), promoCode = code(data.code);
  const type = data.type;
  if (type !== 'fixed' && type !== 'percent') return v.invalid();
  const clean = { type, value: number(data.value, 0.001, type === 'percent' ? 100 : 100),
    ...(data.maxDiscount === undefined ? {} : { maxDiscount: number(data.maxDiscount, 0, 100) }),
    ...(data.minFare === undefined ? {} : { minFare: number(data.minFare, 0, 100) }),
    ...(data.usageLimit === undefined ? {} : { usageLimit: number(data.usageLimit, 1, Number.MAX_SAFE_INTEGER, true) }),
    perUserLimit: number(data.perUserLimit, 1, Number.MAX_SAFE_INTEGER, true), firstRideOnly: boolean(data.firstRideOnly),
    validFrom: date(data.validFrom), validUntil: date(data.validUntil), active: boolean(data.active) };
  if (clean.validFrom.toMillis() >= clean.validUntil.toMillis()) return v.invalid();
  const ref = db.doc(`promos/${promoCode}`), log = db.collection('adminLog').doc(), at = Timestamp.now();
  await db.runTransaction(async tx => {
    const previous = (await tx.get(ref)).data(), usedCount = previous?.usedCount ?? 0;
    if ((usedCount > 0 && previous?.type !== type) || (clean.usageLimit !== undefined && clean.usageLimit < usedCount)) {
      throw new HttpsError('failed-precondition', 'Promo history must be preserved.');
    }
    tx.set(ref, { ...clean, usedCount });
    tx.create(log, { action: 'upsertPromo', target: ref.path, by, at, details: clean });
  });
  return { ok: true };
}
export async function setPromoActiveHandler(request: CallableRequest, db: Firestore) {
  const by = admin(request), data = v.object(request.data), ref = db.doc(`promos/${code(data.code)}`), active = boolean(data.active);
  const log = db.collection('adminLog').doc(), at = Timestamp.now();
  await db.runTransaction(async tx => {
    if (!(await tx.get(ref)).exists) throw new HttpsError('not-found', 'Promo not found.');
    tx.update(ref, { active });
    tx.create(log, { action: 'setPromoActive', target: ref.path, by, at, details: { active } });
  });
  return { ok: true };
}
