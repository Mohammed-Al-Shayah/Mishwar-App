import { defineSecret } from 'firebase-functions/params';
import { HttpsError, type CallableRequest } from 'firebase-functions/v2/https';
export const mapsKey = defineSecret('GOOGLE_MAPS_SERVER_KEY');
export const mapsOptions = { region: 'europe-west1', secrets: [mapsKey] };
export function authenticated(request: Pick<CallableRequest, 'auth'>): void {
    if (!request.auth)
        throw new HttpsError('unauthenticated', 'Authentication required.');
}
