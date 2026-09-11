import { afterEach, describe, expect, it, vi } from 'vitest';
import { pedirJson } from '../src/http.js';
import { ProviderContractError, ProviderUnavailableError } from '../src/ports.js';

afterEach(() => vi.unstubAllGlobals());

const options = {
  provider: 'prueba',
  url: 'https://example.invalid',
  init: {},
  timeoutMs: 100,
  maxRetries: 1,
  esperar: async () => undefined,
};

function truncatedResponse(): Response {
  return new Response(
    new ReadableStream({
      start(controller) {
        controller.error(new Error('La conexion se corto al leer el cuerpo'));
      },
    }),
  );
}

describe('transporte de IA', () => {
  it('reintenta si la conexion se corta despues de recibir las cabeceras', async () => {
    const fetchMock = vi
      .fn()
      .mockResolvedValueOnce(truncatedResponse())
      .mockResolvedValueOnce(new Response('{"ok":true}'));
    vi.stubGlobal('fetch', fetchMock);
    await expect(pedirJson(options)).resolves.toEqual({ ok: true });
    expect(fetchMock).toHaveBeenCalledTimes(2);
  });

  it('clasifica un cuerpo interrumpido como indisponibilidad para activar el respaldo', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn(async () => truncatedResponse()),
    );
    await expect(pedirJson(options)).rejects.toBeInstanceOf(ProviderUnavailableError);
  });

  it('un cuerpo completo que no cumple JSON es un error de contrato sin reintento', async () => {
    const fetchMock = vi.fn(async () => new Response('no es JSON'));
    vi.stubGlobal('fetch', fetchMock);
    await expect(pedirJson(options)).rejects.toBeInstanceOf(ProviderContractError);
    expect(fetchMock).toHaveBeenCalledTimes(1);
  });
});
