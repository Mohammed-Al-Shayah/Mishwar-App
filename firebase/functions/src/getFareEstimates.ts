import { getFirestore } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions';
import { HttpsError, onCall, type CallableRequest } from 'firebase-functions/v2/https';
import { routeHandler } from './getRoute.js';
import { type Fetch } from './lib/google.js';
import { authenticated, mapsKey, mapsOptions } from './lib/maps.js';
import { computeFare, DEFAULT_PRICING, parsePricing, type VehicleType } from './pricing.js';
export async function loadPricing(): Promise<unknown> {
    const document = await getFirestore().doc('config/pricing').get();
    return document.exists ? document.data() : undefined;
}
export async function fareEstimatesHandler(request: CallableRequest, key: string, fetchImpl?: Fetch, pricingLoader = loadPricing) {
    authenticated(request);
    const route = await routeHandler(request, key, fetchImpl);
    try {
        const config = await pricingLoader();
        const pricing = config === undefined ? DEFAULT_PRICING : parsePricing(config);
        return { route, fares: (['economy', 'comfort', 'van'] as VehicleType[]).map((vehicleType) => ({
                vehicleType, amount: computeFare(pricing[vehicleType], route.distanceMeters, route.durationSeconds), currency: 'JOD' as const,
            })) };
    }
    catch {
        logger.error('Pricing configuration could not be loaded or calculated.');
        throw new HttpsError('internal', 'Fare estimates are unavailable.');
    }
}
export const getFareEstimates = onCall(mapsOptions, (request) => fareEstimatesHandler(request, mapsKey.value()));
