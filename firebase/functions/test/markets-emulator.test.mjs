import process from 'node:process';
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { initializeApp, deleteApp } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { migrateMarkets, checkTarget } from '../../scripts/migrate-markets.mjs';
import { DEFAULT_PRICING } from '../lib/pricing.js';

test('emulator migration preserves historical money and is idempotent', async () => {
  process.env.FIRESTORE_EMULATOR_HOST ??= '127.0.0.1:8080';
  const projectId = 'demo-mishwar-markets-migration';
  checkTarget(process.env.FIRESTORE_EMULATOR_HOST, projectId);
  const app = initializeApp({projectId}, 'market-migration'), db = getFirestore(app);
  try {
    await db.doc('config/pricing').set(DEFAULT_PRICING);
    await db.doc('config/app').set({cancellationFee:{amount:0.75,afterSeconds:120}});
    await db.doc('users/ps').set({phone:'+970599123456',balanceDueFils:750});
    await db.doc('users/jo').set({phone:'+962791234567',balanceDue:{ILS:250,JOD:100}});
    await db.doc('rides/old').set({fare:{estimated:3.4,final:4,currency:'JOD'},createdAt:Timestamp.now()});
    await db.doc('drivers/a').set({});
    await db.doc('drivers/a/earnings/2026-11-19').set({total:4,trips:1});
    await db.doc('promos/OLD').set({value:1});
    await migrateMarkets(db);
    const paths=['config/pricing','config/app','users/ps','users/jo','rides/old','drivers/a/earnings/2026-11-19_JO','promos/OLD'];
    const first=await Promise.all(paths.map(async p=>(await db.doc(p).get()).data()));
    await migrateMarkets(db);
    assert.deepEqual(await Promise.all(paths.map(async p=>(await db.doc(p).get()).data())),first);
    assert.deepEqual(first[0].JO,DEFAULT_PRICING);
    assert.equal(first[0].PS.economy.base,3);
    assert.equal(first[1].cancellationFee.JO.amount,0.75);
    assert.equal(first[2].homeMarket,'PS');
    assert.deepEqual(first[2].balanceDue,{ILS:0,JOD:750});
    assert.equal(first[2].balanceDueFils,undefined);
    assert.deepEqual(first[3].balanceDue,{ILS:250,JOD:100});
    assert.equal(first[4].market,'JO');
    assert.equal(first[4].fare.final,4);
    assert.equal(first[5].currency,'JOD');
    assert.equal(first[6].market,'JO');
    assert.equal((await db.doc('drivers/a/earnings/2026-11-19').get()).exists,false);
  } finally {
    for (const collection of ['users','rides','drivers','promos','config']) await db.recursiveDelete(db.collection(collection));
    await deleteApp(app);
  }
});
