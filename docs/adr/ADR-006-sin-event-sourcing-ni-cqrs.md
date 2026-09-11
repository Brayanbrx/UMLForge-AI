# ADR-006 · Sin event sourcing ni CQRS completo

**Estado:** aceptada
**Fecha:** 29 de agosto de 2026
**Fase:** 2

## Contexto

La plataforma ya usa comandos de dominio, un documento CRDT, una proyección JSON
y una tabla de auditoría. Esa combinación puede parecer el comienzo de event
sourcing o CQRS y llevar a tratar el historial de comandos como fuente de verdad.

Eso sería incorrecto para la colaboración: el protocolo transmite deltas del
CRDT y puede fusionar cambios concurrentes sin un orden total de comandos.
Reconstruir desde comandos exigiría inventar ese orden y duplicar la lógica de
persistencia que Yjs ya resuelve.

## Decisión

**El documento Yjs persistido en formato binario es la fuente del estado vivo.
No se implementan event sourcing ni CQRS completo.**

Los comandos sirven para validar y aplicar una intención local de forma atómica.
Su registro es auditoría, no un log desde el que se reconstruye el documento. El
JSON canónico es una proyección para inspección, validación y generación; nunca
rehidrata Yjs (RA-11).

## Consecuencias

- Reabrir una pizarra carga `BoardDocument.state`, no reproduce comandos.
- `audit_operations` puede responder quién pidió qué, pero perder esa tabla no
  impide recuperar el documento.
- Lectura y escritura comparten el mismo modelo; no hay buses, almacenes ni
  despliegues separados para cada lado.
- Los snapshots numerados solo congelan entradas de generación. Tampoco son un
  historial de eventos.
- Si el producto necesitara auditoría legal o reproducción temporal completa,
  haría falta otra decisión y un diseño específico; no se simula dentro del
  alcance actual.
