import {test} from 'node:test';
import assert from 'node:assert/strict';
import {Timestamp} from 'firebase-admin/firestore';
import {countRideStats,rideContributions} from '../lib/admin/stats.js';
import {FakeFirestore} from './fake-firestore.mjs';
const at=iso=>Timestamp.fromDate(new Date(iso));
const createdAt=at('2026-11-17T22:30:00Z'), completedAt=at('2026-11-18T22:30:00Z');
const ride={status:'searching',createdAt,serviceType:'parcel',scheduledFor:completedAt};
test('create counts requested and service categories on Asia/Amman creation day',async()=>{
 const db=new FakeFirestore({'rides/x':ride});await countRideStats(db,'x',undefined,ride,createdAt);
 const row=db.records.get('stats/2026-11-18');assert.equal(row.requested,1);assert.equal(row.parcels,1);assert.equal(row.scheduled,1);assert.equal(row.airport,0);
 assert.deepEqual(db.records.get('rides/x').statsCountedFor,['requested']);
 const airport=rideContributions({...ride,serviceType:'airport'},createdAt)[0];assert.equal(airport.counters.airport,1);assert.equal(airport.counters.parcels,0);
});
test('completion sums integer fils discounts and promo uses; retry and self-write are no-ops',async()=>{
 const db=new FakeFirestore();
 for(const id of ['a','b']){
  const after={...ride,status:'completed',completedAt,fare:{final:3.65,discount:1.35},promo:{code:'SAVE20',applied:true}};db.records.set('rides/'+id,after);
  await Promise.all([countRideStats(db,id,ride,after,completedAt),countRideStats(db,id,ride,after,completedAt)]);
  const current=db.records.get('rides/'+id);await countRideStats(db,id,after,current,completedAt);
 }
 const row=db.records.get('stats/2026-11-19');assert.equal(row.completed,2);assert.equal(row.revenueFils,7300);assert.equal(row.discountFils,2700);assert.equal(row.promoUses,2);assert.deepEqual(row.promoUsesByCode,{SAVE20:2});assert.equal(db.records.get('stats/promos/SAVE20/2026-11-19').uses,2);assert.equal(db.records.get('stats/2026-11-18').requested,2);
});
test('each cancellation actor and no drivers count once on transition day',async()=>{
 for(const actor of ['rider','driver','system']){const after={...ride,status:'cancelled',cancelledBy:actor,cancelledAt:completedAt};const db=new FakeFirestore({'rides/x':after});await countRideStats(db,'x',ride,after,completedAt);await countRideStats(db,'x',ride,after,completedAt);assert.equal(db.records.get('stats/2026-11-19')['cancelledBy'+actor[0].toUpperCase()+actor.slice(1)],1);}
 const after={...ride,status:'no_drivers',noDriversAt:completedAt};const db=new FakeFirestore({'rides/x':after});await countRideStats(db,'x',ride,after,completedAt);assert.equal(db.records.get('stats/2026-11-19').noDrivers,1);
});
test('driver redispatch counts driver cancellation, once, without a new request',async()=>{
 const before={...ride,status:'accepted'},after={...ride,driverCancelledAt:completedAt};const db=new FakeFirestore({'rides/x':after});await countRideStats(db,'x',before,after,completedAt);await countRideStats(db,'x',before,after,completedAt);assert.equal(db.records.get('stats/2026-11-19').cancelledByDriver,1);assert.equal(db.records.get('stats/2026-11-18').requested,1);
});
test('out-of-order create delivery preserves completed markers; non-status writes and deletions do nothing',async()=>{
 const after={...ride,status:'completed',completedAt,fare:{final:5,discount:0},promo:{code:'SAVE20',applied:false}};const db=new FakeFirestore({'rides/x':after});await countRideStats(db,'x',ride,after,completedAt);await countRideStats(db,'x',undefined,ride,createdAt);assert.equal(db.records.get('stats/2026-11-18').requested,1);assert.equal(db.records.get('stats/2026-11-19').promoUses,0);
 const size=db.records.size;await countRideStats(db,'x',after,{...after,rating:5},completedAt);await countRideStats(db,'x',after,undefined,completedAt);assert.equal(db.records.size,size);
});
test('midnight boundary follows Amman rather than UTC',()=>{assert.equal(rideContributions({...ride,createdAt:at('2026-11-18T20:59:59Z')},createdAt)[0].day,'2026-11-18');assert.equal(rideContributions({...ride,createdAt:at('2026-11-18T21:00:00Z')},createdAt)[0].day,'2026-11-19');});
