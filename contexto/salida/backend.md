# Backend

Los dos procesos de servidor y el esquema de datos. `api` es el servidor HTTP (Fastify, puerto 3001) con los modulos de autenticacion, proyectos, pizarras, IA, importacion, generacion y auditoria. `collab` es el servidor WebSocket (puerto 3002) que sostiene la edicion simultanea sobre el documento CRDT. `prisma` contiene el esquema de PostgreSQL y sus migraciones.

> Generado el 2026-09-21 00:41 por `contexto/todo.py`.
> 43 archivos, 4,735 lineas, 162.0 KiB de codigo.
> Pruebas: excluidas. Dependencias, compilados y binarios: siempre excluidos.

## Contenido

- [API HTTP](#api-http) --- 23 archivos
- [Servidor de colaboracion](#servidor-de-colaboracion) --- 7 archivos
- [Esquema y migraciones](#esquema-y-migraciones) --- 12 archivos
- [Configuracion de Prisma](#configuracion-de-prisma) --- 1 archivo

---

## API HTTP

`src/modules/` agrupa por area funcional y `src/plugins/` recoge lo transversal: autenticacion, cliente Prisma y cabeceras de seguridad.

### Estructura

```text
backend/api/
|-- src/
|   |-- lib/
|   |   |-- http-error.ts
|   |   |-- mail.ts
|   |   `-- request-cancellation.ts
|   |-- modules/
|   |   |-- ai/
|   |   |   `-- routes.ts
|   |   |-- audit/
|   |   |   `-- routes.ts
|   |   |-- auth/
|   |   |   |-- passwords.ts
|   |   |   |-- profile.ts
|   |   |   |-- routes.ts
|   |   |   |-- tokens.ts
|   |   |   `-- verification.ts
|   |   |-- boards/
|   |   |   `-- routes.ts
|   |   |-- generation/
|   |   |   `-- routes.ts
|   |   |-- import/
|   |   |   `-- routes.ts
|   |   `-- projects/
|   |       |-- membership.ts
|   |       `-- routes.ts
|   |-- plugins/
|   |   |-- auth.ts
|   |   |-- prisma.ts
|   |   `-- security.ts
|   |-- app.ts
|   |-- config.ts
|   `-- server.ts
|-- package.json
`-- tsconfig.json
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `backend/api/package.json` | 33 |
| `backend/api/tsconfig.json` | 29 |
| `backend/api/src/app.ts` | 187 |
| `backend/api/src/config.ts` | 125 |
| `backend/api/src/server.ts` | 21 |
| `backend/api/src/lib/http-error.ts` | 34 |
| `backend/api/src/lib/mail.ts` | 133 |
| `backend/api/src/lib/request-cancellation.ts` | 27 |
| `backend/api/src/modules/ai/routes.ts` | 229 |
| `backend/api/src/modules/audit/routes.ts` | 124 |
| `backend/api/src/modules/auth/passwords.ts` | 101 |
| `backend/api/src/modules/auth/profile.ts` | 343 |
| `backend/api/src/modules/auth/routes.ts` | 262 |
| `backend/api/src/modules/auth/tokens.ts` | 107 |
| `backend/api/src/modules/auth/verification.ts` | 109 |
| `backend/api/src/modules/boards/routes.ts` | 133 |
| `backend/api/src/modules/generation/routes.ts` | 537 |
| `backend/api/src/modules/import/routes.ts` | 313 |
| `backend/api/src/modules/projects/membership.ts` | 75 |
| `backend/api/src/modules/projects/routes.ts` | 313 |
| `backend/api/src/plugins/auth.ts` | 87 |
| `backend/api/src/plugins/prisma.ts` | 36 |
| `backend/api/src/plugins/security.ts` | 63 |

---

### `backend/api/package.json`

```json
{
  "name": "@uml/api",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "description": "Proceso HTTP: sesion, proyectos, pizarras, IA, imagen, XMI y generacion.",
  "main": "./dist/server.js",
  "scripts": {
    "build": "tsc --build",
    "clean": "tsc --build --clean",
    "dev": "tsx watch src/server.ts",
    "start": "node dist/server.js"
  },
  "dependencies": {
    "@fastify/cookie": "^11.0.0",
    "@fastify/cors": "^10.0.0",
    "@fastify/rate-limit": "^10.3.0",
    "@prisma/adapter-pg": "^7.10.0",
    "@prisma/client": "^7.10.0",
    "@uml/ai": "*",
    "@uml/contracts": "*",
    "@uml/domain-core": "*",
    "@uml/generation-ir": "*",
    "@uml/generator-backend": "*",
    "@uml/xmi": "*",
    "fastify": "^5.0.0",
    "fastify-plugin": "^6.0.0",
    "jose": "^6.2.10",
    "pg": "^8.23.0",
    "zod": "^3.23.0"
  }
}
```

---

### `backend/api/tsconfig.json`

```json
{
  "extends": "../../config/tsconfig.base.json",
  "compilerOptions": {
    "rootDir": "src",
    "outDir": "dist"
  },
  "include": ["src/**/*.ts"],
  "references": [
    {
      "path": "../../shared/ai"
    },
    {
      "path": "../../shared/contracts"
    },
    {
      "path": "../../shared/domain-core"
    },
    {
      "path": "../../shared/generation-ir"
    },
    {
      "path": "../../shared/generator-backend"
    },
    {
      "path": "../../shared/xmi"
    }
  ]
}
```

---

### `backend/api/src/app.ts`

```ts
import cookie from '@fastify/cookie';
import cors from '@fastify/cors';
import { createAiPorts, describeAiChains, loadAiConfig } from '@uml/ai';
import { SCHEMA_VERSION } from '@uml/contracts';
import Fastify, { type FastifyInstance } from 'fastify';
import { ZodError } from 'zod';
import { loadConfig, type Config } from './config.js';
import { HttpError } from './lib/http-error.js';
import { createMailPort, type MailPort } from './lib/mail.js';
import { verificationRoutes } from './modules/auth/verification.js';
import { aiRoutes } from './modules/ai/routes.js';
import { auditRoutes } from './modules/audit/routes.js';
import { profileRoutes } from './modules/auth/profile.js';
import { authRoutes } from './modules/auth/routes.js';
import { InvalidTokenError } from './modules/auth/tokens.js';
import { boardRoutes } from './modules/boards/routes.js';
import { generationRoutes } from './modules/generation/routes.js';
import { importRoutes } from './modules/import/routes.js';
import { projectRoutes } from './modules/projects/routes.js';
import { authPlugin } from './plugins/auth.js';
import { prismaPlugin } from './plugins/prisma.js';
import { securityPlugin } from './plugins/security.js';

export const SERVICE_NAME = 'api';

/**
 * Construye la aplicacion sin escucharla. Separar construccion de escucha es lo
 * que permite probarla por inyeccion, sin abrir un puerto.
 */
export async function buildApp(
  config: Config = loadConfig(),
  options: { mail?: MailPort } = {},
): Promise<FastifyInstance> {
  const app = Fastify({
    // RNF-14: registro estructurado. Los campos de proyecto, pizarra, sesion,
    // lote, comando, generacion, actor y origen se anaden por peticion en las
    // fases que los introducen. Bajo pruebas el registro se apaga entero: el
    // ruido de cada peticion inyectada no aporta nada al diagnostico.
    logger:
      config.NODE_ENV === 'test'
        ? false
        : {
            level: config.LOG_LEVEL,
            base: { service: SERVICE_NAME },
            redact: ['req.headers.authorization', 'req.headers.cookie', 'res.headers.set-cookie'],
          },
    genReqId: () => crypto.randomUUID(),
    trustProxy: (_address, hop) => hop < config.TRUST_PROXY_HOPS,
    requestTimeout: 30_000,
  });

  await app.register(cors, {
    // An exact allowlist: sibling domains, HTTP and direct IP access do not
    // receive CORS permissions. WEB_ORIGIN also defines password-reset links.
    origin: [config.WEB_ORIGIN],
    credentials: true,
    methods: ['GET', 'HEAD', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    exposedHeaders: ['Content-Disposition', 'Retry-After'],
    maxAge: 600,
  });
  await app.register(cookie);
  await app.register(prismaPlugin, { config });
  await app.register(securityPlugin, { config });
  await app.register(authPlugin, { config });

  app.setErrorHandler(errorHandler);

  app.get('/health', async () => ({
    status: 'ok',
    service: SERVICE_NAME,
    schemaVersion: SCHEMA_VERSION,
    uptimeSeconds: Math.round(process.uptime()),
  }));

  app.get('/ready', async (_request, reply) => {
    try {
      await app.prisma.$queryRaw`SELECT 1`;
      const collab = await fetch(`${config.COLLAB_INTERNAL_URL}/health`, {
        signal: AbortSignal.timeout(3000),
      });
      if (!collab.ok) throw new Error('collab unavailable');
      return { status: 'ok', service: SERVICE_NAME };
    } catch {
      return reply.code(503).send({ status: 'unavailable', service: SERVICE_NAME });
    }
  });

  // Una sola pasarela de IA para todo el proceso. Antes el asistente y la
  // importacion construian la suya por separado, con lo que el registro de uso
  // quedaba partido en dos y ninguno contaba la historia completa.
  const aiConfig = loadAiConfig();
  const aiPorts = createAiPorts(aiConfig);
  // Que cadena esta activa, antes de la primera llamada: evita la conversacion
  // de «¿pero esto esta usando el simulado?» en mitad de una demostracion.
  app.log.info({ cadenas: describeAiChains(aiConfig) }, 'capa de IA');

  const mail =
    options.mail ??
    createMailPort(
      {
        provider: config.MAIL_PROVIDER,
        from: config.MAIL_FROM,
        fromName: config.MAIL_FROM_NAME,
        brevoApiKey: config.BREVO_API_KEY,
      },
      app.log,
    );
  await app.register(authRoutes, { config, mail });
  await app.register(verificationRoutes, { config, mail });
  await app.register(profileRoutes, { config, mail });
  await app.register(projectRoutes, { config });
  await app.register(boardRoutes);
  await app.register(aiRoutes, { ports: aiPorts });
  await app.register(importRoutes, { ports: aiPorts });
  await app.register(generationRoutes, { config });
  await app.register(auditRoutes);

  return app;
}

/**
 * Cuerpo de error uniforme para toda la API.
 *
 * Un solo formato hace que el cliente tenga un solo camino de manejo. Es la
 * misma idea que RTM-10 aplica al backend generado.
 */
function errorHandler(
  error: unknown,
  request: Parameters<Parameters<FastifyInstance['setErrorHandler']>[0]>[1],
  reply: Parameters<Parameters<FastifyInstance['setErrorHandler']>[0]>[2],
): void {
  const respond = (statusCode: number, code: string, message: string, details?: unknown): void => {
    void reply.code(statusCode).send({
      error: { code, message, ...(details === undefined ? {} : { details }) },
      requestId: request.id,
    });
  };

  if (error instanceof HttpError) {
    respond(error.statusCode, error.code, error.message, error.details);
    return;
  }

  if (error instanceof InvalidTokenError) {
    respond(401, 'unauthorized', error.message);
    return;
  }

  if (error instanceof ZodError) {
    respond(
      400,
      'validation_failed',
      'La peticion no cumple el contrato.',
      error.issues.map((issue) => ({ path: issue.path.join('.'), message: issue.message })),
    );
    return;
  }

  // Fastify rechaza por su cuenta antes de llegar a la ruta: cuerpo vacio con
  // content-type JSON, carga demasiado grande, JSON mal formado. Traen su propio
  // codigo de estado y hay que respetarlo.
  //
  // Devolver 500 por un error del cliente no es solo impreciso: hace perder
  // tiempo buscando un fallo del servidor que no existe, y ensucia los registros
  // de errores con ruido que nadie puede arreglar.
  const conEstado = error as { statusCode?: unknown; code?: unknown; message?: unknown };
  if (
    typeof conEstado.statusCode === 'number' &&
    conEstado.statusCode >= 400 &&
    conEstado.statusCode < 500
  ) {
    respond(
      conEstado.statusCode,
      typeof conEstado.code === 'string' ? conEstado.code.toLowerCase() : 'bad_request',
      typeof conEstado.message === 'string' ? conEstado.message : 'Peticion invalida.',
    );
    return;
  }

  // Cualquier otra cosa si es un fallo nuestro. Se registra entero y al cliente
  // solo le llega que fue del servidor: un mensaje de excepcion puede contener
  // fragmentos de consulta o de configuracion.
  request.log.error({ err: error }, 'error no controlado');
  respond(500, 'internal_error', 'Error interno del servidor.');
}
```

---

### `backend/api/src/config.ts`

```ts
import { z } from 'zod';

/**
 * RNF-08: toda la configuracion entra por variables de entorno. Ningun secreto
 * queda escrito en el codigo ni en la composicion de contenedores.
 *
 * El proceso falla al arrancar si falta algo obligatorio: es preferible a
 * descubrirlo en mitad de la demostracion.
 */
const schema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  API_HOST: z.string().default('0.0.0.0'),
  API_PORT: z.coerce.number().int().positive().default(3001),
  LOG_LEVEL: z.enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace']).default('info'),
  WEB_ORIGIN: z.string().default('http://localhost:5173'),
  TRUST_PROXY_HOPS: z.coerce.number().int().min(0).max(2).default(0),
  RATE_LIMIT_MAX: z.coerce.number().int().positive().default(300),
  AUTH_RATE_LIMIT_MAX: z.coerce.number().int().positive().default(20),
  WORK_RATE_LIMIT_MAX: z.coerce.number().int().positive().default(20),
  RATE_LIMIT_ENABLED: z.enum(['true', 'false']).transform((value) => value === 'true'),

  DATABASE_URL: z.string().min(1),

  // Sin valor por defecto a proposito. Un secreto con valor por defecto acaba
  // desplegado, y nadie se entera hasta que alguien firma sus propios tokens.
  JWT_SECRET: z.string().min(32, 'JWT_SECRET debe tener al menos 32 caracteres'),
  ACCESS_TOKEN_TTL_SECONDS: z.coerce
    .number()
    .int()
    .positive()
    .default(15 * 60),
  REFRESH_TOKEN_TTL_SECONDS: z.coerce
    .number()
    .int()
    .positive()
    .default(30 * 24 * 60 * 60),
  INVITE_TTL_SECONDS: z.coerce
    .number()
    .int()
    .positive()
    .default(7 * 24 * 60 * 60),

  // Donde vive el proceso de colaboracion, para pedirle que vuelque el
  // documento antes de congelar el snapshot de generacion (RA-08). Es una
  // llamada entre procesos dentro de la misma red: nunca la hace el navegador.
  COLLAB_INTERNAL_URL: z.string().default('http://collab:3002'),

  /**
   * Ventana del enlace de recuperacion de contrasena.
   *
   * Una hora: suficiente para leer el correo, corto para que un enlace olvidado
   * en una bandeja no siga siendo una llave manana.
   */
  PASSWORD_RESET_TTL_SECONDS: z.coerce
    .number()
    .int()
    .positive()
    .default(60 * 60),

  /**
   * Proveedor de correo. `log` escribe el mensaje en el registro del servidor y
   * es el valor por defecto: la plataforma arranca y la recuperacion funciona
   * sin ninguna cuenta configurada.
   */
  MAIL_PROVIDER: z.enum(['log', 'brevo']).default('log'),
  MAIL_FROM: z.string().default('no-responder@plataforma-uml.local'),
  MAIL_FROM_NAME: z.string().default('UMLFORGE AI'),
  BREVO_API_KEY: z.string().optional(),

  // La cookie de refresco solo viaja por HTTPS fuera de desarrollo.
  COOKIE_SECURE: z
    .enum(['true', 'false'])
    .default('false')
    .transform((valor) => valor === 'true'),
});

export type Config = z.infer<typeof schema>;

export function loadConfig(env: NodeJS.ProcessEnv = process.env): Config {
  const parsed = schema.safeParse({
    ...env,
    RATE_LIMIT_ENABLED:
      env['RATE_LIMIT_ENABLED'] ?? (env['NODE_ENV'] === 'production' ? 'true' : 'false'),
  });
  if (!parsed.success) {
    const detalle = parsed.error.issues
      .map((issue) => `  ${issue.path.join('.')}: ${issue.message}`)
      .join('\n');
    throw new Error(`Configuracion invalida del proceso api:\n${detalle}`);
  }
  const config = parsed.data;
  if (config.NODE_ENV === 'production') {
    const problems: string[] = [];
    let origin: URL | undefined;
    try {
      origin = new URL(config.WEB_ORIGIN);
    } catch {
      /* Report a field name, never the supplied secret values. */
    }
    if (!origin || origin.protocol !== 'https:' || origin.origin !== config.WEB_ORIGIN) {
      problems.push('WEB_ORIGIN debe ser un origen HTTPS sin ruta ni barra final');
    }
    if (!config.COOKIE_SECURE) problems.push('COOKIE_SECURE debe ser true');
    if (!config.RATE_LIMIT_ENABLED) problems.push('RATE_LIMIT_ENABLED debe ser true');
    if (
      config.JWT_SECRET.length < 48 ||
      /cambiar|change-me|secreto-de-pruebas/i.test(config.JWT_SECRET)
    ) {
      problems.push('JWT_SECRET debe ser aleatorio y tener al menos 48 caracteres');
    }
    if (config.MAIL_PROVIDER !== 'brevo' || !config.BREVO_API_KEY?.trim()) {
      problems.push('MAIL_PROVIDER=brevo y BREVO_API_KEY son obligatorios en producción');
    }
    if (
      !z.string().email().safeParse(config.MAIL_FROM).success ||
      config.MAIL_FROM.endsWith('.local')
    ) {
      problems.push('MAIL_FROM debe ser un remitente real verificado');
    }
    if (problems.length)
      throw new Error(`Configuracion de producción invalida:\n${problems.join('\n')}`);
  }
  return config;
}
```

---

### `backend/api/src/server.ts`

```ts
import { buildApp, SERVICE_NAME } from './app.js';
import { loadConfig } from './config.js';

const config = loadConfig();
const app = await buildApp(config);

for (const senal of ['SIGINT', 'SIGTERM'] as const) {
  process.on(senal, () => {
    app.log.info({ senal }, 'cerrando el proceso');
    void app.close().then(() => process.exit(0));
  });
}

try {
  await app.listen({ host: config.API_HOST, port: config.API_PORT });
  app.log.info({ service: SERVICE_NAME, port: config.API_PORT }, 'proceso api escuchando');
} catch (error) {
  app.log.fatal({ error }, 'el proceso api no pudo arrancar');
  process.exit(1);
}
```

---

### `backend/api/src/lib/http-error.ts`

```ts
/**
 * Errores con codigo de estado.
 *
 * El manejador global los traduce a un cuerpo uniforme. Cualquier otra excepcion
 * sale como 500 y se registra entera: si un fallo inesperado se disfrazara de
 * error de cliente, nadie lo veria en los registros.
 */
export class HttpError extends Error {
  public constructor(
    public readonly statusCode: number,
    public readonly code: string,
    message: string,
    public readonly details?: unknown,
  ) {
    super(message);
    this.name = 'HttpError';
  }
}

export const badRequest = (code: string, message: string, details?: unknown): HttpError =>
  new HttpError(400, code, message, details);

export const unauthorized = (message = 'Credenciales invalidas o sesion expirada.'): HttpError =>
  new HttpError(401, 'unauthorized', message);

export const forbidden = (message = 'No tienes permiso para esta operacion.'): HttpError =>
  new HttpError(403, 'forbidden', message);

export const notFound = (message = 'El recurso no existe.'): HttpError =>
  new HttpError(404, 'not_found', message);

export const conflict = (code: string, message: string): HttpError =>
  new HttpError(409, code, message);
```

---

### `backend/api/src/lib/mail.ts`

```ts
/**
 * Envio de correo, detras de un puerto (mismo patron que la capa de IA,
 * ADR-015).
 *
 * La recuperacion de contrasena necesita entregar un enlace, y eso arrastra un
 * proveedor externo al camino critico. Ponerlo detras de un puerto evita las dos
 * cosas que salen mal:
 *
 *   - que la plataforma no arranque sin una cuenta de correo configurada;
 *   - que cambiar de proveedor obligue a tocar la ruta de recuperacion.
 *
 * El adaptador por defecto es `log`: escribe el mensaje en el registro del
 * servidor. No es un hueco por rellenar — es lo que permite probar el flujo
 * entero, y en una demostracion sin internet sigue habiendo forma de recuperar
 * una cuenta leyendo el registro.
 */

export interface Correo {
  readonly to: string;
  readonly subject: string;
  /** Cuerpo en texto plano. No se envia HTML: un enlace no lo necesita. */
  readonly text: string;
}

export interface MailPort {
  readonly name: string;
  send(correo: Correo): Promise<void>;
}

/** El proveedor no acepto el mensaje. Nunca se le cuenta al usuario final. */
export class MailDeliveryError extends Error {
  public constructor(
    public readonly provider: string,
    message: string,
    options?: { cause?: unknown },
  ) {
    super(message, options);
    this.name = 'MailDeliveryError';
  }
}

export interface MailConfig {
  readonly provider: 'log' | 'brevo';
  readonly from: string;
  readonly fromName: string;
  readonly brevoApiKey?: string | undefined;
  readonly timeoutMs?: number;
}

export function createMailPort(
  config: MailConfig,
  logger: { info: (obj: unknown, mensaje: string) => void },
): MailPort {
  if (config.provider === 'brevo') return new BrevoMailPort(config);
  return new LogMailPort(logger);
}

/**
 * Escribe el correo en el registro del servidor.
 *
 * Con el enlace completo: es lo que hace utilizable la recuperacion en local y
 * en una red sin salida a internet. `docker logs plataforma-uml-api-1` y ahi
 * esta el enlace.
 */
class LogMailPort implements MailPort {
  public readonly name = 'log';

  public constructor(private readonly logger: { info: (obj: unknown, mensaje: string) => void }) {}

  public send(correo: Correo): Promise<void> {
    this.logger.info(
      { destinatario: correo.to, asunto: correo.subject, cuerpo: correo.text },
      'correo simulado (proveedor: log)',
    );
    return Promise.resolve();
  }
}

/**
 * Brevo, por su API HTTP.
 *
 * Se llama con `fetch` y no con su SDK, por lo mismo que los adaptadores de IA:
 * una peticion no justifica una dependencia con su propia cadencia de versiones.
 */
class BrevoMailPort implements MailPort {
  public readonly name = 'brevo';
  private static readonly URL = 'https://api.brevo.com/v3/smtp/email';

  public constructor(private readonly config: MailConfig) {
    if (config.brevoApiKey === undefined || config.brevoApiKey.trim().length === 0) {
      // Al construir y no en el primer envio: enterarse de que falta la clave
      // cuando alguien ya perdio su contrasena es tarde.
      throw new Error(
        'El proveedor brevo necesita BREVO_API_KEY. Deja MAIL_PROVIDER=log si no la tienes.',
      );
    }
  }

  public async send(correo: Correo): Promise<void> {
    let respuesta: Response;

    try {
      respuesta = await fetch(BrevoMailPort.URL, {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          accept: 'application/json',
          'api-key': this.config.brevoApiKey as string,
        },
        body: JSON.stringify({
          sender: { email: this.config.from, name: this.config.fromName },
          to: [{ email: correo.to }],
          subject: correo.subject,
          textContent: correo.text,
        }),
        signal: AbortSignal.timeout(this.config.timeoutMs ?? 10_000),
      });
    } catch (error) {
      throw new MailDeliveryError('brevo', 'No se pudo contactar con el proveedor.', {
        cause: error,
      });
    }

    if (!respuesta.ok) {
      const detalle = (await respuesta.text().catch(() => '')).slice(0, 300);
      throw new MailDeliveryError(
        'brevo',
        `El proveedor rechazo el envio (${respuesta.status}): ${detalle}`,
      );
    }
  }
}
```

---

### `backend/api/src/lib/request-cancellation.ts`

```ts
import type { FastifyReply, FastifyRequest } from 'fastify';

/** Mantiene viva la llamada mientras el cliente espera la respuesta, no solo
 * mientras sube el cuerpo. IncomingMessage.close también ocurre al terminar
 * de leer un POST normal, por eso se observa el cierre de la respuesta. */
export async function withRequestCancellation<T>(
  request: FastifyRequest,
  reply: FastifyReply,
  run: (signal: AbortSignal) => Promise<T>,
): Promise<T> {
  const controller = new AbortController();
  const abort = () => controller.abort();
  const onClose = () => {
    if (!reply.raw.writableEnded) abort();
  };
  request.raw.once('aborted', abort);
  reply.raw.once('close', onClose);
  try {
    if (request.raw.aborted || reply.raw.destroyed) abort();
    controller.signal.throwIfAborted();
    return await run(controller.signal);
  } finally {
    request.raw.off('aborted', abort);
    reply.raw.off('close', onClose);
  }
}
```

---

### `backend/api/src/modules/ai/routes.ts`

```ts
import { semanticModelSchema } from '@uml/contracts';
import { validateModel } from '@uml/domain-core';
import {
  ProviderContractError,
  ProviderUnavailableError,
  createAiPorts,
  loadAiConfig,
  resolveProposal,
  type AiPorts,
} from '@uml/ai';
import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { HttpError } from '../../lib/http-error.js';
import { withRequestCancellation } from '../../lib/request-cancellation.js';
import { currentUser } from '../../plugins/auth.js';
import { requireMembership, requireWriteAccess } from '../projects/membership.js';

/**
 * Asistente por texto y voz (RF-030 a RF-037).
 *
 * **Que hace este modulo y que no.** Recibe una instruccion y el estado de la
 * pizarra, se lo pasa al proveedor a traves del puerto, resuelve la propuesta
 * contra el modelo real y devuelve un lote listo — o una pregunta. **No aplica
 * nada.**
 *
 * Aplicarlo es cosa del navegador, por el mismo camino que la interfaz grafica:
 * `applyBatchToDocument` sobre el documento colaborativo. Asi hay un solo
 * escritor por documento y el asistente es literalmente otro adaptador que
 * produce comandos (RA-01), no una via paralela con sus propias reglas.
 *
 * El estado llega en la peticion y no se lee del snapshot persistido: el
 * snapshot lo escribe el proceso de colaboracion con retardo, y el asistente
 * tiene que razonar sobre lo que el usuario esta viendo, no sobre lo que habia
 * hace dos segundos.
 */

const boardParams = z.object({ boardId: z.string().uuid() });

const instructionBody = z.object({
  instruction: z.string().trim().min(1).max(2000),
  context: z
    .array(
      z.object({
        role: z.enum(['user', 'assistant']),
        text: z.string().trim().min(1).max(2000),
      }),
    )
    .max(10)
    .default([]),
  model: semanticModelSchema,
});

const questionBody = z.object({
  question: z.string().trim().min(1).max(2000),
  model: semanticModelSchema,
});

const transcribeBody = z.object({
  /** Audio en base64. Respaldo del reconocimiento del navegador (6.2). */
  audio: z.string().min(1).max(8_000_000),
  mediaType: z.string().min(1).max(100),
});

// Base64 más el envoltorio JSON. Igual que imagen, no amplía otras rutas.
const TRANSCRIBE_BODY_LIMIT = 8_000_000 + 1024;

export async function aiRoutes(
  app: FastifyInstance,
  options: { ports?: AiPorts } = {},
): Promise<void> {
  const ports = options.ports ?? createAiPorts(loadAiConfig());

  app.addHook('preHandler', app.authenticate);

  /**
   * RF-030 y RF-032: instruccion por texto (o dictada) a lote validado.
   *
   * Exige permiso de escritura aunque no escriba: devolver un lote listo para
   * aplicar a quien no puede aplicarlo solo genera un rechazo mas adelante.
   */
  app.post('/boards/:boardId/assistant/instruction', async (request, reply) => {
    const { boardId } = boardParams.parse(request.params);
    const body = instructionBody.parse(request.body);
    const { userId } = currentUser(request);

    const board = await findBoard(app, boardId);
    await requireWriteAccess(app.prisma, board.projectId, userId);

    const { proposal, usage } = await withRequestCancellation(request, reply, (signal) =>
      conProveedor(() =>
        ports.llm.proposeCommands({
          instruction: body.instruction,
          snapshot: body.model,
          context: body.context,
          signal,
        }),
      ),
    );

    const outcome = resolveProposal({
      proposal,
      model: body.model,
      actorId: userId,
      origin: 'AI_TEXT',
    });

    // RNF-14: el registro estructurado deja el proveedor, la latencia y el
    // desenlace, que es lo que se mira cuando el asistente hace algo raro.
    request.log.info(
      {
        boardId,
        origin: 'AI_TEXT',
        provider: usage?.provider,
        latencyMs: usage?.latencyMs,
        outcome: outcome.kind,
        operations: proposal.operations.length,
        contextTurns: body.context.length,
      },
      'instruccion del asistente',
    );

    return { ...outcome, rationale: proposal.rationale ?? null };
  });

  /** RF-036 y RF-037: consultar sin modificar. */
  app.post('/boards/:boardId/assistant/question', async (request, reply) => {
    const { boardId } = boardParams.parse(request.params);
    const body = questionBody.parse(request.body);
    const { userId } = currentUser(request);

    const board = await findBoard(app, boardId);
    // Solo lectura: un VIEWER puede consultar al asistente sin modificar (5.5).
    await requireMembership(app.prisma, board.projectId, userId);

    const issues = validateModel(body.model).map((hallazgo) => ({
      code: hallazgo.code,
      severity: hallazgo.severity,
      message: hallazgo.message,
    }));

    const { text, usage } = await withRequestCancellation(request, reply, (signal) =>
      conProveedor(() =>
        ports.llm.answer({ question: body.question, snapshot: body.model, issues, signal }),
      ),
    );

    request.log.info(
      { boardId, provider: usage?.provider, latencyMs: usage?.latencyMs },
      'consulta al asistente',
    );

    return { answer: text, issues };
  });

  /** Respaldo de transcripcion, para navegadores sin reconocimiento (6.2). */
  app.post(
    '/assistant/transcribe',
    { bodyLimit: TRANSCRIBE_BODY_LIMIT },
    async (request, reply) => {
      const body = transcribeBody.parse(request.body);

      const { text } = await withRequestCancellation(request, reply, (signal) =>
        conProveedor(() =>
          ports.speech.transcribe({
            audio: Buffer.from(body.audio, 'base64'),
            mediaType: body.mediaType,
            signal,
          }),
        ),
      );

      return { text };
    },
  );

  /** Uso acumulado del proceso, para diagnosticar y para la defensa (6.5). */
  app.get('/assistant/usage', async () => ({
    provider: ports.llm.name,
    calls: ports.usageLog.length,
    recent: ports.usageLog.slice(-20),
  }));
}

/**
 * Traduce los fallos del proveedor a respuestas HTTP con sentido.
 *
 * Un proveedor caido no es un fallo del servidor: es una dependencia externa que
 * no respondio, y el usuario tiene que poder distinguirlo para saber si merece
 * la pena reintentar.
 */
async function conProveedor<T>(llamar: () => Promise<T>): Promise<T> {
  try {
    return await llamar();
  } catch (error) {
    if (error instanceof ProviderUnavailableError) {
      throw new HttpError(
        503,
        'ai_provider_unavailable',
        `El asistente no esta disponible ahora mismo (${error.provider}). Vuelve a intentarlo.`,
      );
    }
    if (error instanceof ProviderContractError) {
      // El mensaje ya está saneado por el adaptador y diferencia una credencial,
      // un modelo retirado, JSON inválido o una propuesta fuera del vocabulario.
      // Ocultarlo detrás de «no se pudo interpretar» hizo que un 404 de modelo
      // pareciera un fallo del prompt y volvió innecesariamente difícil corregir
      // la configuración.
      // Con el nombre del proveedor delante. Sin el, un fallo del respaldo se
      // lee como un fallo del primario, y quien lo ve busca el problema en la
      // configuracion equivocada.
      throw new HttpError(502, 'ai_provider_contract', `${error.provider}: ${error.message}`);
    }
    throw error;
  }
}

async function findBoard(
  app: FastifyInstance,
  boardId: string,
): Promise<{ id: string; projectId: string }> {
  const board = await app.prisma.board.findUnique({
    where: { id: boardId },
    select: { id: true, projectId: true },
  });

  if (board === null) throw new HttpError(404, 'not_found', 'La pizarra no existe.');
  return board;
}
```

---

### `backend/api/src/modules/audit/routes.ts`

```ts
import { commandBatchSchema } from '@uml/contracts';
import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { notFound } from '../../lib/http-error.js';
import { currentUser } from '../../plugins/auth.js';
import { requireMembership, requireWriteAccess } from '../projects/membership.js';

const boardParams = z.object({ boardId: z.string().uuid() });
const historyQuery = z.object({
  limit: z.coerce.number().int().min(1).max(200).default(50),
});

/**
 * Auditoria de lotes (RF-A09 y CA-023.1).
 *
 * **Por que existe una ruta y no viaja por el canal de tiempo real.** CA-023.1
 * es explicito: el protocolo colaborativo transporta actualizaciones del
 * documento, no comandos de dominio. El comando se aplica localmente y viaja la
 * actualizacion resultante. Los comandos se registran **para auditoria**, no
 * para sincronizar — y por eso el registro va aparte, por HTTP, donde ya hay una
 * sesion autenticada.
 *
 * **El actor no lo elige el cliente.** El lote llega con un `actorId` porque el
 * esquema del dominio lo exige, pero lo que se guarda es el usuario de la
 * sesion. Aceptar el del cuerpo permitiria atribuir cambios a otra persona, que
 * es justamente lo que la auditoria tiene que impedir.
 *
 * **Registrar no puede romper la edicion.** El lote ya se aplico en el documento
 * cuando esto se llama; si el registro falla, se responde el error pero la
 * pizarra sigue como estaba. Por eso el cliente lo envia sin esperar la
 * respuesta.
 */
export async function auditRoutes(app: FastifyInstance): Promise<void> {
  app.addHook('preHandler', app.authenticate);

  app.post('/boards/:boardId/audit', async (request, reply) => {
    const { boardId } = boardParams.parse(request.params);
    const batch = commandBatchSchema.parse(request.body);
    const { userId } = currentUser(request);

    const board = await findBoard(app, boardId);
    await requireWriteAccess(app.prisma, board.projectId, userId);

    // Idempotente por `batchId`: reintentar el envio tras un corte de red no
    // duplica la entrada del registro. El lote es la unidad transaccional
    // (RA-03) y aqui tambien es la unidad de identidad.
    await app.prisma.auditOperation.upsert({
      where: { boardId_batchId: { boardId, batchId: batch.batchId } },
      update: {},
      create: {
        boardId,
        batchId: batch.batchId,
        origin: batch.origin,
        actorId: userId,
        payload: { commands: batch.commands, issuedAt: batch.issuedAt },
      },
    });

    reply.code(202);
    return { batchId: batch.batchId };
  });

  app.get('/boards/:boardId/audit', async (request) => {
    const { boardId } = boardParams.parse(request.params);
    const { limit } = historyQuery.parse(request.query ?? {});
    const { userId } = currentUser(request);

    const board = await findBoard(app, boardId);
    // Leer el historial no modifica nada: un VIEWER puede revisar quien cambio
    // que, que es para lo que sirve un registro de auditoria.
    await requireMembership(app.prisma, board.projectId, userId);

    const operaciones = await app.prisma.auditOperation.findMany({
      where: { boardId },
      orderBy: { createdAt: 'desc' },
      take: limit,
      select: {
        id: true,
        batchId: true,
        origin: true,
        actorId: true,
        payload: true,
        createdAt: true,
      },
    });

    return operaciones.map((operacion) => ({
      id: operacion.id,
      batchId: operacion.batchId,
      origin: operacion.origin,
      actorId: operacion.actorId,
      createdAt: operacion.createdAt,
      // El historial se lee para saber quien hizo que, no para reproducir el
      // modelo: se resume en lugar de devolver cada carga entera.
      commands: resumir(operacion.payload),
    }));
  });
}

function resumir(payload: unknown): readonly string[] {
  if (typeof payload !== 'object' || payload === null) return [];
  const commands = (payload as { commands?: unknown }).commands;
  if (!Array.isArray(commands)) return [];

  return commands.map((command) =>
    typeof command === 'object' && command !== null && 'type' in command
      ? String((command as { type: unknown }).type)
      : 'DESCONOCIDO',
  );
}

async function findBoard(
  app: FastifyInstance,
  boardId: string,
): Promise<{ id: string; projectId: string }> {
  const board = await app.prisma.board.findUnique({
    where: { id: boardId },
    select: { id: true, projectId: true },
  });

  if (board === null) throw notFound('La pizarra no existe.');
  return board;
}
```

---

### `backend/api/src/modules/auth/passwords.ts`

```ts
import {
  randomBytes,
  scrypt as scryptCallback,
  timingSafeEqual,
  type ScryptOptions,
} from 'node:crypto';
import { promisify } from 'node:util';

// `promisify` no infiere la sobrecarga de cuatro argumentos de scrypt, que es la
// unica que acepta parametros de coste.
const scrypt = promisify(scryptCallback) as (
  password: string,
  salt: Buffer,
  keylen: number,
  options: ScryptOptions,
) => Promise<Buffer>;

/**
 * Derivacion de contrasenas (RNF-08).
 *
 * scrypt, de `node:crypto`. Lenta y dura en memoria por diseno: el coste de
 * probar una contrasena no baja comprando hardware paralelo barato.
 *
 * Argon2id seria la primera recomendacion actual. Se descarta por una razon
 * concreta, no por preferencia: las implementaciones de Argon2 para Node son
 * modulos nativos, y un modulo nativo es la fuente numero uno de "en mi maquina
 * si funciona" — distinta arquitectura, distinta libc entre Alpine y Windows,
 * cadena de compilacion ausente. A tres semanas de la defensa, esa clase de
 * fallo cuesta mas de lo que la diferencia entre scrypt y Argon2id protege, con
 * los parametros de abajo. Queda anotado en ADR-014 como via de mejora.
 *
 * Parametros: N=2^16, r=8, p=1, clave de 64 bytes, sal de 16 bytes aleatorios.
 * `maxmem` se sube porque el valor por defecto de Node no alcanza para N=2^16.
 */
const SCRYPT_COST = 2 ** 16;
const SCRYPT_BLOCK_SIZE = 8;
const SCRYPT_PARALLELIZATION = 1;
const KEY_LENGTH = 64;
const SALT_LENGTH = 16;
const MAX_MEMORY = 192 * 1024 * 1024;

const ALGORITHM = 'scrypt';

const scryptOptions = {
  N: SCRYPT_COST,
  r: SCRYPT_BLOCK_SIZE,
  p: SCRYPT_PARALLELIZATION,
  maxmem: MAX_MEMORY,
} as const;

/**
 * Devuelve una cadena autodescriptiva.
 *
 * Llevar el algoritmo y sus parametros dentro del propio hash permite subirlos
 * mas adelante sin invalidar las contrasenas existentes: se comprueban con los
 * parametros con los que se guardaron.
 */
export async function hashPassword(password: string): Promise<string> {
  const salt = randomBytes(SALT_LENGTH);
  const derived = await scrypt(password.normalize('NFKC'), salt, KEY_LENGTH, scryptOptions);

  return [
    ALGORITHM,
    SCRYPT_COST,
    SCRYPT_BLOCK_SIZE,
    SCRYPT_PARALLELIZATION,
    salt.toString('base64'),
    derived.toString('base64'),
  ].join('$');
}

export async function verifyPassword(password: string, stored: string): Promise<boolean> {
  const parts = stored.split('$');
  if (parts.length !== 6 || parts[0] !== ALGORITHM) return false;

  const cost = Number(parts[1]);
  const blockSize = Number(parts[2]);
  const parallelization = Number(parts[3]);
  const salt = Buffer.from(parts[4] as string, 'base64');
  const expected = Buffer.from(parts[5] as string, 'base64');

  if (
    !Number.isInteger(cost) ||
    !Number.isInteger(blockSize) ||
    !Number.isInteger(parallelization)
  ) {
    return false;
  }

  const derived = await scrypt(password.normalize('NFKC'), salt, expected.length, {
    N: cost,
    r: blockSize,
    p: parallelization,
    maxmem: MAX_MEMORY,
  });

  // Comparacion en tiempo constante: una comparacion normal filtra por cuanto
  // tarda en cuantos bytes coincide el prefijo.
  return derived.length === expected.length && timingSafeEqual(derived, expected);
}
```

---

### `backend/api/src/modules/auth/profile.ts`

```ts
import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import type { Config } from '../../config.js';
import { HttpError, badRequest, notFound, unauthorized } from '../../lib/http-error.js';
import { MailDeliveryError, createMailPort, type MailPort } from '../../lib/mail.js';
import { REFRESH_COOKIE, currentUser } from '../../plugins/auth.js';
import { hashPassword, verifyPassword } from './passwords.js';
import { createRefreshToken, hashRefreshToken } from './tokens.js';

/**
 * Perfil, cambio de contrasena y recuperacion (RF-A10 y RF-A11).
 *
 * Tres reglas gobiernan este archivo:
 *
 * **Cambiar la contrasena cierra las demas sesiones.** Quien la cambia porque
 * cree que alguien mas la sabe espera exactamente eso; dejarlas abiertas
 * convierte el cambio en un gesto sin efecto. Se conserva la sesion desde la que
 * se hizo el cambio, para no expulsar a quien lo pidio.
 *
 * **Pedir recuperacion nunca revela si el correo existe.** La respuesta es la
 * misma para una cuenta real y para una inventada. Lo contrario convierte el
 * formulario en un comprobador de correos registrados.
 *
 * **El testigo se guarda con hash y es de un solo uso.** Igual que el de
 * refresco: quien lea la base no puede usarlo, y un enlace ya usado no vale dos
 * veces.
 */

const perfilBody = z.object({
  displayName: z.string().trim().min(1).max(120),
});

const cambioBody = z.object({
  currentPassword: z.string().min(1).max(200),
  newPassword: z.string().min(8).max(200),
});

const olvidoBody = z.object({
  email: z.string().email().max(254),
});

const restablecerBody = z.object({
  token: z.string().min(20).max(200),
  newPassword: z.string().min(8).max(200),
});

/** Formatos que se aceptan como foto. Cualquier otro se rechaza antes de tocar la base. */
const TIPOS_DE_IMAGEN = ['image/png', 'image/jpeg', 'image/webp'] as const;

/**
 * Tope de la foto ya recortada.
 *
 * La interfaz la reduce a 256x256 antes de enviarla, asi que 256 kB es holgado.
 * El limite esta aqui igualmente: el navegador no es quien decide cuanto ocupa
 * una fila de la base.
 */
const MAXIMO_AVATAR = 256 * 1024;

const avatarBody = z.object({
  image: z
    .string()
    .min(1)
    .max(Math.ceil((MAXIMO_AVATAR * 4) / 3) + 1024),
  mediaType: z.enum(TIPOS_DE_IMAGEN),
});

export async function profileRoutes(
  app: FastifyInstance,
  options: { config: Config; mail?: MailPort },
): Promise<void> {
  const { config } = options;
  const mail =
    options.mail ??
    createMailPort(
      {
        provider: config.MAIL_PROVIDER,
        from: config.MAIL_FROM,
        fromName: config.MAIL_FROM_NAME,
        brevoApiKey: config.BREVO_API_KEY,
      },
      app.log,
    );

  // -------------------------------------------------------------------------
  // Perfil
  // -------------------------------------------------------------------------

  app.patch('/auth/me', { preHandler: app.authenticate }, async (request) => {
    const body = perfilBody.parse(request.body);
    const { userId } = currentUser(request);

    const user = await app.prisma.user.update({
      where: { id: userId },
      data: { displayName: body.displayName },
      select: { id: true, email: true, displayName: true, createdAt: true },
    });

    return { ...user, hasAvatar: await tieneAvatar(app, userId) };
  });

  app.put('/auth/me/avatar', { preHandler: app.authenticate }, async (request) => {
    const body = avatarBody.parse(request.body);
    const { userId } = currentUser(request);

    const bytes = Buffer.from(body.image, 'base64');
    if (bytes.byteLength === 0) throw badRequest('imagen_vacia', 'La imagen llego vacia.');
    if (bytes.byteLength > MAXIMO_AVATAR) {
      throw badRequest(
        'imagen_grande',
        `La foto supera ${Math.round(MAXIMO_AVATAR / 1024)} kB una vez recortada.`,
      );
    }

    await app.prisma.user.update({
      where: { id: userId },
      data: { avatar: bytes, avatarMimeType: body.mediaType },
    });

    return { hasAvatar: true, bytes: bytes.byteLength };
  });

  app.delete('/auth/me/avatar', { preHandler: app.authenticate }, async (request, reply) => {
    const { userId } = currentUser(request);

    await app.prisma.user.update({
      where: { id: userId },
      data: { avatar: null, avatarMimeType: null },
    });

    reply.code(204);
    return null;
  });

  /**
   * La foto, por identificador de usuario.
   *
   * **Sin sesion, a proposito, y esto merece explicacion.** La primera version
   * exigia el token de acceso, y la foto no se veia nunca: una etiqueta `<img>`
   * pide la imagen con las cookies del navegador, no con la cabecera
   * `Authorization`, asi que la peticion llegaba sin token y respondia 401. Lo
   * descubrio la prueba de navegador; leyendo el codigo no se ve.
   *
   * De las salidas posibles se elige la simple: la ruta queda abierta y la
   * proteccion es el identificador, un UUID que no se publica en ningun sitio y
   * que solo aparece ante quien ya es miembro. Una foto de perfil no es un dato
   * reservado. Las alternativas eran peor negocio: aceptar la cookie de
   * refresco como credencial mezcla dos tipos de testigo, y descargar cada
   * avatar con `fetch` obliga a gestionar un blob por cara.
   *
   * Lo que no se filtra: un identificador inventado y uno real sin foto
   * responden lo mismo, un 404. La ruta no dice quien existe.
   */
  app.get('/auth/users/:userId/avatar', async (request, reply) => {
    const { userId } = z.object({ userId: z.string().uuid() }).parse(request.params);

    const user = await app.prisma.user.findUnique({
      where: { id: userId },
      select: { avatar: true, avatarMimeType: true },
    });

    if (user === null || user.avatar === null || user.avatarMimeType === null) {
      throw notFound('Ese usuario no tiene foto.');
    }

    reply
      .header('content-type', user.avatarMimeType)
      .header('content-length', String(user.avatar.byteLength))
      // Corta: cambiar la foto tiene que notarse enseguida. La direccion
      // lleva ademas una version, que es lo que salta la cache al subir una.
      .header('cache-control', 'public, max-age=60');

    return reply.send(Buffer.from(user.avatar));
  });

  // -------------------------------------------------------------------------
  // Cambio de contrasena
  // -------------------------------------------------------------------------

  app.post('/auth/me/password', { preHandler: app.authenticate }, async (request) => {
    const body = cambioBody.parse(request.body);
    const { userId } = currentUser(request);

    const user = await app.prisma.user.findUniqueOrThrow({
      where: { id: userId },
      select: { passwordHash: true },
    });

    // Se pide la actual aunque haya sesion: una pantalla desatendida no puede
    // servir para cambiar la contrasena de quien la dejo abierta.
    if (!(await verifyPassword(body.currentPassword, user.passwordHash))) {
      throw unauthorized('La contrasena actual no es correcta.');
    }

    if (body.currentPassword === body.newPassword) {
      throw badRequest('misma_contrasena', 'La nueva contrasena es igual a la actual.');
    }

    const presented = request.cookies[REFRESH_COOKIE];

    await app.prisma.$transaction([
      app.prisma.user.update({
        where: { id: userId },
        data: {
          passwordHash: await hashPassword(body.newPassword),
          sessionVersion: { increment: 1 },
        },
      }),
      // Las demas sesiones se cierran; la actual sobrevive para no expulsar a
      // quien acaba de cambiarla.
      app.prisma.refreshToken.updateMany({
        where: {
          userId,
          revokedAt: null,
          ...(presented === undefined ? {} : { NOT: { tokenHash: hashRefreshToken(presented) } }),
        },
        data: { revokedAt: new Date() },
      }),
      app.prisma.passwordReset.updateMany({
        where: { userId, usedAt: null },
        data: { usedAt: new Date() },
      }),
    ]);

    return { changed: true };
  });

  // -------------------------------------------------------------------------
  // Recuperacion
  // -------------------------------------------------------------------------

  app.post('/auth/password/forgot', async (request, reply) => {
    const body = olvidoBody.parse(request.body);
    const email = body.email.trim().toLowerCase();

    const user = await app.prisma.user.findUnique({ where: { email }, select: { id: true } });

    if (user !== null) {
      const testigo = createRefreshToken();

      await app.prisma.passwordReset.create({
        data: {
          userId: user.id,
          tokenHash: testigo.hash,
          expiresAt: new Date(Date.now() + config.PASSWORD_RESET_TTL_SECONDS * 1000),
        },
      });

      const enlace = `${config.WEB_ORIGIN.replace(/\/$/, '')}/restablecer?token=${testigo.token}`;
      const minutos = Math.round(config.PASSWORD_RESET_TTL_SECONDS / 60);

      try {
        await mail.send({
          to: email,
          subject: 'Restablecer tu contrasena — UMLFORGE AI',
          text: [
            'Alguien pidio restablecer la contrasena de esta cuenta.',
            '',
            `Abre este enlace para elegir una nueva (caduca en ${minutos} minutos):`,
            enlace,
            '',
            'Si no fuiste tu, ignora este mensaje: la contrasena no ha cambiado.',
          ].join('\n'),
        });
      } catch (error) {
        // El fallo se registra y no se propaga: contarlo distinguiria una
        // cuenta existente de una inventada, que es justo lo que esta ruta no
        // puede revelar.
        app.log.error(
          {
            proveedor: mail.name,
            motivo: error instanceof MailDeliveryError ? error.message : 'desconocido',
          },
          'no se pudo enviar el correo de recuperacion',
        );
      }
    }

    // Misma respuesta exista o no la cuenta.
    reply.code(202);
    return { sent: true };
  });

  app.post('/auth/password/reset', async (request) => {
    const body = restablecerBody.parse(request.body);

    const registro = await app.prisma.passwordReset.findUnique({
      where: { tokenHash: hashRefreshToken(body.token) },
      select: { id: true, userId: true, expiresAt: true, usedAt: true },
    });

    if (registro === null || registro.usedAt !== null || registro.expiresAt <= new Date()) {
      // Un solo mensaje para las tres situaciones: distinguirlas le diria a
      // quien prueba testigos cual de ellos existio alguna vez.
      throw new HttpError(
        400,
        'enlace_invalido',
        'Ese enlace ya no sirve. Pide uno nuevo desde «Olvide mi contrasena».',
      );
    }

    const passwordHash = await hashPassword(body.newPassword);
    const ahora = new Date();

    await app.prisma.$transaction(async (tx) => {
      // El cambio bloquea la fila de usuario y serializa tambien dos enlaces
      // distintos de la misma cuenta. Si el consumo falla, todo se revierte.
      await tx.user.update({
        where: { id: registro.userId },
        data: { passwordHash, sessionVersion: { increment: 1 } },
      });
      const consumido = await tx.passwordReset.updateMany({
        where: { id: registro.id, usedAt: null, expiresAt: { gt: new Date() } },
        data: { usedAt: ahora },
      });
      if (consumido.count !== 1) {
        throw new HttpError(400, 'enlace_invalido', 'Ese enlace ya se uso.');
      }
      // Aqui si se cierran **todas**: quien restablece por haber perdido el
      // acceso no tiene ninguna sesion que valga la pena conservar, y puede que
      // otra persona tenga una abierta.
      await tx.refreshToken.updateMany({
        where: { userId: registro.userId, revokedAt: null },
        data: { revokedAt: ahora },
      });
      // Los demas enlaces pendientes de esa cuenta dejan de servir.
      await tx.passwordReset.updateMany({
        where: { userId: registro.userId, usedAt: null },
        data: { usedAt: ahora },
      });
    });

    return { reset: true };
  });
}

async function tieneAvatar(app: FastifyInstance, userId: string): Promise<boolean> {
  const fila = await app.prisma.user.findUnique({
    where: { id: userId },
    select: { avatarMimeType: true },
  });
  return fila !== null && fila.avatarMimeType !== null;
}
```

---

### `backend/api/src/modules/auth/routes.ts`

```ts
import { SCHEMA_VERSION } from '@uml/contracts';
import { Prisma } from '@prisma/client';
import type { FastifyInstance, FastifyReply } from 'fastify';
import { z } from 'zod';
import type { Config } from '../../config.js';
import { HttpError, conflict, unauthorized } from '../../lib/http-error.js';
import type { MailPort } from '../../lib/mail.js';
import { sendVerification } from './verification.js';
import { REFRESH_COOKIE, currentUser } from '../../plugins/auth.js';
import { hashPassword, verifyPassword } from './passwords.js';
import { createRefreshToken, hashRefreshToken } from './tokens.js';

const registerBody = z.object({
  email: z.string().email().max(254),
  displayName: z.string().trim().min(1).max(120),
  password: z.string().min(8).max(200),
});

const loginBody = z.object({
  email: z.string().email().max(254),
  password: z.string().min(1).max(200),
});

/**
 * Sesion: registro, inicio, renovacion y cierre (RF-A01 a RF-A03).
 *
 * El registro requiere activar el correo antes de emitir una sesión.
 * En desarrollo MAIL_PROVIDER=log permite leer el enlace en el servidor.
 */
export async function authRoutes(
  app: FastifyInstance,
  options: { config: Config; mail: MailPort },
): Promise<void> {
  const { config } = options;

  const cookieOptions = {
    httpOnly: true,
    sameSite: 'lax',
    secure: config.COOKIE_SECURE,
    path: '/',
    maxAge: config.REFRESH_TOKEN_TTL_SECONDS,
  } as const;

  /** Emite el par de tokens y deja el de refresco en la cookie. */
  async function issueSession(
    reply: FastifyReply,
    user: { id: string; email: string; displayName: string; sessionVersion: number },
    consumedRefreshId?: string,
  ): Promise<{ accessToken: string; user: { id: string; email: string; displayName: string } }> {
    const refresh = createRefreshToken();

    await app.prisma.$transaction(async (tx) => {
      // Serializa emisión y cambio de contraseña sobre la misma fila. Un login
      // o refresh iniciado antes de la revocación no puede crear otra sesión después.
      const current = await tx.user.updateMany({
        where: { id: user.id, sessionVersion: user.sessionVersion, emailVerifiedAt: { not: null } },
        data: { sessionVersion: user.sessionVersion },
      });
      if (current.count !== 1) throw unauthorized('La sesión fue revocada.');
      const emitido = await tx.refreshToken.create({
        data: {
          userId: user.id,
          tokenHash: refresh.hash,
          expiresAt: new Date(Date.now() + config.REFRESH_TOKEN_TTL_SECONDS * 1000),
        },
      });
      if (consumedRefreshId !== undefined) {
        const now = new Date();
        // El enlace al sucesor se guarda con la revocacion, en la misma fila y
        // la misma transaccion: si la emision falla, no queda un token revocado
        // apuntando a otro que no existe.
        const consumed = await tx.refreshToken.updateMany({
          where: {
            id: consumedRefreshId,
            userId: user.id,
            revokedAt: null,
            expiresAt: { gt: now },
          },
          data: { revokedAt: now, replacedById: emitido.id },
        });
        if (consumed.count !== 1) throw unauthorized('La sesión expiró.');
      }
    });

    reply.setCookie(REFRESH_COOKIE, refresh.token, cookieOptions);

    return {
      accessToken: await app.tokens.signAccessToken({
        userId: user.id,
        email: user.email,
        sessionVersion: user.sessionVersion,
      }),
      user: { id: user.id, email: user.email, displayName: user.displayName },
    };
  }

  app.post('/auth/register', async (request, reply) => {
    const body = registerBody.parse(request.body);
    const email = body.email.trim().toLowerCase();

    const existing = await app.prisma.user.findUnique({ where: { email } });
    if (existing !== null) {
      throw conflict('email_taken', 'Ya existe una cuenta con ese correo.');
    }

    let user: { id: string; email: string; displayName: string; sessionVersion: number };
    try {
      user = await app.prisma.user.create({
        data: {
          email,
          displayName: body.displayName,
          passwordHash: await hashPassword(body.password),
        },
      });
    } catch (error) {
      // El `findUnique` anterior mejora el camino normal, pero no evita que dos
      // registros simultaneos pasen la comprobacion. La restriccion UNIQUE es
      // la autoridad final y su carrera tambien debe conservar el contrato 409.
      if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') {
        throw conflict('email_taken', 'Ya existe una cuenta con ese correo.');
      }
      throw error;
    }

    reply.code(201);
    const emailSent = await sendVerification(app, config, options.mail, user);
    return { verificationRequired: true, emailSent };
  });

  app.post('/auth/login', async (request, reply) => {
    const body = loginBody.parse(request.body);
    const email = body.email.trim().toLowerCase();

    const user = await app.prisma.user.findUnique({ where: { email } });

    // Se comprueba la contrasena aunque el usuario no exista, contra un hash
    // ficticio, para que el tiempo de respuesta no revele que correos estan
    // registrados.
    const stored = user?.passwordHash ?? DUMMY_HASH;
    const valid = await verifyPassword(body.password, stored);

    if (user === null || !valid) {
      throw unauthorized('Correo o contrasena incorrectos.');
    }

    if (user.emailVerifiedAt === null) {
      throw new HttpError(
        403,
        'email_not_verified',
        'Activa tu cuenta desde el enlace del correo. Si no llegó, solicita otro enlace de activación.',
      );
    }

    return issueSession(reply, user);
  });

  /**
   * El sucesor de un token revocado, cuando su rotacion no llego a entregarse.
   *
   * Rotar en cada renovacion deja una ventana que la red puede partir por la
   * mitad: la peticion llega, el servidor revoca el token y emite otro, y la
   * respuesta se pierde —basta recargar en ese instante, que es justo lo que
   * hace quien acaba de recuperar la conexion—. El navegador conserva entonces
   * un token que el servidor ya no acepta y la sesion queda cerrada para
   * siempre, sin que nadie haya hecho nada malo.
   *
   * Se distingue de una reutilizacion real por el sucesor: si sigue **sin
   * usarse**, nadie recibio aquella respuesta. En cuanto el sucesor se usa, el
   * cliente legitimo si la recibio y presentar el token viejo vuelve a ser lo
   * que siempre fue —un replay— y se rechaza. Fuera del margen, tambien.
   */
  const MARGEN_ROTACION_MS = 30_000;

  async function rotacionSinEntregar(revocado: {
    revokedAt: Date | null;
    replacedById: string | null;
  }): Promise<{ id: string } | null> {
    if (revocado.revokedAt === null || revocado.replacedById === null) return null;
    if (Date.now() - revocado.revokedAt.getTime() > MARGEN_ROTACION_MS) return null;

    const sucesor = await app.prisma.refreshToken.findUnique({
      where: { id: revocado.replacedById },
      select: { id: true, revokedAt: true, expiresAt: true },
    });
    if (sucesor === null || sucesor.revokedAt !== null || sucesor.expiresAt <= new Date()) {
      return null;
    }
    return { id: sucesor.id };
  }

  /**
   * RF-A03. El token de refresco es rotativo: cada renovacion revoca el anterior
   * y entrega uno nuevo. Reutilizar uno ya rotado no funciona, salvo el caso que
   * describe `rotacionSinEntregar`: su sucesor sin estrenar y dentro del margen.
   */
  app.post('/auth/refresh', async (request, reply) => {
    const presented = request.cookies[REFRESH_COOKIE];
    if (presented === undefined) throw unauthorized('No hay sesion que renovar.');

    const stored = await app.prisma.refreshToken.findUnique({
      where: { tokenHash: hashRefreshToken(presented) },
      include: { user: true },
    });

    if (stored === null) {
      // No se borra la cookie: otra pestana pudo rotar el token mientras esta
      // peticion estaba en vuelo, y un Set-Cookie tardio borraria el nuevo.
      throw unauthorized('La sesion expiro. Inicia sesion de nuevo.');
    }

    if (stored.revokedAt !== null) {
      const sucesor = await rotacionSinEntregar(stored);
      if (sucesor === null) throw unauthorized('La sesion expiro. Inicia sesion de nuevo.');
      // Se consume el sucesor que nadie llego a recibir y se emite otro: la
      // sesion sigue teniendo un unico token vivo.
      return issueSession(reply, stored.user, sucesor.id);
    }

    if (stored.expiresAt <= new Date()) {
      reply.clearCookie(REFRESH_COOKIE, { path: '/' });
      throw unauthorized('La sesion expiro. Inicia sesion de nuevo.');
    }

    return issueSession(reply, stored.user, stored.id);
  });

  app.post('/auth/logout', async (request, reply) => {
    const presented = request.cookies[REFRESH_COOKIE];

    if (presented !== undefined) {
      await app.prisma.refreshToken.updateMany({
        where: { tokenHash: hashRefreshToken(presented), revokedAt: null },
        data: { revokedAt: new Date() },
      });
    }

    reply.clearCookie(REFRESH_COOKIE, { path: '/' });
    reply.code(204);
    return null;
  });

  app.get('/auth/me', { preHandler: app.authenticate }, async (request) => {
    const { userId } = currentUser(request);

    const user = await app.prisma.user.findUniqueOrThrow({
      where: { id: userId },
      select: { id: true, email: true, displayName: true, createdAt: true },
    });

    return { ...user, schemaVersion: SCHEMA_VERSION };
  });
}

/**
 * Hash de una contrasena que nadie tiene. Solo existe para que el camino del
 * usuario inexistente cueste lo mismo que el del usuario real.
 */
const DUMMY_HASH =
  'scrypt$65536$8$1$AAAAAAAAAAAAAAAAAAAAAA==$' +
  'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' +
  'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==';
```

---

### `backend/api/src/modules/auth/tokens.ts`

```ts
import { createHash, randomBytes } from 'node:crypto';
import { SignJWT, jwtVerify, type JWTPayload } from 'jose';

/**
 * Tokens de sesion (RF-A02 y RF-A03).
 *
 * Token de acceso de vida corta mas token de refresco rotativo. El de acceso es
 * el que se pasa al abrir el WebSocket, que es la razon por la que conviene un
 * token y no solo una cookie de sesion: el servidor de colaboracion tiene que
 * poder autorizar la conexion antes de entregar el documento (RA-15).
 */

export interface AccessTokenClaims {
  readonly userId: string;
  readonly email: string;
  readonly sessionVersion?: number;
}

export interface TokenIssuer {
  signAccessToken(claims: AccessTokenClaims): Promise<string>;
  verifyAccessToken(token: string): Promise<AccessTokenClaims>;
}

export class InvalidTokenError extends Error {
  public constructor(message = 'El token no es valido o expiro.') {
    super(message);
    this.name = 'InvalidTokenError';
  }
}

const ISSUER = 'plataforma-uml';
const AUDIENCE = 'plataforma-uml-clients';

export function createTokenIssuer(secret: string, accessTtlSeconds: number): TokenIssuer {
  const key = new TextEncoder().encode(secret);

  return {
    async signAccessToken(claims) {
      return new SignJWT({
        email: claims.email,
        sessionVersion: claims.sessionVersion ?? 0,
      } satisfies JWTPayload)
        .setProtectedHeader({ alg: 'HS256' })
        .setSubject(claims.userId)
        .setIssuer(ISSUER)
        .setAudience(AUDIENCE)
        .setIssuedAt()
        .setExpirationTime(`${accessTtlSeconds}s`)
        .sign(key);
    },

    async verifyAccessToken(token) {
      let payload: JWTPayload;
      try {
        ({ payload } = await jwtVerify(token, key, {
          issuer: ISSUER,
          audience: AUDIENCE,
          algorithms: ['HS256'],
        }));
      } catch {
        // El motivo exacto no se propaga: distinguir "firma invalida" de
        // "expirado" solo ayuda a quien esta probando tokens.
        throw new InvalidTokenError();
      }

      const userId = payload.sub;
      const email = payload['email'];
      // Los tokens anteriores a la migración pertenecen a la versión inicial.
      const sessionVersion = payload['sessionVersion'] ?? 0;
      if (
        typeof userId !== 'string' ||
        typeof email !== 'string' ||
        typeof sessionVersion !== 'number' ||
        !Number.isSafeInteger(sessionVersion) ||
        sessionVersion < 0
      ) {
        throw new InvalidTokenError();
      }

      return { userId, email, sessionVersion };
    },
  };
}

/**
 * El token de refresco es un secreto opaco, no un JWT.
 *
 * No necesita transportar informacion —siempre se busca en la base para poder
 * revocarlo— y no siendo verificable sin consultar, un token robado deja de
 * servir en cuanto se rota o se revoca.
 */
export function createRefreshToken(): { token: string; hash: string } {
  const token = randomBytes(48).toString('base64url');
  return { token, hash: hashRefreshToken(token) };
}

/**
 * Se guarda el hash, nunca el token.
 *
 * SHA-256 basta aqui, a diferencia de las contrasenas: el token tiene 384 bits
 * de entropia aleatoria, asi que no hay diccionario que probar y una derivacion
 * lenta solo anadiria latencia a cada renovacion.
 */
export function hashRefreshToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}
```

---

### `backend/api/src/modules/auth/verification.ts`

```ts
import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import type { Config } from '../../config.js';
import { badRequest } from '../../lib/http-error.js';
import type { MailPort } from '../../lib/mail.js';
import { createRefreshToken, hashRefreshToken } from './tokens.js';

