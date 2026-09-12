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
