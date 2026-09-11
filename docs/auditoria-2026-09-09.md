# Auditoría de la aplicación — 9 de septiembre de 2026

Revisión posterior solicitada sobre colaboración y XMI: [hallazgos adicionales y estado actualizado](revision-colaboracion-xmi-2026-09-09.md). Los conteos de este documento corresponden a la primera ronda de correcciones.

La auditoría confirmó cinco defectos concretos, incluido uno que rompía la suite de integración. **B01–B05 ya están corregidos en el código del árbol de trabajo**, con pruebas de regresión. Esto no declara cerrado todo el proyecto: siguen pendientes las funcionalidades y verificaciones externas descritas más abajo.

Se auditó el árbol de trabajo existente, incluidos cambios sin commit. La fase inicial fue de diagnóstico; después se aplicaron las correcciones solicitadas, conservando los cambios previos. Las reproducciones iniciales están en `reports/audit-2026-09-09/` y las verificaciones de navegador de las correcciones en `reports/fixes-2026-09-09/` —directorios ignorados por Git—. El paquete Flutter utilizado en la revisión se generó en `generated-output/demo-ventas-ty1ZIh/`.

## Correcciones realizadas y verificación

| Bug | Corrección y regresión |
| --- | --- |
| B01 · Permisos desactualizados | La interfaz toma los permisos de la sesión colaborativa. El servidor notifica cambios de rol y el cliente consulta también cada cinco segundos y al recuperar el foco. Al perder escritura descarta su réplica local y carga una nueva desde el servidor, avisando de los cambios rechazados. Dos pruebas de navegador cubren degradación/ascenso de un participante pasivo y reconexión tras editar sin red. |
| B02 · Relaciones XMI omitidas | La deduplicación compara tipo, ambos roles y cardinalidades; solo permite invertir asociaciones simétricas. Reconoce los roles predeterminados escritos por el exportador para conservar la reimportación sin duplicados. Regresiones con T07R, extremos invertidos y cambios de tipo/cardinalidad. |
| B03 · Colisiones XMI bloqueadas | La resolución XMI conserva los nombres exactos para distinguir los elementos antes de editar el candidato. La fusión ADD dirige atributos y enlaces al nombre real de la clase existente. RF-052 comprueba clases con nombres técnicos coincidentes, sus atributos y el enlace entre ellas; la prueba de navegador corrige el nombre y aplica el candidato con dos usuarios. |
| B04 · Propuestas obsoletas | Antes de aplicar se comparan los elementos afectados con el modelo enviado al preparar la propuesta, incluyendo relaciones eliminadas indirectamente. Si cambiaron, se rechaza el lote, se retira el botón de aplicación y se recupera la instrucción para enviarla y revisarla de nuevo. Cinco pruebas de dominio y una de navegador cubren cambios relevantes y cambios ajenos que sí deben permitirse. |
| B05 · Límite de transcripción | La ruta acepta el máximo de 8.000.000 caracteres base64 más la envoltura JSON. Se prueban 1.100.000 y 8.000.000 caracteres aceptados, exceso de contrato con HTTP 400 y exceso del cuerpo con HTTP 413; las demás rutas mantienen su límite. |

Verificación posterior: **464/464 pruebas unitarias**, **129/129 pruebas de integración** y **80/80 recorridos de navegador** aprobados, incluidos los cuatro nuevos casos de regresión. TypeScript, ESLint, Prettier y compilación de producción aprobados. Las suites de API y navegador aislado usan PostgreSQL temporal y proveedores IA simulados; no acreditan inferencia real, micrófono ni dispositivos físicos.

También se reconstruyeron y actualizaron los contenedores locales `api`, `collab` y `web`, conservando PostgreSQL y sus datos, sin ejecutar migraciones. Los cuatro servicios quedaron saludables y `/`, `/api/health` y `/collab/health` respondieron HTTP 200 en `http://localhost:8080`. Las **4/4 regresiones nuevas** se repitieron satisfactoriamente contra ese despliegue con cuentas de prueba independientes; la propuesta de IA de ese recorrido se intercepta de forma determinista y no consume un proveedor real.

