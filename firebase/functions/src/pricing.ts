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
// Convert the decimal representation to a rational before any arithmetic.
// This preserves exact half-up ties (including fractional route durations).
function decimal(value: number): [
    bigint,
    bigint
] {
    if (!Number.isFinite(value) || value < 0)
        throw new RangeError('Expected a finite nonnegative number.');
    const [coefficient, exponent = '0'] = value.toString().toLowerCase().split('e');
    const [whole, fraction = ''] = coefficient.split('.');
    const scale = fraction.length - Number(exponent);
    const numerator = BigInt(whole + fraction);
    return scale >= 0 ? [numerator, 10n ** BigInt(scale)] : [numerator * 10n ** BigInt(-scale), 1n];
}
function fils(value: number): bigint {
    const [n, d] = decimal(value);
    if (n * 1000n % d !== 0n)
        throw new RangeError('Rates must use whole fils.');
    return n * 1000n / d;
}
// Exact half-up rounding to the nearest 0.05 JOD, also used after fare caps.
function roundFils(numerator: bigint, denominator: bigint): bigint {
    return ((numerator * 2n + 50n * denominator) / (100n * denominator)) * 50n;
}
export function roundFare(value: number): number {
    const [n, d] = decimal(value);
    return Number(roundFils(n * 1000n, d)) / 1000;
}
export function computeFare(rates: VehicleRates, distanceMeters: number, durationSeconds: number): number {
    const [distance, distanceScale] = decimal(distanceMeters);
    const [duration, durationScale] = decimal(durationSeconds);
    const denominator = distanceScale * durationScale * 1000n * 60n;
    const total = fils(rates.base) * denominator
        + fils(rates.perKm) * distance * durationScale * 60n
        + fils(rates.perMin) * duration * distanceScale * 1000n;
    const minimum = fils(rates.minimum) * denominator;
    const fare = total > minimum ? total : minimum;
    const roundedFils = roundFils(fare, denominator);
    const result = Number(roundedFils) / 1000;
    if (!Number.isFinite(result) || roundedFils > BigInt(Number.MAX_SAFE_INTEGER))
        throw new RangeError('Fare is too large.');
    return Number(result.toFixed(2));
}
export function parsePricing(value: unknown): PricingTable {
    if (!value || typeof value !== 'object')
        throw new Error('Invalid pricing configuration.');
    const table = value as PricingTable;
    for (const type of ['economy', 'comfort', 'van'] as const) {
        const rates = table[type];
        if (!rates || typeof rates !== 'object')
            throw new Error('Invalid pricing configuration.');
        for (const name of ['base', 'perKm', 'perMin', 'minimum'] as const)
            fils(rates[name]);
    }
    return table;
}
