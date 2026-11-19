// Owner-run only. Uses existing ADC; never creates or writes credentials.
import { createRequire } from 'node:module';
const require = createRequire(new URL('../functions/package.json', import.meta.url));
const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');

const projectId = process.argv[2];
if (!projectId) throw new Error('Usage: node firebase/scripts/configure-auth.mjs <project-id>');
const emulator = !!process.env.FIREBASE_AUTH_EMULATOR_HOST;
initializeApp({ projectId, ...(emulator ? {} : { credential: applicationDefault() }) });
try {
  const config = await getAuth().projectConfigManager().updateProjectConfig({
    smsRegionConfig: { allowlistOnly: { allowedRegions: ['PS', 'JO'] } },
  });
  console.log(JSON.stringify(config.smsRegionConfig, null, 2));
} catch (error) {
  if (emulator) console.error('Auth emulator may not support SMS region configuration. See docs/SECURITY.md.');
  throw error;
}
