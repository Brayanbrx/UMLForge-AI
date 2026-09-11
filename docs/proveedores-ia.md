# Proveedores y respaldos de IA

Actualizado: 10 de septiembre de 2026. [Disponibilidad, reemplazos necesarios y pruebas reales](modelos-ia-2026-09-10.md).

La pasarela admite **un principal y hasta siete respaldos por capacidad**: texto general, visión y transcripción. Se ejecutan en orden y se detienen al obtener una respuesta válida. No se consulta a todos para comparar respuestas ni se hacen peticiones de prueba al arrancar.

## Configuración preparada

El archivo real es `infra/.env`; la plantilla versionada es `infra/.env.example`. Las claves permanecen en el servidor. La revisión del 10 de septiembre sustituyó cuatro modelos retirados u obsoletos; conservó proveedores, orden, credenciales y activación de perfiles. La plantilla sigue arrancando con `mock`, sin claves.

`AI_LLM_FALLBACK_PROVIDER` y `AI_LLM_FALLBACK_MODEL` conservan el primer respaldo existente. `AI_LLM_FALLBACKS` añade los siguientes, en un array JSON de una sola línea. Lo mismo aplica a `VISION` y `SPEECH`. El máximo de siete incluye el respaldo antiguo y todos los perfiles del array, incluso desactivados. Con el primero configurado, quedan seis lugares adicionales.

Ejemplo: mantener OpenRouter primero y habilitar Z.AI después:

```dotenv
AI_LLM_FALLBACK_PROVIDER=openrouter
AI_LLM_FALLBACK_MODEL=openrouter/free
AI_LLM_FALLBACKS=[{"provider":"zai","model":"glm-4.7-flash","enabled":true}]
ZAI_API_KEY=tu_clave
```

En el archivo preparado basta completar la clave correspondiente y cambiar `"enabled":false` a `true` en el perfil deseado. Cada perfil se habilita por capacidad: activar texto no activa visión. No se omiten silenciosamente proveedores activos sin clave: la API indica la variable faltante al arrancar. No copies una clave de OpenRouter como si fuera una clave directa de otro fabricante.

Después de editar el entorno:

```powershell
docker compose -f infra/compose.yml --env-file infra/.env up -d --force-recreate api
```

## Orden y capacidades

No existe un ranking universal de mejor a peor entre estos **proveedores**: leer multiplicidades de UML, transcribir español y ejecutar instrucciones requieren evaluaciones distintas. Se conserva el orden configurado, sin presentarlo como una medición comparativa de calidad.

| Orden preparado | Texto | Visión | Transcripción de audio en esta app |
| --- | --- | --- | --- |
| Principal | Gemini `gemini-3.7-flash` | Gemini `gemini-3.7-flash` | Groq `whisper-large-v3-turbo` |
| Respaldo 1 | OpenRouter `openrouter/free` | OpenRouter `openai/gpt-5.6-luna` | Cloudflare `@cf/openai/whisper-large-v3-turbo` |
| Respaldo 2 | Groq `openai/gpt-oss-120b` | Groq `qwen/qwen3.6-27b` | Mistral `voxtral-mini-latest` |
| Respaldo 3 | Z.AI `glm-4.7-flash` | Z.AI `glm-4.6v-flash` | Disponible |
| Respaldo 4 | Mistral `mistral-small-latest` | Mistral `ministral-14b-latest` | Disponible |
| Respaldo 5 | Moonshot `kimi-k2.6` | Moonshot `kimi-k2.6` | Disponible |
| Respaldo 6, desactivado | SambaNova `Meta-Llama-3.3-70B-Instruct` | SambaNova `gemma-4-31B-it` | Disponible |

La tabla refleja la configuración local revisada. En la plantilla todos los perfiles adicionales están desactivados. No se activó SambaNova ni se añadieron proveedores. SenseNova y ModelScope aparecían en una propuesta histórica de este documento, pero no forman parte del registro de proveedores ni de las cadenas actuales. Los modelos de voz admitidos por los adaptadores son Groq/Whisper, Cloudflare/Whisper y Mistral/Voxtral.

