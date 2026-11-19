import { isIP } from 'node:net';

/** Canonicalize IPv6 spellings and mapped IPv4 before hashing. */
export function getIPV6Address(ip: string | undefined): string | undefined {
  if (!ip || !isIP(ip)) return undefined;
  if (isIP(ip) === 4) return ip;
  const normalized = new URL(`http://[${ip}]/`).hostname.slice(1, -1);
  if (normalized.startsWith('::ffff:')) {
    const parts = normalized.slice(7).split(':');
    if (parts.length === 2) {
      const high = parseInt(parts[0], 16), low = parseInt(parts[1], 16);
      return `${high >> 8}.${high & 255}.${low >> 8}.${low & 255}`;
    }
  }
  return normalized;
}
