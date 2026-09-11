# ADR-015 · Proveedores de IA detrás de puertos intercambiables

**Estado:** aceptada
**Fecha:** 29 de agosto de 2026
**Fase:** 7
**Ampliada por:** [ADR-019](ADR-019-pasarela-ia-credenciales-y-respaldo.md), que
cambia la forma de configurarla —credenciales por proveedor y respaldo por
puerto— sin cambiar ninguna de estas decisiones.

## Contexto

El asistente por texto y voz, y más adelante la importación por fotografía,
necesitan un modelo de lenguaje y uno de visión. Podrían llamarse directamente
desde el módulo que los usa.

## Decisión

**RA-14: ningún módulo del dominio conoce un proveedor concreto.** La IA se
consume a través de tres puertos —`LlmPort`, `VisionPort`, `SpeechPort`— y cada
proveedor es un adaptador intercambiable por variable de entorno.

Esto no es purismo arquitectónico: es la diferencia entre cambiar de proveedor
en una tarde y reescribir tres módulos a una semana de la entrega.

Cada puerto se configura por separado. Se puede usar un proveedor para comandos
y otro distinto para imágenes sin tocar código.

## Dos reglas que gobiernan todo lo demás

### El modelo nunca toca el estado

Devuelve una **propuesta**. El sistema la resuelve, la valida y la aplica. En
ningún punto del recorrido el proveedor escribe en la pizarra.

### El modelo nunca resuelve identificadores

Devuelve **nombres**; el resolver los busca contra el modelo real. Un
identificador inventado por el modelo sería imposible de detectar como error
—tiene la forma correcta— y produciría un comando que apunta a nada.

Esta regla es la que hace que el resto funcione. Como el modelo habla de
nombres, el resolver puede comparar por nombre técnico y encontrar «detalle de
venta» cuando la clase se llama «Detalle de Venta» — que es exactamente lo que un
asistente por voz necesita, porque nadie dicta un nombre con sus mayúsculas.

## La desambiguación es estructural, no probabilística

La decisión de preguntar **no** se toma con un umbral de confianza. Los modelos
están mal calibrados y ese umbral produce falsos positivos y negativos sin
patrón. Se toma consultando el estado del modelo:

| Situación | Comportamiento |
|---|---|
| El objetivo resuelve a un único elemento | Ejecutar |
| Objetivo ambiguo | Preguntar cuál, con las opciones reales |
| Faltan operandos | Preguntar el faltante |
| Destructivo de alcance amplio | Confirmar antes de ejecutar |

«Ambiguo» aquí significa algo comprobable: *dos clases del modelo tienen el mismo
nombre técnico*, no *el modelo no parecía muy seguro*.

Lo destructivo se mide contando lo que desaparece. Borrar una clase se lleva sus
atributos y sus relaciones; borrar un atributo se lleva un atributo. Lo primero
puede deshacer media hora de trabajo de otra persona en una pizarra compartida.

## El adaptador simulado no es opcional

Devuelve respuestas fijas y deterministas. Es lo que permite que las pruebas y el
banco de regresión corran en integración continua **sin llamar a un servicio de
pago ni depender de la red**.

Sin él, cada ejecución cuesta dinero y falla cuando el proveedor tiene un mal
día. Es media hora de trabajo y se paga sola la primera semana.

Interpreta la instrucción con patrones, no con un modelo. No pretende ser
inteligente: pretende ser predecible, que es lo que una prueba necesita. **No se
presenta como inteligencia artificial en ningún sitio** — es un doble de prueba,
y el asistente de verdad es el adaptador del proveedor.

Es también el valor por defecto de la configuración, así que la plataforma
arranca y el asistente responde algo útil sin ninguna clave.

## El asistente no aplica nada

La API resuelve la instrucción y devuelve un lote listo. **Lo aplica el
navegador**, por el mismo camino que la interfaz gráfica: `applyBatchToDocument`
sobre el documento colaborativo.

Así hay un solo escritor por documento, y el asistente es literalmente otro
adaptador que produce comandos (RA-01) en lugar de una vía paralela con sus
propias reglas. La consecuencia visible es que el usuario ve la propuesta con su
resumen antes de que nada cambie.

El estado llega en la petición y no se lee del snapshot persistido: el snapshot
lo escribe el proceso de colaboración con retardo, y el asistente tiene que
razonar sobre lo que el usuario está viendo, no sobre lo que había hace dos
segundos.

## El asistente no autogenera

El agente asiste, no construye el diagrama completo desde una descripción. El
docente fue explícito. La instrucción del sistema se lo dice al modelo, y una
instrucción vaga sale como pregunta en lugar de como veinte clases inventadas.

La única excepción es la importación desde fotografía o XMI, que por naturaleza
produce un lote grande y por eso pasa por vista previa y confirmación (fase 8).

## Reglas de la capa

- **Las claves solo en el servidor.** El navegador habla con nuestra API, nunca
  con el proveedor. El adaptador solo se importa desde el proceso HTTP.
- **Salida estructurada** contra el esquema derivado de los contratos, no parseo
  de texto libre. Aun así se vuelve a validar al recibirla: el esquema restringe
  la forma, no que la carga de cada operación sea coherente.
- **Tiempo límite y reintentos** con espera creciente. Un proveedor lento no
  cuelga la interfaz.
- **Cadena de respaldo.** Si el primario no responde, se intenta el secundario.
  Solo ante *no respondió*: un contrato incumplido no mejora reintentando en otro
  sitio — es un fallo nuestro o del prompt, y esconderlo lo haría indetectable.
- **Registro de uso** por proveedor, con latencia y tokens, para diagnosticar y
  para la defensa.

## Voz

El reconocimiento lo hace el **navegador**: no hay que subir audio, no cuesta
nada y responde al instante. `SpeechPort` existe como respaldo para navegadores
que no lo traigan.

Conviene ser honesto sobre esto en la defensa: el reconocimiento del navegador
**sí** necesita internet. La sección 16.4 ya lo cuenta entre las dos
funcionalidades que dependen de red. El que funciona en modo avión es el de la
app móvil, que es local y es otra cosa (fase 9).

## Consecuencias

- Añadir un proveedor es escribir un adaptador y añadirlo al registro. Nada más
  cambia.
- El modelo elegido para el adaptador de Claude es `claude-opus-5`, con
  pensamiento adaptativo y esfuerzo bajo: las instrucciones son cortas y el
  esquema de salida es estrecho.
- CI corre siempre con el adaptador simulado. Que el asistente real funcione se
  comprueba a mano antes de la defensa, no en cada cambio.
