import { HttpsError, onCall, type CallableRequest } from 'firebase-functions/v2/https';
import { distanceBetween } from 'geofire-common';
import { google, type Fetch } from './lib/google.js';
import { authenticated, mapsKey, mapsOptions } from './lib/maps.js';
import { loadAppConfig, readAirport, pointInPolygon } from './lib/appConfig.js';
import * as v from './lib/validate.js';

const cache = new Map<string, { name: string; address: string }>();
export async function reverseGeocodeHandler(request: CallableRequest, key: string, fetchImpl?: Fetch) {
  authenticated(request);
  const data = v.object(request.data), point = v.point(data), lang = v.language(data.lang);
  const cacheKey = `${point.lat.toFixed(5)},${point.lng.toFixed(5)}:${lang}`;
  const cached = cache.get(cacheKey);
  if (cached) return cached;
  const query = new URLSearchParams({ latlng: `${point.lat},${point.lng}`, language: lang, key });
  const response = await google<{ status: string; results?: { formatted_address?: string; address_components?: { long_name: string; types: string[] }[] }[] }>(
    `https://maps.googleapis.com/maps/api/geocode/json?${query}`, {}, fetchImpl);
  if (response.status === 'ZERO_RESULTS') throw new HttpsError('not-found', 'No address found.');
  if (response.status !== 'OK') throw new HttpsError(response.status === 'UNKNOWN_ERROR' || response.status === 'OVER_QUERY_LIMIT' ? 'unavailable' : 'internal', 'Map service request failed.');
  const result = response.results?.[0];
  if (!result?.formatted_address) throw new HttpsError('internal', 'Invalid map response.');
  const components = result.address_components ?? [];
  const component = (type: string) => components.find(c => c.types.includes(type))?.long_name;
  const name = component('point_of_interest') ?? component('premise') ??
    ([component('route'), component('street_number')].filter(Boolean).join(' ') || components[0]?.long_name || result.formatted_address);
  const value = { name, address: result.formatted_address };
  if (cache.size >= 500) cache.delete(cache.keys().next().value!);
  cache.set(cacheKey, value);
  return value;
}
export async function pickupSuggestionsHandler(request: CallableRequest, key: string, fetchImpl?: Fetch, loadConfig = loadAppConfig) {
  authenticated(request);
  const point = v.point(request.data);
  const response = await google<{ places?: { id?: string; displayName?: { text?: string }; location?: { latitude: number; longitude: number } }[] }>(
    'https://places.googleapis.com/v1/places:searchNearby', {
      method: 'POST', headers: { 'Content-Type': 'application/json', 'X-Goog-Api-Key': key, 'X-Goog-FieldMask': 'places.id,places.displayName,places.location' },
      body: JSON.stringify({ includedTypes: ['transit_station', 'parking', 'shopping_mall', 'gas_station'], maxResultCount: 4, rankPreference: 'DISTANCE', languageCode: 'ar', locationRestriction: { circle: { center: { latitude: point.lat, longitude: point.lng }, radius: 150 } } }),
    }, fetchImpl);
  const points = (response.places ?? []).flatMap(p => p.id && p.displayName?.text && p.location && Number.isFinite(p.location.latitude) && Number.isFinite(p.location.longitude)
    ? [{ id: p.id, name: p.displayName.text, lat: p.location.latitude, lng: p.location.longitude }] : []).slice(0, 4);
  const airport = readAirport(await loadConfig());
  if (airport && pointInPolygon(point.lat, point.lng, airport.zone)) points.push(...airport.pickupPoints);
  return [...new Map(points.map(p => [p.id, { ...p, distanceMeters: Math.round(distanceBetween([point.lat, point.lng], [p.lat, p.lng]) * 1000) }])).values()];
}
export const reverseGeocode = onCall(mapsOptions, request => reverseGeocodeHandler(request, mapsKey.value()));
export const pickupSuggestions = onCall(mapsOptions, request => pickupSuggestionsHandler(request, mapsKey.value()));
