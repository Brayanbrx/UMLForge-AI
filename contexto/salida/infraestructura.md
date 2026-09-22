# Infraestructura y despliegue

Todo lo que rodea al codigo: contenedores, orquestacion, servidor web, certificados, copias de seguridad, unidades de systemd, integracion continua y la configuracion de la raiz del monorepo.

> Generado el 2026-09-21 00:42 por `contexto/todo.py`.
> 40 archivos, 2,805 lineas, 121.9 KiB de codigo.
> Pruebas: excluidas. Dependencias, compilados y binarios: siempre excluidos.

## Contenido

- [Infraestructura](#infraestructura) --- 22 archivos
- [Integracion continua](#integracion-continua) --- 4 archivos
- [Configuracion compartida](#configuracion-compartida) --- 2 archivos
- [Raiz del monorepo](#raiz-del-monorepo) --- 1 archivo
- [TypeScript raiz](#typescript-raiz) --- 1 archivo
- [Vitest](#vitest) --- 1 archivo
- [ESLint](#eslint) --- 1 archivo
- [Prettier](#prettier) --- 1 archivo
- [Exclusiones de Docker](#exclusiones-de-docker) --- 1 archivo
- [Exclusiones de Git](#exclusiones-de-git) --- 1 archivo
- [Atributos de Git](#atributos-de-git) --- 1 archivo
- [Exclusiones de Prettier](#exclusiones-de-prettier) --- 1 archivo
- [Version de Node](#version-de-node) --- 1 archivo
- [EditorConfig](#editorconfig) --- 1 archivo
- [README del proyecto](#readme-del-proyecto) --- 1 archivo

---

## Infraestructura

Dockerfiles de los tres procesos, Compose local y de produccion, Caddy y nginx, copias a S3, unidades de systemd, plantillas de entorno y las guias de despliegue en Markdown. Los `.env` reales nunca se versionan; solo aparecen los `.example`.

### Estructura

```text
infra/
|-- aws/
|   `-- backup-policy.json
|-- backup/
|   |-- backup.sh
|   `-- Dockerfile
|-- caddy/
|   |-- Caddyfile
|   `-- Caddyfile.production
|-- systemd/
|   |-- uml-monitor.service
|   `-- uml-monitor.timer
|-- .env
|-- .env.example
|-- AI-BACKUPS.md
|-- api.Dockerfile
|-- collab.Dockerfile
|-- compose.production.yml
|-- compose.yml
|-- DEPLOY-UML.md
|-- DEPLOYMENT.md
|-- google-cloud.env.example
|-- GOOGLE-CLOUD.md
|-- nginx.conf
|-- production.env.example
|-- REVISION-2026-09-18.md
`-- web.Dockerfile
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `infra/.env` | 179 |
| `infra/.env.example` | 297 |
| `infra/AI-BACKUPS.md` | 45 |
| `infra/DEPLOY-UML.md` | 101 |
| `infra/DEPLOYMENT.md` | 176 |
| `infra/GOOGLE-CLOUD.md` | 100 |
| `infra/REVISION-2026-09-18.md` | 38 |
| `infra/api.Dockerfile` | 74 |
| `infra/collab.Dockerfile` | 57 |
| `infra/compose.production.yml` | 138 |
| `infra/compose.yml` | 244 |
| `infra/google-cloud.env.example` | 27 |
| `infra/nginx.conf` | 78 |
| `infra/production.env.example` | 35 |
| `infra/web.Dockerfile` | 33 |
| `infra/aws/backup-policy.json` | 12 |
| `infra/backup/Dockerfile` | 7 |
| `infra/backup/backup.sh` | 49 |
| `infra/caddy/Caddyfile` | 26 |
| `infra/caddy/Caddyfile.production` | 35 |
| `infra/systemd/uml-monitor.service` | 12 |
| `infra/systemd/uml-monitor.timer` | 11 |

---

### `infra/.env`

```
# Configuracion local. Ignorado por git (RNF-08): ninguna clave que se ponga
# aqui llega al repositorio, y ninguna llega al navegador.
#
# La plantilla con todos los comentarios esta en infra/.env.example, y la guia
# de proveedores en docs/proveedores-ia.md. Una variable vacia cuenta como no puesta.
#
# Reordenado el 16 de septiembre de 2026 tras probar cada proveedor con estas
# claves: Groq pasa a primario de texto (1 s), Gemini 3.5 Flash y Flash Lite sustituyen a 3.7
# (503 y 19-30 s), Qwen 3.8 sustituye a 3.6 en Groq (404), Moonshot sale (cuenta
# suspendida, sin plan gratuito) y Cloudflare entra tambien para texto e imagen.


# ============================================================
# ENTORNO
# ============================================================

NODE_ENV=development
LOG_LEVEL=info


# ============================================================
# BASE DE DATOS
# ============================================================

POSTGRES_USER=uml
POSTGRES_PASSWORD=uml-desarrollo-local
POSTGRES_DB=plataforma_uml

# No es 5432: si la maquina tiene PostgreSQL instalado, el servidor del sistema
# gana las conexiones desde el anfitrion. Dentro de la composicion los procesos
# siguen usando `db:5432`.
DB_PORT=5433


# ============================================================
# PUERTOS EXPUESTOS EN EL ANFITRION
# ============================================================

API_PORT=3001
COLLAB_PORT=3002
WEB_PORT=8080
PROXY_PORT=80
ADMINER_PORT=8081


# ============================================================
# AUTENTICACION
#
# JWT_SECRET generado el 16 de septiembre de 2026 (48 bytes aleatorios). Al
# cambiarlo caducan las sesiones abiertas. Para generar otro:
#   node -e "console.log(require('crypto').randomBytes(48).toString('base64url'))"
# ============================================================

JWT_SECRET=pM5-Tg3yIDGqVsvxyLEiXAX3xEMZNa1dllt245EncTH3jF6SWvrT7Rt-rni5edjB
ACCESS_TOKEN_TTL_SECONDS=900
REFRESH_TOKEN_TTL_SECONDS=2592000
INVITE_TTL_SECONDS=604800
# false mientras se sirva por HTTP (local y red del aula). En HTTPS: true.
COOKIE_SECURE=false


# ============================================================
# ORIGEN DEL NAVEGADOR (CORS)
#
# Tiene que coincidir con la barra de direcciones. Con todo detras del proxy en
# esta maquina es http://localhost:8080. EL DIA DEL EXAMEN, con otras maquinas
# en la red del aula, poner la IP del servidor (ipconfig -> IPv4), por ejemplo:
#   WEB_ORIGIN=http://192.168.1.10:8080
# y recrear la API: docker compose -f infra/compose.yml --env-file infra/.env up -d --force-recreate api
# ============================================================

WEB_ORIGIN=http://localhost:8080


# ============================================================
# CADENA DE CONEXION PARA HERRAMIENTAS FUERA DEL CONTENEDOR
# (prisma migrate, prisma studio, seed). Dentro de la composicion no se usa.
# ============================================================

DATABASE_URL=postgresql://uml:uml-desarrollo-local@localhost:5433/plataforma_uml

MAIL_PROVIDER=brevo
MAIL_FROM=info@asiscarretera.online
MAIL_FROM_NAME=UMLFORGE AI
BREVO_API_KEY=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
# ============================================================
# CREDENCIALES DE LOS PROVEEDORES DE IA
#
# Una por proveedor, no una por puerto. Nunca salen del servidor.
# Estado el 16 de septiembre de 2026 (docs/proveedores-ia.md):
#   GROQ        funciona; texto 1 s, imagen 9 s, voz OK
#   GEMINI      3.5 Flash (imagen, 38 s) y 3.5 Flash Lite (texto, 1 s) funcionan; 3.7 y 3.8 daban 503
#   OPENROUTER  funciona; cuenta gratuita, 50 peticiones/dia en modelos :free
#   CLOUDFLARE  funciona; voz, texto (gpt-oss-120b) e imagen (Llama 4 Scout)
#   MISTRAL     imagen y voz OK; texto devolvia 429 (revisar limites en la consola)
#   ZAI         funciona pero saturado (52 s en texto, 429 en imagen)
#   NVIDIA      sin clave todavia: build.nvidia.com, gratis y sin tarjeta
#   COHERE      sin clave todavia: dashboard.cohere.com, clave trial gratuita
#   SAMBANOVA   402 sin creditos; revisar el plan en cloud.sambanova.ai
#   MOONSHOT    cuenta suspendida por saldo; no tiene plan gratuito
# ============================================================

ANTHROPIC_API_KEY=
GEMINI_API_KEY=AQ.Ab8RN6LjH21Enzi-RL-ceZXEWPnO-W3mr2I3iBfWlVlg36M8Aw
OPENROUTER_API_KEY=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
GROQ_API_KEY=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
MISTRAL_API_KEY=GOHpiixleN0KpKvhz0BduYbwIKuRNamT
ZAI_API_KEY=cceabef216fa4f01b0aecc911a95f653.TcUlGH0hirajGe0S
NVIDIA_API_KEY=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
COHERE_API_KEY=cohere_evMMPETvkP1C3rNk67AtNuaXcpugi6dIefwhjpmy1me0gt
SAMBANOVA_API_KEY=61753a9e-e182-40fd-a865-3dbb6bbb3768
MOONSHOT_API_KEY=sk-xtVEf0BNlYEr6nX6CW942qinEyXEaM3CX6B0u47iCHHe1nxT

# Cloudflare necesita las dos: el identificador va en la ruta y el testigo en la
# cabecera. Sirven para voz, texto e imagen.
CLOUDFLARE_ACCOUNT_ID=5ca68c635e0f151523430b73ec1ce588
CLOUDFLARE_API_TOKEN=cfut_t9uLyekd9MWoSDxpQFDok7cErYxF59fBHItWTXUH5685714a

# Endpoints. Solo cambiarlos si el proveedor publica otro; siempre HTTPS.
GROQ_BASE_URL=https://api.groq.com/openai/v1
MISTRAL_BASE_URL=https://api.mistral.ai/v1
ZAI_BASE_URL=https://api.z.ai/api/paas/v4
NVIDIA_BASE_URL=https://integrate.api.nvidia.com/v1
COHERE_BASE_URL=https://api.cohere.ai/compatibility/v1
SAMBANOVA_BASE_URL=https://api.sambanova.ai/v1
MOONSHOT_BASE_URL=https://api.moonshot.ai/v1


# ============================================================
# PASARELA DE IA
#
# Un principal, un primer respaldo y hasta seis mas por puerto, en orden. Se
# detiene en el primero que responde bien. `mock` seria el simulado sin red.
# ============================================================

# --- Texto: instrucciones y consultas (RF-030 a RF-037) ---
AI_LLM_PROVIDER=groq
AI_LLM_MODEL=openai/gpt-oss-120b
AI_LLM_FALLBACK_PROVIDER=cloudflare
AI_LLM_FALLBACK_MODEL=@cf/openai/gpt-oss-120b
AI_LLM_FALLBACKS=[{"provider":"nvidia","model":"google/gemma-4-31b-it","enabled":true},{"provider":"mistral","model":"mistral-small-latest","enabled":true},{"provider":"gemini","model":"gemini-3.5-flash-lite","enabled":true},{"provider":"openrouter","model":"openrouter/free","enabled":true},{"provider":"zai","model":"glm-4.7-flash","enabled":true}]

# --- Imagen: fotografia del pizarron (RF-040 a RF-043) ---
#
# openai/gpt-5.6-luna por OpenRouter leia muy bien pero es DE PAGO (0,20/1,20 USD
# por millon de tokens) y la cuenta no tiene creditos. Si se compran, se puede
# volver a poner como primer respaldo:
#   {"provider":"openrouter","model":"openai/gpt-5.6-luna","enabled":true}
AI_VISION_PROVIDER=mistral
AI_VISION_MODEL=ministral-14b-latest
AI_VISION_FALLBACK_PROVIDER=cloudflare
AI_VISION_FALLBACK_MODEL=@cf/meta/llama-4-scout-17b-16e-instruct
AI_VISION_FALLBACKS=[{"provider":"cohere","model":"command-a-plus-05-2026","enabled":true},{"provider":"groq","model":"qwen/qwen3.8-27b","enabled":true},{"provider":"gemini","model":"gemini-3.5-flash","enabled":true},{"provider":"openrouter","model":"google/gemma-4-31b-it:free","enabled":true},{"provider":"zai","model":"glm-4.6v-flash","enabled":true}]

# --- Voz: respaldo del reconocimiento del navegador ---
AI_SPEECH_PROVIDER=groq
AI_SPEECH_MODEL=whisper-large-v3-turbo
AI_SPEECH_FALLBACK_PROVIDER=cloudflare
AI_SPEECH_FALLBACK_MODEL=@cf/openai/whisper-large-v3-turbo
AI_SPEECH_FALLBACKS=[{"provider":"mistral","model":"voxtral-mini-latest","enabled":true}]


# ============================================================
# POLITICA COMUN DE LA CAPA DE IA
# ============================================================

# Por intento. Con Groq de primario sobra; es lo que limita a un respaldo lento.
AI_TIMEOUT_MS=15000
# Vacio = maximo(3 x AI_TIMEOUT_MS, 120000). Leer una foto tarda de 9 a 40 s.
AI_VISION_TIMEOUT_MS=
# Plazo total por puerto, sumando toda la cadena. Nginx espera 330 s.
AI_CHAIN_TIMEOUT_MS=120000
AI_VISION_CHAIN_TIMEOUT_MS=300000
AI_SPEECH_CHAIN_TIMEOUT_MS=120000
AI_MAX_RETRIES=0
AI_QUOTA_COOLDOWN_MS=60000
AI_COMPATIBLE_MAX_OUTPUT_TOKENS=16384
AI_LOG_USAGE=true
```

---

### `infra/.env.example`

```bash
# Copiar a infra/.env y ajustar. El archivo real esta ignorado por git (RNF-08):
# ninguna clave llega al repositorio, y ninguna llega al navegador.
#
# Una variable vacia cuenta como no puesta. Las que estan asi abajo se pueden
# dejar tal cual.
#
# Guia de proveedores, modelos probados y limites gratuitos: docs/proveedores-ia.md


# ============================================================
# ENTORNO
# ============================================================

NODE_ENV=development
LOG_LEVEL=info


# ============================================================
# BASE DE DATOS
# ============================================================

POSTGRES_USER=uml
POSTGRES_PASSWORD=cambiar-esta-clave
POSTGRES_DB=plataforma_uml

# Deliberadamente NO es 5432: si la maquina tiene PostgreSQL instalado, el
# servidor del sistema ya ocupa ese puerto y gana las conexiones desde el
# anfitrion. Docker publica el suyo igualmente y `compose ps` lo da por sano,
# asi que el sintoma es una autenticacion que falla contra un servidor que no es
# el que se cree. Dentro de la composicion los procesos siguen usando `db:5432`.
DB_PORT=5433


# ============================================================
# PUERTOS EXPUESTOS EN EL ANFITRION
#
# Tres cosas quieren el 8080 el dia de la demostracion: este proxy, el backend
# generado y la app movil. El reparto se decide antes del ensayo, no durante
# (docs/pendientes.md 1.3).
# ============================================================

API_PORT=3001
COLLAB_PORT=3002
WEB_PORT=8080
PROXY_PORT=80
ADMINER_PORT=8081


# ============================================================
# AUTENTICACION
# ============================================================

# Sin valor por defecto a proposito: un secreto con valor por defecto acaba
# desplegado, y nadie se entera hasta que alguien firma sus propios tokens.
# Generar uno con:
#   node -e "console.log(require('crypto').randomBytes(48).toString('base64url'))"
JWT_SECRET=cambiar-este-secreto-por-uno-de-al-menos-32-caracteres

ACCESS_TOKEN_TTL_SECONDS=900
REFRESH_TOKEN_TTL_SECONDS=2592000
INVITE_TTL_SECONDS=604800

# false solo para desarrollo por HTTP. En HTTPS tiene que ser true, o la cookie
# de refresco viaja en claro.
COOKIE_SECURE=false


# ============================================================
# ORIGEN DEL NAVEGADOR (CORS)
#
# El que corresponda a como se este sirviendo la interfaz:
#   http://localhost:5173      Vite en desarrollo
#   http://localhost:8080      todo detras del proxy
#   http://192.168.1.10:8080   varias maquinas en la red del aula
#
# Si no coincide con la barra de direcciones, el navegador bloquea todas las
# llamadas y el sintoma no menciona CORS por ninguna parte.
# ============================================================

WEB_ORIGIN=http://localhost:5173


# ============================================================
# CADENA DE CONEXION PARA HERRAMIENTAS FUERA DEL CONTENEDOR
#
# prisma migrate, prisma studio, seed. Dentro de la composicion el anfitrion es
# `db` y esta variable no se usa.
# ============================================================

DATABASE_URL=postgresql://uml:cambiar-esta-clave@localhost:5433/plataforma_uml


# ============================================================
# CORREO (recuperacion de contrasena)
#
# `log` escribe el mensaje en el registro del servidor con el enlace completo.
# No es un hueco por rellenar: es lo que permite recuperar una cuenta en local
# y en una red sin salida a internet — `docker logs plataforma-uml-api-1`.
#
# Para enviar de verdad: MAIL_PROVIDER=brevo y la clave de la cuenta. El
# remitente tiene que ser una direccion verificada en Brevo, o rechazan el envio.
# ============================================================

MAIL_PROVIDER=log
MAIL_FROM=no-responder@plataforma-uml.local
MAIL_FROM_NAME=UMLFORGE AI
BREVO_API_KEY=

# Cuanto vive el enlace de recuperacion. Una hora: suficiente para leer el
# correo, corto para que uno olvidado en la bandeja no siga siendo una llave.
PASSWORD_RESET_TTL_SECONDS=3600


# ============================================================
# CREDENCIALES DE LOS PROVEEDORES DE IA
#
# Una por proveedor, no una por puerto: la clave pertenece a la cuenta, y que
# el texto y la imagen usen la misma es consecuencia, no configuracion.
#
# Nunca salen del servidor. El navegador y la app movil hablan con nuestra API,
# y la API habla con el proveedor (RNF-08).
#
# En integracion continua van vacias: alli todo corre con el adaptador simulado.
#
# Donde conseguirlas, todas sin tarjeta:
#   GROQ         console.groq.com            texto, imagen y voz; el mas rapido
#   GEMINI       aistudio.google.com         texto e imagen; modelos Flash gratis
#   OPENROUTER   openrouter.ai               router; los modelos `:free`, 50 peticiones/dia
#   CLOUDFLARE   dash.cloudflare.com         voz, texto e imagen; 10.000 neuronas/dia
#   MISTRAL      console.mistral.ai          plan Experiment; texto, imagen y voz
#   ZAI          z.ai                        modelos Flash gratuitos
#   NVIDIA       build.nvidia.com            API Catalog de evaluacion; cuota segun cuenta/modelo
#   COHERE       dashboard.cohere.com        clave trial, 1.000 llamadas/mes
#   SAMBANOVA    cloud.sambanova.ai          plan gratuito
#   MOONSHOT     platform.moonshot.ai        de pago; sin plan gratuito
#   ANTHROPIC    console.anthropic.com       de pago
# ============================================================

ANTHROPIC_API_KEY=
GEMINI_API_KEY=
OPENROUTER_API_KEY=
GROQ_API_KEY=
MISTRAL_API_KEY=
ZAI_API_KEY=
NVIDIA_API_KEY=
COHERE_API_KEY=
SAMBANOVA_API_KEY=
MOONSHOT_API_KEY=

# Cloudflare necesita dos: el identificador va en la ruta y el testigo en la
# cabecera. Con uno solo el sintoma seria un 404 del proveedor. Sirven para la
# voz (Whisper) y para texto e imagen (Workers AI).
CLOUDFLARE_ACCOUNT_ID=
CLOUDFLARE_API_TOKEN=

# Endpoints. Solo cambiarlos si el proveedor publica otro; siempre HTTPS.
GROQ_BASE_URL=https://api.groq.com/openai/v1
MISTRAL_BASE_URL=https://api.mistral.ai/v1
ZAI_BASE_URL=https://api.z.ai/api/paas/v4
NVIDIA_BASE_URL=https://integrate.api.nvidia.com/v1
COHERE_BASE_URL=https://api.cohere.ai/compatibility/v1
SAMBANOVA_BASE_URL=https://api.sambanova.ai/v1
MOONSHOT_BASE_URL=https://api.moonshot.ai/v1


# ============================================================
# PASARELA DE IA
#
#                          Pasarela de IA
#                                |
#              +-----------------+-----------------+
#              v                 v                 v
#           LlmPort          VisionPort        SpeechPort
#              |                 |                 |
#              v                 v                 v
#            groq             gemini             groq
#              |                 |                 |
#          no responde       no responde       no responde
#              |                 |                 |
#              v                 v                 v
#        gemini-lite         mistral         cloudflare
#              |                 |                 |
#              v                 v                 v
#        AI_LLM_FALLBACKS  AI_VISION_FALLBACKS  AI_SPEECH_FALLBACKS
#
# `mock` es el valor por defecto y NO es un hueco por rellenar: es el adaptador
# simulado, determinista y sin red, con el que corre la integracion continua y
# con el que la plataforma arranca sin que nadie tenga una clave. Si el dia del
# examen no hay internet, dejarlo en `mock` deja el asistente respondiendo —con
# menos capacidad, pero respondiendo.
#
# Cada puerto tiene un principal, un primer respaldo (AI_*_FALLBACK_*) y hasta
# seis respaldos mas en AI_*_FALLBACKS, un array JSON de una sola linea. Se
# prueban en orden y se detienen en el primero que responde bien. El maximo de
# siete cuenta tambien los desactivados.
#
# Reglas que el proceso comprueba al arrancar, no en la primera llamada:
#   - No todo proveedor sirve para todo puerto. Texto e imagen aceptan
#     anthropic, gemini, openrouter, groq, cloudflare, mistral, zai, nvidia,
#     cohere, moonshot y sambanova; la voz acepta groq, cloudflare y mistral.
#   - Si el proveedor necesita clave y no la tiene, el proceso no arranca.
#   - Un respaldo identico al primario se rechaza: no es un respaldo.
#   - Todos los compatibles con OpenAI exigen modelo en texto e imagen: cada
#     uno sirve muchos y ninguno es el evidente.
# ============================================================

# --- Texto: interpreta instrucciones y responde consultas (RF-030 a RF-037) ---
AI_LLM_PROVIDER=mock
AI_LLM_MODEL=
AI_LLM_FALLBACK_PROVIDER=
AI_LLM_FALLBACK_MODEL=

# --- Imagen: lee la fotografia del pizarron (RF-040 a RF-043) ---
AI_VISION_PROVIDER=mock
AI_VISION_MODEL=
AI_VISION_FALLBACK_PROVIDER=
AI_VISION_FALLBACK_MODEL=

# --- Voz: respaldo del reconocimiento del navegador ---
#
# El reconocimiento normal lo hace el navegador: puede usar servicios remotos propios y
# responde al instante. Esto es para cuando no lo trae —Firefox— o reconoce mal.
# La app movil no usa este puerto: su agente es local y funciona en modo avion.
AI_SPEECH_PROVIDER=mock
AI_SPEECH_MODEL=
AI_SPEECH_FALLBACK_PROVIDER=
AI_SPEECH_FALLBACK_MODEL=

# --- Respaldos adicionales, en orden. Activar solo tras poner su clave. ---
#
# Vienen desactivados: enabled:false -> true. No hay llamadas de prueba al arrancar.
# El perfil de demostracion verificado esta documentado en infra/AI-BACKUPS.md;
# no es un ranking universal de calidad.
AI_LLM_FALLBACKS=[{"provider":"cloudflare","model":"@cf/openai/gpt-oss-120b","enabled":false},{"provider":"nvidia","model":"google/gemma-4-31b-it","enabled":false},{"provider":"mistral","model":"mistral-small-latest","enabled":false},{"provider":"gemini","model":"gemini-3.5-flash-lite","enabled":false},{"provider":"openrouter","model":"openrouter/free","enabled":false},{"provider":"zai","model":"glm-4.7-flash","enabled":false}]
AI_VISION_FALLBACKS=[{"provider":"cloudflare","model":"@cf/meta/llama-4-scout-17b-16e-instruct","enabled":false},{"provider":"cohere","model":"command-a-plus-05-2026","enabled":false},{"provider":"groq","model":"qwen/qwen3.8-27b","enabled":false},{"provider":"gemini","model":"gemini-3.5-flash","enabled":false},{"provider":"openrouter","model":"google/gemma-4-31b-it:free","enabled":false},{"provider":"zai","model":"glm-4.6v-flash","enabled":false}]
AI_SPEECH_FALLBACKS=[{"provider":"mistral","model":"voxtral-mini-latest","enabled":false}]


# ============================================================
# POLITICA COMUN DE LA CAPA DE IA
# ============================================================

# Tiempo maximo POR INTENTO. Corto a proposito: lo que salva una llamada durante
# la defensa es cambiar de proveedor pronto, no esperar mas al que no contesta.
# Con Groq de primario, una instruccion responde en uno o dos segundos.
AI_TIMEOUT_MS=15000

# Leer un pizarron cuesta mas que interpretar una frase. Vacio = el triple del
# anterior, y nunca menos de 120000. Medido: leer un diagrama de doce clases
# tarda de 9 a 40 segundos segun el proveedor. Es un trabajo por lotes, no una
# respuesta en vivo.
AI_VISION_TIMEOUT_MS=

# Plazo TOTAL por puerto, sumando todos los intentos de la cadena. Nginx espera
# 330 s; si se sube alguno por encima, ajustar tambien el proxy.
AI_CHAIN_TIMEOUT_MS=120000
AI_VISION_CHAIN_TIMEOUT_MS=300000
AI_SPEECH_CHAIN_TIMEOUT_MS=120000

# Reintentos adicionales de red/5xx dentro del mismo proveedor. 402 y 429 saltan
# al siguiente de inmediato. Cero: con varios respaldos, repetir no ayuda.
AI_MAX_RETRIES=0

# Cuanto se recuerda que un proveedor agoto su cuota antes de volver a probarlo.
# Se respeta Retry-After hasta 24 horas. Es memoria del proceso: se pierde al recrear la API.
AI_QUOTA_COOLDOWN_MS=60000

# Tope de salida para los compatibles con OpenAI. Una salida truncada se rechaza.
AI_COMPATIBLE_MAX_OUTPUT_TOKENS=16384

# Registra proveedor, modelo, tokens y latencia de cada llamada. Nunca la clave
# ni el contenido de la pizarra.
AI_LOG_USAGE=true


# ============================================================
# EJEMPLO: la cadena de referencia, con claves reales
#
# Descomentar y rellenar GROQ/GEMINI/CLOUDFLARE arriba. Es la cadena probada el
# 16 de septiembre de 2026 (docs/proveedores-ia.md): Groq responde en un
# segundo; Gemini 3.5 Flash Lite en uno; Gemini 3.5 Flash lee una foto en 40.
# ============================================================

# AI_LLM_PROVIDER=groq
# AI_LLM_MODEL=openai/gpt-oss-120b
# AI_LLM_FALLBACK_PROVIDER=gemini
# AI_LLM_FALLBACK_MODEL=gemini-3.5-flash-lite
#
# AI_VISION_PROVIDER=gemini
# AI_VISION_MODEL=gemini-3.5-flash
# AI_VISION_FALLBACK_PROVIDER=mistral
# AI_VISION_FALLBACK_MODEL=ministral-14b-latest
#
# AI_SPEECH_PROVIDER=groq
# AI_SPEECH_MODEL=whisper-large-v3-turbo
# AI_SPEECH_FALLBACK_PROVIDER=cloudflare
```

---

### `infra/AI-BACKUPS.md`

```markdown
# Respaldos IA para la demostración académica

Revisión del 18 de septiembre de 2026. Configuración aplicada en `infra/.env` y en el archivo privado `output/google-cloud/production.env`. Las claves actualizadas de NVIDIA y Cohere están sincronizadas; el dominio, las contraseñas de la VM y Brevo se conservan. Ninguno de estos archivos privados se sube a Git.

## Orden configurado

| Capacidad | Principal | Respaldos, en orden |
| --- | --- | --- |
| Texto y consultas | Groq `openai/gpt-oss-120b` | Cloudflare `@cf/openai/gpt-oss-120b` → NVIDIA `google/gemma-4-31b-it` → Mistral `mistral-small-latest` → Gemini `gemini-3.5-flash-lite` → OpenRouter `openrouter/free` → Z.ai `glm-4.7-flash` |
| Lectura de diagramas | Mistral `ministral-14b-latest` | Cloudflare `@cf/meta/llama-4-scout-17b-16e-instruct` → Cohere `command-a-plus-05-2026` → Groq `qwen/qwen3.8-27b` → Gemini `gemini-3.5-flash` → OpenRouter `google/gemma-4-31b-it:free` → Z.ai `glm-4.6v-flash` |
| Transcripción | Groq `whisper-large-v3-turbo` | Cloudflare `@cf/openai/whisper-large-v3-turbo` → Mistral `voxtral-mini-latest` |

Se quitaron los modelos NVIDIA antiguos que devolvían 404/410 y la segunda variante Gemini, para evitar repetir un proveedor con disponibilidad limitada antes de llegar a otro servicio. Las plantillas públicas permanecen desactivadas hasta disponer de credenciales; el archivo privado preparado ya tiene las cadenas activas de esta tabla.

## Resultado de las llamadas reales

Solo se enviaron ejemplos sintéticos: clases Cliente/Pedido, un PNG de Persona con correo y autoasociación, y una frase generada con síntesis de voz. No se usaron proyectos ni grabaciones personales.

- **Texto:** Groq y Cloudflare generaron correctamente clases, atributo obligatorio y multiplicidades. NVIDIA Gemma superó pruebas de clase/atributo y relación; también tuvo tiempos de espera agotados en otras llamadas. Se limita a 4.096 tokens de salida y se desactiva `enable_thinking` para reducir la latencia. La validación rechaza respuestas truncadas; no aplica lotes parciales.
- **Imagen:** Mistral, Cloudflare y Cohere Command A+ transcribieron la clase, atributo y autoasociación del PNG. Se adelantaron a los servicios que no respondieron o agotaron cuota durante la revisión.
- **Voz:** Groq, Cloudflare y Mistral transcribieron correctamente el audio sintético en llamadas reales.
- **Disponibilidad pendiente:** Mistral texto, Z.ai, Groq imagen y OpenRouter imagen devolvieron 429. Gemini y OpenRouter texto agotaron tiempos de espera; una variante Gemini tampoco estuvo disponible. Conservan posiciones posteriores como alternativas cuando recuperen cuota/disponibilidad; no se consideran respaldos garantizados hoy.
- **Cohere texto no está activo:** Command A, A+, A Reasoning y Command R/R+ respondieron, pero invirtieron las multiplicidades en un ejemplo sencillo. Command A Vision tampoco pasó la transcripción inicial. No confundir acceso a la API con calidad semántica. El modelo elegido de Cohere es **Command A+ para imágenes**.
- **NVIDIA imagen no está activo:** los modelos probados no completaron la lectura dentro del plazo de evaluación.

Estas son pruebas funcionales pequeñas, no una garantía para diagramas arbitrarios. Las propuestas siguen requiriendo revisión humana antes de aplicarse.

## Límites y errores

La configuración conserva 15 segundos por intento de texto, sin reintentos adicionales, y un límite total de 120 segundos. Imagen mantiene su plazo por intento de 120 segundos y total de 300 segundos; voz tiene un total de 120 segundos. Las cuotas 402/429 activan el respaldo y un enfriamiento de al menos 60 segundos, respetando Retry-After. Los errores de red y 5xx también activan el siguiente proveedor. Una credencial inválida, modelo inexistente o respuesta que incumple el contrato se informa: no se oculta como un fallo transitorio.

Se corrigió el presupuesto de Command A y Command A Vision antiguos a un máximo de 8.192 tokens; Command A+ conserva el presupuesto global. NVIDIA Gemma usa su límite específico de 4.096 y el resto mantiene su configuración anterior.

Las cuentas de evaluación están habilitadas para la demostración solicitada. Cohere aplica cuotas de prueba, incluida una cota mensual de 1.000 llamadas; NVIDIA API Catalog se ofrece para evaluación. Para un servicio comercial habrá que contratar la modalidad adecuada. Fuentes oficiales: [límites de Cohere](https://docs.cohere.com/docs/rate-limits), [Command A+](https://docs.cohere.com/docs/command-a-plus), [Gemma en NVIDIA](https://build.nvidia.com/google/gemma-4-31b-it), [condiciones de evaluación NVIDIA](https://assets.ngc.nvidia.com/products/api-catalog/legal/NVIDIA%20API%20Trial%20Terms%20of%20Service.pdf).

## Aplicar en la VM

Sigue [DEPLOY-UML.md](DEPLOY-UML.md): confirma y sube los cambios del código, transfiere **la versión actualizada** del archivo privado a `/etc/uml/production.env` con permisos 600 y ejecuta `sudo bash scripts/production.sh deploy` desde `/opt/uml`. Este comando reconstruye las imágenes y recrea los servicios con las variables nuevas. Un simple `docker restart` no carga cambios del archivo de entorno.

Después ejecuta `sudo bash scripts/production.sh smoke` y prueba una instrucción, una imagen y un dictado desde el subdominio. La comprobación de salud verifica la aplicación; no acredita cuota disponible en todas las IA. Si falla una clave en la VM, consulta los registros de API sin publicar el archivo de entorno ni cabeceras de autorización.

El código incluye regresiones del límite de Cohere, los parámetros de NVIDIA y el salto entre proveedores de texto e imagen. No se ha accedido a la VM ni se han cambiado recursos de Google Cloud durante esta revisión.

Validación final: `npm run check` aprobado (583 pruebas), imagen Docker de API construida y perfil privado validado con Compose. En una prueba controlada se simularon respuestas 429 únicamente en los dos primeros proveedores: NVIDIA respondió realmente al texto y Cohere realmente al PNG usando la configuración del archivo de despliegue. Esto prueba el recorrido de la cadena sin consumir cuota de los proveedores simulados.
```

---

### `infra/DEPLOY-UML.md`

````markdown
# Despliegue de uml.asiscarretera.online

Destino preparado: **https://uml.asiscarretera.online**, VM **35.255.28.222**.
El registro A público fue comprobado el 18 de septiembre de 2026.

## Configuración entregada

Respaldos IA y resultados de pruebas reales: [AI-BACKUPS.md](AI-BACKUPS.md). Usa el archivo privado actualizado; incluye NVIDIA para texto y Cohere Command A+ para imágenes en el perfil de demostración.

- `infra/google-cloud.env.example`: plantilla pública, sin credenciales.
- `output/google-cloud/production.env`: archivo privado preparado en este equipo. Está excluido de Git y del contexto Docker; no aparecerá al clonar el repositorio. Contiene la clave Brevo y las configuraciones/credenciales IA de `infra/.env`, con contraseñas nuevas para PostgreSQL y JWT de esta VM. No reemplaza la configuración local.
- `DOMAIN=uml.asiscarretera.online` y `WEB_ORIGIN=https://uml.asiscarretera.online`.
- CORS admite únicamente ese origen; incluye `GET`, `HEAD`, `POST`, `PUT`, `PATCH`, `DELETE` y `OPTIONS`, con Authorization y Content-Type. Permite leer Content-Disposition para descargas y Retry-After para límites. No habilita el dominio raíz, otros subdominios, HTTP ni la IP como orígenes del navegador. CORS no sustituye la autenticación de la API.
- Cookie de renovación Secure, HttpOnly y SameSite=Lax, limitada al host. El proxy de producción añade HSTS y CSP y redirige HTTP a HTTPS.
- API pública en `/api`, colaboración en `wss://uml.asiscarretera.online/collab`. La interfaz deriva ambas rutas del dominio actual; no requiere recompilar URLs específicas.
- Solo Caddy publica puertos 80/443; API, colaboración y PostgreSQL quedan en la red Docker. Migraciones, comprobaciones de salud, límites, volúmenes y rotación de logs ya están en el Compose de producción.

## 1. Antes de arrancar

1. Reserva **35.255.28.222** como IP estática de la VM. El registro A `uml` debe apuntar a ella. No cambies el dominio raíz ni sus MX.
2. En el firewall VPC permite TCP **80 y 443** a esta VM. Restringe SSH a tu IP administrativa o a IAP. No abras 3001/3002/5432/8080. Si hay firewall del sistema operativo, debe permitir también HTTP y HTTPS.
3. Confirma y sube los cambios del código. `production.sh deploy` requiere checkout limpio. El archivo privado se transfiere por separado.
4. En Brevo autoriza la IP de salida de la nueva VM. Habitualmente será **35.255.28.222** si no hay Cloud NAT u otro proxy; verifica la IP que Brevo reporte. El bloqueo anterior desde el PC era para **166.114.170.75**. Valida el dominio remitente `asiscarretera.online` y `info@asiscarretera.online` en Brevo.

## 2. Preparar la VM por SSH

Para Ubuntu 24.04, sustituye `URL_DEL_REPOSITORIO`:

```bash
sudo apt-get update
sudo apt-get install -y git
sudo git clone URL_DEL_REPOSITORIO /opt/uml
cd /opt/uml
sudo bash scripts/bootstrap-ubuntu.sh
```

Si el repositorio ya existe, actualízalo al commit que incluye esta configuración y conserva `/opt/uml` como directorio de trabajo.

## 3. Transferir la configuración privada

Desde PowerShell en tu PC, sustituye `USUARIO_VM` por tu usuario SSH y usa la misma clave SSH con la que accedes a la VM:

```powershell
scp "C:\Users\braya\Desktop\Practicas\Examen1SW1\output\google-cloud\production.env" USUARIO_VM@35.255.28.222:~/uml-production.env
```

También puedes transferir el archivo mediante la opción de subida de tu sesión SSH del navegador de Google Cloud.

Después, en la VM:

```bash
sudo install -d -m 700 /etc/uml
sudo install -m 600 "$HOME/uml-production.env" /etc/uml/production.env
rm -- "$HOME/uml-production.env"
cd /opt/uml
sudo bash scripts/production.sh deploy
sudo bash scripts/production.sh ps
sudo bash scripts/production.sh smoke
```

El script obtiene el commit para etiquetar imágenes, valida la configuración, hace una copia previa, migra la base y arranca los servicios. Caddy obtiene el certificado cuando el DNS y los puertos son accesibles. Este archivo es para una base nueva: no cambies con él la contraseña de un volumen PostgreSQL ya inicializado.

## 4. Comprobar el despliegue real

Los nuevos registros requieren activar la cuenta por correo antes de iniciar sesión.
Brevo envía un enlace a `https://uml.asiscarretera.online/activar#token=…`, válido
durante 24 horas y de un solo uso. La pantalla de acceso permite reenviarlo (máximo
un envío por minuto por cuenta, además del límite por IP). La migración conserva
el acceso de las cuentas anteriores. Si falla el envío inicial, la cuenta queda
pendiente y la interfaz permite solicitar otro enlace.

Comprueba la entrega real en Brevo y en el buzón antes de abrir el registro público:
una clave configurada no garantiza que el proveedor acepte el envío desde la VM.
En desarrollo, `MAIL_PROVIDER=log` escribe el enlace en los logs de la API.
Las pruebas E2E locales usan ese adaptador; la prueba de producción captura los
correos en un adaptador temporal sin enviar mensajes reales.

Abre `https://uml.asiscarretera.online`. Confirma registro/login, recarga de sesión, dos usuarios con estado **En vivo**, descarga PNG/ZIP y recuperación de contraseña con entrega real del correo y enlace al subdominio correcto.

```bash
curl -fsS https://uml.asiscarretera.online/api/ready
curl -i -X OPTIONS https://uml.asiscarretera.online/api/projects \
  -H 'Origin: https://uml.asiscarretera.online' \
  -H 'Access-Control-Request-Method: PATCH' \
  -H 'Access-Control-Request-Headers: authorization,content-type'
sudo bash scripts/production.sh backup
sudo bash scripts/production.sh restore-check
```

El preflight debe responder **204**, `Access-Control-Allow-Origin: https://uml.asiscarretera.online`, credenciales habilitadas y PATCH entre los métodos. La respuesta genérica del formulario de recuperación no acredita entrega: revisa Brevo y el buzón.

## Copias y operación

El archivo preparado usa **BACKUP_S3_URI=local-only**, ya que no se proporcionó un bucket. Permite iniciar y conserva copias diarias en la VM, pero no protege de perderla. Antes de almacenar datos importantes configura las copias externas de [GOOGLE-CLOUD.md](GOOGLE-CLOUD.md#3-copias-en-cloud-storage).

Monitorización, actualización y rollback: [DEPLOYMENT.md](DEPLOYMENT.md). No uses `npm run up` para este despliegue: ese comando ejecuta el perfil de desarrollo.

La preparación y las pruebas locales no modifican la VM, el firewall de Google Cloud ni la lista de IP autorizadas de Brevo. Esas acciones y la aceptación pública se completan en la cuenta del proveedor.

Validación local del 18 de septiembre: `npm run check` aprobado (578 pruebas), perfil privado validado con Docker Compose, y `npm run test:production` aprobado con CORS a través del proxy HTTPS, cookies seguras, WebSocket, descarga PNG y restauración. Los recursos de la prueba eran temporales y se eliminaron al finalizar.
````

---

### `infra/DEPLOYMENT.md`

````markdown
# Despliegue en AWS EC2, Azure, Google Cloud o un VPS con Docker

Esta configuración despliega una instancia de API, colaboración y PostgreSQL en una máquina Linux. Caddy publica HTTPS y WebSocket seguro. Es portable a una VM de AWS, Google Cloud, Azure o cualquier proveedor con Docker; no es una configuración de ECS, Kubernetes ni un servicio de alta disponibilidad.

Para Google Cloud, la [guía de Compute Engine](GOOGLE-CLOUD.md) detalla la VM, firewall, IP fija y copias en Cloud Storage.

La VM **no necesita** Java, Maven, Flutter ni Android SDK: la plataforma emite el código como ZIP y lo compila quien lo descarga, en su PC. Ver [Descargas y espacio en disco](#descargas-y-espacio-en-disco).

## Preparación

- Ubuntu 24.04 LTS, Docker Engine y Compose **2.24.4 o posterior**. Punto de partida orientativo para pocos usuarios: 2 vCPU, 4 GiB de RAM y 30 GiB de disco; medir uso real y ampliar, especialmente al construir imágenes. No es una capacidad certificada.
- Dominio con DNS A apuntando a la IP pública estable de la VM. Configurar AAAA solo si IPv6 funciona de extremo a extremo.
- Entrada TCP 80 y 443 pública; SSH 22 únicamente desde la IP administrativa. No abrir 3001, 3002, 5432/5433, 8080 ni el administrador de Caddy.
- Un remitente verificado en Brevo y su clave API para recuperación de contraseñas.
- Bucket privado S3 o compatible, con cifrado, bloqueo de acceso público y regla de retención. Recomendación inicial: retener copias 30 días y activar versionado; la retención local es de 7 días. El script nunca elimina objetos del bucket. Sin bucket, `BACKUP_S3_URI=local-only` deja las copias en la VM (ver abajo).
- Una versión de Git confirmada y subida. Los cambios locales y la base de datos de tu PC no viajan con `git clone`.

### Notas por proveedor

| Proveedor | Red y puertos | IP fija | Copias externas |
| --- | --- | --- | --- |
| **AWS EC2** | Security group: 80 y 443 desde `0.0.0.0/0`, 22 solo desde tu IP. | Elastic IP asociada a la instancia. | Rol IAM de instancia con la política de `aws/backup-policy.json` (sustituir el bucket). IMDSv2 obligatorio con hop limit 2 para que el contenedor de backup lea el rol. Sin claves permanentes en la VM. El rol de escritura no borra ni descarga; usar otro con `s3:GetObject` para recuperar. Con SSE-KMS, permisos de la clave KMS. |
| **Azure VM** | Network Security Group: reglas de entrada 80 y 443; SSH restringido. | IP pública con asignación **estática** (la dinámica cambia al reiniciar). | Azure Blob no habla S3. Opciones: un almacenamiento compatible con S3 (Cloudflare R2, Backblaze B2, MinIO) con `AWS_ENDPOINT_URL` y claves limitadas, o `local-only`. |
| **Google Cloud Compute Engine** | Regla de firewall VPC para `tcp:80,443` con etiqueta de red en la VM. | Dirección externa **estática** reservada. | Cloud Storage admite la API S3 con claves HMAC: `AWS_ENDPOINT_URL=https://storage.googleapis.com` y las claves HMAC de una cuenta de servicio limitada. O `local-only`. |
| **VPS (DigitalOcean, Hetzner, Linode, Contabo…)** | Cortafuegos del panel o `ufw allow 80,443/tcp`, `ufw allow from TU_IP to any port 22`. | Suelen ser fijas por defecto. | Spaces, Object Storage o cualquier S3 compatible con `AWS_ENDPOINT_URL`. O `local-only`. |

`BACKUP_S3_URI=local-only` arranca sin bucket: las copias diarias quedan en el volumen `backups` de la VM, con la misma retención de 7 días, y el script de despliegue lo avisa en cada comprobación. Protege de una migración mal aplicada, no de perder la VM. Para datos que importan, configurar un bucket antes de abrir la plataforma a otras personas.

## Primera instalación

Clonar el repositorio en `/opt/uml`. Instalar Git si la imagen no lo incluye:

```bash
sudo apt-get update
sudo apt-get install -y git
sudo git clone URL_DE_TU_REPOSITORIO /opt/uml
cd /opt/uml
sudo bash scripts/bootstrap-ubuntu.sh
sudo install -d -m 700 /etc/uml
sudo install -m 600 infra/production.env.example /etc/uml/production.env
sudoedit /etc/uml/production.env
```

Sustituir todos los ejemplos antes de arrancar:

| Campo | Valor |
| --- | --- |
| `DOMAIN` | `uml.tu-dominio.com`, sin protocolo, puerto ni ruta. |
| `WEB_ORIGIN` | `https://uml.tu-dominio.com`, sin barra final. |
| `ACME_EMAIL` | Correo operativo para certificados. |
| `POSTGRES_PASSWORD` | Generar con `openssl rand -hex 32`. |
| `JWT_SECRET` | Generar con `openssl rand -hex 48`. Compose entrega el mismo valor a API y colaboración. |
| `MAIL_FROM`, `BREVO_API_KEY` | Remitente verificado y clave real de Brevo. |
| `BACKUP_S3_URI` | `s3://mi-bucket-privado/uml`, prefijo exclusivo de este despliegue. |
| `AWS_DEFAULT_REGION` | Región del bucket. |

`NODE_ENV=production`, `COOKIE_SECURE=true`, correo real, límites de peticiones y confianza en un único proxy se establecen en el Compose de producción. La API rechaza configuraciones inseguras. Los secretos se mantienen fuera del repositorio con permisos 600; quien administra Docker puede ver el entorno del contenedor y debe considerarse administrador del servidor.

La plantilla deja la IA en `mock` para arrancar sin contratar un proveedor. Para IA real, copiar al archivo de producción las variables necesarias de `infra/.env.example`: proveedor/modelo de texto, visión y voz, credenciales y respaldos. Todas las variables de IA del Compose base se conservan. No copiar cuentas de demostración ni ejecutar `npm run seed` en producción.

```bash
sudo bash scripts/production.sh deploy
sudo bash scripts/production.sh ps
sudo bash scripts/production.sh smoke
```

El despliegue exige un checkout limpio. Usa el commit actual como etiqueta de imágenes, construye los cinco componentes, valida configuración y Caddy, inicia PostgreSQL y exige una copia externa exitosa **antes** de aplicar las migraciones. Después arranca los servicios y comprueba las rutas públicas con validación TLS. Guarda la versión exitosa en `/root/.local/state/uml-deploy` al ejecutar con sudo. No borra volúmenes.

El servidor necesita acceso saliente a DNS, registros de imágenes, certificados, S3, correo y proveedores de IA. Si la copia externa o un paso falla, el script termina con error; revisar la causa antes de reintentar. Un fallo posterior a una migración puede requerir intervención: el despliegue de una única VM admite una breve interrupción y no promete rollback automático de datos.

## Verificación funcional antes de compartir el enlace

1. Abrir el dominio con certificado válido; confirmar redirección HTTP a HTTPS.
2. Registrar una cuenta real, **activarla desde el enlace del correo** —sin activar, el login responde 403— y verificar después login y renovación de sesión. Este paso comprueba de paso la entrega real de Brevo.
3. Abrir la misma pizarra con dos usuarios y comprobar `En vivo`, cambios y reconexión.
4. Importar/exportar XMI; probar una imagen con el proveedor de visión elegido.
5. Generar y descargar un ZIP desde una pizarra válida.
6. Solicitar recuperación de contraseña y comprobar entrega real del correo.
7. Ejecutar una copia después de crear datos y probar restauración:

```bash
sudo bash scripts/production.sh backup
sudo bash scripts/production.sh restore-check
```

La segunda orden restaura la última copia local en un PostgreSQL temporal, comprueba que hay tablas y destruye únicamente ese contenedor temporal. La base de producción permanece intacta. Si la copia programada coincide con la manual, el bloqueo evita dos dumps simultáneos; reintentar al terminar la primera.

## Copias externas y recuperación

El servicio `backup` ejecuta `pg_dump -Fc`, valida el índice con `pg_restore --list`, sube el resultado a S3 y solo entonces marca éxito. Repite cada 24 horas y reintenta cada cinco minutos si falla. La comprobación de salud falla si la última copia supera el intervalo más dos horas. Las copias viven en un volumen aparte y en el bucket. Supervisar ese estado: un contenedor `unhealthy` por sí solo no envía una alerta.

Para recuperar desde S3 tras perder la VM:

1. Detener escrituras o recuperar en una VM nueva. Guardar la base actual antes de sustituirla.
2. Descargar la copia con un rol de recuperación; verificar origen y fecha. Mantener los permisos privados del archivo.
3. Restaurar **en una base vacía aislada** usando PostgreSQL 17: `pg_restore --exit-on-error --no-owner --no-acl --dbname URL_DE_BASE_DESTINO copia.dump`. No ejecutar el comando contra la base viva.
4. Comprobar cuentas, proyectos, pizarras y snapshots; arrancar la versión de la aplicación correspondiente a la copia. Aplicar migraciones posteriores solo después de verificar compatibilidad.
5. Cambiar el tráfico a la instancia recuperada y repetir pruebas funcionales.

Ensayar también este procedimiento desde una copia descargada del bucket. La prueba automatizada local verifica formato y restauración, pero no acredita tu cuenta, IAM, conectividad o retención S3. Para migrar las pizarras del PC se usa el mismo procedimiento de dump/restauración en la nueva base antes de habilitar usuarios.

## Descargas y espacio en disco

**Dónde se descarga.** En la pizarra, pestaña **Generar**: al terminar aparecen los botones **Descargar backend** y, si se marcó la opción Flutter, **Descargar Android + backend**. El historial de abajo conserva un botón de descarga por cada generación anterior, para cualquier miembro del proyecto, también los de solo lectura. La descarga va por `/api/generations/{id}/download?target=spring|mobile`, autenticada con la sesión.

**Qué contiene.** El ZIP trae el proyecto Spring Boot con su `compose.yaml` y, en el objetivo Android, la app Flutter con `apk.bat` / `apk.sh`. **El APK no se compila en el servidor**: lo compila quien descarga, en su PC, con `.\apk.bat build` (necesita Flutter y Android SDK) y queda en `mobile/dist/`. Compilar Android tarda minutos y pesa gigabytes de SDK; hacerlo en la VM obligaría a una máquina mucho más grande sin ganar nada para la defensa.

**Qué se guarda en el servidor.** Ningún ZIP ni APK. Generar congela una copia del diagrama (una fila JSON en `board_snapshots`, unos KB) y registra un manifiesto en `generations`; al descargar se vuelve a emitir desde esa copia y se comprueba que el SHA-256 coincide con el registrado (ADR-018). Por eso el mismo enlace da los mismos bytes semanas después, y por eso mil generaciones ocupan megabytes, no gigabytes.

**Cómo eliminar.** En el historial de la pestaña Generar, **Eliminar** (solo OWNER y EDITOR) borra el registro y su copia congelada; esa generación deja de poder descargarse. Borrar una pizarra o un proyecto arrastra todas sus generaciones. Desde la API: `DELETE /api/generations/{id}`.

**Qué ocupa espacio de verdad en la VM**, de mayor a menor:

| Qué | Dónde | Cómo se controla |
| --- | --- | --- |
| Imágenes Docker, una por versión desplegada | `docker images` | `sudo bash scripts/production.sh prune` conserva la versión actual y la anterior (para rollback) y borra el resto más la caché de construcción. |
| Base de datos | volumen `db-data` | Crece con pizarras, documentos colaborativos, auditoría y generaciones. `disk` muestra el desglose. |
| Copias locales | volumen `backups` | Retención `BACKUP_KEEP_DAYS` (7 por defecto); el bucket externo tiene la suya. |
| Registros de contenedores | json-file | Rotación fijada en el Compose de producción: 3 archivos de 10 MB por servicio. |
| Certificados | `caddy-data` | Despreciable. |

```bash
sudo bash scripts/production.sh disk    # disco, Docker, tamaño de cada tabla, copias locales
sudo bash scripts/production.sh prune   # imágenes antiguas y caché; nunca volúmenes
```

El monitor avisa cuando el disco supera el 85 %. Nunca ejecutar `docker system prune --volumes` ni `down -v` sobre producción: borra la base y las copias locales.

## Supervisión y alertas

```bash
sudo cp infra/systemd/uml-monitor.service infra/systemd/uml-monitor.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now uml-monitor.timer
sudo systemctl start uml-monitor.service
sudo journalctl -u uml-monitor.service --no-pager -n 30
```

Cada cinco minutos comprueba HTTPS, `/api/ready` (base de datos y servicio colaborativo), antigüedad del backup y disco por debajo del 85 %. Si falla, deja error en systemd. Para recibir notificaciones configurar `/etc/uml/monitor.env` con permisos 600 y `ALERT_WEBHOOK_URL=https://...`: debe aceptar JSON `{"text":"..."}`. Sin ese destino no se envían avisos externos. Añadir también un monitor externo de `/api/ready` o una alarma de AWS para detectar una VM totalmente apagada, que no puede avisar por sí misma. Configurar alarmas de facturación en la cuenta cloud.

## Actualización y rollback

```bash
cd /opt/uml
sudo git pull --ff-only
sudo bash scripts/production.sh deploy
```

No utilizar solo `docker compose restart`: no carga variables nuevas ni recompila el código. Cambiar JWT invalida sesiones y requiere actualizar API y colaboración conjuntamente; el script siempre considera ambos servicios. Cambiar `POSTGRES_PASSWORD` en dotenv **no cambia** la contraseña de una base ya inicializada: requiere una rotación coordinada en PostgreSQL.

Si una nueva versión falla y no hubo cambios de migraciones:

```bash
sudo bash scripts/production.sh rollback HASH_DE_VERSION_EXITOSA_ANTERIOR
```

Reutiliza imágenes locales conservadas; no recompila código nuevo bajo una etiqueta antigua. Rechaza el rollback si la huella de migraciones difiere. Si cambiaron migraciones o configuración incompatible, usar recuperación validada y valorar los datos posteriores a la copia. No podar imágenes de versiones necesarias ni ejecutar `down -v` sobre producción. El rollback cubre API, colaboración y web; no revierte secretos, Caddy, backups ni el esquema.

## Pruebas reproducibles y límites

Desde un equipo de desarrollo con Node, dependencias instaladas y Docker:

```bash
npm run check
npm run test:api
npm run test:production
```

La última crea un proyecto Docker con nombre aleatorio y volúmenes temporales. Construye imágenes reales, valida que no hay puertos internos publicados y comprueba HTTPS con CA local confiada explícitamente, cookies Secure/HttpOnly, autenticación WSS, un navegador real entrando a una pizarra, límites frente a cabeceras IP falsificadas y restauración de datos. Elimina únicamente sus propios contenedores/volúmenes. Usa los puertos locales 18080/18443. No desactiva la verificación TLS global ni usa credenciales reales; S3 y el envío de correo se verifican posteriormente con tu configuración real. CI ejecuta esta prueba también. Funciona también desde Windows con Docker Desktop.

Los contadores de peticiones están en memoria, acotados por proceso y se reinician al reiniciar API. Este despliegue usa una sola API y un solo servidor colaborativo. Antes de múltiples réplicas se requiere almacenamiento compartido de cuotas y coordinación de documentos; no basta con aumentar `replicas`.

Completar una auditoría de dependencias (`npm audit --omit=dev`) y de imágenes antes de la exposición pública. La consulta npm envía metadatos de dependencias al registro: debe estar autorizada. No se presupone que pruebas funcionales equivalgan a ausencia de vulnerabilidades.

Referencias: [Docker en Ubuntu](https://docs.docker.com/engine/install/ubuntu/), [Compose para producción](https://docs.docker.com/compose/how-tos/production/), [HTTPS de Caddy](https://caddyserver.com/docs/automatic-https), [roles de EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html), [puertos y security groups](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/security-group-rules-reference.html).
````

---

### `infra/GOOGLE-CLOUD.md`

````markdown
# Google Cloud Compute Engine con Docker

Para la VM **35.255.28.222** y el dominio **uml.asiscarretera.online**, usa el [procedimiento preparado para este despliegue](DEPLOY-UML.md).

La plataforma está preparada para una única VM Linux: Caddy termina HTTPS, la web sirve los archivos estáticos, la API y el servidor colaborativo comparten PostgreSQL. El archivo base debe combinarse con `compose.production.yml`; `npm run up` es para desarrollo. No aumentar réplicas de colaboración: las salas están en memoria y todavía no existe coordinación entre servidores.

## 1. VM y red

En Compute Engine crea una VM con Ubuntu 24.04 LTS. Como punto de partida para pocos usuarios: 2 vCPU, 4 GiB RAM y disco persistente de al menos 30 GiB. Las compilaciones Docker pueden requerir más memoria; dimensiona con métricas reales. Activa protección contra eliminación y revisa la política de conservación del disco al eliminar la VM.

Reserva y asocia una IP externa estática. Crea un registro DNS A, por ejemplo `uml.tu-dominio.com`, dirigido a esa IP. Añade AAAA únicamente si también configuraste IPv6.

Aplica una etiqueta de red exclusiva a la VM y una regla VPC de entrada para TCP 80 y 443 dirigida a esa etiqueta. Limita SSH a tu IP administrativa o a IAP según tu método de acceso. No publiques 3001, 3002, 5432, 5433, 8080 ni 2019. Revisa también reglas amplias heredadas de la red: una regla específica no anula otra que ya permite tráfico.

La VM necesita salida a los registros de Docker/npm, DNS, certificados, Cloud Storage, Brevo y los proveedores de IA elegidos. No requiere Java, Maven ni Flutter: la generación entrega código y la compilación del APK ocurre en el equipo que lo descarga.

Referencias oficiales: [crear una VM](https://docs.cloud.google.com/compute/docs/instances/create-start-instance), [reservar una dirección estática](https://docs.cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address), [acceso seguro a VM](https://docs.cloud.google.com/solutions/connecting-securely).

## 2. Instalar el proyecto

Desde SSH en la VM, sustituye la URL por la de tu repositorio:

```bash
sudo apt-get update
sudo apt-get install -y git
sudo git clone URL_DE_TU_REPOSITORIO /opt/uml
cd /opt/uml
sudo bash scripts/bootstrap-ubuntu.sh
sudo install -d -m 700 /etc/uml
sudo install -m 600 infra/production.env.example /etc/uml/production.env
sudoedit /etc/uml/production.env
```

Configura los siguientes valores reales fuera del repositorio:

| Variable | Configuración |
| --- | --- |
| `DOMAIN` | `uml.tu-dominio.com` |
| `WEB_ORIGIN` | `https://uml.tu-dominio.com`, sin barra final |
| `ACME_EMAIL` | Correo operativo para los certificados |
| `POSTGRES_PASSWORD` | Valor generado con `openssl rand -hex 32` |
| `JWT_SECRET` | Otro valor generado con `openssl rand -hex 48` |
| `MAIL_FROM` | Remitente verificado en Brevo |
| `BREVO_API_KEY` | Clave de Brevo para recuperación de contraseña |
| `AI_LLM_PROVIDER`, `AI_VISION_PROVIDER`, `AI_SPEECH_PROVIDER` | Proveedores reales y sus credenciales/modelos de `infra/.env.example`; `mock` solo simula respuestas |

`production.sh` etiqueta las imágenes con el commit actual. Antes de instalar, confirma y sube los cambios y usa un checkout limpio en la VM. Git no traslada las pizarras locales; su migración requiere dump y restauración de PostgreSQL.

## 3. Copias en Cloud Storage

El contenedor existente usa AWS CLI y la API compatible con S3 de Cloud Storage. Crea un bucket privado y una cuenta de servicio dedicada con permiso para crear objetos en ese bucket (por ejemplo `roles/storage.objectCreator` a nivel de bucket). Genera claves **HMAC** para esa cuenta; no son una clave JSON ni las credenciales OAuth de `gcloud`.

Configura en `/etc/uml/production.env`:

```dotenv
BACKUP_S3_URI=s3://NOMBRE_REAL_DEL_BUCKET/uml
AWS_ENDPOINT_URL=https://storage.googleapis.com
AWS_DEFAULT_REGION=auto
AWS_ACCESS_KEY_ID=ID_HMAC_REAL
AWS_SECRET_ACCESS_KEY=SECRETO_HMAC_REAL
BACKUP_INTERVAL_SECONDS=86400
BACKUP_KEEP_DAYS=7
```

Aunque el bucket sea de Google, la URI debe comenzar con `s3://` porque el cliente es AWS CLI. El endpoint y las claves dirigen la operación a Cloud Storage. Mantén vacía `AWS_SESSION_TOKEN`.

Establece una política de ciclo de vida/retención en el bucket según tus necesidades; la retención local de siete días no elimina copias remotas. Usa una identidad separada con permiso de lectura para recuperar una copia y comprueba una restauración desde un objeto descargado del bucket. `restore-check` valida la copia local y no demuestra por sí solo que puedas recuperar la remota.

Para una prueba sin bucket puedes usar `BACKUP_S3_URI=local-only`. Las copias permanecen en la misma VM; configura y verifica el almacenamiento externo antes de confiarle datos importantes.

La compatibilidad de endpoint, firma y permisos debe comprobarse con la cuenta real mediante `production.sh backup`; la prueba local usa almacenamiento temporal. Documentación oficial: [interoperabilidad de Cloud Storage](https://docs.cloud.google.com/storage/docs/interoperability), [migración compatible con S3](https://docs.cloud.google.com/storage/docs/aws-simple-migration), [gestionar claves HMAC](https://docs.cloud.google.com/storage/docs/authentication/managing-hmackeys).

## 4. Desplegar y verificar

```bash
cd /opt/uml
sudo bash scripts/production.sh deploy
sudo bash scripts/production.sh ps
sudo bash scripts/production.sh smoke
sudo bash scripts/production.sh backup
sudo bash scripts/production.sh restore-check
```

El despliegue construye las imágenes, comprueba variables, realiza una copia antes de migrar, aplica Prisma y espera a que los servicios estén sanos. Caddy obtiene el certificado automáticamente cuando el DNS y los puertos funcionan.

Antes de compartir el dominio, comprueba:

1. Redirección HTTP → HTTPS y `/api/ready` saludable.
2. Registro, ingreso, renovación de sesión y entrega real del correo de recuperación.
3. Dos usuarios en la misma pizarra con estado **En vivo**, edición y reconexión.
4. **Importar → Exportar imagen PNG → Guardar PNG**: abrir el archivo y revisar clases, atributos, multiplicidades y relaciones. La imagen se procesa en el navegador y no requiere permisos de Cloud Storage.
5. Importación/exportación XMI, generación y descarga del ZIP, texto/visión/voz con los proveedores reales que actives.
6. Un objeto de backup nuevo en el bucket y una restauración probada, incluida una copia descargada de Cloud Storage.

Instala el monitor systemd de [DEPLOYMENT.md](DEPLOYMENT.md#supervisión-y-alertas) y añade un chequeo externo de `/api/ready` en Cloud Monitoring para detectar una VM apagada. Configura alertas de presupuesto y vigila RAM/disco. Las actualizaciones y rollback se realizan con los procedimientos de esa misma guía.

## Alcance de la revisión local

Las pruebas del repositorio validan el software y una pila Docker temporal con HTTPS. No certifican la configuración de tu proyecto de Google Cloud, sus credenciales, el DNS, la entrega de Brevo ni los proveedores de IA. El despliegue se considera verificado en tu VM cuando pasan los pasos anteriores con su configuración real.
````

---

### `infra/REVISION-2026-09-18.md`

```markdown
# Revisión de exportación PNG y despliegue en Compute Engine

## Resultado

La revisión local permite avanzar al despliegue de una única VM con Docker Compose de producción. No se accedió a un proyecto de Google Cloud ni se desplegó infraestructura; la aceptación del entorno público depende de verificar su configuración real.

## Exportación de imagen

En la pizarra: **Importar → Exportar imagen PNG → Guardar PNG**. Permite elegir nombre, conserva el tema y captura clases y relaciones fuera de la cámara sin moverla. Incluye multiplicidades, roles y bucles; omite conectores, tiradores y presencia de otros usuarios. Disponible para lectores y editores, deshabilitada en una pizarra vacía. El archivo se crea en el navegador.

Se limita el tamaño de rasterización para evitar agotar memoria en diagramas grandes. Exporta la representación actual de las tarjetas; si una tarjeta tiene atributos recortados por su tamaño manual, amplíala antes de exportar.

La dependencia `html-to-image` queda fijada en 1.11.11 siguiendo la advertencia de compatibilidad del [ejemplo oficial de React Flow](https://reactflow.dev/examples/misc/download-image). Se carga al solicitar la descarga.

## Evidencia ejecutada

| Comprobación | Resultado |
| --- | --- |
| `npm run check` | Formato, ESLint y tipos correctos; 569 pruebas en 38 archivos aprobadas |
| `npm run build` | Compilación completa y Vite correctos |
| `npm run test:api` | 140 pruebas en 7 archivos aprobadas; PostgreSQL temporal |
| `npm run test:production` | Construcción de imágenes, HTTPS, cookies seguras, WSS, límites de peticiones y restauración aprobados |
| PNG bajo HTTPS y CSP de producción | Descarga válida, nombre correcto, contenido y dimensiones; cámara preservada; revisión visual de `reports/diagram-export.png` |
| `npm audit --omit=dev` | 0 vulnerabilidades reportadas por npm en dependencias de producción |
| `git diff --check` | Sin errores de espacios |

Los contenedores y volúmenes de producción usados para esta prueba eran temporales y se eliminaron al terminar. La auditoría npm no sustituye un escaneo de imágenes base. No se ejecutaron la suite E2E completa ni la compilación del banco Java/Flutter en esta revisión.

## Pendiente en la VM

- Confirmar y subir estos cambios; el script de despliegue exige un checkout limpio y usa su commit para las etiquetas.
- IP externa fija, dominio con DNS correcto y firewall limitado a HTTP/HTTPS y acceso administrativo.
- Secretos reales, remitente y clave Brevo; proveedores/modelos de IA reales si se habilitan esas funciones. Las plantillas usan `mock`.
- Bucket privado, claves HMAC limitadas y prueba real de copia/recuperación desde Cloud Storage. Las pruebas locales no contactaron el bucket ni enviaron correo.
- Ejecutar `production.sh deploy`, `smoke`, `backup` y `restore-check`, verificar dos usuarios y recuperación de contraseña, y configurar monitorización.

Pasos y variables en [GOOGLE-CLOUD.md](GOOGLE-CLOUD.md). Operación, actualización y rollback en [DEPLOYMENT.md](DEPLOYMENT.md).
```

---

### `infra/api.Dockerfile`

```dockerfile
# Proceso HTTP. Construccion en varias etapas: la imagen final no lleva ni el
# compilador de TypeScript ni las dependencias de desarrollo.

FROM node:22.15.0-alpine AS node-base
RUN npm install --global npm@11.6.0

FROM node-base AS deps
WORKDIR /app
COPY package.json package-lock.json prisma.config.ts ./
COPY backend/prisma/ backend/prisma/
COPY shared/contracts/package.json shared/contracts/
COPY shared/domain-core/package.json shared/domain-core/
COPY shared/generation-ir/package.json shared/generation-ir/
COPY shared/generator-backend/package.json shared/generator-backend/
COPY shared/xmi/package.json shared/xmi/
COPY shared/ai/package.json shared/ai/
COPY shared/yjs-adapter/package.json shared/yjs-adapter/
COPY fixtures/package.json fixtures/
COPY backend/api/package.json backend/api/
COPY backend/collab/package.json backend/collab/
COPY frontend/package.json frontend/
RUN npm ci --no-audit --no-fund

# Imagen de un solo uso para `prisma migrate deploy`. Conserva el CLI, que es
# una herramienta de construccion/operacion y no una dependencia del proceso
# HTTP expuesto.
FROM deps AS migrate

FROM deps AS build
WORKDIR /app
COPY tsconfig.json ./
COPY config/tsconfig.base.json config/
COPY shared/ shared/
COPY backend/api/ backend/api/
RUN npx tsc --build backend/api

FROM node-base AS runtime
ENV NODE_ENV=production
WORKDIR /app

# Los package.json de todos los workspaces se toman de la etapa de dependencias,
# que ya los reunio. Volver a listarlos aqui a mano significaba que cada
# dependencia nueva entre paquetes compartidos rompia la imagen en ejecucion, y
# el fallo solo aparecia al arrancar el contenedor.
COPY package.json package-lock.json ./
COPY --from=deps /app/shared/ shared/
COPY --from=deps /app/fixtures/ fixtures/
COPY --from=deps /app/backend/ backend/
COPY --from=deps /app/frontend/ frontend/
RUN npm ci --no-audit --no-fund --omit=dev --omit=optional --ignore-scripts --workspace @uml/api --include-workspace-root

# `prisma generate` ya corrio en `deps`. El proceso solo necesita el cliente
# resultante; ni el CLI ni la configuracion de migraciones.
COPY --from=deps /app/node_modules/.prisma/ node_modules/.prisma/

# Y lo compilado, tambien completo: el grafo de dependencias entre paquetes
# compartidos lo decide el codigo, no este archivo.
COPY --from=build /app/shared/ shared/
COPY --from=build /app/backend/api/dist backend/api/dist

# Las plantillas de generacion. **No son codigo compilado**: son archivos que el
# generador lee en ejecucion, resueltos relativos a su propio `dist`, y por eso
# no llegaban con `tsc --build`.
#
# Sin ellas la imagen arranca sana, responde a todo y solo falla al generar, con
# un 500 y un ENOENT: el banco de regresion no lo ve porque corre fuera del
# contenedor, y la unica forma de detectarlo era generar desde el navegador
# contra la plataforma levantada.
COPY templates/ templates/

USER node
EXPOSE 3001
CMD ["node", "backend/api/dist/server.js"]
```

---

### `infra/collab.Dockerfile`

```dockerfile
# Proceso WebSocket. Misma estrategia que el proceso HTTP.

FROM node:22.15.0-alpine AS node-base
RUN npm install --global npm@11.6.0

FROM node-base AS deps
WORKDIR /app
COPY package.json package-lock.json prisma.config.ts ./
COPY backend/prisma/ backend/prisma/
COPY shared/contracts/package.json shared/contracts/
COPY shared/domain-core/package.json shared/domain-core/
COPY shared/generation-ir/package.json shared/generation-ir/
COPY shared/generator-backend/package.json shared/generator-backend/
COPY shared/xmi/package.json shared/xmi/
COPY shared/ai/package.json shared/ai/
COPY shared/yjs-adapter/package.json shared/yjs-adapter/
COPY fixtures/package.json fixtures/
COPY backend/api/package.json backend/api/
COPY backend/collab/package.json backend/collab/
COPY frontend/package.json frontend/
RUN npm ci --no-audit --no-fund

FROM deps AS build
WORKDIR /app
COPY tsconfig.json ./
COPY config/tsconfig.base.json config/
COPY shared/ shared/
COPY backend/collab/ backend/collab/
RUN npx tsc --build backend/collab

FROM node-base AS runtime
ENV NODE_ENV=production
WORKDIR /app

# Los package.json de todos los workspaces se toman de la etapa de dependencias,
# que ya los reunio. Volver a listarlos aqui a mano significaba que cada
# dependencia nueva entre paquetes compartidos rompia la imagen en ejecucion, y
# el fallo solo aparecia al arrancar el contenedor.
COPY package.json package-lock.json ./
COPY --from=deps /app/shared/ shared/
COPY --from=deps /app/fixtures/ fixtures/
COPY --from=deps /app/backend/ backend/
COPY --from=deps /app/frontend/ frontend/
RUN npm ci --no-audit --no-fund --omit=dev --omit=optional --ignore-scripts --workspace @uml/collab --include-workspace-root

# El cliente generado si es runtime; el CLI de Prisma no.
COPY --from=deps /app/node_modules/.prisma/ node_modules/.prisma/

# Y lo compilado, tambien completo: el grafo de dependencias entre paquetes
# compartidos lo decide el codigo, no este archivo.
COPY --from=build /app/shared/ shared/
COPY --from=build /app/backend/collab/dist backend/collab/dist

USER node
EXPOSE 3002
CMD ["node", "backend/collab/dist/server.js"]
```

---

### `infra/compose.production.yml`

```yaml
# Docker Compose >= 2.24.4. Always combine with compose.yml.
name: plataforma-uml-production

x-logging: &logging
  driver: json-file
  options:
    max-size: '10m'
    max-file: '3'

x-node: &node
  init: true
  read_only: true
  tmpfs: ['/tmp:size=128m,mode=1777']
  cap_drop: [ALL]
  security_opt: ['no-new-privileges:true']
  stop_grace_period: 45s
  logging: *logging

services:
  db:
    ports: !reset []
    mem_limit: ${DB_MEMORY:-1g}
    cpus: ${DB_CPUS:-1.0}
    logging: *logging
    security_opt: ['no-new-privileges:true']
    stop_grace_period: 60s

  migrate:
    image: uml-migrate:${APP_VERSION:?Define APP_VERSION con el commit de la version}
    logging: *logging
    mem_limit: 512m

  api:
    <<: *node
    image: uml-api:${APP_VERSION:?Define APP_VERSION}
    ports: !reset []
    mem_limit: ${API_MEMORY:-768m}
    cpus: ${API_CPUS:-1.0}
    environment:
      NODE_ENV: production
      WEB_ORIGIN: ${WEB_ORIGIN:?Define el origen HTTPS publico}
      COOKIE_SECURE: 'true'
      TRUST_PROXY_HOPS: 1
      MAIL_PROVIDER: brevo
      MAIL_FROM: ${MAIL_FROM:?Define un remitente verificado}
      BREVO_API_KEY: ${BREVO_API_KEY:?Configura el correo de recuperacion}
      RATE_LIMIT_MAX: ${RATE_LIMIT_MAX:-300}
      AUTH_RATE_LIMIT_MAX: ${AUTH_RATE_LIMIT_MAX:-20}
      WORK_RATE_LIMIT_MAX: ${WORK_RATE_LIMIT_MAX:-20}

  collab:
    <<: *node
    image: uml-collab:${APP_VERSION:?Define APP_VERSION}
    ports: !reset []
    mem_limit: ${COLLAB_MEMORY:-512m}
    cpus: ${COLLAB_CPUS:-1.0}
    environment:
      NODE_ENV: production

  web:
    image: uml-web:${APP_VERSION:?Define APP_VERSION}
    ports: !reset []
    read_only: true
    tmpfs: ['/var/cache/nginx', '/var/run', '/tmp']
    security_opt: ['no-new-privileges:true']
    mem_limit: 128m
    cpus: 0.5
    logging: *logging

  proxy:
    profiles: !reset []
    ports: !override ['80:80', '443:443']
    volumes: !override
      - ./caddy/Caddyfile.production:/etc/caddy/Caddyfile:ro
      - caddy-data:/data
      - caddy-config:/config
    environment:
      DOMAIN: ${DOMAIN:?Define el dominio publico sin https ni rutas}
      ACME_EMAIL: ${ACME_EMAIL:?Define correo para certificados}
    mem_limit: 256m
    cpus: 0.5
    read_only: true
    tmpfs: ['/tmp']
    security_opt: ['no-new-privileges:true']
    logging: *logging
    healthcheck:
      test: ['CMD', 'wget', '-q', '--spider', 'http://127.0.0.1:2019/config/']
      interval: 30s
      timeout: 5s
      retries: 3

  adminer:
    ports: !reset []

  backup:
    image: uml-backup:${APP_VERSION:?Define APP_VERSION}
    build:
      context: ..
      dockerfile: infra/backup/Dockerfile
    restart: unless-stopped
    init: true
    user: postgres
    read_only: true
    tmpfs: ['/tmp:size=64m,mode=1777']
    cap_drop: [ALL]
    security_opt: ['no-new-privileges:true']
    mem_limit: 256m
    cpus: 0.5
    logging: *logging
    depends_on:
      db:
        condition: service_healthy
    environment:
      PGHOST: db
      PGUSER: ${POSTGRES_USER}
      PGPASSWORD: ${POSTGRES_PASSWORD}
      PGDATABASE: ${POSTGRES_DB}
      BACKUP_S3_URI: ${BACKUP_S3_URI:?Define s3://bucket/prefijo para copias externas, o local-only para dejarlas en la VM}
      BACKUP_INTERVAL_SECONDS: ${BACKUP_INTERVAL_SECONDS:-86400}
      BACKUP_KEEP_DAYS: ${BACKUP_KEEP_DAYS:-7}
      AWS_DEFAULT_REGION: ${AWS_DEFAULT_REGION:-us-east-1}
      AWS_ENDPOINT_URL: ${AWS_ENDPOINT_URL:-}
      AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID:-}
      AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY:-}
      AWS_SESSION_TOKEN: ${AWS_SESSION_TOKEN:-}
      AWS_PAGER: ''
    volumes:
      - backups:/backups
    healthcheck:
      test: ['CMD', 'sh', '/opt/backup.sh', 'health']
      interval: 60s
      timeout: 5s
      retries: 3
      start_period: 5m

volumes:
  backups:
```

---

### `infra/compose.yml`

```yaml
# Composicion de la plataforma. Corresponde a la seccion 13 del plan maestro.
#
# Reglas que se aplican aqui:
#  - cada servicio declara comprobacion de salud y quien depende de el la espera;
#  - los datos viven en volumenes con nombre, solo `down -v` los borra;
#  - toda la configuracion entra por variables de entorno, sin secretos escritos;
#  - los puertos se exponen solo donde hacen falta.
#
# Uso:
#   docker compose up -d                      entorno de desarrollo
#   docker compose --profile demo up -d       anade el origen unico
#   docker compose --profile tools up -d      anade la inspeccion de la base

name: plataforma-uml

services:
  # PostgreSQL de la plataforma. No es la base del backend generado: esa viaja
  # dentro del ZIP con su propia composicion (13.5).
  db:
    image: postgres:17-alpine
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - db-data:/var/lib/postgresql/data
    ports:
      - '${DB_PORT:-5432}:5432'
    healthcheck:
      test: ['CMD-SHELL', 'pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}']
      interval: 5s
      timeout: 5s
      retries: 12
      start_period: 10s

  # Aplica las migraciones y termina. Es un servicio y no un paso dentro del
  # arranque de `api` para que su salida se lea sola (`compose logs migrate`) y
  # para que dos procesos no intenten migrar a la vez.
  migrate:
    build:
      context: ..
      dockerfile: infra/api.Dockerfile
      target: migrate
    restart: 'no'
    depends_on:
      db:
        condition: service_healthy
    environment:
      DATABASE_URL: postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB}
    command: ['npx', 'prisma', 'migrate', 'deploy']

  # Proceso HTTP: sesion, proyectos, pizarras, IA, imagen, XMI y generacion.
  api:
    build:
      context: ..
      dockerfile: infra/api.Dockerfile
    restart: unless-stopped
    depends_on:
      db:
        condition: service_healthy
      migrate:
        condition: service_completed_successfully
    environment:
      NODE_ENV: ${NODE_ENV:-development}
      API_PORT: 3001
      LOG_LEVEL: ${LOG_LEVEL:-info}
      WEB_ORIGIN: ${WEB_ORIGIN:-http://localhost:5173}
      DATABASE_URL: postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB}
      JWT_SECRET: ${JWT_SECRET:?JWT_SECRET es obligatorio; copia infra/.env.example a infra/.env}
      ACCESS_TOKEN_TTL_SECONDS: ${ACCESS_TOKEN_TTL_SECONDS:-900}
      REFRESH_TOKEN_TTL_SECONDS: ${REFRESH_TOKEN_TTL_SECONDS:-2592000}
      INVITE_TTL_SECONDS: ${INVITE_TTL_SECONDS:-604800}
      COOKIE_SECURE: ${COOKIE_SECURE:-false}
      COLLAB_INTERNAL_URL: http://collab:3002
      # Correo para la recuperacion de contrasena. `log` por defecto: la
      # plataforma arranca y el flujo funciona sin ninguna cuenta configurada.
      MAIL_PROVIDER: ${MAIL_PROVIDER:-log}
      MAIL_FROM: ${MAIL_FROM:-no-responder@plataforma-uml.local}
      MAIL_FROM_NAME: ${MAIL_FROM_NAME:-Plataforma UML}
      BREVO_API_KEY: ${BREVO_API_KEY:-}
      PASSWORD_RESET_TTL_SECONDS: ${PASSWORD_RESET_TTL_SECONDS:-3600}
      # Capa de IA (6.3 y ADR-019). Por defecto el adaptador simulado: la
      # plataforma arranca y el asistente responde sin ninguna clave ni conexion.
      #
      # Se reenvia la lista **completa**, incluidas las variables que hoy suelen
      # ir vacias. Antes faltaban `AI_VISION_MODEL` y `AI_MAX_RETRIES`, y el
      # sintoma era que el instructivo pedia ponerlas, uno las ponia, y dentro
      # del contenedor no existian: se configuraba algo que nadie leia.
      AI_LLM_PROVIDER: ${AI_LLM_PROVIDER:-mock}
      AI_LLM_MODEL: ${AI_LLM_MODEL:-}
      AI_LLM_FALLBACK_PROVIDER: ${AI_LLM_FALLBACK_PROVIDER:-}
      AI_LLM_FALLBACK_MODEL: ${AI_LLM_FALLBACK_MODEL:-}
      AI_VISION_PROVIDER: ${AI_VISION_PROVIDER:-mock}
      AI_VISION_MODEL: ${AI_VISION_MODEL:-}
      AI_VISION_FALLBACK_PROVIDER: ${AI_VISION_FALLBACK_PROVIDER:-}
      AI_VISION_FALLBACK_MODEL: ${AI_VISION_FALLBACK_MODEL:-}
      AI_SPEECH_PROVIDER: ${AI_SPEECH_PROVIDER:-mock}
      AI_SPEECH_MODEL: ${AI_SPEECH_MODEL:-}
      AI_SPEECH_FALLBACK_PROVIDER: ${AI_SPEECH_FALLBACK_PROVIDER:-}
      AI_SPEECH_FALLBACK_MODEL: ${AI_SPEECH_FALLBACK_MODEL:-}
      # Credenciales: una por proveedor, no una por puerto.
      ANTHROPIC_API_KEY: ${ANTHROPIC_API_KEY:-}
      GEMINI_API_KEY: ${GEMINI_API_KEY:-}
      OPENROUTER_API_KEY: ${OPENROUTER_API_KEY:-}
      GROQ_API_KEY: ${GROQ_API_KEY:-}
      CLOUDFLARE_ACCOUNT_ID: ${CLOUDFLARE_ACCOUNT_ID:-}
      CLOUDFLARE_API_TOKEN: ${CLOUDFLARE_API_TOKEN:-}
      AI_TIMEOUT_MS: ${AI_TIMEOUT_MS:-15000}
      AI_VISION_TIMEOUT_MS: ${AI_VISION_TIMEOUT_MS:-}
      AI_MAX_RETRIES: ${AI_MAX_RETRIES:-0}
      MISTRAL_API_KEY: ${MISTRAL_API_KEY:-}
      ZAI_API_KEY: ${ZAI_API_KEY:-}
      MOONSHOT_API_KEY: ${MOONSHOT_API_KEY:-}
      SAMBANOVA_API_KEY: ${SAMBANOVA_API_KEY:-}
      NVIDIA_API_KEY: ${NVIDIA_API_KEY:-}
      COHERE_API_KEY: ${COHERE_API_KEY:-}
      MODELSCOPE_API_KEY: ${MODELSCOPE_API_KEY:-}
      SENSENOVA_API_KEY: ${SENSENOVA_API_KEY:-}
      MISTRAL_BASE_URL: ${MISTRAL_BASE_URL:-}
      ZAI_BASE_URL: ${ZAI_BASE_URL:-}
      MOONSHOT_BASE_URL: ${MOONSHOT_BASE_URL:-}
      SAMBANOVA_BASE_URL: ${SAMBANOVA_BASE_URL:-}
      GROQ_BASE_URL: ${GROQ_BASE_URL:-}
      NVIDIA_BASE_URL: ${NVIDIA_BASE_URL:-}
      COHERE_BASE_URL: ${COHERE_BASE_URL:-}
      MODELSCOPE_BASE_URL: ${MODELSCOPE_BASE_URL:-}
      SENSENOVA_BASE_URL: ${SENSENOVA_BASE_URL:-}
      AI_CHAIN_TIMEOUT_MS: ${AI_CHAIN_TIMEOUT_MS:-}
      AI_VISION_CHAIN_TIMEOUT_MS: ${AI_VISION_CHAIN_TIMEOUT_MS:-}
      AI_SPEECH_CHAIN_TIMEOUT_MS: ${AI_SPEECH_CHAIN_TIMEOUT_MS:-}
      AI_QUOTA_COOLDOWN_MS: ${AI_QUOTA_COOLDOWN_MS:-}
      AI_COMPATIBLE_MAX_OUTPUT_TOKENS: ${AI_COMPATIBLE_MAX_OUTPUT_TOKENS:-}
      AI_LLM_FALLBACKS: ${AI_LLM_FALLBACKS:-}
      AI_VISION_FALLBACKS: ${AI_VISION_FALLBACKS:-}
      AI_SPEECH_FALLBACKS: ${AI_SPEECH_FALLBACKS:-}
      AI_LOG_USAGE: ${AI_LOG_USAGE:-true}
    ports:
      - '${API_PORT:-3001}:3001'
    healthcheck:
      test:
        [
          'CMD',
          'node',
          '-e',
          "fetch('http://127.0.0.1:3001/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))",
        ]
      interval: 10s
      timeout: 5s
      retries: 6
      start_period: 15s

  # Proceso WebSocket: salas por pizarra, presencia, persistencia y autorizacion.
  collab:
    build:
      context: ..
      dockerfile: infra/collab.Dockerfile
    restart: unless-stopped
    depends_on:
      db:
        condition: service_healthy
      migrate:
        condition: service_completed_successfully
    environment:
      NODE_ENV: ${NODE_ENV:-development}
      COLLAB_PORT: 3002
      LOG_LEVEL: ${LOG_LEVEL:-info}
      DATABASE_URL: postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB}
      # El mismo secreto que el proceso HTTP: uno emite los tokens y el otro los
      # verifica al autorizar la conexion (RA-15).
      JWT_SECRET: ${JWT_SECRET:?JWT_SECRET es obligatorio; copia infra/.env.example a infra/.env}
      STORE_DEBOUNCE_MS: ${STORE_DEBOUNCE_MS:-2000}
      STORE_MAX_DEBOUNCE_MS: ${STORE_MAX_DEBOUNCE_MS:-10000}
    ports:
      - '${COLLAB_PORT:-3002}:3002'
    healthcheck:
      test:
        [
          'CMD',
          'node',
          '-e',
          "fetch('http://127.0.0.1:3002/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))",
        ]
      interval: 10s
      timeout: 5s
      retries: 6
      start_period: 15s

  # Interfaz React servida como estatico.
  web:
    build:
      context: ..
      dockerfile: infra/web.Dockerfile
    restart: unless-stopped
    depends_on:
      api:
        condition: service_healthy
    ports:
      - '${WEB_PORT:-8080}:80'
    healthcheck:
      test: ['CMD', 'wget', '--spider', '-q', 'http://127.0.0.1/']
      interval: 10s
      timeout: 5s
      retries: 6
      start_period: 10s

  # Origen unico para la demostracion: las otras computadoras del aula llegan a
  # una sola direccion en lugar de tres puertos (plan maestro 4.3).
  proxy:
    image: caddy:2-alpine
    profiles: ['demo']
    restart: unless-stopped
    depends_on:
      api:
        condition: service_healthy
      collab:
        condition: service_healthy
      web:
        condition: service_healthy
    volumes:
      - ../infra/caddy/Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy-data:/data
      - caddy-config:/config
    ports:
      - '${PROXY_PORT:-80}:80'

  # Inspeccion de la base durante el desarrollo.
  adminer:
    image: adminer:5
    profiles: ['tools']
    restart: unless-stopped
    depends_on:
      db:
        condition: service_healthy
    environment:
      ADMINER_DEFAULT_SERVER: db
    ports:
      - '${ADMINER_PORT:-8081}:8080'

volumes:
  db-data:
  caddy-data:
  caddy-config:
```

---

### `infra/google-cloud.env.example`

```bash
# Perfil publico para la VM nueva 35.255.28.222. Los secretos reales van fuera de Git.
# production.sh obtiene APP_VERSION del commit actual.
DOMAIN=uml.asiscarretera.online
WEB_ORIGIN=https://uml.asiscarretera.online
ACME_EMAIL=info@asiscarretera.online
NODE_ENV=production
COOKIE_SECURE=true
POSTGRES_USER=uml
POSTGRES_DB=uml
POSTGRES_PASSWORD=CHANGE_ME
JWT_SECRET=CHANGE_ME
MAIL_PROVIDER=brevo
MAIL_FROM=info@asiscarretera.online
MAIL_FROM_NAME=UMLFORGE AI
BREVO_API_KEY=CHANGE_ME
# El archivo privado preparado conserva proveedores y credenciales IA locales.
AI_LLM_PROVIDER=mock
AI_VISION_PROVIDER=mock
AI_SPEECH_PROVIDER=mock
# Arranque inicial sin bucket; configurar copias externas antes de guardar datos importantes.
BACKUP_S3_URI=local-only
BACKUP_INTERVAL_SECONDS=86400
BACKUP_KEEP_DAYS=7
RATE_LIMIT_MAX=300
AUTH_RATE_LIMIT_MAX=20
WORK_RATE_LIMIT_MAX=20
```

---

### `infra/nginx.conf`

```nginx
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    # El navegador habla siempre con un solo origen, tambien en el perfil por
    # defecto. Sin esto la interfaz servida en :8080 no tendria forma de llegar
    # a los dos procesos y solo funcionaria con el perfil `demo` encendido.
    resolver 127.0.0.11 valid=30s;

    location /api/ {
        # La API admite XMI de hasta 24 MiB y fotos de hasta 12 MiB. El limite
        # implicito de nginx (1 MiB) bloqueaba estos archivos antes de la API.
        client_max_body_size 24m;
        # Vision puede necesitar mas de los 60 segundos implicitos del proxy.
        # La cadena de vision tiene 300s de plazo total por defecto.
        proxy_read_timeout 330s;
        proxy_pass http://api:3001/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # La salud del proceso de colaboracion, con coincidencia exacta.
    #
    # Hace falta un bloque propio porque el de abajo usa `proxy_pass` con URI:
    # nginx sustituye el prefijo `/collab` por `/` y `/collab/health` llega al
    # proceso como `//health`, que no es ninguna ruta y devuelve 404. La
    # verificacion de integracion continua espera aqui a que la plataforma este
    # sana, asi que el fallo no aparecia al ejecutar las pruebas contra un
    # entorno ya levantado a mano: solo en un arranque limpio.
    #
    # `=` gana a cualquier prefijo, asi que este bloque no toca el WebSocket.
    location = /collab/health {
        proxy_pass http://collab:3002/health;
        proxy_set_header Host $host;
    }

    # Sin barra final en el `location`: el cliente de colaboracion conecta a
    # `/collab` a secas, y con `location /collab/` nginx responde un 301 para
    # anadir la barra, lo que rompe el handshake del WebSocket sin dar ninguna
    # pista util en el navegador.
    location /collab {
        proxy_pass http://collab:3002/;
        proxy_http_version 1.1;
        # La sala de colaboracion viaja por WebSocket: sin estas dos cabeceras
        # nginx cierra la conexion en cuanto el cliente pide el cambio de
        # protocolo.
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
    }

    location = /sw.js {
        add_header Cache-Control "no-cache";
        try_files $uri =404;
    }

    location = /index.html {
        add_header Cache-Control "no-cache";
    }

    location / {
        # La aplicacion enruta del lado del cliente: cualquier ruta desconocida
        # devuelve el documento raiz en lugar de un 404.
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|woff2|svg|png|jpg)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

---

### `infra/production.env.example`

```bash
# Copy outside the repository, for example /etc/uml/production.env, chmod 600.
# Start from infra/.env.example if you need all supported AI fallback settings.
APP_VERSION=SET_COMMIT_SHA
DOMAIN=uml.example.com
WEB_ORIGIN=https://uml.example.com
ACME_EMAIL=admin@example.com
POSTGRES_USER=uml
POSTGRES_DB=uml
# Use openssl rand -hex 32 (URL-safe); changing this does not change an existing DB password.
POSTGRES_PASSWORD=CHANGE_ME
# Use openssl rand -hex 48; shared by both services through Compose.
JWT_SECRET=CHANGE_ME
MAIL_FROM=admin@example.com
MAIL_FROM_NAME=UMLFORGE AI
BREVO_API_KEY=CHANGE_ME
# Choose real providers/models and their credentials before enabling AI features.
AI_LLM_PROVIDER=mock
AI_VISION_PROVIDER=mock
AI_SPEECH_PROVIDER=mock
# Copias fuera de la VM. Cualquier almacenamiento compatible con S3 sirve:
# AWS S3, Cloudflare R2, Backblaze B2, MinIO, DigitalOcean Spaces, Azure con
# una pasarela S3, etc. Escribe `local-only` para arrancar sin bucket: las
# copias se quedan en el volumen `backups` de la VM y perderla es perderlas.
BACKUP_S3_URI=s3://YOUR_PRIVATE_BUCKET/uml
AWS_DEFAULT_REGION=us-east-1
# EC2: use an instance IAM role. Other clouds: S3-compatible endpoint and limited keys.
# AWS_ENDPOINT_URL=https://s3.your-provider.example
# AWS_ACCESS_KEY_ID=
# AWS_SECRET_ACCESS_KEY=
BACKUP_INTERVAL_SECONDS=86400
BACKUP_KEEP_DAYS=7
RATE_LIMIT_MAX=300
AUTH_RATE_LIMIT_MAX=20
WORK_RATE_LIMIT_MAX=20
```

---

### `infra/web.Dockerfile`

```dockerfile
# Interfaz React. Se compila a estatico y la sirve nginx; el enrutado del lado
# del cliente cae siempre en index.html.

FROM node:22.15.0-alpine AS build
RUN npm install --global npm@11.6.0
WORKDIR /app
# El esquema entra antes de `npm ci` porque el postinstall de la raiz genera el
# cliente de Prisma. La interfaz no lo usa, pero la instalacion del monorepo si.
COPY package.json package-lock.json prisma.config.ts ./
COPY backend/prisma/ backend/prisma/
COPY shared/contracts/package.json shared/contracts/
COPY shared/domain-core/package.json shared/domain-core/
COPY shared/generation-ir/package.json shared/generation-ir/
COPY shared/generator-backend/package.json shared/generator-backend/
COPY shared/xmi/package.json shared/xmi/
COPY shared/ai/package.json shared/ai/
COPY shared/yjs-adapter/package.json shared/yjs-adapter/
COPY fixtures/package.json fixtures/
COPY backend/api/package.json backend/api/
COPY backend/collab/package.json backend/collab/
COPY frontend/package.json frontend/
RUN npm ci --no-audit --no-fund
COPY tsconfig.json ./
COPY config/tsconfig.base.json config/
COPY shared/ shared/
COPY frontend/ frontend/
RUN npm run build --workspace @uml/web

FROM nginx:1.27-alpine AS runtime
COPY infra/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/frontend/dist /usr/share/nginx/html
EXPOSE 80
```

---

### `infra/aws/backup-policy.json`

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "WriteUmlBackups",
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:AbortMultipartUpload"],
      "Resource": "arn:aws:s3:::YOUR_PRIVATE_BUCKET/uml/*"
    }
  ]
}
```

---

### `infra/backup/Dockerfile`

```dockerfile
FROM postgres:17-alpine
RUN apk add --no-cache aws-cli util-linux && mkdir /backups && chown postgres:postgres /backups
COPY infra/backup/backup.sh /opt/backup.sh
USER postgres
ENTRYPOINT ["sh", "/opt/backup.sh"]
CMD ["loop"]
```

---

### `infra/backup/backup.sh`

```bash
#!/bin/sh
set -eu
umask 077
export PGCONNECT_TIMEOUT=10

backup() (
  # Kernel lock releases even after a crash; no stale lock can block all future copies.
  exec 9>/backups/backup.lock
  flock -n 9 || { echo 'Otra copia está en curso' >&2; return 1; }
  stamp=$(date -u +%Y%m%dT%H%M%SZ)
  partial=$(mktemp "/backups/uml-$stamp-XXXXXX")
  file="$partial.dump"
  pg_dump --format=custom --no-owner --no-acl --file="$partial"
  pg_restore --list "$partial" >/dev/null
  mv "$partial" "$file"
  # `local-only`: la copia se queda en el volumen del servidor. Sirve para una
  # VM sin bucket (Azure, GCP, un VPS cualquiera) pero no protege de perder la
  # VM; se avisa en cada copia para que no pase desapercibido.
  case "${BACKUP_S3_URI:-}" in
    '') ;;
    local-only) echo 'AVISO: copia solo local (BACKUP_S3_URI=local-only); perder la VM es perder las copias' >&2 ;;
    s3://*/*) aws s3 cp "$file" "${BACKUP_S3_URI%/}/$(basename "$file")" --only-show-errors ;;
    *) echo 'BACKUP_S3_URI requiere s3://bucket/prefijo o local-only' >&2; return 1 ;;
  esac
  # Mark success only after the off-host upload also succeeds.
  date +%s > /backups/last-success
  find /backups -maxdepth 1 -type f -name 'uml-*.dump' -mtime "+${BACKUP_KEEP_DAYS:-7}" -exec rm -f '{}' \;
  echo "Copia verificada: $(basename "$file")"
)

case "${1:-loop}" in
  once) backup ;;
  health)
    test -f /backups/last-success
    age=$(( $(date +%s) - $(cat /backups/last-success) ))
    test "$age" -lt "$(( ${BACKUP_INTERVAL_SECONDS:-86400} + 7200 ))"
    ;;
  loop)
    while :; do
      # A failed upload retries soon and leaves health stale, rather than waiting a day.
      if (backup); then sleep "${BACKUP_INTERVAL_SECONDS:-86400}"; else
        echo 'Copia fallida; reintento en cinco minutos' >&2
        sleep 300
      fi
    done
    ;;
  *) echo 'Uso: backup.sh once|loop|health' >&2; exit 2 ;;
esac
```

---

### `infra/caddy/Caddyfile`

```nginx
# Origen unico para la demostracion. El navegador solo conoce esta direccion:
# desaparecen los problemas de origen cruzado y las otras computadoras del aula
# llegan a un puerto en lugar de tres.
#
# Los dos procesos sirven sus rutas en la raiz (`/health`, no `/api/health`), asi
# que el prefijo se despoja aqui. Es el mismo comportamiento que nginx aplica en
# el perfil por defecto: una sola forma de direccionar, dos lugares donde se
# resuelve.

:80 {
	encode gzip

	handle_path /api/* {
		reverse_proxy api:3001
	}

	# `/collab*` y no `/collab/*`: el cliente conecta a `/collab` a secas.
	handle_path /collab* {
		reverse_proxy collab:3002
	}

	handle {
		reverse_proxy web:80
	}
}
```

---

### `infra/caddy/Caddyfile.production`

```bash
{
	email {$ACME_EMAIL}
}

{$DOMAIN} {
	encode zstd gzip
	header {
		Strict-Transport-Security "max-age=31536000"
		X-Content-Type-Options nosniff
		X-Frame-Options DENY
		Referrer-Policy strict-origin-when-cross-origin
		Permissions-Policy "camera=(self), microphone=(self), geolocation=()"
		Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: blob:; font-src 'self' data:; connect-src 'self' wss:; media-src 'self' blob:; worker-src 'self' blob:; object-src 'none'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'"
		-Server
	}

	# Route directly: one trusted hop, Caddy discards spoofed forwarding headers.
	handle_path /api/* {
		request_body {
			max_size 24MB
		}
		reverse_proxy api:3001 {
			transport http {
				response_header_timeout 330s
			}
		}
	}
	handle_path /collab* {
		reverse_proxy collab:3002
	}
	handle {
		reverse_proxy web:80
	}
}
```

---

### `infra/systemd/uml-monitor.service`

```ini
[Unit]
Description=Comprobar HTTPS, disponibilidad, copias y disco de UML
After=docker.service network-online.target

[Service]
Type=oneshot
WorkingDirectory=/opt/uml
Environment=UML_ENV_FILE=/etc/uml/production.env
EnvironmentFile=-/etc/uml/monitor.env
ExecStart=/bin/bash /opt/uml/scripts/production.sh monitor
# Connect systemd failures or the public /api/ready endpoint to your alerting service.
```

---

### `infra/systemd/uml-monitor.timer`

```ini
[Unit]
Description=Comprobar plataforma UML cada cinco minutos

[Timer]
OnBootSec=3min
OnUnitActiveSec=5min
Persistent=true

[Install]
WantedBy=timers.target
```

---

## Integracion continua

Flujos de trabajo que ejecutan formato, lint, tipos y pruebas.

### Estructura

```text
.github/
|-- modernize/
|   `-- java-upgrade/
|       |-- hooks/
|       |   `-- scripts/
|       |       |-- recordToolUse.ps1
|       |       `-- recordToolUse.sh
|       `-- .gitignore
`-- workflows/
    `-- ci.yml
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `.github/modernize/java-upgrade/.gitignore` | 3 |
| `.github/modernize/java-upgrade/hooks/scripts/recordToolUse.ps1` | 18 |
| `.github/modernize/java-upgrade/hooks/scripts/recordToolUse.sh` | 28 |
| `.github/workflows/ci.yml` | 185 |

---

### `.github/modernize/java-upgrade/.gitignore`

```

**/*
```

---

### `.github/modernize/java-upgrade/hooks/scripts/recordToolUse.ps1`

```powershell
# Records run_in_terminal and appmod-* tool calls as JSONL for the extension to process.

$raw = [Console]::In.ReadToEnd()

if ($raw -notmatch '"tool_name"\s*:\s*"([^"]+)"') { exit 0 }
$toolName = $Matches[1]

if ($toolName -ne 'run_in_terminal' -and $toolName -notlike 'appmod-*') { exit 0 }

if ($raw -notmatch '"session_id"\s*:\s*"([^"]+)"') { exit 0 }
$sessionId = $Matches[1]

$hooksDir = '.github\modernize\java-upgrade\hooks'
if (-not (Test-Path $hooksDir)) { New-Item -ItemType Directory -Path $hooksDir -Force | Out-Null }

$line = ($raw -replace '[\r\n]+', ' ').Trim() + "`n"
[System.IO.File]::AppendAllText("$hooksDir\$sessionId.json", $line, [System.Text.UTF8Encoding]::new($false))
```

---

### `.github/modernize/java-upgrade/hooks/scripts/recordToolUse.sh`

```bash
#!/usr/bin/env bash
# Records run_in_terminal and appmod-* tool calls as JSONL for the extension to process.

INPUT=$(cat)

TOOL_NAME="${INPUT#*\"tool_name\":\"}"
TOOL_NAME="${TOOL_NAME%%\"*}"

case "$TOOL_NAME" in
  run_in_terminal|appmod-*) ;;
  *) exit 0 ;;
esac

case "$INPUT" in
  *'"session_id":"'*) ;;
  *) exit 0 ;;
esac

SESSION_ID="${INPUT#*\"session_id\":\"}"
SESSION_ID="${SESSION_ID%%\"*}"
[ -z "$SESSION_ID" ] && exit 0

HOOKS_DIR=".github/modernize/java-upgrade/hooks"
mkdir -p "$HOOKS_DIR"

LINE=$(printf '%s' "$INPUT" | tr -d '\r\n')
printf '%s\n' "$LINE" >> "$HOOKS_DIR/${SESSION_ID}.json"
```

---

### `.github/workflows/ci.yml`

```yaml
# Integracion continua de la plataforma (RNF-13).
#
# En la fase 0 el flujo verifica formato, lint, tipos, pruebas y que el esquema
# de base de datos es valido. A partir de la fase 2 se anade el banco de
# regresion del generador: cada cambio ejecuta al menos T01 y la rama principal
# el banco completo.
#
# RNF-15 y 15.5: las pruebas del dominio no necesitan base de datos, navegador
# ni proveedor de IA, y por eso `npm test` corre en milisegundos.
#
# Las otras dos levantan PostgreSQL en Docker porque no tiene sentido probarlas
# sin el: la integracion de la API comprueba autorizacion, membresias y
# cascadas, que solo existen de verdad en la base; y la del generador exige
# comprobar el backend generado en ejecucion.

name: CI

on:
  push:
    branches: [main]
  pull_request:

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

env:
  NODE_VERSION: '22.15.0'

jobs:
  produccion:
    name: HTTPS, WebSocket y restauracion aislada
    runs-on: ubuntu-latest
    timeout-minutes: 30
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: npm
      - run: npm ci --no-audit --no-fund
      - run: npx playwright install --with-deps chromium
      - run: npm run test:production

  verificacion:
    name: Formato, lint, tipos y pruebas
    runs-on: ubuntu-latest
    timeout-minutes: 15

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: npm

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '21'
          cache: maven
          # El POM se genera en tiempo de prueba; esta plantilla es la entrada
          # estable que determina sus dependencias y siempre existe en checkout.
          cache-dependency-path: templates/spring/pom.xml.hbs

      - name: Instalar dependencias exactas del lockfile
        run: npm ci

      - name: Formato
        run: npm run format:check

      - name: Lint
        run: npm run lint

      - name: Tipos
        run: npm run typecheck

      - name: Pruebas
        run: npm test

      - name: Integracion de la API
        run: npm run test:api

      - name: Backend generado T01
        run: npm run test:generated

      - name: Esquema de base de datos
        run: npm run db:validate
        env:
          DATABASE_URL: postgresql://ci:ci@localhost:5432/ci

      - name: Publicar resultados
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: reportes-vitest
          path: reports/
          if-no-files-found: ignore

  # RNF-13: cada cambio ejecuta al menos T01; la rama principal, el banco
  # completo. Los ocho modelos se compilan, arrancan y ejecutan su CRUD, y eso
  # cuesta minutos que no tiene sentido pagar en cada propuesta de cambio.
  banco-completo:
    name: Banco de regresion T01-T08 (incluye T07R)
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    timeout-minutes: 60

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: npm

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '21'
          cache: maven
          cache-dependency-path: templates/spring/pom.xml.hbs

      - name: Instalar dependencias exactas del lockfile
        run: npm ci

      - name: Banco completo del backend generado
        run: npm run test:bank

  extremo-a-extremo:
    name: Dos navegadores contra el entorno completo
    runs-on: ubuntu-latest
    timeout-minutes: 30

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: npm

      - name: Instalar dependencias exactas del lockfile
        run: npm ci

      - name: Instalar el navegador
        run: npm run e2e:install

      - name: Configuracion del entorno
        run: |
          cp infra/.env.example infra/.env
          sed -i "s/^POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=$(openssl rand -hex 16)/" infra/.env
          sed -i "s/^JWT_SECRET=.*/JWT_SECRET=$(openssl rand -hex 32)/" infra/.env

      - name: Levantar la plataforma
        run: npm run up

      - name: Esperar a que todo este sano
        run: |
          for intento in $(seq 1 60); do
            if curl -fs http://localhost:8080/api/health > /dev/null                && curl -fs http://localhost:8080/collab/health > /dev/null; then
              exit 0
            fi
            sleep 5
          done
          docker compose -f infra/compose.yml --env-file infra/.env ps
          docker compose -f infra/compose.yml --env-file infra/.env logs --tail 80
          exit 1

      - name: Pruebas de dos navegadores
        run: npm run test:e2e

      - name: Registros si algo fallo
        if: failure()
        run: docker compose -f infra/compose.yml --env-file infra/.env logs --tail 200

      - name: Publicar trazas
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: trazas-playwright
          path: test-results/
          if-no-files-found: ignore
```

---

## Configuracion compartida

Bases de TypeScript y configuracion de las pruebas de integracion.

### Estructura

```text
config/
|-- tsconfig.base.json
`-- vitest.integration.config.ts
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `config/tsconfig.base.json` | 29 |
| `config/vitest.integration.config.ts` | 30 |

---

### `config/tsconfig.base.json`

```json
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "compilerOptions": {
    "target": "ES2023",
    "lib": ["ES2023"],
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "types": ["node"],

    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitOverride": true,
    "noFallthroughCasesInSwitch": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "verbatimModuleSyntax": true,
    "isolatedModules": true,

    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "composite": true,
    "incremental": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  }
}
```

---

### `config/vitest.integration.config.ts`

```ts
import { fileURLToPath } from 'node:url';
import { defineConfig } from 'vitest/config';

/**
 * Pruebas de integracion de la API.
 *
 * Van aparte de `npm test` a proposito: levantan un PostgreSQL en Docker y
 * aplican las migraciones, asi que tardan segundos en lugar de milisegundos. El
 * bucle rapido del nucleo de dominio no debe depender de Docker (RNF-15).
 *
 *   npm run test:api
 */
export default defineConfig({
  // Vitest toma como raiz la carpeta del archivo de configuracion. Este vive en
  // `config/`, asi que se ancla al repositorio: sin esto buscaria las pruebas
  // dentro de `config/` y no encontraria ninguna.
  root: fileURLToPath(new URL('..', import.meta.url)),
  test: {
    environment: 'node',
    include: ['backend/*/tests/integration/**/*.integration.test.ts'],
    // Cada archivo levanta su propio contenedor; en paralelo se pisarian los
    // recursos de la maquina sin ganar tiempo real.
    fileParallelism: false,
    testTimeout: 30_000,
    hookTimeout: 180_000,
    reporters: process.env['CI'] ? ['default', 'junit'] : ['default'],
    outputFile: { junit: 'reports/vitest-integration-junit.xml' },
  },
});
```

---

## Raiz del monorepo

### Estructura

```text
package.json
`-- package.json
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `package.json` | 74 |

---

### `package.json`

```json
{
  "name": "plataforma-uml",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "engines": {
    "node": ">=22.15.0",
    "npm": ">=11.0.0"
  },
  "workspaces": [
    "shared/*",
    "fixtures",
    "backend/api",
    "backend/collab",
    "frontend"
  ],
  "scripts": {
    "postinstall": "prisma generate",
    "build": "npm run build --workspaces --if-present",
    "typecheck": "tsc --build && tsc -p config/tsconfig.test.json",
    "lint": "eslint . --max-warnings=0",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "test": "vitest run",
    "test:watch": "vitest",
    "pretest:generated": "npm run build",
    "test:generated": "tsx shared/generator-backend/tests/verify-bank.ts T01",
    "check": "npm run format:check && npm run lint && npm run typecheck && npm run test",
    "clean": "tsc --build --clean",
    "db:generate": "prisma generate",
    "db:migrate": "prisma migrate dev",
    "db:studio": "prisma studio",
    "dev:api": "npm run dev --workspace @uml/api",
    "dev:collab": "npm run dev --workspace @uml/collab",
    "dev:web": "npm run dev --workspace @uml/web",
    "up": "docker compose -f infra/compose.yml --env-file infra/.env up -d",
    "down": "docker compose -f infra/compose.yml --env-file infra/.env down",
    "ps": "docker compose -f infra/compose.yml --env-file infra/.env ps",
    "db:validate": "prisma validate",
    "fixtures:emit": "npm run emit --workspace @uml/fixtures",
    "bank:report": "npm run report --workspace @uml/fixtures",
    "test:api": "vitest run --config config/vitest.integration.config.ts",
    "test:e2e": "playwright test --config e2e/playwright.config.ts",
    "test:offline": "npm run build --workspace @uml/web && playwright test --config e2e/offline/playwright.config.ts",
    "test:production": "node scripts/verify-production.mjs",
    "e2e:install": "playwright install --with-deps chromium",
    "test:bank": "tsx shared/generator-backend/tests/verify-bank.ts",
    "demo:backend": "tsx scripts/generate-demo-backend.ts",
    "predemo:mobile": "tsc --build shared/generator-backend fixtures shared/xmi",
    "demo:mobile": "tsx scripts/generate-demo-backend.ts --mobile",
    "seed": "tsx scripts/seed-demo.ts"
  },
  "overrides": {
    "deepmerge-ts": "8.0.2",
    "mysql2": "3.24.4"
  },
  "devDependencies": {
    "@eslint/js": "^10.0.1",
    "@hocuspocus/provider": "^4.6.0",
    "@playwright/test": "^1.62.1",
    "@types/archiver": "^8.0.0",
    "@types/node": "^22.0.0",
    "@types/pg": "^8.23.1",
    "eslint": "^10.9.1",
    "eslint-config-prettier": "^10.0.0",
    "prettier": "^3.3.0",
    "prisma": "7.10.0",
    "tsx": "^4.19.0",
    "typescript": "^5.6.0",
    "typescript-eslint": "^8.0.0",
    "vitest": "^3.0.0"
  }
}
```

---

## TypeScript raiz

### Estructura

```text
tsconfig.json
`-- tsconfig.json
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `tsconfig.json` | 39 |

---

### `tsconfig.json`

```json
{
  "files": [],
  "references": [
    {
      "path": "shared/contracts"
    },
    {
      "path": "shared/domain-core"
    },
    {
      "path": "fixtures"
    },
    {
      "path": "shared/generation-ir"
    },
    {
      "path": "shared/generator-backend"
    },
    {
      "path": "shared/xmi"
    },
    {
      "path": "shared/ai"
    },
    {
      "path": "shared/yjs-adapter"
    },
    {
      "path": "backend/api"
    },
    {
      "path": "backend/collab"
    },
    {
      "path": "frontend"
    }
  ]
}
```

---

## Vitest

### Estructura

```text
vitest.config.ts
`-- vitest.config.ts
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `vitest.config.ts` | 40 |

---

### `vitest.config.ts`

```ts
import { defineConfig } from 'vitest/config';

/**
 * Un solo ejecutor de pruebas para todo el monorepo.
 *
 * RNF-15: las pruebas del paquete de dominio corren en el entorno `node`, sin
 * navegador, sin base de datos, sin WebSocket, sin proveedor de IA y sin sistema
 * de archivos. Las pruebas de extremo a extremo con dos navegadores viven aparte
 * y llegan en la fase 5.
 */
export default defineConfig({
  test: {
    environment: 'node',
    include: [
      '{shared,backend}/*/tests/**/*.test.ts',
      'frontend/tests/**/*.test.ts',
      'fixtures/tests/**/*.test.ts',
    ],
    exclude: ['**/node_modules/**', '**/dist/**', '**/tests/integration/**', 'e2e/**'],
    // Levantar la aplicacion Fastify en un `beforeAll` cuesta unos cinco
    // segundos de carga de modulos —Prisma, los adaptadores de IA, las
    // plantillas— y el limite por defecto son diez. Ese margen se agota en
    // cuanto la maquina esta cargada, y el sintoma es un fallo que no se
    // reproduce: pasa aislado y falla en la suite completa.
    hookTimeout: 30_000,
    reporters: process.env['CI'] ? ['default', 'junit'] : ['default'],
    outputFile: { junit: 'reports/vitest-junit.xml' },
    coverage: {
      provider: 'v8',
      reportsDirectory: 'reports/coverage',
      include: [
        'shared/*/src/**/*.ts',
        'backend/*/src/**/*.ts',
        'frontend/src/**/*.ts',
        'fixtures/src/**/*.ts',
      ],
    },
  },
});
```

---

## ESLint

### Estructura

```text
eslint.config.js
`-- eslint.config.js
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `eslint.config.js` | 39 |

---

### `eslint.config.js`

```js
import js from '@eslint/js';
import prettier from 'eslint-config-prettier';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  {
    ignores: [
      'generated-output/**',
      'output/**',
      'tmp/**',
      'temp/**',
      '.agents/**',
      '.claude/**',
      '**/dist/**',
      '**/dist-types/**',
      '**/node_modules/**',
      '**/reports/**',
      '**/test-results/**',
      '**/playwright-report/**',
      'templates/**',
      'backend/prisma/migrations/**',
    ],
  },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    rules: {
      '@typescript-eslint/consistent-type-imports': 'error',
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
      ],
      'no-console': ['warn', { allow: ['warn', 'error'] }],
      eqeqeq: ['error', 'always'],
    },
  },
  prettier,
);
```

---

## Prettier

### Estructura

```text
.prettierrc.json
`-- .prettierrc.json
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `.prettierrc.json` | 10 |

---

### `.prettierrc.json`

```json
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100,
  "tabWidth": 2,
  "endOfLine": "lf",
  "overrides": [{ "files": "*.md", "options": { "proseWrap": "preserve" } }]
}
```

---

## Exclusiones de Docker

### Estructura

```text
.dockerignore
`-- .dockerignore
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `.dockerignore` | 75 |

---

### `.dockerignore`

```
# Lo que no entra en ninguna imagen.
#
# Cada exclusion es tamano de contexto que no se manda al demonio y capa que no
# se invalida: tocar un ADR no deberia reconstruir la API.

# Dependencias y compilacion: se instalan y se compilan dentro de la imagen.
node_modules
**/node_modules
**/dist
**/dist-types
**/*.tsbuildinfo
**/*.timestamp-*.mjs
**/.vite

# Secretos: la configuracion entra por variables de entorno, nunca en una capa.
**/.env
**/.env.*
**/*.env
**/*.dump
**/*.dump.partial
!**/.env.example
**/*.pem
**/*.keystore
**/*.jks

# Herramientas de desarrollo, no del producto.
.agents
.claude
skills-lock.json
.vscode
.idea
**/.eslintcache
**/.prettiercache
**/.cache

# Salidas de herramientas y registros.
reports
coverage
test-results
playwright-report
blob-report
**/*.log

# Artefactos generados y trabajo local: apps compiladas (Flutter, Maven),
# modelos de Enterprise Architect y documentos exportados. Son cientos de MB que
# ninguna imagen usa.
generated-output
tmp
temp
output
**/*.zip
**/*.eap
**/*.eapx
**/*.qea
**/*.qeax
**/*.ldb
**/target
**/build
**/.dart_tool
**/.gradle

# Pruebas de extremo a extremo: corren contra el entorno levantado, desde fuera.
e2e

# Documentacion. `fixtures` no se excluye: `npm ci` necesita el package.json de
# cada workspace declarado en el lockfile, y sin el la construccion falla.
docs
*.md

# Historia, automatizacion y sistema.
.git
.github
**/.DS_Store
**/Thumbs.db
```

---

## Exclusiones de Git

### Estructura

```text
.gitignore
`-- .gitignore
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `.gitignore` | 114 |

---

### `.gitignore`

```
# Dependencias
node_modules/
.pnp.*
.npm/

# Compilacion
dist/
dist-types/
*.tsbuildinfo
*.timestamp-*.mjs

# Entorno (RNF-08: el real nunca se versiona, el ejemplo si)
.env
.env.*
!.env.example
infra/.env
*.env
!*.env.example
*.dump
*.dump.partial

# Secretos y firmas locales
*.pem
*.keystore
*.jks
key.properties

# Salidas de herramientas
reports/
coverage/
.vite/
playwright-report/
blob-report/
test-results/
.eslintcache
.prettiercache
.cache/

# Registros
logs/
*.log
npm-debug.log*

# Prisma
backend/prisma/generated/

# Artefactos generados por la plataforma
generated-output/
*.zip

# Trabajo local fuera del producto: scripts desechables y sus salidas
# (modelos de Enterprise Architect, figuras, documentos exportados).
/tmp/
/temp/
/output/
*.tmp
*.bak

# Enterprise Architect: modelos y bloqueos que genera al abrirlos.
*.eap
*.eapx
*.qea
*.qeax
*.ldb

# Documentos de Office abiertos (archivos de bloqueo).
~$*

# Java / Maven (proyectos generados que se compilen localmente)
target/
.mvn/wrapper/maven-wrapper.jar
*.iml
*.class
hs_err_pid*

# Flutter / Dart / Android (apps generadas que se compilen localmente)
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.pub-cache/
.gradle/
.kotlin/
.cxx/
local.properties
**/android/app/debug/
**/android/app/profile/
**/android/app/release/
build/

# Editores y sistema
.DS_Store
Thumbs.db
ehthumbs.db
desktop.ini
$RECYCLE.BIN/
*.swp
*~
.idea/
.vscode/*
!.vscode/extensions.json
!.vscode/settings.json

# Herramientas de asistencia: configuracion de la maquina, no del proyecto.
.agents/
.claude/
.github/modernize/
skills-lock.json

# Documentos de trabajo que no se versionan: el plan maestro y la especificacion
# de apoyo. La documentacion que si se versiona —ADR, requisitos, arquitectura,
# despliegue— vive en el resto de `docs/`. Anclado a la raiz: sin la barra
# inicial tambien ignoraba `templates/flutter/docs/`, que es codigo del generador.
/docs/*
```

---

## Atributos de Git

### Estructura

```text
.gitattributes
`-- .gitattributes
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `.gitattributes` | 23 |

---

### `.gitattributes`

```
# El repositorio guarda y entrega LF en todas las plataformas.
#
# Sin esto, un checkout en Windows convierte a CRLF y `prettier --check` marca
# como mal formateado todo el arbol, mientras en Linux pasa. Es una diferencia
# entre maquinas del equipo que no aporta nada y cuesta media tarde diagnosticar.
* text=auto eol=lf

# Binarios: nunca tocar.
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.ico binary
*.pdf binary
*.zip binary
*.jar binary
*.woff binary
*.woff2 binary
*.ttf binary

# El lockfile es generado: no ensucia las revisiones.
package-lock.json linguist-generated=true -diff
```

---

## Exclusiones de Prettier

### Estructura

```text
.prettierignore
`-- .prettierignore
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `.prettierignore` | 19 |

---

### `.prettierignore`

```
dist/
dist-types/
node_modules/
reports/
package-lock.json
backend/prisma/migrations/
templates/
*.md

# Herramientas instaladas, no codigo del proyecto: se dejan tal cual vienen.
.agents/
.claude/
test-results/
playwright-report/
generated-output/
output/
tmp/
temp/
```

---

## Version de Node

### Estructura

```text
.nvmrc
`-- .nvmrc
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `.nvmrc` | 2 |

---

### `.nvmrc`

```
22.15.0
```

---

## EditorConfig

### Estructura

```text
.editorconfig
`-- .editorconfig
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `.editorconfig` | 19 |

---

### `.editorconfig`

```
root = true

[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 2
insert_final_newline = true
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false

[*.{java,xml}]
indent_size = 4

[*.dart]
indent_size = 2
```

---

## README del proyecto

### Estructura

```text
README.md
`-- README.md
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `README.md` | 284 |

---

### `README.md`

````markdown
# Plataforma colaborativa de diseño de bases de datos

Plataforma web colaborativa de modelado conceptual basada en un subconjunto de
diagramas de clases UML. Varios usuarios editan la misma pizarra a la vez, por
interfaz gráfica o por asistente de texto y voz, y desde una pizarra seleccionada
se genera un backend Spring Boot con PostgreSQL listo para compilar y ejecutar.

Documento maestro: [`docs/referencia/plan-integral-plataforma-uml.md`](docs/referencia/plan-integral-plataforma-uml.md).
Entrega: **23 de septiembre**. Alcance congelado.

Generador actualizado: [backend de gestión, DTO para Flutter, Postman y despliegue](docs/generacion-backend-gestion.md). `npm run demo:backend` prepara un ejemplo de ventas con ZIP y diagrama XMI.

Auditoría del 5 de septiembre: [estado, correcciones y faltantes](docs/auditoria-2026-09-05.md).
El antiguo objetivo Dart de capa de datos fue retirado. La ampliación del 6 de septiembre incorpora un nuevo [generador Flutter Android con backend protegido, SQLite y GGUF](docs/generacion-flutter-android.md), opcional desde el panel Generación.

Para preparar un ejemplo Android: `npm run demo:mobile`. En la carpeta generada, `.\apk.bat build` crea el APK en `mobile/dist/`; `.\apk.bat install` compila e instala por USB; `.\apk.bat deploy` levanta backend y PostgreSQL con Docker, conecta por USB e instala; `.\apk.bat run --usb` prueba con recarga en caliente y backend iniciado. Cada ZIP incluye `COMANDOS.md` con estas órdenes y sus opciones. El panel Generación también las muestra. En Linux/macOS usar `sh apk.sh`.

---

## Arranque rápido

Para Google Cloud Compute Engine, seguir la [guía de Google Cloud](infra/GOOGLE-CLOUD.md). Para otros proveedores con una VM y dominio HTTPS, seguir la [guía de producción](infra/DEPLOYMENT.md).

Despliegue preparado para **uml.asiscarretera.online** en **35.255.28.222**: [configuración y pasos de instalación](infra/DEPLOY-UML.md).
Incluye Compose separado, certificados, cuotas, copias S3, restauración aislada,
monitorización y actualización por versión. `npm run test:production` verifica el
entorno HTTPS en contenedores temporales.

### Aprender a usar el software

El editor permite abrir y recargar pizarras visitadas sin conexión. Abre la versión compilada con conexión y espera **Disponible sin conexión** en cada pizarra; después podrás editar y sincronizar al reconectar. Consulta [uso, requisitos y límites del editor offline](frontend/OFFLINE.md).

Para descargar el diagrama como imagen, abre **Importar → Exportar imagen PNG**, elige el nombre y pulsa **Guardar PNG**. Incluye clases y relaciones fuera de la vista, conserva el tema actual y permite exportar también con permiso de lectura. Se genera en el navegador; no necesita servicios adicionales en Google Cloud.

Para practicar directamente en la interfaz, abre **Ayuda → Guiarme en esta pantalla**. El recorrido resalta controles reales y muestra instrucciones junto a ellos; detecta escritura y clics, permite ir al control, volver, omitir o pausar con Escape. Continúa cuando navegas de proyectos a una pizarra. **Retomar recorrido interactivo** recupera el último paso guardado para esa pantalla. Puede abrir paneles o pestañas para mostrar controles, pero crear datos, importar y generar requieren acciones del usuario. Los pasos omitidos no certifican que se hayan realizado las operaciones.

El botón **Ayuda** de la barra superior está disponible en Mis proyectos, en cada proyecto, en Mi cuenta y en el editor. Abre una guía con nueve temas: proyectos y pizarras, clases y atributos, relaciones, colaboración, IA, importación/exportación, validación, generación y cuenta. Incluye búsqueda de dudas, instrucciones con los nombres de los controles reales, ejercicios sugeridos y progreso de lectura guardado en este navegador. En el editor abre el tema de edición, importación o generación según el panel activo. Consultar la ayuda no modifica el diagrama ni envía solicitudes a la IA.

### Aprender a usar la IA

En una pizarra, abre **Asistente → Aprender a usar la IA**. La guía interactiva explica Consultar e Instruir, cómo escribir o dictar una solicitud y cómo revisar una propuesta antes de aplicarla. Incluye ejemplos adaptados al diagrama que se cargan como borradores, una práctica sin cambios reales y ayuda para errores frecuentes. No envía solicitudes de IA durante la práctica; recuerda en este navegador cuando completas la guía y permite repasarla. Está disponible en la plataforma web.

```bash
# 1. Requisitos: Node 22.15, Docker con Compose v2+
node --version        # v22.15.0
docker compose version

# 2. Dependencias exactas del lockfile
npm ci

# 3. Configuración local (el .env real nunca se versiona)
cp infra/.env.example infra/.env
#    editar POSTGRES_PASSWORD y JWT_SECRET antes de seguir

# 4. Todo el entorno
npm run up
npm run ps

# 5. Verificar
curl http://localhost:3001/health     # proceso HTTP
curl http://localhost:3002/health     # proceso WebSocket
open http://localhost:8080            # interfaz
```

Desarrollo sin contenedores para las tres aplicaciones:

```bash
npm run dev:api      # http://localhost:3001
npm run dev:collab   # http://localhost:3002
npm run dev:web      # http://localhost:5173  (proxy a las dos anteriores)
```

## Cuenta de demostración

```bash
npm run up
npm run seed
```

Crea dos cuentas y un proyecto con dos pizarras, para probar la colaboración sin
registrarse a mano. Es idempotente.

| | |
|---|---|
| Propietaria | `ana@demo.local` · `demo-plataforma-uml` |
| Editor | `beto@demo.local` · `demo-plataforma-uml` |

Ábrelas en dos navegadores distintos —o uno normal y otro de incógnito— para ver
la sesión colaborativa en vivo. La sección 16.3 pide tener esto listo el día 22.

## Verificación

```bash
npm run check          # formato + lint + tipos + pruebas rápidas
npm test               # solo las rápidas: sin Docker, sin base de datos
npm run test:api       # integración de la API contra un PostgreSQL efímero
npm run test:generated # T01: genera, compila con Maven, arranca y ejerce el CRUD
npm run test:bank      # lo mismo sobre los ocho modelos generables del banco
npm run test:e2e       # dos navegadores contra el entorno levantado
npm run test:offline   # producción + pruebas offline con Hocuspocus, sin Docker
```

Las pruebas de dos navegadores esperan el adaptador `mock` en los tres puertos de
IA (`AI_LLM_PROVIDER`, `AI_VISION_PROVIDER` y `AI_SPEECH_PROVIDER`), como en CI.
Con un proveedor real gastan tokens y las pruebas del asistente fallan por
latencia: un proveedor tarda más que los quince segundos que espera la prueba.

También esperan `MAIL_PROVIDER=log`, como en CI: cada actor registra una cuenta
nueva y lee el enlace de activación del registro de la API. Con `brevo` el
correo se envía de verdad —y a direcciones `@example.com` el proveedor lo
rechaza—, así que la prueba nunca encuentra el enlace y **todas** las que
registran una cuenta fallan al primer paso. Si el `infra/.env` de la máquina
tiene proveedores reales, se recrea la API con los valores de prueba sin tocar
el archivo (las variables del intérprete ganan a las del `.env`):

```bash
AI_LLM_PROVIDER=mock AI_VISION_PROVIDER=mock AI_SPEECH_PROVIDER=mock \
MAIL_PROVIDER=log BREVO_API_KEY= \
docker compose -f infra/compose.yml --env-file infra/.env up -d --no-build --force-recreate api
```

Al terminar, el mismo comando sin variables delante restaura los proveedores
reales.

Las pruebas de dos navegadores incluyen el paso de la defensa que va del diagrama
al archivo: dibujar una clase, generar y **comprobar que el ZIP descargado
contiene esa clase**. No basta con que baje un archivo — uno vacío también
bajaría.

Diagnóstico del banco:

```bash
npm run bank:report    # qué encuentra el validador en cada modelo
npm run fixtures:emit  # regenerar fixtures/uml/*.json desde las definiciones
```

`npm run check` es el bucle rápido y corre en segundos porque nada de lo que
cubre necesita Docker (RNF-15). Las demás levantan contenedores o compilan
proyectos Java, y por eso van aparte.

| Suite | Necesita | Cuándo la ejecuta CI |
|---|---|---|
| `check` | nada | cada cambio |
| `test:api` | Docker | cada cambio |
| `test:generated` | Docker, Java 21, Maven | cada cambio |
| `test:e2e` | Docker + `npm run up` + `npm run e2e:install` | cada cambio |
| `test:bank` | Docker, Java 21, Maven | **solo la rama principal** |

El banco completo compila y arranca ocho backends: son minutos que no tiene
sentido pagar en cada propuesta de cambio. RNF-13 lo dice así — cada cambio
ejecuta al menos T01, la rama principal ejecuta el banco completo.

## Control individual de servicios

```bash
docker compose -f infra/compose.yml --env-file infra/.env <comando>
```

| Objetivo | Comando |
|---|---|
| Todo el entorno de desarrollo | `up -d` |
| Añadir el origen único de demostración | `--profile demo up -d` |
| Añadir la inspección de la base | `--profile tools up -d` |
| Apagar un solo servicio | `stop collab` |
| Reiniciar uno solo | `restart api` |
| Reconstruir uno solo | `up -d --build api` |
| Ver estado y salud | `ps` |
| Seguir los registros de uno | `logs -f collab` |
| Apagar conservando los datos | `down` |
| Apagar y **borrar** los datos | `down -v` |

---

## Estructura

```
frontend/           Aplicación web React
backend/api/        Proceso HTTP: sesión, proyectos, pizarras, IA, imagen, XMI, generación
backend/collab/     Proceso WebSocket: salas, presencia, persistencia, autorización
backend/prisma/     Esquema de la base de datos de la plataforma
shared/             Código compartido navegador ↔ servidor
templates/          Plantillas de emisión del backend Spring Boot
fixtures/           Banco de modelos T01–T08 y XMI real
infra/              Composición de contenedores, Dockerfiles, proxy
docs/               Requisitos, arquitectura y ADR
```

`shared/` no es opcional: es la consecuencia directa de RA-05. El aplicador de
comandos y el validador tienen que ejecutarse en el navegador (para que la
edición sea instantánea) y en el servidor (para que el asistente, la importación
por imagen y XMI apliquen los mismos comandos con las mismas reglas). **Una sola
implementación, dos lugares de ejecución.**

| Paquete compartido | Responsabilidad | Fase |
|---|---|---|
| `@uml/contracts` | Esquemas: modelo canónico, comandos, lotes, API | ✅ 1 |
| `@uml/domain-core` | Normalización, aplicador de comandos, validador | ✅ 1 |
| `@uml/fixtures` | Banco de regresión T01–T08 | ✅ 1 |
| `@uml/generation-ir` | Representación intermedia (RA-13) | ✅ 2 |
| `@uml/generator-backend` | Emisión del proyecto Spring Boot | ✅ 2 |
| `@uml/yjs-adapter` | Puerto del documento colaborativo | ✅ 4 |
| `@uml/ai` | Puertos de IA y adaptadores intercambiables | ✅ 7 |
| `@uml/xmi` | Parser y serializador XMI | ✅ 8 |

---

## Plan por fases

Cada fase es un incremento **ejecutable y verificable**, no un entregable de
documentación. El orden respeta la sección 16.1 del plan maestro: los riesgos que
no dependen del esfuerzo del equipo se atacan primero, por eso los dos spikes que
validan la arquitectura son las fases 2 y 4.

| Fase | Contenido | Cómo se prueba | Estado |
|---|---|---|---|
| **0** | Cimientos: monorepo, TS estricto, lint, pruebas, Compose con perfiles, CI, ADR-016 | `npm run check` verde · `docker compose up -d` deja los cuatro servicios sanos | ✅ **Completa** |
| **1** | `contracts` + `domain-core`: normalización RTM-02/03, aplicador, validador, banco T01–T08 | Vitest sin navegador, sin BD, sin red (RNF-15). Lote inválido → no aplica nada (RA-03) | ✅ **Completa** |
| **2** | **Spike de generación**: IR → plantillas Spring → ZIP de T01 | DoD 15.1 sobre T01: compila, arranca, CRUD, `409` al borrar padre con hijos | ✅ **Completa** |
| **3** | Migraciones, auth, proyectos, membresías, invitaciones, pizarras | RF-A01–A07 y RF-001–005 por HTTP | ✅ **Completa** |
| **4** | **Spike de colaboración**: Yjs + Hocuspocus, autorización en la conexión, persistencia binaria | CA-A08.1, CA-A08.2, CA-004.1, convergencia | ✅ **Completa** |
| **5** | Editor React Flow sobre el documento, validación en pantalla, presencia | Las cinco pruebas de la sección 15.4 con dos navegadores | ✅ **Completa** |
| **6** | Banco T01–T08 + OpenAPI, Postman y Compose en el ZIP | Ocho modelos generables compilados y ejecutados, con T07R y T08 | ✅ **Verificada el 05/09/2026** |
| **7** | Capa de IA: puertos, adaptador simulado, asistente por texto y voz | CA-032.1 y CA-032.2 con el adaptador `mock` en CI | ✅ **Completa** |
| **8** | Importación por imagen con vista previa + XMI 2.5.1 y perfil EA 2.1 en ambos sentidos | CA-042.1 · Importación real de nueve modelos en EA | ✅ **Implementada; reexportación externa pendiente de aceptación** |
| **10** | Integración: generar y descargar desde el editor, auditoría persistida | Guion 16.2 de punta a punta · el ZIP descargado contiene lo dibujado | ⚠️ **Integrada; falta el ensayo cronometrado** |

La fase 10 cerró las dos brechas P0 que arrastraba la fase 6: generar desde la
pizarra congelando el snapshot (RA-08) y descargar el ZIP, y persistir los lotes
en `audit_operations` (RF-A09/CA-023.1). Lo que queda abierto está en
[`docs/pendientes.md`](docs/pendientes.md), con qué falta, por qué importa y cómo
se comprueba que ya está.

### Pendientes

Todo lo que queda —incluidos los dos riesgos externos de abajo— vive en
[`docs/pendientes.md`](docs/pendientes.md). Cómo ponerla en marcha en local, en
la red del aula o en internet, y dónde van las claves de las IA:
[`docs/despliegue.md`](docs/despliegue.md). El contraste función por función
contra el manual de otro proyecto de la materia:
[`docs/comparacion-manual.md`](docs/comparacion-manual.md), y lo que de ahí sale
y merece construirse, con coste y forma de comprobarlo:
[`docs/actualizacion.md`](docs/actualizacion.md).

### Frentes que no esperan a su fase

Dos cosas de la sección 16 no son código y hay que empezarlas ya, porque el
riesgo es externo y no depende del esfuerzo del equipo:

- **Enterprise Architect 15**: nueve modelos aprobaron la importación real con
  tipos, identidad, geometría, cardinalidades y marcas. Falta la reexportación
  externa completa: el exportador automatizado de EA quedó sin responder.
  Evidencia en la [revisión de colaboración y XMI](docs/colaboracion-xmi-2026-09-10.md).
- **Voz y cámara en el navegador real**: comprobar permisos, captura y dictado
  con los dispositivos de la demostración. Las pruebas automáticas no acreditan
  la calidad del micrófono ni del reconocimiento de una fotografía real. El
  módulo móvil retirado ya no forma parte de esta validación.

---

## Decisiones registradas

Ver [`docs/adr/`](docs/adr/README.md). Las decisiones aceptadas hasta hoy:

- [ADR-001](docs/adr/ADR-001-monolito-modular-dos-procesos.md) — Monolito modular con dos procesos
- [ADR-002](docs/adr/ADR-002-crdt-para-colaboracion.md) — CRDT para la colaboración en tiempo real
- [ADR-003](docs/adr/ADR-003-modelo-canonico-comandos-lotes.md) — Modelo canónico único con comandos y lotes atómicos
- [ADR-004](docs/adr/ADR-004-varias-pizarras-generacion-seleccionada.md) — Varias pizarras y generación sobre una seleccionada
- [ADR-005](docs/adr/ADR-005-entidad-intermedia-muchos-a-muchos.md) — Entidad intermedia explícita para muchos a muchos
- [ADR-006](docs/adr/ADR-006-sin-event-sourcing-ni-cqrs.md) — Sin event sourcing ni CQRS completo
- [ADR-007](docs/adr/ADR-007-generacion-por-ir-y-plantillas.md) — Generación por representación intermedia y plantillas
- [ADR-008](docs/adr/ADR-008-dto-planos-relaciones-unidireccionales.md) — DTO planos y relaciones unidireccionales
- [ADR-009](docs/adr/ADR-009-runtime-compartido.md) — Runtime compartido entre navegador y servidor
- [ADR-010](docs/adr/ADR-010-docker-compose-iac-diferida.md) — Docker Compose, IaC diferida
- [ADR-011](docs/adr/ADR-011-generacion-limitada-capa-datos.md) — Generación móvil limitada a la capa de datos
- [ADR-014](docs/adr/ADR-014-autenticacion-propia-minima.md) — Autenticación propia mínima con roles por proyecto
- [ADR-015](docs/adr/ADR-015-proveedores-ia-tras-puertos.md) — Proveedores de IA detrás de puertos
- [ADR-016](docs/adr/ADR-016-matriz-de-versiones.md) — Matriz de versiones congelada, verificada el 29/08/2026

## Criterio de congelamiento

No se agregan requisitos P0 ni P1 salvo que una prueba, un spike o una
aclaración explícita del docente demuestre que falta algo necesario. Toda idea
nueva se registra en P2.
````

