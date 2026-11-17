import { initializeApp } from 'firebase-admin/app';
import { onCall } from 'firebase-functions/v2/https';
import { authenticated } from './lib/maps.js';

initializeApp();

export const ping = onCall({ region: 'europe-west1' }, (request) => {
  authenticated(request);
  return { ok: true, time: new Date().toISOString() };
});

export { placesAutocomplete } from './placesAutocomplete.js';
export { placeDetails } from './placeDetails.js';
export { getRoute } from './getRoute.js';
export { getFareEstimates } from './getFareEstimates.js';
export { switchRole, deleteAccount } from './account/index.js';
export { rateRide, skipRating, updateRideStatus, requestRide, cancelRide, expireSearchingRides, onRideCreated, offerTimeout, acceptRide, declineRide } from './rides/index.js';
