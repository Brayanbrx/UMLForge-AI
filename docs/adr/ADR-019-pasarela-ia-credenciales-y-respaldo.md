# ADR-019 · Pasarela de IA: credenciales por proveedor y respaldo por puerto

**Estado:** aceptada
**Fecha:** 30 de agosto de 2026
**Amplía:** [ADR-015](ADR-015-proveedores-ia-tras-puertos.md)

## Contexto

ADR-015 dejó la capa de IA detrás de tres puertos y prometió que **añadir un
proveedor es escribir un adaptador y añadirlo al registro**. Con un solo
proveedor real —Claude— esa promesa no estaba puesta a prueba.

Al configurar la cadena de referencia —Gemini para texto e imagen, Groq para
voz, con respaldo en OpenRouter y Cloudflare— salieron tres cosas que la forma
anterior no soportaba:

1. **Las claves eran del puerto.** `AI_LLM_API_KEY` y `AI_VISION_API_KEY`. Usar
   el mismo proveedor para las dos cosas obligaba a escribir la misma cadena dos
   veces, y había una regla escondida —«si falta la de visión, usa la de
   texto»— que no se podía adivinar leyendo el `.env`.
2. **El respaldo era global.** Un solo `AI_FALLBACK_PROVIDER` para los tres
   puertos, aplicado en realidad solo al de texto. El proveedor que transcribe
   audio no es el mismo que interpreta una frase: obligarlos a compartir
   respaldo significa que uno de los dos no tiene.
3. **`SpeechPort` no tenía adaptador de proveedor.** El esquema solo aceptaba
   `mock`, con un comentario honesto explicando por qué. La consecuencia real
   era que en un navegador sin `SpeechRecognition` —Firefox— el dictado
   sencillamente no estaba.

## Decisión

### Las credenciales son del proveedor

`ANTHROPIC_API_KEY`, `GEMINI_API_KEY`, `OPENROUTER_API_KEY`, `GROQ_API_KEY`,
`CLOUDFLARE_ACCOUNT_ID` + `CLOUDFLARE_API_TOKEN`.

Una clave pertenece a la cuenta del proveedor. Que dos puertos la usen es
consecuencia, no configuración. La regla de «si falta una, usa la otra»
desaparece porque ya no hay dos.

### El respaldo es por puerto

Cada puerto declara su primario y su respaldo, con su modelo:
`AI_LLM_FALLBACK_PROVIDER`, `AI_VISION_FALLBACK_PROVIDER`,
`AI_SPEECH_FALLBACK_PROVIDER`.

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

**Un respaldo idéntico al primario se rechaza al arrancar.** Si el primario no
responde, ese tampoco. Se rechaza en lugar de ignorarlo porque el síntoma de
ignorarlo es creer que hay red de seguridad y no tenerla. Se acepta el mismo
proveedor con otro modelo, que sí es una degradación real.

Por la misma razón, `AI_LLM_FALLBACK_MODEL` de OpenRouter **no tiene valor por
defecto**: elegir el modelo del respaldo es elegir a qué fabricante se salta, y
esa decisión no puede tomarla una constante escondida en el código. Un respaldo
que pasa por la misma infraestructura que el primario no es un respaldo.

### No todo proveedor sirve para todo puerto

| Puerto | Proveedores |
|---|---|
| Texto | `mock`, `anthropic`, `gemini`, `openrouter` |
| Imagen | `mock`, `anthropic`, `gemini`, `openrouter` |
| Voz | `mock`, `groq`, `cloudflare` |

Groq está aquí por Whisper y no atiende texto; Claude y Gemini no transcriben.
La combinación imposible **no arranca**, con el mismo argumento que ADR-015 usó
para no aceptar `AI_SPEECH_PROVIDER=anthropic`: aceptarla y caer al simulado en
silencio haría creer que se probó un proveedor que nunca fue llamado.

### Todo se comprueba al construir, no en la primera llamada

Que el proveedor atiende el puerto, que su credencial está, que el respaldo no
es el primario, que OpenRouter tiene modelo. Enterarse de que falta una clave
con la fotografía del pizarrón ya cargada es lo peor que puede pasar el día de
la defensa.

Y al arrancar se registra la cadena activa, sin claves. Evita la conversación de
«¿pero esto está usando el simulado?» en mitad de una demostración.

### Una variable vacía es una variable sin poner

Docker Compose entrega `AI_LLM_FALLBACK_PROVIDER=""` cuando la plantilla la
reenvía y el `.env` no la define, y un `.env` real tiene media docena de líneas
`VARIABLE=` esperando a que alguien las rellene. Sin esta regla, la cadena vacía
no es ninguno de los proveedores válidos y el proceso no arranca — por una
variable que nadie llegó a configurar.

## Lo que se movió de sitio

- **Las instrucciones del sistema** vivían dentro del adaptador de Claude. Con
  un proveedor daba igual; con cuatro, no: copiadas en cada adaptador divergen
  en la primera corrección que alguien haga solo en uno, y el síntoma es que el
  asistente se porta distinto según el proveedor configurado ese día. Están en
  `shared/ai/src/prompt.ts`.
- **El tiempo límite, los reintentos y la clasificación de errores** están en
  `shared/ai/src/http.ts`. La clasificación es la parte que importa, porque
  decide si se cae al respaldo, y si vive en cada adaptador el cuarto proveedor
  la implementa distinto.
- **El registro de uso y la cadena de respaldo** siguen en el registro, ahora
  para los tres puertos y no solo para el de texto.

## Lo que no cambia

- **La regla de cuándo se cae al respaldo.** Solo ante *no respondió*. Una clave
  inválida es configuración: se arregla en un minuto, y disimularla cambiando de
  proveedor significa no enterarse nunca (ADR-015).
- **`mock` sigue siendo el valor por defecto** y el que usa la integración
  continua. Ninguna prueba de este repositorio llama a un proveedor de pago.
- **Las claves solo en el servidor.** El navegador y la aplicación móvil hablan
  con nuestra API; la API habla con el proveedor.

## Consecuencias

- Un `.env` anterior con `AI_LLM_API_KEY` deja de ser leído. Como el valor por
  defecto de los tres puertos es `mock`, la plataforma arranca igual; lo que hay
  que hacer es mover la clave a la variable de su proveedor. Está dicho en
  [`despliegue.md`](../despliegue.md) §1.1.
- La voz tiene por primera vez adaptadores reales, así que el dictado funciona
  también donde el navegador no lo trae. Sigue sin ser el camino normal.
- El proyecto arrastra un solo SDK, el de Claude. Los otros cuatro adaptadores
  son HTTP contra `fetch`: entre cuarenta y noventa líneas cada uno, sin una
  dependencia más que mantener al día.
- `shared/ai/tests/pasarela.test.ts` comprueba, además del comportamiento, que
  `infra/.env.example` es configuración válida y que la cadena que documenta es
  exactamente la que el código construye. El instructivo y el código no pueden
  divergir sin que una prueba lo diga.
