import { getFirestore } from 'firebase-admin/firestore';
import { beforeSmsSent } from 'firebase-functions/v2/identity';
import { isSmsSendEvent, limitOtpSms } from './otpLimits.js';

// Only SMS-send events are limited. The Auth emulator also invokes registered blocking
// functions at sign-in (without additionalUserInfo.phoneNumber); those must pass through,
// otherwise every phone sign-in would be rejected.
export const protectOtpSms = beforeSmsSent({ region: 'europe-west1' },
  event => isSmsSendEvent(event) ? limitOtpSms(event, getFirestore()) : undefined);
