import { onCall, type CallableRequest } from 'firebase-functions/v2/https';
import { google, type Fetch } from './lib/google.js';
import { authenticated, mapsKey, mapsOptions } from './lib/maps.js';
import * as v from './lib/validate.js';
type Text = {
    text?: string;
};
type Prediction = {
    placeId?: string;
    text?: Text;
    structuredFormat?: {
        mainText?: Text;
        secondaryText?: Text;
    };
};
export async function autocompleteHandler(request: CallableRequest, key: string, fetchImpl?: Fetch) {
    authenticated(request);
    const data = v.object(request.data);
    const input = v.string(data.input, 1, 100);
    const sessionToken = v.sessionToken(data.sessionToken);
    const languageCode = v.language(data.lang);
    const bias = data.lat !== undefined || data.lng !== undefined ? v.point(data) : undefined;
    const response = await google<{
        suggestions?: {
            placePrediction?: Prediction;
        }[];
    }>('https://places.googleapis.com/v1/places:autocomplete', {
        method: 'POST', headers: { 'Content-Type': 'application/json', 'X-Goog-Api-Key': key },
        body: JSON.stringify({ input, sessionToken, languageCode, includedRegionCodes: ['jo'],
            ...(bias ? { locationBias: { circle: { center: { latitude: bias.lat, longitude: bias.lng }, radius: 30000 } } } : {}) }),
    }, fetchImpl);
    return { suggestions: (response.suggestions ?? []).flatMap(({ placePrediction: p }) => p?.placeId ? [{
                placeId: p.placeId, primaryText: p.structuredFormat?.mainText?.text ?? p.text?.text ?? '',
                secondaryText: p.structuredFormat?.secondaryText?.text ?? '',
            }] : []).slice(0, 5) };
}
export const placesAutocomplete = onCall(mapsOptions, (request) => autocompleteHandler(request, mapsKey.value()));
