# ADR-004 · Varias pizarras y generación sobre una pizarra seleccionada

**Estado:** aceptada
**Fecha:** 29 de agosto de 2026
**Fase:** 3

## Contexto

Un proyecto puede contener diagramas para contextos distintos. Tratar cada
proyecto como una sola pizarra simplificaría la primera pantalla, pero mezclaría
sesiones colaborativas, permisos de edición y artefactos generados.

También había que decidir si la generación combina todas las pizarras de un
proyecto o trabaja con una sola. Combinar exige definir relaciones entre
documentos, resolver colisiones globales y decidir qué hacer con una pizarra
inválida cuando las demás sí son generables.

## Decisión

**Un proyecto contiene varias pizarras independientes. Cada pizarra tiene su
propio documento y su propia sala colaborativa. La generación recibe una pizarra
seleccionada y nunca fusiona varias.**

La sala se identifica como `project:{projectId}:board:{boardId}`. El servidor
comprueba que ambos identificadores corresponden entre sí antes de permitir la
conexión.

## Por qué

- La independencia evita que una actualización de una pizarra aparezca en otra.
- El permiso sigue siendo del proyecto, sin duplicar membresías por documento.
- El snapshot de generación tiene una única fuente y puede congelarse de forma
  inmutable (RA-08).
- El banco y el generador no necesitan semántica de relaciones cruzadas que el
  modelo canónico no representa.

## Consecuencias

- `Board` pertenece a un `Project`, pero documento, snapshots y generaciones
  pertenecen a la pizarra.
- CA-004.1 verifica con dos navegadores que dos pizarras del mismo proyecto no
  mezclan actualizaciones.
- La interfaz debe hacer explícita la pizarra que se va a generar.
- Fusionar pizarras o crear relaciones entre ellas queda fuera del parcial.
