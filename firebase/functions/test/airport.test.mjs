/* global Response */
import { test } from 'node:test';
import assert from 'node:assert/strict';
import process from 'node:process';
import { spawn } from 'node:child_process';
import { createServer } from 'node:http';
import { airportDirection, pointInPolygon, readAirport, loadAppConfig } from '../lib/lib/appConfig.js';
import { fareEstimatesHandler } from '../lib/getFareEstimates.js';
import { requestRideHandler } from '../lib/rides/handlers.js';
import { scheduleRideHandler } from '../lib/rides/scheduled.js';
import { updateRideStatusHandler } from '../lib/rides/lifecycle.js';
import { DEFAULT_PRICING } from '../lib/pricing.js';
import { harness, ride, driver, ts } from './ride-fixtures.mjs';

const zone = { type: 'Polygon', coordinates: [[[35.965,31.705],[36.015,31.705],[36.015,31.745],[35.965,31.745],[35.965,31.705]]] };
const airport = { zone, fixedFares: { economy: 12, comfort: 16, van: 20 }, pickupPoints: [{ id: 'gate1', name: 'Gate 1', lat: 31.7226, lng: 35.9932 }] };
const inside = { lat: 31.7226, lng: 35.9932, name: 'Airport', address: 'Arrivals' };
const outside = { lat: 31.95, lng: 35.91, name: 'Amman', address: 'Amman' };
const request = (pickup = outside, dropoff = inside, extra = {}) => ({ auth: { uid: 'rider' }, data: { pickup, dropoff, vehicleType: 'economy', paymentMethod: 'cash', ...extra } });
const fetchRoute = async () => Response.json({ routes: [{ distanceMeters: 90000, duration: '9000s', polyline: { encodedPolyline: 'abc' } }] });
const estimate = (config = { airport }, pricing = DEFAULT_PRICING) => (req, key) => fareEstimatesHandler(req, key, fetchRoute, async () => pricing, async () => config);

test('ray casting: closed/unclosed ring, vertices, edges, outside and concave polygon', () => {
  for (const ring of [zone.coordinates[0], zone.coordinates[0].slice(0, -1)]) {
    const polygon = { type: 'Polygon', coordinates: [ring] };
    for (const [lat, lng] of [[31.7226,35.9932],[31.705,35.965],[31.745,36.015],[31.725,35.965],[31.705,35.99]]) assert.equal(pointInPolygon(lat, lng, polygon), true);
    for (const [lat, lng] of [[31.7,35.99],[31.75,35.99],[31.725,36.02],[31.725,35.96]]) assert.equal(pointInPolygon(lat, lng, polygon), false);
  }
  const concave = { type: 'Polygon', coordinates: [[[0,0],[4,0],[4,4],[2,2],[0,4],[0,0]]] };
  assert.equal(pointInPolygon(3,2,concave), false);
  assert.equal(pointInPolygon(1,2,concave), true);
  assert.equal(pointInPolygon(NaN,2,concave), false);
});

test('shared config reader has no airport defaults, validates geometry/fares and retains pickup points', async () => {
  assert.equal(readAirport(), undefined);
  assert.equal(readAirport({ airport: { fixedFares: airport.fixedFares } }), undefined);
  assert.deepEqual(readAirport({ airport }), airport);
  assert.deepEqual(readAirport({ airport: { ...airport, zone: JSON.stringify(zone) } }), airport);
  assert.throws(() => readAirport({ airport: { ...airport, fixedFares: {} } }));
  assert.throws(() => readAirport({ airport: { ...airport, zone: { type: 'Point', coordinates: [] } } }));
  assert.deepEqual(await loadAppConfig(harness({ 'config/app': { airport } }).db), { airport });
});

for (const [pickup, dropoff, direction] of [[outside,inside,'to_airport'],[inside,outside,'from_airport'],[inside,inside,undefined],[outside,outside,undefined]]) {
  test('estimates and persisted requests: ' + (direction ?? (pickup === inside ? 'both inside' : 'neither inside')), async () => {
    assert.equal(airportDirection(airport, pickup, dropoff), direction);
    const req = request(pickup, dropoff);
    const quotes = await estimate()({ ...req, data: { origin: pickup, destination: dropoff } }, 'fake');
    assert.equal(quotes.airport?.direction, direction);
    if (direction) assert.deepEqual(quotes.fares.map(f => f.amount), [12,16,20]);
    else assert.ok(quotes.fares[0].amount > 12);
    for (const vehicleType of ['economy','comfort','van']) {
      const h = harness({ 'rides/x': ride({ status: 'completed' }), 'users/rider': { role: 'rider' } });
      const result = await requestRideHandler(request(pickup, dropoff, { vehicleType, ...(direction ? { flightNumber: ' rj 182 ' } : {}) }), h.db, 'fake', estimate());
      const saved = h.db.records.get('rides/' + result.rideId);
      assert.equal(saved.airport?.direction, direction);
      if (direction) {
        assert.equal(saved.fare.estimated, airport.fixedFares[vehicleType]);
        assert.deepEqual(saved.airport, { direction, flightNumber: 'RJ 182', fixedFare: true });
        assert.equal(saved.serviceType, 'airport');
      } else assert.equal(saved.airport, undefined);
    }
  });
}

test('airport quotes respect each normal minimum and disabled airport uses normal pricing', async () => {
  const req = { auth: { uid: 'rider' }, data: { origin: outside, destination: inside } };
  const pricing = Object.fromEntries(Object.entries(DEFAULT_PRICING).map(([type, rates]) => [type, { ...rates, minimum: 25 }]));
  assert.deepEqual((await estimate({ airport }, pricing)(req, '')).fares.map(f => f.amount), [25,25,25]);
  for (const config of [undefined, {}, { airport: { fixedFares: airport.fixedFares } }]) {
    const result = await fareEstimatesHandler(req, '', fetchRoute, async () => DEFAULT_PRICING, async () => config);
    assert.equal(result.airport, undefined);
    assert.ok(result.fares[0].amount > 12);
  }
});

