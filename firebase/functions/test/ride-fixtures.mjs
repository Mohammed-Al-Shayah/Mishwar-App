import { GeoPoint, Timestamp } from 'firebase-admin/firestore';
import { geohashForLocation } from 'geofire-common';
import { FakeFirestore } from './fake-firestore.mjs';
export const ts = (ms) => Timestamp.fromMillis(ms);
export const ride = (extra = {}) => ({ riderId: 'rider', driverId: null, status: 'searching',
  vehicleType: 'economy', pickup: { geopoint: new GeoPoint(31.9539, 35.9106) },
  createdAt: ts(0), searchExpiresAt: ts(120000), offerSeq: 0, offeredTo: null,
  offerExpiresAt: null, declinedBy: [], ...extra });
export const driver = (offset = 0, extra = {}) => {
  const lat = 31.9539 + offset, lng = 35.9106;
  return { isOnline: true, status: 'approved', vehicle: { type: 'economy' }, currentRideId: null,
    offer: null, lastSeenAt: ts(1000), location: { geopoint: new GeoPoint(lat, lng),
      geohash: geohashForLocation([lat, lng]) }, ...extra };
};
export const harness = (seed = {}) => {
  let time = 1000;
  const tasks = [], notifications = [];
  return { db: new FakeFirestore({ 'rides/x': ride(), ...seed }), tasks, notifications,
    setTime: (ms) => { time = ms; }, deps: { now: () => ts(time),
      enqueue: async (data, delay) => { tasks.push({ data, delay }); },
      notify: async (uid, rideId) => { notifications.push({ uid, rideId }); } } };
};