Comandos de verificación: `npm test`, `npm run test:api`, `npm run typecheck`, `npm run lint`, `npm run format:check`, `npm run build`; suite aislada mediante `node --import tsx reports/fixes-2026-09-09/run-current.mjs`; regresiones Docker mediante `node node_modules/@playwright/test/cli.js test --config e2e/playwright.config.ts auditoria-regresiones`. El ejecutor aislado y los resultados E2E están en el directorio local de evidencia; las pruebas nuevas están en `e2e/specs/auditoria-regresiones.spec.ts`, `shared/domain-core/tests/proposal-preconditions.test.ts` y las suites existentes de XMI e integración.

Los resultados de la sección siguiente son la evidencia **anterior a las correcciones**, conservada para contrastar el diagnóstico.

## Alcance y evidencia de esta ejecución

Se contrastaron el plan maestro local, los requisitos del docente del 6 de septiembre, los pendientes, el código y las pruebas. La revisión comprende cuentas, proyectos, permisos, editor, colaboración, IA, importación/exportación, generación Spring y base Flutter. Las verificaciones de PostgreSQL usaron contenedores temporales.

| Comprobación | Resultado de la auditoría inicial |
| --- | --- |
| TypeScript, ESLint y Prettier | Aprobados antes de añadir este informe |
| Compilación de los workspaces y frontend de producción | Aprobada |
| Pruebas rápidas | **455/455** aprobadas, 28 archivos |
| Integración HTTP y colaboración con PostgreSQL | **126/127** aprobadas; falla RF-052 de importación |
| E2E sobre los contenedores locales existentes y proveedores reales configurados | **71/76** aprobadas; cinco fallos por espera agotada en asistente/fotografía |
| E2E aislado: compilación actual, PostgreSQL temporal, API y colaboración reales, IA simulada | **76/76** aprobadas; 6,1 minutos |
| Banco Spring T01, T02, T03, T04, T05, T06, T07R y T08 | **8/8**: emisión, compilación, arranque, OpenAPI/Postman, CRUD, reinicio/persistencia y restricciones de borrado |
| Backend del paquete móvil | Aprobados login, renovación persistente, revocación por dispositivo/cambio de clave, CORS, CRUD, reintentos, reinicio y conflictos |
| Flutter recién generado: dependencias, análisis y pruebas | `flutter pub get` completado, `flutter analyze` sin incidencias y **18/18** pruebas aprobadas; no se compiló un APK nuevo ni se ejecutó GGUF físico |
| Reproducciones adicionales | Confirmados permisos desactualizados en UI, dos fallos XMI, propuesta obsoleta y límite de audio |
| Auditoría npm | Seis paquetes afectados: cuatro de severidad alta y dos moderada; cero críticos. Con `--omit=dev` siguen apareciendo cuatro altos |

Los fallos iniciales de Vitest/Vite por acceso denegado fueron restricciones del sandbox: al ejecutar con acceso autorizado pasaron. No se contabilizan como bugs. La repetición E2E aislada usa un proxy Vite sobre el frontend compilado; no acredita por sí sola una reconstrucción nueva de la imagen nginx. El recorrido inicial sí ejercitó el despliegue local existente.

Los cinco fallos de IA real no prueban cinco defectos distintos de interfaz: esas pruebas esperan respuestas y tiempos propios del adaptador simulado. Su resultado sí muestra que el entorno real necesita ensayo y diagnóstico antes de la defensa. No se acreditó la calidad de reconocimiento de una fotografía real ni de dictado físico.

## Defectos confirmados

P1 significa corregir antes de cerrar la entrega; P2, defecto de alcance más acotado. No se encontró un P0 que bloquee todos los recorridos principales.

### B01 · P1 · Permisos desactualizados producen cambios aparentes que se pierden

- **Reproducción:** propietario y editor abren la misma pizarra; el propietario cambia al editor a `VIEWER` mediante la API; el editor crea una clase.
- **Resultado:** “Nueva clase” sigue habilitado, la clase aparece localmente y el estado sigue mostrando “En vivo”. La auditoría recibe 403, el propietario no recibe esa clase y al recargar desaparece. Tras recargar los controles sí quedan deshabilitados.
- **Causa:** `BoardPage` consulta el rol al abrir la pizarra y `useBoardDocument.dispatch` conserva ese permiso. El servidor actualiza su autorización, pero el frontend no refleja el nuevo rol ni descarta/reconcilia la modificación rechazada.
- **Ubicación:** [BoardPage.tsx](../frontend/src/features/editor/BoardPage.tsx), líneas 80–99; [useBoardDocument.ts](../frontend/src/features/editor/useBoardDocument.ts), desde la línea 207.
- **Cierre:** comunicar/reconsultar cambios de permiso, deshabilitar edición y avisar de escrituras rechazadas. Probar degradación y expulsión con pestañas ya abiertas, además del acceso inicial como lector.
- **Evidencia:** `reproduction.json`, apartado `roleDowngrade`, y `role-downgrade.png`.

