import { HttpsError, onCall, type CallableRequest } from 'firebase-functions/v2/https';
import { google, type Fetch } from './lib/google.js';
import { authenticated, mapsKey, mapsOptions } from './lib/maps.js';
import * as v from './lib/validate.js';
export async function detailsHandler(request: CallableRequest, key: string, fetchImpl?: Fetch) {
    authenticated(request);
    const data = v.object(request.data);
    const placeId = v.string(data.placeId, 1, 256);
    const query = new URLSearchParams({ sessionToken: v.sessionToken(data.sessionToken), languageCode: v.language(data.lang) });
    const result = await google<{
        id?: string;
        displayName?: {
            text?: string;
        };
        formattedAddress?: string;
        location?: {
            latitude: number;
            longitude: number;
        };
    }>('https://places.googleapis.com/v1/places/' + encodeURIComponent(placeId) + '?' + query, {
        headers: { 'X-Goog-Api-Key': key, 'X-Goog-FieldMask': 'id,displayName,formattedAddress,location' },
    }, fetchImpl);
    if (!result.location || !Number.isFinite(result.location.latitude) || !Number.isFinite(result.location.longitude) || Math.abs(result.location.latitude) > 90 || Math.abs(result.location.longitude) > 180)
        throw new HttpsError('internal', 'Invalid place response.');
    return { placeId: result.id ?? placeId, name: result.displayName?.text ?? '', address: result.formattedAddress ?? '', lat: result.location.latitude, lng: result.location.longitude };
}
export const placeDetails = onCall(mapsOptions, (request) => detailsHandler(request, mapsKey.value()));
