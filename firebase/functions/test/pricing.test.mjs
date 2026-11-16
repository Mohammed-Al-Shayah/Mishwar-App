/* global URL, process */
/* global Response, DOMException */
import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {spawnSync, spawn} from 'node:child_process';
import {createServer} from 'node:http';
import {computeFare,DEFAULT_PRICING} from '../lib/pricing.js';
import {fareEstimatesHandler} from '../lib/getFareEstimates.js';
const fixtures=JSON.parse(readFileSync(new URL('./fixtures/fares.json',import.meta.url),'utf8'));
for(const row of fixtures) test('fixture: '+row.name,()=>{
 assert.equal(computeFare(DEFAULT_PRICING[row.vehicleType],row.distanceMeters,row.durationSeconds)*1000,row.expectedFils);
});
test('invalid rates or measurements are rejected',()=>{
 for(const value of [-1,NaN,Infinity]) {
 assert.throws(()=>computeFare(DEFAULT_PRICING.economy,value,0),RangeError);
 assert.throws(()=>computeFare(DEFAULT_PRICING.economy,0,value),RangeError);
 assert.throws(()=>computeFare({...DEFAULT_PRICING.economy,base:value},0,0),RangeError);
 }
 assert.throws(()=>computeFare({...DEFAULT_PRICING.economy,base:0.0001},0,0),RangeError);
});
const data={origin:{lat:31,lng:35},destination:{lat:32,lng:36}};
const request={auth:{uid:'test'},data};
const body={routes:[{distanceMeters:10000,duration:'600s',polyline:{encodedPolyline:'abc'}}]};
const fakeFetch=async()=>Response.json(body);
test('fare estimates default only when document is missing',async()=>{
 const result=await fareEstimatesHandler(request,'fake',fakeFetch,async()=>undefined);
 assert.deepEqual(result,{route:{polyline:'abc',distanceMeters:10000,durationSeconds:600},fares:[
 {vehicleType:'economy',amount:4,currency:'JOD'},
 {vehicleType:'comfort',amount:6,currency:'JOD'},
 {vehicleType:'van',amount:7.3,currency:'JOD'},
 ]});
});
test('configured rates override defaults',async()=>{
 const pricing=Object.fromEntries(Object.keys(DEFAULT_PRICING).map(type=>[type,{base:10,perKm:0,perMin:0,minimum:10}]));
 const result=await fareEstimatesHandler(request,'fake',fakeFetch,async()=>pricing);
 assert.ok(result.fares.every(fare=>fare.amount===10));
});
test('malformed pricing and Firestore failure are sanitized',async()=>{
 for(const load of [async()=>({}),async()=>null,async()=>{throw Error('private details');}]) await assert.rejects(fareEstimatesHandler(request,'fake',fakeFetch,load),{code:'internal',message:'Fare estimates are unavailable.'});
});
for(const [status,code] of [[400,'internal'],[503,'unavailable']])test('fare estimates Google HTTP '+status,async()=>{
 await assert.rejects(fareEstimatesHandler(request,'fake',async()=>new Response('private',{status}),async()=>assert.fail('pricing called')),{code});
});
test('fare estimates timeout',async(context)=>{
 context.mock.timers.enable({apis:['setTimeout']});
 const pending=fareEstimatesHandler(request,'fake',async(_url,init)=>new Promise((_resolve,reject)=>init.signal.addEventListener('abort',()=>reject(new DOMException('private','AbortError')))),async()=>assert.fail('pricing called'));
 const rejected=assert.rejects(pending,{code:'unavailable'});context.mock.timers.tick(8000);await rejected;
});
test('fare estimates unauthenticated and invalid input',async()=>{
 for(const [req,code] of [[{data},'unauthenticated'],[{auth:{uid:'test'},data:{}},'invalid-argument']]) await assert.rejects(fareEstimatesHandler(req,'fake',()=>assert.fail('network called'),async()=>assert.fail('pricing called')),{code});
});
test('fare estimates no route',async()=>{
 await assert.rejects(fareEstimatesHandler(request,'fake',async()=>Response.json({routes:[]}),async()=>assert.fail('pricing called')),{code:'not-found'});
});
test('seed refuses missing, remote and disguised hosts',()=>{
 for(const host of ['', 'example.com:8080','127.0.0.1.evil:8080','localhost:8080@evil.com','localhost:8080/path','https://localhost:8080']){
 const result=spawnSync(process.execPath,['../seed/seed_pricing.mjs'],{env:{...process.env,FIRESTORE_EMULATOR_HOST:host},encoding:'utf8'});
 assert.notEqual(result.status,0);assert.match(result.stderr,/FIRESTORE_EMULATOR_HOST/);
 }
});

test('seed writes defaults through local REST with owner authorization',async()=>{
 let received;
 const server=createServer(async(req,res)=>{
  let body='';for await(const chunk of req)body+=chunk;
  received={method:req.method,url:req.url,auth:req.headers.authorization,body:JSON.parse(body)};
  res.writeHead(200,{'Content-Type':'application/json'});res.end('{}');
 });
 await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
 try {
  const child=spawn(process.execPath,['../seed/seed_pricing.mjs','demo-mishwar'],{env:{...process.env,FIRESTORE_EMULATOR_HOST:'127.0.0.1:'+server.address().port},stdio:'pipe'});
  let errors='';child.stderr.on('data',chunk=>{errors+=chunk;});
  const code=await new Promise((resolve,reject)=>{child.on('error',reject);child.on('exit',resolve);});
  assert.equal(code,0,errors);
  assert.equal(received.method,'PATCH');assert.equal(received.auth,'Bearer owner');
  assert.equal(received.url,'/v1/projects/demo-mishwar/databases/(default)/documents/config/pricing');
  for(const [type,rates] of Object.entries(DEFAULT_PRICING))for(const [name,value]of Object.entries(rates))assert.equal(received.body.fields[type].mapValue.fields[name].doubleValue,value);
 } finally { await new Promise(resolve=>server.close(resolve)); }
});
