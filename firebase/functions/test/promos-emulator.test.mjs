import process from 'node:process';
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { initializeApp, deleteApp } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { updateRideStatusHandler } from '../lib/rides/lifecycle.js';
test('Firestore retries concurrent last-slot redemption',async()=>{
  const host=process.env.FIRESTORE_EMULATOR_HOST ?? '127.0.0.1:8080';
  assert.match(host,/^(localhost|127\.0\.0\.1):[0-9]+$/);process.env.FIRESTORE_EMULATOR_HOST=host;
  const app=initializeApp({projectId:'demo-mishwar-promos'},'promo-race'),db=getFirestore(app);
  const prefix='promo-'+process.pid,code='RACE'+process.pid,time=Timestamp.now();
  const day=new Intl.DateTimeFormat('en-CA',{timeZone:'Asia/Amman',year:'numeric',month:'2-digit',day:'2-digit'}).format(time.toDate());
  const paths=['promos/'+code,...['a','b'].flatMap(s=>['rides/'+prefix+s,'users/'+prefix+s,'drivers/'+prefix+s,'promos/'+code+'/redemptions/'+prefix+s,'drivers/'+prefix+s+'/earnings/'+day])];
  try {
    const batch=db.batch();batch.set(db.doc('promos/'+code),{type:'fixed',value:1,firstRideOnly:false,usedCount:0,usageLimit:1,active:true,validFrom:Timestamp.fromMillis(0),validUntil:time});
    for(const s of ['a','b']) {
      const id=prefix+s;
      batch.set(db.doc('rides/'+id),{riderId:id,driverId:id,status:'in_progress',vehicleType:'economy',createdAt:time,startedAt:time,route:{distanceMeters:5000},fare:{estimated:3,currency:'JOD'},promo:{code,discountPreview:1}});
      batch.set(db.doc('users/'+id),{activeRideId:id});batch.set(db.doc('drivers/'+id),{currentRideId:id});
    }
    await batch.commit();
    await Promise.all(['a','b'].map(s=>updateRideStatusHandler({auth:{uid:prefix+s},data:{rideId:prefix+s,status:'completed'}},db,()=>time)));
    const rides=await Promise.all(['a','b'].map(s=>db.doc('rides/'+prefix+s).get()));
    assert.equal(rides.filter(r=>r.data().promo.applied).length,1);
    assert.deepEqual(rides.map(r=>r.data().fare.final).sort(),[2,3]);
    assert.equal((await db.doc('promos/'+code).get()).data().usedCount,1);
  } finally {
    const batch=db.batch();for(const p of paths)batch.delete(db.doc(p));await batch.commit();await deleteApp(app);
  }
});
