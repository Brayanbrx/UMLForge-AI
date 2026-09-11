# Generación Flutter Android y backend de gestión

Actualización de modelos locales: la plantilla incorpora biblioteca de archivos,
selección independiente de voz/texto, LiteRT-LM y GGUF para instrucciones, y
Whisper GGML para dictado local. Esta ampliación sustituye el selector de un solo
GGUF y el dictado del reconocedor de Android descritos en las revisiones históricas
de abajo. Configuración y límites en la
[guía de modelos locales de la plantilla](../templates/flutter/docs/local-models.md.tpl).
La integración remota con las IA de `infra/.env` y la lectura directa de OpenAPI
siguen pendientes; el contrato móvil y la cola SQLite se conservan.

Revisión del 6 de septiembre de 2026. Se incorporó un generador opcional de Flutter Android a partir del mismo diagrama y DTO que Spring Boot. La generación usa plantillas deterministas: no llama a proveedores IA ni consume tokens. El asistente generado utiliza un GGUF local cuando el usuario lo carga.

Comprobación posterior: [8 diagramas de gestión, 34 recursos CRUD y aclaración CORS](revision-generador-crud.md). Se verificaron los backends del perfil Android y siete pruebas de SQLite/cola, sin probar el agente IA.

## Ampliación en código: cliente reutilizable y agente offline

La revisión posterior añade `/mobile-contract` autenticado al backend y su lectura en el login Android. La misma base Flutter adopta recursos, campos, claves y relaciones del backend conectado, conserva el contrato para abrir offline y comprueba compatibilidad antes de enviar cambios. El cambio de servidor se realiza cerrando sesión e iniciando en la otra URL. Datos y colas quedan separados por servidor/cuenta/contrato; se conserva el espacio local del contrato original del APK previo.

El agente propone CREATE, UPDATE, DELETE o LIST utilizando el contrato y los registros filtrados. Las operaciones confirmadas se guardan en la misma SQLite que los formularios; LIST muestra datos locales. Los UUID de altas se generan en el dispositivo. `AgentPort` permite sustituir el motor local sin cambiar el repositorio, y la selección de plantilla GGUF (incluida `gemma`) se conserva al reabrir. El motor local funciona igual con o sin internet; la compatibilidad de pesos cuantizados concretos debe probarse.

La cola permite consolidar ediciones que nunca se intentaron enviar y cancelar altas locales eliminadas antes del primer envío. A partir del primer intento mantiene la solicitud inmutable. `tool/start_backend.dart` prepara credenciales aleatorias si falta `.env` y arranca Compose, con puertos configurables. No reemplaza configuraciones existentes.

**Estado de esta ampliación:** APK debug ARM64 compilado; análisis Flutter, TypeScript y lint aprobados. Se ejecutaron 4 pruebas Flutter de contrato/login y 23 del generador. Backend real con PostgreSQL: contrato autenticado, login, sincronización y preflight CORS permitido/rechazado para CRUD, login, contrato y cola aprobados. La revisión posterior agregó ocho modelos completos, un caso con claves enteras y siete pruebas de almacenamiento/cola, incluida consolidación offline. No se ejecutaron pruebas del agente, inferencia GGUF ni dictado, por indicación del usuario. El bloqueo anterior por límite de uso dejó de impedir estas verificaciones.

La base incluye registro de pantallas en `mobile/lib/ui/custom_pages.dart`: se muestran según los recursos disponibles en el contrato. Añadir pantallas propias requiere recompilar Flutter; cambiar URL/contrato compatible no. La guía `mobile/docs/extension-and-deployment.md` incluye un ejemplo completo, variables de despliegue, HTTPS, CORS y distribución. Se emite `backend/railway.json` para Docker y healthcheck. No se ha publicado ningún servicio externo.

La compatibilidad abarca los backends emitidos con el perfil Android de esta versión. Para usar un backend REST diferente hay que implementar el protocolo de login, contrato y sincronización. La primera configuración necesita internet; después la cola funciona offline. El envío automático ocurre con la app abierta o al reabrir, no como un servicio Android permanente. Cambios incompatibles de esquema requieren resolver la cola con el backend anterior; no se migran automáticamente datos de negocios distintos.

