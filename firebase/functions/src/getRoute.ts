import { HttpsError, onCall, type CallableRequest } from 'firebase-functions/v2/https';
import { google, type Fetch } from './lib/google.js';
import { authenticated, mapsKey, mapsOptions } from './lib/maps.js';
import * as v from './lib/validate.js';
export async function routeHandler(request: CallableRequest, key: string, fetchImpl?: Fetch) {
    authenticated(request);
    const data = v.object(request.data);
    const origin = v.point(data.origin);
    const destination = v.point(data.destination);
    const waypoint = (p: {
        lat: number;
        lng: number;
    }) => ({ location: { latLng: { latitude: p.lat, longitude: p.lng } } });
    const result = await google<{
        routes?: {
            distanceMeters?: number;
            duration?: string;
            polyline?: {
                encodedPolyline?: string;
            };
        }[];
    }>('https://routes.googleapis.com/directions/v2:computeRoutes', {
        method: 'POST', headers: { 'Content-Type': 'application/json', 'X-Goog-Api-Key': key,
            'X-Goog-FieldMask': 'routes.distanceMeters,routes.duration,routes.polyline.encodedPolyline' },
        body: JSON.stringify({ origin: waypoint(origin), destination: waypoint(destination), travelMode: 'DRIVE', routingPreference: 'TRAFFIC_AWARE' }),
    }, fetchImpl);
    const route = result.routes?.[0];
    if (!route)
        throw new HttpsError('not-found', 'No route found.');
    const duration = route.duration?.match(/^(\d+(?:\.\d+)?)s$/);
    if (!duration || !Number.isFinite(Number(duration[1])) || !Number.isFinite(route.distanceMeters) || route.distanceMeters! < 0 || typeof route.polyline?.encodedPolyline !== 'string')
        throw new HttpsError('internal', 'Invalid route response.');
    return { polyline: route.polyline.encodedPolyline, distanceMeters: route.distanceMeters!, durationSeconds: Number(duration[1]) };
}
export const getRoute = onCall(mapsOptions, (request) => routeHandler(request, mapsKey.value()));
