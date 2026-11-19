import { defineBoolean } from 'firebase-functions/params';
import type { CallableOptions } from 'firebase-functions/v2/https';

export const enforceAppCheck = defineBoolean('ENFORCE_APP_CHECK', { default: false });
export const callableOptions = (extra: CallableOptions = {}): CallableOptions => ({
  region: 'europe-west1', ...extra, enforceAppCheck,
});
