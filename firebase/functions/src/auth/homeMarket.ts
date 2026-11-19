import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { homeMarket } from '../markets.js';

// Use the verified Auth phone, never the client profile field.
export const setUserHomeMarket = onDocumentCreated({ region: 'europe-west1', document: 'users/{uid}', retry: true }, async event => {
  const phone = (await getAuth().getUser(event.params.uid)).phoneNumber;
  if (!phone) return;
  const market = homeMarket(phone);
  await getFirestore().runTransaction(async tx => {
    const ref = getFirestore().doc(`users/${event.params.uid}`);
    if ((await tx.get(ref)).exists) tx.update(ref, { homeMarket: market });
  });
});
