import assert from 'node:assert/strict';
import console from 'node:console';
import { setTimeout, clearTimeout } from 'node:timers';
import { randomUUID } from 'node:crypto';
import { HocuspocusProvider } from '@hocuspocus/provider';
import { chromium, expect } from '@playwright/test';
const { fetch, AbortSignal } = globalThis;

const origin = 'https://localhost:18443';
const request = (path, options = {}) =>
  fetch(`${origin}${path}`, {
    ...options,
    signal: AbortSignal.timeout(15000),
  });
for (const path of ['/', '/api/health', '/api/ready', '/collab/health']) {
  const response = await request(path);
  assert.equal(response.status, 200, path);
  assert.ok(response.headers.get('strict-transport-security'));
  assert.equal(response.headers.get('x-frame-options'), 'DENY');
}
const redirect = await fetch('http://localhost:18080/', { redirect: 'manual' });
assert.equal(redirect.status, 308);
assert.ok(redirect.headers.get('location').startsWith('https://'));
const email = `${randomUUID()}@example.org`;
const password = randomUUID();
const registration = await request('/api/auth/register', {
  method: 'POST',
  headers: { 'content-type': 'application/json' },
  body: JSON.stringify({
    email,
    displayName: 'Production test',
    password,
  }),
});
assert.equal(registration.status, 201);
assert.match(registration.headers.get('set-cookie'), /; Secure/i);
assert.match(registration.headers.get('set-cookie'), /; HttpOnly/i);
const { accessToken } = await registration.json();
const headers = { authorization: `Bearer ${accessToken}`, 'content-type': 'application/json' };
const project = await (
  await request('/api/projects', {
    method: 'POST',
    headers,
    body: JSON.stringify({ displayName: 'HTTPS smoke' }),
  })
).json();
assert.ok(project.id);
const board = await (
  await request(`/api/projects/${project.id}/boards`, {
    method: 'POST',
    headers,
    body: JSON.stringify({ displayName: 'WSS smoke' }),
  })
).json();
assert.ok(board.room);
let provider;
try {
  await new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error('WSS sync timed out')), 15000);
    provider = new HocuspocusProvider({
      url: 'wss://localhost:18443/collab',
      name: board.room,
      token: accessToken,
      onSynced: ({ state }) => {
        if (state) {
          clearTimeout(timer);
          resolve();
        }
      },
      onAuthenticationFailed: ({ reason }) => {
        clearTimeout(timer);
        reject(new Error(reason));
      },
    });
  });
} finally {
  provider?.destroy();
}
// TLS was validated above with the local CA. This option is scoped to this
// temporary localhost browser context, never to a real cloud deployment.
const browser = await chromium.launch();
try {
  const context = await browser.newContext({ ignoreHTTPSErrors: true });
  const page = await context.newPage();
  const errors = [];
  page.on('pageerror', (error) => errors.push(error.message));
  await page.goto(`${origin}/entrar`);
  await page.getByTestId('email').fill(email);
  await page.getByTestId('password').fill(password);
  await page.getByTestId('enviar').click();
  await expect(page.getByTestId('lista-proyectos')).toBeVisible();
  await page.goto(`${origin}/pizarras/${board.id}`);
  await expect(page.getByTestId('estado-conexion')).toHaveText('En vivo', { timeout: 20000 });
  // Las herramientas del panel son pestanas (role="tab"), no botones: el mismo
  // localizador que usan las pruebas E2E en e2e/support/actors.ts.
  await page.getByTestId('pestana-importar').click();
  await expect(page.getByTestId('importar-xmi')).toBeEnabled();
  assert.deepEqual(errors, []);
} finally {
  await browser.close();
}
let blocked = false;
for (let i = 0; i < 22; i++) {
  const response = await request('/api/auth/login', {
    method: 'POST',
    headers: { 'content-type': 'application/json', 'x-forwarded-for': `192.0.2.${i}` },
    body: '{}',
  });
  if (response.status === 429) {
    assert.ok(response.headers.get('retry-after'));
    blocked = true;
    break;
  }
}
assert.ok(blocked, 'Spoofed forwarding headers must not bypass authentication limits');
console.warn('HTTPS/WSS, security headers, secure cookies and rate limits verified');
