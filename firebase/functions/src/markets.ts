import { HttpsError } from 'firebase-functions/v2/https';
import { pointInPolygon, type Polygon, type MultiPolygon } from './lib/appConfig.js';
import { type Currency, toMinor } from './money.js';

export type Market = 'PS' | 'JO';
export const currencyFor = (market: Market): Currency => market === 'PS' ? 'ILS' : 'JOD';
export function homeMarket(phone: string): Market {
  if (phone.startsWith('+970')) return 'PS';
  if (phone.startsWith('+962')) return 'JO';
  throw new RangeError('Unsupported phone country.');
}
export function marketCode(value: unknown): Market {
  if (value !== 'PS' && value !== 'JO') throw new HttpsError('invalid-argument', 'Invalid market.');
  return value;
}
// Approximate service outlines, not legal boundaries. Owner must review before launch.
const ring = (points: number[][]): number[][] => [...points, points[0]];
const westBank = ring([[35.01,31.37],[34.93,31.49],[34.97,31.64],[35.04,31.74],[35.02,31.87],[34.96,32.02],[35.02,32.13],[35.02,32.26],[35.08,32.35],[35.05,32.47],[35.17,32.55],[35.28,32.55],[35.4,32.5],[35.52,32.42],[35.56,32.29],[35.56,32.13],[35.55,31.99],[35.54,31.85],[35.51,31.73],[35.47,31.57],[35.41,31.45],[35.27,31.36],[35.14,31.35]]);
const gaza = ring([[34.22,31.32],[34.26,31.39],[34.32,31.48],[34.4,31.56],[34.49,31.6],[34.56,31.54],[34.51,31.47],[34.47,31.4],[34.4,31.34],[34.34,31.27],[34.27,31.22]]);
const jordan = ring([[35.0,29.35],[34.96,29.5],[35.0,29.65],[35.04,29.87],[35.15,30.1],[35.23,30.35],[35.35,30.6],[35.42,30.85],[35.45,31.1],[35.48,31.35],[35.54,31.6],[35.57,31.8],[35.58,32.0],[35.59,32.2],[35.58,32.4],[35.64,32.56],[35.72,32.68],[35.85,32.7],[36.05,32.52],[36.3,32.4],[36.84,32.32],[38.79,33.37],[39.3,32.22],[39.2,32.15],[38.0,31.5],[37.1,31.5],[37.0,31.3],[37.98,30.5],[37.5,30.0],[36.75,29.86],[36.07,29.18],[35.5,29.18],[35.0,29.19]]);
export const DEFAULT_MARKETS = {
  PS: { zone: JSON.stringify({ type: 'MultiPolygon', coordinates: [[westBank], [gaza]] }), currency: 'ILS' },
  JO: { zone: JSON.stringify({ type: 'Polygon', coordinates: [jordan] }), currency: 'JOD' },
};
export function findMarket(point: { lat: number; lng: number }, app?: Record<string, unknown>): Market | undefined {
  const markets = (app?.markets ?? DEFAULT_MARKETS) as Record<Market, { zone: string; currency: Currency }>;
  for (const market of ['PS', 'JO'] as const) {
    const config = markets[market];
    if (!config || config.currency !== currencyFor(market)) throw new Error('Invalid market configuration.');
    const zone = JSON.parse(config.zone) as Polygon | MultiPolygon;
    if (pointInPolygon(point.lat, point.lng, zone)) return market;
  }
  return undefined;
}
export function resolveMarket(point: { lat: number; lng: number }, app?: Record<string, unknown>): Market {
  const market = findMarket(point, app);
  if (!market) throw new HttpsError('failed-precondition', 'هاد المكان برا منطقة الخدمة', { reason: 'out-of-service-area' });
  return market;
}
export function roundingStep(app: Record<string, unknown> | undefined, market: Market): number {
  const rounding = app?.rounding as Partial<Record<Market, number>> | undefined;
  return toMinor(rounding?.[market] ?? (market === 'PS' ? 0.5 : 0.05), currencyFor(market));
}