const emailBody = z.object({ email: z.string().trim().email().max(254) });
const tokenBody = z.object({ token: z.string().min(20).max(200) });
const LIFETIME_MS = 24 * 60 * 60 * 1000;
const COOLDOWN_MS = 60 * 1000;

/** Reserva el envío atómicamente para limitar también peticiones desde distintas IP. */
export async function sendVerification(
  app: FastifyInstance,
  config: Config,
  mail: MailPort,
  user: { id: string; email: string },
): Promise<boolean> {
  const previous = await app.prisma.user.findUniqueOrThrow({ where: { id: user.id } });
  const token = createRefreshToken();
  const now = new Date();
  const reserved = await app.prisma.user.updateMany({
    where: {
      id: user.id,
      emailVerifiedAt: null,
      OR: [
        { emailVerificationSentAt: null },
        { emailVerificationSentAt: { lte: new Date(now.getTime() - COOLDOWN_MS) } },
      ],
    },
    data: {
      emailVerificationTokenHash: token.hash,
      emailVerificationExpiresAt: new Date(now.getTime() + LIFETIME_MS),
      emailVerificationSentAt: now,
    },
  });
  if (reserved.count !== 1) return false;

  try {
    // Fragmento: el token no viaja en los registros HTTP ni en el Referer.
    const link = `${config.WEB_ORIGIN}/activar#token=${token.token}`;
    await mail.send({
      to: user.email,
      subject: 'Activa tu cuenta — UMLFORGE AI',
      text: [
        'Confirma tu correo para activar tu cuenta de UMLFORGE AI.',
        '',
        'Abre este enlace y pulsa «Activar mi cuenta». Caduca en 24 horas y solo se puede usar una vez:',
        link,
        '',
        'Si no creaste esta cuenta, ignora este mensaje.',
      ].join('\n'),
    });
    return true;
  } catch {
    // No dejar bloqueada la cuenta ni invalidar el último enlace entregado.
    await app.prisma.user.updateMany({
      where: { id: user.id, emailVerificationTokenHash: token.hash, emailVerifiedAt: null },
      data: {
        emailVerificationTokenHash: previous.emailVerificationTokenHash,
        emailVerificationExpiresAt: previous.emailVerificationExpiresAt,
        emailVerificationSentAt: previous.emailVerificationSentAt,
      },
    });
    app.log.error({ provider: mail.name }, 'no se pudo enviar el correo de activación');
    return false;
  }
}

