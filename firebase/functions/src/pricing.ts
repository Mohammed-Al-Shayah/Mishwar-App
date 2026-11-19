import { decimal, toMinor, minorScale, roundMinor, roundMoney, type Currency } from './money.js';
export interface VehicleRates {
    base: number;
    perKm: number;
    perMin: number;
    minimum: number;
}
export type VehicleType = 'economy' | 'comfort' | 'van';
export type PricingTable = Record<VehicleType, VehicleRates>;
export const DEFAULT_PRICING: PricingTable = {
    economy: { base: 0.50, perKm: 0.30, perMin: 0.05, minimum: 1.50 },
    comfort: { base: 0.80, perKm: 0.45, perMin: 0.07, minimum: 2.50 },
    van: { base: 1.00, perKm: 0.55, perMin: 0.08, minimum: 3.00 },
};
// Palestine rates are placeholders pending owner approval.
export const PS_PRICING: PricingTable = {
 economy: { base: 3, perKm: 1.8, perMin: 0.3, minimum: 10 },
 comfort: { base: 5, perKm: 2.6, perMin: 0.4, minimum: 15 },
 van: { base: 6, perKm: 3.2, perMin: 0.5, minimum: 18 },
};
export function roundFare(value: number, currency: Currency = 'JOD', step = 50): number {
 return roundMoney(value, currency, step);
}
export function computeFare(rates: VehicleRates, distanceMeters: number, durationSeconds: number, currency: Currency = 'JOD', step = 50): number {
 const [distance, ds] = decimal(distanceMeters), [duration, ts] = decimal(durationSeconds);
 const denominator = ds * ts * 1000n * 60n;
 const minor = (v: number) => BigInt(toMinor(v, currency));
 const total = minor(rates.base) * denominator + minor(rates.perKm) * distance * ts * 60n + minor(rates.perMin) * duration * ds * 1000n;
 const minimum = minor(rates.minimum) * denominator;
 const rounded = roundMinor(total > minimum ? total : minimum, denominator, step);
 if (rounded > BigInt(Number.MAX_SAFE_INTEGER)) throw new RangeError('Fare too large.');
 return Number(rounded) / minorScale(currency);
}
export function marketPricing(value: unknown, market: 'PS' | 'JO'): PricingTable {
 if (value === undefined) return market === 'PS' ? PS_PRICING : DEFAULT_PRICING;
 const data = value as Record<string, unknown>;
 return parsePricing(data[market] ?? (market === 'JO' ? data : PS_PRICING), market === 'PS' ? 'ILS' : 'JOD');
}
export function parsePricing(value: unknown, currency: Currency = 'JOD'): PricingTable {
    if (!value || typeof value !== 'object')
        throw new Error('Invalid pricing configuration.');
    const table = value as PricingTable;
    for (const type of ['economy', 'comfort', 'van'] as const) {
        const rates = table[type];
        if (!rates || typeof rates !== 'object')
            throw new Error('Invalid pricing configuration.');
        for (const name of ['base', 'perKm', 'perMin', 'minimum'] as const)
            toMinor(rates[name], currency);
    }
    return table;
}
