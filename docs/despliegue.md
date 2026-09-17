# Despliegue y configuración

Dónde va cada cosa para que la plataforma funcione **en local**, **en la red del
aula** y **en internet**. Empieza por el caso que necesites; están en orden de
menos a más trabajo.

---

## 1 · Las claves de las IA

**Van en `infra/.env`, y en ningún otro sitio.** Ese archivo está ignorado por
git a propósito (RNF-08): nunca llega al repositorio ni al navegador. El
navegador no ve ninguna clave — llama a nuestro proceso HTTP, y ese proceso llama
al proveedor.

```bash
cp infra/.env.example infra/.env
```

La plantilla lleva cada variable comentada. Lo que sigue es el mapa.

### 1.1 Una clave por proveedor, no una por puerto

```bash
ANTHROPIC_API_KEY=
GEMINI_API_KEY=
OPENROUTER_API_KEY=
GROQ_API_KEY=
CLOUDFLARE_ACCOUNT_ID=
CLOUDFLARE_API_TOKEN=
```

Una clave pertenece a la cuenta del proveedor. Que el texto y la imagen usen la
misma es consecuencia, no configuración — antes había `AI_LLM_API_KEY` y
`AI_VISION_API_KEY`, y usar Gemini para las dos cosas obligaba a escribir la
misma cadena dos veces, con una regla escondida de «si falta una, usa la otra»
que no se podía adivinar leyendo el archivo.

Cloudflare necesita **dos** valores: el identificador de cuenta va en la ruta y
el testigo en la cabecera. Con uno solo el síntoma sería un 404 del proveedor.

### 1.2 Qué proveedor atiende cada puerto, y a dónde se cae

Cada puerto tiene **un principal, un primer respaldo y hasta seis respaldos
más**, en orden. Se prueban uno tras otro y la cadena se detiene en el primero
que responde bien. La lista completa de proveedores, los modelos probados con
claves reales y los límites de cada plan gratuito están en
[proveedores-ia.md](proveedores-ia.md); aquí va solo el mapa.

```text
                         Pasarela de IA
                               │
             ┌─────────────────┼─────────────────┐
             ▼                 ▼                 ▼
          LlmPort          VisionPort        SpeechPort
             │                 │                 │
             ▼                 ▼                 ▼
           groq             gemini             groq
             │                 │                 │
         no responde       no responde       no responde
             │                 │                 │
             ▼                 ▼                 ▼
       gemini-lite         mistral         cloudflare
             │                 │                 │
             ▼                 ▼                 ▼
      AI_LLM_FALLBACKS  AI_VISION_FALLBACKS  AI_SPEECH_FALLBACKS
```

```bash
# Texto: interpreta instrucciones y responde consultas (RF-030 a RF-037)
AI_LLM_PROVIDER=groq
AI_LLM_MODEL=openai/gpt-oss-120b
AI_LLM_FALLBACK_PROVIDER=gemini
AI_LLM_FALLBACK_MODEL=gemini-3.5-flash-lite
AI_LLM_FALLBACKS=[{"provider":"openrouter","model":"openrouter/free","enabled":true}, …]

# Imagen: lee una foto de un diagrama (RF-040 a RF-043)
AI_VISION_PROVIDER=gemini
AI_VISION_MODEL=gemini-3.5-flash
AI_VISION_FALLBACK_PROVIDER=mistral
AI_VISION_FALLBACK_MODEL=ministral-14b-latest
AI_VISION_FALLBACKS=[{"provider":"cloudflare","model":"@cf/meta/llama-4-scout-17b-16e-instruct","enabled":true}, …]

# Voz: respaldo del reconocimiento del navegador
AI_SPEECH_PROVIDER=groq
AI_SPEECH_MODEL=whisper-large-v3-turbo
AI_SPEECH_FALLBACK_PROVIDER=cloudflare
```

**El respaldo es por puerto.** Uno global no puede existir: el que transcribe
audio no es el mismo que interpreta una frase. Y un respaldo idéntico al
primario —mismo proveedor y mismo modelo— no es un respaldo, así que el proceso
lo **rechaza** en lugar de aceptarlo y dejar creer que hay red de seguridad. El
mismo proveedor con otro modelo sí vale: `gemini-3.8-flash` puede respaldar a
`gemini-3.5-flash-lite`.

