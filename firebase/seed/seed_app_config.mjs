// Neutral demo placeholders only. Replace picsum images with real promotional art.
const host = process.env.FIRESTORE_EMULATOR_HOST;
if (!host || !/^(localhost|127\.0\.0\.1):[0-9]+$/.test(host)) throw new Error('Local FIRESTORE_EMULATOR_HOST required.');
const project = process.argv[2] ?? 'demo-mishwar';
if (!/^[a-z][a-z0-9-]{3,62}$/.test(project)) throw new Error('Invalid project ID.');
const base = 'http://' + host + '/v1/projects/' + project + '/databases/(default)/documents/';
const encode = value => value instanceof Date ? { timestampValue: value.toISOString() }
 : Array.isArray(value) ? { arrayValue: { values: value.map(encode) } }
 : typeof value === 'object' ? { mapValue: { fields: fields(value) } }
 : typeof value === 'boolean' ? { booleanValue: value }
 : typeof value === 'number' ? { integerValue: String(value) } : { stringValue: value };
const fields = value => Object.fromEntries(Object.entries(value).map(([key,value])=>[key,encode(value)]));
async function put(path,data,mask='') {
 const response=await fetch(base+path+mask,{method:'PATCH',redirect:'error',headers:{'Content-Type':'application/json',Authorization:'Bearer owner'},body:JSON.stringify({fields:fields(data)})});
 if(!response.ok)throw new Error('App content seed failed with HTTP '+response.status);
}
await put('config/app',{services:['ride','schedule','parcel','airport'].map((id,order)=>({id,order,enabled:order<2}))},'?updateMask.fieldPaths=services');
const validUntil=new Date();validUntil.setFullYear(validUntil.getFullYear()+1);
await put('banners/welcome',{title:'خصم على أول مشوار',subtitle:'استخدم WELCOME50',imageUrl:'https://picsum.photos/seed/welcome/800/400',promoCode:'WELCOME50',action:'open_promo',order:0,validUntil,active:true});
await put('banners/explore',{title:'وين رايح؟',subtitle:'ابحث عن وجهتك واطلب مشوارك',imageUrl:'https://picsum.photos/seed/explore/800/400',action:'open_search',order:1,validUntil,active:true});
console.log('Seeded app services and two demo banners in the local Firestore emulator. Replace placeholder images with real art.');
