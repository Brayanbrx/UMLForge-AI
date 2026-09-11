# Estado del dictado y consumo de IA

Revisión posterior: [prompt, algoritmos y pendientes de consumo del 6 de septiembre](revision-ia-2026-09-06.md). Las cifras de caracteres y pruebas de este documento describen la etapa anterior a esa revisión.

Actualización: 6 de septiembre de 2026. API y web reconstruidas en Docker y disponibles en el entorno local. API, web, colaboración y PostgreSQL reportan estado saludable.

## Cambios terminados

- **Dictar → Parar → revisar → Enviar.** Los resultados parciales y las pausas no envían solicitudes. Si el servicio del navegador finaliza una sesión normal, el dictado se reanuda y acumula el texto hasta pulsar Parar. La app ya no impone una duración máxima de dictado.
- Al parar se esperan los resultados finales, con hasta tres segundos para cerrar un servicio que no notifique su finalización. Este plazo empieza después de la acción del usuario.
- Se puede cancelar y conservar el borrador anterior, o recuperar el dictado original después de la limpieza. Los errores de permiso o servicio conservan lo capturado y muestran un aviso; nunca lo envían automáticamente.
- La preparación local elimina algunos saludos y muletillas iniciales y normaliza espacios fuera de texto entre comillas. Es conservadora: no intenta resumir semánticamente ni eliminar correcciones o negaciones. La intención se interpreta en la única llamada LLM que sigue a Enviar.
- Se bloquean envíos duplicados, vacíos, durante dictado o mayores de 2.000 caracteres. Un texto largo se conserva completo y pide editarlo; no se recorta silenciosamente. Una solicitud fallida restaura el borrador.
- El prompt común expresa las reglas con menos texto. Conserva nombres, tipos, negaciones, roles, multiplicidades, herencia y creación de entidades intermedias. El modelo sigue proponiendo operaciones que requieren revisión y validación.
- La arquitectura admite un principal y siete respaldos por capacidad, con perfiles nuevos desactivados hasta configurar sus cuentas. Ver [configuración y proveedores](proveedores-ia.md).

## Reducción medida

Medición de caracteres, **no de tokens ni de facturación**. El esquema JSON de operaciones se conserva; estos números no representan la totalidad de una petición.

| Componente | Antes | Después | Reducción |
| --- | ---: | ---: | ---: |
| Prompt principal | 3.028 | 2.145 | 29,2 % |
| Descripción T01 | 746 | 511 | 31,5 % |
| Descripción T02 | 657 | 463 | 29,5 % |
| Descripción T03 | 673 | 475 | 29,4 % |
| Descripción T04 | 679 | 468 | 31,1 % |
| Descripción T05 | 547 | 378 | 30,9 % |
| Descripción T06 | 535 | 379 | 29,2 % |
| Descripción T07R | 653 | 522 | 20,1 % |
| Descripción T08 | 866 | 660 | 23,8 % |

## Verificación

- 411 pruebas unitarias/de regresión aprobadas, incluidas 19 de sesión/preparación de dictado, 2 del contexto compacto y 29 de cadenas múltiples y nuevos adaptadores.
- TypeScript, ESLint y formato completos aprobados.
- Compilación de API y frontend de producción aprobada; configuración de Compose validada. Se comprobó dentro del contenedor que mantiene las cadenas existentes y carga seis perfiles adicionales de texto/visión y uno de voz, desactivados.
- 4 pruebas de navegador aprobadas: pausas y reanudación, parada sin envío, envío único, cancelación, recuperación de original, texto largo, permisos denegados y consultas.
- 6 recorridos móviles aprobados en 320×568, 360×800, 390×844, 430×932, 768×1024 y 844×390, con interacción táctil y controles dentro del ancho disponible. Capturas de asistente en 320 px y horizontal inspeccionadas visualmente.
- Se corrigió una prueba auxiliar de cámara para guardar sus capturas en la salida de Playwright, sin ruta temporal de otra máquina ni mensajes de depuración que rompían ESLint.

Las pruebas de dictado sustituyen el servicio de reconocimiento y las respuestas LLM; las cuentas, pizarras y colaboración usan el entorno local. Las pruebas de proveedores sustituyen HTTP. No se utilizaron claves nuevas ni se consumieron cuotas reales para estas comprobaciones.

## Faltantes y límites

1. Completar las claves de los nuevos proveedores y activar los perfiles deseados en `infra/.env`; verificar acceso, modelo habilitado, cuotas y facturación reales.
2. Comparar calidad con el mismo banco de instrucciones y fotografías UML antes de declarar un orden de mejor a peor. El orden preparado prioriza costo y conserva los proveedores actuales.
3. Probar micrófono real en Android/iOS y con pausas largas. El navegador o el sistema pueden interrumpir el servicio por permisos, red o suspensión de la pestaña; la app conserva texto y evita autoenvíos, pero no puede garantizar continuidad del servicio externo.
4. La transcripción de audio del servidor tiene adaptadores Groq, Cloudflare y Mistral. El botón de dictado usa el reconocimiento del navegador; no se añadió grabación mediante MediaRecorder ni un cambio automático al servidor cuando el navegador carece de reconocimiento.
5. Las pruebas táctiles son emulación de Chromium; no sustituyen la comprobación con teclado virtual, micrófono y suspensión en dispositivos físicos.

Los pendientes generales previos de la aplicación siguen documentados en [la auditoría](auditoria-2026-09-05.md) y [pendientes](pendientes.md). Esta actualización acredita el flujo de dictado y la arquitectura de proveedores, sin certificar aún calidad ni acceso de las APIs nuevas.