El control del servidor funcionó: este hallazgo es una inconsistencia de interfaz/estado local, no una demostración de escritura no autorizada en PostgreSQL.

### B02 · P1 · Importar XMI omite relaciones distintas entre el mismo par de clases

- **Reproducción:** usar T07R, conservar la relación `facturacion` entre Cliente y Order y quitar solo `envio`; importar en modo ADD el XMI completo.
- **Resultado:** el parser lee las cuatro relaciones, pero el conversor no emite ninguna operación de creación. El modelo actual tiene tres relaciones y no recupera la cuarta; se informa incorrectamente que la relación ya existe.
- **Causa:** la deduplicación compara solamente el par de clases en ambas direcciones. No compara los roles, el tipo ni las multiplicidades.
- **Ubicación:** [to-proposal.ts](../shared/xmi/src/to-proposal.ts), líneas 105–113.
- **Cierre:** identificar relaciones considerando sus extremos y semántica, conservar relaciones paralelas y distinguir “igual” de “diferente”. Añadir regresión de importación incremental con facturación/envío.
- **Evidencia:** `domain-reproduction.json`, apartado `parallelRelationship`.

### B03 · P1 · Colisiones de nombres en XMI dejan la importación sin camino de corrección

- **Reproducción:** importar en una pizarra vacía un XMI con `Detalle de Venta` y `detalle venta`, ambas normalizadas a `DetalleVenta`.
- **Resultado:** la API responde `QUESTION`; no hay candidato editable ni botón Aplicar. “Reintentar reemplazando” devuelve la misma pregunta aun sobre un modelo vacío.
- **Causa:** el resolver por nombres corta la conversión al encontrar la segunda clase. La UI de importación solo permite corregir un `BATCH`/`CONFIRMATION`; no puede responder ni editar el contenido de ese `QUESTION`.
- **Ubicación:** [resolver.ts](../shared/ai/src/resolver.ts), líneas 179–187; [ImportPanel.tsx](../frontend/src/features/import/ImportPanel.tsx), líneas 398–419.
- **Cierre:** preservar identidad de elementos XMI durante la preparación y ofrecer corrección de nombres antes de resolver/aplicar, o un flujo real para solucionar la colisión. Cambiar simplemente el esperado del test a `QUESTION` no resuelve el bloqueo de usuario.
- **Evidencia:** falla existente en [import.integration.test.ts](../backend/api/tests/integration/import.integration.test.ts), línea 190; `reproduction.json`, apartado `xmiCollision`; `xmi-collision.png`.

### B04 · P1 · Una propuesta obsoleta puede borrar trabajo añadido después de su preparación

- **Reproducción:** preparar una propuesta “Eliminar Cliente” cuando la clase está vacía; otro colaborador añade un atributo; aplicar la propuesta original.
- **Resultado:** el lote se acepta y elimina también el atributo nuevo, aunque el resumen revisado solo hablaba de la clase vacía. El alcance destructivo se calculó contra el estado anterior.
- **Causa:** el panel guarda comandos resueltos por ID y aplica directamente el lote. Su contador `revision` protege cambios de pizarra/desmontaje, no cambios semánticos de colaboradores.
- **Ubicación:** [AssistantPanel.tsx](../frontend/src/features/assistant/AssistantPanel.tsx), líneas 177–178; [resolver.ts](../shared/ai/src/resolver.ts), cálculo inicial del alcance destructivo.
- **Cierre:** comprobar antes de aplicar que los elementos afectados mantienen las precondiciones revisadas. Ante cambios, recalcular la propuesta y solicitar de nuevo la confirmación con el alcance vigente. No basta con verificar que siga existiendo el UUID.
- **Evidencia:** `domain-reproduction.json`, apartado `staleProposal`; reproducción directa del resolver y aplicador actuales, contrastada con el flujo del panel.

### B05 · P2 · El endpoint de transcripción rechaza audio permitido por su propio contrato

