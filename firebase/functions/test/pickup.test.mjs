/* global Response, URL */
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { reverseGeocodeHandler, pickupSuggestionsHandler } from '../lib/pickup.js';
const request = (data) => ({ auth: { uid: 'u' }, data });
const point = { lat: 31.901111, lng: 35.901111 };
const address = { status: 'OK', results: [{ formatted_address: 'Full address', address_components: [{ long_name: '12', types: ['street_number'] }, { long_name: 'Street', types: ['route'] }] }] };
test('reverse maps street and number and caches rounded coordinates per language', async () => {
  let calls = 0;
  const fetch = async (url) => { calls++; assert.equal(new URL(url).searchParams.get('language'), calls === 1 ? 'ar' : 'en'); return Response.json(address); };
  assert.deepEqual(await reverseGeocodeHandler(request(point), 'fake', fetch), { name: 'Street 12', address: 'Full address' });
  await reverseGeocodeHandler(request({ lat: 31.901112, lng: 35.901112 }), 'fake', fetch);
  assert.equal(calls, 1);
  await reverseGeocodeHandler(request({ ...point, lang: 'en' }), 'fake', fetch);
  assert.equal(calls, 2);
});
test('reverse prefers POI and maps upstream statuses', async () => {
  const poi = { status: 'OK', results: [{ formatted_address: 'Address', address_components: [{ long_name: 'Mall', types: ['point_of_interest'] }] }] };
  assert.equal((await reverseGeocodeHandler(request({ lat: 2, lng: 2 }), 'fake', async () => Response.json(poi))).name, 'Mall');
  for (const [status, code] of [['ZERO_RESULTS', 'not-found'], ['OVER_QUERY_LIMIT', 'unavailable'], ['UNKNOWN_ERROR', 'unavailable'], ['REQUEST_DENIED', 'internal'], ['OK', 'internal']]) {
    await assert.rejects(reverseGeocodeHandler(request({lat: 3,lng: 3}), 'fake', async () => Response.json({ status })), { code });
  }
});
test('suggestions maps nearby points and adds airport points only inside zone', async () => {
  const config = async () => ({ airport: { zone: { type: 'Polygon', coordinates: [[[35,31],[36,31],[36,32],[35,32],[35,31]]] }, fixedFares: { economy: 1, comfort: 2, van: 3 }, pickupPoints: [{ id: 'terminal', name: 'Arrivals', ...point }] } });
  const fetch = async (_url, init) => {
    const body = JSON.parse(init.body);
    assert.equal(body.locationRestriction.circle.radius, 150);
    assert.equal(body.maxResultCount, 4);
    assert.ok(body.includedTypes.includes('parking'));
    assert.equal(init.headers['X-Goog-FieldMask'], 'places.id,places.displayName,places.location');
    return Response.json({ places: [{}, ...Array.from({ length: 5 }, (_, i) => ({ id: String(i), displayName: { text: 'Parking' }, location: { latitude: point.lat, longitude: point.lng } }))] });
  };
  const result = await pickupSuggestionsHandler(request(point), 'fake', fetch, config);
  assert.equal(result.length, 5);
  assert.deepEqual(result[0], { id: '0', name: 'Parking', ...point, distanceMeters: 0 });
  assert.equal(result[4].id, 'terminal');
  assert.equal((await pickupSuggestionsHandler(request({lat: 0,lng: 0}), 'fake', fetch, config)).length, 4);
});
for (const handler of [reverseGeocodeHandler, pickupSuggestionsHandler]) {
  test(handler.name + ' validates auth and coordinates before fetching', async () => {
    const noFetch = () => assert.fail('network called');
    await assert.rejects(handler({ data: point }, 'fake', noFetch), { code: 'unauthenticated' });
    await assert.rejects(handler(request({lat: 91,lng: 1}), 'fake', noFetch), { code: 'invalid-argument' });
    await assert.rejects(handler(request({lat: 4,lng: 4}), 'fake', async () => new Response('', {status: 503})), {code: 'unavailable'});
  });
}
test('reverse skips a leading Plus Code result for a readable street', async () => {
  const body = { status: 'OK', results: [
    { formatted_address: 'XW36+H76، عمّان، الأردن', types: ['plus_code'], address_components: [{ long_name: 'XW36+H76', types: ['plus_code'] }] },
    { formatted_address: 'شارع الملك فيصل، عمّان', types: ['route'], address_components: [{ long_name: 'شارع الملك فيصل', types: ['route'] }] },
  ] };
  const fetch = async () => Response.json(body);
  assert.deepEqual(await reverseGeocodeHandler(request({ lat: 31.95391, lng: 35.91061 }), 'fake', fetch),
    { name: 'شارع الملك فيصل', address: 'شارع الملك فيصل، عمّان' });
});
