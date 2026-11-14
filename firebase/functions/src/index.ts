import { initializeApp } from 'firebase-admin/app';
import { onCall } from 'firebase-functions/v2/https';

initializeApp();

export const ping = onCall({ region: 'europe-west1' }, () => ({
  ok: true,
  time: new Date().toISOString(),
}));
