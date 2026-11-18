import { suite, matrix, now } from './helpers.mjs';
const s = suite();
matrix(s, 'promos/WELCOME50', {active:true,usedCount:0}, {read:['admin']});
matrix(s, 'promos/WELCOME50/redemptions/owner', {count:1,lastRideId:'trip',updatedAt:now}, {read:['admin']});
matrix(s, 'users/owner/meta/promoChecks', {count:1,windowStart:now}, {});
