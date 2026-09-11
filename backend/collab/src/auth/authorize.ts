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
  if (typeof userId !== 'string' || typeof email !== 'string' || typeof payload.exp !== 'number') {
    throw new UnauthorizedConnection(
      CONNECTION_REJECTIONS.TOKEN_INVALIDO,
      'El token no identifica a un usuario.',
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
    },
    // CA-A08.2: el rol de lectura se conecta, ve y no escribe.
    readOnly: !roleCanWrite(membership.role),
  };
}
