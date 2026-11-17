import { after, before, beforeEach, test } from 'node:test';
import { readFile, mkdir, rmdir } from 'node:fs/promises';
import { join } from 'node:path';
import { tmpdir } from 'node:os';
import { setTimeout as delay } from 'node:timers/promises';
import { initializeTestEnvironment, assertSucceeds, assertFails } from '@firebase/rules-unit-testing';
import { doc, setDoc, getDoc, updateDoc, deleteDoc, Timestamp, GeoPoint, setLogLevel } from 'firebase/firestore';

export { assertSucceeds, assertFails, test };
export const actors = ['anonymous', 'owner', 'other', 'rider', 'driver', 'offered', 'admin'];
export const now = Timestamp.fromMillis(1700000000000);
export const point = new GeoPoint(31.95, 35.91);
export const vehicle = { type: 'economy', make: 'Toyota', model: 'Corolla', color: 'White', plate: '12-34567' };
export const application = { vehicle, licensePhotoPath: 'drivers/owner/license.jpg', status: 'pending', isOnline: false };
export const profile = { name: 'Test User', phone: '+962781234567', role: 'rider' };
export const ride = { riderId: 'rider', driverId: 'driver', offeredTo: 'offered', status: 'accepted', createdAt: now };

// node --test runs files in separate processes. Serialize this shared demo project's
// destructive clears/rule uploads, without changing the requested npm command.
const lock = join(tmpdir(), 'mishwar-demo-rules-tests.lock');
export function suite({ storage = false } = {}) {
  let env, locked = false;
  const contexts = new Map();
  before(async () => {
    const deadline = Date.now() + 240000;
    while (!locked) {
      try { await mkdir(lock); locked = true; }
      catch (error) {
        if (error.code !== 'EEXIST') throw error;
        if (Date.now() > deadline) throw Error(`Rules suite lock timed out: ${lock}. Check for another running suite.`);
        await delay(100);
      }
    }
    setLogLevel('silent'); // Expected permission denials otherwise flood test output.
    env = await initializeTestEnvironment({
      projectId: 'demo-mishwar',
      firestore: { rules: await readFile(new URL('../../firestore.rules', import.meta.url), 'utf8'), host: '127.0.0.1', port: 8080 },
      storage: { rules: await readFile(new URL('../../storage.rules', import.meta.url), 'utf8'), host: '127.0.0.1', port: 9199 },
    });
    for (const actor of actors) contexts.set(actor, actor === 'anonymous' ? env.unauthenticatedContext()
      : env.authenticatedContext(actor, actor === 'admin' ? { admin: true } : {}));
  });
  beforeEach(async () => {
    await env.clearFirestore();
    if (storage) await env.clearStorage();
  });
  after(async () => {
    try {
      if (env) {
        await env.clearFirestore();
        if (storage) await env.clearStorage();
        await env.cleanup();
      }
    } finally { if (locked) await rmdir(lock); }
  });
  return {
    db: (actor = 'owner') => contexts.get(actor).firestore(),
    storage: (actor = 'owner') => contexts.get(actor).storage('gs://demo-mishwar.appspot.com'),
    seed: (entries) => env.withSecurityRulesDisabled(async (ctx) => {
      for (const [path, data] of Object.entries(entries)) await setDoc(doc(ctx.firestore(), path), data);
    }),
    seedStorage: (fn) => env.withSecurityRulesDisabled((ctx) => fn(ctx.storage('gs://demo-mishwar.appspot.com'))),
    context: (uid, claims) => env.authenticatedContext(uid, claims),
  };
}

// Every operation is a separate test; no successful denial can hide a later failure.
export function matrix(s, path, data, permissions, fixtures = {}) {
  for (const actor of actors) for (const operation of ['read', 'create', 'update', 'delete']) {
    test(`${path}: ${actor} ${operation}`, async () => {
      await s.seed({ ...fixtures, ...(operation === 'create' ? {} : { [path]: data }) });
      const ref = doc(s.db(actor), path);
      const action = { read: () => getDoc(ref), create: () => setDoc(ref, data),
        update: () => updateDoc(ref, { ...data, ...(path.startsWith('rides/') ? { status: 'completed' } : { forged: true }) }),
        delete: () => deleteDoc(ref) }[operation];
      await (permissions[operation]?.includes(actor) ? assertSucceeds : assertFails)(action());
    });
  }
}
