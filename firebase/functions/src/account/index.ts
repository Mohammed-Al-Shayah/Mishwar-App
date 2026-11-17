import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';
import { onCall } from 'firebase-functions/v2/https';
import { matchingDeps } from '../rides/index.js';
import { deleteAccountHandler, switchRoleHandler } from './handlers.js';

export const switchRole = onCall({ region: 'europe-west1' }, request =>
  switchRoleHandler(request, getFirestore(), matchingDeps));
export const deleteAccount = onCall({ region: 'europe-west1' }, request =>
  deleteAccountHandler(request, getFirestore(), {
    matching: matchingDeps,
    deleteFiles: prefix => getStorage().bucket().deleteFiles({ prefix }),
    deleteUser: uid => getAuth().deleteUser(uid),
  }));