export async function verificationRoutes(
  app: FastifyInstance,
  { config, mail }: { config: Config; mail: MailPort },
): Promise<void> {
  app.post('/auth/verification/resend', async (request, reply) => {
    const { email } = emailBody.parse(request.body);
    const user = await app.prisma.user.findUnique({ where: { email: email.toLowerCase() } });
    if (user !== null && user.emailVerifiedAt === null) {
      await sendVerification(app, config, mail, user);
    }
    // Misma respuesta para inexistentes, activadas y envíos limitados o fallidos.
    reply.code(202);
    return { sent: true };
  });

  app.post('/auth/verification/confirm', async (request) => {
    const { token } = tokenBody.parse(request.body);
    const result = await app.prisma.user.updateMany({
      where: {
        emailVerificationTokenHash: hashRefreshToken(token),
        emailVerificationExpiresAt: { gt: new Date() },
        emailVerifiedAt: null,
      },
      data: {
        emailVerifiedAt: new Date(),
        emailVerificationTokenHash: null,
        emailVerificationExpiresAt: null,
      },
    });
    if (result.count !== 1) {
      throw badRequest(
        'verification_invalid',
        'El enlace caducó o ya fue utilizado. Pide uno nuevo o inicia sesión si ya activaste tu cuenta.',
      );
    }
    return { verified: true };
  });
}
```

---

### `backend/api/src/modules/boards/routes.ts`

```ts
import { BOARD_TYPES, collaborationRoomName, emptyBoardState } from '@uml/contracts';
import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { notFound } from '../../lib/http-error.js';
import { currentUser } from '../../plugins/auth.js';
import { requireMembership, requireWriteAccess } from '../projects/membership.js';

