/* global Response, DOMException */
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { HttpsError } from 'firebase-functions/v2/https';
import { mapsKey } from '../lib/lib/maps.js';
import { autocompleteHandler } from '../lib/placesAutocomplete.js';
import { detailsHandler } from '../lib/placeDetails.js';
import { routeHandler } from '../lib/getRoute.js';
import { google } from '../lib/lib/google.js';
import * as v from '../lib/lib/validate.js';
const token = '12345678-abcd-1234-abcd-123456789012';
const point = { lat: 31.9, lng: 35.9 };
const route = { routes: [{distanceMeters: 5000, duration: '600.5s', polyline: {encodedPolyline: 'abc'}}] };
export const cases = [
 ['autocomplete', autocompleteHandler, {input:' Amman ',sessionToken:token}, {suggestions: [{placePrediction: {placeId:'a',text:{text:'fallback'}}}]}],
 ['details', detailsHandler, {placeId:'a/b',sessionToken:token}, {id:'a/b', displayName:{text:'Name'},formattedAddress:'Address',location:{latitude:31,longitude:35}}],
 ['route', routeHandler, {origin:point,destination:point}, route],
];
for (const [name,handler,data,body] of cases) {
 test(name + ' success', async () => {
  let called = false;
  const result = await handler({auth:{uid:'test'},data},'fake-key',async (url,init)=>{
   called=true; assert.equal(init.headers['X-Goog-Api-Key'],'fake-key'); assert.ok(init.signal);
   if(name==='autocomplete') { const payload=JSON.parse(init.body); assert.equal(payload.input,'Amman'); assert.equal(payload.languageCode,'ar'); assert.deepEqual(payload.includedRegionCodes,['jo']); assert.equal(payload.locationBias,undefined); }
   if(name==='details') { assert.ok(url.includes('a%2Fb')); assert.equal(init.headers['X-Goog-FieldMask'],'id,displayName,formattedAddress,location'); }
   if(name==='route') { const payload=JSON.parse(init.body); assert.equal(payload.travelMode,'DRIVE');assert.equal(payload.routingPreference,'TRAFFIC_AWARE'); }
   return Response.json(body);
  });
  assert.ok(called);
  if(name==='autocomplete')assert.equal(result.suggestions[0].primaryText,'fallback');
  if(name==='details')assert.equal(result.lat,31);
  if(name==='route')assert.equal(result.durationSeconds,600.5);
 });
 for(const [status,code] of [[400,'internal'],[503,'unavailable']]) test(name+' HTTP '+status,async()=>{
  await assert.rejects(handler({auth:{uid:'test'},data},'fake-key',async()=>new Response('private upstream body',{status})),{code,message:'Map service request failed.'});
 });
 test(name+' timeout',async(context)=>{
  context.mock.timers.enable({apis:['setTimeout']});
  const pending=handler({auth:{uid:'test'},data},'fake-key',async(_url,init)=>new Promise((_resolve,reject)=>init.signal.addEventListener('abort',()=>reject(new DOMException('private','AbortError')))));
  const rejected=assert.rejects(pending,{code:'unavailable'});
  context.mock.timers.tick(8000);
  await rejected;
 });
 test(name+' unauthenticated',async()=>{
  await assert.rejects(handler({data},'fake-key',()=>assert.fail('network called')),{code:'unauthenticated'});
 });
 test(name+' invalid input',async()=>{
  await assert.rejects(handler({auth:{uid:'test'},data:{}},'fake-key',()=>assert.fail('network called')),{code:'invalid-argument'});
 });
}
test('actual abort timer covers body consumption',async()=>{
 await assert.rejects(google('https://fake',{},async(_url,init)=>({ok:true,json:()=>new Promise((_resolve,reject)=>init.signal.addEventListener('abort',()=>reject(new DOMException('timeout','AbortError'))))}),1),{code:'unavailable'});
});
test('validation boundaries and trimming',()=>{
 assert.deepEqual(v.point({lat:-90,lng:180}),{lat:-90,lng:180});
 assert.equal(v.string(' a ',1,1),'a'); assert.equal(v.language(undefined),'ar');assert.equal(v.language('en'),'en');
 for(const value of [null,[],1,'x'])assert.throws(()=>v.object(value),{code:'invalid-argument'});
 for(const value of [NaN,Infinity,91,'1',undefined])assert.throws(()=>v.coordinate(value,90),{code:'invalid-argument'});
 for(const value of ['', 'x'.repeat(101), 1])assert.throws(()=>v.string(value,1,100),{code:'invalid-argument'});
 for(const value of ['short','a'.repeat(65),'1234567!'])assert.throws(()=>v.sessionToken(value),{code:'invalid-argument'});
 assert.throws(()=>v.language('fr'),{code:'invalid-argument'});
});
test('autocomplete bias, structured texts and five-result limit',async()=>{
 const result=await autocompleteHandler({auth:{uid:'test'},data:{input:'a',sessionToken:token,lat:0,lng:0,lang:'en'}},'fake',async(_url,init)=>{
 const payload=JSON.parse(init.body);assert.equal(payload.locationBias.circle.radius,30000);assert.equal(payload.locationBias.circle.center.latitude,0);
 return Response.json({suggestions:Array.from({length:8},()=>({placePrediction:{placeId:'a',structuredFormat:{mainText:{text:'Main'},secondaryText:{text:'Secondary'}}}}))});
 });
 assert.equal(result.suggestions.length,5);assert.equal(result.suggestions[0].secondaryText,'Secondary');
});
test('no route and malformed route',async()=>{
 for(const [body,code] of [[{routes:[]},'not-found'],[{routes:[{}]},'internal']]) await assert.rejects(routeHandler({auth:{uid:'a'},data:{origin:point,destination:point}},'fake',async()=>Response.json(body)),{code});
});

test('all deployed callables require auth',async(context)=>{
 const deployed=await import('../lib/index.js');
 // Exercise the deployed wrappers without resolving a real secret or network.
 context.mock.method(mapsKey,'value',()=> 'fake-key');
 context.mock.method(globalThis,'fetch',()=>assert.fail('network called'));
 const callables=Object.entries(deployed).filter(([,value])=>value.__endpoint?.callableTrigger);
 assert.deepEqual(callables.map(([name])=>name).sort(),[
  'getFareEstimates','getRoute','ping','placeDetails','placesAutocomplete',
 ]);
 for(const [name,callable] of callables) {
  await assert.rejects(()=>callable.run({data:{}}),(error)=>{
   assert.ok(error instanceof HttpsError,name);
   assert.equal(error.code,'unauthenticated',name);
   return true;
  });
 }
 assert.equal((await deployed.ping.run({auth:{uid:'test'},data:{}})).ok,true);
});
