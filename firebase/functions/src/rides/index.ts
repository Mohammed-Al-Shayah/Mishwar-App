import { getFirestore } from 'firebase-admin/firestore';
import { onCall } from 'firebase-functions/v2/https';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { mapsKey, mapsOptions } from '../lib/maps.js';
import { requestRideHandler, cancelRideHandler, expireSearchingRidesHandler } from './handlers.js';

export const requestRide = onCall(mapsOptions, (request) => requestRideHandler(request, getFirestore(), mapsKey.value()));
export const cancelRide = onCall({ region: 'europe-west1' }, (request) => cancelRideHandler(request, getFirestore()));
export const expireSearchingRides = onSchedule({ region: 'europe-west1', schedule: 'every 1 minutes' }, async () => {
  await expireSearchingRidesHandler(getFirestore());
});
