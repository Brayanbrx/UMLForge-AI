# Proveedores y respaldos de IA

Actualizado: 16 de septiembre de 2026. Sustituye la [revisión del 10 de septiembre](modelos-ia-2026-09-10.md), que queda como historial.

La pasarela admite **un principal, un primer respaldo y hasta seis respaldos más por capacidad**: texto, visión y transcripción. Se ejecutan en orden y se detienen al obtener una respuesta válida. No se consulta a todos para comparar respuestas ni se hacen peticiones de prueba al arrancar.

## Qué cambió el 16 de septiembre

Se probó cada proveedor y modelo configurado con las claves reales, en las tres capacidades, más los candidatos de reemplazo. Resultado:

| Cambio | Motivo medido |
| --- | --- |
| **Groq `openai/gpt-oss-120b` pasa a primario de texto** | Respondió siempre, en 0,7 a 2,8 s. Gemini 3.7 Flash tardaba 19 a 30 s o devolvía HTTP 503 «high demand», con lo que cada instrucción gastaba el plazo de 15 s antes del respaldo. |
| **Gemini 3.7 Flash sale de las cadenas** | 503 en la mayoría de intentos; 3.8 Flash igual en visión. Se conservan `gemini-3.5-flash` (visión, 38 s, lectura completa) y `gemini-3.5-flash-lite` (texto, 0,8 s). `gemini-2.5-flash` ya no está disponible para cuentas nuevas. |
| **Groq `qwen/qwen3.6-27b` → `qwen/qwen3.8-27b`** | El 3.6 devuelve HTTP 404: ya no existe en Groq. El 3.8 lee una foto en 9 a 18 s, aunque inventa relaciones de más; queda como respaldo, no como primario. |
| **Moonshot sale de las cadenas** | Cuenta suspendida por saldo insuficiente. No tiene plan gratuito. La clave se conserva por si se recarga. |
| **OpenRouter `openai/gpt-5.6-luna` sale de visión** | Leía muy bien, pero es de pago (0,20 / 1,20 USD por millón de tokens) y la cuenta no tiene créditos. Se puede volver a poner si se compran. |
| **Cloudflare entra en texto e imagen** | Workers AI por su capa compatible con OpenAI, con las mismas dos credenciales de la voz. `@cf/openai/gpt-oss-120b` en 3 a 7 s; `@cf/meta/llama-4-scout-17b-16e-instruct` lee una foto en 31 s. |
| **NVIDIA y Cohere entran al registro** | Compatibles con OpenAI, con plan gratuito y sin tarjeta. Sin clave todavía: van desactivados. |
| **Corrección del plazo por intento** | `AI_TIMEOUT_MS` no abortaba de forma fiable en Node 22 (fallo de `AbortSignal.any` con señales de `timeout`). Ahora usa un `AbortController` propio. Ver [http.ts](../shared/ai/src/http.ts). |

## Configuración preparada

El archivo real es `infra/.env`; la plantilla versionada es `infra/.env.example`. Las claves permanecen en el servidor. La plantilla arranca con `mock`, sin claves.

`AI_LLM_FALLBACK_PROVIDER` y `AI_LLM_FALLBACK_MODEL` son el primer respaldo. `AI_LLM_FALLBACKS` añade los siguientes, en un array JSON de una sola línea. Lo mismo aplica a `VISION` y `SPEECH`. El máximo de siete incluye el primer respaldo y todos los perfiles del array, incluso desactivados.

En el archivo preparado basta completar la clave correspondiente y cambiar `"enabled":false` a `true` en el perfil deseado. Cada perfil se habilita por capacidad: activar texto no activa visión. La API indica la variable faltante al arrancar.

Después de editar el entorno:

```powershell
docker compose -f infra/compose.yml --env-file infra/.env up -d --force-recreate api
```

## Orden y capacidades

No existe un ranking universal entre estos proveedores: leer multiplicidades, transcribir español y ejecutar instrucciones requieren evaluaciones distintas. El orden se decidió por velocidad y disponibilidad medidas con una instrucción corta, un diagrama de 12 clases del propio proyecto y un dictado sintetizado en español.

| Orden | Texto | Visión | Transcripción |
| --- | --- | --- | --- |
| Principal | Groq `openai/gpt-oss-120b` · 1 s | Gemini `gemini-3.5-flash` · 38 s, 12 clases / 20 atributos / 18 relaciones | Groq `whisper-large-v3-turbo` |
| Respaldo 1 | Gemini `gemini-3.5-flash-lite` · 1 s | Mistral `ministral-14b-latest` · 31 s, 12 / 22 / 16 | Cloudflare `@cf/openai/whisper-large-v3-turbo` |
| Respaldo 2 | OpenRouter `openrouter/free` · 3 a 7 s | Cloudflare `@cf/meta/llama-4-scout-17b-16e-instruct` · 31 s, 12 / 16 / 11 | Mistral `voxtral-mini-latest` |
| Respaldo 3 | Gemini `gemini-3.8-flash` · 3 s cuando responde | Groq `qwen/qwen3.8-27b` · 9 a 18 s, 11 / 18 / 41 | — |
| Respaldo 4 | Cloudflare `@cf/openai/gpt-oss-120b` · 3 a 7 s | Gemini `gemini-3.8-flash` · 503 el 16 de septiembre | — |
| Respaldo 5 | Mistral `mistral-small-latest` · 429 el 16 de septiembre | OpenRouter `google/gemma-4-31b-it:free` · saturado el 16 de septiembre | — |
| Respaldo 6 | Z.AI `glm-4.7-flash` · 52 s | Z.AI `glm-4.6v-flash` · una lectura buena, luego 429 | — |
| Desactivado | NVIDIA `meta/llama-4-scout-17b-16e-instruct` | NVIDIA `meta/llama-4-scout-17b-16e-instruct` | — |

