import { getFirestore } from 'firebase-admin/firestore';
import { defineString } from 'firebase-functions/params';
import { onCall, onRequest } from 'firebase-functions/v2/https';
import { createShareLinkHandler, sharedTripHandler, ShareRateLimiter } from './handlers.js';
const base = defineString('SHARE_BASE_URL', { default: 'http://127.0.0.1:5002' });
const limiter = new ShareRateLimiter();
export const createShareLink = onCall({ region: 'europe-west1' }, request =>
  createShareLinkHandler(request, getFirestore(), base.value()));
export const sharedTrip = onRequest({ region: 'europe-west1', invoker: 'public' }, async (request, response) => {
  response.set('Cache-Control', 'no-store');
  const origin = new URL(base.value()).origin;
  if (request.headers.origin === origin) response.set('Access-Control-Allow-Origin', origin);
  response.set('Vary', 'Origin');
  if (request.method !== 'GET') { response.status(405).send({ error: 'method' }); return; }
  try {
    const result = await sharedTripHandler(request.query.t, getFirestore(), limiter);
    if (result.status === 429) response.set('Retry-After', '1');
    response.status(result.status).json(result.body);
  } catch {
    response.status(500).json({ error: 'unavailable' });
  }
});
