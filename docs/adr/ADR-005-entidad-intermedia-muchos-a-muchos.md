# ADR-005 · Entidad intermedia explícita para muchos a muchos

**Estado:** aceptada
**Fecha:** 29 de agosto de 2026
**Fase:** 1

## Contexto

`Alumno` y `Materia` se relacionan muchos a muchos, y la inscripción tiene datos
propios: gestión, fecha, nota. JPA sabe generar una tabla de unión con
`@ManyToMany`, así que la herramienta podría emitirla.

## Decisión

RM-01: **toda relación muchos a muchos se modela con una clase intermedia
explícita y dos relaciones N:1.** La N:M directa no llega al generador; el
validador la marca como error y sugiere cómo modelarla.

## Por qué

**La tabla de unión implícita no admite atributos.** En cuanto la asociación
tiene un dato propio —y casi siempre lo tiene— hay que convertirla en entidad de
todos modos. Hacerlo desde el principio evita una migración a mitad del modelado.

**`@ManyToMany` arrastra decisiones que este alcance no toma.** Lado propietario,
`cascade`, `fetch`, nombre de la tabla de unión y de sus columnas. Todo eso es lo
que RTM-05 elimina deliberadamente al generar solo el lado propietario.

**La app móvil no podría sincronizar la asociación.** Una fila de tabla de unión
no tiene identidad propia, así que no tiene UUID que el cliente pueda asignar
antes de sincronizar (ADR-013 y RM-06). Una `Inscripcion` sí.

**Es lo que se enseña.** Presentar `DetalleVenta` como entidad es exactamente lo
que la consigna del docente espera ver.

## El error no es un rechazo seco

El validador identifica la construcción y dice cómo modelarla:

> La relación entre "Alumno" y "Materia" es muchos a muchos.
> Crea una clase intermedia con dos relaciones N:1, una hacia "Alumno" y otra
> hacia "Materia". Ahí es donde viven los atributos propios de la asociación.

Cada exclusión del alcance está declarada, no omitida. Cuando aparece una
construcción no soportada, la herramienta la identifica con claridad y sugiere la
alternativa en lugar de fallar sin explicación.

## Consecuencias

- El generador nunca emite `@ManyToMany`, `@JoinTable` ni colecciones.
- T06 del banco de regresión es exactamente este caso, ya resuelto con
  `Inscripcion`, y T01 lo repite con `DetalleVenta`.
- Detectar la N:M mientras se dibuja y ofrecer crear la clase intermedia con un
  clic es trabajo de la fase 5. La regla que lo hace obligatorio ya está.
