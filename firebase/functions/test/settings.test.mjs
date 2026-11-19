import { URL } from 'node:url';
import {test} from 'node:test';
import assert from 'node:assert/strict';
import {Timestamp} from 'firebase-admin/firestore';
import {updateAppSettingsHandler,upsertPromoHandler,setPromoActiveHandler} from '../lib/admin/settings.js';
import {harness} from './ride-fixtures.mjs';
const request=data=>({auth:{uid:'admin',token:{admin:true}},data});
const promo={code:'SAVE20',type:'percent',value:20,firstRideOnly:false,perUserLimit:1,validFrom:'2026-01-01T00:00:00.000Z',validUntil:'2027-01-01T00:00:00.000Z',active:true};
const airport={zone:JSON.stringify({type:'Polygon',coordinates:[[[35,31],[36,31],[36,32],[35,32],[35,31]]]}),fixedFares:{economy:12,comfort:16,van:20},pickupPoints:[]};
test('settings and promo operations require strict admin claim',async()=>{for(const fn of [updateAppSettingsHandler,upsertPromoHandler,setPromoActiveHandler])for(const auth of [undefined,{uid:'x',token:{}},{uid:'x',token:{admin:'true'}}])await assert.rejects(fn({auth,data:{}},harness().db),{code:'permission-denied'});});
test('settings sections merge without editing zone or other settings and record audit',async()=>{
 const h=harness({'config/app':{airport,cancellationFee:{amount:1,afterSeconds:120},services:[{id:'ride'}]}});
 await updateAppSettingsHandler(request({cancellationFee:{amount:0},airport:{fixedFares:{van:100},pickupPoints:[{id:'a',name:'Gate',lat:31.5,lng:35.5}]}}),h.db);
 const app=h.db.records.get('config/app');assert.equal(app.airport.zone,airport.zone);assert.equal(app.airport.fixedFares.comfort,16);assert.equal(app.airport.fixedFares.van,100);assert.equal(app.cancellationFee.JO.afterSeconds,120);assert.equal(app.services[0].id,'ride');assert.equal([...h.db.records.keys()].filter(p=>p.startsWith('adminLog/')).length,1);
});
test('settings rejects every bound and invalid airport points without writes',async()=>{
 const invalid=[{}, {zone:{}},{cancellationFee:{amount:21,afterSeconds:0}},{cancellationFee:{amount:0,afterSeconds:1801}},{waitingFee:{freeMinutes:31,perMinute:0}},{waitingFee:{freeMinutes:0,perMinute:2.1}},{scheduling:{minLeadMinutes:14,maxDaysAhead:1,dispatchBeforeMinutes:5}},{scheduling:{minLeadMinutes:15,maxDaysAhead:61,dispatchBeforeMinutes:5}},{scheduling:{minLeadMinutes:15,maxDaysAhead:1,dispatchBeforeMinutes:61}},{airport:{zone:'x'}},{airport:{fixedFares:{economy:0}}},{airport:{pickupPoints:[{id:'a',name:'Outside',lat:30,lng:35}]}},{airport:{pickupPoints:Array(11).fill({id:'a',name:'A',lat:31.5,lng:35.5})}},{airport:{pickupPoints:[{id:'a',name:'x'.repeat(61),lat:31.5,lng:35.5}]}}];
 for(const data of invalid){const h=harness({'config/app':{airport}});await assert.rejects(updateAppSettingsHandler(request(data),h.db),{code:'invalid-argument'});assert.equal(h.db.records.size,5);}
});
test('promo preserves redemptions and used count, removes optional fields, enforces history',async()=>{
 const h=harness({'promos/SAVE20':{...promo,usedCount:4,maxDiscount:2},'promos/SAVE20/redemptions/u':{count:1}});
 for(const change of [{type:'fixed'},{usageLimit:3}])await assert.rejects(upsertPromoHandler(request({...promo,...change}),h.db),{code:'failed-precondition'});
 await upsertPromoHandler(request({...promo,usageLimit:4}),h.db);const p=h.db.records.get('promos/SAVE20');assert.equal(p.usedCount,4);assert.equal(p.maxDiscount,undefined);assert.ok(p.validFrom instanceof Timestamp);assert.equal(h.db.records.get('promos/SAVE20/redemptions/u').count,1);
 await setPromoActiveHandler(request({code:'SAVE20',active:false}),h.db);assert.equal(h.db.records.get('promos/SAVE20').active,false);
 await assert.rejects(setPromoActiveHandler(request({code:'MISSING',active:true}),h.db),{code:'not-found'});
});
test('promo validates codes dates numeric fields booleans and limits',async()=>{for(const change of [{code:'abc'},{code:'AB'},{code:'A'.repeat(21)},{type:'other'},{value:101},{value:NaN},{perUserLimit:0},{usageLimit:1.5},{firstRideOnly:1},{active:'true'},{validFrom:'2027-02-30T00:00:00.000Z'},{validUntil:promo.validFrom},{maxDiscount:-1},{minFare:Infinity}])await assert.rejects(upsertPromoHandler(request({...promo,...change}),harness().db),{code:'invalid-argument'});});

import {readFileSync} from 'node:fs';
import {evaluatePromo} from '../lib/promos/evaluate.js';
test('promo math shares fixtures with Dart admin preview',()=>{
 const fixtures=JSON.parse(readFileSync(new URL('./fixtures/promo-math.json',import.meta.url),'utf8').replace(/^\uFEFF/,''));
 for(const f of fixtures){const result=evaluatePromo({...f,usedCount:0,active:true,firstRideOnly:false,validFrom:{toMillis:()=>0},validUntil:{toMillis:()=>2}}, {fareJod:f.fareMinor/1000,uid:'r',isFirstRide:true,userRedemptions:0,now:{toMillis:()=>1}});assert.equal(result.ok,true);assert.equal(Math.round(result.discountJod*1000),f.expected);}
});
