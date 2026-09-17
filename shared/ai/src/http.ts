import { ProviderContractError, ProviderUnavailableError } from './ports.js';

/**
 * Transporte HTTP comun a los adaptadores que no traen SDK propio.
 *
 * Existe por una razon concreta: la politica de tiempo limite, reintentos y
 * clasificacion de errores **no puede vivir en cada adaptador**. Si vive en
 * cada uno, el cuarto proveedor la implementa distinto, la cadena de respaldo
 * deja de dispararse donde deberia y nadie se entera hasta que falla en vivo.
 *
 * La clasificacion es la parte que importa, porque decide si se cae al respaldo:
 *
 *   | Situacion                        | Error                     | ¿Respaldo? |
 *   | Sin red, tiempo agotado, 5xx, 429| ProviderUnavailableError  | Si         |
 *   | Clave invalida o ausente (401/403)| ProviderContractError    | No         |
 *   | Peticion rechazada (400/404/422) | ProviderContractError     | No         |
 *   | Respuesta que no es JSON         | ProviderContractError     | No         |
 *
 * Una clave mal puesta **no** se disimula cambiando de proveedor: es
 * configuracion, se arregla en un minuto y esconderla significa no enterarse
 * nunca (ADR-015).
 */

export interface PeticionJsonOptions {
  /** Nombre del proveedor, para que el error diga quien fallo. */
  readonly provider: string;
  readonly url: string;
  readonly init: RequestInit;
  readonly timeoutMs: number;
  /** Reintentos **adicionales** al primer intento. 0 significa un solo intento. */
  readonly maxRetries: number;
  /** Cancelacion del llamante. Abortar aqui no reintenta: lo pidio el usuario. */
  readonly signal?: AbortSignal;
  /** Inyectable para que las pruebas no esperen de verdad. */
  readonly esperar?: (ms: number) => Promise<void>;
}

/** Codigos que merecen otro intento: el proveedor esta vivo pero no ahora. */
const REINTENTABLES = new Set([408, 409, 425, 429, 500, 502, 503, 504]);

const ESPERA_BASE_MS = 250;
const ESPERA_MAXIMA_MS = 4_000;

export async function pedirJson<T>(options: PeticionJsonOptions): Promise<T> {
  const esperar = options.esperar ?? ((ms) => new Promise((listo) => setTimeout(listo, ms)));
  let ultimo: unknown;

  for (let intento = 0; intento <= options.maxRetries; intento += 1) {
    if (intento > 0) {
      // Espera creciente y acotada. Sin tope, el tercer reintento tarda mas que
      // la paciencia de quien esta mirando la pantalla.
      await esperar(Math.min(ESPERA_BASE_MS * 2 ** (intento - 1), ESPERA_MAXIMA_MS));
    }

    let respuesta: Response;
    let cuerpo: string;
    const plazo = senal(options.timeoutMs, options.signal);
    try {
      respuesta = await fetch(options.url, { ...options.init, signal: plazo.signal });
      // fetch resuelve al recibir las cabeceras. El cuerpo aun puede cortarse
      // o agotar el plazo: tambien debe activar el reintento y el respaldo.
      cuerpo = await respuesta.text();
    } catch (error) {
      // Si aborto el llamante, no es un fallo del proveedor y no se reintenta.
      if (options.signal?.aborted === true) throw error;
      ultimo = error;
      continue;
    } finally {
      plazo.liberar();
    }

    if (respuesta.ok) {
      try {
        return JSON.parse(cuerpo) as T;
      } catch (error) {
        throw new ProviderContractError(
          options.provider,
          'La respuesta del proveedor no era JSON.',
          { raw: recortar(cuerpo), cause: error },
        );
      }
    }

    const detalle = recortar(cuerpo);

    // Repetir una cuota agotada solo consume latencia y solicitudes.
    if (respuesta.status === 402 || respuesta.status === 429) {
      const header = respuesta.headers.get('retry-after');
      const seconds = header === null ? NaN : Number(header);
      const delay = Number.isFinite(seconds)
        ? seconds * 1000
        : header === null
          ? NaN
          : Date.parse(header) - Date.now();
      throw new ProviderUnavailableError(
        options.provider,
        `${options.provider}: cuota o saldo no disponible (HTTP ${respuesta.status}).`,
        {
          quota: true,
          ...(Number.isFinite(delay) ? { retryAfterMs: Math.max(0, delay) } : {}),
        },
      );
    }

    if (respuesta.status === 401 || respuesta.status === 403) {
      throw new ProviderContractError(
        options.provider,
        `El proveedor ${options.provider} rechazo la credencial (HTTP ${respuesta.status}). ` +
          'Revisa la clave en infra/.env.',
        { raw: detalle },
      );
    }

    if (!REINTENTABLES.has(respuesta.status)) {
      throw new ProviderContractError(
        options.provider,
        `El proveedor ${options.provider} rechazo la peticion (HTTP ${respuesta.status}).`,
        { raw: detalle },
      );
    }

    ultimo = new Error(`HTTP ${respuesta.status}: ${detalle}`);
  }

  throw new ProviderUnavailableError(
    options.provider,
    `${options.provider} no respondio tras ${options.maxRetries + 1} intento(s).`,
    { cause: ultimo },
  );
}

/**
 * Aborta por tiempo limite **y** por cancelacion del llamante.
 *
 * El limite se cuenta por intento, no para toda la serie: un reintento que
 * hereda el reloj gastado del anterior nace muerto.
 *
 * Se construye con un `AbortController` y un temporizador propio, y no con
 * `AbortSignal.any([AbortSignal.timeout(ms), llamante])`. Esa forma tiene un
 * fallo en Node 22: la senal compuesta solo guarda referencias debiles a sus
 * fuentes, y la de `timeout` no la retiene nadie mas, asi que el recolector
 * de basura la elimina y el plazo nunca dispara. Medido: con un limite de un
 * segundo, ocho de ocho peticiones de tres segundos terminaban sin abortar.
 * El sintoma en produccion era un primario que tardaba 30 s con
 * `AI_TIMEOUT_MS=15000` y un respaldo que nunca llegaba a intervenir.
 *
 * `liberar` quita el temporizador y el oyente cuando la peticion termina, para
 * que un plazo largo no quede vivo despues de una respuesta rapida.
 */
function senal(
  timeoutMs: number,
  delLlamante?: AbortSignal,
): { readonly signal: AbortSignal; readonly liberar: () => void } {
  const controlador = new AbortController();
  const temporizador = setTimeout(
    () =>
      controlador.abort(
        new DOMException(`El proveedor no respondio en ${String(timeoutMs)} ms.`, 'TimeoutError'),
      ),
    timeoutMs,
  );
  const propagar = (): void => controlador.abort(delLlamante?.reason);
  if (delLlamante?.aborted === true) propagar();
  else delLlamante?.addEventListener('abort', propagar, { once: true });

  return {
    signal: controlador.signal,
    liberar: (): void => {
      clearTimeout(temporizador);
      delLlamante?.removeEventListener('abort', propagar);
    },
  };
}

/**
 * El cuerpo del error se recorta antes de guardarlo.
 *
 * Un proveedor puede devolver una pagina de error entera, y eso acaba en el
 * registro y en la respuesta al navegador.
 */
function recortar(texto: string): string {
  return texto.length > 500 ? `${texto.slice(0, 500)}…` : texto;
}
