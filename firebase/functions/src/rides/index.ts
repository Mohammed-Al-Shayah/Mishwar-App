import { type Market } from '../markets.js';
import { callableOptions } from '../lib/callable.js';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { getFunctions } from 'firebase-admin/functions';
import { getMessaging } from 'firebase-admin/messaging';
import { info } from 'firebase-functions/logger';
import { sendOfferNotification } from '../notifications/send_offer_notification.js';
import { onCall } from 'firebase-functions/v2/https';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { onTaskDispatched } from 'firebase-functions/v2/tasks';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { mapsKey, mapsOptions } from '../lib/maps.js';
import { requestRideHandler, cancelRideHandler, cancellationQuoteHandler, expireSearchingRidesHandler } from './handlers.js';
import { dispatchRide, offerTimeoutHandler, type MatchingDeps, type OfferTask } from './matching.js';
import { updateRideStatusHandler } from './lifecycle.js';
import { acceptRideHandler, declineRideHandler } from './offers.js';

import { feeConfigReader } from './fees.js';
const fees = (market: Market = 'JO') => feeConfigReader(getFirestore())(market);
export const cancellationQuote = onCall(callableOptions(), request => cancellationQuoteHandler(request, getFirestore(), fees));
export const matchingDeps: MatchingDeps = {
  now: () => Timestamp.now(),
  enqueue: (data, scheduleDelaySeconds) => getFunctions()
    .taskQueue('locations/europe-west1/functions/offerTimeout').enqueue(data, { scheduleDelaySeconds }),
  notify: (uid, rideId) => sendOfferNotification(getFirestore(), {
    send: (message) => getMessaging().send(message),
  }, uid, rideId, info),
};
export const onRideCreated = onDocumentCreated({ region: 'europe-west1', document: 'rides/{rideId}' },
  (event) => dispatchRide(getFirestore(), event.params.rideId, matchingDeps));
export const offerTimeout = onTaskDispatched<OfferTask>({ region: 'europe-west1',
  retryConfig: { maxAttempts: 3, minBackoffSeconds: 5 } },
  (request) => offerTimeoutHandler(getFirestore(), request.data, matchingDeps));

export const requestRide = onCall(mapsOptions, (request) => requestRideHandler(request, getFirestore(), mapsKey.value()));
export const cancelRide = onCall(callableOptions(), (request) => cancelRideHandler(request, getFirestore(), matchingDeps, fees));
export const acceptRide = onCall(callableOptions(), (request) => acceptRideHandler(request, getFirestore(), matchingDeps));
export const declineRide = onCall(callableOptions(), (request) => declineRideHandler(request, getFirestore(), matchingDeps));
export const expireSearchingRides = onSchedule({ region: 'europe-west1', schedule: 'every 1 minutes' }, async () => {
  await expireSearchingRidesHandler(getFirestore(), Timestamp.now(), matchingDeps);
});

export const updateRideStatus = onCall(callableOptions(), (request) => updateRideStatusHandler(request, getFirestore()));

import { rateRideHandler, skipRatingHandler } from './ratings.js';
export const rateRide = onCall(callableOptions(), request => rateRideHandler(request, getFirestore()));
export const skipRating = onCall(callableOptions(), request => skipRatingHandler(request, getFirestore()));

import { scheduleRideHandler, schedulingReader, dispatchScheduledRidesHandler, scheduledMatching } from './scheduled.js';
let readScheduling: ReturnType<typeof schedulingReader> | undefined;
const scheduling = () => (readScheduling ??= schedulingReader(getFirestore()))();
export const scheduleRide = onCall(mapsOptions, request => scheduleRideHandler(request, getFirestore(), mapsKey.value(), scheduling));
export const dispatchScheduledRides = onSchedule({ region: 'europe-west1', schedule: 'every 1 minutes' }, async () => {
  const db = getFirestore();
  await dispatchScheduledRidesHandler(db, {
    now: () => Timestamp.now(), config: scheduling,
    notify: (uid, rideId, body) => sendOfferNotification(db, { send: message => getMessaging().send(message) }, uid, rideId, info, body),
    dispatch: scheduledMatching(db, matchingDeps),
  });
});

import { getStorage } from 'firebase-admin/storage';
import { parcelPhotoUrlHandler } from './parcel.js';
import { adminCompleteParcelHandler } from './lifecycle.js';
export const adminCompleteParcel = onCall(callableOptions(), request => adminCompleteParcelHandler(request, getFirestore()));
export const parcelPhotoUrl = onCall(callableOptions(), request => parcelPhotoUrlHandler(request, getFirestore(), async (path, expires) => {
  const [url] = await getStorage().bucket().file(path).getSignedUrl({ action: 'read', expires });
  return url;
}));