test('scheduled airport ride preserves metadata; invalid and non-airport flight numbers cannot write rides', async () => {
  const h = harness({ 'users/rider': { role: 'rider' } });
  const result = await scheduleRideHandler(request(inside, outside, { scheduledFor: 3600000, flightNumber: 'rj182' }), h.db, '', undefined, estimate(), () => ts(0));
  const saved = h.db.records.get('rides/' + result.rideId);
  assert.equal(saved.status, 'scheduled');
  assert.deepEqual(saved.airport, { direction: 'from_airport', flightNumber: 'RJ182', fixedFare: true });
  for (const flightNumber of ['RJ','RJ 12345','RJ  182','R!182',123,'']) {
    await assert.rejects(requestRideHandler(request(outside, inside, { flightNumber }), h.db, '', estimate()), { code: 'invalid-argument' });
  }
  await assert.rejects(requestRideHandler(request(outside, outside, { flightNumber: 'RJ182' }), h.db, '', estimate()), { code: 'invalid-argument' });
});

test('completion locks quoted airport fare despite travel time/config changes; promo excludes waiting and previous balance', async () => {
  const h = harness({ 'rides/x': ride({ status: 'in_progress', driverId: 'a', arrivedAt: ts(0), startedAt: ts(241000), route: { distanceMeters: 90000 }, fare: { estimated: 12, currency: 'JOD' }, airport: { direction: 'to_airport', fixedFare: true }, promo: { code: 'HALF' } }),
    'drivers/a': driver(0, { currentRideId: 'x' }), 'users/rider': { activeRideId: 'x', balanceDueFils: 500 },
    'config/app': { airport: { ...airport, fixedFares: { economy: 50, comfort: 50, van: 50 } } },
    'promos/HALF': { type: 'percent', value: 50, maxDiscount: 10, firstRideOnly: false, usedCount: 0, usageLimit: 100, active: true, validFrom: ts(0), validUntil: ts(99999999) } });
  h.setTime(3600000);
  const req = { auth: { uid: 'a' }, data: { rideId: 'x', status: 'completed' } };
  await updateRideStatusHandler(req, h.db, h.deps.now);
  await updateRideStatusHandler(req, h.db, h.deps.now);
  const fare = h.db.records.get('rides/x').fare;
  assert.equal(fare.discount, 6);
  assert.equal(fare.waitingFee, 0.1);
  assert.equal(fare.previousBalance, 0.5);
  assert.equal(fare.final, 6.6);
  assert.equal(h.db.records.get('promos/HALF').usedCount, 1);
});

test('fixed quote completes unchanged without promo despite long travel time', async () => {
  const h = harness({ 'rides/x': ride({ status: 'in_progress', driverId: 'a', startedAt: ts(0), route: { distanceMeters: 90000 }, fare: { estimated: 16 }, airport: { direction: 'from_airport', fixedFare: true } }),
    'drivers/a': driver(0, { currentRideId: 'x' }) });
  h.setTime(3600000);
  await updateRideStatusHandler({ auth: { uid: 'a' }, data: { rideId: 'x', status: 'completed' } }, h.db, h.deps.now);
  assert.equal(h.db.records.get('rides/x').fare.final, 16);
});

test('airport seed enables service and writes serializable geometry, JOD fares and named arrivals points', async () => {
  const writes = [];
  const server = createServer(async (req, res) => {
    let body = '';
    for await (const chunk of req) body += chunk;
    writes.push({ url: req.url, body: JSON.parse(body), auth: req.headers.authorization });
    res.writeHead(200, { 'Content-Type': 'application/json' }); res.end('{}');
  });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  try {
    const child = spawn(process.execPath, ['../seed/seed_app_config.mjs', 'demo-mishwar'], {
      env: { ...process.env, FIRESTORE_EMULATOR_HOST: '127.0.0.1:' + server.address().port }, stdio: 'pipe',
    });
    let errors = '';
    child.stderr.on('data', chunk => { errors += chunk; });
    const code = await new Promise((resolve, reject) => { child.on('error', reject); child.on('exit', resolve); });
    assert.equal(code, 0, errors);
    const services = writes.find(w => w.url.includes('fieldPaths=services')).body.fields.services.arrayValue.values;
    assert.equal(services.find(s => s.mapValue.fields.id.stringValue === 'airport').mapValue.fields.enabled.booleanValue, true);
    const airportWrite = writes.find(w => w.url.includes('fieldPaths=airport'));
    assert.equal(airportWrite.auth, 'Bearer owner');
    const fields = airportWrite.body.fields.airport.mapValue.fields;
    assert.deepEqual(JSON.parse(fields.zone.stringValue), zone);
    assert.deepEqual(Object.values(fields.fixedFares.mapValue.fields).map(f => f.doubleValue), [12,16,20]);
    const points = fields.pickupPoints.arrayValue.values.map(p => p.mapValue.fields);
    assert.equal(points.length, 2);
    assert.equal(points[0].name.stringValue, 'صالة القادمين - بوابة 1');
    assert.equal(points[1].name.stringValue, 'صالة القادمين - بوابة 3');
    for (const p of points) assert.equal(pointInPolygon(p.lat.doubleValue, p.lng.doubleValue, zone), true);
  } finally { await new Promise(resolve => server.close(resolve)); }
});
