import { DEFAULT_PRICING, PS_PRICING } from '../functions/lib/pricing.js';
const host = process.env.FIRESTORE_EMULATOR_HOST;
if (!host || !/^(localhost|127\.0\.0\.1):[0-9]+$/.test(host)) {
 throw new Error('FIRESTORE_EMULATOR_HOST must be localhost:PORT or 127.0.0.1:PORT.');
}
const target = new URL('http://' + host);
if (!['localhost','127.0.0.1'].includes(target.hostname) || !target.port) throw new Error('Refusing a non-emulator target.');
const project = process.argv[2] ?? 'demo-mishwar';
if (!/^[a-z][a-z0-9-]{3,62}$/.test(project)) throw new Error('Invalid project ID.');
const ratesFields = table => Object.fromEntries(Object.entries(table).map(([type,rates]) => [type,{
 mapValue: { fields: Object.fromEntries(Object.entries(rates).map(([name,value]) => [name,{doubleValue:value}])) },
}]));
const fields = { JO: { mapValue: { fields: ratesFields(DEFAULT_PRICING) } }, PS: { mapValue: { fields: ratesFields(PS_PRICING) } } };
const response = await fetch(target.origin + '/v1/projects/' + project + '/databases/(default)/documents/config/pricing', {
 method:'PATCH', redirect:'error', headers:{'Content-Type':'application/json',Authorization:'Bearer owner'},body:JSON.stringify({fields}),
});
if (!response.ok) throw new Error('Emulator seed failed with HTTP ' + response.status);
console.log('Seeded config/pricing in the local Firestore emulator.');
