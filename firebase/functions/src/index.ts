import { initializeApp } from 'firebase-admin/app';
import { onCall } from 'firebase-functions/v2/https';
import { authenticated } from './lib/maps.js';

initializeApp();

export { reviewDriver, updatePricing, adminCancelRide, upsertBanner, deleteBanner, updateServices } from './admin/index.js';

export const ping = onCall({ region: 'europe-west1' }, (request) => {
  authenticated(request);
  return { ok: true, time: new Date().toISOString() };
});

export { placesAutocomplete } from './placesAutocomplete.js';
export { placeDetails } from './placeDetails.js';
export { getRoute } from './getRoute.js';
export { reverseGeocode, pickupSuggestions } from './pickup.js';
export { getFareEstimates } from './getFareEstimates.js';
export { switchRole, deleteAccount } from './account/index.js';
export { parcelPhotoUrl, adminCompleteParcel, cancellationQuote, scheduleRide, dispatchScheduledRides, rateRide, skipRating, updateRideStatus, requestRide, cancelRide, expireSearchingRides, onRideCreated, offerTimeout, acceptRide, declineRide } from './rides/index.js';

export { validatePromo } from './promos/index.js';
export { createShareLink, sharedTrip } from './safety/index.js';
export { createSupportTicket, replySupportTicket, setSupportTicketStatus, onSupportMessageCreated } from './support/index.js';