Z.AI publica ambos Flash seleccionados como gratuitos; **GLM-4.7-Flash es de texto, GLM-4.6V-Flash es visual**. La gratuidad no garantiza cuota ni disponibilidad. [Precios oficiales](https://docs.z.ai/guides/overview/pricing), [modelos visuales](https://docs.z.ai/guides/vlm/glm-4.6v).

Kimi K2.6 admite texto e imagen y permite desactivar el razonamiento adicional. Sigue disponible en el catálogo de la cuenta, por lo que se conserva. No se sustituye por un modelo nuevo solo por su número de versión. [K2.6](https://platform.kimi.ai/docs/guide/kimi-k2-6-quickstart).

Mistral ofrece modelos multimodales y un endpoint de transcripción compatible con formularios de audio. [Catálogo](https://docs.mistral.ai/models), [transcripción](https://docs.mistral.ai/studio/audio/speech_to_text/offline_transcription).

Groq Qwen 3.6 y SambaNova Gemma 4 son modelos visuales publicados como preview; no se usó GPT-OSS para visión porque es de texto. La disponibilidad depende de cada servicio, no solo del nombre del modelo. [Groq Qwen](https://console.groq.com/docs/model/qwen/qwen3.6-27b), [SambaNova](https://docs.sambanova.ai/docs/en/models/sambacloud-models).

Para clasificar calidad de forma defendible falta ejecutar un banco común: instrucciones con negaciones, herencia y clases intermedias; fotos con atributos y multiplicidades; audio en español. Comparar exactitud, operaciones inválidas, latencia y consumo. Los tests actuales validan la integración sin gastar tokens; no certifican la calidad de cada modelo.

## Protección del consumo

- HTTP 402/429 salta al siguiente servicio sin repetir el mismo intento. La cuota bloqueada se recuerda por proveedor/modelo durante al menos `AI_QUOTA_COOLDOWN_MS=60000`, respetando `Retry-After` hasta un máximo de 24 horas. Esta memoria es local al proceso y se reinicia al recrear la API.
- Fallos de red, timeout y 5xx permiten respaldo. `AI_MAX_RETRIES=0` evita repetir solicitudes antes de cambiar; se puede subir para red inestable. Los adaptadores basados en SDK conservan su política específica de reintentos.
- 400/401/403/404 y respuestas inválidas señalan errores de configuración o contrato. No gastan solicitudes en los demás proveedores para ocultarlos.
- Plazo total: texto 120 s, visión 300 s, voz 120 s. Los tres `AI_*_CHAIN_TIMEOUT_MS` son independientes del plazo de cada intento. Nginx espera 330 s; si aumentas el plazo total por encima, ajusta también el proxy.
- El límite `AI_COMPATIBLE_MAX_OUTPUT_TOKENS=16384` acota los nuevos servicios y OpenRouter. Si el proveedor declara salida truncada, se rechaza; no se aplica un modelo incompleto ni se hace una llamada automática para continuarlo.
- El registro de uso conserva hasta 200 respuestas exitosas con proveedor, modelo, tokens reportados y latencia. No es una factura completa: un proveedor puede cobrar por una solicitud fallida. No se almacenan claves ni prompts en ese registro.
- El reconocimiento de voz del navegador puede usar la nube del propio navegador. El flujo de dictado normal no llama a las APIs LLM hasta que pulses **Enviar**; la transcripción del servidor es una capacidad distinta.

## Estado de validación

Adaptadores y cadenas probados con HTTP simulado: intentos ordenados, cuota, credenciales inválidas, cancelación, plazo total, imágenes y transcripción. El 10 de septiembre se consultaron cinco catálogos reales y aprobaron tres pruebas de los reemplazos activos: texto Groq, visión Groq y visión Mistral. Gemini 3.7 está listado, pero la generación agotó 45 segundos. SambaNova permanece desactivado y no se probó inferencia con esa cuenta. Ver [evidencia y límites](modelos-ia-2026-09-10.md).
