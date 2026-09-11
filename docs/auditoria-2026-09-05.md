# Auditoría consolidada — 5 de septiembre de 2026

**Estado: el núcleo web y la generación Spring Boot están implementados y verificados; la entrega aún tiene validaciones externas pendientes y el despliegue público necesita robustecimiento.** No corresponde presentar la aplicación como completamente terminada ni libre de vulnerabilidades.

Este informe reúne las correcciones de la auditoría y su continuación sobre el código del commit `5bfbfdf`. Conserva las mejoras ya incorporadas, incluidas las de interfaz táctil. La [revisión anterior](estado-aplicacion-2026-09-05.md) contiene evidencia adicional de regresiones y del proxy Vite; los resultados finales de esta continuación se indican aquí.

## Alcance y limpieza

Se revisaron cuentas y recuperación, proyectos e invitaciones, autorización HTTP y WebSocket, persistencia PostgreSQL/Yjs, editor, importación y exportación, IA, auditoría, generación, pruebas y contenedores. El alcance actual es **web adaptable a móviles + generador Spring**. La aplicación nativa y el generador Dart fueron retirados; una página usable en un teléfono no sustituye esos entregables si todavía los exige el docente.

La separación del dominio, contratos, representación intermedia y adaptadores permite probar las reglas sin red ni base de datos. El generador tiene pruebas de determinismo y ejecución real. Formato, lint y tipos pasan. Como deuda de mantenimiento quedan componentes grandes del editor y rutas que mezclan coordinación HTTP con operaciones Prisma; no requieren una reescritura para cerrar la demostración.

La documentación anterior tenía resultados y tareas móviles obsoletos. Se actualizó la lista de pendientes. El plan maestro bajo `docs/referencia/` está excluido de Git: un clon nuevo no contiene esa referencia y necesita una copia autorizada del alcance vigente.

## Defectos corregidos y comprobados

| Área | Fallo y resultado de la corrección | Evidencia |
|---|---|---|
| Sesión y cambio de cuenta | Se impide que respuestas tardías, reintentos de JSON o descargas XMI/ZIP iniciadas por una cuenta continúen con otra. Un refresh tardío tampoco restaura una sesión cerrada. | `frontend/tests/api.test.ts`, pruebas de sesión en navegador. |
| Renovación entre pestañas | Se comparte el refresh en vuelo y se serializa entre pestañas mediante Web Locks cuando está disponible. | Regresión de renovación y recarga simultánea de dos pestañas. |
| Cola de auditoría | Cada cuenta envía únicamente sus lotes. Un lote de una pizarra eliminada o sin acceso no bloquea el envío de los demás; los errores de envío en segundo plano se controlan. | Regresiones de aislamiento y cola bloqueada en `api.test.ts`. |
| Recuperación de contraseña | El consumo del enlace y el cambio de clave son atómicos. Recuperaciones simultáneas no pueden ganar las dos; cambiar la clave invalida enlaces anteriores. La interfaz abandona la sesión previa tras restablecer. | 21 pruebas de integración de perfil y regresión de navegador. |
| Permisos colaborativos | Antes de procesar sincronizaciones se revisan también los receptores conectados. Un miembro retirado o con JWT vencido deja de recibir nuevas ediciones; degradar a lector bloquea escritura. | 16 pruebas de colaboración, incluyendo miembros pasivos y caducidad. |
| Persistencia colaborativa | La comprobación de permisos conserva la última actualización recibida aunque el cliente se desconecte mientras se consulta la base. | Regresión de persistencia y reconexión. |
| Endpoint de sincronización | `/flush` rechaza cuerpos JSON inválidos, nulos o de tipo incorrecto con 400. | 12 pruebas unitarias de salud/entrada del proceso colaborativo. |
| Pizarra y generaciones | Consultar una pizarra usa la proyección viva, en lugar del snapshot histórico más reciente creado al generar. El ZIP conserva su snapshot inmutable. | Integración de generación. |
| Invitaciones concurrentes | Aceptar el mismo código simultáneamente no provoca errores 500 ni duplica membresías. | Integración de proyectos. |
| Importación a través de Nginx | El límite implícito de 1 MiB bloqueaba archivos aceptados por la API. El proxy admite ahora 24 MiB y un tiempo de espera mayor para visión. | Importación XMI de más de 1 MiB desde el navegador. |
| Errores del proveedor de IA | Un fallo al leer el cuerpo HTTP entra en el mecanismo de reintentos y de proveedor no disponible. | Tres regresiones de transporte en `shared/ai/tests/http.test.ts`. |
| Navegación | Las cargas fallidas de proyectos muestran error recuperable; la recuperación de cuenta vuelve al acceso. El proxy Vite elimina los prefijos correctos. | Pruebas de ruta inexistente, sesión y verificación previa de Vite. |
| Carga inicial | El editor se carga bajo demanda. JavaScript inicial: aproximadamente 331 kB, 99 kB comprimidos; antes eran aproximadamente 705 kB y 215 kB. | Build Vite final; el editor añade su propio bloque al abrirse. |
| Prueba de carga | Se corrigieron la multiplicidad de la muestra y la selección de la clase antes de moverla con teclado. | RNF-03 verifica 30 clases, 100 atributos y 40 relaciones en dos navegadores. |
| Interfaz móvil | A 320/360 px se desbordaba la cabecera; los participantes interceptaban «Salir» y algunos controles quedaban recortados. La cabecera distribuye identidad, acciones y estado, el acceso ajusta su ancho y el panel inferior usa todo el ancho del teléfono. | Los seis recorridos táctiles pasan; revisión de capturas a 320 px. Cambios en `frontend/src/styles.css`. |
| Enlaces de recuperación locales | La web funciona en 8080, pero `WEB_ORIGIN` apuntaba a 5173. Se ajustó el origen a `http://localhost:8080` en el entorno local y se recreó la API. | Configuración efectiva del contenedor; `infra/.env` permanece fuera de Git. |

