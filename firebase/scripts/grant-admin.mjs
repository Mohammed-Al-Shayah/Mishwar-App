// Uses ADC outside the emulator; never loads repository credential files.
import { createRequire } from 'node:module';
const require = createRequire(new URL('../functions/package.json', import.meta.url));
const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const email = process.argv[2];
if (!email || !email.includes('@')) throw new Error('Usage: grant-admin.mjs <email>');
initializeApp(process.env.FIREBASE_AUTH_EMULATOR_HOST
  ? { projectId: process.env.GCLOUD_PROJECT ?? 'demo-mishwar' }
  : { credential: applicationDefault() });
const auth = getAuth(), user = await auth.getUserByEmail(email);
await auth.setCustomUserClaims(user.uid, { ...user.customClaims, admin: true });
console.log('Admin claim granted. Sign out and sign in again to refresh the token.');
