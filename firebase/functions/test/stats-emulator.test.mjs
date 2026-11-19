import process from 'node:process';
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { initializeApp, deleteApp } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { countRideStats } from '../lib/admin/stats.js';
test('emulator transactions count concurrent ride deliveries and retries exactly once', async () => {
 const host=process.env.FIRESTORE_EMULATOR_HOST ?? '127.0.0.1:8080';
 assert.match(host,/^(localhost|127\.0\.0\.1):[0-9]+$/);process.env.FIRESTORE_EMULATOR_HOST=host;
 const app=initializeApp({projectId:'demo-mishwar-stats'},'stats-race'),db=getFirestore(app);
 const time=Timestamp.fromDate(new Date('2026-11-18T22:00:00Z')),prefix='stats'+process.pid;
 const after={status:'completed',createdAt:time,completedAt:time,fare:{final:4.15,discount:0.85},promo:{code:'SAVE20',applied:true}};
 const paths=['rides/'+prefix+'a','rides/'+prefix+'b','stats/2026-11-19_JO','stats/promos/SAVE20/2026-11-19_JO'];
 try{
  const batch=db.batch();for(const id of ['a','b'])batch.set(db.doc('rides/'+prefix+id),after);await batch.commit();
  await Promise.all(['a','a','b','b'].map(id=>countRideStats(db,prefix+id,{...after,status:'in_progress'},after,time)));
  const stats=(await db.doc('stats/2026-11-19_JO').get()).data();assert.equal(stats.requested,2);assert.equal(stats.completed,2);assert.equal(stats.revenueMinor,8300);assert.equal(stats.discountMinor,1700);assert.equal(stats.promoUses,2);assert.equal((await db.doc('stats/promos/SAVE20/2026-11-19_JO').get()).data().uses,2);
 }finally{const batch=db.batch();for(const p of paths)batch.delete(db.doc(p));await batch.commit();await deleteApp(app);}
});
import {execFile} from 'node:child_process';
import {promisify} from 'node:util';
import {fileURLToPath, URL} from 'node:url';
test('emulator backfill replaces aggregates idempotently and records deduplication markers',async()=>{
 const projectId='demo-mishwar-backfill',app=initializeApp({projectId},'backfill-test'),db=getFirestore(app);
 const createdAt=Timestamp.fromDate(new Date('2026-11-18T22:00:00Z'));
 const ride={status:'completed',createdAt,completedAt:createdAt,serviceType:'airport',fare:{final:12,discount:2},promo:{code:'SAVE20',applied:true}};
 const paths=['rides/a','stats/2026-11-19_JO','stats/promos/SAVE20/2026-11-19_JO'];
 try{
  await db.doc('rides/a').set(ride);
  const script=fileURLToPath(new URL('../../scripts/backfill-stats.mjs',import.meta.url));
  const env={...process.env,FIRESTORE_EMULATOR_HOST:'127.0.0.1:8080',GCLOUD_PROJECT:projectId};
  for(let i=0;i<2;i++)await promisify(execFile)(process.execPath,[script],{env});
  const row=(await db.doc('stats/2026-11-19_JO').get()).data();assert.equal(row.requested,1);assert.equal(row.revenueMinor,12000);assert.equal(row.airport,1);assert.equal(row.discountMinor,2000);assert.equal(row.promoUses,1);assert.equal((await db.doc('stats/promos/SAVE20/2026-11-19_JO').get()).data().uses,1);assert.deepEqual((await db.doc('rides/a').get()).data().statsCountedFor,['requested','completed']);
  await countRideStats(db,'a',{...ride,status:'in_progress'},ride,createdAt);assert.equal((await db.doc('stats/2026-11-19_JO').get()).data().completed,1);
  await assert.rejects(promisify(execFile)(process.execPath,[script],{env:{...env,FIRESTORE_EMULATOR_HOST:'example.com:8080'}}));
 }finally{const batch=db.batch();for(const p of paths)batch.delete(db.doc(p));await batch.commit();await deleteApp(app);}
});