- **Reproducción:** enviar a `/assistant/transcribe` un cuerpo con 1.100.000 caracteres base64, por debajo del máximo declarado de 8.000.000.
- **Resultado:** HTTP 413 `fst_err_ctp_body_too_large` antes de llegar al proveedor.
- **Causa:** la ruta conserva el límite HTTP general de Fastify; la ruta de imagen sí declara un límite mayor.
- **Ubicación:** [routes.ts de IA](../backend/api/src/modules/ai/routes.ts), líneas 57–61 y 147.
- **Cierre:** alinear el límite HTTP con el contrato y verificar cuerpos justo por debajo/encima del límite.
- **Evidencia:** `reproduction.json`, apartado `audioLimit`. No se llamó al proveedor en esta reproducción.

El dictado web actual utiliza reconocimiento del navegador y no llama a este endpoint. Su impacto afecta al respaldo de transcripción de la API, no a todo el dictado existente.

## Riesgos y verificaciones adicionales

- **Dependencias:** `npm audit` señala `prisma`, `@prisma/config`, `deepmerge-ts`, `mysql2`, `vitest` y `@vitest/mocker`. Son seis paquetes afectados, no necesariamente seis vulnerabilidades independientes. Hay propagación de avisos por dependencias transitivas. El escaneo no demuestra explotación de la API desplegada; su Dockerfile instala un subconjunto y no se auditó el contenido de la imagen como SBOM. Revisar una actualización compatible, no aplicar automáticamente la degradación mayor de Prisma sugerida por npm. Los JSON completos están guardados en el directorio de evidencia.
- **Móvil con red lenta:** `AppModel.sync()` marca `busy=true` antes de verificar el contrato remoto; guardar/eliminar se bloquea mientras tanto y el temporizador repite sincronización cada 30 segundos. El cliente HTTP espera hasta 20 segundos por petición. Puede perjudicar el uso local con una conexión que no responde. Es un riesgo inferido del código, pendiente de reproducción temporal/dispositivo; no se incluye entre los cinco bugs confirmados.
- **Auditoría de operaciones:** la cola utiliza lecturas/escrituras de un JSON compartido en localStorage sin exclusión entre pestañas. Los rechazos permanentes se conservan, pero no existe una recuperación guiada. La auditoría depende del cliente HTTP y no cubre autoritativamente cualquier escritura de un cliente Yjs directo.
- **Historial de artefactos:** por diseño, los ZIP se regeneran desde snapshot/manifiesto. Si cambia el generador, una descarga antigua puede devolver `artifact_drifted`. Es una limitación conocida, no un defecto nuevo. Si se exige recuperar siempre exactamente los ZIP anteriores, falta almacenarlos o versionar el emisor.
- **Cobertura móvil en CI:** el workflow actual ejecuta Node, API, Spring y navegador, pero no incorpora `flutter analyze`, `flutter test` ni el verificador del backend móvil. La nueva ampliación puede romperse sin bloquear el CI existente.

## Funciones y trabajo que faltan para cerrar el proyecto

### Entrega según las notas del docente

| Pendiente | Estado real y criterio de cierre |
| --- | --- |
| Aplicación Flutter de demostración adaptada al caso presentado | Hay generador opcional y base reutilizable. Falta preparar y ensayar las pantallas/caso de gestión que se construirán o adaptarán durante la presentación. Las notas no exigen generar Flutter automáticamente. |
| Agente GGUF en Android físico | Motor, contrato y revisión CRUD existen. Falta elegir/cargar pesos compatibles y demostrar altas, consultas, cambios, negaciones y ambigüedad con calidad, memoria y latencia aceptables. No se validó inferencia real en esta auditoría. |
| Voz y operación móvil completamente offline | Probar en modo avión, cerrar/reabrir, conservar los datos, recuperar conexión y enviar una sola vez. Probar también dos dispositivos con modificaciones incompatibles. SQLite y recibos ya existen; falta acreditar el recorrido físico completo. |
| Interacción sin teclado ni mouse, si se evalúa literalmente | El flujo web y móvil aún usa botones para enviar/revisar/aplicar. Faltan órdenes de control y confirmación por voz. Si se exige escucha offline garantizada, falta un STT local controlado por la app; el reconocedor Android no lo garantiza en todos los equipos. |
| Enterprise Architect 15 | Cerrar app → EA → app después de la corrección del exportador. Revisar tipos, claves, roles, cardinalidades y posiciones. Los tests propios no sustituyen abrir el archivo en EA real. |
| Fotografía y proveedores reales | Usar fotografías reales del aula y micrófono real; diagnosticar tiempos, permisos, cuotas y fallbacks. Un PNG de un píxel y respuestas simuladas solo prueban el flujo. |
| Ensayo integrado | Usuarios distintos → colaboración → modelo nuevo → ZIP → IDE → PostgreSQL vacío → Postman → Flutter → offline → reconexión. Cronometrarlo en los equipos/red previstos y comprobar puertos/configuración. |