const boardBody = z.object({
  displayName: z.string().trim().min(1).max(120),
  type: z.enum(BOARD_TYPES).default('CLASS_DIAGRAM'),
});

const renameBody = z.object({
  displayName: z.string().trim().min(1).max(120),
});

const projectParams = z.object({ projectId: z.string().uuid() });
const boardParams = z.object({ boardId: z.string().uuid() });

/**
 * Pizarras (RF-002, RF-003 y RF-005).
 *
 * Cada pizarra tiene su propia sesion colaborativa y su propio documento
 * (RF-004). Aqui solo viven los metadatos: el estado vivo va por el proceso de
 * colaboracion, y estas rutas devuelven el nombre de sala con el que conectarse.
 */
export async function boardRoutes(app: FastifyInstance): Promise<void> {
  app.addHook('preHandler', app.authenticate);

  app.get('/projects/:projectId/boards', async (request) => {
    const { projectId } = projectParams.parse(request.params);
    const { userId } = currentUser(request);
    await requireMembership(app.prisma, projectId, userId);

    const boards = await app.prisma.board.findMany({
      where: { projectId },
      orderBy: { createdAt: 'asc' },
      select: { id: true, projectId: true, displayName: true, type: true, createdAt: true },
    });

    return boards.map((board) => ({ ...board, room: collaborationRoomName(projectId, board.id) }));
  });

  app.post('/projects/:projectId/boards', async (request, reply) => {
    const { projectId } = projectParams.parse(request.params);
    const body = boardBody.parse(request.body);
    const { userId } = currentUser(request);
    await requireWriteAccess(app.prisma, projectId, userId);

    // Se crea la version 1 del snapshot canonico, vacia. Asi toda pizarra tiene
    // una proyeccion inspeccionable desde el primer momento, sin que nadie tenga
    // que abrirla antes. El documento binario lo crea el proceso de colaboracion
    // la primera vez que alguien entra (RA-11). La escritura anidada es atomica:
    // nunca puede quedar una pizarra creada sin su snapshot inicial.
    const inicial = emptyBoardState();
    const board = await app.prisma.board.create({
      data: {
        projectId,
        displayName: body.displayName,
        type: body.type,
        snapshots: { create: { version: 1, canonicalJson: inicial.semantic } },
      },
      select: { id: true, projectId: true, displayName: true, type: true, createdAt: true },
    });

    reply.code(201);
    return { ...board, room: collaborationRoomName(projectId, board.id) };
  });

  app.get('/boards/:boardId', async (request) => {
    const { boardId } = boardParams.parse(request.params);
    const { userId } = currentUser(request);

    const board = await findBoard(app, boardId);
    const role = await requireMembership(app.prisma, board.projectId, userId);

    // La version 1 es la proyeccion vigente; las posteriores son generaciones
    // congeladas y no representan los cambios hechos despues de generar.
    const snapshot = await app.prisma.boardSnapshot.findUnique({
      where: { boardId_version: { boardId, version: 1 } },
      select: { version: true, canonicalJson: true, updatedAt: true },
    });

    return {
      ...board,
      role,
      room: collaborationRoomName(board.projectId, board.id),
      snapshot,
    };
  });

  app.patch('/boards/:boardId', async (request) => {
    const { boardId } = boardParams.parse(request.params);
    const body = renameBody.parse(request.body);
    const { userId } = currentUser(request);

    const board = await findBoard(app, boardId);
    await requireWriteAccess(app.prisma, board.projectId, userId);

    return app.prisma.board.update({
      where: { id: boardId },
      data: { displayName: body.displayName },
      select: { id: true, projectId: true, displayName: true, type: true, createdAt: true },
    });
  });

  app.delete('/boards/:boardId', async (request, reply) => {
    const { boardId } = boardParams.parse(request.params);
    const { userId } = currentUser(request);

    const board = await findBoard(app, boardId);
    await requireWriteAccess(app.prisma, board.projectId, userId);

    await app.prisma.board.delete({ where: { id: boardId } });

    reply.code(204);
    return null;
  });
}

async function findBoard(
  app: FastifyInstance,
  boardId: string,
): Promise<{ id: string; projectId: string; displayName: string; type: string; createdAt: Date }> {
  const board = await app.prisma.board.findUnique({
    where: { id: boardId },
    select: { id: true, projectId: true, displayName: true, type: true, createdAt: true },
  });

  if (board === null) throw notFound('La pizarra no existe.');
  return board;
}
```

---

### `backend/api/src/modules/generation/routes.ts`

```ts
import { SCHEMA_VERSION, collaborationRoomName, semanticModelSchema } from '@uml/contracts';
import {
  buildGenerationIr,
  InvalidGenerationModelError,
  type GenerationIr,
} from '@uml/generation-ir';
import { InvalidIdentifierError, isJavaReserved } from '@uml/domain-core';
import {
  generateSpringProject,
  generateMobileProject,
  sha256,
  templatesFingerprint,
} from '@uml/generator-backend';
import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import type { Config } from '../../config.js';
import { HttpError, notFound } from '../../lib/http-error.js';
import { currentUser } from '../../plugins/auth.js';
import { requireMembership, requireWriteAccess } from '../projects/membership.js';

const boardParams = z.object({ boardId: z.string().uuid() });
const generationParams = z.object({ generationId: z.string().uuid() });

const generateBody = z.object({
  includeMobile: z.boolean().default(false),
  /** Paquete Java raiz del proyecto generado. */
  basePackage: z
    .string()
    .trim()
    .regex(/^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)*$/, 'No es un paquete Java valido.')
    .refine(
      (value) => value.split('.').every((segment) => !isJavaReserved(segment)),
      'El paquete contiene una palabra reservada de Java.',
    )
    .optional(),
});

const downloadQuery = z.object({
  target: z.enum(['spring', 'mobile']).default('spring'),
});

/**
 * Generacion de codigo desde una pizarra (RF-060 a RF-072, RF-080 a RF-084).
 *
 * **Lo que esta ruta aporta sobre el motor.** El generador ya existia y el banco
 * lo verifica sobre siete modelos; lo que faltaba era el camino desde la pizarra
 * viva hasta un ZIP descargable, que son dos pasos del guion de la defensa.
 *
 * **RA-08 y CA-060.1: se congela el snapshot, no el estado vivo.** Generar hace
 * dos cosas antes de emitir nada: pide al proceso de colaboracion que escriba el
 * documento vivo, y **copia** esa proyeccion a una version nueva que ya nadie
 * volvera a tocar. Quien siga editando escribira sobre la proyeccion viva; el
 * ZIP corresponde a la copia. Sin la copia, descargar el mismo artefacto dos
 * dias despues daria un proyecto distinto.
 *
 * **Por que no se guarda el ZIP.** La emision es determinista (RA-07: mismas
 * plantillas, misma IR, fechas fijas dentro del ZIP), asi que del mismo snapshot
 * salen siempre los mismos bytes. Guardar el binario obligaria a decidir donde
 * —base de datos, disco, almacenamiento de objetos— y a limpiarlo; regenerar
 * desde la version congelada da el mismo resultado y deja la base pequena. Lo
 * que se registra es **que** se genero, cuando y sobre que version, que es lo
 * que pide RF-072.
 *
 * **Y por que hace falta un manifiesto.** «Regenerar da el mismo resultado» solo
 * es cierto si se congela **todo** lo que entra en la emision, no solo el
 * modelo. Faltaban tres cosas y las tres se notaban:
 *
 *   - el `basePackage` que la persona escribia se usaba para responder y se
 *     perdia; **todas** las descargas salian con el paquete por defecto;
 *   - el nombre del proyecto se releia de la pizarra, asi que renombrarla
 *     cambiaba el artefacto de una generacion anterior;
 *   - las plantillas podian cambiar por debajo, y la descarga de la semana
 *     siguiente entregaba otros bytes bajo el mismo identificador.
 *
 * Ahora cada generacion congela nombre, paquete, version de esquema, huella de
 * plantillas y el SHA-256 de cada objetivo. Al descargar se compara: si los
 * bytes ya no son los mismos, se dice — no se entrega otro archivo en silencio.
 */
export async function generationRoutes(
  app: FastifyInstance,
  options: { config: Config },
): Promise<void> {
  app.addHook('preHandler', app.authenticate);

  app.post('/boards/:boardId/generations', async (request, reply) => {
    const { boardId } = boardParams.parse(request.params);
    const body = generateBody.parse(request.body ?? {});
    const { userId } = currentUser(request);

    const board = await findBoard(app, boardId);
    // Generar no modifica la pizarra, pero produce el entregable del proyecto y
    // queda registrado con nombre y apellido. La tabla de roles de `membership`
    // lo asigna a EDITOR: un VIEWER mira, no produce artefactos.
    await requireWriteAccess(app.prisma, board.projectId, userId);

    // Lo que la persona ve en pantalla puede ir por delante de la base: la
    // proyeccion se guarda con retardo. Se pide al proceso de colaboracion que
    // la vuelque antes de congelar nada.
    await volcarDocumento(options.config, board, request.headers.authorization);

    // La IR se valida dentro de la misma transaccion y **antes** del INSERT. Asi
    // un modelo o nombre invalido no deja una version congelada huerfana.
    const { snapshot, value: ir } = await congelarSnapshot(app, boardId, (congelado) =>
      construirIr(congelado, board.displayName, body.basePackage),
    );

    const generation = await app.prisma.generation.create({
      data: {
        boardId,
        snapshotVersion: snapshot.version,
        createdBy: userId,
        // El manifiesto: lo que la descarga volvera a usar en lugar de releer
        // el estado actual de la pizarra.
        projectName: board.displayName,
        artifactId: ir.project.artifactId,
        basePackage: ir.project.groupId,
        schemaVersion: SCHEMA_VERSION,
        templatesHash: await templatesFingerprint(),
        status: 'CREATING',
      },
      select: { id: true, snapshotVersion: true, createdAt: true },
    });

    // La fila nace CREATING y solo pasa a READY cuando el artefacto se ha
    // emitido de verdad. Antes se registraba el exito sin comprobarlo: una
    // generacion podia figurar en el historial y fallar al descargarla.
    let huellas: { spring: string; mobile?: string };
    try {
      huellas = await emitirHuellas(ir, body.includeMobile);
    } catch (error) {
      await app.prisma.generation.update({
        where: { id: generation.id },
        // Solo el mensaje, nunca la traza: esto se muestra en la interfaz.
        data: { status: 'FAILED', error: mensajeDeError(error) },
      });
      throw error;
    }

    await app.prisma.generation.update({
      where: { id: generation.id },
      data: { status: 'READY', springSha256: huellas.spring, mobileSha256: huellas.mobile ?? null },
    });

    reply.code(201);
    return {
      ...generation,
      boardId,
      status: 'READY',
      artifactName: `${ir.project.artifactId}.zip`,
      basePackage: ir.project.groupId,
      entities: ir.entities.length,
      sha256: huellas,
      downloads: {
        spring: `/api/generations/${generation.id}/download?target=spring`,
        ...(huellas.mobile
          ? { mobile: `/api/generations/${generation.id}/download?target=mobile` }
          : {}),
      },
    };
  });

  app.get('/boards/:boardId/generations', async (request) => {
    const { boardId } = boardParams.parse(request.params);
    const { userId } = currentUser(request);

    const board = await findBoard(app, boardId);
    await requireMembership(app.prisma, board.projectId, userId);
    await marcarInterrumpidas(app, { boardId });

    return app.prisma.generation.findMany({
      where: { boardId },
      orderBy: { createdAt: 'desc' },
      take: 50,
      select: {
        id: true,
        snapshotVersion: true,
        createdAt: true,
        status: true,
        projectName: true,
        basePackage: true,
        templatesHash: true,
        springSha256: true,
        mobileSha256: true,
        error: true,
        author: { select: { id: true, displayName: true, email: true } },
      },
    });
  });

  app.get('/generations/:generationId/download', async (request, reply) => {
    const { generationId } = generationParams.parse(request.params);
    // Se sigue validando aunque solo haya un objetivo: `?target=dart` en un
    // enlace viejo tiene que fallar con un 400 claro, no entregar el backend.
    const { target } = downloadQuery.parse(request.query ?? {});
    const { userId } = currentUser(request);

    // Marcar una emision interrumpida escribe en el proyecto. La autorizacion
    // debe comprobarse antes, incluso si finalmente se rechaza la descarga.
    const access = await app.prisma.generation.findUnique({
      where: { id: generationId },
      select: { board: { select: { projectId: true } } },
    });
    if (access === null) throw notFound('La generacion no existe.');
    await requireMembership(app.prisma, access.board.projectId, userId);
    await marcarInterrumpidas(app, { generationId });

    const generation = await app.prisma.generation.findUnique({
      where: { id: generationId },
      select: {
        snapshotVersion: true,
        status: true,
        error: true,
        projectName: true,
        basePackage: true,
        templatesHash: true,
        springSha256: true,
        mobileSha256: true,
        board: { select: { id: true, projectId: true } },
        snapshot: { select: { canonicalJson: true } },
      },
    });

    if (generation === null) throw notFound('La generacion no existe.');
    if (generation.status !== 'READY') {
      throw new HttpError(
        409,
        'generation_not_ready',
        generation.status === 'FAILED'
          ? `Esa generacion fallo y no tiene artefacto: ${generation.error ?? 'sin detalle'}`
          : 'Esa generacion todavia se esta emitiendo.',
      );
    }

    // Se regenera desde la version congelada **y con el manifiesto**, no desde
    // el estado actual: ni el nombre de la pizarra ni el paquete se releen, que
    // es lo que hacia que la descarga cambiara con el tiempo.
    const ir = construirIr(
      { version: generation.snapshotVersion, canonicalJson: generation.snapshot.canonicalJson },
      generation.projectName,
      generation.basePackage,
    );

    if (target === 'mobile' && generation.mobileSha256 === null)
      throw new HttpError(
        409,
        'mobile_not_generated',
        'Esta version no incluye Android. Genera de nuevo activando la opcion Flutter.',
      );
    const { nombre, zip } = await armarArtefacto(ir, target);

    // La comprobacion que sostiene ADR-018. Si los bytes ya no son los que se
    // registraron —porque cambio una plantilla o el generador—, entregar el
    // archivo bajo el mismo identificador seria mentir en silencio.
    const registrado = target === 'mobile' ? generation.mobileSha256 : generation.springSha256;
    const actual = sha256(zip);

    if (registrado !== null && registrado !== actual) {
      throw new HttpError(
        409,
        'artifact_drifted',
        'Esta generacion ya no se puede reproducir: el codigo emitido hoy no coincide ' +
          'byte a byte con el que se registro. Genera de nuevo desde la pizarra.',
        {
          registrado,
          actual,
          plantillasRegistradas: generation.templatesHash,
          plantillasActuales: await templatesFingerprint(),
        },
      );
    }

    reply
      .header('content-type', 'application/zip')
      .header('content-disposition', `attachment; filename="${nombre}"`)
      .header('content-length', String(zip.byteLength))
      // Permite comprobar la descarga sin abrirla, y es lo que compara la prueba.
      .header('x-artifact-sha256', actual);

    return reply.send(zip);
  });

  /**
   * Elimina una generacion del historial (limpieza del servidor).
   *
   * El ZIP nunca se guardo en disco: lo unico que ocupa espacio es la fila del
   * manifiesto y la **copia congelada** del snapshot sobre la que se regenera.
   * Borrar la generacion borra tambien esa copia cuando ya nadie la referencia;
   * la version 1 —la proyeccion viva que reescribe la colaboracion— no se toca
   * nunca desde aqui.
   *
   * Es una accion de EDITOR, como generar: quien puede producir el entregable
   * puede retirarlo. Un VIEWER lo descarga, no lo administra.
   */
  app.delete('/generations/:generationId', async (request, reply) => {
    const { generationId } = generationParams.parse(request.params);
    const { userId } = currentUser(request);

    const generation = await app.prisma.generation.findUnique({
      where: { id: generationId },
      select: { boardId: true, snapshotVersion: true, board: { select: { projectId: true } } },
    });
    if (generation === null) throw notFound('La generacion no existe.');
    await requireWriteAccess(app.prisma, generation.board.projectId, userId);

    await app.prisma.$transaction(async (tx) => {
      await tx.generation.delete({ where: { id: generationId } });

      // Cada generacion congela su propia copia, pero se comprueba igual: si
      // alguna vez dos compartieran version, borrar una no puede dejar a la
      // otra sin snapshot y por tanto sin descarga.
      const referencias = await tx.generation.count({
        where: { boardId: generation.boardId, snapshotVersion: generation.snapshotVersion },
      });
      if (generation.snapshotVersion > 1 && referencias === 0) {
        await tx.boardSnapshot.delete({
          where: {
            boardId_version: { boardId: generation.boardId, version: generation.snapshotVersion },
          },
        });
      }
    });

    return reply.code(204).send();
  });
}

