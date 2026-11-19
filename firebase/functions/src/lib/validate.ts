import { HttpsError } from 'firebase-functions/v2/https';
export function invalid(): never { throw new HttpsError('invalid-argument', 'Invalid request parameters.'); }
export function object(value: unknown): Record<string, unknown> {
    if (!value || typeof value !== 'object' || Array.isArray(value))
        invalid();
    return value as Record<string, unknown>;
}
export function string(value: unknown, min: number, max: number): string {
    if (typeof value !== 'string')
        return invalid();
    const result = value.trim();
    if (result.length < min || result.length > max)
        return invalid();
    return result;
}
export function sessionToken(value: unknown): string {
    const token = string(value, 8, 64);
    if (!/^[a-zA-Z0-9-]+$/.test(token))
        return invalid();
    return token;
}
export function language(value: unknown): 'ar' | 'en' {
    if (value === undefined)
        return 'ar';
    if (value !== 'ar' && value !== 'en')
        return invalid();
    return value;
}
export function coordinate(value: unknown, limit: number): number {
    if (typeof value !== 'number' || !Number.isFinite(value) || Math.abs(value) > limit)
        return invalid();
    return value;
}
export function point(value: unknown): {
    lat: number;
    lng: number;
} {
    const data = object(value);
    return { lat: coordinate(data.lat, 90), lng: coordinate(data.lng, 180) };
}

export function mobilePhone(value: unknown): string {
 const phone = string(value, 13, 13);
 if (!/^\+(9627[789]|9705[69])[0-9]{7}$/.test(phone)) invalid();
 return phone;
}
