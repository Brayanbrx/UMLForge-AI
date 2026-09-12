import { SCHEMA_VERSION } from '@uml/contracts';
import { Prisma } from '@prisma/client';
import type { FastifyInstance, FastifyReply } from 'fastify';
import { z } from 'zod';
import type { Config } from '../../config.js';
import { conflict, unauthorized } from '../../lib/http-error.js';
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
 * Alcance minimo y deliberado. No hay verificacion por correo ni inicio de
 * sesion con terceros: cada uno arrastraria un tercero al camino critico.
 *
 * La recuperacion de contrasena si existe desde el 31 de agosto de 2026, y vive
 * en `profile.ts`. Lo que la hizo posible sin romper esa regla es que el envio
 * esta detras de un puerto: el adaptador por defecto escribe el correo en el
 * registro del servidor, asi que la plataforma sigue arrancando y funcionando
 * sin ninguna cuenta de correo configurada.
 */
export async function authRoutes(app: FastifyInstance, options: { config: Config }): Promise<void> {
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
        where: { id: user.id, sessionVersion: user.sessionVersion },
        data: { sessionVersion: user.sessionVersion },
      });
      if (current.count !== 1) throw unauthorized('La sesión fue revocada.');
      if (consumedRefreshId !== undefined) {
        const now = new Date();
        const consumed = await tx.refreshToken.updateMany({
          where: {
            id: consumedRefreshId,
            userId: user.id,
            revokedAt: null,
            expiresAt: { gt: now },
          },
          data: { revokedAt: now },
        });
        if (consumed.count !== 1) throw unauthorized('La sesión expiró.');
      }
      await tx.refreshToken.create({
        data: {
          userId: user.id,
          tokenHash: refresh.hash,
          expiresAt: new Date(Date.now() + config.REFRESH_TOKEN_TTL_SECONDS * 1000),
        },
      });
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
    return issueSession(reply, user);
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

    return issueSession(reply, user);
  });

  /**
   * RF-A03. El token de refresco es rotativo: cada renovacion revoca el anterior
   * y entrega uno nuevo. Si alguien reutiliza uno ya rotado, no funciona.
   */
  app.post('/auth/refresh', async (request, reply) => {
    const presented = request.cookies[REFRESH_COOKIE];
    if (presented === undefined) throw unauthorized('No hay sesion que renovar.');

    const stored = await app.prisma.refreshToken.findUnique({
      where: { tokenHash: hashRefreshToken(presented) },
      include: { user: true },
    });

    if (stored === null || stored.revokedAt !== null) {
      // No se borra la cookie: otra pestana pudo rotar el token mientras esta
      // peticion estaba en vuelo, y un Set-Cookie tardio borraria el nuevo.
      throw unauthorized('La sesion expiro. Inicia sesion de nuevo.');
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