/**
 * Una fila CREATING solo vive mientras la peticion POST esta emitiendo. Si el
 * proceso se reinicia en medio, no hay tarea en segundo plano que vaya a
 * terminarla: dejarla asi para siempre comunica un progreso que ya no existe.
 */
async function marcarInterrumpidas(
  app: FastifyInstance,
  filtro: { boardId: string } | { generationId: string },
): Promise<void> {
  await app.prisma.generation.updateMany({
    where: {
      ...('boardId' in filtro ? { boardId: filtro.boardId } : { id: filtro.generationId }),
      status: 'CREATING',
      createdAt: { lt: new Date(Date.now() - 5 * 60_000) },
    },
    data: {
      status: 'FAILED',
      error: 'La emision se interrumpio antes de terminar. Genera el proyecto nuevamente.',
    },
  });
}

/**
 * Emite los dos objetivos y devuelve su huella.
 *
 * Se emiten **antes** de dar la generacion por buena. Cuesta unos cientos de
 * milisegundos sobre un modelo del tamano que exige RNF-03, y a cambio una
 * generacion que figura en el historial es una que se puede descargar.
 */
async function emitirHuellas(
  ir: GenerationIr,
  mobile = false,
): Promise<{ spring: string; mobile?: string }> {
  const spring = await armarArtefacto(ir);
  return {
    spring: sha256(spring.zip),
    ...(mobile ? { mobile: sha256((await armarArtefacto(ir, 'mobile')).zip) } : {}),
  };
}

/** Lo que se le puede ensenar a un usuario de un fallo del servidor. */
function mensajeDeError(error: unknown): string {
  const mensaje = error instanceof Error ? error.message : String(error);
  return mensaje.length > 500 ? `${mensaje.slice(0, 500)}…` : mensaje;
}

async function armarArtefacto(
  ir: GenerationIr,
  target: 'spring' | 'mobile' = 'spring',
): Promise<{ nombre: string; zip: Buffer }> {
  const proyecto = await (target === 'mobile' ? generateMobileProject : generateSpringProject)(ir);
  return { nombre: proyecto.artifactName, zip: proyecto.zip };
}

function construirIr(
  snapshot: { version: number; canonicalJson: unknown },
  projectName: string,
  basePackage?: string,
): GenerationIr {
  try {
    return buildGenerationIr({
      model: semanticModelSchema.parse(snapshot.canonicalJson),
      snapshotVersion: snapshot.version,
      projectName,
      ...(basePackage === undefined ? {} : { basePackage }),
    });
  } catch (error) {
    // Un modelo con errores no se genera (ADR-003: los errores bloquean la
    // generacion, no la edicion). Se devuelven los hallazgos tal cual para que
    // la interfaz muestre los mismos que el panel de validacion, y no un texto
    // distinto que obligue a adivinar cual es cual.
    if (error instanceof InvalidGenerationModelError) {
      throw new HttpError(
        422,
        'model_not_generable',
        'El modelo tiene errores y no se puede generar.',
        { issues: error.issues },
      );
    }
    if (error instanceof InvalidIdentifierError) {
      throw new HttpError(
        422,
        'project_name_not_generable',
        'El nombre de la pizarra no puede convertirse en identificadores de codigo.',
        { reason: error.message },
      );
    }
    throw error;
  }
}

/**
 * Pide al proceso de colaboracion que escriba el documento vivo (RA-08).
 *
 * **Si esto falla, no se genera.** Continuar con lo que hubiera en la base
 * produciria un ZIP silenciosamente atrasado, y nadie lo notaria hasta abrirlo:
 * un error visible es mucho mejor que un proyecto al que le falta la ultima
 * clase justo el dia de la defensa.
 *
 * Se reenvia el token de quien pide: el proceso de colaboracion resuelve la
 * misma autorizacion que para entrar a la sala (RA-15), asi que no hace falta
 * ningun secreto nuevo entre procesos.
 */
async function volcarDocumento(
  config: Config,
  board: { id: string; projectId: string },
  authorization: string | undefined,
): Promise<void> {
  const token = authorization?.replace(/^Bearer /i, '') ?? '';

  let respuesta: Response;
  try {
    respuesta = await fetch(`${config.COLLAB_INTERNAL_URL}/flush`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ room: collaborationRoomName(board.projectId, board.id), token }),
      signal: AbortSignal.timeout(5000),
    });
  } catch {
    throw new HttpError(
      503,
      'collab_unreachable',
      'No se pudo contactar con el proceso de colaboracion para congelar la pizarra. ' +
        'Reintenta en unos segundos.',
    );
  }

  if (!respuesta.ok) {
    throw new HttpError(
      503,
      'collab_flush_failed',
      'El proceso de colaboracion no pudo guardar el estado actual de la pizarra.',
    );
  }
}

/**
 * Congela una version inmutable a partir de la proyeccion viva (RA-08).
 *
 * La version 1 es la foto vigente: el proceso de colaboracion la reescribe en
 * cada volcado. Generar sobre ella significaria que descargar el mismo artefacto
 * dos dias despues daria un proyecto distinto. Por eso se **copia** a una version
 * nueva, que ya nadie toca, y la generacion apunta a esa.
 *
 * Es tambien lo que hace cierto CA-060.1: quien siga editando escribira en la
 * version 1; el ZIP corresponde a la copia.
 */
async function congelarSnapshot<T>(
  app: FastifyInstance,
  boardId: string,
  preparar: (snapshot: { version: number; canonicalJson: unknown }) => T,
): Promise<{ snapshot: { version: number; canonicalJson: unknown }; value: T }> {
  // Leer el maximo y despues insertar maximo+1 son dos operaciones, y dos
  // generaciones simultaneas leian el mismo maximo: la segunda moria con un 500
  // por clave duplicada, sin ninguna explicacion util.
  //
  // Calcularlo dentro del INSERT **no** basta: en el nivel de aislamiento por
  // defecto, dos transacciones no ven la fila que la otra todavia no ha
  // confirmado, asi que las dos calculan el mismo numero. Lo comprobo la prueba
  // de cuatro peticiones simultaneas, que seguia dando dos 500.
  //
  // Se bloquea la fila de la version viva mientras se decide el numero. Las
  // generaciones de la **misma** pizarra se ponen en fila —son milisegundos— y
  // las de pizarras distintas no se estorban.
  return app.prisma.$transaction(async (tx) => {
    const bloqueada = await tx.$queryRaw<{ canonicalJson: unknown }[]>`
      SELECT "canonicalJson"
      FROM "board_snapshots"
      WHERE "boardId" = ${boardId}::uuid AND "version" = 1
      FOR UPDATE
    `;

    const viva = bloqueada[0];
    if (viva === undefined) throw notFound('La pizarra no tiene ningun snapshot todavia.');

    const numeros = await tx.$queryRaw<{ version: number }[]>`
      SELECT (COALESCE(MAX("version"), 1) + 1)::int AS "version"
      FROM "board_snapshots"
      WHERE "boardId" = ${boardId}::uuid
    `;

    const version = numeros[0]?.version;
    if (version === undefined) {
      throw new HttpError(500, 'snapshot_no_congelado', 'No se pudo congelar la version.');
    }

    const snapshot = { version, canonicalJson: viva.canonicalJson };
    const value = preparar(snapshot);

    await tx.$executeRaw`
      INSERT INTO "board_snapshots" ("boardId", "version", "canonicalJson", "updatedAt")
      VALUES (${boardId}::uuid, ${version}, ${viva.canonicalJson}::jsonb, NOW())
    `;

    return { snapshot, value };
  });
}

async function findBoard(
  app: FastifyInstance,
  boardId: string,
): Promise<{ id: string; projectId: string; displayName: string }> {
  const board = await app.prisma.board.findUnique({
    where: { id: boardId },
    select: { id: true, projectId: true, displayName: true },
  });

  if (board === null) throw notFound('La pizarra no existe.');
  return board;
}
```

---

### `backend/api/src/modules/import/routes.ts`

```ts
import { layoutSchema, semanticModelSchema, type SemanticModel } from '@uml/contracts';
import {
  MAX_PROPOSAL_OPERATIONS,
  ProviderContractError,
  ProviderUnavailableError,
  createAiPorts,
  loadAiConfig,
  pareceTruncada,
  resolveProposal,
  type AiPorts,
  type AssistantOperation,
  type BatchProposal,
} from '@uml/ai';
import {
  XmiParseError,
  parseXmi,
  serializeToEnterpriseArchitect,
  serializeToXmi251,
  xmiToBatch,
} from '@uml/xmi';
import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { HttpError } from '../../lib/http-error.js';
import { currentUser } from '../../plugins/auth.js';
import { requireMembership, requireWriteAccess } from '../projects/membership.js';

/**
 * Importacion por fotografia y XMI, y exportacion a XMI (M4 y M5).
 *
 * **Nada se aplica aqui.** Las dos importaciones producen un candidato que la
 * interfaz muestra para corregir, y el navegador lo aplica por el mismo camino
 * que la interfaz grafica y que el asistente. Un candidato que no se puede
 * corregir no sirve: el reconocimiento de un pizarron se va a equivocar en algo
 * (CA-042.1).
 */

const boardParams = z.object({ boardId: z.string().uuid() });

/**
 * Ocho megabytes en base64 son unos seis de imagen: una fotografia de movil
 * cabe de sobra. El limite existe porque sin el, una peticion grande ocupa
 * memoria del proceso antes de que nadie la valide (RNF-08).
 */
const MAX_IMAGE_BASE64 = 8_000_000;

/**
 * El limite de cuerpo de Fastify es un megabyte por defecto, y una fotografia de
 * movil en base64 pasa de eso siempre. Sin subirlo, la ruta de imagen no habria
 * aceptado **ninguna foto real**: la rechazaria con un 413 antes de mirarla, y
 * el limite de arriba nunca se habria alcanzado.
 *
 * Se sube por ruta y no globalmente: el resto de la API no tiene por que aceptar
 * cuerpos de megabytes.
 */
const IMAGE_BODY_LIMIT = 12 * 1024 * 1024;
const XMI_BODY_LIMIT = 24 * 1024 * 1024;

const imageBody = z.object({
  image: z.string().min(1).max(MAX_IMAGE_BASE64),
  mediaType: z.string().min(1).max(100),
  mode: z.enum(['ADD', 'REPLACE']).default('ADD'),
  model: semanticModelSchema,
});

const xmiBody = z.object({
  xml: z.string().min(1).max(20_000_000),
  mode: z.enum(['ADD', 'REPLACE']).default('ADD'),
  model: semanticModelSchema,
});

export async function importRoutes(
  app: FastifyInstance,
  options: { ports?: AiPorts } = {},
): Promise<void> {
  const ports = options.ports ?? createAiPorts(loadAiConfig());

  app.addHook('preHandler', app.authenticate);

  /** RF-040 a RF-043: fotografia a candidato editable. */
  app.post('/boards/:boardId/import/image', { bodyLimit: IMAGE_BODY_LIMIT }, async (request) => {
    const { boardId } = boardParams.parse(request.params);
    const body = imageBody.parse(request.body);
    const { userId } = currentUser(request);

    const board = await findBoard(app, boardId);
    await requireWriteAccess(app.prisma, board.projectId, userId);

    const { proposal, usage } = await conProveedor(() =>
      ports.vision.extractModel({
        image: Buffer.from(body.image, 'base64'),
        mediaType: body.mediaType,
      }),
    );

    // Tolerante: la lectura ya se pago. Lo que no se pueda resolver —una clase
    // que ya estaba, una duda que el modelo dejo escrita— se omite y viaja como
    // aviso con el candidato, en vez de tirar todo y obligar a otra lectura.
    const { skipped = [], ...outcome } = resolveProposal({
      proposal: conBorradoPrevio(proposal, body.mode, body.model),
      model: body.model,
      actorId: userId,
      origin: 'IMAGE',
      tolerante: true,
    });

    request.log.info(
      {
        boardId,
        origin: 'IMAGE',
        provider: usage?.provider,
        latencyMs: usage?.latencyMs,
        outcome: outcome.kind,
        operations: proposal.operations.length,
        skipped: skipped.length,
      },
      'importacion por imagen',
    );

    // Si la lectura llego al tope, lo mas probable es que la fotografia tuviera
    // mas de lo que cabe en una propuesta. Se avisa en lugar de entregar un
    // modelo incompleto con aspecto de completo: quien importa un diagrama de
    // ocho tablas no puede tener que contar los atributos para descubrirlo.
    const warnings = [
      ...skipped,
      ...(pareceTruncada(proposal)
        ? [
            {
              element: 'la fotografia',
              reason:
                `La lectura alcanzo el maximo de ${MAX_PROPOSAL_OPERATIONS} operaciones, ` +
                'asi que puede faltar contenido. Revisa el candidato antes de aplicarlo, y si ' +
                'el diagrama es muy grande, importalo por partes.',
            },
          ]
        : []),
    ];

    return { ...outcome, rationale: proposal.rationale ?? null, warnings };
  });

  /** RF-051 y RF-052: XMI a candidato editable, validado contra el dominio. */
  app.post('/boards/:boardId/import/xmi', { bodyLimit: XMI_BODY_LIMIT }, async (request) => {
    const { boardId } = boardParams.parse(request.params);
    const body = xmiBody.parse(request.body);
    const { userId } = currentUser(request);

    const board = await findBoard(app, boardId);
    await requireWriteAccess(app.prisma, board.projectId, userId);

    let importado;
    try {
      importado = parseXmi(body.xml);
    } catch (error) {
      if (error instanceof XmiParseError) {
        throw new HttpError(400, 'xmi_invalido', error.message);
      }
      throw error;
    }

    const propuesta = xmiToBatch(importado, {
      mode: body.mode,
      current: body.model,
      actorId: userId,
    });
    const warnings = [...importado.warnings, ...(propuesta.skipped ?? [])];

    // Volver a importar el mismo archivo es una operacion valida y frecuente.
    // No se convierte en una pregunta sin botones: se informa que se leyo bien
    // y que no habia nada nuevo que aplicar.
    if (propuesta.batch.commands.length === 0) {
      return {
        kind: 'NO_CHANGES' as const,
        message: 'El archivo se leyó correctamente, pero todo su contenido ya está en la pizarra.',
        rationale: propuesta.rationale ?? null,
        warnings,
      };
    }

    // La propuesta pasa por el mismo contrato que la del asistente: si la
    // importacion produjera algo fuera del vocabulario, se ve aqui y no al
    // aplicarlo.
    const outcome =
      body.mode === 'REPLACE' && body.model.classes.length > 0
        ? {
            kind: 'CONFIRMATION' as const,
            batch: propuesta.batch,
            summary: propuesta.summary,
            question: `Esto elimina ${body.model.classes.length} elementos de clase con sus atributos y relaciones y los sustituye por el archivo. Revisa antes de aplicar.`,
          }
        : { kind: 'BATCH' as const, batch: propuesta.batch, summary: propuesta.summary };

    request.log.info(
      {
        boardId,
        origin: 'XMI',
        classes: importado.classes.length,
        relationships: importado.relationships.length,
        warnings: importado.warnings.length,
        outcome: outcome.kind,
      },
      'importacion XMI',
    );

    // Los avisos del parser viajan con el candidato: lo que no se pudo traducir
    // tiene que verse antes de aplicar, no descubrirse despues.
    return { ...outcome, rationale: propuesta.rationale ?? null, warnings };
  });

  /**
   * RF-050: exportar a XMI.
   *
   * Basta con ser miembro: exportar no modifica nada, y un rol de solo lectura
   * tiene tanto derecho a llevarse el diagrama como cualquier otro.
   */
  app.post('/boards/:boardId/export/xmi', async (request, reply) => {
    const { boardId } = boardParams.parse(request.params);
    const body = z
      .object({
        model: semanticModelSchema,
        layout: layoutSchema.optional(),
        format: z.enum(['EA_21', 'UML_251']).default('EA_21'),
      })
      .parse(request.body);
    const { userId } = currentUser(request);

    const board = await findBoard(app, boardId);
    await requireMembership(app.prisma, board.projectId, userId);

    const serializer =
      body.format === 'UML_251' ? serializeToXmi251 : serializeToEnterpriseArchitect;
    const xml = serializer(body.model, {
      modelName: board.displayName,
      boardId,
      ...(body.layout === undefined ? {} : { layout: body.layout }),
    });

    reply.header('content-type', 'application/xml; charset=utf-8');
    reply.header(
      'content-disposition',
      `attachment; filename="${nombreDeArchivo(board.displayName)}.xmi"`,
    );
    return xml;
  });
}

/**
 * En modo de reemplazo, el borrado va delante y en el mismo lote.
 *
 * Se hace aqui y no en el puerto de vision porque el modelo no tiene por que
 * saber que va a pasar con su candidato: solo transcribe lo que ve.
 */
function conBorradoPrevio(
  proposal: BatchProposal,
  mode: 'ADD' | 'REPLACE',
  current: SemanticModel,
): BatchProposal {
  if (mode === 'ADD') return proposal;

  return {
    ...proposal,
    operations: [
      ...current.classes.map<AssistantOperation>((umlClass) => ({
        op: 'DELETE_CLASS',
        className: umlClass.displayName,
      })),
      ...proposal.operations,
    ],
  };
}

async function conProveedor<T>(llamar: () => Promise<T>): Promise<T> {
  try {
    return await llamar();
  } catch (error) {
    if (error instanceof ProviderUnavailableError) {
      throw new HttpError(
        503,
        'ai_provider_unavailable',
        'El servicio de reconocimiento no esta disponible. Vuelve a intentarlo.',
      );
    }
    if (error instanceof ProviderContractError) {
      throw new HttpError(422, 'imagen_no_interpretable', error.message);
    }
    throw error;
  }
}

async function findBoard(
  app: FastifyInstance,
  boardId: string,
): Promise<{ id: string; projectId: string; displayName: string }> {
  const board = await app.prisma.board.findUnique({
    where: { id: boardId },
    select: { id: true, projectId: true, displayName: true },
  });

  if (board === null) throw new HttpError(404, 'not_found', 'La pizarra no existe.');
  return board;
}

/** Un nombre de archivo que no rompa la cabecera ni el sistema de archivos. */
function nombreDeArchivo(displayName: string): string {
  const limpio = displayName
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^A-Za-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .toLowerCase();

  return limpio.length === 0 ? 'pizarra' : limpio.slice(0, 60);
}
```

---

### `backend/api/src/modules/projects/membership.ts`

```ts
import { PROJECT_ROLES, roleCanWrite, type ProjectRole } from '@uml/contracts';
import type { PrismaClient } from '@prisma/client';
import { forbidden, notFound } from '../../lib/http-error.js';

/**
 * Autorizacion por proyecto (plan maestro 5.5).
 *
 * | Rol      | Puede                                                        |
 * |----------|--------------------------------------------------------------|
 * | OWNER    | Todo, mas invitar, cambiar roles y eliminar el proyecto       |
 * | EDITOR   | Crear y editar pizarras, usar el asistente, generar codigo    |
 * | VIEWER   | Ver pizarras y consultar al asistente sin modificar           |
 *
 * Este modulo es la unica puerta. El proceso de colaboracion resuelve lo mismo
 * en su propio proceso (fase 4) reusando estas reglas, porque proteger las rutas
 * HTTP sin autorizar la conexion WebSocket no sirve de nada (RA-15).
 */

export const ROLE_RANK: Readonly<Record<ProjectRole, number>> = {
  VIEWER: 0,
  EDITOR: 1,
  OWNER: 2,
};

export function isProjectRole(value: string): value is ProjectRole {
  return (PROJECT_ROLES as readonly string[]).includes(value);
}

/**
 * Devuelve el rol del usuario en el proyecto.
 *
 * Un no miembro recibe 404 y no 403: responder "no tienes permiso" confirmaria
 * que el proyecto existe a quien solo esta probando identificadores.
 */
export async function requireMembership(
  prisma: PrismaClient,
  projectId: string,
  userId: string,
): Promise<ProjectRole> {
  const membership = await prisma.projectMember.findUnique({
    where: { projectId_userId: { projectId, userId } },
    select: { role: true },
  });

  if (membership === null) throw notFound('El proyecto no existe o no eres miembro.');
  return membership.role;
}

export async function requireRole(
  prisma: PrismaClient,
  projectId: string,
  userId: string,
  minimum: ProjectRole,
): Promise<ProjectRole> {
  const role = await requireMembership(prisma, projectId, userId);

  if (ROLE_RANK[role] < ROLE_RANK[minimum]) {
    throw forbidden(`Esta operacion requiere el rol ${minimum} y el tuyo es ${role}.`);
  }
  return role;
}

