import { resolveMarket, currencyFor, roundingStep } from './markets.js';
import { marketPricing } from './pricing.js';
import { loadAppConfig, readAirport, airportDirection } from './lib/appConfig.js';
import * as v from './lib/validate.js';
import { getFirestore } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions';
import { HttpsError, onCall, type CallableRequest } from 'firebase-functions/v2/https';
import { routeHandler } from './getRoute.js';
import { type Fetch } from './lib/google.js';
import { authenticated, mapsKey, mapsOptions } from './lib/maps.js';
import { computeFare, type VehicleType } from './pricing.js';
export async function loadPricing(): Promise<unknown> {
    const document = await getFirestore().doc('config/pricing').get();
    return document.exists ? document.data() : undefined;
}
export async function fareEstimatesHandler(request: CallableRequest, key: string, fetchImpl?: Fetch, pricingLoader = loadPricing, appLoader = loadAppConfig) {
    authenticated(request);
    v.point(request.data?.origin); v.point(request.data?.destination);
    let app: Record<string, unknown> | undefined;
    try { app = await appLoader(); } catch { throw new HttpsError('internal', 'Fare estimates are unavailable.'); }
    const market = resolveMarket(v.point(request.data.origin), app), currency = currencyFor(market);
    const step = roundingStep(app, market);
    const route = await routeHandler(request, key, fetchImpl);
    try {
        const config = await pricingLoader();
        const pricing = marketPricing(config, market);
        const airport = market === 'JO' ? readAirport(app) : undefined;
        const direction = airportDirection(airport, v.point(request.data.origin), v.point(request.data.destination));
        return { market, currency, route, ...(direction ? { airport: { direction } } : {}), fares: (['economy', 'comfort', 'van'] as VehicleType[]).map((vehicleType) => ({
                vehicleType, amount: direction ? Math.max(pricing[vehicleType].minimum, airport!.fixedFares[vehicleType]) : computeFare(pricing[vehicleType], route.distanceMeters, route.durationSeconds, currency, step), currency,
            })) };
    }
    catch {
        logger.error('Pricing configuration could not be loaded or calculated.');
        throw new HttpsError('internal', 'Fare estimates are unavailable.');
    }
}
export const getFareEstimates = onCall(mapsOptions, (request) => fareEstimatesHandler(request, mapsKey.value()));
