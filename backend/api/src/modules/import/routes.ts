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