/** Escritura sobre pizarras: OWNER y EDITOR si, VIEWER no. */
export async function requireWriteAccess(
  prisma: PrismaClient,
  projectId: string,
  userId: string,
): Promise<ProjectRole> {
  const role = await requireMembership(prisma, projectId, userId);
  if (!roleCanWrite(role)) {
    throw forbidden('Tu rol es de solo lectura en este proyecto.');
  }
  return role;
}
```

---

### `backend/api/src/modules/projects/routes.ts`

```ts
import { randomBytes } from 'node:crypto';
import { Prisma } from '@prisma/client';
import { SCHEMA_VERSION } from '@uml/contracts';
import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import type { Config } from '../../config.js';
import { badRequest, conflict, forbidden, notFound } from '../../lib/http-error.js';
import { currentUser } from '../../plugins/auth.js';
import { requireMembership, requireRole } from './membership.js';

const projectBody = z.object({
  displayName: z.string().trim().min(1).max(120),
});

const inviteBody = z.object({
  // No se puede invitar como propietario: el proyecto tiene uno solo.
  role: z.enum(['EDITOR', 'VIEWER']),
});

const roleBody = z.object({
  // El proyecto tiene un solo propietario, fijado en `ownerId`. Promover otro
  // miembro a OWNER dejaria dos fuentes de verdad para la propiedad.
  role: z.enum(['EDITOR', 'VIEWER']),
});

const projectParams = z.object({ projectId: z.string().uuid() });
const memberParams = projectParams.extend({ userId: z.string().uuid() });
const acceptParams = z.object({ code: z.string().min(8).max(64) });

/** Proyectos, membresias e invitaciones (RF-A04 a RF-A07 y RF-001). */
export async function projectRoutes(
  app: FastifyInstance,
  options: { config: Config },
): Promise<void> {
  const { config } = options;

  app.addHook('preHandler', app.authenticate);

  app.get('/projects', async (request) => {
    const { userId } = currentUser(request);

    const memberships = await app.prisma.projectMember.findMany({
      where: { userId },
      orderBy: { joinedAt: 'desc' },
      select: {
        role: true,
        joinedAt: true,
        project: {
          select: {
            id: true,
            displayName: true,
            ownerId: true,
            schemaVersion: true,
            createdAt: true,
            _count: { select: { boards: true, members: true } },
          },
        },
      },
    });

    return memberships.map(({ project, role, joinedAt }) => ({
      ...project,
      _count: undefined,
      boardCount: project._count.boards,
      memberCount: project._count.members,
      role,
      joinedAt,
    }));
  });

  /** RF-A04: quien crea el proyecto queda como propietario. */
  app.post('/projects', async (request, reply) => {
    const body = projectBody.parse(request.body);
    const { userId } = currentUser(request);

    const project = await app.prisma.project.create({
      data: {
        displayName: body.displayName,
        ownerId: userId,
        schemaVersion: SCHEMA_VERSION,
        members: { create: { userId, role: 'OWNER' } },
      },
    });

    reply.code(201);
    return project;
  });

  app.get('/projects/:projectId', async (request) => {
    const { projectId } = projectParams.parse(request.params);
    const { userId } = currentUser(request);
    const role = await requireMembership(app.prisma, projectId, userId);

    const project = await app.prisma.project.findUniqueOrThrow({
      where: { id: projectId },
      include: {
        boards: {
          orderBy: { createdAt: 'asc' },
          select: { id: true, displayName: true, type: true, createdAt: true },
        },
      },
    });

    return { ...project, role };
  });

  app.patch('/projects/:projectId', async (request) => {
    const { projectId } = projectParams.parse(request.params);
    const body = projectBody.parse(request.body);
    const { userId } = currentUser(request);
    await requireRole(app.prisma, projectId, userId, 'OWNER');

    return app.prisma.project.update({
      where: { id: projectId },
      data: { displayName: body.displayName },
    });
  });

  app.delete('/projects/:projectId', async (request, reply) => {
    const { projectId } = projectParams.parse(request.params);
    const { userId } = currentUser(request);
    await requireRole(app.prisma, projectId, userId, 'OWNER');

    // El esquema borra en cascada pizarras, documentos, snapshots y membresias.
    await app.prisma.project.delete({ where: { id: projectId } });

    reply.code(204);
    return null;
  });

  // -------------------------------------------------------------------------
  // Miembros (RF-A07)
  // -------------------------------------------------------------------------

  app.get('/projects/:projectId/members', async (request) => {
    const { projectId } = projectParams.parse(request.params);
    const { userId } = currentUser(request);
    await requireMembership(app.prisma, projectId, userId);

    const members = await app.prisma.projectMember.findMany({
      where: { projectId },
      orderBy: { joinedAt: 'asc' },
      select: {
        role: true,
        joinedAt: true,
        user: { select: { id: true, email: true, displayName: true } },
      },
    });

    return members.map(({ user, role, joinedAt }) => ({ ...user, role, joinedAt }));
  });

  app.patch('/projects/:projectId/members/:userId', async (request) => {
    const params = memberParams.parse(request.params);
    const body = roleBody.parse(request.body);
    const actor = currentUser(request);
    await requireRole(app.prisma, params.projectId, actor.userId, 'OWNER');

    const project = await app.prisma.project.findUniqueOrThrow({
      where: { id: params.projectId },
      select: { ownerId: true },
    });

    // Degradar al propietario dejaria el proyecto sin nadie que pueda invitar,
    // cambiar roles ni borrarlo. Transferir la propiedad es otra operacion y no
    // entra en este alcance.
    if (params.userId === project.ownerId) {
      throw conflict('owner_immutable', 'No se puede quitar el rol al propietario del proyecto.');
    }

    const updated = await app.prisma.projectMember.updateMany({
      where: { projectId: params.projectId, userId: params.userId },
      data: { role: body.role },
    });

    if (updated.count === 0) throw notFound('Ese usuario no es miembro del proyecto.');

    return { projectId: params.projectId, userId: params.userId, role: body.role };
  });

  app.delete('/projects/:projectId/members/:userId', async (request, reply) => {
    const params = memberParams.parse(request.params);
    const actor = currentUser(request);

    // Autorizar antes de leer el propietario evita que un extrano confirme que
    // un proyecto y su dueno existen apuntando la ruta al identificador correcto.
    if (params.userId !== actor.userId) {
      await requireRole(app.prisma, params.projectId, actor.userId, 'OWNER');
    } else {
      await requireMembership(app.prisma, params.projectId, actor.userId);
    }

    const project = await app.prisma.project.findUniqueOrThrow({
      where: { id: params.projectId },
      select: { ownerId: true },
    });

    if (params.userId === project.ownerId) {
      throw conflict('owner_immutable', 'El propietario no puede salir del proyecto.');
    }

    const removed = await app.prisma.projectMember.deleteMany({
      where: { projectId: params.projectId, userId: params.userId },
    });

    if (removed.count === 0) throw notFound('Ese usuario no es miembro del proyecto.');

    reply.code(204);
    return null;
  });

  // -------------------------------------------------------------------------
  // Invitaciones (RF-A05 y RF-A06)
  // -------------------------------------------------------------------------

  app.post('/projects/:projectId/invites', async (request, reply) => {
    const { projectId } = projectParams.parse(request.params);
    const body = inviteBody.parse(request.body);
    const { userId } = currentUser(request);
    await requireRole(app.prisma, projectId, userId, 'OWNER');

    const invite = await app.prisma.projectInvite.create({
      data: {
        projectId,
        // 32 caracteres aleatorios: no es adivinable, y es lo unico que protege
        // el enlace porque no se verifica quien lo abre.
        code: randomBytes(24).toString('base64url'),
        role: body.role,
        expiresAt: new Date(Date.now() + config.INVITE_TTL_SECONDS * 1000),
        createdBy: userId,
      },
      select: { id: true, code: true, role: true, expiresAt: true, createdAt: true },
    });

    reply.code(201);
    return invite;
  });

  app.get('/projects/:projectId/invites', async (request) => {
    const { projectId } = projectParams.parse(request.params);
    const { userId } = currentUser(request);
    await requireRole(app.prisma, projectId, userId, 'OWNER');

    return app.prisma.projectInvite.findMany({
      where: { projectId },
      orderBy: { createdAt: 'desc' },
      select: { id: true, code: true, role: true, expiresAt: true, createdAt: true },
    });
  });

  /** RF-A06: aceptar la invitacion y quedar como miembro. */
  app.post('/invites/:code/accept', async (request) => {
    const { code } = acceptParams.parse(request.params);
    const { userId } = currentUser(request);

    const invite = await app.prisma.projectInvite.findUnique({
      where: { code },
      select: { projectId: true, role: true, expiresAt: true },
    });

    if (invite === null) throw notFound('Esa invitacion no existe.');
    if (invite.expiresAt <= new Date()) throw badRequest('invite_expired', 'La invitacion expiro.');

    const existing = await app.prisma.projectMember.findUnique({
      where: { projectId_userId: { projectId: invite.projectId, userId } },
      select: { role: true },
    });

    // Aceptar dos veces no es un error: devuelve la membresia que ya hay. Un
    // enlace compartido se abre mas de una vez y fallar la segunda solo confunde.
    if (existing !== null) {
      return { projectId: invite.projectId, role: existing.role, alreadyMember: true };
    }

    try {
      const member = await app.prisma.projectMember.create({
        data: { projectId: invite.projectId, userId, role: invite.role },
        select: { projectId: true, role: true },
      });
      return { ...member, alreadyMember: false };
    } catch (error) {
      if (!(error instanceof Prisma.PrismaClientKnownRequestError) || error.code !== 'P2002') {
        throw error;
      }
      // Dos pestañas pueden aceptar a la vez. Se conserva el rol que ya ganó,
      // sin convertir la segunda aceptación en un 500 ni cambiar permisos.
      const member = await app.prisma.projectMember.findUniqueOrThrow({
        where: { projectId_userId: { projectId: invite.projectId, userId } },
        select: { projectId: true, role: true },
      });
      return { ...member, alreadyMember: true };
    }
  });

  app.delete('/projects/:projectId/invites/:inviteId', async (request, reply) => {
    const { projectId } = projectParams.parse(request.params);
    const { inviteId } = z.object({ inviteId: z.string().uuid() }).parse(request.params);
    const { userId } = currentUser(request);
    await requireRole(app.prisma, projectId, userId, 'OWNER');

    const removed = await app.prisma.projectInvite.deleteMany({
      where: { id: inviteId, projectId },
    });

    if (removed.count === 0) throw notFound('Esa invitacion no existe.');

    reply.code(204);
    return null;
  });
}

export { forbidden };
```

---

### `backend/api/src/plugins/auth.ts`

```ts
import type { FastifyInstance, FastifyRequest } from 'fastify';
import fp from 'fastify-plugin';
import type { Config } from '../config.js';
import { unauthorized } from '../lib/http-error.js';
import { enforceLimit, isExpensiveRequest } from './security.js';
import {
  createTokenIssuer,
  type AccessTokenClaims,
  type TokenIssuer,
} from '../modules/auth/tokens.js';

// Dentro de la ampliacion, `FastifyRequest` y `FastifyReply` resuelven a las
// declaraciones del propio modulo: no se importan aqui arriba.
declare module 'fastify' {
  interface FastifyInstance {
    readonly tokens: TokenIssuer;
    /** Rechaza la peticion si no trae un token de acceso valido. */
    authenticate(request: FastifyRequest, reply: FastifyReply): Promise<void>;
  }

  interface FastifyRequest {
    /** Presente solo despues de pasar por `authenticate`. */
    user?: AccessTokenClaims;
  }
}

export const REFRESH_COOKIE = 'uml_refresh';

export const authPlugin = fp(
  async (app: FastifyInstance, options: { config: Config }) => {
    const tokens = createTokenIssuer(
      options.config.JWT_SECRET,
      options.config.ACCESS_TOKEN_TTL_SECONDS,
    );

    app.decorate('tokens', tokens);
    app.decorateRequest('user', undefined);

    const workQuota = app.createRateLimit({
      max: options.config.WORK_RATE_LIMIT_MAX,
      timeWindow: 60_000,
      keyGenerator: (request) => request.user?.userId ?? request.ip,
    });
    app.decorate('authenticate', async (request: FastifyRequest, reply) => {
      const header = request.headers.authorization;
      if (header === undefined || !header.startsWith('Bearer ')) {
        throw unauthorized('Falta el token de acceso.');
      }

      const claims = await tokens.verifyAccessToken(header.slice('Bearer '.length));
      const user = await app.prisma.user.findUnique({
        where: { id: claims.userId },
        select: { sessionVersion: true, emailVerifiedAt: true },
      });
      if (
        user === null ||
        user.emailVerifiedAt === null ||
        user.sessionVersion !== claims.sessionVersion
      ) {
        throw unauthorized('La sesión fue revocada. Inicia sesión nuevamente.');
      }
      request.user = claims;
      if (options.config.RATE_LIMIT_ENABLED && isExpensiveRequest(request))
        await enforceLimit(workQuota, request, reply);

      // RNF-14: el actor entra en el registro estructurado de la peticion.
      //
      // `setBindings` existe en pino pero no esta declarado en el tipo que
      // Fastify expone, asi que se accede de forma estructural y opcional: si
      // algun dia el registrador no lo tiene, se pierde un campo del log en
      // lugar de caerse la peticion.
      const log = request.log as { setBindings?: (bindings: Record<string, unknown>) => void };
      log.setBindings?.({ actorId: claims.userId });
    });
  },
  { name: 'auth' },
);

/** El usuario autenticado, para rutas que ya pasaron por `authenticate`. */
export function currentUser(request: FastifyRequest): AccessTokenClaims {
  if (request.user === undefined) {
    // Llegar aqui significa que a la ruta le falta el gancho de autenticacion.
    throw new Error('La ruta no declaro preHandler: authenticate');
  }
  return request.user;
}
```

---

### `backend/api/src/plugins/prisma.ts`

```ts
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '@prisma/client';
import type { FastifyInstance } from 'fastify';
import fp from 'fastify-plugin';
import type { Config } from '../config.js';

declare module 'fastify' {
  interface FastifyInstance {
    readonly prisma: PrismaClient;
  }
}

/**
 * Cliente de base de datos, uno por proceso.
 *
 * Prisma 7 exige un adaptador de controlador explicito. Se cierra al apagar el
 * servidor para que las conexiones no queden colgando entre reinicios en
 * desarrollo.
 */
