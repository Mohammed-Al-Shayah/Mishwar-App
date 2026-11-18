import { type Firestore, type Timestamp } from 'firebase-admin/firestore';
import { roundFare } from '../pricing.js';
export const defaultFees = { cancellationFee: { afterSeconds: 120, amount: 0.50 }, waitingFee: { freeMinutes: 3, perMinute: 0.05 } };
export type FeeConfig = typeof defaultFees;
export function parseFees(data: Record<string, unknown> = {}): FeeConfig {
  const section = (key: keyof FeeConfig) => Object.fromEntries(Object.entries(defaultFees[key]).map(([name, fallback]) => {
    const value = (data[key] as Record<string, unknown> | undefined)?.[name];
    return [name, typeof value === 'number' && Number.isFinite(value) && value >= 0 ? value : fallback];
  }));
  return { cancellationFee: section('cancellationFee'), waitingFee: section('waitingFee') } as FeeConfig;
}
export function feeConfigReader(db: Firestore) {
  let cached: Promise<FeeConfig> | undefined;
  return () => cached ??= db.doc('config/app').get().then(s => parseFees(s.data())).catch(error => { cached = undefined; throw error; });
}
interface CancellationRide { status: string; acceptedAt?: Timestamp; offerDistanceMeters?: number | null }
export function cancellationFeeFils(ride: CancellationRide, now: Timestamp, config = defaultFees): number {
  if (!['accepted', 'arriving', 'arrived'].includes(ride.status) || !ride.acceptedAt) return 0;
  const elapsed = now.toMillis() - ride.acceptedAt.toMillis();
  if (elapsed <= config.cancellationFee.afterSeconds * 1000) return 0;
  const distance = ride.offerDistanceMeters;
  const eta = Math.max(5, typeof distance === 'number' && Number.isFinite(distance) ? distance / 400 : 0);
  if (ride.status === 'arriving' && elapsed > 2 * eta * 60000) return 0;
  return Math.round(roundFare(config.cancellationFee.amount) * 1000);
}
export function waitingFeeFils(arrivedAt?: Timestamp, startedAt?: Timestamp, config = defaultFees): number {
  if (!arrivedAt || !startedAt) return 0;
  const minutes = Math.ceil(Math.max(0, (startedAt.toMillis() - arrivedAt.toMillis()) / 60000 - config.waitingFee.freeMinutes));
  return Math.round(roundFare(minutes * Math.round(config.waitingFee.perMinute * 1000) / 1000) * 1000);
}
export function earningsDay(time: Timestamp): string {
  return new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Amman', year: 'numeric', month: '2-digit', day: '2-digit' }).format(time.toDate());
}