| Puerto | Proveedores que lo atienden |
|---|---|
| Texto (`AI_LLM_*`) | `mock`, `anthropic`, `gemini`, `openrouter`, `groq`, `cloudflare`, `mistral`, `zai`, `nvidia`, `cohere`, `moonshot`, `sambanova` |
| Imagen (`AI_VISION_*`) | los mismos que texto |
| Voz (`AI_SPEECH_*`) | `mock`, `groq`, `cloudflare`, `mistral` |

Una combinación imposible —`AI_SPEECH_PROVIDER=gemini`— **no arranca**.
Aceptarla y caer al simulado en silencio haría creer que se probó un proveedor
que nunca fue llamado.

Todos los proveedores compatibles con OpenAI (`openrouter`, `groq`,
`cloudflare`, `mistral`, `zai`, `nvidia`, `cohere`, `moonshot`,
`sambanova`) **exigen modelo** en texto e imagen: cada uno sirve muchos y
ninguno es el evidente. En voz los adaptadores ya saben a qué Whisper o
Voxtral llamar.

### 1.3 Qué se comprueba al arrancar

El proceso falla al construirse, no en la primera llamada. Enterarse de que
falta una clave con la foto ya cargada es lo peor que puede pasar el día de la
defensa. Se comprueba que el proveedor atiende ese puerto, que su credencial
está, que el respaldo no es el primario, que los compatibles tienen modelo y
que no hay más de siete entradas por puerto (contando las desactivadas).

Al arrancar, el registro dice la cadena activa —`texto: groq/openai/gpt-oss-120b
→ gemini/gemini-3.5-flash-lite → … | imagen: … | voz: …`— sin ninguna clave. Es lo
que evita la conversación de «¿pero esto está usando el simulado?» en mitad de
una demostración.

### 1.4 Tiempos y reintentos

```bash
AI_TIMEOUT_MS=15000              # por intento, no por la serie
AI_VISION_TIMEOUT_MS=            # vacío = máximo(3 × el anterior, 120000)
AI_CHAIN_TIMEOUT_MS=120000       # plazo total del puerto de texto, toda la cadena
AI_VISION_CHAIN_TIMEOUT_MS=300000
AI_SPEECH_CHAIN_TIMEOUT_MS=120000
AI_MAX_RETRIES=0                 # reintentos dentro del mismo proveedor ante red/5xx
AI_QUOTA_COOLDOWN_MS=60000       # cuánto se recuerda un 402/429 antes de reintentar ese proveedor
AI_LOG_USAGE=true                # proveedor, modelo, tokens y latencia; nunca la clave
```

El plazo por intento es corto a propósito: lo que salva una llamada durante la
defensa es cambiar de proveedor pronto, no esperar más al que no contesta. Con
Groq de primario una instrucción responde en uno o dos segundos; el límite
existe para los respaldos lentos. El **peor caso** lo acota el plazo total de
la cadena, no la suma de intentos: 120 segundos para texto y voz, 300 para
imagen. Nginx espera 330; si se sube alguno por encima, hay que subir también
el proxy.

La visión tiene su propio límite por intento porque leer un pizarrón cuesta
más que interpretar una frase: medido, entre 9 y 40 segundos según el
proveedor. Sin él, bajar `AI_TIMEOUT_MS` para que el asistente reaccione
rápido rompía la importación por foto.

**Una clave inválida no cae al respaldo.** Es configuración, se arregla en un
minuto, y disimularla cambiando de proveedor significa no enterarse nunca. Solo
se cae al respaldo cuando el primario *no respondió* o dijo que no tiene cuota
([ADR-015](adr/ADR-015-proveedores-ia-tras-puertos.md)).

### 1.5 Después de cambiar el archivo

```bash
npm run up
# o, si ya estaba levantado, para que el proceso lea las variables nuevas:
docker compose -f infra/compose.yml --env-file infra/.env up -d --force-recreate api
```

### 1.6 `mock` no es un hueco por rellenar