La revocación WebSocket anterior ocurre al procesar sincronizaciones, no mediante un temporizador de expulsión instantánea. Las correcciones están respaldadas por regresiones; eso no equivale a demostrar ausencia de cualquier otro defecto.

## Verificación final

| Comprobación | Resultado |
|---|---|
| `npm run check` | Formato, ESLint y TypeScript correctos; **352 pruebas pasan**. La muestra real de Architect se procesa con avisos explícitos para clases asociativas y conectores auxiliares. |
| `npm run test:api` | **126 pruebas pasan**, con PostgreSQL efímero y WebSocket real. |
| `npm run build` y `npm run db:validate` | Compilación completa y esquema correctos. |
| Reconstrucción Docker | API, colaboración, migraciones y web reconstruidos en el proyecto aislado `uml-audit`. |
| Playwright contra Nginx y contenedores actuales | **68 escenarios distintos verificados:** 62 de escritorio y 6 táctiles; detalle de las pasadas debajo. |
| Banco de backends generado, ejecutado durante esta auditoría | **8 modelos**: T01–T06, T07R y T08; compilación Java 21/Maven, PostgreSQL, OpenAPI, CRUD, reinicio y restricciones de borrado. |
| Cinco participantes, 30 cambios | P95 de propagación **39,4 ms** en la última ejecución. Es loopback y excluye el render del navegador; no acredita la red del aula. |
| Diez pizarras | Aislamiento de estados verificado en integración. |
| `npm audit` | **4 paquetes afectados de severidad alta**, 0 críticos; siguen pendientes. |

La muestra de Enterprise Architect proporcionada ya se procesa en las pruebas del repositorio. Las pruebas de IA del entorno aislado utilizan adaptadores `mock`; la API, los permisos, los contenedores y PostgreSQL son reales. En una pasada anterior con Gemini real hubo respuestas válidas, pero también seis fallos de expectativas o tiempo de espera en la suite pensada para mocks. Esto requiere una aceptación específica con fotografías y consultas reales; no permite concluir que toda la integración de IA esté rota ni que ya esté validada.

La pasada completa de esta continuación terminó con **66 aprobadas y 2 fallidas**,
ambas de distribución móvil a 320/360 px. Después de corregir exclusivamente el
CSS adaptable se repitieron los seis recorridos táctiles: **6/6 aprobados en 24,8 s**,
sin omisiones ni reintentos. Los otros 62 recorridos ya estaban aprobados; no se
presentan estos resultados como una única pasada de 68 después del cambio CSS.
Los tamaños táctiles son 320×568, 360×800, 390×844, 430×932, 768×1024 y 844×390.
Es emulación Chromium, no validación de seis dispositivos físicos.

## Qué falta para completar la aplicación

### Prioridad para cerrar la entrega

1. **Enterprise Architect 15:** importar un XMI suyo y abrir uno nuestro allí; guardar archivos y resultados como fixtures/evidencia. Es la interoperabilidad que las pruebas internas no pueden acreditar.
2. **Demostración real:** ejecutar el recorrido completo en los equipos previstos, con red del aula, micrófono y fotografía de un diagrama real. Separar puertos de plataforma y backend generado, por ejemplo 8080 y 8081.
3. **Configuración efectiva:** usar `WEB_ORIGIN` con la URL que realmente abrirán los usuarios. Se corrigió el entorno local de 5173 a 8080; en la red del aula o internet deberá usarse su URL correspondiente. El correo `log` no entrega emails; configurar y probar el proveedor si se demostrará esa función.
4. **Alcance acordado:** confirmar que la retirada nativa/Dart está reflejada en la entrega exigida. La interfaz web táctil sí forma parte del código actual.
5. **Criterios todavía sin cierre:** completar contexto de registros RNF-14 y añadir la comprobación explícita de CA-068.2 sobre la configuración externa del proyecto generado.

### Funciones incompletas o mejoras de producto

