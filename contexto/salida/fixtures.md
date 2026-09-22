# Banco de diagramas

Los diagramas de referencia T01 a T08 y los XMI de importacion. Es la evidencia de que el generador funciona sobre casos variados y no sobre un unico ejemplo favorable: `npm run test:bank` compila lo generado a partir de ellos.

> Generado el 2026-09-21 00:41 por `contexto/todo.py`.
> 21 archivos, 5,039 lineas, 217.2 KiB de codigo.
> Pruebas: excluidas. Dependencias, compilados y binarios: siempre excluidos.

> Sin archivos con los filtros actuales: `fixtures/tests`. Probar con `--con-pruebas`.

## Contenido

- [Construccion del banco](#construccion-del-banco) --- 7 archivos
- [Diagramas T01 a T08](#diagramas-t01-a-t08) --- 10 archivos
- [XMI de referencia](#xmi-de-referencia) --- 2 archivos
- [Paquete de fixtures](#paquete-de-fixtures) --- 1 archivo
- [TypeScript del banco](#typescript-del-banco) --- 1 archivo

---

## Construccion del banco

Definiciones, carga, serializacion y el informe de cobertura.

### Estructura

```text
fixtures/src/
|-- build.ts
|-- definitions.ts
|-- emit.ts
|-- index.ts
|-- load.ts
|-- report.ts
`-- serialize.ts
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `fixtures/src/build.ts` | 193 |
| `fixtures/src/definitions.ts` | 498 |
| `fixtures/src/emit.ts` | 25 |
| `fixtures/src/index.ts` | 38 |
| `fixtures/src/load.ts` | 119 |
| `fixtures/src/report.ts` | 33 |
| `fixtures/src/serialize.ts` | 27 |

---

### `fixtures/src/build.ts`

```ts
import {
  emptyBoardState,
  type BoardState,
  type ConceptualType,
  type Multiplicity,
  type RelationshipKind,
  type SemanticModel,
  type UmlAttribute,
  type UmlClass,
  type UmlRelationship,
} from '@uml/contracts';
import { normalizeName } from '@uml/domain-core';

/**
 * Constructor de modelos del banco de regresion.
 *
 * Los modelos se declaran en `definitions.ts` con nombres visuales, y aqui se
 * derivan los nombres tecnicos con el mismo normalizador que usa la plataforma.
 * Escribirlos a mano en el JSON garantizaria que en algun momento el banco pruebe
 * una normalizacion distinta de la real.
 *
 * Los identificadores son deterministas: dependen solo del nombre del modelo y
 * del elemento. Regenerar el banco no produce un diff (RNF-05).
 */

export interface AttributeSpec {
  readonly name: string;
  readonly type: ConceptualType;
  readonly primaryKey?: boolean;
  /** Por defecto los atributos son opcionales, como en el modelo canonico. */
  readonly required?: boolean;
  readonly unique?: boolean;
}

export interface RelationshipSpec {
  /**
   * Ausente significa asociacion, igual que en el modelo canonico.
   *
   * En una generalizacion `from` es la subclase y `to` la superclase, y las dos
   * multiplicidades se declaran por uniformidad aunque no signifiquen nada.
   */
  readonly kind?: RelationshipKind;
  readonly from: string;
  readonly fromMultiplicity: Multiplicity;
  readonly to: string;
  readonly toMultiplicity: Multiplicity;
  /** Rol del extremo origen. Nombra el campo cuando el destino es propietario. */
  readonly fromRole?: string;
  readonly toRole?: string;
}

export interface ClassSpec {
  readonly name: string;
  readonly attributes: readonly AttributeSpec[];
}

export interface FixtureSpec {
  readonly id: string;
  readonly title: string;
  /** Que cubre este modelo del banco (seccion 15.2 del plan maestro). */
  readonly coverage: string;
  readonly classes: readonly ClassSpec[];
  readonly relationships: readonly RelationshipSpec[];
}

export interface Fixture {
  readonly id: string;
  readonly title: string;
  readonly coverage: string;
  readonly model: SemanticModel;
  readonly boardState: BoardState;
}

// ---------------------------------------------------------------------------
// Identificadores deterministas
// ---------------------------------------------------------------------------

/**
 * UUID derivado de una ruta estable, sin depender de `node:crypto`.
 *
 * No es criptografico y no pretende serlo: solo tiene que ser estable entre
 * ejecuciones y entre maquinas, para que el banco no produzca diffs espurios y
 * para que un fallo del generador se pueda reproducir citando un identificador.
 */
export function deterministicId(path: string): string {
  let hash = 0x811c9dc5;
  for (let i = 0; i < path.length; i += 1) {
    hash ^= path.charCodeAt(i);
    hash = Math.imul(hash, 0x01000193) >>> 0;
  }

  const bytes: number[] = [];
  let estado = hash === 0 ? 0x9e3779b9 : hash;
  while (bytes.length < 16) {
    estado ^= estado << 13;
    estado >>>= 0;
    estado ^= estado >>> 17;
    estado ^= estado << 5;
    estado >>>= 0;
    bytes.push(
      estado & 0xff,
      (estado >>> 8) & 0xff,
      (estado >>> 16) & 0xff,
      (estado >>> 24) & 0xff,
    );
  }

  // Version 5 y variante RFC 4122, para que el identificador pase la validacion
  // de formato del esquema.
  bytes[6] = ((bytes[6] as number) & 0x0f) | 0x50;
  bytes[8] = ((bytes[8] as number) & 0x3f) | 0x80;

  const hex = bytes.slice(0, 16).map((b) => b.toString(16).padStart(2, '0'));
  return [
    hex.slice(0, 4).join(''),
    hex.slice(4, 6).join(''),
    hex.slice(6, 8).join(''),
    hex.slice(8, 10).join(''),
    hex.slice(10, 16).join(''),
  ].join('-');
}

// ---------------------------------------------------------------------------
// Construccion
// ---------------------------------------------------------------------------

export function buildFixture(spec: FixtureSpec): Fixture {
  const classIdOf = (className: string): string => deterministicId(`${spec.id}/class/${className}`);

  const classes: UmlClass[] = spec.classes.map((classSpec) => {
    const names = normalizeName(classSpec.name, 'CLASS');

    return {
      id: classIdOf(classSpec.name),
      displayName: classSpec.name,
      codeName: names.codeName,
      databaseName: names.databaseName,
      attributes: classSpec.attributes.map((attributeSpec) =>
        buildAttribute(spec.id, classSpec.name, attributeSpec),
      ),
    };
  });

  const relationships: UmlRelationship[] = spec.relationships.map((rel, indice) => ({
    id: deterministicId(`${spec.id}/rel/${indice}/${rel.from}-${rel.to}`),
    ...(rel.kind === undefined ? {} : { kind: rel.kind }),
    sourceClassId: classIdOf(rel.from),
    targetClassId: classIdOf(rel.to),
    sourceMultiplicity: rel.fromMultiplicity,
    targetMultiplicity: rel.toMultiplicity,
    ...(rel.fromRole === undefined ? {} : { sourceRoleName: rel.fromRole }),
    ...(rel.toRole === undefined ? {} : { targetRoleName: rel.toRole }),
  }));

  const model: SemanticModel = { classes, relationships };

  // Layout en rejilla. No tiene valor semantico; existe para que abrir un fixture
  // en el editor no amontone todas las clases en el origen.
  const boardState: BoardState = {
    ...emptyBoardState(),
    semantic: model,
    layout: {
      positions: Object.fromEntries(
        classes.map((umlClass, indice) => [
          umlClass.id,
          { x: (indice % 4) * 320, y: Math.floor(indice / 4) * 260 },
        ]),
      ),
      // El banco no fija tamanos: cada tarjeta se dibuja con el alto que le
      // corresponde por sus atributos.
      sizes: {},
    },
  };

  return { id: spec.id, title: spec.title, coverage: spec.coverage, model, boardState };
}

function buildAttribute(fixtureId: string, className: string, spec: AttributeSpec): UmlAttribute {
  const names = normalizeName(spec.name, 'ATTRIBUTE');

  return {
    id: deterministicId(`${fixtureId}/attr/${className}/${spec.name}`),
    displayName: spec.name,
    codeName: names.codeName,
    databaseName: names.databaseName,
    type: spec.type,
    primaryKey: spec.primaryKey ?? false,
    // Una clave primaria nunca es nula, se declare o no.
    nullable: spec.primaryKey === true ? false : !(spec.required ?? false),
    unique: spec.unique ?? false,
  };
}
```

---

### `fixtures/src/definitions.ts`

```ts
import type { FixtureSpec } from './build.js';

/**
 * Banco de regresion (plan maestro 15.2).
 *
 * Los modelos se declaran con nombres visuales. Los nombres tecnicos los deriva
 * el normalizador real, no se escriben aqui.
 *
 * T01 a T06 son modelos validos: el validador no debe encontrar ningun error en
 * ellos. T07 es lo contrario: existe para que encuentre exactamente los que se
 * enumeran en su ficha.
 */

const T01: FixtureSpec = {
  id: 'T01',
  title: 'Ventas',
  coverage: '1:N, N:1, decimales, fechas y entidad intermedia',
  classes: [
    {
      name: 'Cliente',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'nombre', type: 'String', required: true },
        { name: 'correo', type: 'String', required: true, unique: true },
        { name: 'telefono', type: 'String' },
      ],
    },
    {
      name: 'Producto',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'nombre', type: 'String', required: true },
        { name: 'precio', type: 'Decimal', required: true },
        { name: 'stock', type: 'Integer', required: true },
      ],
    },
    {
      name: 'Venta',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'fecha', type: 'DateTime', required: true },
        { name: 'total', type: 'Decimal', required: true },
      ],
    },
    {
      // RM-01: la relacion muchos a muchos entre Venta y Producto se modela con
      // esta clase intermedia explicita y dos relaciones N:1.
      name: 'Detalle de Venta',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'cantidad', type: 'Integer', required: true },
        { name: 'precio unitario', type: 'Decimal', required: true },
        { name: 'subtotal', type: 'Decimal', required: true },
      ],
    },
  ],
  relationships: [
    { from: 'Cliente', fromMultiplicity: '1', to: 'Venta', toMultiplicity: '0..*' },
    { from: 'Venta', fromMultiplicity: '1', to: 'Detalle de Venta', toMultiplicity: '0..*' },
    { from: 'Producto', fromMultiplicity: '1', to: 'Detalle de Venta', toMultiplicity: '0..*' },
  ],
};

const T02: FixtureSpec = {
  id: 'T02',
  title: 'Compras',
  coverage: 'Mismo patron que T01 con otra terminologia',
  classes: [
    {
      name: 'Proveedor',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'razon social', type: 'String', required: true },
        { name: 'nit', type: 'String', required: true, unique: true },
      ],
    },
    {
      name: 'Producto',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'nombre', type: 'String', required: true },
        { name: 'costo', type: 'Decimal', required: true },
      ],
    },
    {
      name: 'Compra',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'fecha', type: 'Date', required: true },
        { name: 'total', type: 'Decimal', required: true },
      ],
    },
    {
      name: 'Detalle de Compra',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'cantidad', type: 'Integer', required: true },
        { name: 'costo unitario', type: 'Decimal', required: true },
      ],
    },
  ],
  relationships: [
    { from: 'Proveedor', fromMultiplicity: '1', to: 'Compra', toMultiplicity: '0..*' },
    { from: 'Compra', fromMultiplicity: '1', to: 'Detalle de Compra', toMultiplicity: '0..*' },
    { from: 'Producto', fromMultiplicity: '1', to: 'Detalle de Compra', toMultiplicity: '0..*' },
  ],
};

const T03: FixtureSpec = {
  id: 'T03',
  title: 'Barberia',
  coverage: 'Caso de la aplicacion movil: varias claves foraneas en la entidad de registro',
  classes: [
    {
      name: 'Cliente',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'nombre', type: 'String', required: true },
        { name: 'telefono', type: 'String' },
      ],
    },
    {
      name: 'Barbero',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'nombre', type: 'String', required: true },
        { name: 'activo', type: 'Boolean', required: true },
      ],
    },
    {
      name: 'Servicio',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'nombre', type: 'String', required: true },
        { name: 'precio', type: 'Decimal', required: true },
        { name: 'duracion minutos', type: 'Integer', required: true },
      ],
    },
    {
      name: 'Atencion',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'fecha', type: 'DateTime', required: true },
        { name: 'monto', type: 'Decimal', required: true },
        { name: 'observacion', type: 'String' },
      ],
    },
  ],
  relationships: [
    { from: 'Cliente', fromMultiplicity: '1', to: 'Atencion', toMultiplicity: '0..*' },
    { from: 'Barbero', fromMultiplicity: '1', to: 'Atencion', toMultiplicity: '0..*' },
    { from: 'Servicio', fromMultiplicity: '1', to: 'Atencion', toMultiplicity: '0..*' },
  ],
};

const T04: FixtureSpec = {
  id: 'T04',
  title: 'Inventario de activos',
  coverage: 'Varias claves foraneas sobre una entidad y una relacion opcional',
  classes: [
    {
      name: 'Categoria',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'nombre', type: 'String', required: true, unique: true },
      ],
    },
    {
      name: 'Responsable',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'nombre', type: 'String', required: true },
        { name: 'correo', type: 'String', required: true, unique: true },
      ],
    },
    {
      name: 'Activo',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'codigo', type: 'String', required: true, unique: true },
        { name: 'descripcion', type: 'String', required: true },
        { name: 'valor', type: 'Decimal', required: true },
        { name: 'fecha alta', type: 'Date', required: true },
      ],
    },
    {
      name: 'Asignacion',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'fecha inicio', type: 'Date', required: true },
        { name: 'fecha fin', type: 'Date' },
      ],
    },
  ],
  relationships: [
    { from: 'Categoria', fromMultiplicity: '1', to: 'Activo', toMultiplicity: '0..*' },
    { from: 'Activo', fromMultiplicity: '1', to: 'Asignacion', toMultiplicity: '0..*' },
    { from: 'Responsable', fromMultiplicity: '1', to: 'Asignacion', toMultiplicity: '0..*' },
  ],
};

const T05: FixtureSpec = {
  id: 'T05',
  title: 'Cuentas y movimientos',
  coverage: 'Cadena de tres niveles de dependencia',
  classes: [
    {
      name: 'Cliente',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'nombre', type: 'String', required: true },
        { name: 'documento', type: 'String', required: true, unique: true },
      ],
    },
    {
      name: 'Cuenta',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'numero', type: 'String', required: true, unique: true },
        { name: 'saldo', type: 'Decimal', required: true },
        { name: 'activa', type: 'Boolean', required: true },
      ],
    },
    {
      name: 'Movimiento',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'fecha', type: 'DateTime', required: true },
        { name: 'monto', type: 'Decimal', required: true },
        { name: 'concepto', type: 'String', required: true },
      ],
    },
  ],
  relationships: [
    { from: 'Cliente', fromMultiplicity: '1', to: 'Cuenta', toMultiplicity: '0..*' },
    { from: 'Cuenta', fromMultiplicity: '1', to: 'Movimiento', toMultiplicity: '0..*' },
  ],
};

const T06: FixtureSpec = {
  id: 'T06',
  title: 'Inscripciones',
  coverage: 'Muchos a muchos con atributos, resuelto con entidad intermedia (RM-01)',
  classes: [
    {
      name: 'Alumno',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'nombre', type: 'String', required: true },
        { name: 'registro', type: 'String', required: true, unique: true },
      ],
    },
    {
      name: 'Materia',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'nombre', type: 'String', required: true },
        { name: 'sigla', type: 'String', required: true, unique: true },
        { name: 'creditos', type: 'Integer', required: true },
      ],
    },
    {
      name: 'Inscripcion',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'gestion', type: 'Integer', required: true },
        { name: 'nota', type: 'Decimal' },
        { name: 'fecha', type: 'Date', required: true },
      ],
    },
  ],
  relationships: [
    { from: 'Alumno', fromMultiplicity: '1', to: 'Inscripcion', toMultiplicity: '0..*' },
    { from: 'Materia', fromMultiplicity: '1', to: 'Inscripcion', toMultiplicity: '0..*' },
  ],
};

/**
 * T07 es obligatorio y contiene deliberadamente todo lo que puede salir mal.
 * Ejercita de una sola vez normalizacion, las tres listas de reservadas,
 * inferencia de clave, colisiones, derivacion por rol y opcionalidad.
 *
 * A diferencia de los seis anteriores, este modelo **no es valido**: su razon de
 * ser es que el validador encuentre exactamente los hallazgos de su ficha.
 */
const T07: FixtureSpec = {
  id: 'T07',
  title: 'Modelo hostil',
  coverage:
    'Reservada de PostgreSQL, tildes y espacios, reservada de Java, clase sin clave, ' +
    'colision al normalizar, dos relaciones entre el mismo par con roles, 0..1 y unico',
  classes: [
    {
      // Reservada de PostgreSQL: la tabla sera `app_order`, pero la ruta REST
      // sigue siendo `/api/order` (RTM-08).
      name: 'Order',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'fecha', type: 'DateTime', required: true },
        // Reservada de Java: el campo sera `appClass`.
        { name: 'class', type: 'String' },
        { name: 'total', type: 'Decimal', required: true },
      ],
    },
    {
      // Tildes y espacios.
      name: 'Número de Cuenta',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'código', type: 'String', required: true, unique: true },
      ],
    },
    {
      name: 'Cliente',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'nombre', type: 'String', required: true },
      ],
    },
    {
      // Sin clave primaria: el generador emitira `id : UUID` y avisara.
      name: 'Detalle de Venta',
      attributes: [{ name: 'cantidad', type: 'Integer', required: true }],
    },
    {
      // Normaliza al mismo identificador que la clase anterior: es error.
      name: 'detalle venta',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'nota', type: 'String' },
      ],
    },
  ],
  relationships: [
    // Dos relaciones entre el mismo par con roles distintos: producen dos campos
    // distintos en `Order` y ambas deben compilar (CA-015.1).
    {
      from: 'Cliente',
      fromMultiplicity: '1',
      fromRole: 'facturacion',
      to: 'Order',
      toMultiplicity: '0..*',
    },
    {
      from: 'Cliente',
      fromMultiplicity: '1',
      fromRole: 'envio',
      to: 'Order',
      toMultiplicity: '0..*',
    },
    // Multiplicidad 0..1.
    { from: 'Cliente', fromMultiplicity: '1', to: 'Número de Cuenta', toMultiplicity: '0..1' },
    { from: 'Order', fromMultiplicity: '1', to: 'Detalle de Venta', toMultiplicity: '0..*' },
  ],
};

/**
 * T07 con la colision resuelta.
 *
 * T07 no llega al generador por construccion: tiene un error, y un modelo con
 * error no se genera. Pero todo lo demas que contiene —la reservada de
 * PostgreSQL, la de Java, las tildes, la clase sin clave, los dos roles, el
 * `0..1` y el atributo unico— es justo lo que hay que ver compilar de verdad.
 *
 * Se deriva de T07 renombrando la clase que colisiona. Derivarlo y no copiarlo
 * garantiza que las dos versiones no se separen: cualquier cosa que se anada a
 * T07 aparece tambien aqui.
 */
const T07R: FixtureSpec = {
  ...T07,
  id: 'T07R',
  title: 'Modelo hostil resuelto',
  coverage: T07.coverage + ', con la colision resuelta para que llegue al generador',
  classes: T07.classes.map((clase) =>
    clase.name === 'detalle venta' ? { ...clase, name: 'nota de venta' } : clase,
  ),
};

/**
 * T08 existe porque la herencia no se parece a nada mas del banco.
 *
 * Los siete modelos anteriores solo tienen claves foraneas, y una clave foranea
 * se prueba a si misma: si el campo esta, funciona. La generalizacion se
 * proyecta a tabla por clase unida por la clave primaria, y ahi hay cuatro
 * cosas que solo fallan ejecutando:
 *
 *   - `Docente` cuelga de `Empleado`, que cuelga de `Persona`. Con dos niveles
 *     no se distingue heredar de la superclase de heredar de la raiz, y la
 *     clave primaria viene de la raiz.
 *   - `Empleado` y `Estudiante` son hermanas: cada una anade sus columnas sin
 *     ver las de la otra.
 *   - `Departamento` apunta a `Empleado`, asi que `Docente` hereda esa clave
 *     foranea y su servicio tiene que inyectar un repositorio que su clase no
 *     menciona.
 *   - `Materia` apunta a `Docente`, que es una hoja de la jerarquia: la clave
 *     foranea referencia la tabla hija, no la de la raiz.
 */
const T08: FixtureSpec = {
  id: 'T08',
  title: 'Institucion con jerarquia',
  coverage:
    'Generalizacion en cadena de tres niveles, dos hermanas, clave foranea heredada y ' +
    'clave foranea que apunta a una subclase',
  classes: [
    {
      name: 'Persona',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'nombre', type: 'String', required: true },
        { name: 'correo', type: 'String' },
      ],
    },
    {
      // Sin clave propia: la hereda de Persona, y por eso no produce el aviso
      // PRIMARY_KEY_GENERATED que produciria una clase suelta sin clave.
      name: 'Empleado',
      attributes: [
        { name: 'fecha de ingreso', type: 'Date', required: true },
        { name: 'salario', type: 'Decimal', required: true },
      ],
    },
    {
      name: 'Docente',
      attributes: [{ name: 'escalafon', type: 'String' }],
    },
    {
      name: 'Estudiante',
      attributes: [{ name: 'matricula', type: 'String', required: true, unique: true }],
    },
    {
      name: 'Departamento',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'nombre', type: 'String', required: true },
      ],
    },
    {
      name: 'Materia',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'nombre', type: 'String', required: true },
        { name: 'creditos', type: 'Integer', required: true },
      ],
    },
    {
      name: 'Inscripcion',
      attributes: [
        { name: 'id', type: 'UUID', primaryKey: true },
        { name: 'fecha', type: 'Date', required: true },
        { name: 'nota', type: 'Decimal' },
      ],
    },
  ],
  relationships: [
    // El origen es la subclase y el destino la superclase. Las multiplicidades
    // no significan nada en una generalizacion; se declaran por uniformidad.
    {
      kind: 'GENERALIZATION',
      from: 'Empleado',
      fromMultiplicity: '1',
      to: 'Persona',
      toMultiplicity: '1',
    },
    {
      kind: 'GENERALIZATION',
      from: 'Docente',
      fromMultiplicity: '1',
      to: 'Empleado',
      toMultiplicity: '1',
    },
    {
      kind: 'GENERALIZATION',
      from: 'Estudiante',
      fromMultiplicity: '1',
      to: 'Persona',
      toMultiplicity: '1',
    },
    // La clave foranea la recibe Empleado, y Docente la hereda.
    { from: 'Departamento', fromMultiplicity: '1', to: 'Empleado', toMultiplicity: '0..*' },
    // Y esta apunta a una subclase.
    { from: 'Docente', fromMultiplicity: '1', to: 'Materia', toMultiplicity: '0..*' },
    { from: 'Estudiante', fromMultiplicity: '1', to: 'Inscripcion', toMultiplicity: '0..*' },
    { from: 'Materia', fromMultiplicity: '1', to: 'Inscripcion', toMultiplicity: '0..*' },
  ],
};

export const FIXTURE_SPECS: readonly FixtureSpec[] = [T01, T02, T03, T04, T05, T06, T07, T07R, T08];

/** Los que el validador debe aceptar sin un solo error. */
export const VALID_FIXTURE_IDS = ['T01', 'T02', 'T03', 'T04', 'T05', 'T06', 'T07R', 'T08'] as const;

/**
 * Los que pasan por el generador (RNF-13).
 *
 * T07 queda fuera a proposito: su razon de ser es que el validador lo rechace.
 */
export const GENERABLE_FIXTURE_IDS = VALID_FIXTURE_IDS;
```

---

### `fixtures/src/emit.ts`

```ts
/**
 * Emite el banco de regresion a `fixtures/uml/*.json`.
 *
 * Los JSON son derivados, no fuente: se editan las definiciones y se vuelve a
 * emitir. Una prueba comprueba que lo versionado coincide con lo que produce
 * este script, para que nadie edite el JSON a mano y el banco pruebe una cosa
 * distinta de la que dice probar.
 */
import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { FIXTURES, fixtureFileName } from './index.js';
import { serializeFixture } from './serialize.js';

const aqui = dirname(fileURLToPath(import.meta.url));
const destino = join(aqui, '..', 'uml');

mkdirSync(destino, { recursive: true });

for (const item of FIXTURES) {
  const ruta = join(destino, fixtureFileName(item.id));
  writeFileSync(ruta, serializeFixture(item), 'utf8');
  console.warn(`emitido ${item.id} → ${ruta}`);
}
```

---

### `fixtures/src/index.ts`

```ts
/**
 * @uml/fixtures
 *
 * Banco de regresion T01-T07 (plan maestro 15.2), disponible como datos en
 * memoria. No lee del sistema de archivos: las pruebas del nucleo de dominio lo
 * importan sin romper RNF-15.
 *
 * Los archivos JSON de `fixtures/uml/` se emiten desde estos mismos datos con
 * `npm run fixtures:emit` y sirven para inspeccion humana y como entrada del
 * generador. Una prueba comprueba que no se hayan desincronizado.
 */
import { buildFixture, type Fixture } from './build.js';
import { FIXTURE_SPECS } from './definitions.js';

export * from './build.js';
export { buildLoadModel, type LoadModelOptions } from './load.js';
export { serializeFixture } from './serialize.js';
export { FIXTURE_SPECS, VALID_FIXTURE_IDS, GENERABLE_FIXTURE_IDS } from './definitions.js';

export const FIXTURES: readonly Fixture[] = FIXTURE_SPECS.map(buildFixture);

const porId = new Map(FIXTURES.map((fixture) => [fixture.id, fixture]));

export function fixture(id: string): Fixture {
  const encontrado = porId.get(id);
  if (encontrado === undefined) {
    throw new Error(
      `No existe el modelo ${id} en el banco. Disponibles: ${[...porId.keys()].join(', ')}`,
    );
  }
  return encontrado;
}

/** Nombre del archivo JSON emitido para un modelo del banco. */
export function fixtureFileName(fixtureId: string): string {
  return `${fixtureId}.json`;
}
```

---

### `fixtures/src/load.ts`

```ts
import type { SemanticModel } from '@uml/contracts';

/**
 * Modelo sintetico del tamano que exige RNF-03.
 *
 * El banco T01-T07 existe para comprobar que el generador traduce **bien**: cada
 * modelo aisla una regla —clave compuesta, nombre reservado, muchos a muchos— y
 * por eso son pequenos, de tres a cinco clases. Ninguno se acerca a las treinta
 * clases, cien atributos y cuarenta relaciones que RNF-03 exige soportar con
 * fluidez, asi que el tamano nunca se habia probado.
 *
 * Este generador no sustituye al banco: no comprueba que la traduccion sea
 * correcta, solo que a ese tamano nada se cae ni tarda de mas.
 *
 * Solo produce el modelo **semantico**. Las posiciones viven en la capa de
 * disposicion, no aqui: el modelo canonico no sabe donde esta dibujada cada
 * clase, y quien necesite colocarlas las calcula.
 */
export interface LoadModelOptions {
  readonly classes?: number;
  readonly attributes?: number;
  readonly relationships?: number;
  /**
   * Semilla de los identificadores.
   *
   * Deterministas a proposito: un UUID aleatorio haria que la prueba generara
   * un modelo distinto en cada ejecucion, y un fallo intermitente seria
   * imposible de reproducir.
   */
  readonly seed?: string;
}

const TIPOS = ['String', 'Integer', 'Long', 'Decimal', 'Boolean', 'Date'] as const;

export function buildLoadModel(options: LoadModelOptions = {}): SemanticModel {
  const totalClases = options.classes ?? 30;
  const totalAtributos = options.attributes ?? 100;
  const totalRelaciones = options.relationships ?? 40;
  const seed = options.seed ?? 'carga';

  if (totalRelaciones > totalClases * (totalClases - 1)) {
    throw new Error('No caben tantas relaciones sin repetir el par de clases.');
  }

  const classes = Array.from({ length: totalClases }, (_, i) => ({
    id: idDeterminista(`${seed}:clase:${i}`),
    displayName: `Entidad ${i + 1}`,
    codeName: `Entidad${i + 1}`,
    databaseName: `entidad${i + 1}`,
    attributes: [] as SemanticModel['classes'][number]['attributes'][number][],
  }));

  // Los atributos se reparten entre las clases hasta llegar al total pedido: es
  // mas parecido a un diagrama real que cargar todos en una sola clase.
  for (let n = 0; n < totalAtributos; n += 1) {
    const clase = classes[n % totalClases];
    if (clase === undefined) continue;

    const indice = Math.floor(n / totalClases) + 1;
    clase.attributes.push({
      id: idDeterminista(`${seed}:attr:${n}`),
      displayName: `campo ${indice}`,
      codeName: `campo${indice}`,
      databaseName: `campo${indice}`,
      type: TIPOS[n % TIPOS.length] as (typeof TIPOS)[number],
      primaryKey: false,
      nullable: true,
      unique: false,
    });
  }

  // Uno a muchos entre clases distintas. El desplazamiento crece cada vuelta
  // para no repetir el mismo par, que seria un error del modelo y no carga.
  const relationships = Array.from({ length: totalRelaciones }, (_, i) => {
    const origen = i % totalClases;
    const salto = 1 + Math.floor(i / totalClases);
    return {
      id: idDeterminista(`${seed}:rel:${i}`),
      sourceClassId: classes[origen]?.id as string,
      targetClassId: classes[(origen + salto) % totalClases]?.id as string,
      sourceMultiplicity: '1' as const,
      targetMultiplicity: '0..*' as const,
    };
  });

  return { classes, relationships } as SemanticModel;
}

/**
 * Identificador con forma de UUID derivado del texto, sin dependencias.
 *
 * No necesita ser criptografico: solo estable entre ejecuciones y con la forma
 * que exige el esquema.
 */
function idDeterminista(texto: string): string {
  let h1 = 0x811c9dc5;
  let h2 = 0x01000193;

  for (let i = 0; i < texto.length; i += 1) {
    const c = texto.charCodeAt(i);
    h1 = Math.imul(h1 ^ c, 0x01000193) >>> 0;
    h2 = Math.imul(h2 + c, 0x85ebca6b) >>> 0;
  }

  // `>>> 0` en cada paso: en JavaScript `^` devuelve un entero **con signo**, y
  // sin esto `toString(16)` mete un guion delante que invalida el UUID. La
  // primera version lo tenia y el esquema lo rechazo entero.
  const palabras = [h1, h2, (h1 ^ h2) >>> 0, Math.imul(h1, h2) >>> 0];
  const hex = palabras.map((valor) => valor.toString(16).padStart(8, '0')).join('');

  return [
    hex.slice(0, 8),
    hex.slice(8, 12),
    `4${hex.slice(13, 16)}`,
    `8${hex.slice(17, 20)}`,
    hex.slice(20, 32),
  ].join('-');
}
```

---

### `fixtures/src/report.ts`

```ts
/**
 * Informe del banco de regresion: que encuentra el validador en cada modelo.
 *
 * No es una prueba, es una herramienta de diagnostico. Sirve para ver de un
 * vistazo el efecto de un cambio en el normalizador o en el validador sobre los
 * siete modelos, antes de mirar que prueba fallo y por que.
 *
 *   npm run bank:report
 */
import { validateModel } from '@uml/domain-core';
import { FIXTURES } from './index.js';

let totalErrores = 0;

for (const item of FIXTURES) {
  const hallazgos = validateModel(item.model);
  const errores = hallazgos.filter((h) => h.severity === 'ERROR');
  totalErrores += errores.length;

  console.warn(
    `\n${item.id} — ${item.title}` +
      `\n   ${item.model.classes.length} clases · ${item.model.relationships.length} relaciones` +
      ` · ${errores.length} error(es) · ${hallazgos.length - errores.length} aviso(s)`,
  );

  for (const hallazgo of hallazgos) {
    const marca = hallazgo.severity === 'ERROR' ? 'x' : '!';
    console.warn(`   ${marca} ${hallazgo.code}: ${hallazgo.message}`);
  }
}

console.warn(`\nTotal de errores en el banco: ${totalErrores} (se espera 1, el de T07)\n`);
```

---

### `fixtures/src/serialize.ts`

```ts
import { SCHEMA_VERSION } from '@uml/contracts';
import type { Fixture } from './build.js';

/**
 * Serializacion canonica de un modelo del banco.
 *
 * Una sola funcion produce el texto, y tanto el emisor como la prueba de
 * sincronia la usan. Si el formato cambia, las dos cambian a la vez.
 */
export function serializeFixture(item: Fixture): string {
  return (
    JSON.stringify(
      {
        $schema: 'https://plataforma-uml.local/schemas/board-state.json',
        schemaVersion: SCHEMA_VERSION,
        id: item.id,
        title: item.title,
        coverage: item.coverage,
        semantic: item.model,
        layout: item.boardState.layout,
      },
      null,
      2,
    ) + '\n'
  );
}
```

---

## Diagramas T01 a T08

Cada archivo es un modelo canonico completo en JSON.

### Estructura

```text
fixtures/uml/
|-- README.md
|-- T01.json
|-- T02.json
|-- T03.json
|-- T04.json
|-- T05.json
|-- T06.json
|-- T07.json
|-- T07R.json
`-- T08.json
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `fixtures/uml/README.md` | 108 |
| `fixtures/uml/T01.json` | 238 |
| `fixtures/uml/T02.json` | 208 |
| `fixtures/uml/T03.json` | 228 |
| `fixtures/uml/T04.json` | 218 |
| `fixtures/uml/T05.json` | 179 |
| `fixtures/uml/T06.json` | 179 |
| `fixtures/uml/T07.json` | 219 |
| `fixtures/uml/T07R.json` | 219 |
| `fixtures/uml/T08.json` | 305 |

---

### `fixtures/uml/README.md`

````markdown
# Banco de regresión T01–T08

Los ocho modelos de la sección 15.2 del plan maestro.

## Los JSON de este directorio son derivados

**No se editan a mano.** La fuente son las definiciones en
[`../src/definitions.ts`](../src/definitions.ts), donde los modelos se declaran
con nombres visuales y los nombres técnicos los deriva el normalizador real.

```bash
npm run fixtures:emit    # regenerar los JSON
npm run bank:report      # ver qué encuentra el validador en cada modelo
```

Una prueba comprueba que lo versionado coincide con lo que producen las
definiciones. Si falla, alguien editó el JSON a mano o cambió las definiciones
sin volver a emitir.

Escribir los nombres técnicos a mano garantizaría que en algún momento el banco
pruebe una normalización distinta de la que la plataforma aplica de verdad.

## Cobertura

| ID | Modelo | Qué ejercita |
|---|---|---|
| T01 | Cliente · Producto · Venta · DetalleVenta | 1:N, N:1, decimales, fechas, entidad intermedia |
| T02 | Proveedor · Compra · DetalleCompra · Producto | Mismo patrón, otra terminología |
| T03 | Cliente · Barbero · Servicio · Atencion | Caso de la aplicación móvil |
| T04 | Activo · Categoria · Responsable · Asignacion | Varias claves foráneas sobre una entidad |
| T05 | Cliente · Cuenta · Movimiento | Cadena de tres niveles |
| T06 | Alumno · Materia · Inscripcion | Muchos a muchos con atributos |
| T07 | Modelo hostil | Ver abajo |
| T07R | Modelo hostil resuelto | Lo mismo que T07, con la colisión arreglada, para que llegue al generador |
| T08 | Persona · Empleado · Docente · Estudiante · Departamento · Materia · Inscripcion | Generalización: ver abajo |

## T01 a T06 son válidos

El validador no encuentra **ningún error** en ellos. Avisos sí: nombres que se
normalizan, sobre todo. Los avisos permiten generar.

## T07 no es válido, y esa es su razón de ser

Contiene deliberadamente:

| Construcción | Qué ejercita | Resultado esperado |
|---|---|---|
| Clase `Order` | Reservada de PostgreSQL | Tabla `app_order`, ruta `/api/order` |
| Clase `Número de Cuenta` | Tildes y espacios | `NumeroCuenta` / `numero_cuenta` |
| Atributo `class` | Reservada de Java | Campo `appClass`, columna `class` |
| Clase `Detalle de Venta` sin clave | Inferencia RTM-04 rama 4 | Aviso: se generará `id : UUID` |
| `Detalle de Venta` + `detalle venta` | Colisión al normalizar | **Error** `DUPLICATE_CLASS_NAME` |
| Dos relaciones `Cliente`↔`Order` con roles | Derivación por rol (CA-015.1) | Dos campos distintos, sin error |
| Multiplicidad `0..1` | Opcionalidad RTM-06 | — |
| Atributo `código` único | Restricción de unicidad | — |

**Un solo error, el de la colisión.** Todo lo demás son avisos. Que `Order` y
`class` produzcan aviso y no error es el punto: la herramienta los resuelve y
sigue adelante en lugar de bloquear al usuario.

## T07R existe porque T07 no puede generarse

Un modelo con error no llega al generador por construcción. Pero todo lo demás
que contiene T07 —la reservada de PostgreSQL, la de Java, las tildes, la clase
sin clave, los dos roles, el `0..1` y el atributo único— es justo lo que hay que
**ver compilar de verdad**.

`T07R` se deriva de `T07` renombrando la clase que colisiona. Derivarlo y no
copiarlo garantiza que las dos versiones no se separen: cualquier cosa que se
añada a T07 aparece también en T07R.

## T08 es el único modelo con herencia

Los siete anteriores solo tienen claves foráneas, y una clave foránea se prueba
sola: si el campo está, funciona. La generalización se proyecta a tabla por
clase unida por la clave primaria (RTM-13), y eso falla de formas que compilan.

| Construcción | Qué ejercita |
|---|---|
| `Docente ▷ Empleado ▷ Persona` | Tres niveles. Con dos no se distingue heredar de la superclase de heredar de la raíz, y la clave primaria sale de la raíz |
| `Empleado` y `Estudiante` bajo `Persona` | Dos hermanas: cada una añade sus columnas sin ver las de la otra |
| `Departamento 1 ── N Empleado` | `Docente` hereda esa clave foránea, y su servicio inyecta un repositorio que su clase no menciona |
| `Docente 1 ── N Materia` | Una clave foránea que apunta a una hoja de la jerarquía, no a la raíz |
| Tres subclases sin clave propia | Aviso `PRIMARY_KEY_INHERITED`, no el `PRIMARY_KEY_GENERATED` de una clase suelta |

`GENERABLE_FIXTURE_IDS` es la lista que recorre el banco de generación: T01–T06,
T07R y T08. T07 queda fuera a propósito.

## Cómo se ejecuta el banco

```bash
npm run bank:report    # qué encuentra el validador en cada modelo (rápido)
npm run test:generated # solo T01 por la DoD 15.1 completa
npm run test:bank      # los ocho generables por la DoD 15.1 completa
```

`test:bank` compila y arranca ocho backends: son minutos. RNF-13 lo resuelve
así — cada cambio ejecuta al menos T01, la rama principal ejecuta el banco
completo.

## Por qué el escape es por nombre y no por elemento

`Order` recibe `app_order` en la tabla pero conserva `Order` como nombre de
código. Es deliberado: RTM-08 deriva la ruta REST del nombre de código
precisamente para que el prefijo no se filtre a las URL. Lo mismo al revés con
`class`, que se escapa en el código Java pero no en la columna, porque `class`
no es reservada en PostgreSQL.
````

---

### `fixtures/uml/T01.json`

```json
{
  "$schema": "https://plataforma-uml.local/schemas/board-state.json",
  "schemaVersion": "1.0.0",
  "id": "T01",
  "title": "Ventas",
  "coverage": "1:N, N:1, decimales, fechas y entidad intermedia",
  "semantic": {
    "classes": [
      {
        "id": "cfea03b5-a2b2-57c3-a3e8-3e9d3aa76746",
        "displayName": "Cliente",
        "codeName": "Cliente",
        "databaseName": "cliente",
        "attributes": [
          {
            "id": "dd3f37fe-5bf4-5e20-918d-682474499c8c",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "e12a4723-6c54-5605-b1c1-8d306c18cf9f",
            "displayName": "nombre",
            "codeName": "nombre",
            "databaseName": "nombre",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "903d0c77-2ffc-56e7-960a-9326b6c7fcbf",
            "displayName": "correo",
            "codeName": "correo",
            "databaseName": "correo",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": true
          },
          {
            "id": "9819d080-4955-58ff-b9f4-0051f69561bc",
            "displayName": "telefono",
            "codeName": "telefono",
            "databaseName": "telefono",
            "type": "String",
            "primaryKey": false,
            "nullable": true,
            "unique": false
          }
        ]
      },
      {
        "id": "d1dedaa1-f1f9-50ba-a6e7-ff00c36d607d",
        "displayName": "Producto",
        "codeName": "Producto",
        "databaseName": "producto",
        "attributes": [
          {
            "id": "0877c54c-5ac5-54a6-bdd1-fcff9c20abdd",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "2c3ea260-7f1e-52cb-b1f0-ea83e36e7361",
            "displayName": "nombre",
            "codeName": "nombre",
            "databaseName": "nombre",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "e2d1bd85-624a-50cf-9c4a-71192d837834",
            "displayName": "precio",
            "codeName": "precio",
            "databaseName": "precio",
            "type": "Decimal",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "12fa5f64-1c04-53f8-8cc9-399c087a0b04",
            "displayName": "stock",
            "codeName": "stock",
            "databaseName": "stock",
            "type": "Integer",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          }
        ]
      },
      {
        "id": "e88413a1-cf69-53e0-ba20-33202006bcc2",
        "displayName": "Venta",
        "codeName": "Venta",
        "databaseName": "venta",
        "attributes": [
          {
            "id": "8de1854d-b713-53c7-b583-f10db693608d",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "a4e72a5b-2bed-52fc-b063-4c9749a37f7d",
            "displayName": "fecha",
            "codeName": "fecha",
            "databaseName": "fecha",
            "type": "DateTime",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "c34e2902-5b5c-5655-951d-f355d1787dff",
            "displayName": "total",
            "codeName": "total",
            "databaseName": "total",
            "type": "Decimal",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          }
        ]
      },
      {
        "id": "b5285758-b514-5b15-a367-5c8a9f8bb8d1",
        "displayName": "Detalle de Venta",
        "codeName": "DetalleVenta",
        "databaseName": "detalle_venta",
        "attributes": [
          {
            "id": "11eb30bd-38fc-51aa-9b69-5025eaa80024",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "d84cf393-6c0c-5eb7-bd54-95aa3c635c00",
            "displayName": "cantidad",
            "codeName": "cantidad",
            "databaseName": "cantidad",
            "type": "Integer",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "75d1b170-7ad3-5519-979c-42c0178bc6eb",
            "displayName": "precio unitario",
            "codeName": "precioUnitario",
            "databaseName": "precio_unitario",
            "type": "Decimal",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "2a5faf3a-6f86-54f8-ab13-e3712c2f4162",
            "displayName": "subtotal",
            "codeName": "subtotal",
            "databaseName": "subtotal",
            "type": "Decimal",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          }
        ]
      }
    ],
    "relationships": [
      {
        "id": "8ab80e2a-a546-5f5e-b80a-4c71152475f3",
        "sourceClassId": "cfea03b5-a2b2-57c3-a3e8-3e9d3aa76746",
        "targetClassId": "e88413a1-cf69-53e0-ba20-33202006bcc2",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*"
      },
      {
        "id": "5970001a-dc11-5095-9194-207c84e3fabb",
        "sourceClassId": "e88413a1-cf69-53e0-ba20-33202006bcc2",
        "targetClassId": "b5285758-b514-5b15-a367-5c8a9f8bb8d1",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*"
      },
      {
        "id": "81d584b7-7b80-588b-a818-52efeb9fae24",
        "sourceClassId": "d1dedaa1-f1f9-50ba-a6e7-ff00c36d607d",
        "targetClassId": "b5285758-b514-5b15-a367-5c8a9f8bb8d1",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*"
      }
    ]
  },
  "layout": {
    "positions": {
      "cfea03b5-a2b2-57c3-a3e8-3e9d3aa76746": {
        "x": 0,
        "y": 0
      },
      "d1dedaa1-f1f9-50ba-a6e7-ff00c36d607d": {
        "x": 320,
        "y": 0
      },
      "e88413a1-cf69-53e0-ba20-33202006bcc2": {
        "x": 640,
        "y": 0
      },
      "b5285758-b514-5b15-a367-5c8a9f8bb8d1": {
        "x": 960,
        "y": 0
      }
    },
    "sizes": {}
  }
}
```

---

### `fixtures/uml/T02.json`

```json
{
  "$schema": "https://plataforma-uml.local/schemas/board-state.json",
  "schemaVersion": "1.0.0",
  "id": "T02",
  "title": "Compras",
  "coverage": "Mismo patron que T01 con otra terminologia",
  "semantic": {
    "classes": [
      {
        "id": "b99889fb-3642-55db-97cd-7413386f13d1",
        "displayName": "Proveedor",
        "codeName": "Proveedor",
        "databaseName": "proveedor",
        "attributes": [
          {
            "id": "549d74c9-5b37-5801-a2c0-99f920e439f1",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "80ed2752-2bf3-505d-89e7-b32328ed1fb7",
            "displayName": "razon social",
            "codeName": "razonSocial",
            "databaseName": "razon_social",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "d283cacf-4a0d-5169-8e40-054984f08ac3",
            "displayName": "nit",
            "codeName": "nit",
            "databaseName": "nit",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": true
          }
        ]
      },
      {
        "id": "b4d90835-cb9b-57e9-8c27-504b549a81b9",
        "displayName": "Producto",
        "codeName": "Producto",
        "databaseName": "producto",
        "attributes": [
          {
            "id": "6ca19aa6-d75e-5ca4-948b-53df04cc0a6a",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "cff659b5-ef32-5afb-840c-26073f146b10",
            "displayName": "nombre",
            "codeName": "nombre",
            "databaseName": "nombre",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "f70bbdae-d66e-5ef7-a4cf-f2768b45d5cc",
            "displayName": "costo",
            "codeName": "costo",
            "databaseName": "costo",
            "type": "Decimal",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          }
        ]
      },
      {
        "id": "c919211d-65fe-5cfd-ad8e-dd38092f05a8",
        "displayName": "Compra",
        "codeName": "Compra",
        "databaseName": "compra",
        "attributes": [
          {
            "id": "5a71d3c6-e6c1-54b7-82d6-cad623d8580c",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "f70c9332-516b-5532-be93-3f649612535c",
            "displayName": "fecha",
            "codeName": "fecha",
            "databaseName": "fecha",
            "type": "Date",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "ee0ecade-c5ad-577d-aa74-b6835b5541e9",
            "displayName": "total",
            "codeName": "total",
            "databaseName": "total",
            "type": "Decimal",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          }
        ]
      },
      {
        "id": "e07ece6c-49c2-57c1-8626-c11ac6d93efe",
        "displayName": "Detalle de Compra",
        "codeName": "DetalleCompra",
        "databaseName": "detalle_compra",
        "attributes": [
          {
            "id": "e1818098-5f52-509f-aae5-1438ba089f30",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "4fd0e9f1-5fe2-5ab7-af86-8f9f0e680887",
            "displayName": "cantidad",
            "codeName": "cantidad",
            "databaseName": "cantidad",
            "type": "Integer",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "3418b1ef-8f33-585a-b34f-06db6ff7fc4d",
            "displayName": "costo unitario",
            "codeName": "costoUnitario",
            "databaseName": "costo_unitario",
            "type": "Decimal",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          }
        ]
      }
    ],
    "relationships": [
      {
        "id": "caea1f92-4930-5587-a710-1c128fb50792",
        "sourceClassId": "b99889fb-3642-55db-97cd-7413386f13d1",
        "targetClassId": "c919211d-65fe-5cfd-ad8e-dd38092f05a8",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*"
      },
      {
        "id": "879eeff5-98ce-50c1-b9f1-77d8b99158ee",
        "sourceClassId": "c919211d-65fe-5cfd-ad8e-dd38092f05a8",
        "targetClassId": "e07ece6c-49c2-57c1-8626-c11ac6d93efe",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*"
      },
      {
        "id": "a166fd50-152e-5e79-93de-562579ea0c2c",
        "sourceClassId": "b4d90835-cb9b-57e9-8c27-504b549a81b9",
        "targetClassId": "e07ece6c-49c2-57c1-8626-c11ac6d93efe",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*"
      }
    ]
  },
  "layout": {
    "positions": {
      "b99889fb-3642-55db-97cd-7413386f13d1": {
        "x": 0,
        "y": 0
      },
      "b4d90835-cb9b-57e9-8c27-504b549a81b9": {
        "x": 320,
        "y": 0
      },
      "c919211d-65fe-5cfd-ad8e-dd38092f05a8": {
        "x": 640,
        "y": 0
      },
      "e07ece6c-49c2-57c1-8626-c11ac6d93efe": {
        "x": 960,
        "y": 0
      }
    },
    "sizes": {}
  }
}
```

---

### `fixtures/uml/T03.json`

```json
{
  "$schema": "https://plataforma-uml.local/schemas/board-state.json",
  "schemaVersion": "1.0.0",
  "id": "T03",
  "title": "Barberia",
  "coverage": "Caso de la aplicacion movil: varias claves foraneas en la entidad de registro",
  "semantic": {
    "classes": [
      {
        "id": "875b487f-fbb2-58f3-80a8-834ba557fdef",
        "displayName": "Cliente",
        "codeName": "Cliente",
        "databaseName": "cliente",
        "attributes": [
          {
            "id": "3058f4ee-e933-5fdb-88ac-8385295558f0",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "428b8f09-1151-51e4-88d7-51085004a964",
            "displayName": "nombre",
            "codeName": "nombre",
            "databaseName": "nombre",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "1f14b606-a556-5742-8cf3-27a2cff88dd4",
            "displayName": "telefono",
            "codeName": "telefono",
            "databaseName": "telefono",
            "type": "String",
            "primaryKey": false,
            "nullable": true,
            "unique": false
          }
        ]
      },
      {
        "id": "d23717ac-2406-5717-8541-fc074f734075",
        "displayName": "Barbero",
        "codeName": "Barbero",
        "databaseName": "barbero",
        "attributes": [
          {
            "id": "3bb64daf-3e85-5128-a569-bf166038fd8a",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "cb9a7201-1ea8-5117-975f-1d68a41a1cbf",
            "displayName": "nombre",
            "codeName": "nombre",
            "databaseName": "nombre",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "c98bab7a-206a-5771-a1ac-a704746a55d4",
            "displayName": "activo",
            "codeName": "activo",
            "databaseName": "activo",
            "type": "Boolean",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          }
        ]
      },
      {
        "id": "8d046b34-f050-5bcb-aa05-15977688b3c0",
        "displayName": "Servicio",
        "codeName": "Servicio",
        "databaseName": "servicio",
        "attributes": [
          {
            "id": "472436bb-9888-5188-8150-289735ec2f38",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "7bc9f89d-1089-5a1e-947c-1daebb676032",
            "displayName": "nombre",
            "codeName": "nombre",
            "databaseName": "nombre",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "5ab77bb0-5216-5214-b6d3-479fee0415c3",
            "displayName": "precio",
            "codeName": "precio",
            "databaseName": "precio",
            "type": "Decimal",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "3217360a-1a58-56d2-b08a-7723649f1597",
            "displayName": "duracion minutos",
            "codeName": "duracionMinutos",
            "databaseName": "duracion_minutos",
            "type": "Integer",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          }
        ]
      },
      {
        "id": "52b7ccb1-e17c-5ac3-9240-a500e9cd5dbe",
        "displayName": "Atencion",
        "codeName": "Atencion",
        "databaseName": "atencion",
        "attributes": [
          {
            "id": "ba475b51-ec76-5f0c-b575-a2bcd72a91b2",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "c7fad8ea-e760-5c45-8f61-8cfbb5f80281",
            "displayName": "fecha",
            "codeName": "fecha",
            "databaseName": "fecha",
            "type": "DateTime",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "deb85216-3a57-5268-b8c9-25725d335faa",
            "displayName": "monto",
            "codeName": "monto",
            "databaseName": "monto",
            "type": "Decimal",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "505ec32a-54a4-5660-82be-2321d773918b",
            "displayName": "observacion",
            "codeName": "observacion",
            "databaseName": "observacion",
            "type": "String",
            "primaryKey": false,
            "nullable": true,
            "unique": false
          }
        ]
      }
    ],
    "relationships": [
      {
        "id": "82f0088e-4ee9-5793-b9d5-edabd8461d39",
        "sourceClassId": "875b487f-fbb2-58f3-80a8-834ba557fdef",
        "targetClassId": "52b7ccb1-e17c-5ac3-9240-a500e9cd5dbe",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*"
      },
      {
        "id": "23b8acf3-97a4-55f1-84a6-cbe129ed7636",
        "sourceClassId": "d23717ac-2406-5717-8541-fc074f734075",
        "targetClassId": "52b7ccb1-e17c-5ac3-9240-a500e9cd5dbe",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*"
      },
      {
        "id": "886b0609-d33f-564a-8535-ef202e2ba90c",
        "sourceClassId": "8d046b34-f050-5bcb-aa05-15977688b3c0",
        "targetClassId": "52b7ccb1-e17c-5ac3-9240-a500e9cd5dbe",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*"
      }
    ]
  },
  "layout": {
    "positions": {
      "875b487f-fbb2-58f3-80a8-834ba557fdef": {
        "x": 0,
        "y": 0
      },
      "d23717ac-2406-5717-8541-fc074f734075": {
        "x": 320,
        "y": 0
      },
      "8d046b34-f050-5bcb-aa05-15977688b3c0": {
        "x": 640,
        "y": 0
      },
      "52b7ccb1-e17c-5ac3-9240-a500e9cd5dbe": {
        "x": 960,
        "y": 0
      }
    },
    "sizes": {}
  }
}
```

---

### `fixtures/uml/T04.json`

```json
{
  "$schema": "https://plataforma-uml.local/schemas/board-state.json",
  "schemaVersion": "1.0.0",
  "id": "T04",
  "title": "Inventario de activos",
  "coverage": "Varias claves foraneas sobre una entidad y una relacion opcional",
  "semantic": {
    "classes": [
      {
        "id": "11300ccd-5687-582a-a712-697e994b86db",
        "displayName": "Categoria",
        "codeName": "Categoria",
        "databaseName": "categoria",
        "attributes": [
          {
            "id": "eec00aca-4575-5ed0-ae97-8dd4d2f674a9",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "2c537302-c703-5a6a-9e25-ec7cddb6b4f0",
            "displayName": "nombre",
            "codeName": "nombre",
            "databaseName": "nombre",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": true
          }
        ]
      },
      {
        "id": "e2e59853-70cc-54ab-8d78-6075d15b4535",
        "displayName": "Responsable",
        "codeName": "Responsable",
        "databaseName": "responsable",
        "attributes": [
          {
            "id": "616572e2-ce53-5c75-bc63-d813cf695aeb",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "db207452-6c56-5a1b-af27-b879a1c9e2d6",
            "displayName": "nombre",
            "codeName": "nombre",
            "databaseName": "nombre",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "807b9fbb-176f-55c9-a411-10f8b272b1bf",
            "displayName": "correo",
            "codeName": "correo",
            "databaseName": "correo",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": true
          }
        ]
      },
      {
        "id": "31469068-5a95-5c6a-a181-c2fed6343073",
        "displayName": "Activo",
        "codeName": "Activo",
        "databaseName": "activo",
        "attributes": [
          {
            "id": "8bc8a8bc-b7b0-5612-9f6d-965625d08dfd",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "39e3a2f3-bb0f-5757-9bab-866641de47cd",
            "displayName": "codigo",
            "codeName": "codigo",
            "databaseName": "codigo",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": true
          },
          {
            "id": "a7f8f493-37c4-5390-a550-cfe4c80ea5d5",
            "displayName": "descripcion",
            "codeName": "descripcion",
            "databaseName": "descripcion",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "eed0e047-10fc-5ae2-bcfd-cc066d0805b5",
            "displayName": "valor",
            "codeName": "valor",
            "databaseName": "valor",
            "type": "Decimal",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "db89e420-b497-598a-bb30-36a34b270dc1",
            "displayName": "fecha alta",
            "codeName": "fechaAlta",
            "databaseName": "fecha_alta",
            "type": "Date",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          }
        ]
      },
      {
        "id": "1dafe79a-7f2b-538f-a97f-7bb7a65f58cb",
        "displayName": "Asignacion",
        "codeName": "Asignacion",
        "databaseName": "asignacion",
        "attributes": [
          {
            "id": "044e4a6d-6154-51b5-af42-fa74703248ab",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "d90ffa21-f9e4-5260-878e-06ab20370423",
            "displayName": "fecha inicio",
            "codeName": "fechaInicio",
            "databaseName": "fecha_inicio",
            "type": "Date",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "f79caa8b-4d0d-56de-82fa-ebfcbf90c4f4",
            "displayName": "fecha fin",
            "codeName": "fechaFin",
            "databaseName": "fecha_fin",
            "type": "Date",
            "primaryKey": false,
            "nullable": true,
            "unique": false
          }
        ]
      }
    ],
    "relationships": [
      {
        "id": "8818023a-21a4-575b-98a8-8951b1c8c1f6",
        "sourceClassId": "11300ccd-5687-582a-a712-697e994b86db",
        "targetClassId": "31469068-5a95-5c6a-a181-c2fed6343073",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*"
      },
      {
        "id": "30950165-8362-50a3-a3f5-0a4fb02b7525",
        "sourceClassId": "31469068-5a95-5c6a-a181-c2fed6343073",
        "targetClassId": "1dafe79a-7f2b-538f-a97f-7bb7a65f58cb",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*"
      },
      {
        "id": "b823bfb9-dca6-59e4-b594-5bd2ffe779ba",
        "sourceClassId": "e2e59853-70cc-54ab-8d78-6075d15b4535",
        "targetClassId": "1dafe79a-7f2b-538f-a97f-7bb7a65f58cb",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*"
      }
    ]
  },
  "layout": {
    "positions": {
      "11300ccd-5687-582a-a712-697e994b86db": {
        "x": 0,
        "y": 0
      },
      "e2e59853-70cc-54ab-8d78-6075d15b4535": {
        "x": 320,
        "y": 0
      },
      "31469068-5a95-5c6a-a181-c2fed6343073": {
        "x": 640,
        "y": 0
      },
      "1dafe79a-7f2b-538f-a97f-7bb7a65f58cb": {
        "x": 960,
        "y": 0
      }
    },
    "sizes": {}
  }
}
```

---

### `fixtures/uml/T05.json`

```json
{
  "$schema": "https://plataforma-uml.local/schemas/board-state.json",
  "schemaVersion": "1.0.0",
  "id": "T05",
  "title": "Cuentas y movimientos",
  "coverage": "Cadena de tres niveles de dependencia",
  "semantic": {
    "classes": [
      {
        "id": "5f3abb2a-4768-5ff3-b461-17c224221fea",
        "displayName": "Cliente",
        "codeName": "Cliente",
        "databaseName": "cliente",
        "attributes": [
          {
            "id": "b325efaa-7f31-5585-92da-02487af44279",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "504f9fa5-2a44-58c2-8441-f181e439f391",
            "displayName": "nombre",
            "codeName": "nombre",
            "databaseName": "nombre",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "04a67a87-f9b4-53a4-af44-f39f142dad19",
            "displayName": "documento",
            "codeName": "documento",
            "databaseName": "documento",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": true
          }
        ]
      },
      {
        "id": "3ebc4d4f-3b0b-5ae1-ad52-4abda6a5e615",
        "displayName": "Cuenta",
        "codeName": "Cuenta",
        "databaseName": "cuenta",
        "attributes": [
          {
            "id": "69674cb3-994f-5acb-85fa-5ccd6b129211",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "312fd2cc-cb3e-5daf-9905-ef0493a9de6e",
            "displayName": "numero",
            "codeName": "numero",
            "databaseName": "numero",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": true
          },
          {
            "id": "c44af2dd-b192-5a01-87f7-3f26e00720c1",
            "displayName": "saldo",
            "codeName": "saldo",
            "databaseName": "saldo",
            "type": "Decimal",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "0aa261cc-5a5d-53fc-9684-92641a9513b7",
            "displayName": "activa",
            "codeName": "activa",
            "databaseName": "activa",
            "type": "Boolean",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          }
        ]
      },
      {
        "id": "f9593929-ba67-5942-8504-fca9dba7ea06",
        "displayName": "Movimiento",
        "codeName": "Movimiento",
        "databaseName": "movimiento",
        "attributes": [
          {
            "id": "94891911-a129-5825-bf2a-ff2fc74ba59c",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "8d824f4c-c2ec-513f-a611-7c4bca044ee2",
            "displayName": "fecha",
            "codeName": "fecha",
            "databaseName": "fecha",
            "type": "DateTime",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "3c09aeae-f861-5e9e-b85f-a802f739b422",
            "displayName": "monto",
            "codeName": "monto",
            "databaseName": "monto",
            "type": "Decimal",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "057ee3f7-94d0-519c-9575-236ef57fbb10",
            "displayName": "concepto",
            "codeName": "concepto",
            "databaseName": "concepto",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          }
        ]
      }
    ],
    "relationships": [
      {
        "id": "133f8e29-852c-5923-9978-48c9344d3c0d",
        "sourceClassId": "5f3abb2a-4768-5ff3-b461-17c224221fea",
        "targetClassId": "3ebc4d4f-3b0b-5ae1-ad52-4abda6a5e615",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*"
      },
      {
        "id": "b062bca1-e5fc-5490-9934-33e8a533b259",
        "sourceClassId": "3ebc4d4f-3b0b-5ae1-ad52-4abda6a5e615",
        "targetClassId": "f9593929-ba67-5942-8504-fca9dba7ea06",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*"
      }
    ]
  },
  "layout": {
    "positions": {
      "5f3abb2a-4768-5ff3-b461-17c224221fea": {
        "x": 0,
        "y": 0
      },
      "3ebc4d4f-3b0b-5ae1-ad52-4abda6a5e615": {
        "x": 320,
        "y": 0
      },
      "f9593929-ba67-5942-8504-fca9dba7ea06": {
        "x": 640,
        "y": 0
      }
    },
    "sizes": {}
  }
}
```

---

### `fixtures/uml/T06.json`

```json
{
  "$schema": "https://plataforma-uml.local/schemas/board-state.json",
  "schemaVersion": "1.0.0",
  "id": "T06",
  "title": "Inscripciones",
  "coverage": "Muchos a muchos con atributos, resuelto con entidad intermedia (RM-01)",
  "semantic": {
    "classes": [
      {
        "id": "69f11a2a-3285-5af2-8414-feef53c4be80",
        "displayName": "Alumno",
        "codeName": "Alumno",
        "databaseName": "alumno",
        "attributes": [
          {
            "id": "0a7a22a8-db7e-5a0b-93aa-f6dea52f357e",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "3b94fd3a-c6b0-5c87-9c73-bb37bc38db61",
            "displayName": "nombre",
            "codeName": "nombre",
            "databaseName": "nombre",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "7f0d81f8-e8bc-5efc-b982-164775d3647c",
            "displayName": "registro",
            "codeName": "registro",
            "databaseName": "registro",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": true
          }
        ]
      },
      {
        "id": "2f52aed7-9a27-5ca0-8dc0-81a96d3185a1",
        "displayName": "Materia",
        "codeName": "Materia",
        "databaseName": "materia",
        "attributes": [
          {
            "id": "eb3ffca8-0b45-58cf-af9f-a1362dcccbad",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "001e1dfc-2e0c-5ba4-b174-2b7acb8b1e82",
            "displayName": "nombre",
            "codeName": "nombre",
            "databaseName": "nombre",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "9d83eb5d-719f-5e9e-a9a0-63e396a1a778",
            "displayName": "sigla",
            "codeName": "sigla",
            "databaseName": "sigla",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": true
          },
          {
            "id": "d811634e-74f9-58a7-af8c-b2b6bcf8c403",
            "displayName": "creditos",
            "codeName": "creditos",
            "databaseName": "creditos",
            "type": "Integer",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          }
        ]
      },
      {
        "id": "48f30e54-1b79-51c6-82d5-ffdf8563bf8c",
        "displayName": "Inscripcion",
        "codeName": "Inscripcion",
        "databaseName": "inscripcion",
        "attributes": [
          {
            "id": "2daf863c-1c08-5cc5-bbe9-fac531676d82",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "83d5f4ee-817b-55fc-b338-0b27957ea241",
            "displayName": "gestion",
            "codeName": "gestion",
            "databaseName": "gestion",
            "type": "Integer",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "f24e37b4-c620-5de0-ac97-6dde680c8cfd",
            "displayName": "nota",
            "codeName": "nota",
            "databaseName": "nota",
            "type": "Decimal",
            "primaryKey": false,
            "nullable": true,
            "unique": false
          },
          {
            "id": "73896890-d093-53a9-a43a-d6a6c5c6d351",
            "displayName": "fecha",
            "codeName": "fecha",
            "databaseName": "fecha",
            "type": "Date",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          }
        ]
      }
    ],
    "relationships": [
      {
        "id": "04755607-1fae-54f7-ac92-083e069cf5a6",
        "sourceClassId": "69f11a2a-3285-5af2-8414-feef53c4be80",
        "targetClassId": "48f30e54-1b79-51c6-82d5-ffdf8563bf8c",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*"
      },
      {
        "id": "913d512d-e004-5056-aed2-9995c0fd5454",
        "sourceClassId": "2f52aed7-9a27-5ca0-8dc0-81a96d3185a1",
        "targetClassId": "48f30e54-1b79-51c6-82d5-ffdf8563bf8c",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*"
      }
    ]
  },
  "layout": {
    "positions": {
      "69f11a2a-3285-5af2-8414-feef53c4be80": {
        "x": 0,
        "y": 0
      },
      "2f52aed7-9a27-5ca0-8dc0-81a96d3185a1": {
        "x": 320,
        "y": 0
      },
      "48f30e54-1b79-51c6-82d5-ffdf8563bf8c": {
        "x": 640,
        "y": 0
      }
    },
    "sizes": {}
  }
}
```

---

### `fixtures/uml/T07.json`

```json
{
  "$schema": "https://plataforma-uml.local/schemas/board-state.json",
  "schemaVersion": "1.0.0",
  "id": "T07",
  "title": "Modelo hostil",
  "coverage": "Reservada de PostgreSQL, tildes y espacios, reservada de Java, clase sin clave, colision al normalizar, dos relaciones entre el mismo par con roles, 0..1 y unico",
  "semantic": {
    "classes": [
      {
        "id": "26eefe47-5b04-56dd-853e-50a26d558917",
        "displayName": "Order",
        "codeName": "Order",
        "databaseName": "app_order",
        "attributes": [
          {
            "id": "30789d7c-5d2e-59a0-8454-6b2315e69d75",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "2c441d40-60bc-5efb-81e6-57acce2f6243",
            "displayName": "fecha",
            "codeName": "fecha",
            "databaseName": "fecha",
            "type": "DateTime",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "bf70dc14-9a66-50c3-8b64-0b23ca52c6bf",
            "displayName": "class",
            "codeName": "appClass",
            "databaseName": "class",
            "type": "String",
            "primaryKey": false,
            "nullable": true,
            "unique": false
          },
          {
            "id": "22223df4-de09-505f-8b3b-1793b856aaf8",
            "displayName": "total",
            "codeName": "total",
            "databaseName": "total",
            "type": "Decimal",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          }
        ]
      },
      {
        "id": "fdb7e841-b6b2-50b5-854f-62d788b1ce4d",
        "displayName": "Número de Cuenta",
        "codeName": "NumeroCuenta",
        "databaseName": "numero_cuenta",
        "attributes": [
          {
            "id": "80a25007-00cb-5573-ba69-c0842ddc02b4",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "1a1040aa-5b83-53a0-9fe4-59d93ab9845c",
            "displayName": "código",
            "codeName": "codigo",
            "databaseName": "codigo",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": true
          }
        ]
      },
      {
        "id": "cbf21ff8-e8ac-54ce-acac-393afe4c21fb",
        "displayName": "Cliente",
        "codeName": "Cliente",
        "databaseName": "cliente",
        "attributes": [
          {
            "id": "78e8beaa-a0a7-5b81-bf7e-845a127e257e",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "66d716d4-7b13-58d1-9048-34a9e348ed24",
            "displayName": "nombre",
            "codeName": "nombre",
            "databaseName": "nombre",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          }
        ]
      },
      {
        "id": "ffdd6910-942a-5351-b4a6-77bcec4f915e",
        "displayName": "Detalle de Venta",
        "codeName": "DetalleVenta",
        "databaseName": "detalle_venta",
        "attributes": [
          {
            "id": "a1ee557f-c153-5492-878b-430112394175",
            "displayName": "cantidad",
            "codeName": "cantidad",
            "databaseName": "cantidad",
            "type": "Integer",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          }
        ]
      },
      {
        "id": "7760470c-33fa-57e9-8bb4-03d0ce66da77",
        "displayName": "detalle venta",
        "codeName": "DetalleVenta",
        "databaseName": "detalle_venta",
        "attributes": [
          {
            "id": "fc4b3ce6-fd77-5c87-9cb0-b931695aecf2",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "8750cbd1-2a40-56c0-9b8b-c31cab64bbd9",
            "displayName": "nota",
            "codeName": "nota",
            "databaseName": "nota",
            "type": "String",
            "primaryKey": false,
            "nullable": true,
            "unique": false
          }
        ]
      }
    ],
    "relationships": [
      {
        "id": "ef05e4dd-23a3-50f6-81f6-92a228ad0776",
        "sourceClassId": "cbf21ff8-e8ac-54ce-acac-393afe4c21fb",
        "targetClassId": "26eefe47-5b04-56dd-853e-50a26d558917",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*",
        "sourceRoleName": "facturacion"
      },
      {
        "id": "a8f8ed74-d437-5bb4-9c05-2a909c4ebcc0",
        "sourceClassId": "cbf21ff8-e8ac-54ce-acac-393afe4c21fb",
        "targetClassId": "26eefe47-5b04-56dd-853e-50a26d558917",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*",
        "sourceRoleName": "envio"
      },
      {
        "id": "8825752b-2a2f-5877-bc99-0727e00f3653",
        "sourceClassId": "cbf21ff8-e8ac-54ce-acac-393afe4c21fb",
        "targetClassId": "fdb7e841-b6b2-50b5-854f-62d788b1ce4d",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..1"
      },
      {
        "id": "4a1dcbc1-1b83-53ee-9b2b-5556446af894",
        "sourceClassId": "26eefe47-5b04-56dd-853e-50a26d558917",
        "targetClassId": "ffdd6910-942a-5351-b4a6-77bcec4f915e",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*"
      }
    ]
  },
  "layout": {
    "positions": {
      "26eefe47-5b04-56dd-853e-50a26d558917": {
        "x": 0,
        "y": 0
      },
      "fdb7e841-b6b2-50b5-854f-62d788b1ce4d": {
        "x": 320,
        "y": 0
      },
      "cbf21ff8-e8ac-54ce-acac-393afe4c21fb": {
        "x": 640,
        "y": 0
      },
      "ffdd6910-942a-5351-b4a6-77bcec4f915e": {
        "x": 960,
        "y": 0
      },
      "7760470c-33fa-57e9-8bb4-03d0ce66da77": {
        "x": 0,
        "y": 260
      }
    },
    "sizes": {}
  }
}
```

---

### `fixtures/uml/T07R.json`

```json
{
  "$schema": "https://plataforma-uml.local/schemas/board-state.json",
  "schemaVersion": "1.0.0",
  "id": "T07R",
  "title": "Modelo hostil resuelto",
  "coverage": "Reservada de PostgreSQL, tildes y espacios, reservada de Java, clase sin clave, colision al normalizar, dos relaciones entre el mismo par con roles, 0..1 y unico, con la colision resuelta para que llegue al generador",
  "semantic": {
    "classes": [
      {
        "id": "b1e3a998-1eaa-5d3f-89ca-abc7fc1abc63",
        "displayName": "Order",
        "codeName": "Order",
        "databaseName": "app_order",
        "attributes": [
          {
            "id": "0ab46971-3e28-52ba-846f-470173bb5c79",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "15417bb5-9978-5876-a4e0-1756058165ea",
            "displayName": "fecha",
            "codeName": "fecha",
            "databaseName": "fecha",
            "type": "DateTime",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "afbc5876-69e5-5058-af06-71dd199f3f48",
            "displayName": "class",
            "codeName": "appClass",
            "databaseName": "class",
            "type": "String",
            "primaryKey": false,
            "nullable": true,
            "unique": false
          },
          {
            "id": "d08dd68e-a6ee-58b2-b05f-a34ad2bdec09",
            "displayName": "total",
            "codeName": "total",
            "databaseName": "total",
            "type": "Decimal",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          }
        ]
      },
      {
        "id": "dc83486d-e595-54db-b133-ea7497440d63",
        "displayName": "Número de Cuenta",
        "codeName": "NumeroCuenta",
        "databaseName": "numero_cuenta",
        "attributes": [
          {
            "id": "500273f3-4c32-50f4-a0a7-60b966c5121c",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "bc8dafd1-b0ab-5b23-8690-dd9b2cd17d13",
            "displayName": "código",
            "codeName": "codigo",
            "databaseName": "codigo",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": true
          }
        ]
      },
      {
        "id": "75d75bcb-4fda-5087-83f8-7717386b8ae6",
        "displayName": "Cliente",
        "codeName": "Cliente",
        "databaseName": "cliente",
        "attributes": [
          {
            "id": "fbff504f-2c42-5945-a260-82ce0d5452d1",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "07fe500c-2fee-5261-8410-b5b616c01680",
            "displayName": "nombre",
            "codeName": "nombre",
            "databaseName": "nombre",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          }
        ]
      },
      {
        "id": "65144bc6-c626-5b3c-979c-9a443f8c1ef5",
        "displayName": "Detalle de Venta",
        "codeName": "DetalleVenta",
        "databaseName": "detalle_venta",
        "attributes": [
          {
            "id": "2133bd44-ed2b-55b9-8930-988dedfca3fa",
            "displayName": "cantidad",
            "codeName": "cantidad",
            "databaseName": "cantidad",
            "type": "Integer",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          }
        ]
      },
      {
        "id": "eeb1785a-4cae-5fc4-bfed-e0159c2aa600",
        "displayName": "nota de venta",
        "codeName": "NotaVenta",
        "databaseName": "nota_venta",
        "attributes": [
          {
            "id": "08e10c25-5e0e-5a9c-b6be-657787d2c0d4",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "59fce34f-cd49-503d-898e-77bd5e9b7fd9",
            "displayName": "nota",
            "codeName": "nota",
            "databaseName": "nota",
            "type": "String",
            "primaryKey": false,
            "nullable": true,
            "unique": false
          }
        ]
      }
    ],
    "relationships": [
      {
        "id": "1d9b643a-5e9c-5a89-ae1c-4796a72e8ecf",
        "sourceClassId": "75d75bcb-4fda-5087-83f8-7717386b8ae6",
        "targetClassId": "b1e3a998-1eaa-5d3f-89ca-abc7fc1abc63",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*",
        "sourceRoleName": "facturacion"
      },
      {
        "id": "33d15948-8c89-5e3d-b385-507b40d83c17",
        "sourceClassId": "75d75bcb-4fda-5087-83f8-7717386b8ae6",
        "targetClassId": "b1e3a998-1eaa-5d3f-89ca-abc7fc1abc63",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*",
        "sourceRoleName": "envio"
      },
      {
        "id": "b25f77a6-3217-56fd-925a-49d7bbff7f7e",
        "sourceClassId": "75d75bcb-4fda-5087-83f8-7717386b8ae6",
        "targetClassId": "dc83486d-e595-54db-b133-ea7497440d63",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..1"
      },
      {
        "id": "f097c42f-cde4-531a-b081-b4b9513bd019",
        "sourceClassId": "b1e3a998-1eaa-5d3f-89ca-abc7fc1abc63",
        "targetClassId": "65144bc6-c626-5b3c-979c-9a443f8c1ef5",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*"
      }
    ]
  },
  "layout": {
    "positions": {
      "b1e3a998-1eaa-5d3f-89ca-abc7fc1abc63": {
        "x": 0,
        "y": 0
      },
      "dc83486d-e595-54db-b133-ea7497440d63": {
        "x": 320,
        "y": 0
      },
      "75d75bcb-4fda-5087-83f8-7717386b8ae6": {
        "x": 640,
        "y": 0
      },
      "65144bc6-c626-5b3c-979c-9a443f8c1ef5": {
        "x": 960,
        "y": 0
      },
      "eeb1785a-4cae-5fc4-bfed-e0159c2aa600": {
        "x": 0,
        "y": 260
      }
    },
    "sizes": {}
  }
}
```

---

### `fixtures/uml/T08.json`

```json
{
  "$schema": "https://plataforma-uml.local/schemas/board-state.json",
  "schemaVersion": "1.0.0",
  "id": "T08",
  "title": "Institucion con jerarquia",
  "coverage": "Generalizacion en cadena de tres niveles, dos hermanas, clave foranea heredada y clave foranea que apunta a una subclase",
  "semantic": {
    "classes": [
      {
        "id": "9221a017-3b63-5f61-87f9-b03a2f729197",
        "displayName": "Persona",
        "codeName": "Persona",
        "databaseName": "persona",
        "attributes": [
          {
            "id": "bf14482f-50a8-5396-84e1-128679877b9d",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "f016b9d8-a313-5ab6-9c32-3f6b2668ea23",
            "displayName": "nombre",
            "codeName": "nombre",
            "databaseName": "nombre",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "7a60db07-90a7-5611-826d-3c71cc3a166f",
            "displayName": "correo",
            "codeName": "correo",
            "databaseName": "correo",
            "type": "String",
            "primaryKey": false,
            "nullable": true,
            "unique": false
          }
        ]
      },
      {
        "id": "7244ede2-2309-5706-b24c-40033d3a1f51",
        "displayName": "Empleado",
        "codeName": "Empleado",
        "databaseName": "empleado",
        "attributes": [
          {
            "id": "6258ac5b-7276-5ec4-825b-6646a1edcd2d",
            "displayName": "fecha de ingreso",
            "codeName": "fechaIngreso",
            "databaseName": "fecha_ingreso",
            "type": "Date",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "b22638c2-65bd-5e1b-a41f-cd5c38e70518",
            "displayName": "salario",
            "codeName": "salario",
            "databaseName": "salario",
            "type": "Decimal",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          }
        ]
      },
      {
        "id": "1b5ce23d-4be2-51ba-afe8-10470d90a11a",
        "displayName": "Docente",
        "codeName": "Docente",
        "databaseName": "docente",
        "attributes": [
          {
            "id": "7f7448ba-9c0d-5e2c-9a90-325c42370bc8",
            "displayName": "escalafon",
            "codeName": "escalafon",
            "databaseName": "escalafon",
            "type": "String",
            "primaryKey": false,
            "nullable": true,
            "unique": false
          }
        ]
      },
      {
        "id": "68dcf519-d427-59ed-bda0-ebfb23af7470",
        "displayName": "Estudiante",
        "codeName": "Estudiante",
        "databaseName": "estudiante",
        "attributes": [
          {
            "id": "9dde924e-9df3-5fbd-b330-92209d0410b5",
            "displayName": "matricula",
            "codeName": "matricula",
            "databaseName": "matricula",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": true
          }
        ]
      },
      {
        "id": "7b063dc3-c2a7-581d-a28f-5c21be78aaa7",
        "displayName": "Departamento",
        "codeName": "Departamento",
        "databaseName": "departamento",
        "attributes": [
          {
            "id": "8412ff56-b3d2-5621-9329-199b0adf5178",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "1dcf3cbf-32f2-50fd-a9b2-ae8dd4558c24",
            "displayName": "nombre",
            "codeName": "nombre",
            "databaseName": "nombre",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          }
        ]
      },
      {
        "id": "be22ac2f-235f-5dd4-b712-4992f4e4f2b0",
        "displayName": "Materia",
        "codeName": "Materia",
        "databaseName": "materia",
        "attributes": [
          {
            "id": "dd738ed5-c71a-5e65-8c90-c364097e89cf",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "88effc0c-ce46-59b0-be95-799471cc1e7d",
            "displayName": "nombre",
            "codeName": "nombre",
            "databaseName": "nombre",
            "type": "String",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "147507ee-865d-5b14-b3e8-df8a3fc8ef8c",
            "displayName": "creditos",
            "codeName": "creditos",
            "databaseName": "creditos",
            "type": "Integer",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          }
        ]
      },
      {
        "id": "7a4be9ee-997f-5b37-a50b-b64f086d8755",
        "displayName": "Inscripcion",
        "codeName": "Inscripcion",
        "databaseName": "inscripcion",
        "attributes": [
          {
            "id": "0c79e231-cd0b-5ba6-accd-9b3fdbb9e383",
            "displayName": "id",
            "codeName": "id",
            "databaseName": "id",
            "type": "UUID",
            "primaryKey": true,
            "nullable": false,
            "unique": false
          },
          {
            "id": "eae9449a-96e0-5ce8-994d-9dff4e97e693",
            "displayName": "fecha",
            "codeName": "fecha",
            "databaseName": "fecha",
            "type": "Date",
            "primaryKey": false,
            "nullable": false,
            "unique": false
          },
          {
            "id": "8b8fa1cc-43b5-5257-b663-b03c39d8092b",
            "displayName": "nota",
            "codeName": "nota",
            "databaseName": "nota",
            "type": "Decimal",
            "primaryKey": false,
            "nullable": true,
            "unique": false
          }
        ]
      }
    ],
    "relationships": [
      {
        "id": "c88d890e-50d8-52d9-84b1-3bc7e5416e91",
        "kind": "GENERALIZATION",
        "sourceClassId": "7244ede2-2309-5706-b24c-40033d3a1f51",
        "targetClassId": "9221a017-3b63-5f61-87f9-b03a2f729197",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "1"
      },
      {
        "id": "73ea2b6c-e1da-553d-858d-be574aafd345",
        "kind": "GENERALIZATION",
        "sourceClassId": "1b5ce23d-4be2-51ba-afe8-10470d90a11a",
        "targetClassId": "7244ede2-2309-5706-b24c-40033d3a1f51",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "1"
      },
      {
        "id": "6e05eaf4-ed76-543c-b974-58ff5aaf22c9",
        "kind": "GENERALIZATION",
        "sourceClassId": "68dcf519-d427-59ed-bda0-ebfb23af7470",
        "targetClassId": "9221a017-3b63-5f61-87f9-b03a2f729197",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "1"
      },
      {
        "id": "1859aed9-9e5b-5743-b439-cda2e1c39cb8",
        "sourceClassId": "7b063dc3-c2a7-581d-a28f-5c21be78aaa7",
        "targetClassId": "7244ede2-2309-5706-b24c-40033d3a1f51",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*"
      },
      {
        "id": "a65e5143-64f6-5078-9ae6-74b925244992",
        "sourceClassId": "1b5ce23d-4be2-51ba-afe8-10470d90a11a",
        "targetClassId": "be22ac2f-235f-5dd4-b712-4992f4e4f2b0",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*"
      },
      {
        "id": "55d0ead8-8515-56de-aece-8196c860c746",
        "sourceClassId": "68dcf519-d427-59ed-bda0-ebfb23af7470",
        "targetClassId": "7a4be9ee-997f-5b37-a50b-b64f086d8755",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*"
      },
      {
        "id": "2c917583-0439-511b-bc40-45b2357f0b50",
        "sourceClassId": "be22ac2f-235f-5dd4-b712-4992f4e4f2b0",
        "targetClassId": "7a4be9ee-997f-5b37-a50b-b64f086d8755",
        "sourceMultiplicity": "1",
        "targetMultiplicity": "0..*"
      }
    ]
  },
  "layout": {
    "positions": {
      "9221a017-3b63-5f61-87f9-b03a2f729197": {
        "x": 0,
        "y": 0
      },
      "7244ede2-2309-5706-b24c-40033d3a1f51": {
        "x": 320,
        "y": 0
      },
      "1b5ce23d-4be2-51ba-afe8-10470d90a11a": {
        "x": 640,
        "y": 0
      },
      "68dcf519-d427-59ed-bda0-ebfb23af7470": {
        "x": 960,
        "y": 0
      },
      "7b063dc3-c2a7-581d-a28f-5c21be78aaa7": {
        "x": 0,
        "y": 260
      },
      "be22ac2f-235f-5dd4-b712-4992f4e4f2b0": {
        "x": 320,
        "y": 260
      },
      "7a4be9ee-997f-5b37-a50b-b64f086d8755": {
        "x": 640,
        "y": 260
      }
    },
    "sizes": {}
  }
}
```

---

## XMI de referencia

Diagramas reales de Enterprise Architect usados para probar la importacion. Son grandes; se truncan si superan el limite.

### Estructura

```text
fixtures/xmi/
|-- architect-practica1.xmi
`-- README.md
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `fixtures/xmi/README.md` | 70 |
| `fixtures/xmi/architect-practica1.xmi` | 1896 |

---

### `fixtures/xmi/README.md`

```markdown
# Fixtures XMI

Archivos reales exportados de la instalación del laboratorio. **No** archivos
construidos a mano contra el estándar teórico.

## Muestra real incorporada

`architect-practica1.xmi` es el archivo exportado por Enterprise Architect 15
que se usó para ajustar y probar el parser. Contiene tipos Java en
`primitivetypes`, atributos en la extensión nativa, conectores y el diagrama
`Logical`.

La instalación de destino es **Enterprise Architect 15** (confirmado el 29 de
agosto de 2026). EA 15 puede publicar en XMI 1.1, XMI 2.1 y XMI 2.4.2.

El parser de `@uml/xmi` se prueba ahora contra esa muestra real y contra el
archivo generado anteriormente por la app. La prueba comprueba nombres, tipos,
relaciones y avisos. La apertura del archivo nuevo en una instalación EA real
sigue siendo la validación final de interoperabilidad.

### Qué hay que hacer

1. Abrir Enterprise Architect 15 en la máquina del laboratorio.
2. Si se desea ampliar la cobertura, exportar otros diagramas en **XMI 2.1**
   a este directorio; la prueba los recorrerá automáticamente.
3. Ejecutar `npm test`.
4. Abrir en EA un archivo generado por `npm run up` → exportar XMI, y comprobar
   que se ve el diagrama.
5. Confirmar con el docente si exige importación **y** exportación, o si basta
   con exportar.

Si hay que recortar, **exportar es lo que no se sacrifica**: el caso de uso del
docente es hacer el diagrama de secuencia sobre clases que ya existen. RF-050 es
P0; RF-051 es P1.

## Por qué archivos reales y no sintéticos

La variante de XMI que produce EA tiene extensiones propias y decisiones de
serialización que el estándar no fija — dónde cuelga el modelo, cómo escribe el
tipo de un atributo, si los extremos de una asociación van dentro de la
asociación o dentro de la clase.

Un parser escrito contra el estándar y probado contra archivos sintéticos falla
el día de la defensa contra el archivo que el docente abre en su máquina. Por eso
el nuestro acepta las tres notaciones de tipo que se ven en la práctica y busca
el modelo sin depender de una ruta fija — pero esas son mitigaciones, no una
verificación.

## Qué exporta la plataforma

La descarga usa UML/XMI 2.1 con el perfil de Enterprise Architect. La cabecera
`exporter="Enterprise Architect" exporterVersion="6.5"` activa su importador
nativo; un comentario identifica a la app como productor. Ver el
[resultado de la importación real y su corrección](../../docs/compatibilidad-xmi-2026-09-05.md).

| Elemento | Cómo se emite |
|---|---|
| Clase | `packagedElement` con `xmi:type="uml:Class"` |
| Atributo | `ownedAttribute` con referencia a tipos EAJava declarados en `xmi:Extension/primitivetypes`; respaldo en `properties.type` |
| Clave primaria | `isID="true"` — UML estándar, significa exactamente eso |
| Obligatorio | `lowerValue` a 1; opcional, a 0 |
| Relación | `uml:Association` con dos `ownedEnd`, cada uno con su multiplicidad |
| Identidad | UUID como `EAID_...`, paquete `EAPK_...` y referencias coherentes |
| Diagrama | Extensión EA con posiciones, tamaños, conectores y opciones de detalle |

La marca de atributo único se conserva en una extensión propia: `isUnique` de
UML describe repetidos en una colección, no unicidad de columna. Las extensiones
EA contienen tipos y presentación; ignorarlas puede perder esa información.
`serializeToXmi` sigue disponible como serializador genérico con tipos en el modelo.
```

---

### `fixtures/xmi/architect-practica1.xmi`

```xml
<?xml version="1.0" encoding="windows-1252"?>
<xmi:XMI xmi:version="2.1" xmlns:uml="http://schema.omg.org/spec/UML/2.1" xmlns:xmi="http://schema.omg.org/spec/XMI/2.1">
	<xmi:Documentation exporter="Enterprise Architect" exporterVersion="6.5"/>
	<uml:Model xmi:type="uml:Model" name="EA_Model" visibility="public">
		<packagedElement xmi:type="uml:Package" xmi:id="EAPK_B45D3D37_ADD5_4f7f_AD77_690F6097B920" name="Practica 1" visibility="public">
			<packagedElement xmi:type="uml:Class" xmi:id="EAID_D61CA6B6_D2CB_40cb_BF5C_E19BD21542A0" name="Aula" visibility="public">
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_F6F2CD63_6E8D_45b5_A5B9_901F2C21CFA3" name="idAula" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000001_6E8D_45b5_A5B9_901F2C21CFA3" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000002_6E8D_45b5_A5B9_901F2C21CFA3" value="1"/>
					<type xmi:idref="EAJava_int"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_FCB03521_11CC_4119_A10F_7A48CA3FD6E5" name="nombre" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000003_11CC_4119_A10F_7A48CA3FD6E5" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000004_11CC_4119_A10F_7A48CA3FD6E5" value="1"/>
					<type xmi:idref="EAJava_string"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_E0933A2C_6750_4f48_9824_BB98C009AC09" name="capacidad" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000005_6750_4f48_9824_BB98C009AC09" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000006_6750_4f48_9824_BB98C009AC09" value="1"/>
					<type xmi:idref="EAJava_int"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_C42593A2_8952_4831_B9BF_FEF88DC01761" name="bloque" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000007_8952_4831_B9BF_FEF88DC01761" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000008_8952_4831_B9BF_FEF88DC01761" value="1"/>
					<type xmi:idref="EAJava_string"/>
				</ownedAttribute>
			</packagedElement>
			<packagedElement xmi:type="uml:Association" xmi:id="EAID_926DEF20_8378_43bd_B04C_E604C4642425" visibility="public">
				<memberEnd xmi:idref="EAID_dst6DEF20_8378_43bd_B04C_E604C4642425"/>
				<ownedEnd xmi:type="uml:Property" xmi:id="EAID_dst6DEF20_8378_43bd_B04C_E604C4642425" visibility="public" association="EAID_926DEF20_8378_43bd_B04C_E604C4642425" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false" aggregation="none">
					<type xmi:idref="EAID_A4682377_D439_4256_B146_05374A8041F8"/>
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000009__8378_43bd_B04C_E604C4642425" value="0"/>
					<upperValue xmi:type="uml:LiteralUnlimitedNatural" xmi:id="EAID_LI000010__8378_43bd_B04C_E604C4642425" value="-1"/>
				</ownedEnd>
				<memberEnd xmi:idref="EAID_src6DEF20_8378_43bd_B04C_E604C4642425"/>
				<ownedEnd xmi:type="uml:Property" xmi:id="EAID_src6DEF20_8378_43bd_B04C_E604C4642425" visibility="public" association="EAID_926DEF20_8378_43bd_B04C_E604C4642425" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false" aggregation="none">
					<type xmi:idref="EAID_D61CA6B6_D2CB_40cb_BF5C_E19BD21542A0"/>
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000051__8378_43bd_B04C_E604C4642425" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000052__8378_43bd_B04C_E604C4642425" value="1"/>
				</ownedEnd>
			</packagedElement>
			<packagedElement xmi:type="uml:Class" xmi:id="EAID_C653E036_9DFB_4e15_9B7B_DECB00FAA79F" name="Calificacion" visibility="public">
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_D5C96E3D_DC41_4a10_AB8A_7D7CB948A90C" name="idCalificacion" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000011_DC41_4a10_AB8A_7D7CB948A90C" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000012_DC41_4a10_AB8A_7D7CB948A90C" value="1"/>
					<type xmi:idref="EAJava_int"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_F033616A_31B7_48b7_A57F_02DB312BC8D4" name="nombre" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000013_31B7_48b7_A57F_02DB312BC8D4" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000014_31B7_48b7_A57F_02DB312BC8D4" value="1"/>
					<type xmi:idref="EAJava_string"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_0367D6A8_6439_455a_B336_ED45D6B805AF" name="porcentaje" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000015_6439_455a_B336_ED45D6B805AF" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000016_6439_455a_B336_ED45D6B805AF" value="1"/>
					<type xmi:idref="EAJava_decimal"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_4693B204_E0C5_49c3_8996_D61073B27B88" name="nota" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000017_E0C5_49c3_8996_D61073B27B88" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000018_E0C5_49c3_8996_D61073B27B88" value="1"/>
					<type xmi:idref="EAJava_decimal"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_dst6F79AD_B5C1_4bcf_BC4D_7FDFBEBF9DF2" visibility="public" association="EAID_F26F79AD_B5C1_4bcf_BC4D_7FDFBEBF9DF2" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false" aggregation="none">
					<type xmi:idref="EAID_7FEBB9BF_1F3F_4e76_9857_5F07C7628A03"/>
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000019__B5C1_4bcf_BC4D_7FDFBEBF9DF2" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000020__B5C1_4bcf_BC4D_7FDFBEBF9DF2" value="1"/>
				</ownedAttribute>
			</packagedElement>
			<packagedElement xmi:type="uml:Association" xmi:id="EAID_F26F79AD_B5C1_4bcf_BC4D_7FDFBEBF9DF2" visibility="public">
				<memberEnd xmi:idref="EAID_dst6F79AD_B5C1_4bcf_BC4D_7FDFBEBF9DF2"/>
				<memberEnd xmi:idref="EAID_src6F79AD_B5C1_4bcf_BC4D_7FDFBEBF9DF2"/>
				<ownedEnd xmi:type="uml:Property" xmi:id="EAID_src6F79AD_B5C1_4bcf_BC4D_7FDFBEBF9DF2" visibility="public" association="EAID_F26F79AD_B5C1_4bcf_BC4D_7FDFBEBF9DF2" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false" aggregation="composite">
					<type xmi:idref="EAID_C653E036_9DFB_4e15_9B7B_DECB00FAA79F"/>
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000101__B5C1_4bcf_BC4D_7FDFBEBF9DF2" value="0"/>
					<upperValue xmi:type="uml:LiteralUnlimitedNatural" xmi:id="EAID_LI000102__B5C1_4bcf_BC4D_7FDFBEBF9DF2" value="-1"/>
				</ownedEnd>
			</packagedElement>
			<packagedElement xmi:type="uml:Class" xmi:id="EAID_612CBEF6_C55B_415c_B03A_34446EF1955D" name="CarnetEstudiante" visibility="public">
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_3C8D6AAD_3F18_4efc_8D2E_3337CA94C6B8" name="idCarnet" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000021_3F18_4efc_8D2E_3337CA94C6B8" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000022_3F18_4efc_8D2E_3337CA94C6B8" value="1"/>
					<type xmi:idref="EAJava_int"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_BF542E00_8D63_470d_8005_443B2D37013F" name="codigo" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000023_8D63_470d_8005_443B2D37013F" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000024_8D63_470d_8005_443B2D37013F" value="1"/>
					<type xmi:idref="EAJava_string"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_61B79204_2550_43ae_BBBE_AC20C4D84D87" name="fechaEmision" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000025_2550_43ae_BBBE_AC20C4D84D87" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000026_2550_43ae_BBBE_AC20C4D84D87" value="1"/>
					<type xmi:idref="EAJava_date"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_2F133C78_4E48_477b_98A7_863FB195A59A" name="fechaVencimiento" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000027_4E48_477b_98A7_863FB195A59A" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000028_4E48_477b_98A7_863FB195A59A" value="1"/>
					<type xmi:idref="EAJava_date"/>
				</ownedAttribute>
			</packagedElement>
			<packagedElement xmi:type="uml:Association" xmi:id="EAID_27E33190_8A7C_4514_9D06_98BECC31B712" visibility="public">
				<memberEnd xmi:idref="EAID_dstE33190_8A7C_4514_9D06_98BECC31B712"/>
				<memberEnd xmi:idref="EAID_srcE33190_8A7C_4514_9D06_98BECC31B712"/>
				<ownedEnd xmi:type="uml:Property" xmi:id="EAID_srcE33190_8A7C_4514_9D06_98BECC31B712" visibility="public" association="EAID_27E33190_8A7C_4514_9D06_98BECC31B712" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false" aggregation="none">
					<type xmi:idref="EAID_413197F1_1E7D_4a71_A961_218ED07519D2"/>
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000029__8A7C_4514_9D06_98BECC31B712" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000030__8A7C_4514_9D06_98BECC31B712" value="1"/>
				</ownedEnd>
				<ownedEnd xmi:type="uml:Property" xmi:id="EAID_dstE33190_8A7C_4514_9D06_98BECC31B712" visibility="public" association="EAID_27E33190_8A7C_4514_9D06_98BECC31B712" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false" aggregation="none">
					<type xmi:idref="EAID_612CBEF6_C55B_415c_B03A_34446EF1955D"/>
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000089__8A7C_4514_9D06_98BECC31B712" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000090__8A7C_4514_9D06_98BECC31B712" value="1"/>
				</ownedEnd>
			</packagedElement>
			<packagedElement xmi:type="uml:Class" xmi:id="EAID_F47E3563_90EE_48ad_AE30_5488758D7710" name="Carrera" visibility="public">
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_4AA5E0F9_665D_4c5a_A8CE_53DF8787E366" name="idCarrera" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000031_665D_4c5a_A8CE_53DF8787E366" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000032_665D_4c5a_A8CE_53DF8787E366" value="1"/>
					<type xmi:idref="EAJava_int"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_F3ABD9EA_4B24_4c2a_8136_BAE032110094" name="nombre" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000033_4B24_4c2a_8136_BAE032110094" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000034_4B24_4c2a_8136_BAE032110094" value="1"/>
					<type xmi:idref="EAJava_string"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_4BDC8A51_8A36_436c_9E4F_96C74C313616" name="duracionSemestre" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000035_8A36_436c_9E4F_96C74C313616" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000036_8A36_436c_9E4F_96C74C313616" value="1"/>
					<type xmi:idref="EAJava_int"/>
				</ownedAttribute>
			</packagedElement>
			<packagedElement xmi:type="uml:Association" xmi:id="EAID_49164E2F_13AE_4bd1_B088_6C2F1559588B" visibility="public">
				<memberEnd xmi:idref="EAID_dst164E2F_13AE_4bd1_B088_6C2F1559588B"/>
				<ownedEnd xmi:type="uml:Property" xmi:id="EAID_dst164E2F_13AE_4bd1_B088_6C2F1559588B" visibility="public" association="EAID_49164E2F_13AE_4bd1_B088_6C2F1559588B" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false" aggregation="none">
					<type xmi:idref="EAID_21D38904_C859_44ff_A301_944416EF1EB8"/>
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000037__13AE_4bd1_B088_6C2F1559588B" value="1"/>
					<upperValue xmi:type="uml:LiteralUnlimitedNatural" xmi:id="EAID_LI000038__13AE_4bd1_B088_6C2F1559588B" value="-1"/>
				</ownedEnd>
				<memberEnd xmi:idref="EAID_src164E2F_13AE_4bd1_B088_6C2F1559588B"/>
				<ownedEnd xmi:type="uml:Property" xmi:id="EAID_src164E2F_13AE_4bd1_B088_6C2F1559588B" visibility="public" association="EAID_49164E2F_13AE_4bd1_B088_6C2F1559588B" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false" aggregation="none">
					<type xmi:idref="EAID_F47E3563_90EE_48ad_AE30_5488758D7710"/>
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000117__13AE_4bd1_B088_6C2F1559588B" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000118__13AE_4bd1_B088_6C2F1559588B" value="1"/>
				</ownedEnd>
			</packagedElement>
			<packagedElement xmi:type="uml:Association" xmi:id="EAID_8A209896_3D45_47de_800C_92CB3BC026D8" visibility="public">
				<memberEnd xmi:idref="EAID_dst209896_3D45_47de_800C_92CB3BC026D8"/>
				<memberEnd xmi:idref="EAID_src209896_3D45_47de_800C_92CB3BC026D8"/>
				<ownedEnd xmi:type="uml:Property" xmi:id="EAID_src209896_3D45_47de_800C_92CB3BC026D8" visibility="public" association="EAID_8A209896_3D45_47de_800C_92CB3BC026D8" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false" aggregation="none">
					<type xmi:idref="EAID_083D0DB1_BCBE_4a1c_A8A3_FA0146133CA6"/>
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000039__3D45_47de_800C_92CB3BC026D8" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000040__3D45_47de_800C_92CB3BC026D8" value="1"/>
				</ownedEnd>
				<ownedEnd xmi:type="uml:Property" xmi:id="EAID_dst209896_3D45_47de_800C_92CB3BC026D8" visibility="public" association="EAID_8A209896_3D45_47de_800C_92CB3BC026D8" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false" aggregation="none">
					<type xmi:idref="EAID_F47E3563_90EE_48ad_AE30_5488758D7710"/>
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000065__3D45_47de_800C_92CB3BC026D8" value="0"/>
					<upperValue xmi:type="uml:LiteralUnlimitedNatural" xmi:id="EAID_LI000066__3D45_47de_800C_92CB3BC026D8" value="-1"/>
				</ownedEnd>
			</packagedElement>
			<packagedElement xmi:type="uml:Class" xmi:id="EAID_66F5597A_0FC0_4ab9_A176_D1F05B7057C0" name="Class1" visibility="public"/>
			<packagedElement xmi:type="uml:Class" xmi:id="EAID_A4682377_D439_4256_B146_05374A8041F8" name="Curso" visibility="public">
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_BC84A785_34B9_4e4c_89FB_52DEBE8B270B" name="idCurso" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000041_34B9_4e4c_89FB_52DEBE8B270B" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000042_34B9_4e4c_89FB_52DEBE8B270B" value="1"/>
					<type xmi:idref="EAJava_int"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_37C0D3C1_284D_41e4_89A5_FD473747E196" name="grupo" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000043_284D_41e4_89A5_FD473747E196" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000044_284D_41e4_89A5_FD473747E196" value="1"/>
					<type xmi:idref="EAJava_string"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_B9D1498F_9E6E_47c3_BA62_2B24DCF8C30F" name="gestion" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000045_9E6E_47c3_BA62_2B24DCF8C30F" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000046_9E6E_47c3_BA62_2B24DCF8C30F" value="1"/>
					<type xmi:idref="EAJava_int"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_C1308DC7_F4D9_4d19_A823_7DD6797AA6CF" name="periodo" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000047_F4D9_4d19_A823_7DD6797AA6CF" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000048_F4D9_4d19_A823_7DD6797AA6CF" value="1"/>
					<type xmi:idref="EAJava_int"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_41C57B56_5892_4f28_9D8B_B8059E5463DC" name="horario" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000049_5892_4f28_9D8B_B8059E5463DC" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000050_5892_4f28_9D8B_B8059E5463DC" value="1"/>
					<type xmi:idref="EAJava_string"/>
				</ownedAttribute>
			</packagedElement>
			<packagedElement xmi:type="uml:Association" xmi:id="EAID_D2A2071B_E9E3_40f3_881D_29CDF8CE57D4" visibility="public">
				<memberEnd xmi:idref="EAID_dstA2071B_E9E3_40f3_881D_29CDF8CE57D4"/>
				<memberEnd xmi:idref="EAID_srcA2071B_E9E3_40f3_881D_29CDF8CE57D4"/>
				<ownedEnd xmi:type="uml:Property" xmi:id="EAID_srcA2071B_E9E3_40f3_881D_29CDF8CE57D4" visibility="public" association="EAID_D2A2071B_E9E3_40f3_881D_29CDF8CE57D4" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false" aggregation="none">
					<type xmi:idref="EAID_413197F1_1E7D_4a71_A961_218ED07519D2"/>
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000053__E9E3_40f3_881D_29CDF8CE57D4" value="0"/>
					<upperValue xmi:type="uml:LiteralUnlimitedNatural" xmi:id="EAID_LI000054__E9E3_40f3_881D_29CDF8CE57D4" value="-1"/>
				</ownedEnd>
				<ownedEnd xmi:type="uml:Property" xmi:id="EAID_dstA2071B_E9E3_40f3_881D_29CDF8CE57D4" visibility="public" association="EAID_D2A2071B_E9E3_40f3_881D_29CDF8CE57D4" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false" aggregation="none">
					<type xmi:idref="EAID_A4682377_D439_4256_B146_05374A8041F8"/>
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000091__E9E3_40f3_881D_29CDF8CE57D4" value="0"/>
					<upperValue xmi:type="uml:LiteralUnlimitedNatural" xmi:id="EAID_LI000092__E9E3_40f3_881D_29CDF8CE57D4" value="-1"/>
				</ownedEnd>
			</packagedElement>
			<packagedElement xmi:type="uml:Association" xmi:id="EAID_EA8465DB_DD4A_4733_8533_8E822E102842" visibility="public">
				<memberEnd xmi:idref="EAID_dst8465DB_DD4A_4733_8533_8E822E102842"/>
				<memberEnd xmi:idref="EAID_src8465DB_DD4A_4733_8533_8E822E102842"/>
				<ownedEnd xmi:type="uml:Property" xmi:id="EAID_src8465DB_DD4A_4733_8533_8E822E102842" visibility="public" association="EAID_EA8465DB_DD4A_4733_8533_8E822E102842" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false" aggregation="none">
					<type xmi:idref="EAID_21D38904_C859_44ff_A301_944416EF1EB8"/>
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000055__DD4A_4733_8533_8E822E102842" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000056__DD4A_4733_8533_8E822E102842" value="1"/>
				</ownedEnd>
				<ownedEnd xmi:type="uml:Property" xmi:id="EAID_dst8465DB_DD4A_4733_8533_8E822E102842" visibility="public" association="EAID_EA8465DB_DD4A_4733_8533_8E822E102842" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false" aggregation="none">
					<type xmi:idref="EAID_A4682377_D439_4256_B146_05374A8041F8"/>
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000115__DD4A_4733_8533_8E822E102842" value="0"/>
					<upperValue xmi:type="uml:LiteralUnlimitedNatural" xmi:id="EAID_LI000116__DD4A_4733_8533_8E822E102842" value="-1"/>
				</ownedEnd>
			</packagedElement>
			<packagedElement xmi:type="uml:Association" xmi:id="EAID_F9D134A4_C537_4bc8_9481_FA8D8099EA95" visibility="public">
				<memberEnd xmi:idref="EAID_dstD134A4_C537_4bc8_9481_FA8D8099EA95"/>
				<memberEnd xmi:idref="EAID_srcD134A4_C537_4bc8_9481_FA8D8099EA95"/>
				<ownedEnd xmi:type="uml:Property" xmi:id="EAID_srcD134A4_C537_4bc8_9481_FA8D8099EA95" visibility="public" association="EAID_F9D134A4_C537_4bc8_9481_FA8D8099EA95" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false" aggregation="none">
					<type xmi:idref="EAID_D8D61BB2_E1C9_4b86_8443_B5362CD5B82D"/>
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000057__C537_4bc8_9481_FA8D8099EA95" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000058__C537_4bc8_9481_FA8D8099EA95" value="1"/>
				</ownedEnd>
				<ownedEnd xmi:type="uml:Property" xmi:id="EAID_dstD134A4_C537_4bc8_9481_FA8D8099EA95" visibility="public" association="EAID_F9D134A4_C537_4bc8_9481_FA8D8099EA95" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false" aggregation="none">
					<type xmi:idref="EAID_A4682377_D439_4256_B146_05374A8041F8"/>
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000079__C537_4bc8_9481_FA8D8099EA95" value="0"/>
					<upperValue xmi:type="uml:LiteralUnlimitedNatural" xmi:id="EAID_LI000080__C537_4bc8_9481_FA8D8099EA95" value="-1"/>
				</ownedEnd>
			</packagedElement>
			<packagedElement xmi:type="uml:Class" xmi:id="EAID_083D0DB1_BCBE_4a1c_A8A3_FA0146133CA6" name="Departamento" visibility="public">
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_E81037EC_DDBE_40c1_AE6D_FB8AC9221A2D" name="idDepartamento" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000059_DDBE_40c1_AE6D_FB8AC9221A2D" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000060_DDBE_40c1_AE6D_FB8AC9221A2D" value="1"/>
					<type xmi:idref="EAJava_int"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_3FD94692_783F_4158_8E7F_EBCE706D6AA0" name="nombre" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000061_783F_4158_8E7F_EBCE706D6AA0" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000062_783F_4158_8E7F_EBCE706D6AA0" value="1"/>
					<type xmi:idref="EAJava_string"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_CC3F313D_C0BA_41a0_9A95_096F9354F853" name="ubicacion" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000063_C0BA_41a0_9A95_096F9354F853" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000064_C0BA_41a0_9A95_096F9354F853" value="1"/>
					<type xmi:idref="EAJava_string"/>
				</ownedAttribute>
			</packagedElement>
			<packagedElement xmi:type="uml:Association" xmi:id="EAID_D91235B1_A372_4535_BAE5_456B6E7D1F3F" visibility="public">
				<memberEnd xmi:idref="EAID_dst1235B1_A372_4535_BAE5_456B6E7D1F3F"/>
				<memberEnd xmi:idref="EAID_src1235B1_A372_4535_BAE5_456B6E7D1F3F"/>
				<ownedEnd xmi:type="uml:Property" xmi:id="EAID_src1235B1_A372_4535_BAE5_456B6E7D1F3F" visibility="public" association="EAID_D91235B1_A372_4535_BAE5_456B6E7D1F3F" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false" aggregation="shared">
					<type xmi:idref="EAID_D8D61BB2_E1C9_4b86_8443_B5362CD5B82D"/>
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000067__A372_4535_BAE5_456B6E7D1F3F" value="0"/>
					<upperValue xmi:type="uml:LiteralUnlimitedNatural" xmi:id="EAID_LI000068__A372_4535_BAE5_456B6E7D1F3F" value="-1"/>
				</ownedEnd>
			</packagedElement>
			<packagedElement xmi:type="uml:Class" xmi:id="EAID_D8D61BB2_E1C9_4b86_8443_B5362CD5B82D" name="Docente" visibility="public">
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_268C4426_C0B4_4aa8_8897_380372F4013C" name="idPersona" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000069_C0B4_4aa8_8897_380372F4013C" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000070_C0B4_4aa8_8897_380372F4013C" value="1"/>
					<type xmi:idref="EAJava_int"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_89FCFDD4_F753_4c60_BA0C_EE22CAAE2D2B" name="codigoDocente" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000071_F753_4c60_BA0C_EE22CAAE2D2B" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000072_F753_4c60_BA0C_EE22CAAE2D2B" value="1"/>
					<type xmi:idref="EAJava_string"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_3237C58C_15D7_4e03_9EB0_2A87D240A10E" name="especialidad" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000073_15D7_4e03_9EB0_2A87D240A10E" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000074_15D7_4e03_9EB0_2A87D240A10E" value="1"/>
					<type xmi:idref="EAJava_string"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_73538FC6_57D5_4d2b_BC24_0FF6F3C07505" name="fechaContratacion" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000075_57D5_4d2b_BC24_0FF6F3C07505" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000076_57D5_4d2b_BC24_0FF6F3C07505" value="1"/>
					<type xmi:idref="EAJava_date"/>
				</ownedAttribute>
				<generalization xmi:type="uml:Generalization" xmi:id="EAID_12B79008_50CE_4e02_B54F_F66AB79E7C35" general="EAID_5BDC6444_175B_4e5c_8B60_8EC1CD658997"/>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_dst1235B1_A372_4535_BAE5_456B6E7D1F3F" visibility="public" association="EAID_D91235B1_A372_4535_BAE5_456B6E7D1F3F" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false" aggregation="none">
					<type xmi:idref="EAID_083D0DB1_BCBE_4a1c_A8A3_FA0146133CA6"/>
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000077__A372_4535_BAE5_456B6E7D1F3F" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000078__A372_4535_BAE5_456B6E7D1F3F" value="1"/>
				</ownedAttribute>
			</packagedElement>
			<packagedElement xmi:type="uml:Class" xmi:id="EAID_413197F1_1E7D_4a71_A961_218ED07519D2" name="Estudiante" visibility="public">
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_65DFE0C3_3560_47c9_BCBB_0898CE5251FE" name="idPersona" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000081_3560_47c9_BCBB_0898CE5251FE" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000082_3560_47c9_BCBB_0898CE5251FE" value="1"/>
					<type xmi:idref="EAJava_int"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_F0CCB5AE_F992_4c52_ADAD_D4C5DF86A705" name="registro" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000083_F992_4c52_ADAD_D4C5DF86A705" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000084_F992_4c52_ADAD_D4C5DF86A705" value="1"/>
					<type xmi:idref="EAJava_string"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_B04B5EF9_6E8D_4d77_AE06_7695A62894B1" name="fechaIngreso" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000085_6E8D_4d77_AE06_7695A62894B1" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000086_6E8D_4d77_AE06_7695A62894B1" value="1"/>
					<type xmi:idref="EAJava_date"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_A11AB739_6904_46ca_A65F_235983F6B0C3" name="estado" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000087_6904_46ca_A65F_235983F6B0C3" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000088_6904_46ca_A65F_235983F6B0C3" value="1"/>
					<type xmi:idref="EAJava_string"/>
				</ownedAttribute>
				<generalization xmi:type="uml:Generalization" xmi:id="EAID_FD88C7CB_4DD9_4e23_8939_C1A22EACCA94" general="EAID_5BDC6444_175B_4e5c_8B60_8EC1CD658997"/>
			</packagedElement>
			<packagedElement xmi:type="uml:Class" xmi:id="EAID_D6C5A3B9_FD4E_4dc0_BD66_E66E7759C85E" name="Inscripcion" visibility="public"/>
			<packagedElement xmi:type="uml:AssociationClass" xmi:id="EAID_7FEBB9BF_1F3F_4e76_9857_5F07C7628A03" name="Inscripcion" visibility="public">
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_488E07EF_1249_485c_A74D_08325F9A8FF0" name="fecha" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000093_1249_485c_A74D_08325F9A8FF0" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000094_1249_485c_A74D_08325F9A8FF0" value="1"/>
					<type xmi:idref="EAJava_date"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_F1FC2AAE_A0AC_481a_81F8_01AB9B5E09C7" name="estado" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000095_A0AC_481a_81F8_01AB9B5E09C7" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000096_A0AC_481a_81F8_01AB9B5E09C7" value="1"/>
					<type xmi:idref="EAJava_string"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_0D0609BA_F741_4031_815D_3194DF5D683B" name="notaFinal" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000097_F741_4031_815D_3194DF5D683B" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000098_F741_4031_815D_3194DF5D683B" value="1"/>
					<type xmi:idref="EAJava_decimal"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_5E275F90_929B_46fd_8AF1_F0CA3584514F" name="idInscripcion" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000099_929B_46fd_8AF1_F0CA3584514F" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000100_929B_46fd_8AF1_F0CA3584514F" value="1"/>
					<type xmi:idref="EAJava_int"/>
				</ownedAttribute>
				<memberEnd xmi:idref="EAID_dstAF9D5A_0903_49f5_8602_BA5820547AD6"/>
				<ownedEnd xmi:type="uml:Property" xmi:id="EAID_dstAF9D5A_0903_49f5_8602_BA5820547AD6" visibility="public" association="EAID_7FEBB9BF_1F3F_4e76_9857_5F07C7628A03" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false" aggregation="none">
					<type xmi:idref="EAID_A38849F1_506B_4769_9F51_47AC9B014704"/>
				</ownedEnd>
				<memberEnd xmi:idref="EAID_srcAF9D5A_0903_49f5_8602_BA5820547AD6"/>
				<ownedEnd xmi:type="uml:Property" xmi:id="EAID_srcAF9D5A_0903_49f5_8602_BA5820547AD6" visibility="public" association="EAID_7FEBB9BF_1F3F_4e76_9857_5F07C7628A03" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false" aggregation="none">
					<type xmi:idref="EAID_62EE9303_7A72_4331_AFA9_0ABC599D8749"/>
				</ownedEnd>
			</packagedElement>
			<packagedElement xmi:type="uml:Class" xmi:id="EAID_21D38904_C859_44ff_A301_944416EF1EB8" name="Materia" visibility="public">
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_0707D46D_DC93_4486_BCE9_A5C9CB13DE34" name="idMateria" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000103_DC93_4486_BCE9_A5C9CB13DE34" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000104_DC93_4486_BCE9_A5C9CB13DE34" value="1"/>
					<type xmi:idref="EAJava_int"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_A2BF5002_6D10_49c7_9EA3_AD27C949F5B9" name="sigla" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000105_6D10_49c7_9EA3_AD27C949F5B9" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000106_6D10_49c7_9EA3_AD27C949F5B9" value="1"/>
					<type xmi:idref="EAJava_string"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_BA536EE2_3A3D_4a20_99ED_5DDF6C8A461B" name="nombre" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000107_3A3D_4a20_99ED_5DDF6C8A461B" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000108_3A3D_4a20_99ED_5DDF6C8A461B" value="1"/>
					<type xmi:idref="EAJava_string"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_1714A655_9A3B_4b81_9068_4A6FE73A2F20" name="creditos" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000109_9A3B_4b81_9068_4A6FE73A2F20" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000110_9A3B_4b81_9068_4A6FE73A2F20" value="1"/>
					<type xmi:idref="EAJava_int"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_44186335_A56F_48a8_9984_2544FCEF0327" name="semestre" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000111_A56F_48a8_9984_2544FCEF0327" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000112_A56F_48a8_9984_2544FCEF0327" value="1"/>
					<type xmi:idref="EAJava_int"/>
				</ownedAttribute>
			</packagedElement>
			<packagedElement xmi:type="uml:Association" xmi:id="EAID_A7075F92_B883_4b58_A303_287A45EF47B7" visibility="public">
				<memberEnd xmi:idref="EAID_dst075F92_B883_4b58_A303_287A45EF47B7"/>
				<ownedEnd xmi:type="uml:Property" xmi:id="EAID_dst075F92_B883_4b58_A303_287A45EF47B7" visibility="public" association="EAID_A7075F92_B883_4b58_A303_287A45EF47B7" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false" aggregation="none">
					<type xmi:idref="EAID_21D38904_C859_44ff_A301_944416EF1EB8"/>
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000113__B883_4b58_A303_287A45EF47B7" value="0"/>
					<upperValue xmi:type="uml:LiteralUnlimitedNatural" xmi:id="EAID_LI000114__B883_4b58_A303_287A45EF47B7" value="-1"/>
				</ownedEnd>
				<memberEnd xmi:idref="EAID_src075F92_B883_4b58_A303_287A45EF47B7"/>
				<ownedEnd xmi:type="uml:Property" xmi:id="EAID_src075F92_B883_4b58_A303_287A45EF47B7" visibility="public" association="EAID_A7075F92_B883_4b58_A303_287A45EF47B7" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false" aggregation="none">
					<type xmi:idref="EAID_21D38904_C859_44ff_A301_944416EF1EB8"/>
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000119__B883_4b58_A303_287A45EF47B7" value="0"/>
					<upperValue xmi:type="uml:LiteralUnlimitedNatural" xmi:id="EAID_LI000120__B883_4b58_A303_287A45EF47B7" value="-1"/>
				</ownedEnd>
			</packagedElement>
			<packagedElement xmi:type="uml:Class" xmi:id="EAID_5BDC6444_175B_4e5c_8B60_8EC1CD658997" name="Persona" visibility="public">
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_EFED3636_22AB_415d_A82A_F1F7ED4AA50B" name="idPersona" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000121_22AB_415d_A82A_F1F7ED4AA50B" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000122_22AB_415d_A82A_F1F7ED4AA50B" value="1"/>
					<type xmi:idref="EAJava_int"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_3E833D20_3FFF_43c2_8EC3_88B36E40FA36" name="ci" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000123_3FFF_43c2_8EC3_88B36E40FA36" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000124_3FFF_43c2_8EC3_88B36E40FA36" value="1"/>
					<type xmi:idref="EAJava_string"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_556775A9_E390_4477_9CFC_575383B541C3" name="nombre" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000125_E390_4477_9CFC_575383B541C3" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000126_E390_4477_9CFC_575383B541C3" value="1"/>
					<type xmi:idref="EAJava_string"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_7E04437C_5D23_45fb_80AE_91E668087854" name="apellido" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000127_5D23_45fb_80AE_91E668087854" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000128_5D23_45fb_80AE_91E668087854" value="1"/>
					<type xmi:idref="EAJava_string"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_0C5EE71E_3CAC_4d80_9747_808C6F33B28C" name="correo" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000129_3CAC_4d80_9747_808C6F33B28C" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000130_3CAC_4d80_9747_808C6F33B28C" value="1"/>
					<type xmi:idref="EAJava_string"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_3AC9335C_F48C_420c_8755_D22AFC4DF0C2" name="telefono" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000131_F48C_420c_8755_D22AFC4DF0C2" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000132_F48C_420c_8755_D22AFC4DF0C2" value="1"/>
					<type xmi:idref="EAJava_string"/>
				</ownedAttribute>
				<ownedAttribute xmi:type="uml:Property" xmi:id="EAID_0F851884_D986_4d2a_8C27_3A4F9A765A34" name="fechaNacimiento" visibility="private" isStatic="false" isReadOnly="false" isDerived="false" isOrdered="false" isUnique="true" isDerivedUnion="false">
					<lowerValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000133_D986_4d2a_8C27_3A4F9A765A34" value="1"/>
					<upperValue xmi:type="uml:LiteralInteger" xmi:id="EAID_LI000134_D986_4d2a_8C27_3A4F9A765A34" value="1"/>
					<type xmi:idref="EAJava_date"/>
				</ownedAttribute>
			</packagedElement>
			<packagedElement xmi:type="uml:Class" xmi:id="EAID_CF7609F1_C991_4503_A15F_B43FBCD34315" name="PrerequisitoMateria" visibility="public"/>
			<packagedElement xmi:type="uml:Association" xmi:id="EAID_3B238C8F_CEC1_4c79_B386_CDF3B1E95712" visibility="public"/>
			<packagedElement xmi:type="uml:Class" xmi:id="EAID_62EE9303_7A72_4331_AFA9_0ABC599D8749" name="ProxyConnector" visibility="public"/>
			<packagedElement xmi:type="uml:Class" xmi:id="EAID_A38849F1_506B_4769_9F51_47AC9B014704" name="ProxyConnector" visibility="public"/>
		</packagedElement>
	</uml:Model>
	<xmi:Extension extender="Enterprise Architect" extenderID="6.5">
		<elements>
			<element xmi:idref="EAPK_B45D3D37_ADD5_4f7f_AD77_690F6097B920" xmi:type="uml:Package" name="Practica 1" scope="public">
				<model package2="EAID_B45D3D37_ADD5_4f7f_AD77_690F6097B920" package="EAPK_6C72DC83_8D2C_47d2_AED6_5DC2A1D39691" tpos="0" ea_localid="2" ea_eleType="package"/>
				<properties isSpecification="false" sType="Package" nType="0" scope="public"/>
				<project author="braya" version="1.0" phase="1.0" created="2026-08-31 18:27:42" modified="2026-08-31 18:27:42" complexity="1" status="Proposed"/>
				<code gentype="Java"/>
				<style appearance="BackColor=-1;BorderColor=-1;BorderWidth=-1;FontColor=-1;VSwimLanes=1;HSwimLanes=1;BorderStyle=0;"/>
				<tags/>
				<xrefs/>
				<extendedProperties tagged="0" package_name="Model"/>
				<packageproperties version="1.0"/>
				<paths/>
				<times created="2026-08-31 18:27:42" modified="2026-08-31 18:27:42"/>
				<flags iscontrolled="FALSE" isprotected="FALSE" usedtd="FALSE" logxml="FALSE" packageFlags="isModel=1;VICON=3;"/>
			</element>
			<element xmi:idref="EAID_D61CA6B6_D2CB_40cb_BF5C_E19BD21542A0" xmi:type="uml:Class" name="Aula" scope="public">
				<model package="EAPK_B45D3D37_ADD5_4f7f_AD77_690F6097B920" tpos="0" ea_localid="18" ea_eleType="element"/>
				<properties isSpecification="false" sType="Class" nType="0" scope="public" isRoot="false" isLeaf="false" isAbstract="false" isActive="false"/>
				<project author="braya" version="1.0" phase="1.0" created="2026-09-03 00:33:02" modified="2026-09-03 00:33:05" complexity="1" status="Proposed"/>
				<code gentype="Java"/>
				<style appearance="BackColor=-1;BorderColor=-1;BorderWidth=-1;FontColor=-1;VSwimLanes=1;HSwimLanes=1;BorderStyle=0;"/>
				<tags/>
				<xrefs/>
				<extendedProperties tagged="0" package_name="Practica 1"/>
				<attributes>
					<attribute xmi:idref="EAID_F6F2CD63_6E8D_45b5_A5B9_901F2C21CFA3" name="idAula" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="43" ea_guid="{F6F2CD63-6E8D-45b5-A5B9-901F2C21CFA3}"/>
						<properties type="int" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="0"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_FCB03521_11CC_4119_A10F_7A48CA3FD6E5" name="nombre" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="44" ea_guid="{FCB03521-11CC-4119-A10F-7A48CA3FD6E5}"/>
						<properties type="string" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="1"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_E0933A2C_6750_4f48_9824_BB98C009AC09" name="capacidad" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="45" ea_guid="{E0933A2C-6750-4f48-9824-BB98C009AC09}"/>
						<properties type="int" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="2"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_C42593A2_8952_4831_B9BF_FEF88DC01761" name="bloque" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="46" ea_guid="{C42593A2-8952-4831-B9BF-FEF88DC01761}"/>
						<properties type="string" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="3"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
				</attributes>
				<links>
					<Association xmi:id="EAID_926DEF20_8378_43bd_B04C_E604C4642425" start="EAID_D61CA6B6_D2CB_40cb_BF5C_E19BD21542A0" end="EAID_A4682377_D439_4256_B146_05374A8041F8"/>
				</links>
			</element>
			<element xmi:idref="EAID_C653E036_9DFB_4e15_9B7B_DECB00FAA79F" xmi:type="uml:Class" name="Calificacion" scope="public">
				<model package="EAPK_B45D3D37_ADD5_4f7f_AD77_690F6097B920" tpos="0" ea_localid="21" ea_eleType="element"/>
				<properties isSpecification="false" sType="Class" nType="0" scope="public" isRoot="false" isLeaf="false" isAbstract="false" isActive="false"/>
				<project author="braya" version="1.0" phase="1.0" created="2026-09-03 00:33:20" modified="2026-09-03 00:33:23" complexity="1" status="Proposed"/>
				<code gentype="Java"/>
				<style appearance="BackColor=-1;BorderColor=-1;BorderWidth=-1;FontColor=-1;VSwimLanes=1;HSwimLanes=1;BorderStyle=0;"/>
				<tags/>
				<xrefs/>
				<extendedProperties tagged="0" package_name="Practica 1"/>
				<attributes>
					<attribute xmi:idref="EAID_D5C96E3D_DC41_4a10_AB8A_7D7CB948A90C" name="idCalificacion" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="56" ea_guid="{D5C96E3D-DC41-4a10-AB8A-7D7CB948A90C}"/>
						<properties type="int" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="0"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_F033616A_31B7_48b7_A57F_02DB312BC8D4" name="nombre" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="57" ea_guid="{F033616A-31B7-48b7-A57F-02DB312BC8D4}"/>
						<properties type="string" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="1"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_0367D6A8_6439_455a_B336_ED45D6B805AF" name="porcentaje" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="58" ea_guid="{0367D6A8-6439-455a-B336-ED45D6B805AF}"/>
						<properties type="decimal" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="2"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_4693B204_E0C5_49c3_8996_D61073B27B88" name="nota" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="59" ea_guid="{4693B204-E0C5-49c3-8996-D61073B27B88}"/>
						<properties type="decimal" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="3"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
				</attributes>
				<links>
					<Aggregation xmi:id="EAID_F26F79AD_B5C1_4bcf_BC4D_7FDFBEBF9DF2" start="EAID_C653E036_9DFB_4e15_9B7B_DECB00FAA79F" end="EAID_7FEBB9BF_1F3F_4e76_9857_5F07C7628A03"/>
				</links>
			</element>
			<element xmi:idref="EAID_612CBEF6_C55B_415c_B03A_34446EF1955D" xmi:type="uml:Class" name="CarnetEstudiante" scope="public">
				<model package="EAPK_B45D3D37_ADD5_4f7f_AD77_690F6097B920" tpos="0" ea_localid="19" ea_eleType="element"/>
				<properties isSpecification="false" sType="Class" nType="0" scope="public" isRoot="false" isLeaf="false" isAbstract="false" isActive="false"/>
				<project author="braya" version="1.0" phase="1.0" created="2026-09-03 00:33:06" modified="2026-09-03 00:33:11" complexity="1" status="Proposed"/>
				<code gentype="Java"/>
				<style appearance="BackColor=-1;BorderColor=-1;BorderWidth=-1;FontColor=-1;VSwimLanes=1;HSwimLanes=1;BorderStyle=0;"/>
				<tags/>
				<xrefs/>
				<extendedProperties tagged="0" package_name="Practica 1"/>
				<attributes>
					<attribute xmi:idref="EAID_3C8D6AAD_3F18_4efc_8D2E_3337CA94C6B8" name="idCarnet" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="39" ea_guid="{3C8D6AAD-3F18-4efc-8D2E-3337CA94C6B8}"/>
						<properties type="int" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="0"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_BF542E00_8D63_470d_8005_443B2D37013F" name="codigo" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="40" ea_guid="{BF542E00-8D63-470d-8005-443B2D37013F}"/>
						<properties type="string" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="1"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_61B79204_2550_43ae_BBBE_AC20C4D84D87" name="fechaEmision" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="41" ea_guid="{61B79204-2550-43ae-BBBE-AC20C4D84D87}"/>
						<properties type="date" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="2"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_2F133C78_4E48_477b_98A7_863FB195A59A" name="fechaVencimiento" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="42" ea_guid="{2F133C78-4E48-477b-98A7-863FB195A59A}"/>
						<properties type="date" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="3"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
				</attributes>
				<links>
					<Association xmi:id="EAID_27E33190_8A7C_4514_9D06_98BECC31B712" start="EAID_413197F1_1E7D_4a71_A961_218ED07519D2" end="EAID_612CBEF6_C55B_415c_B03A_34446EF1955D"/>
				</links>
			</element>
			<element xmi:idref="EAID_F47E3563_90EE_48ad_AE30_5488758D7710" xmi:type="uml:Class" name="Carrera" scope="public">
				<model package="EAPK_B45D3D37_ADD5_4f7f_AD77_690F6097B920" tpos="0" ea_localid="14" ea_eleType="element"/>
				<properties isSpecification="false" sType="Class" nType="0" scope="public" isRoot="false" isLeaf="false" isAbstract="false" isActive="false"/>
				<project author="braya" version="1.0" phase="1.0" created="2026-09-03 00:32:36" modified="2026-09-03 00:32:45" complexity="1" status="Proposed"/>
				<code gentype="Java"/>
				<style appearance="BackColor=-1;BorderColor=-1;BorderWidth=-1;FontColor=-1;VSwimLanes=1;HSwimLanes=1;BorderStyle=0;"/>
				<tags/>
				<xrefs/>
				<extendedProperties tagged="0" package_name="Practica 1"/>
				<attributes>
					<attribute xmi:idref="EAID_4AA5E0F9_665D_4c5a_A8CE_53DF8787E366" name="idCarrera" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="31" ea_guid="{4AA5E0F9-665D-4c5a-A8CE-53DF8787E366}"/>
						<properties type="int" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="0"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_F3ABD9EA_4B24_4c2a_8136_BAE032110094" name="nombre" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="32" ea_guid="{F3ABD9EA-4B24-4c2a-8136-BAE032110094}"/>
						<properties type="string" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="1"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_4BDC8A51_8A36_436c_9E4F_96C74C313616" name="duracionSemestre" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="33" ea_guid="{4BDC8A51-8A36-436c-9E4F-96C74C313616}"/>
						<properties type="int" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="2"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
				</attributes>
				<links>
					<Association xmi:id="EAID_49164E2F_13AE_4bd1_B088_6C2F1559588B" start="EAID_F47E3563_90EE_48ad_AE30_5488758D7710" end="EAID_21D38904_C859_44ff_A301_944416EF1EB8"/>
					<Association xmi:id="EAID_8A209896_3D45_47de_800C_92CB3BC026D8" start="EAID_083D0DB1_BCBE_4a1c_A8A3_FA0146133CA6" end="EAID_F47E3563_90EE_48ad_AE30_5488758D7710"/>
				</links>
			</element>
			<element xmi:idref="EAID_66F5597A_0FC0_4ab9_A176_D1F05B7057C0" xmi:type="uml:Class" name="Class1" scope="public">
				<model package="EAPK_B45D3D37_ADD5_4f7f_AD77_690F6097B920" tpos="0" ea_localid="22" ea_eleType="element"/>
				<properties isSpecification="false" sType="Class" nType="0" scope="public" isRoot="false" isLeaf="false" isAbstract="false" isActive="false"/>
				<project author="braya" version="1.0" phase="1.0" created="2026-09-03 00:49:19" modified="2026-09-03 00:49:19" complexity="1" status="Proposed"/>
				<code gentype="Java"/>
				<style appearance="BackColor=-1;BorderColor=-1;BorderWidth=-1;FontColor=-1;VSwimLanes=1;HSwimLanes=1;BorderStyle=0;"/>
				<tags/>
				<xrefs/>
				<extendedProperties tagged="0" package_name="Practica 1"/>
			</element>
			<element xmi:idref="EAID_A4682377_D439_4256_B146_05374A8041F8" xmi:type="uml:Class" name="Curso" scope="public">
				<model package="EAPK_B45D3D37_ADD5_4f7f_AD77_690F6097B920" tpos="0" ea_localid="16" ea_eleType="element"/>
				<properties isSpecification="false" sType="Class" nType="0" scope="public" isRoot="false" isLeaf="false" isAbstract="false" isActive="false"/>
				<project author="braya" version="1.0" phase="1.0" created="2026-09-03 00:32:53" modified="2026-09-03 00:32:56" complexity="1" status="Proposed"/>
				<code gentype="Java"/>
				<style appearance="BackColor=-1;BorderColor=-1;BorderWidth=-1;FontColor=-1;VSwimLanes=1;HSwimLanes=1;BorderStyle=0;"/>
				<tags/>
				<xrefs/>
				<extendedProperties tagged="0" package_name="Practica 1"/>
				<attributes>
					<attribute xmi:idref="EAID_BC84A785_34B9_4e4c_89FB_52DEBE8B270B" name="idCurso" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="47" ea_guid="{BC84A785-34B9-4e4c-89FB-52DEBE8B270B}"/>
						<properties type="int" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="0"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_37C0D3C1_284D_41e4_89A5_FD473747E196" name="grupo" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="48" ea_guid="{37C0D3C1-284D-41e4-89A5-FD473747E196}"/>
						<properties type="string" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="1"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_B9D1498F_9E6E_47c3_BA62_2B24DCF8C30F" name="gestion" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="49" ea_guid="{B9D1498F-9E6E-47c3-BA62-2B24DCF8C30F}"/>
						<properties type="int" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="2"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_C1308DC7_F4D9_4d19_A823_7DD6797AA6CF" name="periodo" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="50" ea_guid="{C1308DC7-F4D9-4d19-A823-7DD6797AA6CF}"/>
						<properties type="int" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="3"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_41C57B56_5892_4f28_9D8B_B8059E5463DC" name="horario" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="51" ea_guid="{41C57B56-5892-4f28-9D8B-B8059E5463DC}"/>
						<properties type="string" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="4"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
				</attributes>
				<links>
					<Association xmi:id="EAID_926DEF20_8378_43bd_B04C_E604C4642425" start="EAID_D61CA6B6_D2CB_40cb_BF5C_E19BD21542A0" end="EAID_A4682377_D439_4256_B146_05374A8041F8"/>
					<Association xmi:id="EAID_D2A2071B_E9E3_40f3_881D_29CDF8CE57D4" start="EAID_413197F1_1E7D_4a71_A961_218ED07519D2" end="EAID_A4682377_D439_4256_B146_05374A8041F8"/>
					<Association xmi:id="EAID_EA8465DB_DD4A_4733_8533_8E822E102842" start="EAID_21D38904_C859_44ff_A301_944416EF1EB8" end="EAID_A4682377_D439_4256_B146_05374A8041F8"/>
					<Association xmi:id="EAID_F9D134A4_C537_4bc8_9481_FA8D8099EA95" start="EAID_D8D61BB2_E1C9_4b86_8443_B5362CD5B82D" end="EAID_A4682377_D439_4256_B146_05374A8041F8"/>
				</links>
			</element>
			<element xmi:idref="EAID_083D0DB1_BCBE_4a1c_A8A3_FA0146133CA6" xmi:type="uml:Class" name="Departamento" scope="public">
				<model package="EAPK_B45D3D37_ADD5_4f7f_AD77_690F6097B920" tpos="0" ea_localid="13" ea_eleType="element"/>
				<properties isSpecification="false" sType="Class" nType="0" scope="public" isRoot="false" isLeaf="false" isAbstract="false" isActive="false"/>
				<project author="braya" version="1.0" phase="1.0" created="2026-09-03 00:32:29" modified="2026-09-03 00:32:34" complexity="1" status="Proposed"/>
				<code gentype="Java"/>
				<style appearance="BackColor=-1;BorderColor=-1;BorderWidth=-1;FontColor=-1;VSwimLanes=1;HSwimLanes=1;BorderStyle=0;"/>
				<tags/>
				<xrefs/>
				<extendedProperties tagged="0" package_name="Practica 1"/>
				<attributes>
					<attribute xmi:idref="EAID_E81037EC_DDBE_40c1_AE6D_FB8AC9221A2D" name="idDepartamento" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="28" ea_guid="{E81037EC-DDBE-40c1-AE6D-FB8AC9221A2D}"/>
						<properties type="int" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="0"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_3FD94692_783F_4158_8E7F_EBCE706D6AA0" name="nombre" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="29" ea_guid="{3FD94692-783F-4158-8E7F-EBCE706D6AA0}"/>
						<properties type="string" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="1"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_CC3F313D_C0BA_41a0_9A95_096F9354F853" name="ubicacion" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="30" ea_guid="{CC3F313D-C0BA-41a0-9A95-096F9354F853}"/>
						<properties type="string" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="2"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
				</attributes>
				<links>
					<Association xmi:id="EAID_8A209896_3D45_47de_800C_92CB3BC026D8" start="EAID_083D0DB1_BCBE_4a1c_A8A3_FA0146133CA6" end="EAID_F47E3563_90EE_48ad_AE30_5488758D7710"/>
					<Aggregation xmi:id="EAID_D91235B1_A372_4535_BAE5_456B6E7D1F3F" start="EAID_D8D61BB2_E1C9_4b86_8443_B5362CD5B82D" end="EAID_083D0DB1_BCBE_4a1c_A8A3_FA0146133CA6"/>
				</links>
			</element>
			<element xmi:idref="EAID_D8D61BB2_E1C9_4b86_8443_B5362CD5B82D" xmi:type="uml:Class" name="Docente" scope="public">
				<model package="EAPK_B45D3D37_ADD5_4f7f_AD77_690F6097B920" tpos="0" ea_localid="12" ea_eleType="element"/>
				<properties isSpecification="false" sType="Class" nType="0" scope="public" isRoot="false" isLeaf="false" isAbstract="false" isActive="false"/>
				<project author="braya" version="1.0" phase="1.0" created="2026-09-03 00:32:19" modified="2026-09-03 00:32:21" complexity="1" status="Proposed"/>
				<code gentype="Java"/>
				<style appearance="BackColor=-1;BorderColor=-1;BorderWidth=-1;FontColor=-1;VSwimLanes=1;HSwimLanes=1;BorderStyle=0;"/>
				<tags/>
				<xrefs/>
				<extendedProperties tagged="0" package_name="Practica 1"/>
				<attributes>
					<attribute xmi:idref="EAID_268C4426_C0B4_4aa8_8897_380372F4013C" name="idPersona" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="24" ea_guid="{268C4426-C0B4-4aa8-8897-380372F4013C}"/>
						<properties type="int" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="0"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_89FCFDD4_F753_4c60_BA0C_EE22CAAE2D2B" name="codigoDocente" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="25" ea_guid="{89FCFDD4-F753-4c60-BA0C-EE22CAAE2D2B}"/>
						<properties type="string" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="1"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_3237C58C_15D7_4e03_9EB0_2A87D240A10E" name="especialidad" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="26" ea_guid="{3237C58C-15D7-4e03-9EB0-2A87D240A10E}"/>
						<properties type="string" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="2"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_73538FC6_57D5_4d2b_BC24_0FF6F3C07505" name="fechaContratacion" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="27" ea_guid="{73538FC6-57D5-4d2b-BC24-0FF6F3C07505}"/>
						<properties type="date" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="3"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
				</attributes>
				<links>
					<Generalization xmi:id="EAID_12B79008_50CE_4e02_B54F_F66AB79E7C35" start="EAID_D8D61BB2_E1C9_4b86_8443_B5362CD5B82D" end="EAID_5BDC6444_175B_4e5c_8B60_8EC1CD658997"/>
					<Aggregation xmi:id="EAID_D91235B1_A372_4535_BAE5_456B6E7D1F3F" start="EAID_D8D61BB2_E1C9_4b86_8443_B5362CD5B82D" end="EAID_083D0DB1_BCBE_4a1c_A8A3_FA0146133CA6"/>
					<Association xmi:id="EAID_F9D134A4_C537_4bc8_9481_FA8D8099EA95" start="EAID_D8D61BB2_E1C9_4b86_8443_B5362CD5B82D" end="EAID_A4682377_D439_4256_B146_05374A8041F8"/>
				</links>
			</element>
			<element xmi:idref="EAID_413197F1_1E7D_4a71_A961_218ED07519D2" xmi:type="uml:Class" name="Estudiante" scope="public">
				<model package="EAPK_B45D3D37_ADD5_4f7f_AD77_690F6097B920" tpos="0" ea_localid="11" ea_eleType="element"/>
				<properties isSpecification="false" sType="Class" nType="0" scope="public" isRoot="false" isLeaf="false" isAbstract="false" isActive="false"/>
				<project author="braya" version="1.0" phase="1.0" created="2026-09-03 00:32:12" modified="2026-09-03 00:32:17" complexity="1" status="Proposed"/>
				<code gentype="Java"/>
				<style appearance="BackColor=-1;BorderColor=-1;BorderWidth=-1;FontColor=-1;VSwimLanes=1;HSwimLanes=1;BorderStyle=0;"/>
				<tags/>
				<xrefs/>
				<extendedProperties tagged="0" package_name="Practica 1"/>
				<attributes>
					<attribute xmi:idref="EAID_65DFE0C3_3560_47c9_BCBB_0898CE5251FE" name="idPersona" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="20" ea_guid="{65DFE0C3-3560-47c9-BCBB-0898CE5251FE}"/>
						<properties type="int" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="0"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_F0CCB5AE_F992_4c52_ADAD_D4C5DF86A705" name="registro" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="21" ea_guid="{F0CCB5AE-F992-4c52-ADAD-D4C5DF86A705}"/>
						<properties type="string" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="1"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_B04B5EF9_6E8D_4d77_AE06_7695A62894B1" name="fechaIngreso" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="22" ea_guid="{B04B5EF9-6E8D-4d77-AE06-7695A62894B1}"/>
						<properties type="date" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="2"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_A11AB739_6904_46ca_A65F_235983F6B0C3" name="estado" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="23" ea_guid="{A11AB739-6904-46ca-A65F-235983F6B0C3}"/>
						<properties type="string" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="3"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
				</attributes>
				<links>
					<Association xmi:id="EAID_27E33190_8A7C_4514_9D06_98BECC31B712" start="EAID_413197F1_1E7D_4a71_A961_218ED07519D2" end="EAID_612CBEF6_C55B_415c_B03A_34446EF1955D"/>
					<Association xmi:id="EAID_D2A2071B_E9E3_40f3_881D_29CDF8CE57D4" start="EAID_413197F1_1E7D_4a71_A961_218ED07519D2" end="EAID_A4682377_D439_4256_B146_05374A8041F8"/>
					<Generalization xmi:id="EAID_FD88C7CB_4DD9_4e23_8939_C1A22EACCA94" start="EAID_413197F1_1E7D_4a71_A961_218ED07519D2" end="EAID_5BDC6444_175B_4e5c_8B60_8EC1CD658997"/>
				</links>
			</element>
			<element xmi:idref="EAID_D6C5A3B9_FD4E_4dc0_BD66_E66E7759C85E" xmi:type="uml:Class" name="Inscripcion" scope="public">
				<model package="EAPK_B45D3D37_ADD5_4f7f_AD77_690F6097B920" tpos="0" ea_localid="17" ea_eleType="element"/>
				<properties isSpecification="false" sType="Class" nType="0" scope="public" isRoot="false" isLeaf="false" isAbstract="false" isActive="false"/>
				<project author="braya" version="1.0" phase="1.0" created="2026-09-03 00:32:57" modified="2026-09-03 00:33:02" complexity="1" status="Proposed"/>
				<code gentype="Java"/>
				<style appearance="BackColor=-1;BorderColor=-1;BorderWidth=-1;FontColor=-1;VSwimLanes=1;HSwimLanes=1;BorderStyle=0;"/>
				<tags/>
				<xrefs/>
				<extendedProperties tagged="0" package_name="Practica 1"/>
			</element>
			<element xmi:idref="EAID_7FEBB9BF_1F3F_4e76_9857_5F07C7628A03" xmi:type="uml:Class" name="Inscripcion" scope="public">
				<model package="EAPK_B45D3D37_ADD5_4f7f_AD77_690F6097B920" tpos="0" ea_localid="25" ea_eleType="element"/>
				<properties isSpecification="false" sType="Class" nType="17" scope="public" isRoot="false" isLeaf="false" isAbstract="false" isActive="false"/>
				<project author="braya" version="1.0" phase="1.0" created="2026-09-03 00:49:30" modified="2026-09-03 00:50:43" complexity="1" status="Proposed"/>
				<code product_name="Java" gentype="Java"/>
				<style appearance="BackColor=-1;BorderColor=-1;BorderWidth=-1;FontColor=-1;VSwimLanes=1;HSwimLanes=1;BorderStyle=0;"/>
				<tags/>
				<xrefs/>
				<extendedProperties tagged="0" package_name="Practica 1" conID="EAID_50AF9D5A_0903_49f5_8602_BA5820547AD6"/>
				<attributes>
					<attribute xmi:idref="EAID_488E07EF_1249_485c_A74D_08325F9A8FF0" name="fecha" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="52" ea_guid="{488E07EF-1249-485c-A74D-08325F9A8FF0}"/>
						<properties type="date" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="0"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_F1FC2AAE_A0AC_481a_81F8_01AB9B5E09C7" name="estado" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="53" ea_guid="{F1FC2AAE-A0AC-481a-81F8-01AB9B5E09C7}"/>
						<properties type="string" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="1"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_0D0609BA_F741_4031_815D_3194DF5D683B" name="notaFinal" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="54" ea_guid="{0D0609BA-F741-4031-815D-3194DF5D683B}"/>
						<properties type="decimal" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="2"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_5E275F90_929B_46fd_8AF1_F0CA3584514F" name="idInscripcion" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="55" ea_guid="{5E275F90-929B-46fd-8AF1-F0CA3584514F}"/>
						<properties type="int" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="3"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
				</attributes>
				<links>
					<Aggregation xmi:id="EAID_F26F79AD_B5C1_4bcf_BC4D_7FDFBEBF9DF2" start="EAID_C653E036_9DFB_4e15_9B7B_DECB00FAA79F" end="EAID_7FEBB9BF_1F3F_4e76_9857_5F07C7628A03"/>
				</links>
			</element>
			<element xmi:idref="EAID_21D38904_C859_44ff_A301_944416EF1EB8" xmi:type="uml:Class" name="Materia" scope="public">
				<model package="EAPK_B45D3D37_ADD5_4f7f_AD77_690F6097B920" tpos="0" ea_localid="15" ea_eleType="element"/>
				<properties isSpecification="false" sType="Class" nType="0" scope="public" isRoot="false" isLeaf="false" isAbstract="false" isActive="false"/>
				<project author="braya" version="1.0" phase="1.0" created="2026-09-03 00:32:47" modified="2026-09-03 00:32:49" complexity="1" status="Proposed"/>
				<code gentype="Java"/>
				<style appearance="BackColor=-1;BorderColor=-1;BorderWidth=-1;FontColor=-1;VSwimLanes=1;HSwimLanes=1;BorderStyle=0;"/>
				<tags/>
				<xrefs/>
				<extendedProperties tagged="0" package_name="Practica 1"/>
				<attributes>
					<attribute xmi:idref="EAID_0707D46D_DC93_4486_BCE9_A5C9CB13DE34" name="idMateria" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="34" ea_guid="{0707D46D-DC93-4486-BCE9-A5C9CB13DE34}"/>
						<properties type="int" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="0"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_A2BF5002_6D10_49c7_9EA3_AD27C949F5B9" name="sigla" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="35" ea_guid="{A2BF5002-6D10-49c7-9EA3-AD27C949F5B9}"/>
						<properties type="string" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="1"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_BA536EE2_3A3D_4a20_99ED_5DDF6C8A461B" name="nombre" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="36" ea_guid="{BA536EE2-3A3D-4a20-99ED-5DDF6C8A461B}"/>
						<properties type="string" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="2"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_1714A655_9A3B_4b81_9068_4A6FE73A2F20" name="creditos" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="37" ea_guid="{1714A655-9A3B-4b81-9068-4A6FE73A2F20}"/>
						<properties type="int" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="3"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_44186335_A56F_48a8_9984_2544FCEF0327" name="semestre" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="38" ea_guid="{44186335-A56F-48a8-9984-2544FCEF0327}"/>
						<properties type="int" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="4"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
				</attributes>
				<links>
					<Association xmi:id="EAID_A7075F92_B883_4b58_A303_287A45EF47B7" start="EAID_21D38904_C859_44ff_A301_944416EF1EB8" end="EAID_21D38904_C859_44ff_A301_944416EF1EB8"/>
					<Association xmi:id="EAID_EA8465DB_DD4A_4733_8533_8E822E102842" start="EAID_21D38904_C859_44ff_A301_944416EF1EB8" end="EAID_A4682377_D439_4256_B146_05374A8041F8"/>
					<Association xmi:id="EAID_49164E2F_13AE_4bd1_B088_6C2F1559588B" start="EAID_F47E3563_90EE_48ad_AE30_5488758D7710" end="EAID_21D38904_C859_44ff_A301_944416EF1EB8"/>
					<Association xmi:id="EAID_A7075F92_B883_4b58_A303_287A45EF47B7" start="EAID_21D38904_C859_44ff_A301_944416EF1EB8" end="EAID_21D38904_C859_44ff_A301_944416EF1EB8"/>
				</links>
			</element>
			<element xmi:idref="EAID_5BDC6444_175B_4e5c_8B60_8EC1CD658997" xmi:type="uml:Class" name="Persona" scope="public">
				<model package="EAPK_B45D3D37_ADD5_4f7f_AD77_690F6097B920" tpos="0" ea_localid="10" ea_eleType="element"/>
				<properties isSpecification="false" sType="Class" nType="0" scope="public" isRoot="false" isLeaf="false" isAbstract="false" isActive="false"/>
				<project author="braya" version="1.0" phase="1.0" created="2026-09-03 00:24:54" modified="2026-09-03 00:24:58" complexity="1" status="Proposed"/>
				<code gentype="Java"/>
				<style appearance="BackColor=-1;BorderColor=-1;BorderWidth=-1;FontColor=-1;VSwimLanes=1;HSwimLanes=1;BorderStyle=0;"/>
				<tags/>
				<xrefs/>
				<extendedProperties tagged="0" package_name="Practica 1"/>
				<attributes>
					<attribute xmi:idref="EAID_EFED3636_22AB_415d_A82A_F1F7ED4AA50B" name="idPersona" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="13" ea_guid="{EFED3636-22AB-415d-A82A-F1F7ED4AA50B}"/>
						<properties type="int" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="0"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_3E833D20_3FFF_43c2_8EC3_88B36E40FA36" name="ci" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="14" ea_guid="{3E833D20-3FFF-43c2-8EC3-88B36E40FA36}"/>
						<properties type="string" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="1"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_556775A9_E390_4477_9CFC_575383B541C3" name="nombre" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="15" ea_guid="{556775A9-E390-4477-9CFC-575383B541C3}"/>
						<properties type="string" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="2"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_7E04437C_5D23_45fb_80AE_91E668087854" name="apellido" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="16" ea_guid="{7E04437C-5D23-45fb-80AE-91E668087854}"/>
						<properties type="string" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="3"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_0C5EE71E_3CAC_4d80_9747_808C6F33B28C" name="correo" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="17" ea_guid="{0C5EE71E-3CAC-4d80-9747-808C6F33B28C}"/>
						<properties type="string" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="4"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_3AC9335C_F48C_420c_8755_D22AFC4DF0C2" name="telefono" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="18" ea_guid="{3AC9335C-F48C-420c-8755-D22AFC4DF0C2}"/>
						<properties type="string" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="5"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
					<attribute xmi:idref="EAID_0F851884_D986_4d2a_8C27_3A4F9A765A34" name="fechaNacimiento" scope="Private">
						<initial/>
						<documentation/>
						<model ea_localid="19" ea_guid="{0F851884-D986-4d2a-8C27-3A4F9A765A34}"/>
						<properties type="date" collection="false" static="0" duplicates="0" changeability="changeable"/>
						<coords ordered="0"/>
						<containment containment="Not Specified" position="6"/>
						<stereotype/>
						<bounds lower="1" upper="1"/>
						<options/>
						<style/>
						<styleex value="volatile=0;"/>
						<tags/>
						<xrefs/>
					</attribute>
				</attributes>
				<links>
					<Generalization xmi:id="EAID_12B79008_50CE_4e02_B54F_F66AB79E7C35" start="EAID_D8D61BB2_E1C9_4b86_8443_B5362CD5B82D" end="EAID_5BDC6444_175B_4e5c_8B60_8EC1CD658997"/>
					<Generalization xmi:id="EAID_FD88C7CB_4DD9_4e23_8939_C1A22EACCA94" start="EAID_413197F1_1E7D_4a71_A961_218ED07519D2" end="EAID_5BDC6444_175B_4e5c_8B60_8EC1CD658997"/>
				</links>
			</element>
			<element xmi:idref="EAID_CF7609F1_C991_4503_A15F_B43FBCD34315" xmi:type="uml:Class" name="PrerequisitoMateria" scope="public">
				<model package="EAPK_B45D3D37_ADD5_4f7f_AD77_690F6097B920" tpos="0" ea_localid="20" ea_eleType="element"/>
				<properties isSpecification="false" sType="Class" nType="0" scope="public" isRoot="false" isLeaf="false" isAbstract="false" isActive="false"/>
				<project author="braya" version="1.0" phase="1.0" created="2026-09-03 00:33:12" modified="2026-09-03 00:33:19" complexity="1" status="Proposed"/>
				<code gentype="Java"/>
				<style appearance="BackColor=-1;BorderColor=-1;BorderWidth=-1;FontColor=-1;VSwimLanes=1;HSwimLanes=1;BorderStyle=0;"/>
				<tags/>
				<xrefs/>
				<extendedProperties tagged="0" package_name="Practica 1"/>
			</element>
			<element xmi:idref="EAID_3B238C8F_CEC1_4c79_B386_CDF3B1E95712" xmi:type="uml:Association" scope="public">
				<model package="EAPK_B45D3D37_ADD5_4f7f_AD77_690F6097B920" tpos="0" ea_localid="26" ea_eleType="element"/>
				<properties isSpecification="false" sType="Association" nType="0" scope="public" isRoot="false" isLeaf="false" isAbstract="false"/>
				<project author="braya" version="1.0" phase="1.0" created="2026-09-03 00:54:40" modified="2026-09-03 00:54:40" complexity="1" status="Proposed"/>
				<code gentype="&lt;none&gt;"/>
				<style appearance="BackColor=-1;BorderColor=-1;BorderWidth=-1;FontColor=-1;VSwimLanes=1;HSwimLanes=1;BorderStyle=0;"/>
				<tags/>
				<xrefs/>
				<extendedProperties tagged="0" package_name="Practica 1"/>
			</element>
			<element xmi:idref="EAID_62EE9303_7A72_4331_AFA9_0ABC599D8749" xmi:type="uml:ProxyConnector" name="ProxyConnector" scope="public" classifier="EAID_D2A2071B_E9E3_40f3_881D_29CDF8CE57D4">
				<model package="EAPK_B45D3D37_ADD5_4f7f_AD77_690F6097B920" tpos="0" ea_localid="23" ea_eleType="element"/>
				<properties isSpecification="false" sType="ProxyConnector" nType="0" scope="public" isRoot="false" isLeaf="false" isAbstract="false"/>
				<project author="braya" version="1.0" phase="1.0" created="2026-09-03 00:49:30" modified="2026-09-03 00:49:30" complexity="1" status="Proposed"/>
				<code gentype="Java"/>
				<style appearance="BackColor=-1;BorderColor=-1;BorderWidth=-1;FontColor=-1;VSwimLanes=1;HSwimLanes=1;BorderStyle=0;"/>
				<tags/>
				<xrefs/>
				<extendedProperties tagged="0" package_name="Practica 1"/>
				<links>
					<Association xmi:id="EAID_50AF9D5A_0903_49f5_8602_BA5820547AD6" start="EAID_62EE9303_7A72_4331_AFA9_0ABC599D8749" end="EAID_A38849F1_506B_4769_9F51_47AC9B014704"/>
				</links>
			</element>
			<element xmi:idref="EAID_A38849F1_506B_4769_9F51_47AC9B014704" xmi:type="uml:ProxyConnector" name="ProxyConnector" scope="public" classifier="EAID_D2A2071B_E9E3_40f3_881D_29CDF8CE57D4">
				<model package="EAPK_B45D3D37_ADD5_4f7f_AD77_690F6097B920" tpos="0" ea_localid="24" ea_eleType="element"/>
				<properties isSpecification="false" sType="ProxyConnector" nType="0" scope="public" isRoot="false" isLeaf="false" isAbstract="false"/>
				<project author="braya" version="1.0" phase="1.0" created="2026-09-03 00:49:30" modified="2026-09-03 00:49:30" complexity="1" status="Proposed"/>
				<code gentype="Java"/>
				<style appearance="BackColor=-1;BorderColor=-1;BorderWidth=-1;FontColor=-1;VSwimLanes=1;HSwimLanes=1;BorderStyle=0;"/>
				<tags/>
				<xrefs/>
				<extendedProperties tagged="0" package_name="Practica 1"/>
				<links>
					<Association xmi:id="EAID_50AF9D5A_0903_49f5_8602_BA5820547AD6" start="EAID_62EE9303_7A72_4331_AFA9_0ABC599D8749" end="EAID_A38849F1_506B_4769_9F51_47AC9B014704"/>
				</links>
			</element>
		</elements>
		<connectors>
			<connector xmi:idref="EAID_926DEF20_8378_43bd_B04C_E604C4642425">
				<source xmi:idref="EAID_D61CA6B6_D2CB_40cb_BF5C_E19BD21542A0">
					<model ea_localid="18" type="Class" name="Aula"/>
					<role visibility="Public" targetScope="instance"/>
					<type multiplicity="1" aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="false"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;Owned=0;Navigable=Unspecified;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</source>
				<target xmi:idref="EAID_A4682377_D439_4256_B146_05374A8041F8">
					<model ea_localid="16" type="Class" name="Curso"/>
					<role visibility="Public" targetScope="instance"/>
					<type multiplicity="0..*" aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="false"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;Owned=0;Navigable=Unspecified;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</target>
				<model ea_localid="12"/>
				<properties ea_type="Association" direction="Unspecified"/>
				<modifiers isRoot="false" isLeaf="false"/>
				<parameterSubstitutions/>
				<documentation/>
				<appearance linemode="3" linecolor="-1" linewidth="0" seqno="0" headStyle="0" lineStyle="0"/>
				<labels lb="1" rb="0..*"/>
				<extendedProperties virtualInheritance="0"/>
				<style/>
				<xrefs/>
				<tags/>
			</connector>
			<connector xmi:idref="EAID_F26F79AD_B5C1_4bcf_BC4D_7FDFBEBF9DF2">
				<source xmi:idref="EAID_C653E036_9DFB_4e15_9B7B_DECB00FAA79F">
					<model ea_localid="21" type="Class" name="Calificacion"/>
					<role visibility="Public" targetScope="instance"/>
					<type multiplicity="0..*" aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="false"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;Owned=0;Navigable=Navigable;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</source>
				<target xmi:idref="EAID_7FEBB9BF_1F3F_4e76_9857_5F07C7628A03">
					<model ea_localid="25" type="Class" name="Inscripcion"/>
					<role visibility="Public" targetScope="instance"/>
					<type multiplicity="1" aggregation="composite" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="true"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;Owned=0;Navigable=Unspecified;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</target>
				<model ea_localid="20"/>
				<properties ea_type="Aggregation" subtype="Strong" direction="Source -&gt; Destination"/>
				<modifiers isRoot="false" isLeaf="false"/>
				<documentation/>
				<appearance linemode="3" linecolor="-1" linewidth="0" seqno="0" headStyle="0" lineStyle="0"/>
				<labels lb="0..*" rb="1"/>
				<extendedProperties virtualInheritance="0"/>
				<style/>
				<xrefs/>
				<tags/>
			</connector>
			<connector xmi:idref="EAID_27E33190_8A7C_4514_9D06_98BECC31B712">
				<source xmi:idref="EAID_413197F1_1E7D_4a71_A961_218ED07519D2">
					<model ea_localid="11" type="Class" name="Estudiante"/>
					<role visibility="Public" targetScope="instance"/>
					<type multiplicity="1" aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="false"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;Owned=0;Navigable=Unspecified;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</source>
				<target xmi:idref="EAID_612CBEF6_C55B_415c_B03A_34446EF1955D">
					<model ea_localid="19" type="Class" name="CarnetEstudiante"/>
					<role visibility="Public" targetScope="instance"/>
					<type multiplicity="1" aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="false"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;Owned=0;Navigable=Unspecified;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</target>
				<model ea_localid="11"/>
				<properties ea_type="Association" direction="Unspecified"/>
				<modifiers isRoot="false" isLeaf="false"/>
				<parameterSubstitutions/>
				<documentation/>
				<appearance linemode="3" linecolor="-1" linewidth="0" seqno="0" headStyle="0" lineStyle="0"/>
				<labels lb="1" rb="1"/>
				<extendedProperties virtualInheritance="0"/>
				<style/>
				<xrefs/>
				<tags/>
			</connector>
			<connector xmi:idref="EAID_49164E2F_13AE_4bd1_B088_6C2F1559588B">
				<source xmi:idref="EAID_F47E3563_90EE_48ad_AE30_5488758D7710">
					<model ea_localid="14" type="Class" name="Carrera"/>
					<role visibility="Public" targetScope="instance"/>
					<type multiplicity="1" aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="false"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;Owned=0;Navigable=Unspecified;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</source>
				<target xmi:idref="EAID_21D38904_C859_44ff_A301_944416EF1EB8">
					<model ea_localid="15" type="Class" name="Materia"/>
					<role visibility="Public" targetScope="instance"/>
					<type multiplicity="1..*" aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="false"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;Owned=0;Navigable=Unspecified;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</target>
				<model ea_localid="10"/>
				<properties ea_type="Association" direction="Unspecified"/>
				<modifiers isRoot="false" isLeaf="false"/>
				<parameterSubstitutions/>
				<documentation/>
				<appearance linemode="3" linecolor="-1" linewidth="0" seqno="0" headStyle="0" lineStyle="0"/>
				<labels lb="1" rb="1..*"/>
				<extendedProperties virtualInheritance="0"/>
				<style/>
				<xrefs/>
				<tags/>
			</connector>
			<connector xmi:idref="EAID_8A209896_3D45_47de_800C_92CB3BC026D8">
				<source xmi:idref="EAID_083D0DB1_BCBE_4a1c_A8A3_FA0146133CA6">
					<model ea_localid="13" type="Class" name="Departamento"/>
					<role visibility="Public" targetScope="instance"/>
					<type multiplicity="1" aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="false"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;Owned=0;Navigable=Unspecified;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</source>
				<target xmi:idref="EAID_F47E3563_90EE_48ad_AE30_5488758D7710">
					<model ea_localid="14" type="Class" name="Carrera"/>
					<role visibility="Public" targetScope="instance"/>
					<type multiplicity="0..*" aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="false"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;Owned=0;Navigable=Unspecified;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</target>
				<model ea_localid="9"/>
				<properties ea_type="Association" direction="Unspecified"/>
				<modifiers isRoot="false" isLeaf="false"/>
				<parameterSubstitutions/>
				<documentation/>
				<appearance linemode="3" linecolor="-1" linewidth="0" seqno="0" headStyle="0" lineStyle="0"/>
				<labels lb="1" rb="0..*"/>
				<extendedProperties virtualInheritance="0"/>
				<style/>
				<xrefs/>
				<tags/>
			</connector>
			<connector xmi:idref="EAID_D2A2071B_E9E3_40f3_881D_29CDF8CE57D4">
				<source xmi:idref="EAID_413197F1_1E7D_4a71_A961_218ED07519D2">
					<model ea_localid="11" type="Class" name="Estudiante"/>
					<role visibility="Public" targetScope="instance"/>
					<type multiplicity="0..*" aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="false"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;Owned=0;Navigable=Unspecified;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</source>
				<target xmi:idref="EAID_A4682377_D439_4256_B146_05374A8041F8">
					<model ea_localid="16" type="Class" name="Curso"/>
					<role visibility="Public" targetScope="instance"/>
					<type multiplicity="0..*" aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="false"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;Owned=0;Navigable=Unspecified;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</target>
				<model ea_localid="17"/>
				<properties ea_type="Association" direction="Unspecified"/>
				<modifiers isRoot="false" isLeaf="false"/>
				<parameterSubstitutions/>
				<documentation/>
				<appearance linemode="3" linecolor="-1" linewidth="0" seqno="0" headStyle="0" lineStyle="0"/>
				<labels lb="0..*" rb="0..*"/>
				<extendedProperties virtualInheritance="0"/>
				<style/>
				<xrefs/>
				<tags/>
			</connector>
			<connector xmi:idref="EAID_EA8465DB_DD4A_4733_8533_8E822E102842">
				<source xmi:idref="EAID_21D38904_C859_44ff_A301_944416EF1EB8">
					<model ea_localid="15" type="Class" name="Materia"/>
					<role visibility="Public" targetScope="instance"/>
					<type multiplicity="1" aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="false"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;Owned=0;Navigable=Unspecified;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</source>
				<target xmi:idref="EAID_A4682377_D439_4256_B146_05374A8041F8">
					<model ea_localid="16" type="Class" name="Curso"/>
					<role visibility="Public" targetScope="instance"/>
					<type multiplicity="0..*" aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="false"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;Owned=0;Navigable=Unspecified;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</target>
				<model ea_localid="14"/>
				<properties ea_type="Association" direction="Unspecified"/>
				<modifiers isRoot="false" isLeaf="false"/>
				<parameterSubstitutions/>
				<documentation/>
				<appearance linemode="3" linecolor="-1" linewidth="0" seqno="0" headStyle="0" lineStyle="0"/>
				<labels lb="1" rb="0..*"/>
				<extendedProperties virtualInheritance="0"/>
				<style/>
				<xrefs/>
				<tags/>
			</connector>
			<connector xmi:idref="EAID_F9D134A4_C537_4bc8_9481_FA8D8099EA95">
				<source xmi:idref="EAID_D8D61BB2_E1C9_4b86_8443_B5362CD5B82D">
					<model ea_localid="12" type="Class" name="Docente"/>
					<role visibility="Public" targetScope="instance"/>
					<type multiplicity="1" aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="false"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;Owned=0;Navigable=Unspecified;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</source>
				<target xmi:idref="EAID_A4682377_D439_4256_B146_05374A8041F8">
					<model ea_localid="16" type="Class" name="Curso"/>
					<role visibility="Public" targetScope="instance"/>
					<type multiplicity="0..*" aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="false"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;Owned=0;Navigable=Unspecified;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</target>
				<model ea_localid="15"/>
				<properties ea_type="Association" direction="Unspecified"/>
				<modifiers isRoot="false" isLeaf="false"/>
				<parameterSubstitutions/>
				<documentation/>
				<appearance linemode="3" linecolor="-1" linewidth="0" seqno="0" headStyle="0" lineStyle="0"/>
				<labels lb="1" rb="0..*"/>
				<extendedProperties virtualInheritance="0"/>
				<style/>
				<xrefs/>
				<tags/>
			</connector>
			<connector xmi:idref="EAID_D91235B1_A372_4535_BAE5_456B6E7D1F3F">
				<source xmi:idref="EAID_D8D61BB2_E1C9_4b86_8443_B5362CD5B82D">
					<model ea_localid="12" type="Class" name="Docente"/>
					<role visibility="Public" targetScope="instance"/>
					<type multiplicity="0..*" aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="false"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;Owned=0;Navigable=Navigable;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</source>
				<target xmi:idref="EAID_083D0DB1_BCBE_4a1c_A8A3_FA0146133CA6">
					<model ea_localid="13" type="Class" name="Departamento"/>
					<role visibility="Public" targetScope="instance"/>
					<type multiplicity="1" aggregation="shared" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="true"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;Owned=0;Navigable=Unspecified;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</target>
				<model ea_localid="22"/>
				<properties ea_type="Aggregation" subtype="Weak" direction="Source -&gt; Destination"/>
				<modifiers isRoot="false" isLeaf="false"/>
				<documentation/>
				<appearance linemode="3" linecolor="-1" linewidth="0" seqno="0" headStyle="0" lineStyle="0"/>
				<labels lb="0..*" rb="1"/>
				<extendedProperties virtualInheritance="0"/>
				<style/>
				<xrefs/>
				<tags/>
			</connector>
			<connector xmi:idref="EAID_12B79008_50CE_4e02_B54F_F66AB79E7C35">
				<source xmi:idref="EAID_D8D61BB2_E1C9_4b86_8443_B5362CD5B82D">
					<model ea_localid="12" type="Class" name="Docente"/>
					<role visibility="Public" targetScope="instance"/>
					<type aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="false"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</source>
				<target xmi:idref="EAID_5BDC6444_175B_4e5c_8B60_8EC1CD658997">
					<model ea_localid="10" type="Class" name="Persona"/>
					<role visibility="Public" targetScope="instance"/>
					<type aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="true"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</target>
				<model ea_localid="5"/>
				<properties ea_type="Generalization" direction="Source -&gt; Destination"/>
				<parameterSubstitutions/>
				<documentation/>
				<appearance linemode="3" linecolor="-1" linewidth="0" seqno="0" headStyle="0" lineStyle="0"/>
				<labels/>
				<extendedProperties virtualInheritance="0"/>
				<style/>
				<xrefs/>
				<tags/>
			</connector>
			<connector xmi:idref="EAID_FD88C7CB_4DD9_4e23_8939_C1A22EACCA94">
				<source xmi:idref="EAID_413197F1_1E7D_4a71_A961_218ED07519D2">
					<model ea_localid="11" type="Class" name="Estudiante"/>
					<role visibility="Public" targetScope="instance"/>
					<type aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="false"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</source>
				<target xmi:idref="EAID_5BDC6444_175B_4e5c_8B60_8EC1CD658997">
					<model ea_localid="10" type="Class" name="Persona"/>
					<role visibility="Public" targetScope="instance"/>
					<type aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="true"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</target>
				<model ea_localid="6"/>
				<properties ea_type="Generalization" direction="Source -&gt; Destination"/>
				<parameterSubstitutions/>
				<documentation/>
				<appearance linemode="3" linecolor="-1" linewidth="0" seqno="0" headStyle="0" lineStyle="0"/>
				<labels/>
				<extendedProperties virtualInheritance="0"/>
				<style/>
				<xrefs/>
				<tags/>
			</connector>
			<connector xmi:idref="EAID_A7075F92_B883_4b58_A303_287A45EF47B7">
				<source xmi:idref="EAID_21D38904_C859_44ff_A301_944416EF1EB8">
					<model ea_localid="15" type="Class" name="Materia"/>
					<role visibility="Public" targetScope="instance"/>
					<type multiplicity="0..*" aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="false"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;Owned=0;Navigable=Unspecified;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</source>
				<target xmi:idref="EAID_21D38904_C859_44ff_A301_944416EF1EB8">
					<model ea_localid="15" type="Class" name="Materia"/>
					<role visibility="Public" targetScope="instance"/>
					<type multiplicity="0..*" aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="false"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;Owned=0;Navigable=Unspecified;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</target>
				<model ea_localid="21"/>
				<properties ea_type="Association" direction="Unspecified"/>
				<modifiers isRoot="false" isLeaf="false"/>
				<parameterSubstitutions/>
				<documentation/>
				<appearance linemode="3" linecolor="-1" linewidth="0" seqno="0" headStyle="0" lineStyle="0"/>
				<labels lb="0..*" rb="0..*"/>
				<extendedProperties virtualInheritance="0"/>
				<style/>
				<xrefs/>
				<tags/>
			</connector>
			<connector xmi:idref="EAID_50AF9D5A_0903_49f5_8602_BA5820547AD6">
				<source xmi:idref="EAID_62EE9303_7A72_4331_AFA9_0ABC599D8749">
					<model ea_localid="23" type="ProxyConnector" name="ProxyConnector"/>
					<role visibility="Public" targetScope="instance"/>
					<type aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="false"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;Owned=0;Navigable=Unspecified;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</source>
				<target xmi:idref="EAID_A38849F1_506B_4769_9F51_47AC9B014704">
					<model ea_localid="24" type="ProxyConnector" name="ProxyConnector"/>
					<role visibility="Public" targetScope="instance"/>
					<type aggregation="none" containment="Unspecified"/>
					<constraints/>
					<modifiers isOrdered="false" changeable="none" isNavigable="false"/>
					<style value="Union=0;Derived=0;AllowDuplicates=0;Owned=0;Navigable=Unspecified;"/>
					<documentation/>
					<xrefs/>
					<tags/>
				</target>
				<model ea_localid="18"/>
				<properties ea_type="Association" subtype="Class" direction="Unspecified"/>
				<modifiers isRoot="false" isLeaf="false"/>
				<documentation/>
				<appearance linemode="3" linecolor="-1" linewidth="0" seqno="0" headStyle="0" lineStyle="0"/>
				<labels/>
				<extendedProperties virtualInheritance="0" associationclass="EAID_7FEBB9BF_1F3F_4e76_9857_5F07C7628A03" privatedata1="25"/>
				<style/>
				<xrefs/>
				<tags/>
			</connector>
		</connectors>
		<primitivetypes>
			<packagedElement xmi:type="uml:Package" xmi:id="EAPrimitiveTypesPackage" name="EA_PrimitiveTypes_Package" visibility="public">
				<packagedElement xmi:type="uml:Package" xmi:id="EAJavaTypesPackage" name="EA_Java_Types_Package" visibility="public">
					<packagedElement xmi:type="uml:PrimitiveType" xmi:id="EAJava_int" name="int" visibility="public">
						<generalization xmi:type="uml:Generalization" xmi:id="EAJava_int_General">
							<general href="http://schema.omg.org/spec/UML/2.1/uml.xml#Integer"/>
						</generalization>
					</packagedElement>
					<packagedElement xmi:type="uml:PrimitiveType" xmi:id="EAJava_string" name="string" visibility="public"/>
					<packagedElement xmi:type="uml:PrimitiveType" xmi:id="EAJava_decimal" name="decimal" visibility="public"/>
					<packagedElement xmi:type="uml:PrimitiveType" xmi:id="EAJava_date" name="date" visibility="public"/>
				</packagedElement>
			</packagedElement>
		</primitivetypes>
		<profiles/>
		<diagrams>
			<diagram xmi:id="EAID_C88BF657_2BE4_4fe3_9508_22BB017F3B51">
				<model package="EAPK_B45D3D37_ADD5_4f7f_AD77_690F6097B920" localID="1" owner="EAPK_B45D3D37_ADD5_4f7f_AD77_690F6097B920"/>
				<properties name="Practica 1" type="Logical"/>
				<project author="braya" version="1.0" created="2026-08-31 18:27:55" modified="2026-09-03 23:06:35"/>
				<style1 value="ShowPrivate=1;ShowProtected=1;ShowPublic=1;HideRelationships=0;Locked=0;Border=1;HighlightForeign=1;PackageContents=1;SequenceNotes=0;ScalePrintImage=0;PPgs.cx=0;PPgs.cy=0;DocSize.cx=850;DocSize.cy=1098;ShowDetails=0;Orientation=P;Zoom=100;ShowTags=0;OpParams=1;VisibleAttributeDetail=0;ShowOpRetType=1;ShowIcons=1;CollabNums=0;HideProps=0;ShowReqs=0;ShowCons=0;PaperSize=1;HideParents=0;UseAlias=0;HideAtts=0;HideOps=0;HideStereo=0;HideElemStereo=0;ShowTests=0;ShowMaint=0;ConnectorNotation=UML 2.1;ExplicitNavigability=0;ShowShape=1;AllDockable=0;AdvancedElementProps=1;AdvancedFeatureProps=1;AdvancedConnectorProps=1;m_bElementClassifier=1;SPT=1;ShowNotes=0;SuppressBrackets=0;SuppConnectorLabels=0;PrintPageHeadFoot=0;ShowAsList=0;"/>
				<style2 value="ExcludeRTF=0;DocAll=0;HideQuals=0;AttPkg=1;ShowTests=0;ShowMaint=0;SuppressFOC=1;MatrixActive=0;SwimlanesActive=1;KanbanActive=0;MatrixLineWidth=1;MatrixLineClr=0;MatrixLocked=0;TConnectorNotation=UML 2.1;TExplicitNavigability=0;AdvancedElementProps=1;AdvancedFeatureProps=1;AdvancedConnectorProps=1;m_bElementClassifier=1;SPT=1;MDGDgm=;STBLDgm=;ShowNotes=0;VisibleAttributeDetail=0;ShowOpRetType=1;SuppressBrackets=0;SuppConnectorLabels=0;PrintPageHeadFoot=0;ShowAsList=0;SuppressedCompartments=;Theme=:119;SaveTag=31E83FD2;"/>
				<swimlanes value="locked=false;orientation=0;width=0;inbar=false;names=false;color=-1;bold=false;fcol=0;tcol=-1;ofCol=-1;ufCol=-1;hl=0;ufh=0;hh=0;cls=0;bw=0;hli=0;SwimlaneFont=lfh:-10,lfw:0,lfi:0,lfu:0,lfs:0,lfface:Calibri,lfe:0,lfo:0,lfchar:1,lfop:0,lfcp:0,lfq:0,lfpf=0,lfWidth=0;"/>
				<matrixitems value="locked=false;matrixactive=false;swimlanesactive=true;kanbanactive=false;width=1;clrLine=0;"/>
				<extendedProperties/>
				<elements>
					<element geometry="Left=196;Top=354;Right=296;Bottom=442;" subject="EAID_7FEBB9BF_1F3F_4e76_9857_5F07C7628A03" seqno="1" style="DUID=5CD89028;"/>
					<element geometry="Left=228;Top=239;Right=242;Bottom=253;" subject="EAID_A38849F1_506B_4769_9F51_47AC9B014704" seqno="2" style="DUID=65ABAB57;"/>
					<element geometry="Left=231;Top=239;Right=245;Bottom=253;" subject="EAID_62EE9303_7A72_4331_AFA9_0ABC599D8749" seqno="3" style="DUID=CBF56F4D;"/>
					<element geometry="Left=403;Top=354;Right=508;Bottom=442;" subject="EAID_C653E036_9DFB_4e15_9B7B_DECB00FAA79F" seqno="4" style="DUID=83BAE979;"/>
					<element geometry="Left=9;Top=345;Right=131;Bottom=433;" subject="EAID_612CBEF6_C55B_415c_B03A_34446EF1955D" seqno="5" style="DUID=EE9290F4;"/>
					<element geometry="Left=645;Top=329;Right=735;Bottom=417;" subject="EAID_D61CA6B6_D2CB_40cb_BF5C_E19BD21542A0" seqno="6" style="DUID=95BF309A;"/>
					<element geometry="Left=313;Top=198;Right=403;Bottom=299;" subject="EAID_A4682377_D439_4256_B146_05374A8041F8" seqno="7" style="DUID=1E6746EF;"/>
					<element geometry="Left=656;Top=181;Right=746;Bottom=282;" subject="EAID_21D38904_C859_44ff_A301_944416EF1EB8" seqno="8" style="DUID=916F73F8;"/>
					<element geometry="Left=746;Top=40;Right=860;Bottom=110;" subject="EAID_F47E3563_90EE_48ad_AE30_5488758D7710" seqno="9" style="DUID=36CB4827;"/>
					<element geometry="Left=519;Top=49;Right=626;Bottom=119;" subject="EAID_083D0DB1_BCBE_4a1c_A8A3_FA0146133CA6" seqno="10" style="DUID=2B015008;"/>
					<element geometry="Left=258;Top=31;Right=380;Bottom=119;" subject="EAID_D8D61BB2_E1C9_4b86_8443_B5362CD5B82D" seqno="11" style="DUID=A21B1783;"/>
					<element geometry="Left=19;Top=202;Right=121;Bottom=290;" subject="EAID_413197F1_1E7D_4a71_A961_218ED07519D2" seqno="12" style="DUID=B323244F;"/>
					<element geometry="Left=29;Top=12;Right=146;Bottom=139;" subject="EAID_5BDC6444_175B_4e5c_8B60_8EC1CD658997" seqno="13" style="DUID=1F10689F;"/>
					<element geometry="SX=0;SY=0;EX=0;EY=0;SCME=1;SCTR=1;EDGE=3;SCTR.LEFT=692;SCTR.TOP=-313;SCTR.RIGHT=712;SCTR.BOTTOM=-281;$LLB=;LLT=CX=17:CY=14:OX=0:OY=0:HDN=0:BLD=0:ITA=0:UND=0:CLR=-1:ALN=1:DIR=0:ROT=0;LMT=;LMB=;LRT=CX=17:CY=14:OX=0:OY=0:HDN=0:BLD=0:ITA=0:UND=0:CLR=-1:ALN=1:DIR=0:ROT=0;LRB=;IRHS=;ILHS=;Path=692:-282$692:-313$712:-313$712:-282$;" subject="EAID_A7075F92_B883_4b58_A303_287A45EF47B7" style="Mode=3;EOID=916F73F8;SOID=916F73F8;Color=-1;LWidth=0;Hidden=0;"/>
					<element geometry="SX=0;SY=0;EX=0;EY=0;EDGE=4;$LLB=CX=17:CY=14:OX=0:OY=0:HDN=0:BLD=0:ITA=0:UND=0:CLR=-1:ALN=1:DIR=0:ROT=0;LLT=;LMT=;LMB=;LRT=;LRB=CX=6:CY=14:OX=0:OY=0:HDN=0:BLD=0:ITA=0:UND=0:CLR=-1:ALN=1:DIR=0:ROT=0;IRHS=;ILHS=;Path=;" subject="EAID_F26F79AD_B5C1_4bcf_BC4D_7FDFBEBF9DF2" style="Mode=3;EOID=5CD89028;SOID=83BAE979;Color=-1;LWidth=0;Hidden=0;"/>
					<element geometry="SX=0;SY=0;EX=0;EY=0;EDGE=2;$LLB=CX=17:CY=14:OX=0:OY=0:HDN=0:BLD=0:ITA=0:UND=0:CLR=-1:ALN=1:DIR=0:ROT=0;LLT=;LMT=;LMB=;LRT=;LRB=CX=17:CY=14:OX=0:OY=0:HDN=0:BLD=0:ITA=0:UND=0:CLR=-1:ALN=1:DIR=0:ROT=0;IRHS=;ILHS=;Path=;" subject="EAID_D2A2071B_E9E3_40f3_881D_29CDF8CE57D4" style="Mode=3;EOID=1E6746EF;SOID=B323244F;Color=-1;LWidth=0;Hidden=0;"/>
					<element geometry="EDGE=4;SX=0;SY=0;EX=0;EY=0;$LLB=;LLT=;LMT=;LMB=;LRT=;LRB=;IRHS=;ILHS=;Path=;" subject="EAID_50AF9D5A_0903_49f5_8602_BA5820547AD6" style="Mode=3;EOID=65ABAB57;SOID=CBF56F4D;Color=-1;LWidth=0;Hidden=0;"/>
					<element geometry="SX=0;SY=0;EX=0;EY=0;EDGE=3;$LLB=CX=6:CY=14:OX=0:OY=0:HDN=0:BLD=0:ITA=0:UND=0:CLR=-1:ALN=1:DIR=0:ROT=0;LLT=;LMT=;LMB=;LRT=;LRB=CX=17:CY=14:OX=0:OY=0:HDN=0:BLD=0:ITA=0:UND=0:CLR=-1:ALN=1:DIR=0:ROT=0;IRHS=;ILHS=;Path=;" subject="EAID_F9D134A4_C537_4bc8_9481_FA8D8099EA95" style="Mode=3;EOID=1E6746EF;SOID=A21B1783;Color=-1;LWidth=0;Hidden=0;"/>
					<element geometry="SX=0;SY=0;EX=0;EY=0;EDGE=4;$LLB=CX=6:CY=14:OX=0:OY=0:HDN=0:BLD=0:ITA=0:UND=0:CLR=-1:ALN=1:DIR=0:ROT=0;LLT=;LMT=;LMB=;LRT=;LRB=CX=17:CY=14:OX=0:OY=0:HDN=0:BLD=0:ITA=0:UND=0:CLR=-1:ALN=1:DIR=0:ROT=0;IRHS=;ILHS=;Path=;" subject="EAID_EA8465DB_DD4A_4733_8533_8E822E102842" style="Mode=3;EOID=1E6746EF;SOID=916F73F8;Color=-1;LWidth=0;Hidden=0;"/>
					<element geometry="SX=0;SY=0;EX=0;EY=0;EDGE=4;$LLB=CX=6:CY=14:OX=0:OY=0:HDN=0:BLD=0:ITA=0:UND=0:CLR=-1:ALN=1:DIR=0:ROT=0;LLT=;LMT=;LMB=;LRT=;LRB=CX=17:CY=14:OX=0:OY=0:HDN=0:BLD=0:ITA=0:UND=0:CLR=-1:ALN=1:DIR=0:ROT=0;IRHS=;ILHS=;Path=;" subject="EAID_926DEF20_8378_43bd_B04C_E604C4642425" style="Mode=3;EOID=1E6746EF;SOID=95BF309A;Color=-1;LWidth=0;Hidden=0;"/>
					<element geometry="SX=0;SY=0;EX=0;EY=0;EDGE=3;$LLB=CX=6:CY=14:OX=0:OY=0:HDN=0:BLD=0:ITA=0:UND=0:CLR=-1:ALN=1:DIR=0:ROT=0;LLT=;LMT=;LMB=;LRT=;LRB=CX=6:CY=14:OX=0:OY=0:HDN=0:BLD=0:ITA=0:UND=0:CLR=-1:ALN=1:DIR=0:ROT=0;IRHS=;ILHS=;Path=;" subject="EAID_27E33190_8A7C_4514_9D06_98BECC31B712" style="Mode=3;EOID=EE9290F4;SOID=B323244F;Color=-1;LWidth=0;Hidden=0;"/>
					<element geometry="SX=0;SY=0;EX=0;EY=0;EDGE=2;$LLB=CX=17:CY=14:OX=0:OY=0:HDN=0:BLD=0:ITA=0:UND=0:CLR=-1:ALN=1:DIR=0:ROT=0;LLT=;LMT=;LMB=;LRT=;LRB=CX=6:CY=14:OX=0:OY=0:HDN=0:BLD=0:ITA=0:UND=0:CLR=-1:ALN=1:DIR=0:ROT=0;IRHS=;ILHS=;Path=;" subject="EAID_D91235B1_A372_4535_BAE5_456B6E7D1F3F" style="Mode=3;EOID=2B015008;SOID=A21B1783;Color=-1;LWidth=0;Hidden=0;"/>
					<element geometry="SX=0;SY=0;EX=0;EY=0;EDGE=3;$LLB=CX=6:CY=14:OX=0:OY=0:HDN=0:BLD=0:ITA=0:UND=0:CLR=-1:ALN=1:DIR=0:ROT=0;LLT=;LMT=;LMB=;LRT=;LRB=CX=17:CY=14:OX=0:OY=0:HDN=0:BLD=0:ITA=0:UND=0:CLR=-1:ALN=1:DIR=0:ROT=0;IRHS=;ILHS=;Path=;" subject="EAID_49164E2F_13AE_4bd1_B088_6C2F1559588B" style="Mode=3;EOID=916F73F8;SOID=36CB4827;Color=-1;LWidth=0;Hidden=0;"/>
					<element geometry="SX=0;SY=0;EX=0;EY=0;EDGE=2;$LLB=CX=6:CY=14:OX=0:OY=0:HDN=0:BLD=0:ITA=0:UND=0:CLR=-1:ALN=1:DIR=0:ROT=0;LLT=;LMT=;LMB=;LRT=;LRB=CX=17:CY=14:OX=0:OY=0:HDN=0:BLD=0:ITA=0:UND=0:CLR=-1:ALN=1:DIR=0:ROT=0;IRHS=;ILHS=;Path=;" subject="EAID_8A209896_3D45_47de_800C_92CB3BC026D8" style="Mode=3;EOID=36CB4827;SOID=2B015008;Color=-1;LWidth=0;Hidden=0;"/>
					<element geometry="SX=0;SY=0;EX=0;EY=0;EDGE=1;$LLB=;LLT=;LMT=;LMB=;LRT=;LRB=;IRHS=;ILHS=;Path=;" subject="EAID_FD88C7CB_4DD9_4e23_8939_C1A22EACCA94" style="Mode=3;EOID=1F10689F;SOID=B323244F;Color=-1;LWidth=0;Hidden=0;"/>
					<element geometry="SX=0;SY=0;EX=0;EY=0;EDGE=4;$LLB=;LLT=;LMT=;LMB=;LRT=;LRB=;IRHS=;ILHS=;Path=;" subject="EAID_12B79008_50CE_4e02_B54F_F66AB79E7C35" style="Mode=3;EOID=1F10689F;SOID=A21B1783;Color=-1;LWidth=0;Hidden=0;"/>
				</elements>
			</diagram>
		</diagrams>
	</xmi:Extension>
</xmi:XMI>
```

---

## Paquete de fixtures

### Estructura

```text
fixtures/package.json
`-- package.json
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `fixtures/package.json` | 29 |

---

### `fixtures/package.json`

```json
{
  "name": "@uml/fixtures",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "description": "Banco de regresion T01-T07 y demas material de prueba compartido.",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "default": "./dist/index.js"
    }
  },
  "files": [
    "dist"
  ],
  "scripts": {
    "build": "tsc --build",
    "clean": "tsc --build --clean",
    "emit": "tsx src/emit.ts",
    "report": "tsx src/report.ts"
  },
  "dependencies": {
    "@uml/contracts": "*",
    "@uml/domain-core": "*"
  }
}
```

---

## TypeScript del banco

### Estructura

```text
fixtures/tsconfig.json
`-- tsconfig.json
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `fixtures/tsconfig.json` | 10 |

---

### `fixtures/tsconfig.json`

```json
{
  "extends": "../config/tsconfig.base.json",
  "compilerOptions": {
    "rootDir": "src",
    "outDir": "dist"
  },
  "include": ["src/**/*.ts"],
  "references": [{ "path": "../shared/contracts" }, { "path": "../shared/domain-core" }]
}
```

