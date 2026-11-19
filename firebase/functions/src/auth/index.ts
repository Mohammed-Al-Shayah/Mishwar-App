import { getFirestore } from 'firebase-admin/firestore';
import { beforeSmsSent } from 'firebase-functions/v2/identity';
import { limitOtpSms } from './otpLimits.js';

export const protectOtpSms = beforeSmsSent({ region: 'europe-west1' }, event => limitOtpSms(event, getFirestore()));
