import { suite, matrix } from './helpers.mjs';
const s = suite();
matrix(s, 'stats/2026-11-18', {requested:1,completed:1,revenueFils:5000}, {read:['admin']});
matrix(s, 'stats/promos/SAVE20/2026-11-18', {uses:1}, {read:['admin']});
