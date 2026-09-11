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
      return new SignJWT({ email: claims.email } satisfies JWTPayload)
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
      if (typeof userId !== 'string' || typeof email !== 'string') {
        throw new InvalidTokenError();
      }

      return { userId, email };
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