Es el adaptador simulado: determinista, sin red y sin coste. Es con el que corre
la integración continua, y con el que la plataforma arranca sin que nadie tenga
una clave. Si el día del examen no hay internet, dejarlo en `mock` deja el
asistente respondiendo — con menos capacidad, pero respondiendo.

### 1.7 La voz, en tres sitios distintos

- **En el navegador**, con la API del sistema: es el camino normal, no sube
  audio, no cuesta nada y responde al instante. No lleva clave.
- **En el servidor**, con `AI_SPEECH_PROVIDER`: es el respaldo para cuando el
  navegador no lo trae —Firefox— o reconoce mal. Antes solo aceptaba `mock`, es
  decir, en esos navegadores el dictado sencillamente no estaba.
- **En el teléfono**, con el motor del dispositivo: es local y funciona en modo
  avión (fase 9). No pasa por este puerto ni por esta configuración.

Añadir un proveedor sigue siendo escribir un adaptador contra el mismo puerto y
añadirlo al registro, sin tocar nada más
([ADR-015](adr/ADR-015-proveedores-ia-tras-puertos.md),
[ADR-019](adr/ADR-019-pasarela-ia-credenciales-y-respaldo.md)).

---

## 2 · Local, una sola máquina

Es lo que ya funciona:

```bash
cp infra/.env.example infra/.env     # y cambiar POSTGRES_PASSWORD y JWT_SECRET
npm ci
npm run up
npm run seed                          # crea ana@demo.local y beto@demo.local
```

`http://localhost:8080`. Contraseña de las dos cuentas:
`demo-plataforma-uml`.

**Lo que hay que cambiar sí o sí** en `infra/.env`: `POSTGRES_PASSWORD` y
`JWT_SECRET`. El segundo se genera con:

```bash
node -e "console.log(require('crypto').randomBytes(48).toString('base64url'))"
```

### Repartir los puertos antes de la demostración

Tres cosas quieren el 8080 y el guion las levanta a la vez:

| Quién | Puerto | Dónde se cambia |
|---|---|---|
| Proxy de la plataforma | 8080 | `WEB_PORT` en `infra/.env` |
| Backend generado | 8080 | variable `PORT` al ejecutarlo |
| Aplicación móvil que se construya sobre el backend | 8080 | Su propia configuración |

Lo más simple: dejar la plataforma en 8080 y arrancar el proyecto generado con
`PORT=8081`, apuntando el móvil a ese.

---

## 3 · La red del aula, varias máquinas

Es el caso de la defensa: dos computadoras y un teléfono contra el mismo
servidor. Solo cambian dos cosas.

**1. Averiguar la IP de la máquina que hace de servidor:**

```bash
ipconfig            # Windows: la IPv4 del adaptador conectado
```

**2. Ponerla en `infra/.env`:**

```bash
WEB_ORIGIN=http://192.168.1.10:8080
```

Y levantar de nuevo. Las otras máquinas abren `http://192.168.1.10:8080`; el
teléfono se conecta con
apuntando la aplicación que se construya a `http://192.168.1.10:8081`.

**No hace falta internet.** Solo el asistente de IA y la lectura de la foto
salen a la red (§16.4 del plan). Todo lo demás —sesión, editor, colaboración,
generación, compilación del proyecto generado, base de datos, y la app móvil
entera— funciona en la red local.

**Cortafuegos de Windows:** la primera vez pedirá permiso para que Docker acepte
conexiones entrantes. Si las otras máquinas no llegan, es lo primero que hay que
mirar.

---

## 4 · En internet: una máquina virtual en cualquier nube

El instructivo completo y probado está en
[`infra/DEPLOYMENT.md`](../infra/DEPLOYMENT.md). Aquí va el resumen de qué
cambia respecto al aula y por qué.

### 4.1 Qué se necesita

- Una VM Linux (Ubuntu 24.04) con Docker. Sirve AWS EC2, Azure, Google Cloud o
  cualquier VPS; la guía tiene una tabla con los puertos, la IP fija y las copias
  de cada proveedor. Orientativo: 2 vCPU, 4 GiB de RAM, 30 GiB de disco.
