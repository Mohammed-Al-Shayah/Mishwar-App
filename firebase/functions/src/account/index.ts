import { callableOptions } from '../lib/callable.js';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';
import { onCall } from 'firebase-functions/v2/https';
import { matchingDeps } from '../rides/index.js';
import { deleteAccountHandler, switchRoleHandler } from './handlers.js';

export const switchRole = onCall(callableOptions(), request =>
  switchRoleHandler(request, getFirestore(), matchingDeps));
export const deleteAccount = onCall(callableOptions(), request =>
  deleteAccountHandler(request, getFirestore(), {
    matching: matchingDeps,
    deleteFiles: prefix => getStorage().bucket().deleteFiles({ prefix }),
    deleteUser: uid => getAuth().deleteUser(uid),
  }));
