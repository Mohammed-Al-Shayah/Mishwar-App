import { callableOptions } from './lib/callable.js';
import { initializeApp } from 'firebase-admin/app';
import { onCall } from 'firebase-functions/v2/https';
import { authenticated } from './lib/maps.js';

initializeApp();

export { updateAppSettings, upsertPromo, setPromoActive, reviewDriver, updatePricing, adminCancelRide, upsertBanner, deleteBanner, updateServices } from './admin/index.js';

export const ping = onCall(callableOptions(), (request) => {
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

export { onRideStatsWritten } from './admin/stats.js';

export { protectOtpSms } from './auth/index.js';

export { setUserHomeMarket } from './auth/homeMarket.js';