## Cómo usarlo

1. En la pizarra, abrir **Generación**, marcar **Incluir Flutter Android con login, datos offline y modelo GGUF** y generar.
2. Descargar **Android + backend**. El ZIP contiene `backend/`, `mobile/` y sus instrucciones. Usar el backend de este paquete para el móvil: incluye autenticación y sincronización.
3. Copiar `backend/.env.example` a `backend/.env` y configurar `DB_PASSWORD`, `AUTH_PASSWORD` y `AUTH_TOKEN_SECRET`. Los valores AUTH se entregan vacíos; reemplazar también el marcador de contraseña de PostgreSQL. La contraseña de acceso requiere al menos 12 caracteres y como máximo 72 bytes; el secreto requiere 32 caracteres como mínimo. Generarlo aleatoriamente.
4. En `backend/`, ejecutar `docker compose up -d --build`. También puede ejecutarse con Java/Maven y PostgreSQL externo, según su README. Postman incluye login y captura automática del token; configurar usuario y contraseña en un entorno privado.
5. Instalar Flutter y Android SDK/NDK. En `mobile/`, ejecutar `dart run tool/bootstrap.dart`, `flutter pub get` y `flutter run`. El bootstrap crea el proyecto Android nativo con el SDK local sin reemplazar uno existente. Compilación probada con Flutter 3.44 / Dart 3.12, Android ARM64, API mínima 26.
6. El emulador usa `http://10.0.2.2:8081`. En un teléfono configurar la dirección LAN del servidor. HTTP solo se permite en debug; release necesita HTTPS y firma propia.
7. En Asistente, cargar un GGUF compatible y elegir su plantilla de conversación. Después de reiniciar, pulsar **Abrir guardado**. Los pesos no se incluyen ni se descargan automáticamente.

Si está levantada la plataforma UML o el ejemplo anterior, sus puertos pueden estar ocupados: elegir otros `APP_PORT` y `DB_PORT` en el `.env` del backend generado (por ejemplo 8082 y 5435 si están libres) y usar ese puerto de aplicación en el login móvil. El ejemplo anterior no fue sustituido.

Ejemplo reproducible desde este repositorio: `npx tsx scripts/generate-demo-backend.ts --mobile`. Crea un directorio nuevo dentro de `generated-output/`, el ZIP, el diagrama XMI y el modelo JSON. Comprobación real del backend: `npx tsx scripts/verify-mobile-backend.ts` (Java, Maven y Docker necesarios).

## Implementado

- Spring Boot/PostgreSQL con Modelo, Repositorio, Servicio, Controlador y DTO; validaciones, errores JSON, OpenAPI, Postman, Dockerfile y Compose.
- Perfil Android con administrador configurado por entorno y Bearer token. Las rutas de datos requieren autenticación. El ZIP Spring independiente conserva su comportamiento anterior.
- Flutter Material 3 con login, colecciones, CRUD, búsqueda local, asistente y ajustes. Capas UI/ViewModel, repositorio y HTTP/SQLite; relaciones mediante IDs del contrato.
- Sesión en almacenamiento seguro; no guarda la contraseña. Datos y cola SQLite separados por servidor, cuenta y contrato.
- Guardado local transaccional antes del envío. Reintentos mantienen operación, ID, datos y base; PostgreSQL guarda recibos transaccionales para evitar duplicados, incluso después de reiniciar el backend.
- Detección de cambios remotos y conflictos; confirmación para descartar un cambio rechazado y aceptar el servidor. Un error de red no permite descartar una operación posiblemente aplicada.
- Protección contra formularios o propuestas abiertas sobre datos que cambiaron durante la revisión. Las operaciones pendientes se mantienen inmutables hasta sincronizar o resolver su conflicto.
- GGUF en el dispositivo, contexto acotado al recurso y registros filtrados, salida JSON validada y revisión antes de ejecutar. No permite SQL, URLs ni llamadas arbitrarias propuestas por el modelo.

