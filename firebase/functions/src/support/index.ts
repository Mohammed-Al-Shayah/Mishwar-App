import { getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import { onCall } from 'firebase-functions/v2/https';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { createSupportTicketHandler, replySupportTicketHandler, setSupportTicketStatusHandler, supportMessageCreatedHandler } from './handlers.js';

export const createSupportTicket = onCall({ region: 'europe-west1' }, request => createSupportTicketHandler(request, getFirestore()));
export const replySupportTicket = onCall({ region: 'europe-west1' }, request =>
  replySupportTicketHandler(request, getFirestore(), async (uid, role, ticketId) => {
    if (process.env.FUNCTIONS_EMULATOR === 'true') return;
    const token = (await getFirestore().doc(`users/${uid}`).get()).data()?.fcmToken;
    if (typeof token !== 'string' || !token) return;
    await getMessaging().send({ token, notification: { title: 'الدعم', body: 'رد فريق الدعم على طلبك' },
      data: { type: 'support_reply', role, ticketId } });
  }));
export const setSupportTicketStatus = onCall({ region: 'europe-west1' }, request => setSupportTicketStatusHandler(request, getFirestore()));
export const onSupportMessageCreated = onDocumentCreated({ region: 'europe-west1', document: 'supportTickets/{ticketId}/messages/{messageId}' }, async event => {
  const message = event.data?.data();
  if (message) await supportMessageCreatedHandler(getFirestore(), event.params.ticketId, message);
});
