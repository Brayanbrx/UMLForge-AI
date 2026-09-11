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

```text
                         Pasarela de IA
                               │
             ┌─────────────────┼─────────────────┐
             ▼                 ▼                 ▼
          LlmPort          VisionPort        SpeechPort
             │                 │                 │
             ▼                 ▼                 ▼
           gemini            gemini             groq
             │                 │                 │
         no responde       no responde       no responde
             │                 │                 │
             ▼                 ▼                 ▼
         openrouter        openrouter        cloudflare
```

```bash
# Texto: interpreta instrucciones y responde consultas (RF-030 a RF-037)
AI_LLM_PROVIDER=gemini
AI_LLM_MODEL=gemini-3.6-flash
AI_LLM_FALLBACK_PROVIDER=openrouter
AI_LLM_FALLBACK_MODEL=anthropic/claude-sonnet-4.5

# Imagen: lee una foto de un diagrama (RF-040 a RF-043)
AI_VISION_PROVIDER=gemini
AI_VISION_MODEL=gemini-3.6-flash
AI_VISION_FALLBACK_PROVIDER=openrouter
AI_VISION_FALLBACK_MODEL=anthropic/claude-sonnet-4.5

# Voz: respaldo del reconocimiento del navegador
AI_SPEECH_PROVIDER=groq
AI_SPEECH_MODEL=whisper-large-v3-turbo
AI_SPEECH_FALLBACK_PROVIDER=cloudflare
```

**El respaldo es por puerto, y tiene que ser otro proveedor.** Uno global no
puede existir: el que transcribe audio no es el mismo que interpreta una frase.
Y un respaldo que pasa por la misma infraestructura que el primario no es un
respaldo — si Google está caído, dos rutas hacia Google están caídas. Por eso el
proceso **rechaza** un respaldo idéntico al primario en lugar de aceptarlo y
dejar creer que hay red de seguridad.

| Puerto | Proveedores que lo atienden |
|---|---|
| Texto (`AI_LLM_*`) | `mock`, `anthropic`, `gemini`, `openrouter` |
| Imagen (`AI_VISION_*`) | `mock`, `anthropic`, `gemini`, `openrouter` |
| Voz (`AI_SPEECH_*`) | `mock`, `groq`, `cloudflare` |

Una combinación imposible —`AI_LLM_PROVIDER=groq`— **no arranca**. Aceptarla y
caer al simulado en silencio haría creer que se probó un proveedor que nunca fue
llamado.

`openrouter` exige modelo: enruta a cientos y ninguno es el evidente.

### 1.3 Qué se comprueba al arrancar

El proceso falla al construirse, no en la primera llamada. Enterarse de que
falta una clave con la foto ya cargada es lo peor que puede
pasar el día de la defensa. Se comprueba que el proveedor atiende ese puerto,
que su credencial está, que el respaldo no es el primario y que OpenRouter tiene
modelo.

Al arrancar, el registro dice la cadena activa —`texto: gemini/gemini-3.6-flash
→ openrouter/anthropic/claude-sonnet-4.5 | imagen: … | voz: …`— sin ninguna
clave. Es lo que evita la conversación de «¿pero esto está usando el simulado?»
en mitad de una demostración.

### 1.4 Tiempos y reintentos

```bash
AI_TIMEOUT_MS=15000        # por intento, no por la serie
AI_VISION_TIMEOUT_MS=      # vacío = el triple del anterior
AI_MAX_RETRIES=1           # adicionales al primer intento, solo ante 429 y 5xx
AI_LOG_USAGE=true          # proveedor, modelo, tokens y latencia; nunca la clave
```

Corto a propósito: lo que salva una llamada durante la defensa es cambiar de
proveedor pronto, no esperar más al que no contesta. **Peor caso** =
`AI_TIMEOUT_MS × (AI_MAX_RETRIES + 1) × 2` cuando hay respaldo; con estos
valores, 60 segundos.

La visión tiene su propio límite porque leer un pizarrón cuesta más que
interpretar una frase. Sin él, bajar `AI_TIMEOUT_MS` para que el asistente
reaccione rápido rompía la importación por foto.

**Una clave inválida no cae al respaldo.** Es configuración, se arregla en un
minuto, y disimularla cambiando de proveedor significa no enterarse nunca. Solo
se cae al respaldo cuando el primario *no respondió*
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

## 4 · En internet

Nada de esto está hecho todavía. Es la lista de lo que falta, no un instructivo
probado.

### 4.1 Lo que hay que cambiar en la configuración

| Variable | Local | En internet | Por qué |
|---|---|---|---|
| `COOKIE_SECURE` | `false` | `true` | La cookie de refresco solo debe viajar por HTTPS. Con `false` en producción se puede interceptar. |
| `WEB_ORIGIN` | `http://localhost:8080` | `https://tu-dominio` | Es lo que autoriza el origen cruzado. Si no coincide, el navegador bloquea todas las llamadas. |
| `NODE_ENV` | `development` | `production` | |
| `JWT_SECRET` | uno local | **otro distinto** | Un secreto que estuvo en una máquina de desarrollo ya no es secreto. |
| `POSTGRES_PASSWORD` | una local | otra distinta | Igual. |

### 4.2 HTTPS, y por qué aquí importa más de lo normal

La colaboración va por **WebSocket**. Sobre HTTPS el navegador exige `wss://`, no
`ws://`, y rechaza la mezcla sin dar un error legible: la pizarra simplemente no
conecta. El proxy tiene que terminar TLS y reenviar la conexión con las cabeceras
`Upgrade` y `Connection`, que
[`infra/nginx.conf`](../infra/nginx.conf) ya pone.

La forma más corta de conseguir el certificado es el perfil `demo`, que usa Caddy
([`infra/caddy/Caddyfile`](../infra/caddy/Caddyfile)): con un dominio real
apuntando a la máquina, Caddy pide y renueva el certificado de Let's Encrypt
solo. Habría que cambiar `:80` por el dominio.

### 4.3 Lo que falta de verdad

- **Persistencia y copias de la base.** El volumen de PostgreSQL vive en la
  máquina. En un servidor de verdad hace falta una copia programada; sin ella,
  una máquina perdida son todos los proyectos perdidos.
- **Los secretos no pueden vivir en un archivo `.env` en el servidor.** Para un
  despliegue real: secretos del proveedor de nube, o al menos un archivo con
  permisos restringidos fuera del árbol del repositorio.
- **Límite de peticiones.** No hay ninguno. Registrar cuentas, probar contraseñas
  o pedir generaciones son operaciones sin freno; en una red local no importa, en
  internet sí.
- **Un dominio y un servidor.** Cualquier proveedor con Docker sirve: la
  composición ya levanta los cuatro servicios.
- **Registro y alertas.** Hoy los registros van a la salida del contenedor y
  nadie los recoge. Para saber que algo se cayó hay que mirar a mano.
- **RNF-14, el registro estructurado, está incompleto**: ver
  [`pendientes.md`](pendientes.md) §2.1.

**Ninguno de estos puntos bloquea la defensa**, que es en red local. Están aquí
para que la pregunta «¿y esto se puede subir a internet?» tenga una respuesta
concreta en lugar de un «sí, supongo».

---

## 5 · Escritorio

Fuera de alcance por ahora. Cuando toque, la vía corta es empaquetar la interfaz
web existente; la decisión que habrá que tomar es si el escritorio lleva su
propio servidor dentro o sigue hablando con uno remoto, y eso cambia bastante más
que el empaquetado.
