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
    const adapter = new PrismaPg({ connectionString: options.config.DATABASE_URL });
    const prisma = new PrismaClient({ adapter });

    app.decorate('prisma', prisma);
    app.addHook('onClose', async () => {
      await prisma.$disconnect();
    });
  },
  { name: 'prisma' },
);
