// Run against the Cloud Tasks emulator only; does not load Functions or secrets.
import assert from 'node:assert/strict';
import { createServer } from 'node:http';
import { createRequire } from 'node:module';

const require = createRequire(new URL('../functions/package.json', import.meta.url));
const { initializeApp, deleteApp } = require('firebase-admin/app');
const { getFunctions } = require('firebase-admin/functions');
process.env.CLOUD_TASKS_EMULATOR_HOST = '127.0.0.1:9499';
const app = initializeApp({ projectId: 'demo-mishwar', serviceAccountId: 'probe@demo-mishwar.iam.gserviceaccount.com' });
const queue = `offerTimeoutProbe-${Date.now()}`;
let resolveTask;
const received = new Promise((resolve) => { resolveTask = resolve; });
const server = createServer(async (req, res) => {
  let body = '';
  for await (const chunk of req) body += chunk;
  res.writeHead(200).end('{}');
  resolveTask({ body: JSON.parse(body), eta: req.headers['x-cloudtasks-tasketa'] });
});
await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
let timeout;
try {
  // Isolated queue and loopback receiver leave the app's offerTimeout queue alone.
  const response = await fetch(`http://127.0.0.1:9499/projects/demo-mishwar/locations/europe-west1/queues/${queue}`, {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ defaultUri: `http://127.0.0.1:${server.address().port}`,
      retryConfig: { maxAttempts: 3, minBackoffSeconds: 5 } }),
  });
  assert.equal(response.status, 200);
  const started = Date.now();
  await getFunctions(app).taskQueue(`locations/europe-west1/functions/${queue}`)
    .enqueue({ rideId: 'probe', seq: 1 }, { scheduleDelaySeconds: 16 });
  const result = await Promise.race([received, new Promise((_, reject) => {
    timeout = setTimeout(() => reject(Error('Task delivery timed out')), 30000);
  })]);
  assert.deepEqual(result.body, { data: { rideId: 'probe', seq: 1 } });
  assert(Date.parse(result.eta) >= started + 15000, 'SDK must send a 16-second schedule');
  console.log(`PASS: Tasks emulator :9499 delivered offer payload with 16-second ETA (elapsed ${Date.now() - started}ms)`);
} finally {
  clearTimeout(timeout);
  await new Promise((resolve) => server.close(resolve));
  await deleteApp(app);
}
