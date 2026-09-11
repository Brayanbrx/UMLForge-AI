# Revisión de generación de aplicaciones CRUD

Fecha: 6 de septiembre de 2026. Alcance: código actual, configuración CORS y generación de aplicaciones de gestión desde distintos diagramas. Se excluyen las pruebas del agente IA, inferencia GGUF y dictado por indicación del usuario.

## Dónde se configura cada cosa

| Configuración | Lugar | Ejemplo |
| --- | --- | --- |
| CORS de la aplicación generada | `backend/.env` del ZIP generado, leído por `WebConfig` de Spring | `CORS_ALLOWED_ORIGINS=https://frontend.ejemplo.com,http://localhost:5173` |
| URL que consume Flutter | Campo Dirección del backend en login, o `API_BASE_URL` al compilar | `https://api.ejemplo.com` |
| PostgreSQL, credenciales de login y secreto de tokens | Entorno del backend Spring generado | `DATABASE_URL`, `DB_USER`, `DB_PASSWORD`, `AUTH_USERNAME`, `AUTH_PASSWORD`, `AUTH_TOKEN_SECRET` |
| HTTP de desarrollo, permisos Android y firma | Proyecto Android del cliente Flutter | Debug permite HTTP; distribución requiere HTTPS y firma propia |
| Configuración del diseñador UML | `infra/.env` de este repositorio | Configura la herramienta principal; no configura automáticamente los servidores independientes que generas |

