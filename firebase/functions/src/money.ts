export type Currency = 'JOD' | 'ILS';
export const minorScale = (currency: Currency): number => currency === 'ILS' ? 100 : 1000;
export const defaultStep = (currency: Currency): number => currency === 'ILS' ? 50 : 50;
export function decimal(value: number): [bigint, bigint] {
  if (!Number.isFinite(value) || value < 0) throw new RangeError('Expected nonnegative finite money.');
  const [coefficient, exponent = '0'] = value.toString().toLowerCase().split('e');
  const [whole, fraction = ''] = coefficient.split('.');
  const scale = fraction.length - Number(exponent), numerator = BigInt(whole + fraction);
  return scale >= 0 ? [numerator, 10n ** BigInt(scale)] : [numerator * 10n ** BigInt(-scale), 1n];
}
export function toMinor(value: number, currency: Currency): number {
  const [n, d] = decimal(value), scaled = n * BigInt(minorScale(currency));
  if (scaled % d !== 0n || scaled / d > BigInt(Number.MAX_SAFE_INTEGER)) throw new RangeError('Invalid minor units.');
  return Number(scaled / d);
}
export function roundMinor(numerator: bigint, denominator: bigint, step: number): bigint {
  if (!Number.isSafeInteger(step) || step <= 0) throw new RangeError('Invalid rounding step.');
  const s = BigInt(step);
  return (2n * numerator + s * denominator) / (2n * s * denominator) * s;
}
export function roundMoney(value: number, currency: Currency, step = defaultStep(currency)): number {
  const [n, d] = decimal(value);
  return Number(roundMinor(n * BigInt(minorScale(currency)), d, step)) / minorScale(currency);
}
export function formatMoney(minor: number, currency: Currency): string {
  if (!Number.isSafeInteger(minor) || minor < 0) throw new RangeError('Invalid minor units.');
  const cents = currency === 'JOD' ? Math.floor((minor + 5) / 10) : minor;
  return `${currency === 'ILS' ? '₪' : 'JD'} ${Math.floor(cents / 100)}.${String(cents % 100).padStart(2, '0')}`;
}