| Pendiente | Estado actual | Criterio de cierre |
|---|---|---|
| Administración de miembros e invitaciones | La API tiene operaciones de roles, retirada y revocación; la web permite crear códigos pero no ofrece toda esa administración. | El propietario puede listar, modificar y retirar accesos desde la interfaz; una segunda sesión respeta el cambio. |
| Edición del candidato importado | Se pueden corregir nombres, tipos, nulabilidad, claves y multiplicidades. | Añadir roles, descarte de operaciones y validación reactiva antes de aplicar. |
| Copias y restauración para el usuario | Hay XMI y snapshots de generaciones; no hay copia/restauración JSON ni restauración de versiones desde la interfaz. | Recuperar un modelo de prueba sin depender de acceso a PostgreSQL. |
| Trabajo sin conexión prolongada | Se recuperan desconexiones transitorias con la pestaña abierta. La cola local guarda auditoría, no el documento Yjs completo. | Si se ofrece modo offline, persistir y recuperar el diagrama tras cerrar o recargar sin red. |
| Auditoría rechazada | Los lotes se conservan, pero no hay pantalla para recuperar o descartar errores permanentes. El almacenamiento compartido entre pestañas necesita más robustez. | Mostrar los lotes y su causa, permitir recuperación y probar escrituras concurrentes de la cola. |
| Reparación muchos a muchos | Se detecta el modelo no generable y se explica la entidad intermedia. | Si se incluye en el alcance, ofrecer una reparación guiada y atómica. |
| Accesibilidad y otros navegadores | Hay interacción por teclado y pruebas táctiles; no una auditoría WCAG completa ni pruebas equivalentes en Safari/Firefox. | Revisar foco, lector de pantalla y dispositivos físicos, además de emulación Chromium. |

### Antes de una publicación pública

- **Dependencias:** los cuatro avisos se agrupan en la cadena `prisma → @prisma/config → deepmerge-ts/mysql2`. La imagen de ejecución de la API no instala esos paquetes, comprobado con `npm ls`; el entorno de herramientas/migración sigue afectado. El arreglo automático propone bajar Prisma 7 a 6, por lo que no se aplicó un cambio mayor incompatible. Resolver con versiones compatibles y repetir esquema, migraciones e integración. Referencias: [deepmerge-ts](https://github.com/advisories/GHSA-ggr8-5vv4-36mx), [descompresión mysql2](https://github.com/advisories/GHSA-rgwj-5xj2-c3m3), [autenticación mysql2](https://github.com/advisories/GHSA-3f6p-5ww8-9rcr).
- **Sesiones revocables:** cambiar/restablecer contraseña revoca refresh tokens; los JWT de acceso emitidos siguen válidos hasta caducar, por defecto 15 minutos. Añadir comprobación revocable en HTTP y WebSocket si se promete cierre inmediato de todas las sesiones.
- **Abuso y exposición:** limitar intentos de autenticación/recuperación y consumo costoso de IA/generación; configurar HTTPS, cookies seguras y cabeceras de seguridad. Los puertos de base/API/colaboración no necesitan estar expuestos públicamente.
- **Operación:** copias de seguridad y ensayo de restauración, límites de recursos, rotación de logs, alertas y retención de tokens/snapshots. Las sondas de salud no sustituyen un ensayo de recuperación.
- **Integridad de auditoría:** los cambios que pasan por el editor se registran, pero un cliente Yjs directo autorizado puede editar sin enviar el lote HTTP de auditoría. No presentar ese registro como una bitácora inviolable del servidor.

## Evidencia y reproducción

El [índice de pendientes](pendientes.md) resume el orden de trabajo. Los artefactos locales de las pasadas anteriores están en `reports/revision-2026-09-05/` y los de esta continuación en `reports/auditoria-2026-09-05/`; esas carpetas están excluidas de Git.

- `antes-movil/`: capturas y trazas de la pasada completa, incluidos ambos fallos reproducidos y el editor de 30 clases.
- `movil-final.json` y `movil-final/`: resultados y capturas de los seis recorridos táctiles corregidos.
- `npm-audit.json`: los avisos de dependencias vigentes al finalizar.

Se reconstruyeron también los servicios de la aplicación local en el puerto 8080
conservando el volumen PostgreSQL y ajustando únicamente `WEB_ORIGIN` al 8080. Los proveedores reales
configurados allí no se sustituyeron por mocks. El entorno `uml-audit` fue
exclusivamente el entorno de pruebas de esta auditoría.
Se retiraron sus contenedores y su volumen de datos sintéticos al terminar;
se conservaron las capturas y los informes. La web local, `/api/health` y
`/collab/health` respondieron 200 después de actualizar la configuración.

Para repetir las comprobaciones: `npm run check`, `npm run test:api`, `npm run build`, `npm run db:validate` y `npm run test:bank`. Para navegador, levantar los contenedores actuales con proveedores simulados y ejecutar `npm run test:e2e`, definiendo `E2E_BASE_URL` si no se usa el puerto 8080. La aceptación de proveedores reales debe ejecutarse por separado.
