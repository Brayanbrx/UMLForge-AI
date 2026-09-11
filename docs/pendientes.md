# Pendientes vigentes

Actualización de IA del 10 de septiembre: [prompt, texto, voz y cancelación](revision-ia-2026-09-10.md). Se corrigieron pérdida de opciones/contexto, inferencia de teléfonos e identificadores y borradores tras fallar el dictado. El asistente propaga cancelación; siguen pendientes presupuestos por usuario, alternativa de grabación y calidad comprobada con el proveedor real.

Actualización del 10 de septiembre: [colaboración, candidato editable e intercambio XMI](colaboracion-xmi-2026-09-10.md). Se completaron administración de participantes, edición del candidato, conservación de identidad/geometría y selección de XMI 2.5.1 o del perfil EA 2.1. Nueve modelos aprobaron la importación real en Enterprise Architect; queda su reexportación completa y el ensayo entre equipos.

Offline y flexibilidad del prompt móvil: [estrategia y estado implementado](estrategia-mobile-offline-agente.md). El contrato adapta CRUD; faltan perfil semántico configurable, herramientas de negocio compuestas, renovación automática de sesión y sincronización con la app cerrada si se requieren.

Revisión de cumplimiento y generación de distintas aplicaciones: [banco CRUD y configuración Spring/Flutter](revision-generador-crud.md). Ocho modelos generados con perfil móvil aprobaron contra PostgreSQL; siguen pendientes la prueba física del agente y el ensayo de presentación.

Generador Android incorporado el 6 de septiembre: [estado, validaciones y faltantes](generacion-flutter-android.md). La ampliación es opcional y no cambia el requisito docente de construir el frontend durante la presentación. Quedan la validación física de GGUF/voz en modo avión y la preparación de distribución release.

Generación de gestión actualizada el 6 de septiembre: [capas, DTO para Flutter, Postman y ejecución](generacion-backend-gestion.md). Se cerró la comprobación de configuración externa del generado indicada anteriormente como CA-068.2.

Alcance aclarado por las notas del docente del 6 de septiembre: [matriz de cumplimiento](requisitos-docente-2026-09-06.md). Flutter se construye aparte durante la presentación; su agente local y funcionamiento offline siguen siendo requisitos de la demostración. No se exige generar Flutter desde la herramienta.

Actualización de IA del 6 de septiembre: [correcciones, evidencia y pendientes priorizados](revision-ia-2026-09-06.md).

Revisado el **5 de septiembre de 2026**. Entrega prevista: **23 de septiembre**.
La evidencia y los defectos corregidos están en la
[auditoría consolidada](auditoria-2026-09-05.md). Este índice sustituye el diagnóstico
del 30 de agosto; la historia de propuestas permanece en
[actualizacion.md](actualizacion.md) y en Git.

El alcance ejecutable actual es la web colaborativa y el generador Spring Boot.
La web se adapta a teléfonos; el cliente nativo y la generación Dart fueron retirados.

## Antes de cerrar la entrega

| Prioridad | Qué falta | Cómo se cierra |
|---|---|---|
| P1 | Reexportación completa desde Enterprise Architect 15 | Nueve modelos ya conservan tipos, posiciones, identidad, relaciones y marcas al importarse realmente. El exportador automatizado de EA no respondió; falta comprobar su archivo de vuelta. Ver [evidencia actual](colaboracion-xmi-2026-09-10.md). |
| P0 | Ensayo completo en equipos y red de la defensa | Recorrer acceso, invitación, edición simultánea, IA/importación, generación y ejecución del ZIP con reloj. |
| P0 | Confirmar el alcance después de retirar nativo/Dart | Reflejar la decisión en los requisitos acordados; no presentar la web táctil como una app nativa. |
| P1 | Voz, fotografía y proveedores reales | Probar el micrófono y una imagen real del pizarrón, permisos y respuesta de IA. Los mocks verifican el flujo, no la calidad del reconocimiento. |
| P1 | URL, correo y reparto de puertos | WEB_ORIGIN debe coincidir con la URL de acceso. Probar email real si se demuestra recuperación. Plataforma 8080 y backend generado 8081, por ejemplo. |
| P1 | RNF-14: contexto en registros | Ver proyecto, pizarra, lote, comando, generación, actor y origen en los registros correspondientes. |

Preparación del entorno: [despliegue.md](despliegue.md). El adaptador de correo
`log` muestra enlaces en registros y **no envía correo**. El plan maestro de
`docs/referencia/` no se incluye en un clon limpio; compartir una versión
autorizada del alcance con quienes revisen la entrega.

## Funciones todavía incompletas

- Copia/restauración JSON y recuperación de versiones por el usuario.
- Recuperación visible de lotes de auditoría rechazados permanentemente y
  protección de la cola frente a escrituras concurrentes entre pestañas.
- Persistencia del documento sin conexión a través de recargas, si se ofrece
  esa capacidad: hoy se recuperan desconexiones transitorias con la pestaña abierta.
- Reparación guiada muchos a muchos, si se incorpora al alcance: hoy se detecta
  y explica la entidad intermedia requerida.
- Actualización automática del historial de generaciones de otros colaboradores.
- Revisión de accesibilidad completa y validación en dispositivos físicos y
  navegadores distintos de Chromium.

## Antes de publicar en internet

- Resolver los cuatro paquetes afectados en la cadena de herramientas Prisma
  con una actualización compatible; no ejecutar una degradación mayor automática.
- Revocación inmediata de JWT de acceso si se promete cierre instantáneo de
  todas las sesiones. Hoy los refresh se revocan, pero los JWT emitidos caducan después.
- Limitar intentos de acceso/recuperación y consumo de IA/generación.
- HTTPS, cookies seguras, cabeceras de seguridad y exposición mínima de puertos.
- Copias de seguridad, ensayo de restauración, alertas, límites de recursos,
  rotación de registros y retención de tokens/snapshots.
- Si se exige auditoría autoritativa, cubrir las escrituras de clientes Yjs
  directos que no envían lotes al endpoint HTTP de auditoría.

## Verificaciones ya realizadas

- RF-053: exportar/reimportar archivos de la app conserva identidad y geometría; la reexportación externa de EA se sigue arriba.
- Formato, lint, TypeScript, pruebas unitarias e integración con PostgreSQL.
- Cinco participantes y 30 cambios; P95 local de 39,4 ms en la última ejecución.
- Diez pizarras con estados aislados.
- Modelo de 30 clases, 100 atributos y 40 relaciones importado, renderizado y
  movido con propagación a otro navegador.
- Ocho modelos Spring generados, compilados y ejecutados con CRUD y reinicio.
- Determinismo de archivos/ZIP y generación sintética bajo el presupuesto de 10 s.

Estas mediciones son locales. Falta el ensayo de red del aula y no se infiere
rendimiento prolongado de producción a partir de ellas.

## Fuera del núcleo por decisión

- RF-018: deshacer el último comando propio (P2).
- Bloqueo temporal de la pizarra, visor de código por capas y cambios cosméticos
  sin criterio de aceptación asignado.

## Preparación final de la demostración

- [ ] Contenedores reconstruidos después del último cambio.
- [ ] Dependencias Java y de Node disponibles en los equipos previstos.
- [ ] Enterprise Architect probado con los archivos del ensayo.
- [ ] Plataforma y backend generado ejecutándose simultáneamente en puertos distintos.
- [ ] Cuentas de demostración y modelo de respaldo preparados.
- [ ] Voz/cámara y acceso a proveedores comprobados; conexión de respaldo disponible.
- [ ] Guion completo cronometrado y requisitos pendientes reconocidos explícitamente.
