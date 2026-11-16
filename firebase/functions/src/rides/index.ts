import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { getFunctions } from 'firebase-admin/functions';
import { onCall } from 'firebase-functions/v2/https';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { onTaskDispatched } from 'firebase-functions/v2/tasks';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { mapsKey, mapsOptions } from '../lib/maps.js';
import { requestRideHandler, cancelRideHandler, expireSearchingRidesHandler } from './handlers.js';
import { dispatchRide, offerTimeoutHandler, type MatchingDeps, type OfferTask } from './matching.js';
import { acceptRideHandler, declineRideHandler } from './offers.js';

const matchingDeps: MatchingDeps = {
  now: () => Timestamp.now(),
  enqueue: (data, scheduleDelaySeconds) => getFunctions()
    .taskQueue('locations/europe-west1/functions/offerTimeout').enqueue(data, { scheduleDelaySeconds }),
  notify: async () => {}, // T3.5 supplies FCM.
};
export const onRideCreated = onDocumentCreated({ region: 'europe-west1', document: 'rides/{rideId}' },
  (event) => dispatchRide(getFirestore(), event.params.rideId, matchingDeps));
export const offerTimeout = onTaskDispatched<OfferTask>({ region: 'europe-west1',
  retryConfig: { maxAttempts: 3, minBackoffSeconds: 5 } },
  (request) => offerTimeoutHandler(getFirestore(), request.data, matchingDeps));

export const requestRide = onCall(mapsOptions, (request) => requestRideHandler(request, getFirestore(), mapsKey.value()));
export const cancelRide = onCall({ region: 'europe-west1' }, (request) => cancelRideHandler(request, getFirestore()));
export const acceptRide = onCall({ region: 'europe-west1' }, (request) => acceptRideHandler(request, getFirestore(), matchingDeps));
export const declineRide = onCall({ region: 'europe-west1' }, (request) => declineRideHandler(request, getFirestore(), matchingDeps));
export const expireSearchingRides = onSchedule({ region: 'europe-west1', schedule: 'every 1 minutes' }, async () => {
  await expireSearchingRidesHandler(getFirestore(), Timestamp.now(), matchingDeps);
});
