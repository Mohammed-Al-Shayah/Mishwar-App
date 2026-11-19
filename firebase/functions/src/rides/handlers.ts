import { currencyFor, resolveMarket, roundingStep, type Market } from '../markets.js';
import { minorScale } from '../money.js';
import { parcelInput, deliverySecret, emulatorSmsSender, requireSmsSender, type SmsSender } from './parcel.js';
import { FieldValue, GeoPoint, Timestamp, type Firestore } from 'firebase-admin/firestore';
import { HttpsError, type CallableRequest } from 'firebase-functions/v2/https';
import { fareEstimatesHandler } from '../getFareEstimates.js';
import { authenticated } from '../lib/maps.js';
import * as v from '../lib/validate.js';
import { normalizePromo, previewPromo } from '../promos/handlers.js';
import { type VehicleType } from '../pricing.js';
import { dispatchRide, offeredDriver, offerIsLive, type MatchingDeps } from './matching.js';

import { cancellationFeeFils, defaultFees, earningsDay, parseFees, type FeeConfig } from './fees.js';

export const activeStatuses = ['searching', 'accepted', 'arriving', 'arrived', 'in_progress'];
const cancellable = ['searching', 'accepted', 'arriving', 'arrived'];
function place(value: unknown) {
  const data = v.object(value);
  return { ...v.point(data), name: v.string(data.name, 1, 120), address: v.string(data.address, 1, 200) };
}
export async function buildRide(request: CallableRequest, db: Firestore, key: string,
  estimate = fareEstimatesHandler) {
  authenticated(request);
  const uid = request.auth!.uid;
  const data = v.object(request.data);
  const service = parcelInput(data, uid);
  if (service.serviceType === 'parcel') {
    const services = (await db.doc('config/app').get()).data()?.services;
    if (!Array.isArray(services) || !services.some(s => s.id === 'parcel' && s.enabled === true)) {
      throw new HttpsError('failed-precondition', 'Parcel service disabled.', { reason: 'service-disabled' });
    }
    if (data.vehicleType !== 'economy') v.invalid();
  }
  const pickup = place(data.pickup), dropoff = place(data.dropoff);
  if (!['economy', 'comfort', 'van'].includes(data.vehicleType as string) || data.paymentMethod !== 'cash') v.invalid();
  const vehicleType = data.vehicleType as VehicleType;
  const userRef = db.doc(`users/${uid}`);
  if ((await userRef.get()).data()?.role !== 'rider') throw new HttpsError('permission-denied', 'Rider role required.');
  // Only validated coordinates go to the server route/pricing implementation.
  const estimates = await estimate({ ...request, data: { origin: pickup, destination: dropoff } }, key);
  const market = estimates.market ?? resolveMarket(pickup, (await db.doc('config/app').get()).data());
  const currency = currencyFor(market);
  const direction = market === 'JO' ? estimates.airport?.direction : undefined;
  let flightNumber: string | undefined;
  if (data.flightNumber !== undefined) {
    flightNumber = v.string(data.flightNumber, 3, 8).toUpperCase();
    if (!/^[A-Z0-9]{2}\s?\d{1,4}[A-Z]?$/.test(flightNumber) || !direction || service.serviceType === 'parcel') v.invalid();
  }
  const estimated = estimates.fares.find((fare) => fare.vehicleType === vehicleType)!.amount;
  const storedPlace = (p: ReturnType<typeof place>) => ({ name: p.name, address: p.address, geopoint: new GeoPoint(p.lat, p.lng) });
  return {
    ...(data.promoCode === undefined ? {} : { promo: await previewPromo(db, normalizePromo(data.promoCode), uid, estimated, undefined, market, roundingStep((await db.doc('config/app').get()).data(), market)) }),
    ...service, serviceType: service.serviceType === 'parcel' ? 'parcel' : direction ? 'airport' : 'ride', ...(direction ? { airport: { direction, ...(flightNumber ? { flightNumber } : {}), fixedFare: true } } : {}), riderId: uid, driverId: null, vehicleType,
    pickup: storedPlace(pickup), dropoff: storedPlace(dropoff), route: estimates.route,
    waitingPolicy: parseFees((await db.doc('config/app').get()).data(), market).waitingFee,
    market, fare: { estimated, final: null, currency }, paymentMethod: 'cash',
    offeredTo: null, offerExpiresAt: null, offerSeq: 0, offerDistanceMeters: null,
    declinedBy: [], createdAt: FieldValue.serverTimestamp(),
  };
}
export async function requestRideHandler(request: CallableRequest, db: Firestore, key: string,
  estimate = fareEstimatesHandler, now = () => Timestamp.now(), sms: SmsSender = emulatorSmsSender) {
  const ride = await buildRide(request, db, key, estimate);
  const uid = request.auth!.uid, userRef = db.doc(`users/${uid}`);
  const rideRef = db.collection('rides').doc();
  const secret = ride.parcel ? deliverySecret(rideRef.id) : undefined;
  if (secret) requireSmsSender(sms);
  await db.runTransaction(async (tx) => {
    const user = await tx.get(userRef);
    if (user.data()?.accountDeleting || user.data()?.role !== 'rider') throw new HttpsError('permission-denied', 'Rider role required.');
    const active = await tx.get(db.collection('rides').where('riderId', '==', uid).where('status', 'in', activeStatuses).limit(1));
    if (!active.empty) throw new HttpsError('failed-precondition', 'An active ride already exists.', { activeRideId: active.docs[0].id });
    tx.create(rideRef, { ...ride, ...(secret ? { parcel: { ...ride.parcel, deliveryCodeHash: secret.deliveryCodeHash, deliveryCodeSalt: secret.deliveryCodeSalt, codeAttempts: 0 } } : {}), status: 'searching',
      searchExpiresAt: Timestamp.fromMillis(now().toMillis() + 120000),
    });
    if (secret) tx.create(db.doc(`rides/${rideRef.id}/private/rider`), { deliveryCode: secret.deliveryCode });
    // This document also serializes concurrent requests from the same rider.
    tx.update(userRef, { activeRideId: rideRef.id });
  });
  if (secret) await sms.send(ride.parcel!.recipientPhone, `مشوار: رمز استلام طردك ${secret.deliveryCode}`);
  return { rideId: rideRef.id, ...(secret ? { deliveryCode: secret.deliveryCode } : {}) };
}
export function rideId(value: unknown) {
  const id = v.string(v.object(value).rideId, 1, 1500);
  if (id.includes('/')) v.invalid();
  return id;
}
export async function cancelRideHandler(request: CallableRequest, db: Firestore, deps?: MatchingDeps, config: (market?: Market) => Promise<FeeConfig> = async () => defaultFees) {
  authenticated(request);
  const ref = db.doc(`rides/${rideId(request.data)}`);
  const redispatched = await db.runTransaction(async (tx) => {
    const ride = await tx.get(ref);
    if (!ride.exists) throw new HttpsError('not-found', 'Ride not found.');
    const data = ride.data()!;
    const uid = request.auth!.uid;
    if (data.driverId === uid && data.riderId !== uid) {
      if (!['accepted', 'arriving', 'arrived'].includes(data.status)) {
        throw new HttpsError('failed-precondition', 'Ride cannot be cancelled.', { reason: 'invalid-transition' });
      }
      if (!deps) throw new HttpsError('internal', 'Matching dependencies required.');
      const driverRef = db.doc(`drivers/${uid}`);
      const driver = (await tx.get(driverRef)).data();
      if (driver?.currentRideId !== ref.id) throw new HttpsError('failed-precondition', 'Ride is not active.', { reason: 'invalid-transition' });
      tx.update(ref, { status: 'searching', driverCancelledAt: data.driverCancelledAt ?? deps.now(), driverId: null, driverInfo: FieldValue.delete(),
        acceptedAt: FieldValue.delete(), arrivingAt: FieldValue.delete(), arrivedAt: FieldValue.delete(),
        declinedBy: FieldValue.arrayUnion(uid), searchExpiresAt: Timestamp.fromMillis(deps.now().toMillis() + 120000),
        offeredTo: null, offerExpiresAt: null, offerDistanceMeters: null });
      tx.update(driverRef, { currentRideId: null, cancelCount: (driver.cancelCount ?? 0) + 1 });
      return true;
    }
    if (data.riderId !== uid) throw new HttpsError('permission-denied', 'Ride participant required.');
    if (data.status === 'scheduled' || (data.status === 'cancelled' && data.scheduledFor && data.cancelledBy === 'rider')) {
      if (data.status === 'scheduled') tx.update(ref, { fare: { ...data.fare, cancellationFee: 0 }, status: 'cancelled', cancelledBy: 'rider', cancelledAt: FieldValue.serverTimestamp() });
      return false;
    }
    const userRef = db.doc(`users/${data.riderId}`);
    const user = await tx.get(userRef);
    if (data.status !== 'cancelled' && !cancellable.includes(data.status)) throw new HttpsError('failed-precondition', 'Ride cannot be cancelled.');
    const offered = await offeredDriver(db, tx, data);
    const assigned = data.driverId ? await tx.get(db.doc(`drivers/${data.driverId}`)) : undefined;
    const time = deps?.now() ?? Timestamp.now();
    const market = data.market ?? 'JO', currency = currencyFor(market), scale = minorScale(currency);
    const settings = await config(market), app = (await tx.get(db.doc('config/app'))).data();
    const feeFils = cancellationFeeFils(data as Parameters<typeof cancellationFeeFils>[0], time, settings, market, roundingStep(app, market));
    const earningsRef = feeFils > 0 && data.driverId ? db.doc('drivers/' + data.driverId + '/earnings/' + earningsDay(time) + '_' + market) : undefined;
    const earnings = earningsRef ? (await tx.get(earningsRef)).data() : undefined;
    if (feeFils > 0) {
      const balance = user.data()?.balanceDue?.[currency] ?? (currency === 'JOD' ? user.data()?.balanceDueFils ?? 0 : 0);
      if (!Number.isSafeInteger(balance) || balance < 0 || !Number.isSafeInteger(balance + feeFils)) throw new HttpsError('internal', 'Invalid balance.');
      tx.update(userRef, { balanceDue: { ...user.data()?.balanceDue, [currency]: balance + feeFils } });
      if (earningsRef) tx.set(earningsRef, { ...earnings,
        total: (Math.round((earnings?.total ?? 0) * scale) + feeFils) / scale,
        cancellationFees: (Math.round((earnings?.cancellationFees ?? 0) * scale) + feeFils) / scale,
        currency, market, day: earningsDay(time), trips: earnings?.trips ?? 0, updatedAt: time });
    }
    if (data.status !== 'cancelled') tx.update(ref, { status: 'cancelled', cancelledBy: 'rider', cancelledAt: time, fare: { ...data.fare, cancellationFee: feeFils / scale },
      offeredTo: null, offerExpiresAt: null, offerDistanceMeters: null });
    if (offered?.data()?.offer?.rideId === ref.id) tx.update(offered.ref, { offer: null });
    if (assigned?.data()?.currentRideId === ref.id) tx.update(assigned.ref, { currentRideId: null });
    // A repeated cancellation must never clear a newer ride.
    if (user.data()?.activeRideId === ref.id) tx.update(userRef, { activeRideId: FieldValue.delete() });
    return false;
  });
  if (redispatched) await dispatchRide(db, ref.id, deps!);
  return { ok: true, redispatched };
}
export async function expireSearchingRidesHandler(db: Firestore, now = Timestamp.now(), deps?: MatchingDeps) {
  while (true) {
    const page = await db.collection('rides').where('status', '==', 'searching').where('searchExpiresAt', '<', now).limit(200).get();
    if (page.empty) break;
    for (const document of page.docs) {
      await db.runTransaction(async (tx) => {
        const ride = await tx.get(document.ref);
        const data = ride.data();
        if (!data || data.status !== 'searching' || data.searchExpiresAt.toMillis() >= now.toMillis()) return;
        const userRef = db.doc(`users/${data.riderId}`);
        const user = await tx.get(userRef);
        const offered = await offeredDriver(db, tx, data);
        tx.update(document.ref, { status: 'no_drivers', noDriversAt: now, offeredTo: null, offerExpiresAt: null, offerDistanceMeters: null });
        if (offered?.data()?.offer?.rideId === document.id) tx.update(offered.ref, { offer: null });
        if (user.data()?.activeRideId === document.id) tx.update(userRef, { activeRideId: FieldValue.delete() });
      });
    }
  }
  if (deps) {
    const searching = await db.collection('rides').where('status', '==', 'searching').get();
    for (const ride of searching.docs) {
      const data = ride.data();
      if (data.searchExpiresAt?.toMillis?.() > now.toMillis() &&
          data.createdAt?.toMillis() < now.toMillis() - 20000 && !offerIsLive(data, now)) {
        await dispatchRide(db, ride.id, deps);
      }
    }
  }
}

export async function cancellationQuoteHandler(request: CallableRequest, db: Firestore,
  config: (market?: Market) => Promise<FeeConfig> = async () => defaultFees, now = () => Timestamp.now()) {
  authenticated(request);
  const ride = (await db.doc('rides/' + rideId(request.data)).get()).data();
  if (!ride) throw new HttpsError('not-found', 'Ride not found.');
  if (ride.riderId !== request.auth!.uid) throw new HttpsError('permission-denied', 'Rider required.');
  const market = ride.market ?? 'JO', currency = currencyFor(market);
  const app = (await db.doc('config/app').get()).data();
  return { currency, fee: cancellationFeeFils(ride as Parameters<typeof cancellationFeeFils>[0], now(), await config(market), market, roundingStep(app, market)) / minorScale(currency) };
}
