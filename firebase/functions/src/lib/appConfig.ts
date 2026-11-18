import { getFirestore, type Firestore } from 'firebase-admin/firestore';
import { type VehicleType } from '../pricing.js';

export interface Polygon { type: 'Polygon'; coordinates: number[][][] }
export interface AirportConfig {
  zone: Polygon;
  fixedFares: Record<VehicleType, number>;
  pickupPoints: { id: string; name: string; lat: number; lng: number }[];
}
export async function loadAppConfig(db: Firestore = getFirestore()): Promise<Record<string, unknown> | undefined> {
  return (await db.doc('config/app').get()).data();
}
export function readAirport(data?: Record<string, unknown>): AirportConfig | undefined {
  const raw = data?.airport as (Omit<AirportConfig, 'zone'> & { zone?: Polygon | string }) | undefined;
  if (!raw?.zone) return undefined;
  // Firestore rejects nested arrays, so persistence uses serialized GeoJSON.
  const airport = { ...raw, zone: typeof raw.zone === 'string' ? JSON.parse(raw.zone) as Polygon : raw.zone };
  if (!airport?.zone) return undefined;
  const { zone, fixedFares } = airport;
  if (zone.type !== 'Polygon' || !Array.isArray(zone.coordinates) || !zone.coordinates.length ||
      zone.coordinates.some(ring => !Array.isArray(ring) || ring.length < 4 ||
        ring.some(p => !Array.isArray(p) || p.length !== 2 || !Number.isFinite(p[0]) || !Number.isFinite(p[1]) || Math.abs(p[0]) > 180 || Math.abs(p[1]) > 90) ||
        ring[0][0] !== ring.at(-1)![0] || ring[0][1] !== ring.at(-1)![1])) throw new Error('Invalid airport zone.');
  for (const type of ['economy', 'comfort', 'van'] as const) {
    const fare = fixedFares?.[type];
    if (!Number.isFinite(fare) || fare < 0 || !Number.isSafeInteger(Math.round(fare * 1000))) throw new Error('Invalid airport fare.');
  }
  return { zone, fixedFares, pickupPoints: airport.pickupPoints ?? [] };
}
// GeoJSON positions are [longitude, latitude]. Boundaries count as inside.
// Intended for simple rings that do not cross the antimeridian; holes are supported.
export function pointInPolygon(lat: number, lng: number, polygon: Polygon): boolean {
  const ringContains = (ring: number[][]): boolean => {
    let inside = false;
    for (let i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      const [x, y] = ring[i], [px, py] = ring[j];
      const cross = (lng - x) * (py - y) - (lat - y) * (px - x);
      if (Math.abs(cross) < 1e-12 && lng >= Math.min(x, px) && lng <= Math.max(x, px) && lat >= Math.min(y, py) && lat <= Math.max(y, py)) return true;
      if ((y > lat) !== (py > lat) && lng < (px - x) * (lat - y) / (py - y) + x) inside = !inside;
    }
    return inside;
  };
  return Number.isFinite(lat) && Number.isFinite(lng) && ringContains(polygon.coordinates[0]) && !polygon.coordinates.slice(1).some(ringContains);
}
export function airportDirection(config: AirportConfig | undefined, pickup: { lat: number; lng: number }, dropoff: { lat: number; lng: number }) {
  if (!config) return undefined;
  const from = pointInPolygon(pickup.lat, pickup.lng, config.zone), to = pointInPolygon(dropoff.lat, dropoff.lng, config.zone);
  return from === to ? undefined : from ? 'from_airport' as const : 'to_airport' as const;
}