- Un dominio apuntando a la IP pública. Caddy pide y renueva el certificado
  solo; sin dominio no hay HTTPS, y sin HTTPS la colaboración no conecta (el
  navegador exige `wss://` y no lo explica).
- Un remitente verificado en Brevo para la recuperación de contraseñas.
- Un bucket S3 compatible para las copias, o `BACKUP_S3_URI=local-only` para
  empezar sin él.

### 4.2 Qué cambia respecto a la configuración local

| Variable | Local | En internet | Por qué |
|---|---|---|---|
| `COOKIE_SECURE` | `false` | `true` | La cookie de refresco solo debe viajar por HTTPS. |
| `WEB_ORIGIN` | `http://localhost:8080` | `https://tu-dominio` | Autoriza el origen cruzado; si no coincide, el navegador bloquea todo. |
| `NODE_ENV` | `development` | `production` | Activa los límites de peticiones y las comprobaciones de arranque. |
| `JWT_SECRET`, `POSTGRES_PASSWORD` | unos locales | **otros distintos** | Un secreto que estuvo en una máquina de desarrollo ya no es secreto. |

Todo eso lo fija [`infra/compose.production.yml`](../infra/compose.production.yml)
y lo exige la API al arrancar: con `NODE_ENV=production` rechaza `COOKIE_SECURE=false`,
un origen sin HTTPS, un JWT corto o un correo sin configurar. Los secretos viven
en `/etc/uml/production.env` con permisos 600, fuera del repositorio. Solo se
publican los puertos 80 y 443; base de datos, API y colaboración quedan dentro de
la red de Docker.

### 4.3 Qué ya está resuelto

- **Copias.** Un contenedor hace `pg_dump` cada 24 horas, lo verifica, lo sube al
  bucket y solo entonces marca éxito. `restore-check` restaura la última copia en
  un PostgreSQL temporal para probar que sirve.
- **Límite de peticiones.** Global por IP, más estricto en login/registro/
  recuperación, y una cuota por usuario para IA, importación y generación.
- **Versiones y vuelta atrás.** `production.sh deploy` etiqueta las imágenes con
  el commit, hace copia antes de migrar y guarda la versión buena; `rollback`
  vuelve a la anterior si las migraciones no cambiaron.
- **Supervisión.** Un temporizador de systemd comprueba cada cinco minutos HTTPS,
  base, colaboración, antigüedad de la copia y disco, y puede avisar a un webhook.
- **Prueba reproducible.** `npm run test:production` levanta la configuración de
  producción en contenedores temporales y verifica HTTPS, WSS, cookies seguras,
  límites y restauración. La ejecuta CI y funciona también desde Windows.

### 4.4 Descargas y espacio en el servidor

El servidor **no guarda ningún ZIP ni APK**. Generar congela una copia del
diagrama en PostgreSQL (unos KB) y al pulsar **Descargar backend** o **Descargar
Android + backend** se vuelve a emitir desde esa copia, comprobando que los bytes
coinciden con los registrados. El historial de la pestaña Generar tiene un botón
de descarga por cada generación anterior y un botón **Eliminar** para retirarla
junto con su copia congelada.

El APK lo compila quien descarga, en su PC, con `.\apk.bat build`; la VM no
necesita Flutter, Android SDK ni Java. Lo que sí ocupa espacio en la VM son las
imágenes Docker de cada versión desplegada, la base y las copias locales:
`production.sh disk` lo muestra y `production.sh prune` borra las imágenes que ya
no sirven para rollback.

### 4.5 Pendiente

- **RNF-14, el registro estructurado, está incompleto**: ver
  [`pendientes.md`](pendientes.md) §2.1.
- Los contadores de peticiones viven en memoria: valen para una sola instancia
  de la API, que es lo que despliega esta configuración.

---

## 5 · Escritorio

Fuera de alcance por ahora. Cuando toque, la vía corta es empaquetar la interfaz
web existente; la decisión que habrá que tomar es si el escritorio lleva su
propio servidor dentro o sigue hablando con uno remoto, y eso cambia bastante más
que el empaquetado.