### Funcionalidad incompleta de la plataforma

1. **Administración web de miembros:** cambiar roles, retirar miembros, listar/revocar invitaciones. La API ya ofrece operaciones; faltan controles en la interfaz.
2. **Completar la revisión de importación:** editar roles de relaciones, quitar operaciones, validar reactivamente y resolver otras ambigüedades. La colisión XMI descrita en B03 ya permite editar el candidato y corregir los nombres.
3. **Respaldo y recuperación por el usuario:** exportación/restauración JSON o equivalente y recuperación de versiones de la pizarra. El historial de generaciones no equivale a restaurar el documento.
4. **Auditoría recuperable:** mostrar causa y acciones para lotes rechazados; coordinación durable de la cola entre pestañas y política para evitar pérdida/crecimiento indefinido.
5. **Robustez del asistente:** cancelar peticiones remotas en curso, limitar consumo por usuario y conservar trazabilidad de intentos/resultados según el alcance acordado. La detección de propuestas obsoletas descrita en B04 ya está implementada.
6. **Actualización compartida del historial:** ver generaciones creadas por otros colaboradores sin reabrir/refrescar el panel.
7. **Accesibilidad y compatibilidad:** completar auditoría de teclado/lector de pantalla y probar navegadores distintos de Chromium y dispositivos físicos.

### Publicación y opciones que no deben confundirse con requisitos obligatorios

- Antes de publicar: HTTPS, cookies seguras, puertos mínimos, límites de acceso/recuperación/IA/generación, correo operativo, backups con restauración ensayada, supervisión y retención de datos/registros. Si se promete cierre instantáneo de todas las sesiones web, falta revocación inmediata de JWT de acceso, además de refresh tokens.
- Si se distribuye Android: firma y configuración release/HTTPS y una estrategia de actualización; el APK debug previo no equivale a una distribución final.
- Si se ofrece edición web offline a través de recargas: persistir el Y.Doc localmente. Hoy la recuperación de desconexión transitoria requiere conservar la pestaña.
- Sincronización móvil con la app cerrada, sincronización incremental, migración automática de contratos, reglas de negocio compuestas y perfil semántico configurable son ampliaciones; no se deducen todas como obligaciones del parcial.
- Deshacer propio, reparación guiada de muchos a muchos y bloqueo exclusivo por elemento siguen siendo opcionales o requieren confirmación del alcance. CRDT ya resuelve convergencia; no equivale a bloqueo exclusivo.

## Documentación que debe ponerse al día

- `docs/pendientes.md` todavía menciona renovación móvil automática como faltante, pero `templates/flutter/lib/data/api.dart.tpl`, `MobileSessions.java.tpl` y sus pruebas ya la implementan.
- El índice de requisitos y varios párrafos siguen diciendo que nativo/Dart fue retirado sin distinguir esa retirada histórica de la nueva base Flutter Android.
- El plan maestro está disponible localmente, pero `docs/referencia/` se ignora en Git. Un clon limpio no recibe la especificación completa enlazada por el README; se necesita una referencia versionable/autorizada.
- La evidencia histórica de 8/23/442 pruebas no debe reemplazar los resultados de esta ejecución ni presentarse como verificación de GGUF/voz reales.

## Orden de cierre propuesto

1. **Completado:** corregir B01–B05 y añadir regresiones; integración 129/129, incluido RF-052 con expectativas reforzadas.
2. Resolver los avisos de dependencias con una actualización evaluada.
3. Completar administración web y revisión de importación; definir recuperación/auditoría según el alcance de entrega.
4. Validar Android físico, GGUF, voz/foto y Enterprise Architect.
5. Ensayar de punta a punta y consolidar requisitos, evidencia, configuración de despliegue y pendientes reconocidos.

Pasar todas las suites existentes no garantiza ausencia de bugs: cuatro de los cinco defectos confirmados requirieron casos adicionales a los tests habituales. Tampoco acredita por sí solo el comportamiento de dispositivos, proveedores y programas externos.
