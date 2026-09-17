import { CONCEPTUAL_TYPES, MULTIPLICITIES, RELATIONSHIP_KINDS } from '@uml/contracts';
import { z } from 'zod';

/**
 * Lo que el modelo puede proponer.
 *
 * **El vocabulario es cerrado** (RA-06). Once operaciones, cada una con su carga
 * tipada. Si el vocabulario fuera abierto, cada respuesta del proveedor seria una
 * superficie de ataque y una fuente de estados imposibles.
 *
 * **Las operaciones se expresan por nombre, no por identificador.** El modelo
 * nunca resuelve identificadores (6.5): devuelve nombres y el resolver los busca
 * en el modelo real. Un identificador inventado seria indetectable como error y
 * produciria un comando que apunta a nada.
 *
 * De este esquema sale el formato de salida estructurada que se le pasa al
 * proveedor, y el mismo esquema valida lo que devuelve. Mantener a mano un
 * esquema JSON y aparte estos tipos garantiza que en algun momento discrepen.
 */

const className = z.string().trim().min(1).max(120);
const memberName = z.string().trim().min(1).max(120);

const createClass = z
  .object({
    op: z.literal('CREATE_CLASS'),
    className,
  })
  .strict();

const renameClass = z
  .object({
    op: z.literal('RENAME_CLASS'),
    className,
    newName: className,
  })
  .strict();

const deleteClass = z
  .object({
    op: z.literal('DELETE_CLASS'),
    className,
  })
  .strict();

const addAttribute = z
  .object({
    op: z.literal('ADD_ATTRIBUTE'),
    className,
    attributeName: memberName,
    type: z.enum(CONCEPTUAL_TYPES),
    primaryKey: z.boolean().optional(),
    required: z.boolean().optional(),
    unique: z.boolean().optional(),
  })
  .strict();

const updateAttribute = z
  .object({
    op: z.literal('UPDATE_ATTRIBUTE'),
    className,
    attributeName: memberName,
    newName: memberName.optional(),
    type: z.enum(CONCEPTUAL_TYPES).optional(),
    primaryKey: z.boolean().optional(),
    required: z.boolean().optional(),
    unique: z.boolean().optional(),
  })
  .strict();

const deleteAttribute = z
  .object({
    op: z.literal('DELETE_ATTRIBUTE'),
    className,
    attributeName: memberName,
  })
  .strict();

const createRelationship = z
  .object({
    op: z.literal('CREATE_RELATIONSHIP'),
    /**
     * Ausente significa asociacion. En una generalizacion `fromClass` es la
     * subclase y `toClass` la superclase.
     */
    kind: z.enum(RELATIONSHIP_KINDS).optional(),
    fromClass: className,
    toClass: className,
    fromMultiplicity: z.enum(MULTIPLICITIES),
    toMultiplicity: z.enum(MULTIPLICITIES),
    fromRole: memberName.optional(),
    toRole: memberName.optional(),
  })
  .strict();

const changeMultiplicity = z
  .object({
    op: z.literal('CHANGE_MULTIPLICITY'),
    fromClass: className,
    toClass: className,
    fromRole: memberName.optional(),
    toRole: memberName.optional(),
    fromMultiplicity: z.enum(MULTIPLICITIES).optional(),
    toMultiplicity: z.enum(MULTIPLICITIES).optional(),
  })
  .strict();

const deleteRelationship = z
  .object({
    op: z.literal('DELETE_RELATIONSHIP'),
    fromClass: className,
    toClass: className,
    fromRole: memberName.optional(),
    toRole: memberName.optional(),
  })
  .strict();

export const assistantOperationSchema = z.discriminatedUnion('op', [
  createClass,
  renameClass,
  deleteClass,
  addAttribute,
  updateAttribute,
  deleteAttribute,
  createRelationship,
  changeMultiplicity,
  deleteRelationship,
]);

export type AssistantOperation = z.infer<typeof assistantOperationSchema>;

/**
 * Cuantas operaciones cabe proponer de una vez.
 *
 * El numero sale de RNF-03, que promete soportar **30 clases, 100 atributos y
 * 40 relaciones**: importar un modelo de ese tamano son 170 operaciones, y en
 * modo «reemplazar» se suman los borrados de lo que habia. 200 cubre las dos
 * cosas.
 *
 * Antes eran 40, y no era un numero pensado: era el tope del asistente por
 * texto —donde una instruccion produce tres o cuatro operaciones— aplicado sin
 * querer a la importacion por fotografia. Un diagrama entidad-relacion normal,
 * de ocho tablas, necesita sesenta. El resultado era que la foto se importaba
 * **truncada y en silencio**: el modelo cortaba en la operacion cuarenta y la
 * persona solo se enteraba comparando con el original.
 */