Los tres transcriptores devolvieron exactamente «Crea la clase cliente con nombre y correo.» a partir de un audio sintetizado. En visión, «12 / 20 / 18» significa clases, atributos y relaciones propuestas para un diagrama que tiene 12 clases, unos 22 atributos y 8 asociaciones sólidas; las líneas discontinuas de dependencia se interpretan de forma distinta según el modelo, y el candidato se corrige a mano antes de aplicarlo.

Los tests automatizados validan la integración sin gastar tokens; no certifican la calidad de cada modelo.

## Dónde conseguir cada clave

Todas sin tarjeta salvo donde se indica. Los límites cambian sin aviso; comprobar la consola de cada uno antes del examen.

| Proveedor | Dónde | Plan gratuito | Sirve para |
| --- | --- | --- | --- |
| Groq | console.groq.com | 30 peticiones/min; el más rápido | texto, imagen, voz |
| Google AI Studio | aistudio.google.com | modelos Flash; cuotas diarias que Google revisa sin aviso | texto, imagen |
| OpenRouter | openrouter.ai | modelos `:free`: 50 peticiones/día, 1.000 con 10 USD comprados | texto, imagen |
| Cloudflare Workers AI | dash.cloudflare.com | 10.000 neuronas/día; necesita `CLOUDFLARE_ACCOUNT_ID` y un token con permiso Workers AI | texto, imagen, voz |
| Mistral | console.mistral.ai | plan Experiment; el 16 de septiembre el texto devolvía 429 y la imagen y la voz funcionaban | texto, imagen, voz |
| Z.AI | z.ai | `glm-4.7-flash` y `glm-4.6v-flash` gratuitos, pero saturados | texto, imagen |
| NVIDIA NIM | build.nvidia.com | Developer Program; 40 peticiones/min; endpoint `integrate.api.nvidia.com/v1` | texto, imagen |
| Cohere | dashboard.cohere.com | clave trial: 1.000 llamadas/mes, uso no comercial; `command-a-vision-07-2025` para imagen | texto, imagen |
| SambaNova | cloud.sambanova.ai | plan gratuito anunciado; la cuenta actual devuelve 402 sin créditos | texto, imagen |
| Moonshot | platform.moonshot.ai | sin plan gratuito | texto, imagen |
| Anthropic | console.anthropic.com | sin plan gratuito | texto, imagen |

Descartados: GitHub Models fue retirado el 30 de julio de 2026; Cerebras exige tarjeta desde julio de 2026 para un crédito de 5 USD que caduca en 30 días.

Para añadir un proveedor compatible con OpenAI que no esté en la lista: nombre en `PROVIDERS`, `LLM_PROVIDERS` y `VISION_PROVIDERS`, clave y endpoint en el esquema, entrada en `credencial` y en `compatibleOptions` de [registry.ts](../shared/ai/src/registry.ts), variable en `infra/compose.yml`. Sin tocar los adaptadores.

## Protección del consumo

- HTTP 402/429 salta al siguiente servicio sin repetir el mismo intento. La cuota bloqueada se recuerda por proveedor/modelo durante al menos `AI_QUOTA_COOLDOWN_MS=60000`, respetando `Retry-After` hasta un máximo de 24 horas. Esta memoria es local al proceso y se reinicia al recrear la API.
- Fallos de red, timeout y 5xx permiten respaldo. `AI_MAX_RETRIES=0` evita repetir solicitudes antes de cambiar; se puede subir para red inestable. Los adaptadores basados en SDK conservan su política específica de reintentos.
- 400/401/403/404 y respuestas inválidas señalan errores de configuración o contrato. No gastan solicitudes en los demás proveedores para ocultarlos.
- Plazo por intento: `AI_TIMEOUT_MS=15000` para texto y voz; visión usa el máximo entre el triple y 120 s. Plazo total: texto 120 s, visión 300 s, voz 120 s. Nginx espera 330 s; si aumentas el plazo total por encima, ajusta también el proxy.
- El límite `AI_COMPATIBLE_MAX_OUTPUT_TOKENS=16384` acota los compatibles con OpenAI. Si el proveedor declara salida truncada, se rechaza; no se aplica un modelo incompleto.
- El registro de uso conserva hasta 200 respuestas exitosas con proveedor, modelo, tokens reportados y latencia. No es una factura completa: un proveedor puede cobrar por una solicitud fallida. No se almacenan claves ni prompts en ese registro.
- No hay todavía límite de consumo por usuario: cualquier cuenta de la plataforma puede agotar las cuotas gratuitas. Aceptable en la red del aula; no para publicar en internet.

## Estado de validación

- Adaptadores y cadenas probados con HTTP simulado: 186 pruebas en `shared/ai`, incluidas dos nuevas del plazo por intento y de la cancelación del llamante.
- El 16 de septiembre se probaron con claves reales los 17 perfiles configurados más 9 candidatos de reemplazo. La cadena final respondió: texto por Groq en 1,5 a 2,8 s; imagen por Gemini 3.5 Flash y, en su ausencia, por Groq; los adaptadores de Cloudflare para texto e imagen funcionaron desde la primera llamada.
- Pendiente: repetir la lectura de visión con una fotografía real del pizarrón del examen, no con un diagrama exportado; y una prueba de micrófono físico en los navegadores del aula.
