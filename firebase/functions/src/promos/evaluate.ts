import { currencyFor, type Market } from '../markets.js';
import { minorScale } from '../money.js';
export type PromoReason = 'not-found' | 'inactive' | 'not-started' | 'expired' | 'limit-reached' | 'user-limit' | 'first-ride-only' | 'min-fare' | 'wrong-market';
export interface Promo {
  market?: Market;
  type: 'percent' | 'fixed'; value: number; maxDiscount?: number; minFare?: number;
  firstRideOnly: boolean; usageLimit?: number; perUserLimit?: number; usedCount: number;
  validFrom: { toMillis(): number }; validUntil: { toMillis(): number }; active: boolean;
}
function percentOf(fareFils: bigint, value: number): bigint {
  const [coefficient, exponent = '0'] = value.toString().toLowerCase().split('e');
  const [whole, fraction = ''] = coefficient.split('.');
  const scale = fraction.length - Number(exponent);
  const numerator = BigInt(whole + fraction);
  return scale >= 0 ? fareFils * numerator / (100n * 10n ** BigInt(scale))
    : fareFils * numerator * 10n ** BigInt(-scale) / 100n;
}
export function evaluatePromo(promo: Promo | undefined, context: {
  market?: Market; step?: number; fareJod: number; uid: string; isFirstRide: boolean; userRedemptions: number; now: { toMillis(): number };
}): { ok: true; discountJod: number } | { ok: false; reason: PromoReason } {
  if (!promo) return { ok: false, reason: 'not-found' };
  if ((promo.market ?? 'JO') !== (context.market ?? 'JO')) return { ok: false, reason: 'wrong-market' };
  const scale = minorScale(currencyFor(context.market ?? 'JO'));
  if (!promo.active) return { ok: false, reason: 'inactive' };
  if (context.now.toMillis() < promo.validFrom.toMillis()) return { ok: false, reason: 'not-started' };
  if (context.now.toMillis() > promo.validUntil.toMillis()) return { ok: false, reason: 'expired' };
  if (promo.usageLimit !== undefined && promo.usedCount >= promo.usageLimit) return { ok: false, reason: 'limit-reached' };
  if (context.userRedemptions >= (promo.perUserLimit ?? 1)) return { ok: false, reason: 'user-limit' };
  if (promo.firstRideOnly && !context.isFirstRide) return { ok: false, reason: 'first-ride-only' };
  if (Math.round(context.fareJod * scale) < Math.round((promo.minFare ?? 0) * scale)) return { ok: false, reason: 'min-fare' };
  const fareFils = BigInt(Math.round(context.fareJod * scale));
  // Integer fils and an exact rational percentage avoid floating point boundary errors.
  let discount = promo.type === 'percent'
    ? percentOf(fareFils, promo.value)
    : BigInt(Math.round(promo.value * scale));
  if (promo.type === 'percent' && promo.maxDiscount !== undefined) {
    const cap = BigInt(Math.round(promo.maxDiscount * scale));
    if (discount > cap) discount = cap;
  }
  if (discount > fareFils) discount = fareFils;
  if (discount < 0n) discount = 0n;
  return { ok: true, discountJod: Number(discount / BigInt(context.step ?? 50) * BigInt(context.step ?? 50)) / scale };
}