export const MAX_PROPOSAL_OPERATIONS = 200;

/**
 * Una modificacion que no modifica nada.
 *
 * Se comprueba aparte del esquema de cada operacion porque el rescate de una
 * propuesta defectuosa filtra operacion por operacion, y una de estas pasaria
 * el filtro y haria fallar el lote entero al final.
 */
export function esOperacionVacia(operation: AssistantOperation): boolean {
  if (operation.op === 'UPDATE_ATTRIBUTE') {
    return (
      operation.newName === undefined &&
      operation.type === undefined &&
      operation.primaryKey === undefined &&
      operation.required === undefined &&
      operation.unique === undefined
    );
  }
  if (operation.op === 'CHANGE_MULTIPLICITY') {
    return operation.fromMultiplicity === undefined && operation.toMultiplicity === undefined;
  }
  return false;
}

export const batchProposalSchema = z
  .object({
    operations: z.array(assistantOperationSchema).max(MAX_PROPOSAL_OPERATIONS),
    /**
     * Una frase sobre lo que entendio. Se le ensena al usuario junto a la vista
     * previa; no se usa para decidir nada.
     */
    rationale: z.string().max(400).optional(),
    /**
     * Lo que el modelo no pudo resolver por si mismo.
     *
     * Se distingue de una propuesta vacia: "no entendi" y "no hay nada que hacer"
     * necesitan respuestas distintas en la interfaz.
     */
    needsClarification: z.string().trim().min(1).max(300).optional(),
  })
  .superRefine((proposal, ctx) => {
    proposal.operations.forEach((operation, index) => {
      if (esOperacionVacia(operation))
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['operations', index],
          message: 'La operacion debe indicar al menos un cambio.',
        });
    });
  });

export type BatchProposal = z.infer<typeof batchProposalSchema>;

/**
 * El esquema JSON que se le entrega al proveedor como formato de salida.
 *
 * Se escribe a mano y no se deriva de Zod porque los proveedores exigen un
 * subconjunto estricto de JSON Schema —sin `anyOf` de discriminadores, con
 * `additionalProperties: false` en todas partes— que los generadores automaticos
 * no producen igual. Una prueba comprueba que las dos definiciones enumeran las
 * mismas operaciones, que es lo unico que puede desincronizarse en silencio.
 */
export const PROPOSAL_JSON_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['operations'],
  properties: {
    operations: {
      type: 'array',
      maxItems: MAX_PROPOSAL_OPERATIONS,
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['op'],
        properties: {
          op: {
            type: 'string',
            enum: [
              'CREATE_CLASS',
              'RENAME_CLASS',
              'DELETE_CLASS',
              'ADD_ATTRIBUTE',
              'UPDATE_ATTRIBUTE',
              'DELETE_ATTRIBUTE',
              'CREATE_RELATIONSHIP',
              'CHANGE_MULTIPLICITY',
              'DELETE_RELATIONSHIP',
            ],
          },
          className: { type: 'string' },
          newName: { type: 'string' },
          attributeName: { type: 'string' },
          type: { type: 'string', enum: [...CONCEPTUAL_TYPES] },
          primaryKey: { type: 'boolean' },
          required: { type: 'boolean' },
          unique: { type: 'boolean' },
          fromClass: { type: 'string' },
          toClass: { type: 'string' },
          fromMultiplicity: { type: 'string', enum: [...MULTIPLICITIES] },
          toMultiplicity: { type: 'string', enum: [...MULTIPLICITIES] },
          fromRole: { type: 'string' },
          toRole: { type: 'string' },
          // Sin esto el proveedor no puede proponer una herencia aunque el
          // contrato la acepte: el esquema declara `additionalProperties:
          // false`, asi que una propiedad que no este aqui se rechaza —o se
          // descarta en silencio— antes de que nadie la valide.
          kind: { type: 'string', enum: [...RELATIONSHIP_KINDS] },
        },
      },
    },
    rationale: { type: 'string' },
    needsClarification: { type: 'string' },
  },
} as const;

/**
 * Si una propuesta llego al tope, probablemente venga cortada.
 *
 * No hay forma de que el modelo avise: se le da un maximo y lo respeta sin
 * decir que dejo cosas fuera. Llegar justo al limite es la unica senal que
 * queda, y basta para advertir en vez de dar por buena una lectura incompleta.
 */
export function pareceTruncada(proposal: BatchProposal): boolean {
  return proposal.operations.length >= MAX_PROPOSAL_OPERATIONS;
}

/** Las operaciones que el esquema JSON declara, para comprobar que no divergen. */
export const PROPOSAL_OPERATION_NAMES = PROPOSAL_JSON_SCHEMA.properties.operations.items.properties
  .op.enum as readonly string[];