**CORS vive en Spring Boot, no en Dart.** Android nativo y Postman no están sujetos a CORS del navegador. Para Flutter web u otro frontend web se habilitan orígenes exactos en el backend. El origen es el del frontend, sin rutas; no la dirección del teléfono ni un comodín. CORS no sustituye autenticación. El perfil móvil contempla CRUD, login, contrato y sincronización. Referencia: [Spring MVC CORS](https://docs.spring.io/spring-framework/reference/web/webmvc-cors.html).

## Qué genera un diagrama

Cada clase del modelo generable produce su entidad, repositorio, servicio, controlador y DTO. Relaciones y tipos forman el contrato REST y el esquema PostgreSQL. También se emiten Postman, OpenAPI, documentación, Dockerfile y Compose.

Al elegir **Android + backend**, se añaden autenticación y endpoints `/mobile-contract` y `/mobile-sync`. Flutter obtiene ese contrato en el login y adapta sus colecciones y formularios. Login, configuración GGUF, búsqueda, CRUD y cola offline son comunes; las pantallas particulares se registran en `lib/ui/custom_pages.dart`.

Ejemplos posibles: ventas/clientes/productos, compras/proveedores, barbería/citas/servicios, activos/ubicaciones/responsables e inscripciones/estudiantes/cursos. Son bases CRUD ajustadas al modelo; una aplicación bancaria completa, contabilidad, pagos o disponibilidad de citas requieren reglas adicionales.

## Verificación reproducible

`npx tsx scripts/verify-management-apps.ts` recorre los modelos generables del banco. Por cada uno genera Android + backend, compila Java con Maven, arranca PostgreSQL temporal, autentica, compara `/mobile-contract` con el contrato Flutter, crea/consulta/actualiza/borra recursos y comprueba reintentos con el mismo ID de operación. Las altas respetan dependencias y los borrados se hacen en orden inverso. No llama a ningún motor o proveedor IA.

Para repetir un caso con claves numéricas: `npx tsx scripts/verify-management-apps.ts T03 --numeric-keys`.

Resultado del banco: **8 modelos aprobados, 34 recursos en total**, con generación, compilación, contrato, CRUD, referencias y reintentos verificados contra PostgreSQL.

Además, T03 se repitió con claves Integer: sus cuatro recursos también aprobaron. Esto acredita que el perfil móvil no depende exclusivamente de claves UUID.

| Modelo | Dominio | Recursos | Resultado |
| --- | --- | ---: | --- |
| T01 | Ventas | 4 | Aprobado |
| T02 | Compras | 4 | Aprobado |
| T03 | Barbería | 4 | Aprobado |
| T04 | Inventario de activos | 4 | Aprobado |
| T05 | Cuentas y movimientos | 3 | Aprobado |
| T06 | Inscripciones | 3 | Aprobado |
| T07R | Nombres y relaciones conflictivos corregidos | 5 | Aprobado |
| T08 | Institución con jerarquía de clases | 7 | Aprobado |

Las siete pruebas Flutter de almacenamiento/cola seleccionadas en esta revisión aprobaron: consolidación antes del envío, cancelación de alta local, confirmación perdida, inmutabilidad después de intentar envío, propagación de borrados, reapertura SQLite, edición obsoleta y resolución de conflicto. Se excluyeron las pruebas de propuestas del agente. Las cuatro pruebas de contrato/login, el APK compilado y las verificaciones CORS del turno anterior siguen siendo la evidencia complementaria de la base móvil.

## Cumplimiento y faltantes

| Requisito | Estado |
| --- | --- |
| Diferentes diagramas → backends CRUD independientes | Implementado para modelos aceptados por el validador; comprobación real por banco descrita arriba |
| Spring Boot, PostgreSQL y cinco capas incluyendo DTO | Implementado |
| Postman, OpenAPI y ejecución local | Implementado |
| Flutter común adaptable al backend generado | Implementado; contrato versionado, formularios genéricos y extensión de pantallas |
| Login estándar | Administrador compartido; faltan registro, recuperación, roles y aislamiento multiempresa si la aplicación los necesita |
| Preparación de IA local | Carga GGUF y configuración implementadas; calidad y funcionamiento físico no acreditados, sin probar por solicitud del usuario |
| CRUD y persistencia offline | Implementados; siete pruebas de almacenamiento/cola aprobadas |
| Sincronización al recuperar conectividad | Se intenta con la app abierta y al reabrir; falta servicio permanente con la app cerrada, si se desea ese comportamiento |
| Despliegue sencillo | Docker/Compose y configuración Railway preparados; no hay despliegue externo acreditado |
| Aplicación lista para distribución pública | Pendientes firma release, HTTPS en servidor real, copias y migraciones de esquema versionadas |
| Todo el alcance de la presentación | Pendiente ensayo físico Flutter + voz/IA offline, foto real, recorrido Architect y demostración colaborativa en los equipos previstos |

## Límites que no deben confundirse con generación completa

- El validador admite un subconjunto UML: no claves compuestas, herencia múltiple ni ciclos de herencia. Las relaciones muchos a muchos necesitan una clase intermedia explícita. Los nombres ambiguos o duplicados deben resolverse antes de generar.
- Crear CRUD no genera automáticamente cobros, totales, descuentos de stock, intereses ni transacciones entre varios recursos. Añadir esos casos de uso en Servicio/Controlador y las pantallas correspondientes.
- Flutter usa el protocolo móvil generado; para un REST diferente hace falta un adaptador o implementar ese protocolo. Cambiar pantallas exige recompilar; cambiar URL compatible puede hacerse en login.
- El primer login requiere conexión. Después se conserva sesión/contrato/datos; un token remoto vencido requiere volver a iniciar sesión para sincronizar. La inferencia offline requiere pesos compatibles instalados previamente.
- No se promete sincronización incremental a gran escala ni migración automática entre contratos incompatibles. Una operación cuyo envío se intentó no se modifica hasta confirmar o resolver el conflicto. El usuario puede aceptar la versión del servidor y editar de nuevo.

La conclusión correcta es que la plataforma puede generar distintas **bases de aplicaciones de gestión CRUD**, con backend y cliente estándar, pero todavía no cumple por sí sola todos los requisitos de una aplicación de negocio terminada ni toda la demostración del docente.
