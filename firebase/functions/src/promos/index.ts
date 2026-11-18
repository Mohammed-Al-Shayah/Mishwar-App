import { getFirestore } from 'firebase-admin/firestore';
import { onCall } from 'firebase-functions/v2/https';
import { mapsKey, mapsOptions } from '../lib/maps.js';
import { validatePromoHandler } from './handlers.js';
export const validatePromo = onCall(mapsOptions, request => validatePromoHandler(request, getFirestore(), mapsKey.value()));
