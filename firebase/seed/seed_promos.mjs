const host = process.env.FIRESTORE_EMULATOR_HOST;
if (!host || !/^(localhost|127\.0\.0\.1):[0-9]+$/.test(host)) throw new Error('Local FIRESTORE_EMULATOR_HOST required.');
const project = process.argv[2] ?? 'demo-mishwar';
if (!/^[a-z][a-z0-9-]{3,62}$/.test(project)) throw new Error('Invalid project ID.');
const start = new Date(), end = new Date(start); end.setFullYear(end.getFullYear()+1);
const common = {active:true,usedCount:0,perUserLimit:1,validFrom:start,validUntil:end};
for (const [code,promo] of Object.entries({
  WELCOME50:{...common,type:'percent',value:50,maxDiscount:2,firstRideOnly:true,usageLimit:1000},
  MISHWAR1:{...common,type:'fixed',value:1,minFare:3,firstRideOnly:false},
})) {
  const fields=Object.fromEntries(Object.entries(promo).map(([k,v])=>[k,v instanceof Date?{timestampValue:v.toISOString()}:typeof v==='boolean'?{booleanValue:v}:typeof v==='number'?{doubleValue:v}:{stringValue:v}]));
  const response=await fetch('http://'+host+'/v1/projects/'+project+'/databases/(default)/documents/promos/'+code,{
    method:'PATCH',redirect:'error',headers:{'Content-Type':'application/json',Authorization:'Bearer owner'},body:JSON.stringify({fields}),
  });
  if(!response.ok)throw new Error('Promo seed failed with HTTP '+response.status);
}
console.log('Seeded promos in the local Firestore emulator.');
