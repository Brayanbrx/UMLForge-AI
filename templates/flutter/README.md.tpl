# Android de gestión

Interfaz Material 3: login, CRUD por colección, búsqueda local, asistente con LiteRT-LM o GGUF, voz con Whisper local y cola de sincronización. Arquitectura UI/ViewModel → Repository → HTTP/SQLite. El contrato se genera desde el mismo snapshot que Spring Boot.

## Base reutilizable entre aplicaciones

Al iniciar sesión, la app obtiene `/mobile-contract` del backend autenticado (protocolo 1). Colecciones, campos, claves, relaciones y título se adaptan a ese contrato y se conservan en la sesión para abrir sin internet. Cambiar de backend desde Ajustes → Cerrar sesión / cambiar backend. Cada servidor/cuenta/contrato mantiene su SQLite y cola separados; no se mezclan pendientes entre negocios. Antes de enviar la cola se verifica que el contrato siga siendo compatible. Si cambia, se conservan los pendientes y se bloquea el envío; restaurar la versión compatible para resolverlos. No hay migración automática entre contratos diferentes.

El backend debe generarse con el perfil **Android + backend** de esta versión. Un REST arbitrario o el ZIP Spring independiente necesita implementar `/session/login`, `/mobile-contract` y `/mobile-sync`; cambiar solamente la URL no adapta protocolos distintos. La flexibilidad cubre cualquier modelo aceptado por el generador y las operaciones CRUD del contrato, no reglas de negocio que no estén implementadas.

La primera configuración requiere conexión para iniciar sesión y obtener el contrato. Después, tanto formularios como propuestas del agente escriben en SQLite y se sincronizan cuando la aplicación está abierta y el backend es accesible. Android no mantiene este proceso vivo con la app cerrada: al reabrir se retoma la cola. No se envía la instrucción sin interpretar para ejecutarla después; se guarda la operación validada y confirmada.

## Preparación

Flutter 3.44 / Dart 3.12 o compatible, Android SDK y NDK 29.0.13113456. Ejecutar `dart run tool/bootstrap.dart`, `flutter pub get`, `flutter analyze`, `flutter test`, `flutter run`. El bootstrap crea el armazón nativo Android con el SDK instalado sin reemplazar un proyecto Android existente. API mínima 26. Para generar APK: `flutter build apk --debug --target-platform android-arm64`. Para distribución usar firma release propia y backend HTTPS; el permiso HTTP está limitado a debug.

Arranque rápido del backend desde `mobile/`: `dart run tool/start_backend.dart 8082 5435`. Crea `../backend/.env` si falta, con credenciales aleatorias, y ejecuta Docker Compose. Si ya existe `.env`, conserva sus valores y puertos. Consultar allí AUTH_USERNAME/AUTH_PASSWORD. Con esos puertos, el emulador usa `http://10.0.2.2:8082`; en teléfono usar la IP LAN del equipo. No publicar `.env`.

El backend del paquete debe configurar AUTH_USERNAME, AUTH_PASSWORD y AUTH_TOKEN_SECRET. Es una cuenta administradora para una aplicación de gestión compartida, no un sistema multiempresa ni administración de usuarios. El token vence a los 15 minutos; volver a iniciar sesión renueva el acceso remoto. La sesión se guarda en el almacenamiento seguro del sistema; no se guarda la contraseña. El primer login requiere conexión. Los datos SQLite no están cifrados: dependen del aislamiento de Android y del bloqueo del dispositivo. Cerrar sesión conserva los datos/cola separados por servidor, cuenta y contrato.

## Offline

Altas y cambios se guardan en una transacción SQLite antes del envío. La sincronización se intenta cada 30 segundos, al volver al primer plano y manualmente. Reintentos conservan el mismo operationId y el servidor guarda un recibo en PostgreSQL. Antes del primer intento se pueden consolidar ediciones de un mismo registro; crear y luego borrar un registro aún no enviado cancela esa alta. Después del primer intento se exige sincronizar o resolver su conflicto antes de editarlo otra vez, porque el servidor podría haber aplicado una solicitud cuya respuesta se perdió. La migración de colas antiguas las trata como ya intentadas.

Las claves UUID se generan en el móvil; las numéricas/textuales las introduce el usuario. Las relaciones requieren IDs existentes: crear primero el padre. Colisiones o discrepancias con los datos originales se presentan como conflictos y frenan la cola. Se permite aceptar explícitamente la versión del servidor y volver a editar. La descarga completa de cada colección conserva cambios locales pendientes y elimina registros remotos borrados; no implementa sincronización incremental para grandes volúmenes.

El backend compara el DTO original con el actual antes de editar/borrar y usa bloqueo de fila, versión JPA y recibos transaccionales. No es un merge automático de negocio; una modificación que vuelve exactamente al mismo contenido puede no distinguirse de la versión original. Los recibos deben mantenerse mientras puedan llegar reintentos de dispositivos offline; diseñar su retención antes de un despliegue prolongado.

## Modelos locales de texto y voz

En Asistente, importar archivos `.litertlm` o `.gguf` para texto y Whisper GGML `.bin` para voz. Las listas Modelo de texto y Modelo de voz permiten cambiar entre varios archivos conservados en el dispositivo. La selección, CPU/GPU de LiteRT-LM, plantilla GGUF e idioma de Whisper persisten. No se incluyen pesos ni se descargan automáticamente. Ver [configuración, prompts y comparación](docs/local-models.md).

LiteRT-LM utiliza la plantilla propia del modelo; GGUF requiere elegir la indicada por su distribución (por ejemplo `gemma`). Los modelos se cargan al inferir y se liberan al terminar para evitar mantener voz y texto en RAM a la vez. `AgentPort` y `LocalTextEngine` separan propuesta y runtime. La app genera UUID antes de mostrar una alta. Sin pesos siguen disponibles los CRUD manuales.

El agente recibe el recurso seleccionado, sus campos y la lista filtrada. Propone una acción, valida tipos/campos y exige confirmación antes de guardar. No ejecuta SQL ni llamadas arbitrarias. Whisper transcribe español localmente usando el archivo seleccionado, sin depender del reconocedor de Android. La transcripción se puede editar y no ejecuta cambios. Las fechas, negaciones, relaciones y calidad del dictado requieren pruebas con los modelos reales.

## Pruebas y límites

`flutter test` verifica repositorio y validación con SQLite y HTTP simulados. Probar en Android físico: cargar modelo, modo avión, alta por texto/voz, cierre y reapertura, reconexión, conflictos y consumo de memoria. Compilar no acredita que un GGUF concreto funcione en todos los teléfonos.

Motores: llama_flutter_android 0.2.6, litertlm 0.0.13 (runtime 0.15.0) y whisper_ggml 2.6.0. No se necesita ninguna clave de proveedor IA en el móvil. Esto no incorpora todavía IA remota ni lectura directa de OpenAPI; se mantiene `/mobile-contract`.
