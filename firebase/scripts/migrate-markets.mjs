// Emulator only. Pause local ride traffic while migrating. Safe to re-run.
import { createRequire } from 'node:module';
import { pathToFileURL } from 'node:url';
const require = createRequire(new URL('../functions/package.json', import.meta.url));
export function checkTarget(host, projectId) {
  if (!host || !/^(127\.0\.0\.1|localhost|\[::1\]):\d+$/.test(host)) throw Error('A loopback FIRESTORE_EMULATOR_HOST is required.');
  if (!/^demo-mishwar(?:-[a-z0-9-]+)?$/.test(projectId)) throw Error('A demo-mishwar project is required.');
}
export async function migrateMarkets(db) {
  const { FieldValue } = require('firebase-admin/firestore');
  const { DEFAULT_MARKETS, homeMarket } = await import('../functions/lib/markets.js');
  const { DEFAULT_PRICING, PS_PRICING } = await import('../functions/lib/pricing.js');
  await db.runTransaction(async tx => {
    const appRef = db.doc('config/app'), pricingRef = db.doc('config/pricing');
    const app = (await tx.get(appRef)).data() ?? {}, pricing = (await tx.get(pricingRef)).data();
    const { economy, comfort, van, ...rest } = pricing ?? {};
    tx.set(pricingRef, { ...rest, JO: pricing?.JO ?? (economy ? { economy, comfort, van } : DEFAULT_PRICING), PS: pricing?.PS ?? PS_PRICING });
    tx.set(appRef, { ...app, markets: app.markets ?? DEFAULT_MARKETS,
      cancellationFee: { JO: app.cancellationFee?.JO ?? (app.cancellationFee?.amount !== undefined ? app.cancellationFee : { amount: 0.5, afterSeconds: 120 }), PS: app.cancellationFee?.PS ?? { amount: 2, afterSeconds: 120 } },
      waitingFee: { JO: app.waitingFee?.JO ?? (app.waitingFee?.perMinute !== undefined ? app.waitingFee : { freeMinutes: 3, perMinute: 0.05 }), PS: app.waitingFee?.PS ?? { freeMinutes: 3, perMinute: 0.5 } },
      rounding: { JO: 0.05, PS: 0.5, ...app.rounding },
    });
  });
  for (const doc of (await db.collection('users').get()).docs) {
    const user = doc.data();
    const market = user.homeMarket ?? (user.phone ? homeMarket(user.phone) : undefined);
    await doc.ref.update({ ...(market ? { homeMarket: market } : {}),
      balanceDue: { JOD: user.balanceDueFils ?? 0, ILS: 0, ...user.balanceDue }, balanceDueFils: FieldValue.delete() });
  }
  for (const doc of (await db.collection('rides').get()).docs) {
    const ride = doc.data();
    // Historical prices were computed in JOD: preserve their currency and amounts.
    // Do not reinterpret old Palestinian pickups as ILS prices.
    if (!ride.market) await doc.ref.update({ market: 'JO', fare: { ...ride.fare, currency: 'JOD' } });
  }
  for (const doc of (await db.collection('promos').get()).docs) {
    if (!doc.data().market) await doc.ref.update({ market: 'JO' });
  }
  for (const driver of (await db.collection('drivers').get()).docs) {
    for (const doc of (await driver.ref.collection('earnings').get()).docs) {
      if (/^\d{4}-\d{2}-\d{2}$/.test(doc.id)) {
        await db.runTransaction(async tx => {
          const target = driver.ref.collection('earnings').doc(`${doc.id}_JO`);
          if (!(await tx.get(target)).exists) tx.set(target, { ...doc.data(), day: doc.id, market: 'JO', currency: 'JOD' });
          tx.delete(doc.ref);
        });
      }
    }
  }
}
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const projectId = process.env.GCLOUD_PROJECT ?? 'demo-mishwar';
  checkTarget(process.env.FIRESTORE_EMULATOR_HOST, projectId);
  const { initializeApp } = require('firebase-admin/app');
  const { getFirestore } = require('firebase-admin/firestore');
  initializeApp({ projectId });
  await migrateMarkets(getFirestore());
  console.log('Migrated local market documents. Run backfill-stats.mjs next.');
}
