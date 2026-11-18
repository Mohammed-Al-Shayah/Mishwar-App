// Usage: FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 node firebase/scripts/backfill-stats.mjs
import { createRequire } from 'node:module';
const require = createRequire(new URL('../functions/package.json', import.meta.url));
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, Timestamp } = require('firebase-admin/firestore');
const host = process.env.FIRESTORE_EMULATOR_HOST;
if (!host || !/^(127\.0\.0\.1|localhost|\[::1\]):\d+$/.test(host)) throw Error('A loopback Firestore emulator host is required.');
const projectId = process.env.GCLOUD_PROJECT ?? 'demo-mishwar';
if (!/^demo-mishwar(?:-[a-z0-9-]+)?$/.test(projectId)) throw Error('Only demo-mishwar demo projects are allowed.');
initializeApp({ projectId });
const { rideContributions, emptyDailyStats } = await import('../functions/lib/admin/stats.js');
const db = getFirestore();
const rides = await db.collection('rides').get();
const aggregates = new Map();
const markers = new Map();
for (const doc of rides.docs) {
  const ride = doc.data();
  if (!ride.createdAt?.toMillis) throw Error(`Missing createdAt: ${doc.id}. No stats were changed.`);
  const contributions = rideContributions(ride, ride.createdAt ?? Timestamp.now());
  markers.set(doc.ref.path, contributions.map(c => c.marker));
  for (const c of contributions) {
    const path = `stats/${c.day}`, row = aggregates.get(path) ?? { ...emptyDailyStats };
    for (const [key, value] of Object.entries(c.counters)) row[key] = (row[key] ?? 0) + value;
    if (c.promoCode) {
      row.promoUsesByCode ??= {};
      row.promoUsesByCode[c.promoCode] = (row.promoUsesByCode[c.promoCode] ?? 0) + 1;
      const promoPath = `stats/promos/${c.promoCode}/${c.day}`;
      aggregates.set(promoPath, { uses: (aggregates.get(promoPath)?.uses ?? 0) + 1 });
    }
    aggregates.set(path, row);
  }
}
// Run with ride traffic paused. This replaces aggregates and resets idempotency markers.
await db.recursiveDelete(db.collection('stats'));
let batch = db.batch(), count = 0;
async function flush() { if (count) await batch.commit(); batch = db.batch(); count = 0; }
for (const [path, row] of aggregates) { batch.set(db.doc(path), row); if (++count === 400) await flush(); }
for (const [path, statsCountedFor] of markers) { batch.update(db.doc(path), { statsCountedFor }); if (++count === 400) await flush(); }
await flush();
console.log(`Recomputed ${aggregates.size} aggregate documents from ${rides.size} rides in ${projectId} emulator.`);
