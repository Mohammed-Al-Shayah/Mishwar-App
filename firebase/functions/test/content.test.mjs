import { test } from 'node:test';
import assert from 'node:assert/strict';
import { upsertBannerHandler, deleteBannerHandler, updateServicesHandler } from '../lib/admin/content.js';
import { harness } from './ride-fixtures.mjs';
const request=data=>({auth:{uid:'admin',token:{admin:true}},data});
const banner={title:'Welcome',subtitle:'First ride',imageUrl:'https://picsum.photos/seed/welcome/800/400',action:'open_promo',promoCode:'WELCOME50',order:1,validUntil:'2027-01-01T00:00:00.000Z',active:true};
const logs=h=>[...h.db.records].filter(([p])=>p.startsWith('adminLog/')).map(([,d])=>d);
test('banner callables require strict admin claims',async()=>{
 for(const fn of [upsertBannerHandler,deleteBannerHandler,updateServicesHandler])for(const auth of [undefined,{uid:'r',token:{}},{uid:'r',token:{admin:'true'}}]){
  const h=harness();await assert.rejects(fn({auth,data:banner},h.db),{code:'permission-denied'});assert.equal(logs(h).length,0);
 }
});
test('banner create/edit/delete writes clean fields and atomic audit',async()=>{
 const h=harness();const {id}=await upsertBannerHandler(request({...banner,forged:'ignored'}),h.db);
 let saved=h.db.records.get('banners/'+id);assert.equal(saved.promoCode,'WELCOME50');assert.equal(saved.forged,undefined);assert.ok(saved.validUntil.toMillis());
 assert.equal(logs(h)[0].by,'admin');assert.equal(logs(h)[0].target,'banners/'+id);
 await upsertBannerHandler(request({...banner,id,action:'url',url:'https://example.com/offer'}),h.db);
 saved=h.db.records.get('banners/'+id);assert.equal(saved.promoCode,undefined);assert.equal(saved.url,'https://example.com/offer');
 await deleteBannerHandler(request({id}),h.db);assert.equal(h.db.records.has('banners/'+id),false);assert.equal(logs(h).length,3);
 await assert.rejects(deleteBannerHandler(request({id}),h.db),{code:'not-found'});assert.equal(logs(h).length,3);
});
test('banner validation rejects bad bounds, types, dates and unsafe URLs without writes',async()=>{
 for(const change of [{title:''},{title:'x'.repeat(61)},{subtitle:'x'.repeat(121)},{imageUrl:'http://example.com'},{imageUrl:'https://user:pass@example.com'},{imageUrl:'javascript:alert(1)'},{action:'unknown'},{promoCode:''},{order:1.1},{order:'1'},{order:Infinity},{active:1},{validUntil:'invalid'},{validUntil:'2027-02-30T00:00:00.000Z'},{validUntil:123},{id:'../x'},{action:'url',url:'http://example.com'},{action:'url',url:''}]){
  const h=harness();await assert.rejects(upsertBannerHandler(request({...banner,...change}),h.db),{code:'invalid-argument'});assert.equal(logs(h).length,0);
 }
});

const services=['ride','schedule','parcel','airport'].map((id,order)=>({id,order,enabled:order<2}));
test('services requires exactly four known ids, boolean flags and safe integer orders',async()=>{
 for(const invalid of [undefined,[],services.slice(1),[...services,services[0]],services.map(s=>({...s,id:'ride'})),services.map(s=>({...s,id:s.id==='ride'?'other':s.id})),services.map(s=>({...s,enabled:1})),services.map(s=>({...s,order:0.5})),services.map(s=>({...s,order:'1'})),services.map(s=>({...s,order:Infinity}))]){
  const h=harness();await assert.rejects(updateServicesHandler(request({services:invalid}),h.db),{code:'invalid-argument'});assert.equal(logs(h).length,0);
 }
});
test('services preserves other app flags and writes one atomic audit',async()=>{
 const h=harness({'config/app':{scheduling:{minLeadMinutes:30},cancellationFee:{amount:1}}});
 await updateServicesHandler(request({services:services.map(s=>({...s,forged:'ignored'}))}),h.db);
 const config=h.db.records.get('config/app');assert.deepEqual(config.services,services);assert.deepEqual(config.scheduling,{minLeadMinutes:30});assert.deepEqual(config.cancellationFee,{amount:1});assert.equal(config.updatedBy,'admin');
 assert.equal(logs(h).length,1);assert.equal(logs(h)[0].action,'updateServices');assert.deepEqual(logs(h)[0].details.services,services);
});
