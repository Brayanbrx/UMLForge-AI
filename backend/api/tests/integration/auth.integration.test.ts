import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { startHarness, type Harness } from '../support/harness.js';

/** RF-A01 a RF-A03: registro, inicio y cierre de sesion, y renovacion. */
describe('sesion', () => {
  let api: Harness;

  beforeAll(async () => {
    api = await startHarness();
  }, 180_000);

  afterAll(async () => {
    await api?.stop();
  });

  it('RF-A01 — registra una cuenta y devuelve token y cookie de refresco', async () => {
    const respuesta = await api.request('POST', '/auth/register', {
      body: { email: 'ana@example.com', displayName: 'Ana', password: 'contrasena-larga' },
    });

    expect(respuesta.status).toBe(201);
    expect(respuesta.body.user).toMatchObject({ email: 'ana@example.com', displayName: 'Ana' });
    expect(typeof respuesta.body.accessToken).toBe('string');

    const cookie = respuesta.cookies.find((item) => item.name === 'uml_refresh');
    expect(cookie).toBeDefined();
  });

  it('nunca devuelve el hash de la contrasena', async () => {
    const respuesta = await api.request('POST', '/auth/register', {
      body: { email: 'sinhash@example.com', displayName: 'Sin Hash', password: 'contrasena-larga' },
    });

    expect(JSON.stringify(respuesta.body)).not.toMatch(/passwordHash|scrypt/);
  });

  it('rechaza un correo ya registrado', async () => {
    const respuesta = await api.request('POST', '/auth/register', {
      body: { email: 'ana@example.com', displayName: 'Otra Ana', password: 'contrasena-larga' },
    });

    expect(respuesta.status).toBe(409);
    expect(respuesta.body.error.code).toBe('email_taken');
  });

  it('conserva el 409 si dos registros del mismo correo llegan juntos', async () => {
    const body = {
      email: 'registro-simultaneo@example.com',
      displayName: 'Registro simultaneo',
      password: 'contrasena-larga',
    };

    const respuestas = await Promise.all([
      api.request('POST', '/auth/register', { body }),
      api.request('POST', '/auth/register', { body }),
    ]);

    expect(respuestas.map(({ status }) => status).sort()).toEqual([201, 409]);
    expect(respuestas.find(({ status }) => status === 409)?.body.error.code).toBe('email_taken');
  });

  it('normaliza el correo a minusculas', async () => {
    const respuesta = await api.request('POST', '/auth/login', {
      body: { email: 'ANA@Example.com', password: 'contrasena-larga' },
    });

    expect(respuesta.status).toBe(200);
  });

  it('RF-A02 — inicia sesion con credenciales correctas', async () => {
    const respuesta = await api.request('POST', '/auth/login', {
      body: { email: 'ana@example.com', password: 'contrasena-larga' },
    });

    expect(respuesta.status).toBe(200);
    expect(typeof respuesta.body.accessToken).toBe('string');
  });

  it('rechaza la contrasena incorrecta sin decir si el correo existe', async () => {
    const conCorreoReal = await api.request('POST', '/auth/login', {
      body: { email: 'ana@example.com', password: 'contrasena-equivocada' },
    });
    const conCorreoInventado = await api.request('POST', '/auth/login', {
      body: { email: 'nadie@example.com', password: 'contrasena-equivocada' },
    });

    expect(conCorreoReal.status).toBe(401);
    expect(conCorreoInventado.status).toBe(401);
    // El mismo mensaje en los dos casos: distinguirlos convierte el inicio de
    // sesion en un comprobador de correos registrados.
    expect(conCorreoReal.body.error.message).toBe(conCorreoInventado.body.error.message);
  });

  it('rechaza una contrasena demasiado corta', async () => {
    const respuesta = await api.request('POST', '/auth/register', {
      body: { email: 'corta@example.com', displayName: 'Corta', password: 'abc' },
    });

    expect(respuesta.status).toBe(400);
    expect(respuesta.body.error.code).toBe('validation_failed');
  });

  it('RF-A03 — renueva la sesion y rota el token de refresco', async () => {
    const registro = await api.request('POST', '/auth/register', {
      body: { email: 'rota@example.com', displayName: 'Rota', password: 'contrasena-larga' },
    });
    const primera = registro.cookies.find((item) => item.name === 'uml_refresh');
    const cookieInicial = `uml_refresh=${primera?.value ?? ''}`;

    const renovacion = await api.request('POST', '/auth/refresh', { cookie: cookieInicial });
    expect(renovacion.status).toBe(200);

    const segunda = renovacion.cookies.find((item) => item.name === 'uml_refresh');
    expect(segunda?.value).not.toBe(primera?.value);

    // Reutilizar el token ya rotado no funciona.
    const reutilizacion = await api.request('POST', '/auth/refresh', { cookie: cookieInicial });
    expect(reutilizacion.status).toBe(401);
  });

  it('un token de refresco solo puede consumirse una vez aunque lleguen dos peticiones juntas', async () => {
    const sesion = await api.signUp('carrera-refresh@example.com');

    const respuestas = await Promise.all([
      api.request('POST', '/auth/refresh', { cookie: sesion.cookie }),
      api.request('POST', '/auth/refresh', { cookie: sesion.cookie }),
    ]);

    expect(respuestas.map(({ status }) => status).sort()).toEqual([200, 401]);
  });

  it('cerrar sesion revoca el token de refresco', async () => {
    const sesion = await api.signUp('cierra@example.com');

    const cierre = await api.request('POST', '/auth/logout', { cookie: sesion.cookie });
    expect(cierre.status).toBe(204);

    const renovacion = await api.request('POST', '/auth/refresh', { cookie: sesion.cookie });
    expect(renovacion.status).toBe(401);
  });

  it('protege las rutas que necesitan sesion', async () => {
    expect((await api.request('GET', '/auth/me')).status).toBe(401);
    expect((await api.request('GET', '/auth/me', { token: 'no-es-un-token' })).status).toBe(401);
    expect((await api.request('GET', '/projects')).status).toBe(401);
  });

  it('devuelve el perfil con un token valido', async () => {
    const sesion = await api.signUp('perfil@example.com');
    const respuesta = await api.request('GET', '/auth/me', { token: sesion.token });

    expect(respuesta.status).toBe(200);
    expect(respuesta.body).toMatchObject({ id: sesion.userId, email: 'perfil@example.com' });
  });
});
