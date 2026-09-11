# ADR-013 · La creación sin conexión exige clave primaria UUID

- **Estado:** Aceptada
- **Fase:** 9
- **Fecha:** 2026-08-30

## Contexto

La aplicación móvil tiene que registrar en modo avión (RFM-05, CA-03.1) y enviar
lo registrado cuando vuelva la conexión (RFM-10). Eso obliga a decidir **quién
asigna el identificador** de una fila que nace sin servidor.

Con un entero autoincremental la respuesta es el servidor, y entonces la fila no
existe hasta que haya red: no se le puede referenciar desde otra tabla local, no
se puede mostrar en una lista con identidad estable, y reintentar un envío que
agotó el tiempo de espera crea un duplicado, porque el cliente no puede decir
«esta fila es la misma que te mandé antes».

RTM-04 ya define cuatro ramas para elegir clave primaria a partir de la pizarra.
La pregunta aquí es qué pasa cuando el modelo elige entero autoincremental y ese
modelo se lleva al móvil.

## Decisión

**Toda entidad que la aplicación móvil pueda crear sin conexión usa UUID como
clave primaria, asignado por el dispositivo.** El generador de la capa de datos
El cliente emite `id` de tipo texto y el servidor lo exige ya presente: no hay un
camino en el que el identificador llegue después.

El backend generado, al recibir un alta con un identificador que ya tiene,
devuelve el recurso existente en lugar de duplicar o fallar (RTM-11). Reintentar
es seguro por construcción, no por suerte de red.

## Consecuencias

**A favor.** La fila existe en cuanto se dicta. Se puede referenciar desde una
atención antes de que ningún servidor la conozca. Un tiempo de espera agotado
seguido de un reintento deja **una** operación, que es lo que comprueba CA-10.1
y lo que verifica la prueba «RM-06 — el identificador lo asigna el dispositivo,
sin red».

**En contra.** Un UUID ocupa dieciséis bytes frente a cuatro u ocho, y como
clave primaria agrupada dispersa las escrituras. A la escala de este sistema —un
puñado de barberías, miles de filas— no se mide. En un sistema con volumen alto
de inserciones habría que revisarlo, y la revisión sería local a la elección de
clave, no a la arquitectura.

**Lo que cierra.** Ya no es posible que un modelo con clave autoincremental
llegue al móvil y falle a mitad de la demostración, sin conexión, sin poder
explicar por qué. La restricción se declara aquí y el generador la impone.

Relacionado: [ADR-011](ADR-011-generacion-limitada-capa-datos.md) (la generación
móvil llega hasta la capa de datos) y
[ADR-017](ADR-017-agente-movil-local.md) (quién escribe esas filas).
