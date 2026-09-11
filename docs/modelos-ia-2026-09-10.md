# Disponibilidad de modelos de IA

Revisión: 10 de septiembre de 2026 (America/La_Paz).

Se revisaron los modelos configurados para texto, imágenes y transcripción contra documentación oficial y cinco catálogos HTTP. Se actualizaron únicamente referencias retiradas u obsoletas en `infra/.env` y `infra/.env.example`; se conservaron credenciales, proveedores, orden y perfiles habilitados. No se cambiaron adaptadores ni prompts en esta revisión.

## Reemplazos necesarios

| Capacidad / proveedor | Referencia anterior | Referencia actual | Motivo |
| --- | --- | --- | --- |
| Texto / Groq | `llama-3.3-70b-versatile` | `openai/gpt-oss-120b` | Retirado para cuentas free/developer el 16 de agosto de 2026; ausente del catálogo de esta cuenta. |
| Imagen / Groq | `meta-llama/llama-4-scout-17b-16e-instruct` | `qwen/qwen3.6-27b` | Retirado para cuentas free/developer el 17 de julio de 2026; ausente del catálogo de esta cuenta. El reemplazo admite imágenes. |
| Imagen / Mistral | `pixtral-12b-latest` | `ministral-14b-latest` | Pixtral 12B está deprecado y ausente del catálogo; Mistral recomienda Ministral 3 14B. |
| Imagen / SambaNova, desactivado | `Llama-4-Maverick-17B-128E-Instruct` | `gemma-4-31B-it` | Retirado el 9 de junio de 2026; Gemma es el reemplazo recomendado. Sigue desactivado. |

Fuentes: [retiros de Groq](https://console.groq.com/docs/deprecations), [Qwen 3.6 visual](https://console.groq.com/docs/model/qwen/qwen3.6-27b), [Pixtral 12B](https://docs.mistral.ai/models/pixtral-12b-24-09), [Ministral 3 14B](https://docs.mistral.ai/models/ministral-3-14b-25-12), [retiros de SambaNova](https://docs.sambanova.ai/docs/en/models/deprecations).

Qwen 3.6 de Groq y Gemma 4 de SambaNova están publicados como preview. GPT-OSS se utiliza solamente para texto. La sustitución de SambaNova corrige un perfil preparado para uso futuro; no se habilitó ni se ejecutó inferencia con esa cuenta.

## Modelos conservados

- **Gemini `gemini-3.7-flash`**, texto e imágenes: el endpoint autenticado del modelo respondió HTTP 200. La documentación no anuncia su retiro. La aparición de 3.8 no obliga a migrar. También se conserva el valor predeterminado `gemini-3.6-flash` del adaptador, sin fecha de retiro anunciada. [Ciclo de vida de Gemini](https://ai.google.dev/gemini-api/docs/deprecations).
- **OpenRouter `openrouter/free` y `openai/gpt-5.6-luna`**: presentes en el catálogo público con capacidad de imagen. La referencia de ejemplo `anthropic/claude-sonnet-4.5` también existe. Un router gratuito puede cambiar el modelo subyacente. [Catálogo API](https://openrouter.ai/api/v1/models).
- **Moonshot `kimi-k2.6`**: presente en el catálogo autenticado y documentado para texto e imagen. [Kimi K2.6](https://platform.kimi.ai/docs/guide/kimi-k2-6-quickstart).
- **Mistral `mistral-small-latest` y `voxtral-mini-latest`**: catálogo autenticado HTTP 200; alias de `mistral-small-2603` y `voxtral-mini-2602`, respectivamente. Voxtral declara transcripción de audio. [Voxtral Mini Transcribe](https://docs.mistral.ai/models/voxtral-mini-transcribe-26-02).
- **Groq `whisper-large-v3-turbo`**: activo en el catálogo autenticado. **Cloudflare `@cf/openai/whisper-large-v3-turbo`**: documentado como disponible. [Whisper en Cloudflare](https://developers.cloudflare.com/workers-ai/models/whisper-large-v3-turbo/).
- **Z.AI `glm-4.7-flash` y `glm-4.6v-flash`**: siguen publicados, con texto y visión respectivamente. Verificación documental; no se ejecutó inferencia autenticada. [Precios y modelos](https://docs.z.ai/guides/overview/pricing), [GLM visual](https://docs.z.ai/guides/vlm/glm-4.6v).
- **SambaNova `Meta-Llama-3.3-70B-Instruct`**, desactivado: sigue en el catálogo documental de producción. [Modelos SambaNova](https://docs.sambanova.ai/docs/en/models/sambacloud-models).
- **Anthropic `claude-opus-5`**, valor predeterminado del adaptador: figura activo; no forma parte de las cadenas locales actuales. [Ciclo de vida de Anthropic](https://docs.anthropic.com/en/docs/about-claude/model-deprecations).

## Validación realizada

Los catálogos de Gemini, Groq, Mistral, Moonshot y OpenRouter respondieron HTTP 200. Los cuatro primeros se consultaron con las credenciales locales; OpenRouter publica su catálogo sin autenticación. No se guardaron claves en la evidencia.

Las pruebas reales utilizaron una petición y una imagen sintéticas de la clase `Cliente`, con el atributo `nombre: String`, mediante los adaptadores existentes. No se enviaron datos de la pizarra del usuario.

| Prueba real | Resultado | Tiempo aproximado |
| --- | --- | --- |
| Groq GPT-OSS, texto | Propuesta válida con clase y atributo correctos | 1,4 s |
| Groq Qwen, imagen | Propuesta válida con clase y atributo correctos | 3,0 s |
| Mistral Ministral, imagen | Propuesta válida con clase y atributo correctos | 1,7 s |
| Gemini 3.7, texto | Tiempo de espera agotado, un intento sin respaldos | 45 s |

El catálogo confirma que Gemini está disponible para la cuenta, pero esta prueba no confirma una generación exitosa. Se mantuvo su versión porque el timeout no demuestra retiro ni incompatibilidad. Las pruebas visuales validan operaciones correctas en un caso sencillo; no certifican exactitud general. En particular, la explicación de Qwen mencionó recuadros adicionales, aunque produjo las operaciones esperadas.

Además:

- **57/57 pruebas automatizadas** aprobadas en `pasarela.test.ts` y `multi-fallback.test.ts`, con HTTP simulado: contratos de proveedores y comportamiento de respaldos.
- La configuración real y la plantilla se cargaron correctamente mediante `loadAiConfig` y `createAiPorts`; la plantilla conserva `mock` como principal.
- Se recreó solamente la API local y se verificaron las cadenas cargadas dentro del contenedor: nuevos modelos Groq y Mistral presentes; SambaNova ausente por estar desactivado.
- API, web, colaboración y base de datos quedaron en estado `healthy`.

Evidencia local, excluida del control de versiones: `reports/modelos-2026-09-10/catalogos.json`, `pruebas-reales.json`, `diagrama-sintetico.png` y `regresiones.xml`. Los scripts de consulta y prueba están en la misma carpeta.

Esta revisión confirma disponibilidad de catálogo y compatibilidad básica de los reemplazos activos, no disponibilidad continua ni una evaluación completa de calidad de todos los modelos. Los modelos de voz se conservaron; no se hizo una nueva prueba de audio contra cada proveedor en esta revisión.
