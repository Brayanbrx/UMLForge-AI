# Registro de decisiones de arquitectura

Una página por decisión. Sirven directamente para responder en la defensa.

El plan maestro (sección 17) exige dieciséis. Se escriben cuando la decisión se
toma de verdad, no antes: un ADR redactado sobre una decisión que todavía no se
ejecutó es una intención, no un registro.

| ADR | Decisión | Estado | Fase |
|---|---|---|---|
| [ADR-001](ADR-001-monolito-modular-dos-procesos.md) | Monolito modular con dos procesos, no microservicios | Aceptada | 0 |
| [ADR-002](ADR-002-crdt-para-colaboracion.md) | CRDT para la colaboración en tiempo real | Aceptada | 4 |
| [ADR-003](ADR-003-modelo-canonico-comandos-lotes.md) | Modelo canónico único con comandos y lotes atómicos | Aceptada | 1 |
| [ADR-004](ADR-004-varias-pizarras-generacion-seleccionada.md) | Varias pizarras, generación sobre una pizarra seleccionada | Aceptada | 3 |
| [ADR-005](ADR-005-entidad-intermedia-muchos-a-muchos.md) | Entidad intermedia explícita para muchos a muchos | Aceptada | 1 |
| [ADR-006](ADR-006-sin-event-sourcing-ni-cqrs.md) | Sin event sourcing ni CQRS completo | Aceptada | 2 |
| [ADR-007](ADR-007-generacion-por-ir-y-plantillas.md) | Generación por representación intermedia y plantillas | Aceptada | 2 |
| [ADR-008](ADR-008-dto-planos-relaciones-unidireccionales.md) | DTO planos y relaciones unidireccionales | Aceptada | 2 |
| [ADR-009](ADR-009-runtime-compartido.md) | Runtime compartido entre navegador y servidor | Aceptada | 1 |
| [ADR-010](ADR-010-docker-compose-iac-diferida.md) | Docker Compose, infraestructura como código diferida | Aceptada | 0 |
| [ADR-011](ADR-011-generacion-limitada-capa-datos.md) | Generación limitada a la capa de datos del cliente móvil | **Superada** | 6 |
| [ADR-012](ADR-012-importacion-como-candidato-editable.md) | Toda importación produce un candidato editable | Aceptada | 8 |
| [ADR-017](ADR-017-agente-movil-local.md) | Agente móvil local con resolución determinista de entidades | **Superada** | 9 |
| [ADR-013](ADR-013-uuid-para-creacion-sin-conexion.md) | Creación sin conexión requiere clave primaria UUID | Aceptada | 9 |
| [ADR-014](ADR-014-autenticacion-propia-minima.md) | Autenticación propia mínima con roles por proyecto | Aceptada | 3 |
| [ADR-015](ADR-015-proveedores-ia-tras-puertos.md) | Proveedores de IA detrás de puertos intercambiables | Aceptada | 7 |
| [ADR-016](ADR-016-matriz-de-versiones.md) | Matriz de versiones congelada, con fecha de verificación | Aceptada | 0 |
| [ADR-018](ADR-018-artefactos-no-se-almacenan.md) | Los artefactos no se almacenan; se congela el snapshot | Aceptada | 10 |
| [ADR-019](ADR-019-pasarela-ia-credenciales-y-respaldo.md) | Pasarela de IA: credenciales por proveedor y respaldo por puerto | Aceptada | 7 |
| [ADR-020](ADR-020-generalizacion-tabla-por-clase.md) | La generalización se genera como tabla por clase unida por la clave | Aceptada | — |