export const prismaPlugin = fp(
  async (app: FastifyInstance, options: { config: Config }) => {
    const adapter = new PrismaPg({
      connectionString: options.config.DATABASE_URL,
      connectionTimeoutMillis: 3000,
      statement_timeout: 5000,
    });
    const prisma = new PrismaClient({ adapter });

    app.decorate('prisma', prisma);
    app.addHook('onClose', async () => {
      await prisma.$disconnect();
    });
  },
  { name: 'prisma' },
);
```

---

### `backend/api/src/plugins/security.ts`

```ts
import rateLimit from '@fastify/rate-limit';
import fp from 'fastify-plugin';
import type { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import type { Config } from '../config.js';
import { HttpError } from '../lib/http-error.js';

export async function enforceLimit(
  limiter: ReturnType<FastifyInstance['createRateLimit']>,
  request: FastifyRequest,
  reply: FastifyReply,
): Promise<void> {
  const result = await limiter(request);
  if (!result.isAllowed && result.isExceeded) {
    reply.header('retry-after', result.ttlInSeconds);
    throw new HttpError(
      429,
      'rate_limit_exceeded',
      'Demasiadas peticiones. Espera antes de reintentar.',
    );
  }
}

export function isExpensiveRequest(request: FastifyRequest): boolean {
  const path = request.url.split('?')[0] ?? '';
  return (
    request.method === 'POST' &&
    (/\/assistant\//.test(path) || /\/import\//.test(path) || /\/generations$/.test(path))
  );
}

// One API instance per deployment. Counters are bounded and reset on restart.
// Multiple API replicas require a shared rate-limit store before scaling out.
export const securityPlugin = fp(
  async (app: FastifyInstance, { config }: { config: Config }) => {
    await app.register(rateLimit, { global: false, cache: 10000 });
    const general = app.createRateLimit({ max: config.RATE_LIMIT_MAX, timeWindow: 60_000 });
    const authentication = app.createRateLimit({
      max: config.AUTH_RATE_LIMIT_MAX,
      timeWindow: 900_000,
    });
    app.addHook('onRequest', async (request, reply) => {
      if (!config.RATE_LIMIT_ENABLED) return;
      const path = request.url.split('?')[0];
      if (path === '/health' || path === '/ready') return;
      await enforceLimit(general, request, reply);
      if (
        request.method === 'POST' &&
        [
          '/auth/login',
          '/auth/register',
          '/auth/password/forgot',
          '/auth/password/reset',
          '/auth/verification/resend',
          '/auth/verification/confirm',
        ].includes(path ?? '')
      ) {
        await enforceLimit(authentication, request, reply);
      }
    });
  },
  { name: 'security' },
);
```

---

## Servidor de colaboracion

Autoriza por proyecto antes de abrir la sesion y persiste el estado del documento compartido.

### Estructura

```text
backend/collab/
|-- src/
|   |-- auth/
|   |   `-- authorize.ts
|   |-- persistence/
|   |   `-- board-store.ts
|   |-- app.ts
|   |-- config.ts
|   `-- server.ts
|-- package.json
`-- tsconfig.json
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `backend/collab/package.json` | 27 |
| `backend/collab/tsconfig.json` | 20 |
| `backend/collab/src/app.ts` | 376 |
| `backend/collab/src/config.ts` | 34 |
| `backend/collab/src/server.ts` | 22 |
| `backend/collab/src/auth/authorize.ts` | 181 |
| `backend/collab/src/persistence/board-store.ts` | 58 |

---

### `backend/collab/package.json`

```json
{
  "name": "@uml/collab",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "description": "Proceso WebSocket: salas por pizarra, presencia, persistencia del documento y autorizacion de la conexion.",
  "main": "./dist/server.js",
  "scripts": {
    "build": "tsc --build",
    "clean": "tsc --build --clean",
    "dev": "tsx watch src/server.ts",
    "start": "node dist/server.js"
  },
  "dependencies": {
    "@hocuspocus/server": "4.6.0",
    "@prisma/adapter-pg": "^7.10.0",
    "@prisma/client": "7.10.0",
    "@uml/contracts": "*",
    "@uml/domain-core": "*",
    "@uml/yjs-adapter": "*",
    "jose": "^6.2.10",
    "y-protocols": "^1.0.7",
    "yjs": "^13.6.0",
    "zod": "^3.23.0"
  }
}
```

---

### `backend/collab/tsconfig.json`

```json
{
  "extends": "../../config/tsconfig.base.json",
  "compilerOptions": {
    "rootDir": "src",
    "outDir": "dist"
  },
  "include": ["src/**/*.ts"],
  "references": [
    {
      "path": "../../shared/contracts"
    },
    {
      "path": "../../shared/domain-core"
    },
    {
      "path": "../../shared/yjs-adapter"
    }
  ]
}
```

---

### `backend/collab/src/app.ts`

```ts
import { roleCanWrite, SCHEMA_VERSION } from '@uml/contracts';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '@prisma/client';
import {
  IncomingMessage as HocuspocusIncomingMessage,
  MessageType,
  Server,
  type Connection,
} from '@hocuspocus/server';
import type { IncomingMessage } from 'node:http';
import type { Config } from './config.js';
import {
  UnauthorizedConnection,
  authorizeConnection,
  parseRoomName,
  type CollaborationContext,
} from './auth/authorize.js';
import { loadBoardDocument, storeBoardDocument } from './persistence/board-store.js';

export const SERVICE_NAME = 'collab';

/**
 * Fuerza la escritura del documento vivo antes de generar (RA-08).
 *
 * **Por que hace falta.** La proyeccion canonica se guarda con retardo: escribir
 * en cada tecla castigaria la base sin ganar nada, porque el estado vivo esta en
 * memoria y replicado en cada navegador. Pero eso significa que la base puede ir
 * hasta diez segundos por detras de lo que la persona ve en pantalla, y quien
 * pulsa «generar» justo despues de dibujar una clase obtendria un proyecto sin
 * esa clase. Se detecto generando desde el navegador: la primera version genero
 * cero entidades sobre una pizarra que mostraba una.
 *
 * **Por que con el token de quien pide.** No hay secreto nuevo entre procesos:
 * el proceso HTTP reenvia el token del usuario y aqui se resuelve exactamente la
 * misma autorizacion que para conectarse a la sala (RA-15). Quien no puede
 * abrir la pizarra tampoco puede provocar una escritura en ella.
 */
async function atenderVolcado(options: {
  server: Server<CollaborationContext>;
  prisma: PrismaClient;
  jwtSecret: Uint8Array;
  request: IncomingMessage;
  responder: (status: number, cuerpo: unknown) => void;
}): Promise<void> {
  const { server, prisma, jwtSecret, request, responder } = options;

  let cuerpo: unknown;
  try {
    cuerpo = JSON.parse(await leerCuerpo(request));
  } catch {
    responder(400, { error: 'cuerpo_invalido' });
    return;
  }

  if (
    typeof cuerpo !== 'object' ||
    cuerpo === null ||
    !('room' in cuerpo) ||
    !('token' in cuerpo)
  ) {
    responder(400, { error: 'cuerpo_invalido' });
    return;
  }
  const room = cuerpo.room;
  const token = cuerpo.token;
  if (typeof room !== 'string' || typeof token !== 'string') {
    responder(400, { error: 'cuerpo_invalido' });
    return;
  }

  let boardId: string;
  try {
    await authorizeConnection({ prisma, jwtSecret, documentName: room, token });
    boardId = parseRoomName(room).boardId;
  } catch (error) {
    responder(403, {
      error: error instanceof UnauthorizedConnection ? error.reason : 'sin-acceso-a-la-pizarra',
    });
    return;
  }

  const document = server.hocuspocus.documents.get(room);

  // Sin documento cargado no hay nada mas reciente que lo que ya esta en la
  // base: nadie tiene la pizarra abierta, asi que lo guardado es lo vigente.
  if (document === undefined) {
    responder(200, { stored: false });
    return;
  }

  await storeBoardDocument(prisma, boardId, document);
  responder(200, { stored: true });
}

async function leerCuerpo(request: IncomingMessage): Promise<string> {
  const trozos: Buffer[] = [];
  let total = 0;

  for await (const trozo of request) {
    const buffer = trozo as Buffer;
    total += buffer.byteLength;
    // Este cuerpo son dos cadenas. Cualquier cosa mayor es un error o un abuso.
    if (total > 8192) throw new Error('cuerpo demasiado grande');
    trozos.push(buffer);
  }

  return Buffer.concat(trozos).toString('utf8');
}

export interface CollabServer {
  readonly server: Server<CollaborationContext>;
  readonly prisma: PrismaClient;
  listen(): Promise<void>;
  /** Puerto real. Util cuando se pide el 0 para que el sistema elija. */
  port(): number;
  close(): Promise<void>;
}

/**
 * Proceso de colaboracion.
 *
 * Una sala por pizarra, `project:{projectId}:board:{boardId}`. Cada sala tiene su
 * propio documento, y por eso dos pizarras del mismo proyecto no mezclan
 * actualizaciones (CA-004.1): son dos documentos distintos, no dos vistas del
 * mismo.
 */
export function buildCollabServer(config: Config): CollabServer {
  const adapter = new PrismaPg({ connectionString: config.DATABASE_URL });
  const prisma = new PrismaClient({ adapter });
  const jwtSecret = new TextEncoder().encode(config.JWT_SECRET);

  const server = new Server<CollaborationContext>({
    port: config.COLLAB_PORT,
    address: config.COLLAB_HOST,
    // El apagado lo gobierna el proceso, no la libreria: asi se cierra tambien
    // la conexion a la base.
    stopOnSignals: false,
    quiet: config.NODE_ENV !== 'development',

    debounce: config.STORE_DEBOUNCE_MS,
    maxDebounce: config.STORE_MAX_DEBOUNCE_MS,

    /**
     * RA-15: se autoriza antes de entregar el documento.
     *
     * Lanzar aqui rechaza la conexion. Hocuspocus solo llama a este gancho si el
     * cliente envia un token, asi que una conexion sin token nunca queda
     * autenticada y no recibe nada.
     */
    async onAuthenticate(data) {
      let resultado;
      try {
        resultado = await authorizeConnection({
          prisma,
          jwtSecret,
          documentName: data.documentName,
          token: data.token,
        });
      } catch (error) {
        if (error instanceof UnauthorizedConnection) {
          // El detalle queda aqui; al cliente solo le llega el motivo corto.
          console.warn(
            JSON.stringify({
              service: SERVICE_NAME,
              msg: 'conexion rechazada',
              room: data.documentName,
              reason: error.reason,
              detail: error.message,
            }),
          );
        }
        throw error;
      }

      const { context, readOnly } = resultado;

      // CA-A08.2: el rol de lectura se conecta y ve, pero el servidor descarta
      // sus escrituras. No basta con ocultarlas en la interfaz.
      data.connectionConfig.readOnly = readOnly;

      return context;
    },

    /** RA-11: se rehidrata desde la representacion binaria nativa. */
    async onLoadDocument(data) {
      const { boardId } = parseRoomName(data.documentName);
      await loadBoardDocument(prisma, boardId, data.document);
      return data.document;
    },

    /**
     * El rol no se congela al abrir la pestaña. Antes de procesar cada mensaje se
     * consulta la membresia actual: degradar a VIEWER bloquea el siguiente update
     * y quitar al miembro cierra la conexion existente.
     */
    async beforeHandleMessage(data) {
      // Presencia y ping no esperan SQL. Los mensajes sin estado sí revisan
      // permisos: permiten detectar cambios de rol aun sin editar el documento.
      if (!requiereRevisarAcceso(data.update)) return;

      // Se revisan tambien los receptores: un miembro expulsado que no escriba
      // nada no debe seguir recibiendo los cambios del resto de la sala.
      const connections = [
        ...new Set([
          ...(data.document.getConnections() as Connection<CollaborationContext>[]),
          data.connection,
        ]),
      ];
      const board = await prisma.board.findUnique({
        where: { id: data.context.boardId },
        select: {
          projectId: true,
          project: {
            select: {
              members: {
                where: {
                  userId: { in: connections.map((connection) => connection.context.userId) },
                },
                select: { userId: true, role: true, user: { select: { sessionVersion: true } } },
              },
            },
          },
        },
      });
      const roles = new Map(board?.project.members.map((member) => [member.userId, member.role]));
      const versions = new Map(
        board?.project.members.map((member) => [member.userId, member.user.sessionVersion]),
      );
      for (const connection of connections) {
        const role = roles.get(connection.context.userId);
        const expired =
          connection.context.expiresAt <= Date.now() ||
          (role !== undefined &&
            versions.get(connection.context.userId) !== connection.context.sessionVersion);
        if (expired || role === undefined || board?.projectId !== connection.context.projectId) {
          connection.close({
            code: expired ? 4401 : 4403,
            reason: expired ? 'token-invalido' : 'sin-acceso-a-la-pizarra',
          });
        } else {
          const readOnly = !roleCanWrite(role);
          if (connection.readOnly !== readOnly) {
            connection.readOnly = readOnly;
            // El cliente debe descartar su réplica con cambios rechazados y
            // resincronizar antes de volver a mostrar el documento como vivo.
            connection.sendStateless(JSON.stringify({ type: 'access-changed', readOnly }));
          }
        }
      }
      // Una desconexion normal puede ocurrir mientras SQL responde. Sus ultimos
      // mensajes recibidos siguen siendo validos y deben alcanzar la persistencia.
      if (
        data.context.expiresAt <= Date.now() ||
        versions.get(data.context.userId) !== data.context.sessionVersion ||
        !roles.has(data.context.userId) ||
        board?.projectId !== data.context.projectId
      ) {
        throw new UnauthorizedConnection(
          'sin-acceso-a-la-pizarra',
          'La sesion ya no tiene acceso.',
        );
      }
    },

    async onStoreDocument(data) {
      const { boardId } = parseRoomName(data.documentName);
      await storeBoardDocument(prisma, boardId, data.document);
    },

    /**
     * Sonda de vida, y nada mas. Todo el trafico util de este proceso va por
     * WebSocket.
     *
     * El gancho atiende **todas** las rutas, no solo `/health`. Si resolviera sin
     * escribir, Hocuspocus responderia su propio 200 con un texto que nombra el
     * software: superficie HTTP que nadie vigila y una pista gratuita sobre la
     * pila para quien este mirando.
     *
     * Rechazar sin motivo es como se le dice a Hocuspocus que la peticion ya
     * esta atendida.
     */
    async onRequest(data) {
      const responder = (status: number, cuerpo: unknown): void => {
        data.response.writeHead(status, { 'content-type': 'application/json; charset=utf-8' });
        data.response.end(JSON.stringify(cuerpo));
      };

      if (data.request.method === 'GET' && data.request.url === '/health') {
        responder(200, {
          status: 'ok',
          service: SERVICE_NAME,
          schemaVersion: SCHEMA_VERSION,
          uptimeSeconds: Math.round(process.uptime()),
        });
        return Promise.reject();
      }

      if (data.request.method === 'POST' && data.request.url === '/flush') {
        await atenderVolcado({ server, prisma, jwtSecret, request: data.request, responder });
        return Promise.reject();
      }

      responder(404, { error: 'not_found' });
      return Promise.reject();
    },
  });

  let revocationTimer: ReturnType<typeof setInterval> | undefined;
  let revocationCheck: Promise<void> | undefined;
  async function closeRevokedSessions(): Promise<void> {
    const connections = [...server.hocuspocus.documents.values()].flatMap(
      (document) => document.getConnections() as Connection<CollaborationContext>[],
    );
    if (connections.length === 0) return;
    const users = await prisma.user.findMany({
      where: { id: { in: [...new Set(connections.map((c) => c.context.userId))] } },
      select: { id: true, sessionVersion: true },
    });
    const versions = new Map(users.map((user) => [user.id, user.sessionVersion]));
    for (const connection of connections) {
      if (
        connection.context.expiresAt <= Date.now() ||
        versions.get(connection.context.userId) !== connection.context.sessionVersion
      ) {
        connection.close({ code: 4401, reason: 'token-invalido' });
      }
    }
  }

  return {
    server,
    prisma,
    async listen() {
      await server.listen();
      // También cierra clientes inactivos que no envían el latido del navegador.
      revocationTimer = setInterval(() => {
        revocationCheck ??= closeRevokedSessions()
          .catch((error: unknown) =>
            console.warn('No se pudo comprobar la revocación de sesiones', error),
          )
          .finally(() => {
            revocationCheck = undefined;
          });
      }, 5000);
      revocationTimer.unref();
    },
    port() {
      return server.address.port;
    },
    async close() {
      clearInterval(revocationTimer);
      await revocationCheck;
      await server.destroy();
      await prisma.$disconnect();
    },
  };
}

function requiereRevisarAcceso(update: Uint8Array): boolean {
  try {
    const message = new HocuspocusIncomingMessage(update);
    message.readVarString(); // dirección de documento
    const type = message.readVarUint();
    return (
      type === MessageType.Sync || type === MessageType.SyncReply || type === MessageType.Stateless
    );
  } catch {
    // Que el receptor normal produzca el error de protocolo correspondiente.
    // Autorizar por defecto un mensaje indescifrable sería peor que una consulta
    // adicional que terminará igualmente con el cierre de la conexión.
    return true;
  }
}

export { UnauthorizedConnection };
```

---

### `backend/collab/src/config.ts`

```ts
import { z } from 'zod';

const schema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  COLLAB_HOST: z.string().default('0.0.0.0'),
  COLLAB_PORT: z.coerce.number().int().nonnegative().default(3002),
  LOG_LEVEL: z.enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace']).default('info'),

  DATABASE_URL: z.string().min(1),

  // El mismo secreto que firma los tokens en el proceso HTTP. Los dos procesos
  // comparten la clave porque uno emite y el otro verifica.
  JWT_SECRET: z.string().min(32, 'JWT_SECRET debe tener al menos 32 caracteres'),

  // Cuanto se espera tras el ultimo cambio antes de escribir en la base. Guardar
  // en cada tecla castigaria la base sin ganar nada: el estado vivo esta en
  // memoria y replicado en cada navegador conectado.
  STORE_DEBOUNCE_MS: z.coerce.number().int().nonnegative().default(2000),
  STORE_MAX_DEBOUNCE_MS: z.coerce.number().int().positive().default(10_000),
});

export type Config = z.infer<typeof schema>;

export function loadConfig(env: NodeJS.ProcessEnv = process.env): Config {
  const parsed = schema.safeParse(env);
  if (!parsed.success) {
    const detalle = parsed.error.issues
      .map((issue) => `  ${issue.path.join('.')}: ${issue.message}`)
      .join('\n');
    throw new Error(`Configuracion invalida del proceso collab:\n${detalle}`);
  }
  return parsed.data;
}
```

---

### `backend/collab/src/server.ts`

```ts
import { buildCollabServer, SERVICE_NAME } from './app.js';
import { loadConfig } from './config.js';

const config = loadConfig();
const collab = buildCollabServer(config);

let cerrando = false;
for (const senal of ['SIGINT', 'SIGTERM'] as const) {
  process.on(senal, () => {
    if (cerrando) return;
    cerrando = true;
    // El apagado ordenado guarda los documentos abiertos antes de salir: sin el,
    // lo escrito en los ultimos segundos se perderia con el proceso.
    void collab.close().then(() => process.exit(0));
  });
}

await collab.listen();
console.warn(
  JSON.stringify({ service: SERVICE_NAME, port: collab.port(), msg: 'proceso collab escuchando' }),
);
```

---

### `backend/collab/src/auth/authorize.ts`

```ts
import { roleCanWrite, type ProjectRole } from '@uml/contracts';
import type { PrismaClient } from '@prisma/client';
import { jwtVerify, type JWTPayload } from 'jose';

/**
 * Autorizacion de la conexion de colaboracion (plan maestro 5.4, RA-15).
 *
 *   Conexion entrante
 *         ↓
 *   Token valido y no expirado
 *         ↓
 *   El usuario es miembro del proyecto de esa pizarra
 *         ↓
 *   Rol determina el modo: OWNER y EDITOR escriben, VIEWER solo lee
 *         ↓
 *   Se une a la sala
 *
 * Sin esta verificacion, proteger las rutas HTTP no sirve de nada: cualquiera
 * con el identificador de la sala editaria la pizarra.
 */

const ISSUER = 'plataforma-uml';
const AUDIENCE = 'plataforma-uml-clients';

/**
 * Motivos que se le devuelven al cliente.
 *
 * `sin-acceso-a-la-pizarra` cubre a la vez "esa pizarra no existe" y "no eres
 * miembro", igual que el proceso HTTP responde 404 en los dos casos: distinguir
 * confirmaria que la pizarra existe a quien solo esta probando identificadores.
 *
 * El motivo detallado si queda en el registro del servidor, donde lo lee el
 * equipo y no quien intenta entrar.
 */
export const CONNECTION_REJECTIONS = {
  SALA_INVALIDA: 'sala-invalida',
  TOKEN_INVALIDO: 'token-invalido',
  SIN_ACCESO: 'sin-acceso-a-la-pizarra',
} as const;

export type ConnectionRejection =
  (typeof CONNECTION_REJECTIONS)[keyof typeof CONNECTION_REJECTIONS];

export class UnauthorizedConnection extends Error {
  /** Hocuspocus lo envia al cliente como motivo del rechazo. */
  public readonly reason: ConnectionRejection;

  public constructor(reason: ConnectionRejection, message: string) {
    super(message);
    this.name = 'UnauthorizedConnection';
    this.reason = reason;
  }
}

export interface CollaborationContext {
  readonly userId: string;
  readonly email: string;
  readonly projectId: string;
  readonly boardId: string;
  readonly role: ProjectRole;
  readonly expiresAt: number;
  readonly sessionVersion: number;
}

/**
 * Nombre de sala: `project:{projectId}:board:{boardId}`.
 *
 * Se analiza en lugar de confiar: el cliente elige el nombre del documento, asi
 * que es entrada no confiable como cualquier otra.
 */
const ROOM_PATTERN =
  /^project:([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}):board:([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})$/i;

export function parseRoomName(documentName: string): { projectId: string; boardId: string } {
  const match = ROOM_PATTERN.exec(documentName);
  if (match === null) {
    throw new UnauthorizedConnection(
      CONNECTION_REJECTIONS.SALA_INVALIDA,
      'El nombre de sala no tiene el formato esperado.',
    );
  }
  return { projectId: match[1] as string, boardId: match[2] as string };
}

export interface AuthorizeOptions {
  readonly prisma: PrismaClient;
  readonly jwtSecret: Uint8Array;
  readonly documentName: string;
  readonly token: string;
}

export async function authorizeConnection(
  options: AuthorizeOptions,
): Promise<{ context: CollaborationContext; readOnly: boolean }> {
  const { projectId, boardId } = parseRoomName(options.documentName);

  let payload: JWTPayload;
  try {
    ({ payload } = await jwtVerify(options.token, options.jwtSecret, {
      issuer: ISSUER,
      audience: AUDIENCE,
      algorithms: ['HS256'],
    }));
  } catch {
    throw new UnauthorizedConnection(
      CONNECTION_REJECTIONS.TOKEN_INVALIDO,
      'El token no es valido o expiro.',
    );
  }

  const userId = payload.sub;
  const email = payload['email'];
  const sessionVersion = payload['sessionVersion'] ?? 0;
  if (
    typeof userId !== 'string' ||
    typeof email !== 'string' ||
    typeof payload.exp !== 'number' ||
    typeof sessionVersion !== 'number' ||
    !Number.isSafeInteger(sessionVersion) ||
    sessionVersion < 0
  ) {
    throw new UnauthorizedConnection(
      CONNECTION_REJECTIONS.TOKEN_INVALIDO,
      'El token no identifica a un usuario.',
    );
  }

  const user = await options.prisma.user.findUnique({
    where: { id: userId },
    select: { sessionVersion: true, emailVerifiedAt: true },
  });
  if (user === null || user.emailVerifiedAt === null || user.sessionVersion !== sessionVersion) {
    throw new UnauthorizedConnection(
      CONNECTION_REJECTIONS.TOKEN_INVALIDO,
      'La sesión fue revocada.',
    );
  }

  // La pizarra tiene que existir y pertenecer al proyecto que dice el nombre de
  // sala. Sin esta comprobacion, un miembro de un proyecto podria abrir la
  // pizarra de otro montando un nombre de sala con su propio projectId.
  const board = await options.prisma.board.findUnique({
    where: { id: boardId },
    select: { projectId: true },
  });

  if (board === null || board.projectId !== projectId) {
    throw new UnauthorizedConnection(
      CONNECTION_REJECTIONS.SIN_ACCESO,
      `La pizarra ${boardId} no existe en el proyecto ${projectId}.`,
    );
  }

  const membership = await options.prisma.projectMember.findUnique({
    where: { projectId_userId: { projectId, userId } },
    select: { role: true },
  });

  // CA-A08.1: quien no es miembro no entra, aunque el identificador sea valido.
  if (membership === null) {
    throw new UnauthorizedConnection(
      CONNECTION_REJECTIONS.SIN_ACCESO,
      `El usuario ${userId} no es miembro del proyecto ${projectId}.`,
    );
  }

  return {
    context: {
      userId,
      email,
      projectId,
      boardId,
      role: membership.role,
      expiresAt: payload.exp * 1000,
      sessionVersion,
    },
    // CA-A08.2: el rol de lectura se conecta, ve y no escribe.
    readOnly: !roleCanWrite(membership.role),
  };
}
```

---

### `backend/collab/src/persistence/board-store.ts`

```ts
import { readSemanticModel } from '@uml/yjs-adapter';
import type { PrismaClient } from '@prisma/client';
import * as Y from 'yjs';

/**
 * Persistencia del documento (RA-11).
 *
 * El documento se guarda en su representacion binaria nativa, que es lo unico
 * que puede reabrir la sesion colaborativa conservando el historial de
 * operaciones del CRDT.
 *
 * El JSON canonico se guarda **ademas**, como proyeccion derivada, para validar,
 * generar e inspeccionar sin cargar Yjs. Nunca reconstruye el documento: si
 * alguna vez se intentara, se perderia el historial y dos replicas que estaban
 * convergiendo dejarian de hacerlo.
 */

export async function loadBoardDocument(
  prisma: PrismaClient,
  boardId: string,
  document: Y.Doc,
): Promise<boolean> {
  const stored = await prisma.boardDocument.findUnique({
    where: { boardId },
    select: { state: true },
  });

  if (stored === null) return false;

  Y.applyUpdate(document, new Uint8Array(stored.state));
  return true;
}

export async function storeBoardDocument(
  prisma: PrismaClient,
  boardId: string,
  document: Y.Doc,
): Promise<void> {
  const state = Buffer.from(Y.encodeStateAsUpdate(document));
  const canonicalJson = readSemanticModel(document);

  await prisma.$transaction([
    prisma.boardDocument.upsert({
      where: { boardId },
      create: { boardId, state },
      update: { state },
    }),
    // La proyeccion se guarda siempre en la version 1: las versiones numeradas
    // son para los snapshots inmutables de generacion (RA-08), que congela el
    // proceso HTTP cuando alguien pulsa generar. Esta es solo la foto vigente.
    prisma.boardSnapshot.upsert({
      where: { boardId_version: { boardId, version: 1 } },
      create: { boardId, version: 1, canonicalJson },
      update: { canonicalJson },
    }),
  ]);
}
```

---

## Esquema y migraciones

Fuente de verdad del modelo relacional de la plataforma.

### Estructura

```text
backend/prisma/
|-- migrations/
|   |-- 20260829183809_inicial/
|   |   `-- migration.sql
|   |-- 20260830020000_auditoria_lote_unico/
|   |   `-- migration.sql
|   |-- 20260830170000_manifiesto_de_generacion/
|   |   `-- migration.sql
|   |-- 20260830183000_auditoria_por_pizarra/
|   |   `-- migration.sql
|   |-- 20260831090000_perfil_y_recuperacion/
|   |   `-- migration.sql
|   |-- 20260905110000_retirar_objetivo_dart/
|   |   `-- migration.sql
|   |-- 20260906110000_generacion_android/
|   |   `-- migration.sql
|   |-- 20260912090000_revocacion_sesiones/
|   |   `-- migration.sql
|   |-- 20260919010000_activacion_correo/
|   |   `-- migration.sql
|   |-- 20260920120000_margen_rotacion_refresh/
|   |   `-- migration.sql
|   `-- migration_lock.toml
`-- schema.prisma
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `backend/prisma/schema.prisma` | 254 |
| `backend/prisma/migrations/migration_lock.toml` | 4 |
| `backend/prisma/migrations/20260829183809_inicial/migration.sql` | 189 |
| `backend/prisma/migrations/20260830020000_auditoria_lote_unico/migration.sql` | 11 |
| `backend/prisma/migrations/20260830170000_manifiesto_de_generacion/migration.sql` | 45 |
| `backend/prisma/migrations/20260830183000_auditoria_por_pizarra/migration.sql` | 7 |
| `backend/prisma/migrations/20260831090000_perfil_y_recuperacion/migration.sql` | 30 |
| `backend/prisma/migrations/20260905110000_retirar_objetivo_dart/migration.sql` | 9 |
| `backend/prisma/migrations/20260906110000_generacion_android/migration.sql` | 3 |
| `backend/prisma/migrations/20260912090000_revocacion_sesiones/migration.sql` | 2 |
| `backend/prisma/migrations/20260919010000_activacion_correo/migration.sql` | 13 |
| `backend/prisma/migrations/20260920120000_margen_rotacion_refresh/migration.sql` | 8 |

---

### `backend/prisma/schema.prisma`

```prisma
// Esquema de la plataforma. Corresponde a la seccion 5.2 del plan maestro.
//
// RA-11: el documento colaborativo se persiste en su representacion binaria
// nativa (BoardDocument.state). El JSON canonico (BoardSnapshot) es proyeccion
// derivada y nunca reconstruye el documento.
//
// Fase 0: el esquema queda declarado. Las migraciones y el acceso desde los
// procesos llegan en la fase 3.

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
}

enum ProjectRole {
  OWNER
  EDITOR
  VIEWER
}

enum BatchOrigin {
  GUI
  AI_TEXT
  AI_VOICE
  IMAGE
  XMI
}

model User {
  id             String   @id @default(uuid()) @db.Uuid
  email          String   @unique
  displayName    String
  // RNF-08: derivacion lenta. Nunca cifrado reversible, nunca hash simple.
  passwordHash   String
  sessionVersion Int      @default(0)
  createdAt      DateTime @default(now())
  emailVerifiedAt DateTime?
  emailVerificationTokenHash String? @unique
  emailVerificationExpiresAt DateTime?
  emailVerificationSentAt DateTime?

  // Foto de perfil. Se guarda en la base y no en disco ni en almacenamiento de
  // objetos: la plataforma no tiene ninguno de los dos, y una imagen recortada
  // a 256x256 ocupa unas decenas de kilobytes. El limite lo impone la ruta.
  avatar         Bytes?
  avatarMimeType String?

  refreshTokens  RefreshToken[]
  passwordResets PasswordReset[]
  memberships    ProjectMember[]
  ownedProjects  Project[]       @relation("ProjectOwner")
  createdInvites ProjectInvite[]
  generations    Generation[]

  @@map("users")
}

// Recuperacion de contrasena (RF-A10).
//
// Se guarda el hash del testigo, nunca el testigo: quien lea la base no puede
// usarlo para entrar, igual que con los tokens de refresco. Es de un solo uso y
// caduca, porque un enlace de recuperacion vivo en una bandeja de correo es una
// llave olvidada encima de la mesa.
model PasswordReset {
  id        String    @id @default(uuid()) @db.Uuid
  userId    String    @db.Uuid
  tokenHash String    @unique
  expiresAt DateTime
  usedAt    DateTime?
  createdAt DateTime  @default(now())

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId])
  @@map("password_resets")
}

