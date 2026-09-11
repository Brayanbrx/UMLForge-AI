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
