import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import vm from 'node:vm';
import { URL } from 'node:url';
test('tracking page parses and invalid token ends without any fetch or external scripts', async () => {
  const html = await readFile(new URL('../../hosting/public/t/index.html', import.meta.url), 'utf8');
  assert.match(html, /lang="ar" dir="rtl"/);
  assert.match(html, /leaflet@1\.9\.4/);
  assert.match(html, /OpenStreetMap/);
  const scripts = [...html.matchAll(/<script(?:\s[^>]*)?>([\s\S]*?)<\/script>/g)].map(m => m[1]).filter(Boolean);
  const elements = new Map();
  for (const source of scripts) {
    const script = new vm.Script(source);
    script.runInNewContext({ location: { pathname: '/t/invalid' }, document: { getElementById: id => {
      if (!elements.has(id)) elements.set(id, {}); return elements.get(id);
    } }, clearTimeout() {}, clearInterval() {}, fetch() { throw Error('No network allowed'); } });
  }
  assert.equal(elements.get('state').textContent, 'انتهى الرابط');
});