model RefreshToken {
  id        String    @id @default(uuid()) @db.Uuid
  userId    String    @db.Uuid
  tokenHash String    @unique
  expiresAt DateTime
  revokedAt DateTime?
  createdAt DateTime  @default(now())

  /// El token que lo sustituyo al rotar. Permite distinguir una respuesta de
  /// renovacion que no llego al navegador —su reemplazo sigue sin usarse— de la
  /// reutilizacion de un token viejo, que si es motivo para cerrar la sesion.
  replacedById String? @db.Uuid

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId])
  @@map("refresh_tokens")
}

model Project {
  id            String   @id @default(uuid()) @db.Uuid
  displayName   String
  ownerId       String   @db.Uuid
  schemaVersion String
  createdAt     DateTime @default(now())

  owner   User            @relation("ProjectOwner", fields: [ownerId], references: [id])
  members ProjectMember[]
  invites ProjectInvite[]
  boards  Board[]

  @@index([ownerId])
  @@map("projects")
}

model ProjectMember {
  projectId String      @db.Uuid
  userId    String      @db.Uuid
  role      ProjectRole
  joinedAt  DateTime    @default(now())

  project Project @relation(fields: [projectId], references: [id], onDelete: Cascade)
  user    User    @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@id([projectId, userId])
  @@index([userId])
  @@map("project_members")
}

model ProjectInvite {
  id        String      @id @default(uuid()) @db.Uuid
  projectId String      @db.Uuid
  code      String      @unique
  role      ProjectRole
  expiresAt DateTime
  createdBy String      @db.Uuid
  createdAt DateTime    @default(now())

  project Project @relation(fields: [projectId], references: [id], onDelete: Cascade)
  creator User    @relation(fields: [createdBy], references: [id])

  @@index([projectId])
  @@map("project_invites")
}

model Board {
  id          String   @id @default(uuid()) @db.Uuid
  projectId   String   @db.Uuid
  displayName String
  type        String   @default("CLASS_DIAGRAM")
  createdAt   DateTime @default(now())

  project     Project          @relation(fields: [projectId], references: [id], onDelete: Cascade)
  document    BoardDocument?
  snapshots   BoardSnapshot[]
  generations Generation[]
  operations  AuditOperation[]

  @@index([projectId])
  @@map("boards")
}

model BoardDocument {
  boardId   String   @id @db.Uuid
  // Estado binario nativo del documento colaborativo (RA-11).
  state     Bytes
  updatedAt DateTime @updatedAt

  board Board @relation(fields: [boardId], references: [id], onDelete: Cascade)

  @@map("board_documents")
}

model BoardSnapshot {
  boardId       String   @db.Uuid
  version       Int
  canonicalJson Json
  updatedAt     DateTime @updatedAt

  board       Board        @relation(fields: [boardId], references: [id], onDelete: Cascade)
  generations Generation[]

  @@id([boardId, version])
  @@map("board_snapshots")
}

// Manifiesto de una generacion (ADR-018).
//
// El artefacto no se almacena: se regenera desde el snapshot congelado. Eso
// solo es cierto si se congela tambien todo lo demas que entra en la emision.
// Antes se guardaba el snapshot y nada mas, asi que el paquete Java elegido se
// perdia y el nombre del proyecto se releia de la pizarra: renombrarla cambiaba
// el artefacto de una generacion anterior.
model Generation {
  id              String   @id @default(uuid()) @db.Uuid
  boardId         String   @db.Uuid
  snapshotVersion Int
  createdBy       String   @db.Uuid
  createdAt       DateTime @default(now())

  // --- Manifiesto: las entradas de la emision, congeladas ---
  // Nombre con el que se genero. No se relee de la pizarra, que puede cambiar.
  projectName   String
  artifactId    String
  basePackage   String
  schemaVersion String
  // Huella de las plantillas. Si cambia, los bytes de esta generacion cambian.
  templatesHash String

  status GenerationStatus @default(CREATING)
  // Motivo saneado del fallo. Solo cuando status es FAILED.
  error  String?

  // SHA-256 de cada objetivo, para comprobar que dos descargas coinciden.
  springSha256 String?
  mobileSha256 String?

  board    Board         @relation(fields: [boardId], references: [id], onDelete: Cascade)
  snapshot BoardSnapshot @relation(fields: [boardId, snapshotVersion], references: [boardId, version])
  author   User          @relation(fields: [createdBy], references: [id])

  @@index([boardId])
  @@map("generations")
}

enum GenerationStatus {
  // La fila existe, el artefacto todavia no se ha emitido.
  CREATING
  // Los dos objetivos se emitieron y su huella quedo registrada.
  READY
  // La emision fallo. Se conserva para poder explicar por que.
  FAILED
}

// CA-023.1: los comandos se registran para auditoria, no para sincronizar.
model AuditOperation {
  id        String      @id @default(uuid()) @db.Uuid
  boardId   String      @db.Uuid
  // Unico: un lote es una entrada, y reintentar el registro tras un corte de red
  // no puede duplicarla. El lote ya es la unidad transaccional del dominio
  // (RA-03); aqui es tambien la unidad de identidad.
  batchId   String      @db.Uuid
  origin    BatchOrigin
  actorId   String      @db.Uuid
  payload   Json
  createdAt DateTime    @default(now())

  board Board @relation(fields: [boardId], references: [id], onDelete: Cascade)

  @@unique([boardId, batchId])
  @@index([boardId, createdAt])
  @@map("audit_operations")
}
```

---

### `backend/prisma/migrations/migration_lock.toml`

```toml
# Please do not edit this file manually
# It should be added in your version-control system (e.g., Git)
provider = "postgresql"
```

---

### `backend/prisma/migrations/20260829183809_inicial/migration.sql`

```sql
-- CreateEnum
CREATE TYPE "ProjectRole" AS ENUM ('OWNER', 'EDITOR', 'VIEWER');

-- CreateEnum
CREATE TYPE "BatchOrigin" AS ENUM ('GUI', 'AI_TEXT', 'AI_VOICE', 'IMAGE', 'XMI');

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "email" TEXT NOT NULL,
    "displayName" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "refresh_tokens" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "revokedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "refresh_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "projects" (
    "id" UUID NOT NULL,
    "displayName" TEXT NOT NULL,
    "ownerId" UUID NOT NULL,
    "schemaVersion" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "projects_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_members" (
    "projectId" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "role" "ProjectRole" NOT NULL,
    "joinedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "project_members_pkey" PRIMARY KEY ("projectId","userId")
);

-- CreateTable
CREATE TABLE "project_invites" (
    "id" UUID NOT NULL,
    "projectId" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "role" "ProjectRole" NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdBy" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "project_invites_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "boards" (
    "id" UUID NOT NULL,
    "projectId" UUID NOT NULL,
    "displayName" TEXT NOT NULL,
    "type" TEXT NOT NULL DEFAULT 'CLASS_DIAGRAM',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "boards_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "board_documents" (
    "boardId" UUID NOT NULL,
    "state" BYTEA NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "board_documents_pkey" PRIMARY KEY ("boardId")
);

-- CreateTable
CREATE TABLE "board_snapshots" (
    "boardId" UUID NOT NULL,
    "version" INTEGER NOT NULL,
    "canonicalJson" JSONB NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "board_snapshots_pkey" PRIMARY KEY ("boardId","version")
);

-- CreateTable
CREATE TABLE "generations" (
    "id" UUID NOT NULL,
    "boardId" UUID NOT NULL,
    "snapshotVersion" INTEGER NOT NULL,
    "createdBy" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "generations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_operations" (
    "id" UUID NOT NULL,
    "boardId" UUID NOT NULL,
    "batchId" UUID NOT NULL,
    "origin" "BatchOrigin" NOT NULL,
    "actorId" UUID NOT NULL,
    "payload" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_operations_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "refresh_tokens_tokenHash_key" ON "refresh_tokens"("tokenHash");

-- CreateIndex
CREATE INDEX "refresh_tokens_userId_idx" ON "refresh_tokens"("userId");

-- CreateIndex
CREATE INDEX "projects_ownerId_idx" ON "projects"("ownerId");

-- CreateIndex
CREATE INDEX "project_members_userId_idx" ON "project_members"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "project_invites_code_key" ON "project_invites"("code");

-- CreateIndex
CREATE INDEX "project_invites_projectId_idx" ON "project_invites"("projectId");

-- CreateIndex
CREATE INDEX "boards_projectId_idx" ON "boards"("projectId");

-- CreateIndex
CREATE INDEX "generations_boardId_idx" ON "generations"("boardId");

-- CreateIndex
CREATE INDEX "audit_operations_boardId_createdAt_idx" ON "audit_operations"("boardId", "createdAt");

-- CreateIndex
CREATE INDEX "audit_operations_batchId_idx" ON "audit_operations"("batchId");

-- AddForeignKey
ALTER TABLE "refresh_tokens" ADD CONSTRAINT "refresh_tokens_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "projects" ADD CONSTRAINT "projects_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_members" ADD CONSTRAINT "project_members_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_members" ADD CONSTRAINT "project_members_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_invites" ADD CONSTRAINT "project_invites_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_invites" ADD CONSTRAINT "project_invites_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "boards" ADD CONSTRAINT "boards_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "board_documents" ADD CONSTRAINT "board_documents_boardId_fkey" FOREIGN KEY ("boardId") REFERENCES "boards"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "board_snapshots" ADD CONSTRAINT "board_snapshots_boardId_fkey" FOREIGN KEY ("boardId") REFERENCES "boards"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "generations" ADD CONSTRAINT "generations_boardId_fkey" FOREIGN KEY ("boardId") REFERENCES "boards"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "generations" ADD CONSTRAINT "generations_boardId_snapshotVersion_fkey" FOREIGN KEY ("boardId", "snapshotVersion") REFERENCES "board_snapshots"("boardId", "version") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "generations" ADD CONSTRAINT "generations_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_operations" ADD CONSTRAINT "audit_operations_boardId_fkey" FOREIGN KEY ("boardId") REFERENCES "boards"("id") ON DELETE CASCADE ON UPDATE CASCADE;
```

---

### `backend/prisma/migrations/20260830020000_auditoria_lote_unico/migration.sql`

```sql
-- Un lote es una entrada de auditoria, y reintentar el registro tras un corte de
-- red no puede duplicarla. El lote ya es la unidad transaccional del dominio
-- (RA-03); aqui pasa a ser tambien la unidad de identidad, para que la ruta de
-- registro pueda ser idempotente.

-- DropIndex
DROP INDEX "audit_operations_batchId_idx";

-- CreateIndex
CREATE UNIQUE INDEX "audit_operations_batchId_key" ON "audit_operations"("batchId");
```

---

### `backend/prisma/migrations/20260830170000_manifiesto_de_generacion/migration.sql`

```sql
-- Manifiesto de generacion (ADR-018 enmendado).
--
-- ADR-018 no guarda el ZIP: promete regenerarlo desde el snapshot congelado.
-- Faltaba congelar el resto de las entradas de la emision, asi que el paquete
-- Java elegido se perdia y el nombre del proyecto se releia de la pizarra.
--
-- Las filas existentes se rellenan con lo que **de hecho** se usaba al
-- descargarlas: el paquete por defecto del generador y el nombre actual de su
-- pizarra. No es una reconstruccion inventada — es exactamente lo que la ruta de
-- descarga hacia antes de este cambio.

CREATE TYPE "GenerationStatus" AS ENUM ('CREATING', 'READY', 'FAILED');

ALTER TABLE "generations"
  ADD COLUMN "projectName"   TEXT,
  ADD COLUMN "artifactId"    TEXT,
  ADD COLUMN "basePackage"   TEXT NOT NULL DEFAULT 'bo.edu.sw1',
  ADD COLUMN "schemaVersion" TEXT NOT NULL DEFAULT '1.0.0',
  ADD COLUMN "templatesHash" TEXT NOT NULL DEFAULT 'desconocida',
  ADD COLUMN "status" "GenerationStatus" NOT NULL DEFAULT 'CREATING',
  ADD COLUMN "error"        TEXT,
  ADD COLUMN "springSha256" TEXT,
  ADD COLUMN "dartSha256"   TEXT;

UPDATE "generations" AS g
SET "projectName" = b."displayName",
    "artifactId"  = lower(regexp_replace(b."displayName", '[^a-zA-Z0-9]+', '-', 'g')),
    -- READY sin huellas: son anteriores al manifiesto y no hay con que
    -- comparar. La ruta de descarga lo distingue de una generacion nueva.
    "status"      = 'READY'
FROM "boards" AS b
WHERE b."id" = g."boardId";

ALTER TABLE "generations"
  ALTER COLUMN "projectName" SET NOT NULL,
  ALTER COLUMN "artifactId"  SET NOT NULL;

-- Los valores por defecto existian solo para poder rellenar lo que ya estaba.
-- Una generacion nueva declara los suyos: si el codigo se olvida de uno, tiene
-- que fallar, no heredar un valor plausible.
ALTER TABLE "generations"
  ALTER COLUMN "basePackage"   DROP DEFAULT,
  ALTER COLUMN "schemaVersion" DROP DEFAULT,
  ALTER COLUMN "templatesHash" DROP DEFAULT;
```

---

### `backend/prisma/migrations/20260830183000_auditoria_por_pizarra/migration.sql`

```sql
-- La idempotencia pertenece a una pizarra. Un batchId repetido en otra no debe
-- hacer que la API responda 202 sin registrar nada en la pizarra solicitada.
DROP INDEX IF EXISTS "audit_operations_batchId_key";

CREATE UNIQUE INDEX "audit_operations_boardId_batchId_key"
  ON "audit_operations"("boardId", "batchId");
```

---

### `backend/prisma/migrations/20260831090000_perfil_y_recuperacion/migration.sql`

```sql
-- Perfil de usuario y recuperacion de contrasena (RF-A10, RF-A11).
--
-- La foto se guarda en la base y no en disco ni en almacenamiento de objetos:
-- la plataforma no tiene ninguno de los dos, y la ruta recorta la imagen a
-- 256x256, que son unas decenas de kilobytes por usuario.
--
-- Del testigo de recuperacion se guarda el hash, nunca el testigo, igual que
-- con los de refresco: quien lea la base no puede usarlo para entrar.

ALTER TABLE "users"
  ADD COLUMN "avatar" BYTEA,
  ADD COLUMN "avatarMimeType" TEXT;

CREATE TABLE "password_resets" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "usedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "password_resets_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "password_resets_tokenHash_key" ON "password_resets"("tokenHash");
CREATE INDEX "password_resets_userId_idx" ON "password_resets"("userId");

ALTER TABLE "password_resets" ADD CONSTRAINT "password_resets_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
```

---

### `backend/prisma/migrations/20260905110000_retirar_objetivo_dart/migration.sql`

```sql
-- La generacion deja de emitir la aplicacion Flutter: solo queda el backend
-- Spring Boot, y con el una sola huella por generacion.
--
-- Se borra la columna en lugar de dejarla nula para siempre: una columna que
-- nadie escribe y nadie lee es una pregunta abierta para quien lea el esquema
-- dentro de un mes. El historial de generaciones anteriores conserva su
-- `springSha256`, que es lo unico que hoy se puede volver a emitir.
ALTER TABLE "generations" DROP COLUMN IF EXISTS "dartSha256";
```

---

### `backend/prisma/migrations/20260906110000_generacion_android/migration.sql`

```sql
-- Optional paired Android + Spring artifact. Existing generations remain Spring-only.
ALTER TABLE "generations" ADD COLUMN "mobileSha256" TEXT;
```

---

### `backend/prisma/migrations/20260912090000_revocacion_sesiones/migration.sql`

```sql
ALTER TABLE "users" ADD COLUMN "sessionVersion" INTEGER NOT NULL DEFAULT 0;
```

---

### `backend/prisma/migrations/20260919010000_activacion_correo/migration.sql`

```sql
ALTER TABLE "users"
  ADD COLUMN "emailVerifiedAt" TIMESTAMP(3),
  ADD COLUMN "emailVerificationTokenHash" TEXT,
  ADD COLUMN "emailVerificationExpiresAt" TIMESTAMP(3),
  ADD COLUMN "emailVerificationSentAt" TIMESTAMP(3);

-- Conservar el acceso de las cuentas anteriores a esta funcionalidad.
-- Las nuevas cuentas quedan pendientes por defecto (NULL).
UPDATE "users" SET "emailVerifiedAt" = "createdAt";

CREATE UNIQUE INDEX "users_emailVerificationTokenHash_key"
  ON "users"("emailVerificationTokenHash");
```

---

### `backend/prisma/migrations/20260920120000_margen_rotacion_refresh/migration.sql`

```sql
-- Enlaza cada token de refresco con el que lo sustituyo al rotar.
--
-- Sin este enlace no se puede distinguir «la respuesta de la renovacion no
-- llego al navegador» de «alguien reutiliza un token viejo»: en los dos casos
-- llega un token revocado. Las filas anteriores quedan en NULL y siguen
-- rechazandose, que es el comportamiento que ya tenian.
ALTER TABLE "refresh_tokens" ADD COLUMN "replacedById" UUID;
```

---

## Configuracion de Prisma

### Estructura

```text
prisma.config.ts
`-- prisma.config.ts
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `prisma.config.ts` | 21 |

---

### `prisma.config.ts`

```ts
import { defineConfig } from 'prisma/config';

/**
 * Prisma 7 saco la URL de conexion del archivo de esquema. Vive aqui y se lee de
 * la variable de entorno: RNF-08, ningun secreto queda escrito en el repositorio.
 */
const url = process.env['DATABASE_URL'];

export default defineConfig({
  schema: 'backend/prisma/schema.prisma',
  migrations: {
    path: 'backend/prisma/migrations',
  },
  // La cadena de conexion solo se declara si existe. `prisma generate` no
  // necesita base de datos, y sin esta condicion no se podria generar el cliente
  // durante la construccion de una imagen ni en integracion continua, que es
  // justo donde no hay ninguna base a la que apuntar. `migrate` sigue fallando
  // con un mensaje claro si falta.
  ...(url === undefined ? {} : { datasource: { url } }),
});
```

