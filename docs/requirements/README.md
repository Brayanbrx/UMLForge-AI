# Requisitos

La lista completa vive en el [plan maestro](../referencia/plan-integral-plataforma-uml.md),
secciones 5.6 y 9 a 12. No se duplica aquí para que no puedan divergir.

## Cómo leer los códigos

**Procedencia** — `DOC` pedido por el docente · `DER` derivado, necesario para
cumplir uno del docente · `PROY` alcance propio · `OPT` mejora opcional.

**Prioridad** — `P0` sin esto falla la demostración · `P1` necesario para una
demostración confiable · `P2` posterior al núcleo · `P3` fuera del parcial.

Procedencia y prioridad son independientes. Un requisito `DER` puede ser `P0`:
que el docente no lo haya verbalizado no significa que se pueda postergar.

**Otros bloques** — `CA` criterio de aceptación · `RNF` requisito no funcional ·
`RT` restricción tecnológica · `RA` restricción arquitectónica · `RM` regla de
modelado · `RTM` regla de transformación · `FA` fuera de alcance.

## Trazabilidad por fase

| Fase | Requisitos que cierra |
|---|---|
| 0 | RNF-12 (un solo comando), RNF-13 (base de CI), RNF-15 (base del aislamiento del dominio) |
| 1 | RM-01 a RM-07, RTM-01 a RTM-04, RF-017 |
| 2 | Spike técnico de RF-061 a RF-068 sobre T01, RTM-05 a RTM-13, RNF-05, RNF-07 |
| 3 | RF-A01 a RF-A07, RF-001 a RF-005 |
| 4 | RF-020 a RF-026, RF-A08 y atribución en memoria de RF-A09, RNF-01, RNF-02 |
| 5 | RF-010 a RF-016, RNF-03, RNF-04 |
| 6 | RF-069 a RF-071 |
| 7 | RF-030 a RF-037 |
| 8 | RF-040 a RF-044, RF-050 a RF-052 |
| 9 | Histórico: RFM-01 a RFM-12, RNF-09 a RNF-11; módulo móvil retirado del alcance ejecutable actual |
| 10 | Integración de RF-060/RF-072, persistencia de RF-A09 y guion de ensayo de la sección 16.2 |

La atribución viaja en cada lote y se persiste en `audit_operations`; el cliente
mantiene además una cola reintentable y el servidor deduplica por pizarra y lote.
RF-060 y RF-072 están integrados: la API congela el snapshot y el manifiesto, y
la interfaz descarga el backend, también desde el historial. Siguen abiertas
las validaciones externas y el robustecimiento detallado en
[`actualizacion.md`](../actualizacion.md).
