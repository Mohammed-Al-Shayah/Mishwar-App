import { getFirestore } from 'firebase-admin/firestore';
import { onCall } from 'firebase-functions/v2/https';
import { matchingDeps } from '../rides/index.js';
import { reviewDriverHandler, updatePricingHandler, adminCancelRideHandler } from './handlers.js';
export const reviewDriver = onCall({ region: 'europe-west1' }, request => reviewDriverHandler(request, getFirestore(), matchingDeps));
export const updatePricing = onCall({ region: 'europe-west1' }, request => updatePricingHandler(request, getFirestore()));
export const adminCancelRide = onCall({ region: 'europe-west1' }, request => adminCancelRideHandler(request, getFirestore()));