## Evidencia

- TypeScript y ESLint: sin errores.
- 455 pruebas unitarias del repositorio aprobadas.
- Integración HTTP de generación: 29 pruebas aprobadas, incluyendo bytes/hash de ambos objetivos.
- Backend móvil real compilado y ejecutado con PostgreSQL: login válido/inválido, rutas protegidas, IDs, reintentos concurrentes, recibos tras reinicio, conflictos y borrados aprobados.
- Flutter: `analyze` sin incidencias y 8 pruebas aprobadas. Incluyen login a 360 px sin desbordamiento, persistencia SQLite tras reapertura, confirmación perdida, edición obsoleta, conflictos y validación de propuestas.
- APK debug ARM64 compilado. Esto no acredita rendimiento de un modelo GGUF ni funcionamiento del reconocedor de voz en un teléfono concreto.
- Navegador Chromium contra la app local actualizada: 2 pruebas aprobadas, incluyendo descarga de ambos ZIP y visibilidad de los botones. API y web están funcionando tras aplicar la migración de generación Android.

## Faltantes y límites concretos

| Prioridad | Pendiente | Criterio para cerrarlo |
| --- | --- | --- |
| Alta, demostración | GGUF real en Android físico | Cargar un modelo de instrucciones con licencia adecuada, probar altas/ediciones/negaciones en modo avión y medir RAM, latencia y batería. |
| Alta, demostración | Voz totalmente offline | Verificar reconocedor e idiomas locales instalados. El dictado solicita procesamiento local, pero Android puede finalizar la escucha; GGUF interpreta texto, no transcribe audio. Si se requiere voz continua garantizada, hace falta un motor STT local controlado por la app. |
| Alta, entrega | Recorrido completo con Flutter físico y PostgreSQL | Primer login, modo avión, CRUD por texto/voz, cierre/reapertura, reconexión, conflicto entre dispositivos y referencias entre entidades. |
| Antes de publicación | Distribución y acceso | Firma release, HTTPS, copias/restauración y permisos del caso de uso. El login generado es un administrador compartido, sin registro, recuperación, roles ni aislamiento por empresa. |
| Según el caso | Reglas de negocio | Cobros, inventario, totales y transacciones entre entidades no se deducen del UML; implementar el flujo específico de gestión. |
| Escala/producción | Sincronización incremental | Se descargan colecciones completas; no hay paginación incremental ni merge automático. Definir retención de recibos y migración de datos locales al cambiar el contrato. |
| Automatización | Validación Android en CI | La compilación y pruebas se ejecutaron localmente; incorporar SDK/NDK y pruebas del APK a la canalización según el entorno de CI. |

La sesión remota dura 15 minutos; volver a iniciar sesión con la misma cuenta conserva la cola. Los datos SQLite no están cifrados y dependen del aislamiento y bloqueo del dispositivo. La comparación de conflictos usa el DTO original: una modificación que vuelve al mismo contenido puede no distinguirse de su versión original. No se promete sincronización semántica entre operaciones de negocio.

## Incidencias adicionales encontradas

SambaNova estaba habilitado como respaldo con credencial vacía, impidiendo iniciar toda la API. Se desactivó únicamente esa entrada en las cadenas locales de texto/visión y se añadieron al Compose las variables SambaNova y la URL Groq que faltaban. Para activarlo, configurar su credencial y cambiar `enabled` a `true`.

La auditoría npm informa cuatro dependencias con severidad alta en el árbol de Prisma (`prisma`, `@prisma/config`, `deepmerge-ts` y `mysql2`). La solución automática propuesta baja Prisma de versión mayor; no se aplicó por riesgo de incompatibilidad. Revisar actualización compatible y exposición real por separado. El backend generado usa PostgreSQL. Gradle también advierte que tres plugins aún aplican KGP; compiló, pero habrá que validar compatibilidad al actualizar Flutter.
