# Documentacion del proyecto

El porque de cada decision. Los ADR numerados justifican el monolito modular, el CRDT para colaboracion, el modelo canonico con comandos por lotes, la IA tras puertos, la ausencia de event sourcing y la generalizacion tabla por clase. El codigo los cita por numero (`RA-04`, `RA-06`, `RA-13`, `RM-02`, `RTM-02`), asi que sin ellos las referencias de los comentarios quedan sueltas.

> Generado el 2026-09-21 00:42 por `contexto/todo.py`.
> 57 archivos, 12,099 lineas, 692.5 KiB de codigo.
> Pruebas: excluidas. Dependencias, compilados y binarios: siempre excluidos.

## Contenido

- [Decisiones de arquitectura](#decisiones-de-arquitectura) --- 21 archivos
- [Arquitectura](#arquitectura) --- 1 archivo
- [Requisitos](#requisitos) --- 1 archivo
- [Plan maestro](#plan-maestro) --- 2 archivos
- [Material de defensa](#material-de-defensa) --- 3 archivos
- [Notas sueltas](#notas-sueltas) --- 29 archivos

---

## Decisiones de arquitectura

ADR-001 a ADR-020, cada uno con contexto, decision y consecuencias.

### Estructura

```text
docs/adr/
|-- ADR-001-monolito-modular-dos-procesos.md
|-- ADR-002-crdt-para-colaboracion.md
|-- ADR-003-modelo-canonico-comandos-lotes.md
|-- ADR-004-varias-pizarras-generacion-seleccionada.md
|-- ADR-005-entidad-intermedia-muchos-a-muchos.md
|-- ADR-006-sin-event-sourcing-ni-cqrs.md
|-- ADR-007-generacion-por-ir-y-plantillas.md
|-- ADR-008-dto-planos-relaciones-unidireccionales.md
|-- ADR-009-runtime-compartido.md
|-- ADR-010-docker-compose-iac-diferida.md
|-- ADR-011-generacion-limitada-capa-datos.md
|-- ADR-012-importacion-como-candidato-editable.md
|-- ADR-013-uuid-para-creacion-sin-conexion.md
|-- ADR-014-autenticacion-propia-minima.md
|-- ADR-015-proveedores-ia-tras-puertos.md
|-- ADR-016-matriz-de-versiones.md
|-- ADR-017-agente-movil-local.md
|-- ADR-018-artefactos-no-se-almacenan.md
|-- ADR-019-pasarela-ia-credenciales-y-respaldo.md
|-- ADR-020-generalizacion-tabla-por-clase.md
`-- README.md
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `docs/adr/ADR-001-monolito-modular-dos-procesos.md` | 63 |
| `docs/adr/ADR-002-crdt-para-colaboracion.md` | 138 |
| `docs/adr/ADR-003-modelo-canonico-comandos-lotes.md` | 111 |
| `docs/adr/ADR-004-varias-pizarras-generacion-seleccionada.md` | 45 |
| `docs/adr/ADR-005-entidad-intermedia-muchos-a-muchos.md` | 55 |
| `docs/adr/ADR-006-sin-event-sourcing-ni-cqrs.md` | 40 |
| `docs/adr/ADR-007-generacion-por-ir-y-plantillas.md` | 99 |
| `docs/adr/ADR-008-dto-planos-relaciones-unidireccionales.md` | 98 |
| `docs/adr/ADR-009-runtime-compartido.md` | 59 |
| `docs/adr/ADR-010-docker-compose-iac-diferida.md` | 56 |
| `docs/adr/ADR-011-generacion-limitada-capa-datos.md` | 137 |
| `docs/adr/ADR-012-importacion-como-candidato-editable.md` | 122 |
| `docs/adr/ADR-013-uuid-para-creacion-sin-conexion.md` | 55 |
| `docs/adr/ADR-014-autenticacion-propia-minima.md` | 112 |
| `docs/adr/ADR-015-proveedores-ia-tras-puertos.md` | 143 |
| `docs/adr/ADR-016-matriz-de-versiones.md` | 151 |
| `docs/adr/ADR-017-agente-movil-local.md` | 92 |
| `docs/adr/ADR-018-artefactos-no-se-almacenan.md` | 104 |
| `docs/adr/ADR-019-pasarela-ia-credenciales-y-respaldo.md` | 143 |
| `docs/adr/ADR-020-generalizacion-tabla-por-clase.md` | 101 |
| `docs/adr/README.md` | 31 |

---

### `docs/adr/ADR-001-monolito-modular-dos-procesos.md`

```markdown
# ADR-001 · Monolito modular con dos procesos, no microservicios

**Estado:** aceptada
**Fecha:** 29 de agosto de 2026
**Fase:** 0

## Contexto

La plataforma tiene que atender tráfico HTTP (sesión, proyectos, pizarras, IA,
imagen, XMI, generación) y tráfico WebSocket (salas, presencia, persistencia del
documento). Son dos perfiles de carga distintos sobre el mismo dominio.

## Decisión

Un monolito modular orientado al dominio, desplegado como **dos ejecutables**:
`backend/api` y `backend/collab`. Comparten el mismo repositorio, los mismos
paquetes de `shared/` y la misma base de datos.

Arquitectura hexagonal aplicada de forma ligera y **solo** en
`shared/domain-core`, que no depende de React, del documento colaborativo, del
servidor HTTP, de la base de datos ni de ningún proveedor de IA. Fuera de ese
paquete, código directo: nada de convertir cada operación en un puerto con su
adaptador, su fábrica y su mapeador.

## Por qué dos procesos y no uno

Montar HTTP y WebSocket sobre el mismo servidor obliga a resolver una
convivencia que no aporta nada al examen. Además escalan distinto: el proceso de
colaboración mantiene conexiones abiertas y estado de sala; el HTTP atiende
peticiones cortas.

## Por qué no son microservicios

No hay bases de datos separadas, ni contratos versionados entre ellos, ni
despliegue independiente, ni equipos distintos. Es una aplicación modular con dos
ejecutables, y Docker Compose lo oculta detrás de un comando.

Dividir el módulo de proyectos o el de usuarios en servicios propios no
resolvería ningún problema real de este sistema.

## Consecuencias

- Los dos procesos **no guardan estado en memoria propia**: todo va a la base.
  Es lo que permitirá replicarlos más adelante sin rediseñar (sección 14).
- `shared/` no es opcional: es la consecuencia directa de RA-05. El aplicador de
  comandos y el validador se ejecutan en el navegador y en el servidor, con una
  sola implementación.
- El proceso `collab` se construye sobre `node:http` y no sobre un framework,
  porque en la fase 4 el servidor de documentos se engancha al evento `upgrade`
  de esa misma instancia.
- Los primeros candidatos a separar, si algún día hiciera falta, son generación e
  imágenes: consumen tiempo y ya tienen frontera limpia (reciben un snapshot,
  devuelven un artefacto). No se implementa durante el parcial.

## Alternativas descartadas

**Un solo proceso.** Posible, pero obliga a integrar HTTP y WebSocket en el mismo
servidor sin ganancia para el examen.

**Núcleo en Java.** Obligaría a implementar el modelo canónico y el validador dos
veces, y el módulo de IA no podría aplicar comandos directamente sobre el
documento. Descartada.
```

---

### `docs/adr/ADR-002-crdt-para-colaboracion.md`

````markdown
# ADR-002 · CRDT para la colaboración en tiempo real

**Estado:** aceptada
**Fecha:** 29 de agosto de 2026
**Fase:** 4

## Contexto

Varias personas editan la misma pizarra a la vez, desde máquinas distintas de la
red del aula. Dos de ellas pueden mover la misma clase, renombrarla o añadirle
atributos en el mismo segundo.

## Decisión

**Yjs**, un CRDT, con **Hocuspocus** como servidor de salas y su persistencia.

Una sala por pizarra: `project:{projectId}:board:{boardId}`. Cada sala tiene su
propio documento, y por eso dos pizarras del mismo proyecto no mezclan
actualizaciones (CA-004.1) — son dos documentos, no dos vistas del mismo.

## Por qué un CRDT y no bloqueo ni transformación operacional

**Bloqueo por elemento** obliga a preguntar al servidor antes de cada cambio, lo
que se nota como latencia en cada tecla, y deja el problema de qué hacer cuando
quien tiene el bloqueo cierra el portátil.

**Transformación operacional** converge, pero necesita un servidor con estado que
ordene y transforme cada operación. Es más servidor del que este sistema quiere
tener, y su corrección es notoriamente difícil de conseguir.

Un CRDT converge sin coordinación central. El servidor pasa a ser un punto de
encuentro y un almacén, no un árbitro. Eso es lo que permite que la edición sea
instantánea en local y que un participante que pierde la red un momento se
reincorpore sin perder lo que escribió.

## Lo que el CRDT no garantiza

**RA-12: la colaboración garantiza convergencia estructural, no validez
semántica.**

Dos usuarios pueden crear a la vez `Detalle de Venta` y `detalle venta`. Los dos
nombres colapsan al mismo identificador técnico, así que el modelo resultante es
inválido — y sin embargo el documento converge perfectamente: las dos clases
existen, con los mismos identificadores, en todas las réplicas (CA-025.1).

Resolver eso en el CRDT sería pedirle algo que no hace. Lo resuelve el validador,
y el error bloquea la generación, no la edición. Esa distinción es la que hace
que la pizarra siga siendo usable mientras alguien arregla la colisión.

## Forma del documento

```
classes        Y.Map<classId, Y.Map>   cada clase, con Y.Array de atributos
relationships  Y.Map<relationshipId, Y.Map>
layout         Y.Map con positions: Y.Map<classId, Y.Map{x,y}>
meta           Y.Map con la versión del esquema
```

Clases y relaciones van en `Y.Map` indexado por identificador, no en `Y.Array`.
Dos inserciones concurrentes en la misma posición de un array habría que
desempatarlas; dos claves distintas de un mapa conviven sin ambigüedad.

Los atributos sí van en `Y.Array`, porque **su orden se ve**: es el de la tarjeta
y el del código generado. El CRDT garantiza que ese orden converge igual en todas
las réplicas.

## Una sola implementación de las reglas

`@uml/yjs-adapter` **no reimplementa** la validación. Llama a `applyBatch` de
`@uml/domain-core`, que valida y calcula el estado resultante, y después escribe
en el documento los valores que ese resultado contiene — nombres técnicos
incluidos. Lo único que vive en el adaptador es dónde va cada cosa en el árbol
Yjs (RA-05).

Aun así son dos mutadores: uno sobre objetos planos y otro sobre el árbol Yjs.
Una prueba compara la proyección del documento con el estado que devolvió el
dominio después de cada comando. Si algún día divergen, falla ahí y no el día de
la defensa.

## Transacción y deltas

Un lote entero se aplica dentro de una única `doc.transact`. Cuatro comandos
producen **un solo mensaje** a los demás participantes, no cuatro. La transacción
no es un mecanismo de deshacer: la validación ya ocurrió antes, y un lote
rechazado no llega a tocar el documento (RA-03).

Durante la edición viajan actualizaciones incrementales; el estado completo solo
se entrega a quien se incorpora (RA-02, CA-023.1). Una prueba mide que el delta
de un cambio es una fracción del estado completo — sin esa propiedad, cada tecla
enviaría el diagrama entero.

**El protocolo de tiempo real no transporta comandos de dominio.** El comando se
aplica localmente y viaja la actualización resultante. Los comandos se registran
para auditoría, no para sincronizar.

## Persistencia

**RA-11: el documento se persiste en su representación binaria nativa.** Es lo
único que puede reabrir la sesión conservando el historial del CRDT.

El JSON canónico se guarda **además**, como proyección derivada, para validar,
generar e inspeccionar sin cargar Yjs. Nunca reconstruye el documento: si se
intentara, se perdería el historial y dos réplicas que estaban convergiendo
dejarían de hacerlo.

La escritura se agrupa con una espera tras el último cambio. Guardar en cada tecla
castigaría la base sin ganar nada: el estado vivo está en memoria y replicado en
cada navegador conectado.

## Autorización, que es la parte que suele olvidarse

**RA-15: toda conexión se autentica y autoriza antes de unirse a la sala.**

```
Conexión entrante → token válido → miembro del proyecto de esa pizarra
→ rol determina el modo → se une
```

Tres detalles que la implementación tuvo que resolver:

- **El nombre de sala es entrada no confiable.** Lo elige el cliente, así que se
  analiza con un patrón estricto y se comprueba que la pizarra pertenezca de
  verdad a ese proyecto. Sin eso, un miembro de un proyecto abriría la pizarra de
  otro montando un nombre de sala con su propio `projectId`.
- **`VIEWER` se conecta en modo de solo lectura y el servidor descarta sus
  escrituras.** Ocultar los botones en la interfaz no es una medida de seguridad.
- **El motivo del rechazo que llega al cliente no distingue «no existe» de «no
  eres miembro».** Distinguirlos confirmaría que la pizarra existe a quien solo
  está probando identificadores. El detalle sí queda en el registro del servidor.

## Escalabilidad, prevista y no construida

Los procesos no guardan estado propio más allá de los documentos abiertos. Correr
varias instancias del proceso de colaboración requeriría un adaptador de
mensajería compartida entre ellas — Hocuspocus tiene extensión para eso. No se
implementa durante el parcial: RNF-02 pide cinco participantes por pizarra, y eso
lo sirve un proceso de sobra.
````

---

### `docs/adr/ADR-003-modelo-canonico-comandos-lotes.md`

````markdown
# ADR-003 · Modelo canónico único con comandos y lotes atómicos

**Estado:** aceptada
**Fecha:** 29 de agosto de 2026
**Fase:** 1

## Contexto

Seis entradas distintas modifican el mismo diagrama: interfaz gráfica, texto,
voz, imagen, XMI y, en el futuro, cualquier otra. Cada una podría escribir
directamente sobre el estado.

## Decisión

Existe **un solo modelo canónico**, y toda entrada es un adaptador que produce
**lotes de comandos** de un vocabulario cerrado de once operaciones (ver la
enmienda del 31 de agosto: sigue siendo once). Ninguna
entrada escribe el estado directamente.

```
GUI · texto · voz · imagen · XMI
              ↓
     Propuesta de lote
              ↓
     Resolución estructural
              ↓
         Validación          ← si hay un solo error, no se aplica nada
              ↓
    Aplicador de comandos
```

## Por qué el vocabulario es cerrado

El asistente de IA propone comandos. Si el vocabulario fuera abierto —o peor, si
el modelo pudiera emitir mutaciones arbitrarias— cada respuesta del proveedor
sería una superficie de ataque y una fuente de estados imposibles. Once
operaciones con carga tipada se validan por esquema antes de tocar nada.

Esto es RA-06, y es también lo que permite que el esquema JSON entregado al
modelo como formato de salida se derive de los mismos contratos que validan la
entrada, en lugar de mantenerse a mano en paralelo.

## Enmienda del 31 de agosto de 2026 · el tamaño de una tarjeta

Redimensionar una clase en el lienzo, como se hace en Enterprise Architect,
necesitaba un sitio donde guardar el tamaño. Había dos caminos y se eligió el
que **no** amplía el vocabulario: `MOVE_CLASS` lleva ahora un `size` opcional.

**Por qué ahí y no en un comando nuevo.** Redimensionar es colocar. Igual que la
posición, el tamaño es disposición pura: no entra en el modelo semántico, no
puede invalidarlo y no llega al snapshot que congela la generación —ese se
construye con `readSemanticModel`—, así que no puede cambiar una línea del código
generado ni del XMI. Un duodécimo comando para una variante de lo mismo habría
ampliado la superficie que el asistente puede proponer sin ninguna ganancia:
**el asistente no tiene por qué redimensionar cajas.**

**Por qué opcional.** Arrastrar emite `MOVE_CLASS` sin tamaño, y entonces el que
hubiera se conserva; si lo borrara, mover una tarjeta desharía el ancho que
alguien acaba de ajustar. Además, todos los lotes anteriores a este cambio
siguen validando contra el esquema nuevo.

**Dónde se impone el mínimo.** En el contrato, no en el aplicador. `applyBatch`
recibe comandos ya tipados y no revalida: quien filtra es el esquema, en el borde
por donde entra un lote. Lo descubrió una prueba que esperaba lo contrario.

El tamaño manual gana al alto calculado por número de atributos. Si no, añadir un
atributo desharía el ajuste.

## Por qué el lote es la unidad transaccional

CA-032.2 lo exige: ante "crea Cliente con nombre, teléfono y correo", si un
comando es inválido no se aplica ninguno. El usuario dictó una intención, no tres
operaciones independientes; dejarla a medias produce un modelo que él no pidió.

La implementación es una función pura sobre el estado: recibe uno y devuelve
otro, sin mutar el que recibe. Un lote rechazado no deja rastro por construcción,
no por disciplina al escribir cada rama.

## La consecuencia que no era obvia

La validación del lote **no puede** limitarse a "¿el modelo resultante es
válido?". Dos usuarios pueden crear concurrentemente nombres que colapsan al
mismo identificador (CA-025.1): el documento converge en un modelo inválido, y el
validador debe marcarlo. Pero si un lote se rechazara por cualquier error presente
en el resultado, esa pizarra quedaría congelada — incluido el lote que arreglaría
la colisión.

Por eso el aplicador compara los hallazgos **antes** y **después**, y solo
rechaza los que el lote introduce. Cada hallazgo tiene una identidad estable
(código más elementos implicados) que hace posible esa comparación.

RA-12 dice que la colaboración garantiza convergencia estructural, no validez
semántica. Esta es la pieza que hace esa frase vivible.

## Consecuencias

- Los comandos se registran para auditoría, **no** para sincronizar (CA-023.1).
  Lo que viaja en tiempo real es la actualización del documento, no el comando.
- El validador es el mismo que decide si se puede generar. Una sola definición de
  "modelo válido".
- Añadir una entrada nueva —otro formato de importación, otro proveedor— no toca
  el núcleo: se escribe un adaptador que produzca comandos.

## Alternativas descartadas

**Cada entrada escribe el estado.** Seis implementaciones peleándose por ser la
verdad, y seis sitios donde arreglar cada regla de validación.

**Event sourcing.** Ver ADR-006. El comando aquí es una instrucción, no un evento
persistido del que se reconstruya el estado.
````

---

### `docs/adr/ADR-004-varias-pizarras-generacion-seleccionada.md`

```markdown
# ADR-004 · Varias pizarras y generación sobre una pizarra seleccionada

**Estado:** aceptada
**Fecha:** 29 de agosto de 2026
**Fase:** 3

## Contexto

Un proyecto puede contener diagramas para contextos distintos. Tratar cada
proyecto como una sola pizarra simplificaría la primera pantalla, pero mezclaría
sesiones colaborativas, permisos de edición y artefactos generados.

También había que decidir si la generación combina todas las pizarras de un
proyecto o trabaja con una sola. Combinar exige definir relaciones entre
documentos, resolver colisiones globales y decidir qué hacer con una pizarra
inválida cuando las demás sí son generables.

## Decisión

**Un proyecto contiene varias pizarras independientes. Cada pizarra tiene su
propio documento y su propia sala colaborativa. La generación recibe una pizarra
seleccionada y nunca fusiona varias.**

La sala se identifica como `project:{projectId}:board:{boardId}`. El servidor
comprueba que ambos identificadores corresponden entre sí antes de permitir la
conexión.

## Por qué

- La independencia evita que una actualización de una pizarra aparezca en otra.
- El permiso sigue siendo del proyecto, sin duplicar membresías por documento.
- El snapshot de generación tiene una única fuente y puede congelarse de forma
  inmutable (RA-08).
- El banco y el generador no necesitan semántica de relaciones cruzadas que el
  modelo canónico no representa.

## Consecuencias

- `Board` pertenece a un `Project`, pero documento, snapshots y generaciones
  pertenecen a la pizarra.
- CA-004.1 verifica con dos navegadores que dos pizarras del mismo proyecto no
  mezclan actualizaciones.
- La interfaz debe hacer explícita la pizarra que se va a generar.
- Fusionar pizarras o crear relaciones entre ellas queda fuera del parcial.
```

---

### `docs/adr/ADR-005-entidad-intermedia-muchos-a-muchos.md`

```markdown
# ADR-005 · Entidad intermedia explícita para muchos a muchos

**Estado:** aceptada
**Fecha:** 29 de agosto de 2026
**Fase:** 1

## Contexto

`Alumno` y `Materia` se relacionan muchos a muchos, y la inscripción tiene datos
propios: gestión, fecha, nota. JPA sabe generar una tabla de unión con
`@ManyToMany`, así que la herramienta podría emitirla.

## Decisión

RM-01: **toda relación muchos a muchos se modela con una clase intermedia
explícita y dos relaciones N:1.** La N:M directa no llega al generador; el
validador la marca como error y sugiere cómo modelarla.

## Por qué

**La tabla de unión implícita no admite atributos.** En cuanto la asociación
tiene un dato propio —y casi siempre lo tiene— hay que convertirla en entidad de
todos modos. Hacerlo desde el principio evita una migración a mitad del modelado.

**`@ManyToMany` arrastra decisiones que este alcance no toma.** Lado propietario,
`cascade`, `fetch`, nombre de la tabla de unión y de sus columnas. Todo eso es lo
que RTM-05 elimina deliberadamente al generar solo el lado propietario.

**La app móvil no podría sincronizar la asociación.** Una fila de tabla de unión
no tiene identidad propia, así que no tiene UUID que el cliente pueda asignar
antes de sincronizar (ADR-013 y RM-06). Una `Inscripcion` sí.

**Es lo que se enseña.** Presentar `DetalleVenta` como entidad es exactamente lo
que la consigna del docente espera ver.

## El error no es un rechazo seco

El validador identifica la construcción y dice cómo modelarla:

> La relación entre "Alumno" y "Materia" es muchos a muchos.
> Crea una clase intermedia con dos relaciones N:1, una hacia "Alumno" y otra
> hacia "Materia". Ahí es donde viven los atributos propios de la asociación.

Cada exclusión del alcance está declarada, no omitida. Cuando aparece una
construcción no soportada, la herramienta la identifica con claridad y sugiere la
alternativa en lugar de fallar sin explicación.

## Consecuencias

- El generador nunca emite `@ManyToMany`, `@JoinTable` ni colecciones.
- T06 del banco de regresión es exactamente este caso, ya resuelto con
  `Inscripcion`, y T01 lo repite con `DetalleVenta`.
- Detectar la N:M mientras se dibuja y ofrecer crear la clase intermedia con un
  clic es trabajo de la fase 5. La regla que lo hace obligatorio ya está.
```

---

### `docs/adr/ADR-006-sin-event-sourcing-ni-cqrs.md`

```markdown
# ADR-006 · Sin event sourcing ni CQRS completo

**Estado:** aceptada
**Fecha:** 29 de agosto de 2026
**Fase:** 2

## Contexto

La plataforma ya usa comandos de dominio, un documento CRDT, una proyección JSON
y una tabla de auditoría. Esa combinación puede parecer el comienzo de event
sourcing o CQRS y llevar a tratar el historial de comandos como fuente de verdad.

Eso sería incorrecto para la colaboración: el protocolo transmite deltas del
CRDT y puede fusionar cambios concurrentes sin un orden total de comandos.
Reconstruir desde comandos exigiría inventar ese orden y duplicar la lógica de
persistencia que Yjs ya resuelve.

## Decisión

**El documento Yjs persistido en formato binario es la fuente del estado vivo.
No se implementan event sourcing ni CQRS completo.**

Los comandos sirven para validar y aplicar una intención local de forma atómica.
Su registro es auditoría, no un log desde el que se reconstruye el documento. El
JSON canónico es una proyección para inspección, validación y generación; nunca
rehidrata Yjs (RA-11).

## Consecuencias

- Reabrir una pizarra carga `BoardDocument.state`, no reproduce comandos.
- `audit_operations` puede responder quién pidió qué, pero perder esa tabla no
  impide recuperar el documento.
- Lectura y escritura comparten el mismo modelo; no hay buses, almacenes ni
  despliegues separados para cada lado.
- Los snapshots numerados solo congelan entradas de generación. Tampoco son un
  historial de eventos.
- Si el producto necesitara auditoría legal o reproducción temporal completa,
  haría falta otra decisión y un diseño específico; no se simula dentro del
  alcance actual.
```

---

### `docs/adr/ADR-007-generacion-por-ir-y-plantillas.md`

````markdown
# ADR-007 · Generación por representación intermedia y plantillas

**Estado:** aceptada
**Fecha:** 29 de agosto de 2026
**Fase:** 2

## Contexto

Hay que convertir un diagrama de clases en un proyecto Spring Boot que compile y
arranque. Un modelo de lenguaje escribe Java razonable la mayoría de las veces, y
sería el camino más corto.

## Decisión

**RA-07: la generación es determinista por plantillas. Ningún modelo de lenguaje
escribe Java.**

**RA-13: entre el modelo canónico y las plantillas existe una representación
intermedia.** El modelo canónico no sabe qué es una clave foránea; las plantillas
no saben qué es una multiplicidad.

```
Modelo canónico          ← qué significa el diagrama
       ↓
Snapshot inmutable       ← RA-08, entrada congelada
       ↓
Representación intermedia ← lado propietario, FK, rutas, tipos Java
       ↓
Plantillas Handlebars    ← texto
       ↓
Árbol de archivos → ZIP
```

## Por qué no un modelo de lenguaje

**«La mayoría de las veces» no sirve.** El docente abre el ZIP delante de todos y
lo ejecuta. Un fallo de compilación en ese momento no tiene recuperación, y la
probabilidad de que cuatro entidades y siete archivos por entidad salgan todos
correctos es el producto de veintiocho probabilidades menores que uno.

**RNF-05 exige determinismo**: el mismo snapshot y la misma versión del generador
producen el mismo código. Un modelo de lenguaje no lo garantiza ni con
temperatura cero, y sin determinismo el banco de regresión no significa nada:
cada ejecución probaría un artefacto distinto.

**El aula puede no tener internet.** El plan de degradación (16.4) dice que
generar el backend no necesita conexión. Con un modelo de lenguaje en el
camino, sí la necesitaría — y la generación es justo lo que no se puede permitir
perder.

Donde el modelo sí aporta es en interpretar la intención del usuario y en leer
una fotografía de pizarrón. Ahí la ambigüedad es del problema; en emitir Java,
no.

## Por qué existe la representación intermedia

Sin ella, las plantillas tendrían que decidir cuál de los dos extremos de una
relación recibe la clave foránea, cómo se llama el campo cuando no hay rol, qué
tipo Java corresponde a `Decimal` y cómo se deriva la ruta REST. Esas decisiones
son de persistencia (RTM-05 a RTM-12) y estarían repetidas en cada plantilla que
las necesite, en un lenguaje de plantillas que no se puede probar unitariamente.

Con ella, la IR se prueba como cualquier estructura de datos —entra un modelo,
sale un objeto que se puede afirmar campo por campo— y las plantillas quedan
reducidas a interpolar. Las mismas decisiones alimentan al generador de la capa
la representación intermedia, que es lo que mantiene un solo origen de verdad.

La IR se congela con `Object.freeze` recursivo. La entrada se analiza con el
esquema de contratos, que devuelve una copia: un cambio en la pizarra a mitad de
la generación no puede alterar el ZIP en curso (CA-060.1).

## Qué se verifica, y por qué no basta con compilar

`npm run test:generated` ejecuta la Definition of Done de la sección 15.1 sobre
T01, contra una base limpia:

```
generar → compilar con Maven y Java 21 → arrancar contra PostgreSQL
→ el contrato OpenAPI carga → altas en orden topológico
→ consulta por colección, por identificador y por clave foránea
→ modificación → alta repetida con el mismo id, sin duplicado
→ reiniciar → los datos siguen ahí
→ borrar padre con hijos → 409 esperado → borrado en orden inverso
```

La compilación exitosa por sí sola no significa que el generador funciona. El
ciclo de serialización, la violación de clave foránea, el error sin traducir y el
borrado accidental del esquema **solo aparecen ejecutando**. El `409` es un caso
de éxito, no un fallo.

## Consecuencias

- Añadir un campo al código generado es editar una plantilla, no reentrenar nada.
- Cualquier generador futuro parte de la misma IR y del mismo
  snapshot, así que los contratos no pueden divergir.
- Las versiones del proyecto generado (Spring Boot, springdoc, PostgreSQL) están
  fijadas en el generador y verificadas por la ejecución real. Ver ADR-016.
- CI ejecuta T01 en cada cambio (RNF-13), con Java 21 y un PostgreSQL efímero.
````

---

### `docs/adr/ADR-008-dto-planos-relaciones-unidireccionales.md`

````markdown
# ADR-008 · DTO planos y relaciones unidireccionales

**Estado:** aceptada
**Fecha:** 29 de agosto de 2026
**Fase:** 2

## Contexto

`Cliente` tiene muchas `Venta`. JPA permite mapear los dos lados: `@ManyToOne` en
`Venta` y `@OneToMany(mappedBy = "cliente")` en `Cliente`. Y el CRUD podría
devolver la entidad con su cliente anidado.

Las dos cosas parecen convenientes y las dos rompen.

## Decisión

**RTM-05: solo se genera el lado propietario.** Sin colección inversa, sin
`mappedBy`, sin `cascade`, sin `orphanRemoval`, sin `fetch` explícito.

**RTM-09: un registro plano por entidad, para entrada y salida. Las relaciones se
expresan como identificador, nunca como objeto anidado.**

```java
public record VentaDTO(UUID id, LocalDateTime fecha, BigDecimal total, UUID clienteId) {}
```

## Por qué unidireccional

Con el lado inverso desaparecen los ciclos de propiedad, las colecciones
perezosas y la pregunta de quién es el dueño de la relación. **La clave foránea
en la base de datos queda exactamente igual de correcta**: `venta.cliente_id`
existe con o sin `@OneToMany` en `Cliente`.

Lo que se pierde es `cliente.getVentas()`. Se compensa, y hay que compensarlo
explícitamente porque sin ello la app móvil no podría hacer nada útil.

## La compensación

Por cada clave foránea el generador emite un finder con navegación explícita de
propiedad, expuesto como parámetro de consulta:

```java
List<Venta> findByCliente_Id(UUID clienteId);
```
```
GET /api/venta?clienteId={uuid}
```

Sin esto no habría forma de consultar las ventas de un cliente, que es
exactamente lo que la app móvil necesita. El controlador acepta el parámetro
como opcional: sin él devuelve la colección completa.

## Por qué DTO planos

**Elimina por construcción el ciclo de serialización.** `Venta` → `Cliente` →
lista de ventas → `Venta` es un desbordamiento de pila en el primer `GET`, y es
el fallo más común de este tipo de proyecto.

**No se usan anotaciones de referencia gestionada.** `@JsonManagedReference` y
`@JsonIgnore` ocultan el ciclo, pero también ocultan el dato: la app móvil
recibiría ventas sin cliente y no sabría a quién pertenecen. El identificador
plano da el dato completo sin el ciclo.

**Separa la entidad del contrato HTTP.** La entidad puede cambiar de mapeo sin
cambiar la respuesta.

## Se implementa desde el primer generador

El docente lo planteó como opcional. Se hace igual, y desde el principio:
introducirlo después obliga a reescribir todos los controladores, todos los
servicios y todas las pruebas del banco. Es la clase de decisión que solo es
barata al principio.

## Consecuencia sobre la clave primaria

Con DTO planos, el identificador viaja en el cuerpo de la petición. Eso obliga a
RTM-11: la clave primaria UUID se declara **sin generación automática**. Si
llevara `@GeneratedValue`, el identificador enviado por el cliente se ignoraría o
dispararía una actualización en lugar de un alta.

El servicio asigna un UUID solo si la petición no trae uno, y un `POST` sobre un
identificador existente devuelve el recurso existente en lugar de duplicar o
fallar. Eso hace idempotentes las creaciones sin infraestructura adicional: un
reintento tras un tiempo de espera agotado devuelve el mismo registro, que es
justo lo que la cola de sincronización del móvil necesita (CA-10.1).

## Alternativas descartadas

**Bidireccional con `mappedBy`.** Añade la pregunta del lado propietario a cada
relación, y las colecciones perezosas provocan `LazyInitializationException`
fuera de la transacción — otro fallo clásico en demostración.

**Devolver entidades directamente.** Ciclo de serialización garantizado y
acoplamiento del contrato HTTP al mapeo de persistencia.

**Anidar el objeto relacionado en el DTO.** Vuelve el ciclo por otra puerta y
obliga a decidir hasta qué profundidad se anida.
````

---

### `docs/adr/ADR-009-runtime-compartido.md`

```markdown
# ADR-009 · Runtime compartido entre navegador y servidor

**Estado:** aceptada
**Fecha:** 29 de agosto de 2026
**Fase:** 1

## Contexto

El aplicador de comandos y el validador tienen que ejecutarse en dos sitios:

- en el **navegador**, para que la edición sea instantánea y el usuario vea el
  error mientras escribe, sin ida y vuelta al servidor;
- en el **servidor**, para que el asistente de IA, la importación por imagen y la
  de XMI apliquen los mismos comandos con las mismas reglas.

## Decisión

RA-05: **una implementación, dos lugares de ejecución.** `@uml/domain-core` es un
paquete de TypeScript puro que no depende de React, del documento colaborativo,
del servidor HTTP, de la base de datos, de ningún proveedor de IA ni del sistema
de archivos.

Esa restricción se prueba, no se confía: RNF-15 exige que el paquete se pruebe
sin ninguna de esas cosas, y sus pruebas no importan ninguna.

## Por qué no vive dentro del backend

Si el código viviera en `backend/`, el navegador tendría que reimplementarlo. Las
dos versiones divergirían — no *quizá*, sino en algún momento. El síntoma sería
un lote que el asistente produce y el editor rechaza sin motivo aparente, o al
revés: un modelo que el editor acepta y el generador no puede emitir.

Ese fallo es especialmente caro porque aparece tarde y se diagnostica mal: parece
un problema del asistente cuando es una discrepancia de reglas.

## Por qué el núcleo es TypeScript y no Java

Un núcleo en Java obligaría a implementar el modelo canónico y el validador dos
veces, y a que el módulo de IA no pudiera aplicar comandos directamente sobre el
documento. El generador emite Java; no tiene que estar escrito en Java.

## Lo que sí es específico de cada lado

`@uml/domain-core` trabaja sobre el modelo canónico plano. El documento
colaborativo es otra representación, y traducir entre ambas es trabajo de
`@uml/yjs-adapter` (fase 4) — que reutiliza esta validación en lugar de
reimplementarla.

## Consecuencias

- `shared/` no es una carpeta de conveniencia: es la consecuencia directa de
  RA-05. Lo mismo aplica a `@uml/contracts`, del que se derivan los tipos
  estáticos, el validador en ejecución y el esquema JSON que se le pasa al modelo
  de lenguaje.
- Cualquier `import` de `node:fs`, `node:crypto` o del DOM dentro de
  `domain-core` es una señal de que la lógica está en el paquete equivocado.
- El banco de regresión (`@uml/fixtures`) construye sus modelos en memoria por
  esta misma razón: las pruebas del núcleo lo importan sin tocar disco.
```

---

### `docs/adr/ADR-010-docker-compose-iac-diferida.md`

```markdown
# ADR-010 · Docker Compose, infraestructura como código diferida

**Estado:** aceptada
**Fecha:** 29 de agosto de 2026
**Fase:** 0

## Contexto

RNF-12 exige que la plataforma se levante completa con un solo comando. La
sección 13 pide además poder apagar o reiniciar piezas individuales sin tocar el
resto.

## Decisión

Docker Compose desde el primer día, con perfiles. Infraestructura como código
(Terraform u OpenTofu) queda **después del parcial**.

### Servicios y perfiles

| Servicio | Perfil | Por qué |
|---|---|---|
| `db` | por defecto | PostgreSQL de la plataforma |
| `api` | por defecto | Proceso HTTP |
| `collab` | por defecto | Proceso WebSocket |
| `web` | por defecto | Interfaz React |
| `proxy` | `demo` | Origen único para la demostración |
| `adminer` | `tools` | Inspección de la base |

Los perfiles hacen que `proxy` y `adminer` no arranquen salvo que se pidan. El
entorno diario queda liviano y el de demostración se enciende cuando hace falta.

### Reglas aplicadas en `infra/compose.yml`

- Cada servicio declara comprobación de salud y quien depende de él la espera.
  Evita el error clásico del servidor que arranca antes que la base.
- Los datos viven en volúmenes con nombre. Solo `down -v` los borra.
- Toda la configuración entra por variables de entorno, con `infra/.env.example`
  versionado y `infra/.env` ignorado.
- Ningún secreto queda escrito en la composición.
- Con el perfil `demo`, el navegador habla con un solo origen: desaparecen los
  problemas de origen cruzado y las otras computadoras del aula llegan a una
  dirección en lugar de tres puertos.

## Por qué no infraestructura como código ahora

El retorno es negativo a tres semanas de la entrega. El problema a resolver es
modelado UML colaborativo, no aprovisionamiento de redes y DNS. Docker sí reduce
riesgo real el día de la defensa; Terraform no reduce ninguno.

## Consecuencia para el artefacto generado

El backend generado trae **su propia** composición dentro del ZIP, independiente
de la plataforma. Es la salvaguarda del día de la defensa: si la máquina donde se
abre el proyecto no tiene PostgreSQL, o tiene otra versión, o el puerto ocupado,
la composición lo resuelve. Se implementa en la fase 6 (RF-071).
```

---

### `docs/adr/ADR-011-generacion-limitada-capa-datos.md`

````markdown
# ADR-011 · Generación limitada a la capa de datos del cliente móvil

**Estado:** aceptada
**Fecha:** 29 de agosto de 2026
**Fase:** 6

## Contexto

La herramienta genera un backend completo. La pregunta natural es si debería
generar también la aplicación móvil.

## Decisión

**No se genera la aplicación Flutter. Se genera su capa de datos.**

El equipo construye la interfaz en vivo durante la defensa, apoyándose en el
paquete generado: modelos, cliente HTTP tipado, base local, repositorios con dos
orígenes y cola de sincronización.

## Por qué no la aplicación entera

**El docente dijo explícitamente que no verá aplicaciones móviles generadas.**
Eso por sí solo cierra la discusión.

Además, un segundo generador de aplicaciones cuesta tanto como el primero y
compite por tiempo con el que sí se evalúa. Generar pantallas obliga a decidir
navegación, formularios, validación en pantalla y estado — decisiones que no
tienen una traducción mecánica desde un diagrama de clases.

## Por qué sí la capa de datos

Es exactamente la parte que **sí** tiene traducción mecánica. Un modelo, un
cliente HTTP, una tabla y un repositorio salen del mismo sitio que la entidad
JPA: la representación intermedia.

Y es la parte que más tiempo consume escribir a mano en la demostración. Con
cuatro entidades son dieciséis archivos de conversión de tipos, y cada uno tiene
la misma oportunidad de equivocarse con un `int` que debía ser `double`.

## La propiedad que hace esto valioso

**Backend y capa Dart salen del mismo snapshot y la misma representación
intermedia.** No de dos lecturas del mismo modelo: del mismo objeto.

Es lo que impide que los contratos diverjan. Si el backend emite `clienteId` y el
cliente móvil espera `cliente_id`, la aplicación compila, arranca y falla en
ejecución contra un servidor que responde otra cosa — un fallo que se diagnostica
mal y en el peor momento.

## Lo que el paquete resuelve, y lo que no

**Resuelve:**

- Los tipos. `Decimal` → `double`, pero leyendo con `(json['x'] as num).toDouble()`
  porque un JSON con `total: 100` produce un `int` en Dart y asignarlo a un
  `double` revienta en ejecución.
- SQLite no tiene booleano ni fecha: van como entero y como texto ISO, y la
  conversión está escrita en los dos sentidos.
- Los finders por clave foránea, que son la compensación de RTM-05. Sin ellos no
  habría forma de pedir «las atenciones de este cliente».
- La cola persistente. Editar tres veces el mismo registro sin conexión deja
  **una** operación pendiente con el último estado, no tres envíos que el
  servidor tendría que aplicar en orden.

**No resuelve:** pantallas, navegación, gestión de estado ni el agente de voz.
Eso es la fase 9 y lo escribe el equipo.

## Compatibilidad con la creación sin conexión

RF-084 y CA-084.1: si una entidad no tiene clave primaria UUID, **se reporta como
incompatible** en lugar de emitir código que fallará al sincronizar.

Un `create` sin conexión necesita que el cliente asigne el identificador antes de
que exista red. Con una clave entera es el servidor quien la asigna, así que el
registro no puede existir hasta que haya conexión. El generador emite entonces un
`create` que exige red, y lo dice en el README del paquete y en el aviso de
generación.

Emitir un `create` que aparenta funcionar sin conexión y falla al sincronizar
sería peor que no generarlo.

## Enmienda del 5 de septiembre de 2026 · también se generan las pantallas

Esta decisión se apoyaba en una frase atribuida al docente: que el frontend
móvil se construye en vivo y generarlo sustituiría ese ejercicio. Al releer los
apuntes de la consigna, lo que dice es más preciso: **no verá aplicaciones
móviles generadas por la herramienta**, y sobre el backend generado el equipo
construye el frontend.

La diferencia importa. Lo que hace interesante a esa aplicación —el agente de
voz, el reconocimiento en el dispositivo, la clasificación local de
intenciones— es exactamente lo que la herramienta **no** puede generar, porque
depende del dominio y de la conversación que se quiera sostener. Los listados y
los formularios, en cambio, son mecánicos: salen del mismo modelo del que sale
el DTO.

**Se generan también las pantallas**: menú de entidades, listado con borrado y
formulario de alta y edición por cada una, con el control que corresponde a cada
tipo conceptual y un desplegable por clave foránea poblado desde la copia local.
El paquete deja de ser una biblioteca y pasa a ser una aplicación ejecutable.

Lo que sigue fuera, y es lo que el equipo escribe encima: el agente, la voz y la
interfaz conversacional. La sección 10 del plan maestro lo separa.

**Lo que la herramienta no emite y hay que ejecutar a mano**, documentado en el
README del propio artefacto:

```bash
flutter create --platforms=android .   # respeta lib/, añade android/
```

Y una línea en el manifiesto, `android:usesCleartextTraffic="true"`, sin la cual
Android bloquea el tráfico HTTP hacia el backend de la red local. Emitir
`android/` ataría cada generación a una versión concreta de Gradle.

## Verificación

`npm run test:dart` genera la aplicación para los ocho modelos generables del
banco y ejecuta `flutter analyze --fatal-infos` sobre cada uno (CA-080.1).

Que el generador emita texto plausible no significa nada. Un `as int` sobre un
`num`, un campo requerido que llega nulo o un import que no existe solo aparecen
cuando el analizador de verdad mira el código — y las dos primeras versiones de
estas plantillas fallaron exactamente ahí.

## Retirada del 5 de septiembre de 2026

**Superada.** La herramienta ya no emite ningún artefacto para el cliente móvil:
la generación queda en el backend Spring Boot con PostgreSQL, más su colección
de Postman. `shared/generator-dart` y `templates/dart` se retiraron del
repositorio, con la aplicación de referencia que vivía en `mobile/`.

La aplicación que consuma el backend generado se construye entera aparte. Esta
decisión queda como registro de por qué en su momento se generó solo la capa de
datos y no las pantallas; el razonamiento sigue siendo válido si algún día se
retoma. Recuperable con `git checkout <commit> -- shared/generator-dart templates/dart`.
````

---

### `docs/adr/ADR-012-importacion-como-candidato-editable.md`

```markdown
# ADR-012 · Toda importación produce un candidato editable, nunca un modelo aplicado

**Estado:** aceptada
**Fecha:** 29 de agosto de 2026
**Fase:** 8

> Este número estaba reservado en el plan maestro para «Agente móvil local con
> resolución determinista de entidades». Esa decisión se toma en la fase 9 y se
> registrará entonces; el índice de ADR recoge la renumeración.

## Contexto

Dos entradas producen modelos completos de golpe: una fotografía de un pizarrón y
un archivo XMI de Enterprise Architect. A diferencia del editor o del asistente,
que hacen un cambio pequeño y comprobable, aquí llegan veinte elementos a la vez.

## Decisión

**Ninguna importación aplica nada.** Produce un candidato que la interfaz muestra
con su resumen, y el usuario decide.

CA-042.1 lo dice para la fotografía: *«el resultado se presenta como propuesta
editable y nunca se aplica automáticamente»*. Se aplica igual a XMI, por la misma
razón multiplicada: un archivo ajeno puede traer construcciones que este alcance
no modela.

## Por qué

**El reconocimiento de un pizarrón se va a equivocar en algo.** Luz, letra,
flechas ambiguas, un `N` que puede ser una `M`. Un candidato que no se puede
corregir no sirve.

**Un XMI ajeno trae cosas que no modelamos.** Herencia, asociaciones ternarias,
tipos que no están en RTM-01. El parser las reporta en lugar de descartarlas en
silencio: un modelo importado al que le faltan la mitad de los atributos sin
decirlo es peor que un error.

## Dónde se corrige el candidato

**En una tabla estructurada antes de aplicarlo.** La primera implementación
permite corregir nombres de clases y atributos, tipos, nulabilidad, claves
primarias y multiplicidades. Editar modifica las operaciones del mismo lote; no
crea una segunda vía de escritura ni toca todavía el documento Yjs.

No se duplica React Flow, el inspector ni el aplicador. La tabla conserva los
UUID resueltos y el lote completo sigue pasando por la validación y aplicación
atómicas al pulsar `Aplicar`. Los avisos extensos se pueden desplegar y el mismo
archivo se puede reintentar en modo `REPLACE`.

Quedan para fase 11 la edición de roles, eliminar operaciones individuales y la
validación reactiva que deshabilite `Aplicar` antes del intento. Hasta cerrar
esas tres piezas, el candidato es editable en sus campos principales pero el
criterio completo no se considera terminado.

## El mismo camino que todo lo demás

La importación produce **operaciones por nombre**, exactamente igual que el
asistente. De ahí en adelante recorre el mismo camino: resolución estructural,
validación, lote atómico, aplicación desde el navegador.

Eso significa que hereda todo gratis. La desambiguación pregunta si un nombre es
ambiguo. El lote es todo o nada, así que un XMI con un elemento inválido no deja
la pizarra a medias. Y reemplazar el contenido pasa por confirmación, porque
borrar veinte elementos es destructivo de alcance amplio (RF-035) — eso salió
solo, sin escribir una línea para ello.

RF-044 (añadir o reemplazar) es una decisión sobre qué operaciones se generan, no
un modo de aplicación distinto: en modo de reemplazo el borrado va delante y **en
el mismo lote**, así que si el contenido nuevo fuera inválido la pizarra queda
como estaba.

## Un hueco que esto destapó

El resolver no tenía en cuenta las clases borradas antes en la misma propuesta.
Con el editor y el asistente nunca se notó: nadie borra y vuelve a crear la misma
clase en una sola instrucción. Reemplazar el contenido de una pizarra hace
exactamente eso, y fallaba en cuanto un nombre se repetía entre lo viejo y lo
nuevo.

Ya seguía la pista de las clases *creadas* dentro del lote, por el caso «crea
Cliente y agrégale nombre». Faltaba la simétrica.

## XMI: qué se emite y qué queda por verificar

Se exporta **UML 2.1 estándar**, sin extensiones propietarias en la estructura.
Un archivo que solo Enterprise Architect entiende no sirve para nada más.

Los identificadores son los nuestros con un `_` delante — un `xmi:id` es un ID de
XML y no puede empezar por dígito, cosa que un UUID hace la mitad de las veces.
Conservarlos es lo que da el ida y vuelta sin perder identidad (RF-053), que sale
casi gratis.

Lo único en una extensión es la marca de atributo único: UML no tiene forma
estándar de expresarla, `isUnique` significa otra cosa, y usarlo sería mentir en
el archivo.

**Lo que no está verificado, y hay que decirlo claro:** el parser está probado
contra archivos de nuestro propio serializador. Eso comprueba que exportar e
importar no se separen entre sí; **no** comprueba que Enterprise Architect 15 lea
lo nuestro ni que nosotros leamos lo suyo. La variante de XMI la decide esa
instalación, no el estándar teórico.

Las mitigaciones —aceptar las tres notaciones de tipo que se ven en la práctica,
buscar el modelo sin depender de una ruta fija— reducen el riesgo pero no lo
cierran. Hay una prueba en `shared/xmi/tests/enterprise-architect.test.ts` que se
activa sola en cuanto alguien deje un archivo real en `fixtures/xmi/`, y mientras
tanto queda marcada como pendiente para que nadie lo dé por hecho.

Si hay que recortar, **exportar es lo que no se sacrifica**: RF-050 es P0 y
RF-051 es P1, y el caso de uso del docente es hacer el diagrama de secuencia
sobre clases que ya existen.

## Consecuencias

- El puerto de visión ya tenía su adaptador simulado desde la fase 7, así que
  toda esta cadena se prueba en CI sin llamar a un proveedor de pago.
- El límite de cuerpo de las rutas de importación sube por ruta, no
  globalmente: con el megabyte que Fastify trae por defecto, **ninguna fotografía
  real habría llegado nunca**.
- Exportar solo exige ser miembro. No modifica nada, y quien puede ver el
  diagrama puede llevárselo.
```

---

### `docs/adr/ADR-013-uuid-para-creacion-sin-conexion.md`

```markdown
# ADR-013 · La creación sin conexión exige clave primaria UUID

- **Estado:** Aceptada
- **Fase:** 9
- **Fecha:** 2026-08-30

## Contexto

La aplicación móvil tiene que registrar en modo avión (RFM-05, CA-03.1) y enviar
lo registrado cuando vuelva la conexión (RFM-10). Eso obliga a decidir **quién
asigna el identificador** de una fila que nace sin servidor.

Con un entero autoincremental la respuesta es el servidor, y entonces la fila no
existe hasta que haya red: no se le puede referenciar desde otra tabla local, no
se puede mostrar en una lista con identidad estable, y reintentar un envío que
agotó el tiempo de espera crea un duplicado, porque el cliente no puede decir
«esta fila es la misma que te mandé antes».

RTM-04 ya define cuatro ramas para elegir clave primaria a partir de la pizarra.
La pregunta aquí es qué pasa cuando el modelo elige entero autoincremental y ese
modelo se lleva al móvil.

## Decisión

**Toda entidad que la aplicación móvil pueda crear sin conexión usa UUID como
clave primaria, asignado por el dispositivo.** El generador de la capa de datos
El cliente emite `id` de tipo texto y el servidor lo exige ya presente: no hay un
camino en el que el identificador llegue después.

El backend generado, al recibir un alta con un identificador que ya tiene,
devuelve el recurso existente en lugar de duplicar o fallar (RTM-11). Reintentar
es seguro por construcción, no por suerte de red.

## Consecuencias

**A favor.** La fila existe en cuanto se dicta. Se puede referenciar desde una
atención antes de que ningún servidor la conozca. Un tiempo de espera agotado
seguido de un reintento deja **una** operación, que es lo que comprueba CA-10.1
y lo que verifica la prueba «RM-06 — el identificador lo asigna el dispositivo,
sin red».

**En contra.** Un UUID ocupa dieciséis bytes frente a cuatro u ocho, y como
clave primaria agrupada dispersa las escrituras. A la escala de este sistema —un
puñado de barberías, miles de filas— no se mide. En un sistema con volumen alto
de inserciones habría que revisarlo, y la revisión sería local a la elección de
clave, no a la arquitectura.

**Lo que cierra.** Ya no es posible que un modelo con clave autoincremental
llegue al móvil y falle a mitad de la demostración, sin conexión, sin poder
explicar por qué. La restricción se declara aquí y el generador la impone.

Relacionado: [ADR-011](ADR-011-generacion-limitada-capa-datos.md) (la generación
móvil llega hasta la capa de datos) y
[ADR-017](ADR-017-agente-movil-local.md) (quién escribe esas filas).
```

---

### `docs/adr/ADR-014-autenticacion-propia-minima.md`

```markdown
# ADR-014 · Autenticación propia mínima con roles por proyecto

**Estado:** aceptada
**Fecha:** 29 de agosto de 2026
**Fase:** 3

## Contexto

Sin identidad real, tres cosas no se sostienen: los roles no tienen dónde
apoyarse, la atribución de cambios en la presencia no es fiable, y las pizarras
son accesibles por quien adivine un identificador de sala.

## Decisión

Autenticación propia, con el alcance mínimo que hace posible lo anterior.

**Lo que se construye:** registro, inicio y cierre de sesión, renovación por
token de refresco, invitación por enlace con código, y tres roles por proyecto.

**Lo que no:** verificación por correo, recuperación de contraseña, inicio de
sesión con terceros, administración de organizaciones. Cada uno de esos
arrastraría un proveedor de correo o un tercero al camino crítico, a tres semanas
de la entrega.

## Contraseñas: scrypt, no Argon2id

RNF-08 pide una función de derivación moderna y lenta. Se usa **scrypt** de
`node:crypto`, con N=2¹⁶, r=8, p=1, sal de 16 bytes y clave de 64.

Argon2id sería la primera recomendación hoy. Se descarta por una razón concreta:
las implementaciones de Argon2 para Node son **módulos nativos**, y un módulo
nativo es la fuente número uno de «en mi máquina sí funciona» — distinta
arquitectura, distinta libc entre Alpine y Windows, cadena de compilación
ausente en el portátil de un compañero. scrypt viene en el runtime, se comporta
igual en los cinco sitios donde este código corre, y con esos parámetros es
memory-hard de verdad.

Es un intercambio consciente, no un descuido. El hash es autodescriptivo
(`scrypt$N$r$p$sal$clave`), así que subir los parámetros —o migrar a Argon2id
cuando deje de ser un riesgo de despliegue— no invalida las contraseñas
existentes: cada una se comprueba con los parámetros con los que se guardó.

## Tokens: acceso corto en cabecera, refresco rotativo en cookie

El **token de acceso** es un JWT de vida corta que viaja en `Authorization`. Es
un JWT y no una cookie de sesión por una razón específica: es el que se pasa al
abrir el WebSocket, y el servidor de colaboración tiene que poder autorizar la
conexión antes de entregar el documento (RA-15, fase 4).

El **token de refresco** es un secreto opaco de 384 bits, no un JWT. No necesita
transportar información —siempre se busca en la base, para poder revocarlo— y al
no ser verificable sin consultar, uno robado deja de servir en cuanto se rota.
Viaja en cookie `httpOnly`, así que el JavaScript de la página no lo ve.

Es **rotativo**: cada renovación revoca el anterior. Reutilizar uno ya rotado no
funciona, lo que convierte el robo de un refresco en una ventana estrecha en
lugar de un acceso permanente.

Se guarda el hash SHA-256 del token, nunca el token. SHA-256 basta aquí, a
diferencia de las contraseñas: hay 384 bits de entropía aleatoria, así que no hay
diccionario que probar y una derivación lenta solo añadiría latencia a cada
renovación.

## Dos decisiones de fuga de información

**Un no miembro recibe 404, no 403.** Responder «no tienes permiso» confirmaría
que el proyecto existe a quien solo está probando identificadores.

**El inicio de sesión comprueba la contraseña aunque el correo no exista**,
contra un hash ficticio, y devuelve el mismo mensaje en los dos casos. Sin eso,
el tiempo de respuesta y el texto del error convierten el formulario en un
comprobador de qué correos están registrados.

## Roles

| Rol | Puede |
|---|---|
| `OWNER` | Todo, más invitar, cambiar roles y eliminar el proyecto |
| `EDITOR` | Crear y editar pizarras, usar el asistente, generar código |
| `VIEWER` | Ver pizarras y consultar al asistente sin modificar |

El propietario no se puede degradar ni expulsar: dejaría el proyecto sin nadie
capaz de invitar, cambiar roles ni borrarlo. Transferir la propiedad es otra
operación y no entra en este alcance.

La autorización vive en un solo módulo, `modules/projects/membership.ts`. El
proceso de colaboración resolverá lo mismo en la fase 4 reutilizando esas reglas:
proteger las rutas HTTP sin autorizar la conexión WebSocket no sirve de nada.

## Invitaciones

Enlace con código aleatorio de 32 caracteres y rol asignado en el momento de
crearlo. No se verifica quién lo abre, así que lo único que lo protege es que no
sea adivinable — de ahí la longitud y la caducidad.

Aceptar dos veces la misma invitación **no es un error**: devuelve la membresía
que ya hay. Un enlace compartido se abre más de una vez, y fallar la segunda vez
solo confunde a quien no hizo nada mal.

## Consecuencias

- Toda la configuración sensible entra por entorno y `JWT_SECRET` **no tiene
  valor por defecto**: un secreto con valor por defecto acaba desplegado, y nadie
  se entera hasta que alguien firma sus propios tokens. El proceso se niega a
  arrancar sin él.
- Las pruebas de la API son de integración contra un PostgreSQL efímero. Probar
  autorización, membresías y cascadas contra una base de mentira no prueba nada:
  las restricciones de unicidad y las claves compuestas solo existen de verdad en
  PostgreSQL.
- `RF-A10` (revocar sesiones activas) queda en P2. La tabla de tokens ya lo
  admite; falta la ruta.
```

---

### `docs/adr/ADR-015-proveedores-ia-tras-puertos.md`

```markdown
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
```

---

### `docs/adr/ADR-016-matriz-de-versiones.md`

```markdown
# ADR-016 · Matriz de versiones congelada

**Estado:** aceptada
**Fecha de verificación:** 29 de agosto de 2026
**Fase:** 0

## Contexto

RT-05 y la sección 19 del plan maestro exigen verificar cada versión el primer
día, comprobar la compatibilidad entre las piezas que dependen entre sí y
clavarlas en los archivos de bloqueo. Un número copiado de un documento escrito
semanas antes es una suposición, no una decisión.

## Decisión

Las versiones de esta tabla **no se copiaron de ningún documento**: se instalaron
y se leyeron del `package-lock.json` resultante. La fecha de verificación es la
de esa instalación.

### Herramientas del entorno

| Pieza | Versión verificada | Nota |
|---|---|---|
| Node.js | 22.15.0 | Fijada en `.nvmrc` y en las tres imágenes de contenedor |
| npm | 11.6.0 | Gestor del monorepo, ver más abajo |
| Docker | 29.6.1 | |
| Docker Compose | v5.1.4 | |
| Java | 21.0.9 LTS | Para compilar el backend generado (fase 2) |
| Maven | 3.9.9 | |
| Flutter | 3.44.2 (canal estable) | Aplicación móvil (fase 9) |

### Dependencias del monorepo

| Paquete | Versión resuelta |
|---|---|
| typescript | 5.9.3 |
| vitest | 3.2.7 |
| eslint | 10.9.1 |
| typescript-eslint | 8.68.0 |
| prettier | 3.9.6 |
| prisma | 7.10.0 |
| fastify | 5.12.1 |
| @fastify/cors | 10.1.0 |
| @fastify/cookie | 11.1.2 |
| zod | 3.25.76 |
| react / react-dom | 19.2.8 |
| vite | 6.4.3 |
| @vitejs/plugin-react | 4.7.0 |
| yjs | 13.6.32 |
| @hocuspocus/server | 4.6.0 |
| @hocuspocus/provider | 4.6.0 |
| y-protocols | 1.0.7 |
| jose | 6.2.10 |
| @prisma/client | 7.10.0 |
| @prisma/adapter-pg | 7.10.0 |
| @xyflow/react | 12.11.5 |
| zustand | 5.0.15 |
| react-router | 7.18.3 |
| @playwright/test | 1.62.1 |
| pg | 8.23.0 |
| handlebars | 4.7.9 |
| archiver | 8.0.0 |
| @anthropic-ai/sdk | 0.122.0 |
| tsx | 4.23.12 |

### Backend generado

| Pieza | Versión verificada |
|---|---|
| Spring Boot | 4.1.1 |
| springdoc-openapi | 3.1.0 |
| Java | 21.0.9 LTS |
| Maven | 3.9.9 |
| PostgreSQL | 17-alpine |

### Capa de datos Dart generada

| Pieza | Versión verificada |
|---|---|
| Dart SDK | 3.12.2 (stable) |
| `http` | ^1.2.0 |
| `sqflite` | ^2.3.0 |
| `lints` | ^5.0.0 |

Se verifican con `npm run test:dart`: la capa se genera para los siete modelos
generables del banco y cada una pasa `dart analyze --fatal-infos`.

Estas versiones se verifican con `npm run test:generated`: T01 se genera,
compila, arranca contra PostgreSQL y ejecuta su prueba HTTP completa.

### Imágenes de contenedor

| Servicio | Imagen |
|---|---|
| db | `postgres:17-alpine` |
| api / collab / web (construcción) | `node:22.15.0-alpine` |
| web (ejecución) | `nginx:1.27-alpine` |
| proxy | `caddy:2-alpine` |
| adminer | `adminer:5` |

## Tres decisiones que la verificación obligó a tomar

### npm workspaces en lugar de pnpm

La especificación de apoyo dejaba el gestor abierto («workspaces del gestor de
paquetes elegido»). `pnpm` no está instalado en las máquinas del equipo; npm 11
trae workspaces suficientes para ocho paquetes compartidos y tres aplicaciones,
y elimina un paso de arranque para cada integrante a tres semanas de la entrega.

Reversible sin coste: la estructura de carpetas y los `package.json` no cambian.

### Prisma 7.10.0, no la etiqueta `latest`

En npm, `latest` apunta hoy a `8.0.0-rc.12`, un **release candidate**. La última
versión de disponibilidad general es 7.10.0, publicada bajo la etiqueta `prev`.
Se fija 7.10.0 exacta, sin rango. Adoptar un RC a tres semanas de la defensa es
exactamente el riesgo que RT-05 pretende evitar.

Consecuencia práctica: Prisma 7 sacó la URL de conexión del archivo de esquema.
Vive en `prisma.config.ts` y se lee de `DATABASE_URL`.

### ESLint 10, no 9

`eslint@9` está en soporte de mantenimiento y npm avisa de ello en cada
instalación. `typescript-eslint@8.68.0` declara compatibilidad con `^10.0.0`, así
que se adopta la rama actual.

## Aviso de seguridad conocido y aceptado

`npm audit` reporta tres avisos de severidad alta, todos con el mismo origen:
`deepmerge-ts < 8.0.0`, alcanzado a través de `@prisma/config` desde el CLI de
Prisma. Es agotamiento de pila al fusionar grafos de objetos recursivos.

Se acepta porque el fallo está en el CLI de Prisma y solo procesa el archivo de
configuración y las migraciones del propio repositorio, que no son entrada no
confiable. El CLI es dependencia de desarrollo y queda en el target de un solo
uso con el que `migrate` ejecuta `prisma migrate deploy`; las imágenes finales de
HTTP y WebSocket solo copian el cliente generado. Prisma es además un peer
opcional de `@prisma/client`, por lo que esas imágenes omiten dependencias de
desarrollo y opcionales; `npm audit --omit=dev --omit=optional` queda sin
hallazgos. `npm audit fix --force` degradaría a `prisma@6`, un cambio mayor e
incompatible.

Revisado de nuevo tras las fases 3 y 7: Prisma 7.10.0 todavía resuelve la versión
afectada y npm sigue ofreciendo únicamente la degradación forzada a la rama 6.

## Regla permanente

Cualquier cambio de versión se hace instalando y actualizando esta tabla con la
nueva fecha de verificación. No se editan números a mano.
```

---

### `docs/adr/ADR-017-agente-movil-local.md`

```markdown
# ADR-017 · Agente móvil local con resolución determinista de entidades

- **Estado:** Aceptada
- **Fase:** 9
- **Fecha:** 2026-08-30

## Contexto

La aplicación móvil tiene que aceptar órdenes por voz y funcionar sin conexión
(RFM-03, RFM-04, CA-03.1). Hay tres formas de hacerlo y las tres se consideraron:

1. **Enviar la frase a un modelo de lenguaje en la nube.** Es lo más capaz y lo
   único que no se puede hacer: en modo avión no hay nube, y el requisito
   central de la demostración es precisamente el modo avión.
2. **Ejecutar un modelo de lenguaje pequeño en el teléfono.** Añade cientos de
   megabytes al paquete y segundos de latencia por frase, para un problema de
   cinco intenciones. Queda registrado como P2, no como carencia.
3. **Un clasificador entrenado fuera del dispositivo.** Es lo que se hizo.

También había que decidir quién convierte «Carlos Pérez» en un identificador de
fila. Es la parte donde un modelo generativo hace daño de verdad: un
identificador inventado tiene la forma correcta y es indistinguible de uno real
hasta que algo se rompe, lejos y más tarde.

## Decisión

**El modelo interpreta; el código resuelve los datos.**

- **Clasificación de intención:** bolsa de palabras (unigramas y bigramas) más
  regresión logística multinomial, entrenada por `npm run intents:train` y
  exportada como JSON de 27 kB. El teléfono solo multiplica una matriz por un
  vector. Seis clases: las cinco acciones y una **clase de rechazo** entrenada
  con frases que la aplicación no sabe hacer.
- **Resolución de entidades:** determinista, contra la base local, en Dart. El
  modelo produce un nombre; buscarlo es trabajo del código. Si hay una
  coincidencia, actúa; si hay varias, **pregunta**; si no hay ninguna, lo dice.
  Nunca inventa un identificador (CA-07.1).
- **Confirmación antes de crear:** dar de alta un cliente es lo único
  irreversible que hace el agente, y es justo donde el clasificador se equivoca
  («crea el cliente X» contra «busca el cliente X»). Equivocarse hacia una
  consulta no cuesta nada; hacia una creación deja basura en el catálogo de
  todos. Por eso se confirma.

## Por qué la clase de rechazo, y no solo un umbral

La primera versión tenía cinco clases y un umbral de confianza: por debajo de
0.45, «no entendí». No funciona, y la prueba lo demostró. Un softmax reparte
**toda** la probabilidad entre las clases que conoce, así que «cuánto cuesta un
pasaje a Santa Cruz» se parece más a una intención que a las otras cuatro y sale
con confianza alta. Rechazar requiere ejemplos de lo que hay que rechazar.

El umbral se mantiene como segunda red, no como la única.

## Consecuencias

**Medible.** 96.3% de acierto sobre 27 frases que no se usaron para entrenar
(RNF-11 exige 90% sobre al menos 20). El único fallo es «crea el cliente Tomas
Ruiz» → consulta, que es exactamente la confusión que la confirmación protege.

**Explicable en un minuto**, que es el criterio real: es un modelo entrenado, no
`if (texto.contains('registra'))`, y no un modelo de lenguaje del que no se puede
decir por qué respondió lo que respondió.

**Frágil en un punto conocido:** la tokenización está escrita dos veces, en
TypeScript para entrenar y en Dart para ejecutar. Si divergen, nada falla —el
modelo simplemente ve términos que no están en su vocabulario y acierta menos,
en silencio. Por eso el entrenador escribe cómo tokeniza cada frase del corpus y
una prueba de Dart lo compara término a término.

**Lo que no cubre ninguna prueba automática:** que el reconocedor de voz del
teléfono transcriba bien en español **y sin conexión**. `onDevice: true` pide el
modelo local, pero si el motor instalado no lo tiene descargado, Android cae al
reconocimiento por red y la demostración en modo avión se queda muda. Se
comprueba en el teléfono real que se llevará al examen; el emulador no sirve.

Relacionado: [ADR-011](ADR-011-generacion-limitada-capa-datos.md),
[ADR-013](ADR-013-uuid-para-creacion-sin-conexion.md) y
[ADR-015](ADR-015-proveedores-ia-tras-puertos.md) (en el servidor los
proveedores van tras puertos; aquí no hay proveedor que abstraer).

## Retirada del 5 de septiembre de 2026

**Superada.** La herramienta ya no emite ningún artefacto para el cliente móvil:
la generación queda en el backend Spring Boot con PostgreSQL, más su colección
de Postman. `shared/generator-dart` y `templates/dart` se retiraron del
repositorio, con la aplicación de referencia que vivía en `mobile/`.

La aplicación que consuma el backend generado se construye entera aparte. Esta
decisión queda como registro de por qué en su momento se generó solo la capa de
datos y no las pantallas; el razonamiento sigue siendo válido si algún día se
retoma. Recuperable con `git checkout <commit> -- shared/generator-dart templates/dart`.
```

---

### `docs/adr/ADR-018-artefactos-no-se-almacenan.md`

```markdown
# ADR-018 · Los artefactos generados no se almacenan; se congela el snapshot

- **Estado:** Aceptada
- **Fase:** 10
- **Fecha:** 2026-08-30

## Contexto

Al conectar el generador con la interfaz había que decidir qué persiste una
generación. Lo evidente es guardar el ZIP: alguien pulsa «generar», el archivo
queda en algún sitio y se descarga cuando haga falta.

Guardar el binario obliga a decidir **dónde** —columna de la base, disco del
contenedor, almacenamiento de objetos—, a limpiarlo, y a que el proceso HTTP deje
de ser reemplazable sin más. Un proyecto Spring Boot de siete entidades pesa
decenas de kilobytes, pero cada generación de cada pizarra de cada proyecto se
acumula, y nadie va a escribir la rutina de limpieza tres semanas antes de la
defensa.

## Decisión

**No se guarda el artefacto. Se guarda la versión del modelo con la que se
generó, y el artefacto se vuelve a emitir cuando se descarga.**

Esto solo es válido porque la emisión es determinista (RA-07): mismas plantillas,
misma representación intermedia, y fechas fijas dentro del ZIP. Del mismo
snapshot salen siempre los mismos bytes — hay una prueba que descarga dos veces y
compara.

Para que «la misma versión» signifique algo, generar **copia** la proyección viva
a una versión nueva e inmutable:

| Versión | Qué es | Quién la escribe |
|---|---|---|
| 1 | La proyección vigente de la pizarra | El proceso de colaboración, con retardo |
| 2, 3, … | Copias congeladas para generación (RA-08) | El proceso HTTP, al pulsar «generar» |

Y antes de copiar, el proceso HTTP le pide al de colaboración que escriba el
documento vivo. Si esa llamada falla, **no se genera**: se responde un 503.

## Enmienda del 30 de agosto de 2026 · el snapshot no era suficiente

La decisión se sostenía en una frase que no era del todo cierta: «del mismo
snapshot salen siempre los mismos bytes». El snapshot es **una** de las entradas
de la emisión, no todas. Faltaban tres, y las tres se notaban:

| Entrada | Qué pasaba | Consecuencia |
|---|---|---|
| `basePackage` | Se usaba para responder y no se guardaba | **Todas** las descargas salían con el paquete por defecto, aunque la persona hubiera escrito el suyo |
| Nombre del proyecto | Se releía de la pizarra al descargar | Renombrar la pizarra cambiaba el artefacto de una generación anterior |
| Plantillas | Podían cambiar por debajo | La descarga de la semana siguiente entregaba otros bytes bajo el mismo identificador |

El primero es un defecto silencioso: la interfaz aceptaba el paquete, respondía
con él, y el ZIP no lo llevaba. La prueba que existía comprobaba que la petición
se aceptaba — no que el código generado lo tuviera.

**Cada generación congela ahora un manifiesto:** nombre de proyecto,
`artifactId`, `basePackage`, versión del esquema canónico, huella de las
plantillas, estado y el **SHA-256 de cada objetivo**. La descarga reconstruye con
el manifiesto, nunca releyendo la pizarra.

**Y se comprueba.** Al descargar se compara el SHA-256 de lo que se acaba de
emitir con el que se registró. Si no coinciden, se responde 409 y se dice por
qué, en lugar de entregar un archivo distinto bajo el mismo identificador. Es lo
que hace verificable la promesa de esta ADR en vez de simplemente afirmarla.

Esa comprobación exige que la emisión sea determinista: si alguien mete una fecha
o un identificador aleatorio en una plantilla, **toda** descarga posterior se
rechazaría. La prueba de bytes idénticos está para que eso se note enseguida.

**El estado se registra antes de darlo por bueno.** La fila nace `CREATING`, se
emiten los dos objetivos, y solo entonces pasa a `READY` con sus huellas. Si la
emisión falla queda `FAILED` con el motivo saneado. Antes se registraba el éxito
sin comprobarlo: una generación podía figurar en el historial y fallar al
descargarla.

**Lo que sigue sin almacenarse es el ZIP.** El manifiesto son unos cientos de
bytes por generación.

## Consecuencias

**A favor.** La base guarda una fila por generación —quién, cuándo, sobre qué
versión, que es lo que pide RF-072— y ningún binario. Descargar el mismo
artefacto dentro de un mes da el mismo archivo. CA-060.1 se cumple por
construcción: quien siga editando escribe sobre la versión 1, y el ZIP
corresponde a la copia.

**En contra.** Descargar cuesta lo que cuesta generar, unas decenas de
milisegundos para los modelos del banco. Y la emisión tiene que seguir siendo
determinista: si alguien mete una fecha o un identificador aleatorio en una
plantilla, dos descargas dejarían de coincidir. La prueba que las compara está
para que eso se note enseguida.

**Lo que arregló.** La primera versión leía «la última versión del snapshot», que
era la 1 — la que el proceso de colaboración reescribe. Descargar dos días
después habría dado un proyecto distinto, y generar justo después de dibujar una
clase daba un proyecto sin esa clase, porque la proyección se guarda con retardo.
Los dos fallos se vieron generando desde el navegador, no leyendo el código.

Relacionado: [ADR-007](ADR-007-generacion-por-ir-y-plantillas.md) (la emisión es
determinista y por plantillas) y
[ADR-004](ADR-004-varias-pizarras-generacion-seleccionada.md) (se genera sobre
una pizarra seleccionada).
```

---

### `docs/adr/ADR-019-pasarela-ia-credenciales-y-respaldo.md`

````markdown
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
````

---

### `docs/adr/ADR-020-generalizacion-tabla-por-clase.md`

````markdown
# ADR-020 · La generalización se genera como tabla por clase unida por la clave

- **Estado:** Aceptada
- **Fase:** posterior a la 10
- **Fecha:** 2026-09-03

## Contexto

La versión 2.0 del plan maestro excluía la herencia: aparecía en la lista de
fuera de alcance y `INHERITANCE_PRESENT` figuraba entre los errores de CA-017.1.

La realidad del repositorio era otra. El editor ya ofrecía las cuatro relaciones
UML —asociación, generalización, composición y agregación—, cada una con su
notación: el triángulo hueco de la generalización se dibujaba en el lienzo, el
inspector explicaba que «el origen es la subclase y el destino la superclase», y
el serializador XMI la emitía como `<generalization>` para Enterprise Architect.
`INHERITANCE_PRESENT` estaba declarado y **nadie lo emitía**.

Lo que faltaba era lo de después. Una generalización se proyectaba como una
clave foránea más: `Estudiante` recibía un campo `persona` y una columna
`persona_id`, exactamente igual que si alguien hubiera dibujado una asociación
1:1. El diagrama decía una cosa y el proyecto Spring Boot decía otra.

Eso es peor que no soportarla. Un usuario que dibuja el triángulo, genera y abre
el ZIP encuentra código que no corresponde a su modelo, y nada se lo advierte:
compila, arranca y guarda filas.

## Decisión

**La generalización se proyecta a tabla por clase unida por la clave primaria**
(`InheritanceType.JOINED`), y deja de producir clave foránea.

```java
@Entity @Table(name = "persona")
@Inheritance(strategy = InheritanceType.JOINED)
public class Persona { @Id private UUID id; private String nombre; }

@Entity @Table(name = "estudiante")
@PrimaryKeyJoinColumn(name = "id")
public class Estudiante extends Persona { private String matricula; }
```

De las tres estrategias de JPA es la única que conserva **lo que el modelo
conceptual dice**: cada clase tiene sus columnas en su propia tabla, sin columnas
nulas para las que no le corresponden —tabla única con discriminador— y sin
repetir las de la superclase en cada hija —tabla por clase concreta—. Es también
la que se parece a lo que alguien dibujaría a mano normalizando.

Cuatro decisiones se derivan de ahí, y las cuatro están en RTM-13:

| Decisión | Por qué |
|---|---|
| La clave primaria sale de la **raíz** de la jerarquía | Es la columna por la que se unen todas las tablas de la cadena. Con dos niveles daría igual; con tres, no |
| La subclase no vuelve a declarar nada heredado | Un segundo `@Id`, o un campo repetido, compila y rompe el arranque de Hibernate |
| El DTO y el servicio sí trabajan con la entidad completa | Crear un estudiante por su propia ruta tiene que poder mandar el nombre, que vive en `persona` |

**Y el validador gana cuatro errores**, que son los que la proyección no puede
absorber: una clase que se generaliza a sí misma, dos superclases —Java tiene
una—, un ciclo, y un miembro declarado que tapa a otro heredado. Los cuatro
bloquean la generación porque los cuatro producen código que compila y falla
después. `INHERITANCE_PRESENT` se retiró: ya no describe nada.

## Consecuencias

**A favor.** El triángulo del lienzo significa lo mismo que el `extends` del
ZIP. El asistente por texto y voz puede crear una jerarquía —«Estudiante hereda
de Persona»—, la importación por fotografía puede leer un triángulo, y el XMI
sigue redondeando contra Enterprise Architect como antes.

**En contra.** Una consulta a una subclase es una unión, y la colección de una
superclase devuelve también las filas de sus hijas: `GET /api/persona` con un
estudiante dado de alta devuelve dos registros. Es semántica correcta de JPA
—una subclase **es** una superclase— pero sorprende la primera vez, y obligó a
enseñársela a la propia Definition of Done, que contaba una fila donde la
jerarquía produce cuatro.

**Cómo se comprueba.** T08 entró al banco de regresión: tres niveles de cadena,
dos hermanas, una clave foránea heredada y otra que apunta a una subclase. Pasa
la DoD completa de la sección 15.1: compila con Maven, arranca contra PostgreSQL
limpio, altas en orden topológico, reinicio y `409` al borrar un padre con hijos.

**Efecto sobre las generaciones anteriores.** `entity.java.hbs` cambió, así que
la huella de plantillas cambió con él. Una generación registrada antes de esta
decisión ya no se puede reproducir byte a byte, y al descargarla se responde
`409` diciendo por qué, en lugar de entregar un archivo distinto bajo el mismo
identificador. Es exactamente el caso para el que
[ADR-018](ADR-018-artefactos-no-se-almacenan.md) puso esa comprobación: quien la
necesite vuelve a generar desde la pizarra.

**Lo que sigue fuera.** Herencia múltiple, clases abstractas, interfaces y
métodos. Y las otras dos estrategias de JPA: elegirlas por modelo sería una
decisión de persistencia dentro del modelo conceptual, que es justo lo que
[ADR-003](ADR-003-modelo-canonico-comandos-lotes.md) mantiene fuera.

Relacionado: [ADR-007](ADR-007-generacion-por-ir-y-plantillas.md) (la
representación intermedia es donde viven las decisiones de persistencia),
[ADR-008](ADR-008-dto-planos-relaciones-unidireccionales.md) (por qué el DTO es
plano) y
[ADR-005](ADR-005-entidad-intermedia-muchos-a-muchos.md) (la otra construcción
UML que el generador no proyecta tal cual).
````

---

### `docs/adr/README.md`

```markdown
# Registro de decisiones de arquitectura

Una página por decisión. Sirven directamente para responder en la defensa.

El plan maestro (sección 17) exige dieciséis. Se escriben cuando la decisión se
toma de verdad, no antes: un ADR redactado sobre una decisión que todavía no se
ejecutó es una intención, no un registro.

| ADR | Decisión | Estado | Fase |
|---|---|---|---|
| [ADR-001](ADR-001-monolito-modular-dos-procesos.md) | Monolito modular con dos procesos, no microservicios | Aceptada | 0 |
| [ADR-002](ADR-002-crdt-para-colaboracion.md) | CRDT para la colaboración en tiempo real | Aceptada | 4 |
| [ADR-003](ADR-003-modelo-canonico-comandos-lotes.md) | Modelo canónico único con comandos y lotes atómicos | Aceptada | 1 |
| [ADR-004](ADR-004-varias-pizarras-generacion-seleccionada.md) | Varias pizarras, generación sobre una pizarra seleccionada | Aceptada | 3 |
| [ADR-005](ADR-005-entidad-intermedia-muchos-a-muchos.md) | Entidad intermedia explícita para muchos a muchos | Aceptada | 1 |
| [ADR-006](ADR-006-sin-event-sourcing-ni-cqrs.md) | Sin event sourcing ni CQRS completo | Aceptada | 2 |
| [ADR-007](ADR-007-generacion-por-ir-y-plantillas.md) | Generación por representación intermedia y plantillas | Aceptada | 2 |
| [ADR-008](ADR-008-dto-planos-relaciones-unidireccionales.md) | DTO planos y relaciones unidireccionales | Aceptada | 2 |
| [ADR-009](ADR-009-runtime-compartido.md) | Runtime compartido entre navegador y servidor | Aceptada | 1 |
| [ADR-010](ADR-010-docker-compose-iac-diferida.md) | Docker Compose, infraestructura como código diferida | Aceptada | 0 |
| [ADR-011](ADR-011-generacion-limitada-capa-datos.md) | Generación limitada a la capa de datos del cliente móvil | **Superada** | 6 |
| [ADR-012](ADR-012-importacion-como-candidato-editable.md) | Toda importación produce un candidato editable | Aceptada | 8 |
| [ADR-017](ADR-017-agente-movil-local.md) | Agente móvil local con resolución determinista de entidades | **Superada** | 9 |
| [ADR-013](ADR-013-uuid-para-creacion-sin-conexion.md) | Creación sin conexión requiere clave primaria UUID | Aceptada | 9 |
| [ADR-014](ADR-014-autenticacion-propia-minima.md) | Autenticación propia mínima con roles por proyecto | Aceptada | 3 |
| [ADR-015](ADR-015-proveedores-ia-tras-puertos.md) | Proveedores de IA detrás de puertos intercambiables | Aceptada | 7 |
| [ADR-016](ADR-016-matriz-de-versiones.md) | Matriz de versiones congelada, con fecha de verificación | Aceptada | 0 |
| [ADR-018](ADR-018-artefactos-no-se-almacenan.md) | Los artefactos no se almacenan; se congela el snapshot | Aceptada | 10 |
| [ADR-019](ADR-019-pasarela-ia-credenciales-y-respaldo.md) | Pasarela de IA: credenciales por proveedor y respaldo por puerto | Aceptada | 7 |
| [ADR-020](ADR-020-generalizacion-tabla-por-clase.md) | La generalización se genera como tabla por clase unida por la clave | Aceptada | — |
```

---

## Arquitectura

### Estructura

```text
docs/architecture/
`-- README.md
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `docs/architecture/README.md` | 100 |

---

### `docs/architecture/README.md`

````markdown
# Arquitectura

El detalle vive en la sección 4 del [plan maestro](../referencia/plan-integral-plataforma-uml.md).
Aquí solo queda lo que un integrante necesita tener presente al escribir código.

## Principio rector

Todas las entradas modifican un **único modelo UML canónico** mediante lotes de
comandos atómicos. Colaboración, IA, imagen, XMI y generación son adaptadores
alrededor de ese núcleo.

Si esa pieza está bien hecha, las seis funcionalidades se conectan al mismo
centro. Si está mal hecha, habrá seis implementaciones peleándose por ser la
verdad.

## Flujo de una modificación

```
GUI · texto · voz · imagen · XMI
              ↓
     Propuesta de lote
              ↓
     Resolución estructural (desambiguación)
              ↓
         Validación            ← si hay un solo error, no se aplica nada
              ↓
    Aplicador de comandos
              ↓
  Documento colaborativo (transacción única)
              ↓
   ┌──────────┴──────────┐
   ↓                     ↓
Actualización        Snapshot inmutable
incremental                ↓
a los demás         Representación intermedia
                           ↓
                    Plantillas → ZIP
```

## Restricciones que no se negocian

Las quince restricciones arquitectónicas están en la sección 4.8 del plan
maestro. Las que más se olvidan al escribir código:

- **RA-03** — Lotes transaccionales: todo o nada. La validación ocurre **antes**
  de aplicar; la transacción del documento agrupa el cambio para que produzca una
  sola actualización, no como mecanismo de deshacer.
- **RA-04** — Identidad UUID interna independiente del nombre. Renombrar nunca
  rompe una relación.
- **RA-05** — Aplicador y validador: una implementación, dos lugares de ejecución.
- **RA-06** — El asistente dispone de vocabulario cerrado. Nunca mutación
  arbitraria.
- **RA-07** — Generación determinista por plantillas. Ningún modelo de lenguaje
  escribe Java.
- **RA-08** — La generación opera sobre snapshot inmutable, no sobre estado vivo.
- **RA-11** — El documento colaborativo se persiste en su representación binaria
  nativa. El JSON canónico es proyección derivada y **nunca** reconstruye el
  documento.
- **RA-12** — La colaboración garantiza convergencia estructural, no validez
  semántica. Dos usuarios pueden converger en un modelo inválido; el validador lo
  marca antes de permitir generar.
- **RA-15** — Toda conexión al servidor de colaboración se autentica y autoriza
  antes de unirse a una sala. Proteger solo las rutas HTTP no sirve de nada.

## Fuentes de verdad

| Representación | Responsabilidad |
|---|---|
| Esquema canónico | Contrato semántico: qué significa el estado |
| Documento colaborativo | Estado vivo replicado |
| Layout | Posición y viewport, sin valor semántico |
| PostgreSQL | Persistencia durable y metadatos |
| Snapshot de generación | Entrada inmutable al generador |
| Representación intermedia | Traducción temporal para emitir código |

El editor visual siempre es una **proyección** del documento, nunca la fuente de
verdad.

## Despliegue

```
                    Navegador
              React + editor + documento
                        │
              ┌─────────┴─────────┐
            HTTPS               WSS
              ↓                   ↓
         ┌──────────┐      ┌─────────────┐
         │   api    │      │   collab    │
         │ :3001    │      │ :3002       │
         └────┬─────┘      └──────┬──────┘
              └──────────┬────────┘
                         ↓
                    PostgreSQL
```

Con el perfil `demo`, Caddy queda delante y expone un único origen en el puerto
80: `/api/*` al proceso HTTP, `/collab/*` al de colaboración, el resto a la
interfaz.
````

---

## Requisitos

### Estructura

```text
docs/requirements/
`-- README.md
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `docs/requirements/README.md` | 43 |

---

### `docs/requirements/README.md`

```markdown
# Requisitos

La lista completa vive en el [plan maestro](../referencia/plan-integral-plataforma-uml.md),
secciones 5.6 y 9 a 12. No se duplica aquí para que no puedan divergir.

## Cómo leer los códigos

**Procedencia** — `DOC` pedido por el docente · `DER` derivado, necesario para
cumplir uno del docente · `PROY` alcance propio · `OPT` mejora opcional.

**Prioridad** — `P0` sin esto falla la demostración · `P1` necesario para una
demostración confiable · `P2` posterior al núcleo · `P3` fuera del parcial.

Procedencia y prioridad son independientes. Un requisito `DER` puede ser `P0`:
que el docente no lo haya verbalizado no significa que se pueda postergar.

**Otros bloques** — `CA` criterio de aceptación · `RNF` requisito no funcional ·
`RT` restricción tecnológica · `RA` restricción arquitectónica · `RM` regla de
modelado · `RTM` regla de transformación · `FA` fuera de alcance.

## Trazabilidad por fase

| Fase | Requisitos que cierra |
|---|---|
| 0 | RNF-12 (un solo comando), RNF-13 (base de CI), RNF-15 (base del aislamiento del dominio) |
| 1 | RM-01 a RM-07, RTM-01 a RTM-04, RF-017 |
| 2 | Spike técnico de RF-061 a RF-068 sobre T01, RTM-05 a RTM-13, RNF-05, RNF-07 |
| 3 | RF-A01 a RF-A07, RF-001 a RF-005 |
| 4 | RF-020 a RF-026, RF-A08 y atribución en memoria de RF-A09, RNF-01, RNF-02 |
| 5 | RF-010 a RF-016, RNF-03, RNF-04 |
| 6 | RF-069 a RF-071 |
| 7 | RF-030 a RF-037 |
| 8 | RF-040 a RF-044, RF-050 a RF-052 |
| 9 | Histórico: RFM-01 a RFM-12, RNF-09 a RNF-11; módulo móvil retirado del alcance ejecutable actual |
| 10 | Integración de RF-060/RF-072, persistencia de RF-A09 y guion de ensayo de la sección 16.2 |

La atribución viaja en cada lote y se persiste en `audit_operations`; el cliente
mantiene además una cola reintentable y el servidor deduplica por pizarra y lote.
RF-060 y RF-072 están integrados: la API congela el snapshot y el manifiesto, y
la interfaz descarga el backend, también desde el historial. Siguen abiertas
las validaciones externas y el robustecimiento detallado en
[`actualizacion.md`](../actualizacion.md).
```

---

## Plan maestro

### Estructura

```text
docs/referencia/
|-- especificacion-herramienta-uml-colaborativa.md
`-- plan-integral-plataforma-uml.md
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `docs/referencia/especificacion-herramienta-uml-colaborativa.md` | 867 |
| `docs/referencia/plan-integral-plataforma-uml.md` | 1286 |

---

### `docs/referencia/especificacion-herramienta-uml-colaborativa.md`

````markdown
# Herramienta colaborativa de diseño de bases de datos

Especificación definitiva de requisitos y arquitectura — Primer parcial
Entrega: 23 de septiembre
Versión: 1.0 · Alcance congelado

---

## 0. Cómo leer este documento

Cada requisito lleva dos atributos independientes.

**Procedencia** — de dónde viene:
- `OBL` el docente lo pidió
- `DER` derivado, necesario para cumplir un OBL
- `OPT` mejora propia del equipo

**Prioridad** — cuándo se construye:
- `P0` sin esto falla la demostración
- `P1` hace confiable la demostración
- `P2` después del núcleo
- `P3` fuera del parcial

Un requisito `DER` puede ser `P0`. La procedencia indica origen, la prioridad indica orden de construcción. Confundirlas lleva a postergar cosas que sostienen requisitos críticos.

Otros bloques: `CA` criterio de aceptación · `RNF` requisito no funcional · `RT` restricción tecnológica · `RA` restricción arquitectónica · `RM` regla de modelado · `RTM` regla de transformación · `FA` fuera de alcance.

---

## 1. Definición del producto

Herramienta web colaborativa de modelado conceptual de datos basada en un subconjunto de diagramas de clases UML, editable mediante interfaz gráfica y mediante un agente de IA por texto y voz, interoperable con Enterprise Architect vía XMI, capaz de generar un backend Spring Boot con PostgreSQL listo para ejecutar.

No es un modelador UML general. No sustituye a Enterprise Architect: se integra con él.

Como validación del backend generado, el equipo construye en vivo una aplicación móvil Flutter con interfaz de voz, IA local y operación sin conexión.

### Flujo del producto

```
Requerimientos → Modelo conceptual → Backend Spring Boot → PostgreSQL → App Flutter
```

### Tres aclaraciones de alcance

**Múltiples pizarras.** Un usuario tiene tantos proyectos como quiera, cada uno con su pizarra colaborativa. Lo que no cambia es que un proyecto contiene un único diagrama principal: es lo que hace determinista la generación y evita tener que preguntar cuál diagrama se genera.

**Generación del frontend Flutter.** Fuera de alcance. El docente dijo explícitamente que no verá aplicaciones móviles generadas por la herramienta. Un segundo generador cuesta tanto como el primero y compite con el que sí se evalúa. Lo que sí entra, como P2, es generar un cliente Dart tipado a partir del contrato OpenAPI del backend: modelos y llamadas listos para usar, que aceleran el frontend que el equipo escribe en vivo sin construir un generador de aplicaciones.

**IA local en la herramienta.** Fuera de alcance. El enunciado acota la IA local a la aplicación móvil. Un modelo local en la herramienta degradaría la interpretación de comandos justo donde se necesita precisión, sin aportar nada evaluable. El plan de contingencia ante una caída de red es la interfaz gráfica, que funciona siempre.

---

## 2. Restricciones tecnológicas

| ID | Restricción |
|---|---|
| RT-01 | El backend generado se implementa en Spring Boot |
| RT-02 | La persistencia del backend generado es PostgreSQL |
| RT-03 | La aplicación móvil de demostración se implementa en Flutter |
| RT-04 | El proyecto generado usa Maven exclusivamente. No se soporta Gradle |
| RT-05 | Versiones fijadas e idénticas a las del banco de regresión. Se verifica al arrancar cuál es la rama estable con mayor volumen de documentación disponible y se clava en el `pom.xml` y en el lockfile. Se registra la combinación exacta en un ADR con fecha. No copiar números de versión de un documento escrito semanas antes |
| RT-06 | El backend generado no usa Lombok. El generador emite getters y setters completos, para que el proyecto abra sin errores en un IDE sin plugins |
| RT-07 | Verificar qué JDK tiene la máquina donde el docente abrirá el proyecto. Es el único dato del entorno que el equipo no controla |

Todo lo demás — React, Node, Yjs, Fastify — es elección del equipo y no debe atribuirse al docente.

---

## 3. Restricciones arquitectónicas

| ID | Restricción |
|---|---|
| RA-01 | Existe un único modelo UML canónico. Toda entrada (GUI, texto, voz, imagen, XMI) es un adaptador que produce comandos sobre ese modelo |
| RA-02 | Toda modificación se expresa como operación incremental. Durante la edición se transmiten deltas; un cliente que se incorpora recibe un snapshot inicial y luego solo actualizaciones |
| RA-03 | Los comandos se agrupan en lotes transaccionales. Se valida el lote completo y se aplica todo o nada |
| RA-04 | Cada elemento tiene identidad UUID interna independiente de su nombre. Renombrar nunca rompe relaciones |
| RA-05 | El aplicador de comandos y el validador son una única implementación compartida entre navegador y servidor |
| RA-06 | El agente de IA dispone de un vocabulario cerrado de comandos. Nunca recibe capacidad de mutación arbitraria del modelo |
| RA-07 | La generación de código es determinista por plantillas. No se usa un modelo de lenguaje para escribir Java |
| RA-08 | La generación opera sobre un snapshot inmutable, no sobre el estado vivo |
| RA-09 | El modelo persistido declara la versión de su esquema canónico |
| RA-10 | La sincronización del diagrama (CRDT) y la de datos de la app móvil (cola offline) son mecanismos distintos y no comparten protocolo |
| RA-11 | Cinco representaciones con roles distintos: modelo canónico (semántica), layout (visual), documento CRDT (colaboración), persistencia (recuperación), snapshot (entrada al generador) |
| RA-12 | El documento colaborativo se persiste en su representación binaria nativa. El JSON canónico es una proyección derivada y nunca se usa para reconstruir el documento: hacerlo produce duplicaciones al fusionar |
| RA-13 | Un lote validado se aplica dentro de una única transacción del documento, etiquetada con identificador de lote y origen, produciendo una sola actualización para los demás participantes |
| RA-14 | La colaboración garantiza convergencia estructural, no validez semántica. La validez se evalúa de forma continua e informativa, y estricta y bloqueante antes de generar |
| RA-15 | Entre el modelo canónico y las plantillas existe una representación intermedia de generación. Ahí viven las decisiones de persistencia que no pertenecen al modelo conceptual |

---

## 4. Reglas de modelado

| ID | Regla |
|---|---|
| RM-01 | Toda relación muchos-a-muchos se modela mediante clase intermedia explícita con dos relaciones N:1. La herramienta ofrece crearla automáticamente al detectar una N:M |
| RM-02 | Las relaciones directas se soportan únicamente entre dos clases. Tres o más participantes se modelan como entidad |
| RM-03 | Las claves primarias son de un solo atributo. No se soportan claves compuestas |
| RM-04 | Multiplicidades soportadas: `1`, `0..1`, `0..*`, `1..*` |
| RM-05 | Un proyecto contiene un único diagrama de clases principal. Un usuario puede tener múltiples proyectos |
| RM-06 | Las entidades que participan en creación sin conexión deben tener clave primaria UUID |

---

## 5. Reglas de transformación

### RTM-01 — Tipos de datos

| Conceptual | Java | PostgreSQL |
|---|---|---|
| String | `String` | `VARCHAR(255)` |
| Integer | `Integer` | `INTEGER` |
| Long | `Long` | `BIGINT` |
| Decimal | `BigDecimal` | `NUMERIC(19,2)` |
| Boolean | `Boolean` | `BOOLEAN` |
| Date | `LocalDate` | `DATE` |
| DateTime | `LocalDateTime` | `TIMESTAMP` |
| UUID | `UUID` | `UUID` |

Longitud de `String` y precisión de `Decimal` configurables por atributo: P2.

### RTM-02 — Nombres

Cada elemento lleva tres nombres:

| Campo | Contenido | Ejemplo |
|---|---|---|
| `displayName` | Lo que escribe el usuario. Admite espacios, tildes, ñ | `Número de Teléfono` |
| `codeName` | Identificador Java válido | `numeroTelefono` |
| `databaseName` | Identificador PostgreSQL en snake_case | `numero_telefono` |

Clases: `Detalle de Venta` → `DetalleVenta` → `detalle_venta`.

Pipeline obligatorio: nombre visual → normalización → validación de identificador → **detección de colisión** → nombre técnico.

La unicidad se valida sobre `codeName` y `databaseName`, nunca sobre `displayName`. `Número` y `Numero` colapsan al mismo identificador: es ERROR.

### RTM-03 — Palabras reservadas

Se validan tres listas: reservadas de Java, reservadas de PostgreSQL, y nombres reservados del generador (la clase principal de la aplicación, por ejemplo).

Si `databaseName` es reservada en PostgreSQL se antepone `app_`:

```
order → app_order
user  → app_user
```

No se usan identificadores entre comillas: dejan la tabla permanentemente sensible a mayúsculas y complican cualquier consulta manual.

### RTM-04 — Clave primaria

```
1. ¿Atributo marcado como PK?                    → usarlo
2. ¿Un solo candidato por convención             → promoverlo + WARNING
   (id, id<Clase>, <clase>Id)?
3. ¿Dos o más candidatos?                        → ERROR, el usuario elige
4. Ninguno                                       → generar id : UUID + WARNING
```

La inferencia es deliberadamente estrecha. `ci`, `nit`, `codigoCliente` no se promueven: son identificadores de negocio, no necesariamente claves técnicas. La herramienta no inventa semántica.

### RTM-05 — Relaciones a JPA

Solo se genera el lado propietario:

| Modelo | Java generado |
|---|---|
| `Cliente 1 ── N Venta` | `Venta` recibe `@ManyToOne Cliente cliente` |
| `Cliente 1 ── 1 Perfil` | `Perfil` recibe `@OneToOne Cliente cliente` |
| N:M | No existe. Resuelto por RM-01 |

No se genera colección inversa, `mappedBy`, `cascade` ni `orphanRemoval`. La clave foránea queda igual de correcta y desaparecen los ciclos, la propiedad bidireccional y las colecciones perezosas.

**Nombre del campo.** Si la relación tiene rol, se usa el rol. Si no, se deriva del `codeName` de la clase destino. Si existen dos relaciones entre el mismo par de clases y ninguna tiene rol, los campos colisionarían: es ERROR de validación.

**Compensación de la ausencia de colección inversa.** Por cada clave foránea el generador emite un finder derivado con navegación explícita de propiedad:

```java
List<Venta> findByCliente_Id(UUID clienteId);
```

expuesto como `GET /api/venta?clienteId={uuid}`. Sin esto no habría forma de consultar las ventas de un cliente, que es exactamente lo que la app móvil necesita.

### RTM-06 — Opcionalidad derivada de la multiplicidad

| Multiplicidad del destino | Java generado | Columna |
|---|---|---|
| `1` | `@ManyToOne(optional = false)` | `NOT NULL` |
| `0..1` | `@ManyToOne(optional = true)` | `NULL` |

Marcadores del atributo:

| Marcador | Java generado |
|---|---|
| `nullable = false` | `@Column(nullable = false)` |
| `unique = true` | `@Column(unique = true)` |

### RTM-07 — Propietario en relaciones uno a uno

En una relación `1:1` la clave foránea la recibe siempre la clase destino. `Persona 1 ── 1 Perfil` produce `perfil.persona_id`.

La elección es arbitraria; lo que importa es que sea invariable. Vive en la representación intermedia de generación, no en el modelo canónico.

### RTM-08 — Convención REST

```
GET    /api/{recurso}
GET    /api/{recurso}/{id}
GET    /api/{recurso}?{fk}={uuid}
POST   /api/{recurso}
PUT    /api/{recurso}/{id}
DELETE /api/{recurso}/{id}
```

`{recurso}` es el `codeName` en kebab-case y **singular**: `Cliente` → `cliente`, `DetalleVenta` → `detalle-venta`, `Order` → `order`.

Singular para eliminar la pluralización del español, que introduce irregulares sin aportar nada. Derivado del `codeName` y no del `databaseName` para que el prefijo `app_` no se filtre a las URL.

### RTM-09 — DTO

Un DTO plano por entidad, para entrada y salida. Las relaciones se expresan como identificador, nunca como objeto anidado.

```java
public record VentaDTO(UUID id, LocalDate fecha, BigDecimal total, UUID clienteId) {}
```

Esto elimina por construcción los ciclos de serialización. No se usan anotaciones de referencia gestionada: ocultan el ciclo pero también el dato, y la app móvil terminaría recibiendo ventas sin cliente.

No se generan DTO separados de petición y respuesta. Uno por entidad.

### RTM-10 — Borrado y traducción de errores

Las claves foráneas se generan con integridad referencial restrictiva. No hay borrado en cascada.

La restricción por sí sola no produce la respuesta correcta: sin traducción, una violación de integridad sale como `500`. El generador emite un manejador global de excepciones fijo:

| Excepción | Respuesta |
|---|---|
| Violación de integridad referencial | `409 Conflict` |
| Entidad no encontrada | `404 Not Found` |
| Validación de campos fallida | `400 Bad Request` |

Con cuerpo de error uniforme. Es P0: sin ello el criterio del `409` del banco no se cumple.

### RTM-11 — Identificadores del cliente e idempotencia

Consecuencia de la decisión de UUID de extremo a extremo:

1. La clave primaria UUID se declara **sin** `@GeneratedValue`. Si la llevara, el identificador enviado por el cliente se ignoraría o dispararía una actualización en lugar de un alta.
2. El servicio asigna un UUID nuevo solo si la petición no trae uno.
3. `POST` sobre un identificador existente devuelve `200` con el recurso existente. No duplica ni falla.

El punto 3 es lo que hace idempotentes las creaciones: un reintento tras un tiempo de espera agotado devuelve el mismo registro. No hace falta tabla de operaciones procesadas ni interceptor de cabecera. Las demás operaciones ya son idempotentes por naturaleza.

**Condición de aplicabilidad.** Depende de que la clave primaria sea UUID asignable por el cliente. Si el modelo define `idCliente : Long [PK]`, el backend funciona con identificadores del servidor y este mecanismo no aplica. Por eso RM-06. La correspondencia entre identificador local y de servidor para claves no UUID queda fuera de alcance, declarada como limitación conocida.

### RTM-12 — Paquete y artefacto

```
Proyecto:  Sistema de Ventas
codeName:  sistemaVentas
artifact:  sistema-ventas
paquete:   bo.edu.sw1.sistemaventas
```

Completamente determinista. Nunca decidido por un modelo de lenguaje.

---

## 6. Requisitos funcionales — Herramienta

### M1 · Proyecto y editor

| ID | Requisito | Proc. | Prio. |
|---|---|---|---|
| RF-01 | Crear, abrir, listar, guardar y reanudar proyectos. Cada proyecto es una pizarra independiente | DER | P0 |
| RF-02 | Crear, renombrar, mover y eliminar clases | OBL | P0 |
| RF-03 | Agregar, modificar y eliminar atributos con tipo, PK, nullable y unique | OBL | P0 |
| RF-04 | Crear, modificar y eliminar relaciones entre clases | OBL | P0 |
| RF-05 | Definir multiplicidad en ambos extremos | OBL | P0 |
| RF-06 | Definir nombre de rol en los extremos | DER | P1 |
| RF-07 | Manipular el diagrama: seleccionar, mover, conectar, eliminar, zoom, pan | OBL | P0 |
| RF-08 | Validar el modelo con niveles ERROR y WARNING | DER | P0 |
| RF-09 | Deshacer el último comando propio de la sesión | OPT | P2 |

**CA-06.1** — Dadas dos relaciones entre `Venta` y `Cliente` con roles `facturacion` y `envio`, el backend generado produce dos campos distintos y compila.

**CA-08.1 — ERROR, bloquea la generación:** clase sin nombre · nombres duplicados tras normalizar · tipo no soportado · relación a clase inexistente · múltiples candidatos a PK · herencia presente · clave compuesta · dos relaciones entre el mismo par sin rol que las distinga.

**CA-08.2 — WARNING, permite generar e informa:** PK inferida · PK autogenerada · nombre normalizado · nombre reservado con prefijo · clase sin relaciones.

### M2 · Colaboración

| ID | Requisito | Proc. | Prio. |
|---|---|---|---|
| RF-10 | Varios usuarios editan el mismo diagrama, cada uno con identidad distinguible en la sala | OBL | P0 |
| RF-11 | Propagar las modificaciones a todos los participantes sin recargar | OBL | P0 |
| RF-12 | Aplicar y transmitir únicamente la operación, no el modelo completo | OBL | P0 |
| RF-13 | Mantener estado consistente ante operaciones concurrentes | OBL | P0 |
| RF-14 | Entregar el estado actual a quien se incorpora a una sesión en curso | DER | P0 |
| RF-15 | Mostrar los participantes conectados y qué elemento edita cada uno | DER | P1 |

**CA-11.1** — Dados dos navegadores con el mismo proyecto abierto, cuando A crea la clase `Producto`, B la ve aparecer sin recargar.

**CA-12.1** — Durante la edición se transmiten actualizaciones incrementales del documento CRDT, nunca una sustitución completa. El protocolo de tiempo real no transporta comandos de dominio: el comando se aplica localmente y lo que viaja es la actualización resultante. Los comandos se registran para auditoría, no para sincronizar.

**CA-13.1** — Dos usuarios crean concurrentemente nombres que colapsan al mismo identificador técnico. El documento converge sin conflicto y el validador marca ERROR antes de permitir generar.

**CA-14.1** — Dado un diagrama de 10 clases construido durante 20 minutos, cuando un tercer usuario abre el proyecto recibe las 10 clases y a partir de ahí solo actualizaciones.

Autenticación con credenciales, roles de propietario/editor/lector y cursores remotos: P2.

### M3 · Agente de IA

| ID | Requisito | Proc. | Prio. |
|---|---|---|---|
| RF-16 | Recibir instrucciones en lenguaje natural por texto | OBL | P0 |
| RF-17 | Recibir instrucciones por voz | OBL | P0 |
| RF-18 | Traducir la instrucción a un lote de comandos atómicos validado como unidad | OBL | P0 |
| RF-19 | Solicitar aclaración cuando la instrucción es ambigua o incompleta | DER | P1 |
| RF-20 | Modificar solo los elementos afectados, sujeto a las mismas reglas de concurrencia y validación que la GUI | OBL | P0 |

Vocabulario cerrado: `CREATE_CLASS`, `RENAME_CLASS`, `DELETE_CLASS`, `MOVE_CLASS`, `ADD_ATTRIBUTE`, `UPDATE_ATTRIBUTE`, `DELETE_ATTRIBUTE`, `CREATE_RELATIONSHIP`, `UPDATE_RELATIONSHIP`, `DELETE_RELATIONSHIP`, `CHANGE_MULTIPLICITY`.

Cada comando lleva `commandId`; cada lote lleva `batchId` y `origin` (`GUI`, `AI_TEXT`, `AI_VOICE`, `IMAGE`, `XMI`).

**CA-18.1** — Dado `Cliente` con el atributo `nombre`, cuando el usuario dice "agrega teléfono tipo String a Cliente", `Cliente` queda con `nombre` y `telefono` y ningún otro elemento cambia.

**CA-18.2** — Dado "crea Cliente con nombre, teléfono y correo", si un comando del lote es inválido no se aplica ninguno.

**CA-18.3** — El agente asiste, no autogenera. No construye el diagrama completo a partir de una sola instrucción. La única excepción es la importación desde fotografía o XMI, que por naturaleza produce varios elementos.

**CA-19.1 — Política de desambiguación, estructural y no por umbral de confianza:**

| Situación | Comportamiento |
|---|---|
| El objetivo resuelve a un único elemento | Ejecutar |
| Objetivo ambiguo ("borra nombre" con tres clases que lo tienen) | Preguntar cuál |
| Faltan operandos ("relaciona Cliente") | Preguntar el faltante |
| Destructivo de alcance amplio (eliminar clase con relaciones) | Confirmar antes de ejecutar |

Los modelos de lenguaje están mal calibrados: un umbral numérico de confianza produce falsos positivos y negativos sin patrón. La decisión se toma consultando el modelo, no midiendo confianza.

### M4 · Importación por imagen

| ID | Requisito | Proc. | Prio. |
|---|---|---|---|
| RF-21 | Cargar una fotografía de un diagrama dibujado a mano | OBL | P0 |
| RF-22 | Producir un modelo candidato con clases, atributos, relaciones y cardinalidades, revisable y corregible | OBL | P0 |
| RF-23 | Incorporar el candidato confirmado como lote validado | DER | P0 |

**CA-22.1** — El resultado se presenta como propuesta editable. Nunca se aplica directamente. El reconocimiento de un pizarrón se va a equivocar en algo; un candidato que no se puede corregir no sirve.

**CA-23.1** — Al confirmar, el usuario elige entre reemplazar el diagrama o agregar al existente.

### M5 · Interoperabilidad con Enterprise Architect

| ID | Requisito | Proc. | Prio. |
|---|---|---|---|
| RF-24 | Exportar el diagrama a XMI abrible en Enterprise Architect | OBL | P0 |
| RF-25 | Importar XMI de Enterprise Architect a través del modelo canónico | OBL | P1 |

**CA-24.1** — El archivo exportado se abre en la versión de Enterprise Architect del laboratorio y muestra clases, atributos, relaciones y multiplicidades.

**CA-25.1** — El XMI importado pasa por el mismo validador que cualquier otra entrada. Un XMI inválido no evade las reglas del dominio.

La versión se determina por ingeniería inversa sobre archivos exportados de la instalación real, no por el estándar teórico. Round-trip con preservación de identidad: P2.

Si hay que recortar por tiempo, exportar es lo que no se sacrifica: el caso de uso concreto del docente es hacer el diagrama de secuencia en Enterprise Architect sobre clases que ya existen.

### M6 · Generación de código

| ID | Requisito | Proc. | Prio. |
|---|---|---|---|
| RF-26 | Tomar un snapshot inmutable del modelo al iniciar la generación | DER | P0 |
| RF-27 | Generar un proyecto Spring Boot descargable en ZIP | OBL | P0 |
| RF-28 | Generar por entidad: Entity, Repository, Service, Controller | OBL | P0 |
| RF-29 | Generar DTO plano por entidad | OPT | P1 |
| RF-30 | Traducir las relaciones a mapeo JPA según RTM-05 | OBL | P0 |
| RF-31 | Crear el esquema PostgreSQL a partir de las entidades al arrancar | OBL | P0 |
| RF-32 | Exponer CRUD REST completo, finders por clave foránea y manejador global de errores | DER | P0 |
| RF-33 | Producir código que compila y arranca sin modificar una línea de fuente | OBL | P0 |
| RF-34 | Generar colección Postman de todos los endpoints | OBL | P1 |
| RF-35 | Generar contrato OpenAPI e interfaz de exploración | DER | P1 |
| RF-36 | Incluir Dockerfile, compose.yaml, .env.example, README y manifiesto de generación | DER | P1 |
| RF-37 | Generar cliente Dart tipado desde el contrato OpenAPI | OPT | P2 |

**CA-33.1** — Dado un modelo válido, la compilación termina con éxito sin editar código.
**CA-33.2** — Lo único configurable externamente es `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`.
**CA-26.1** — Si durante la generación otro usuario modifica el diagrama, el ZIP corresponde al snapshot tomado al inicio.
**CA-36.1** — El ZIP incluye `generation-manifest.json` con proyecto, versión del snapshot, fecha y versión del generador.

Cada generación produce un artefacto independiente. No existe regeneración incremental sobre un proyecto ya generado.

Aunque RF-29 sea `OPT` por procedencia, se implementa desde el primer generador: es lo que evita los ciclos de serialización, y reescribir después los controladores para introducirlo cuesta más que hacerlo bien de entrada.

---

## 7. Requisitos funcionales — Aplicación móvil

La herramienta no genera esta aplicación. El equipo la construye para validar el backend.

| ID | Requisito | Proc. | Prio. |
|---|---|---|---|
| RFM-01 | Consumir el backend generado por la herramienta | OBL | P0 |
| RFM-02 | Operar las funciones principales mediante voz | OBL | P0 |
| RFM-03 | Reconocer voz e interpretar intenciones sin conexión | OBL | P0 |
| RFM-04 | Descargar y mantener localmente los catálogos necesarios para operar sin conexión | DER | P0 |
| RFM-05 | Registrar operaciones sin conexión en almacenamiento local | OBL | P0 |
| RFM-06 | Sincronizar las operaciones pendientes al recuperar la conexión | OBL | P0 |
| RFM-07 | Detectar conflictos de actualización mediante versión | DER | P1 |

**CA-03.1** — En modo avión la cadena completa funciona: micrófono → reconocimiento en dispositivo → intención local → comando → base local. El reconocimiento debe ser en dispositivo; un servicio de nube deja la aplicación muda sin conexión, y entonces el modo offline es decorativo.

**CA-04.1** — Antes de perder conexión la aplicación tiene localmente los clientes, productos o servicios que necesita referenciar. Sin esto no puede crear ningún registro con clave foránea, que es casi cualquier registro útil.

**CA-04.2** — Dado "registra una atención a Carlos Pérez", la aplicación resuelve el nombre contra el catálogo local. Si hay varias coincidencias, pregunta. Nunca inventa un identificador.

**CA-06.1** — Las operaciones llevan `operationId`. Un reintento tras tiempo de espera agotado no duplica el registro.
**CA-06.2** — Los identificadores son UUID generados en el cliente y conservados sin cambios en PostgreSQL. No existe traducción de identificador local a identificador de servidor.
**CA-07.1** — Las actualizaciones llevan número de versión. Ante conflicto el servidor responde `409`, conserva su versión y la aplicación informa. No hay sobrescritura silenciosa.

La idempotencia en creaciones es P0 porque casi todas las operaciones de la demostración son altas. El control de versión es P1: solo se ejercita si la aplicación incorpora operaciones de modificación.

---

## 8. Requisitos no funcionales

Objetivos de ingeniería adoptados por el equipo, no cifras exigidas por el docente. Se miden antes de comprometerse en la defensa.

| ID | Objetivo |
|---|---|
| RNF-01 | Propagación de cambios colaborativos por debajo de 500 ms (P95) en red local estable |
| RNF-02 | Al menos 5 participantes simultáneos sobre un mismo diagrama |
| RNF-03 | Edición fluida con diagramas de hasta 30 clases |
| RNF-04 | Generación del ZIP por debajo de 10 segundos para los modelos del banco |
| RNF-05 | El código generado sigue la convención de paquetes de Spring Boot y es legible: el docente lo va a abrir |
| RNF-06 | El banco de regresión pasa en verde al 100% antes de considerar terminado el generador |
| RNF-07 | Seguridad mínima: claves de servicios de IA solo en el servidor, secretos por variables de entorno, ningún secreto en el frontend, validación de tipo y tamaño en carga de imágenes y XMI, validación de todo lote recibido. No se construye autenticación empresarial |
| RNF-08 | Integración continua desde la primera semana: cada cambio al generador ejecuta generar y compilar sobre al menos T01. El banco completo corre en cada integración a la rama principal |
| RNF-09 | Registro estructurado con `projectId`, `sessionId`, `batchId`, `commandId`, `generationId` y `origin` |
| RNF-10 | El paquete de dominio se prueba sin navegador, sin base de datos, sin WebSocket y sin servicio de IA |
| RNF-11 | Determinismo: el mismo snapshot produce el mismo código, salvo fecha e identificador de generación |

---

## 9. Fuera de alcance

| ID | Excluido | Motivo |
|---|---|---|
| FA-01 | Herencia y generalización UML | El validador la detecta y sugiere aplanar |
| FA-02 | Claves primarias compuestas | RM-03 |
| FA-03 | Relaciones ternarias directas | RM-02 |
| FA-04 | `@ManyToMany` en el generador | RM-01 lo hace innecesario |
| FA-05 | Métodos y operaciones de clase | La herramienta modela estructura de datos |
| FA-06 | Agregación, composición, interfaces, clases abstractas | Fuera del subconjunto orientado a datos |
| FA-07 | Otros diagramas UML | Se resuelven en Enterprise Architect vía XMI |
| FA-08 | Regeneración incremental sobre código generado | Cada generación es independiente |
| FA-09 | Ingeniería inversa de código Java hacia el modelo | Problema distinto |
| FA-10 | Generación de la aplicación Flutter completa | El docente dijo que no verá apps generadas. Solo se genera el cliente Dart desde OpenAPI (RF-37) |
| FA-11 | IA local en la herramienta web | El enunciado la acota a la aplicación móvil |
| FA-12 | Paginación, filtrado avanzado, ordenamiento, seguridad y HATEOAS en el CRUD generado | CRUD simple más finders por clave foránea |
| FA-13 | Migraciones con Flyway o Liquibase | El esquema se crea desde las entidades |
| FA-14 | Correspondencia de identificadores para claves primarias no UUID | RM-06 lo evita |
| FA-15 | Event sourcing, CQRS completo, microservicios, Kubernetes, brokers de mensajería | Desproporcionados |

---

## 10. Arquitectura

### 10.1 Principio rector

Todas las entradas modifican un único modelo UML canónico mediante lotes de comandos atómicos. Colaboración, IA, imagen, XMI y generación son adaptadores alrededor de ese núcleo.

Si esa pieza está bien hecha, las seis funcionalidades se conectan al mismo centro. Si está mal hecha, habrá seis implementaciones peleándose.

### 10.2 Estilo

Monolito modular, orientado al dominio, con arquitectura hexagonal aplicada de forma ligera y solo donde aporta: el paquete de dominio es puro, sin dependencias de entrada/salida, y todo lo demás son adaptadores.

Organización por módulo de dominio, no por capa global:

```
project/   modeling/   collaboration/
ai/        xmi/        imageimport/     generation/
```

Sin convertir cada operación en un puerto con su adaptador y su fábrica.

### 10.3 Decisión de runtime

El aplicador de comandos y el validador deben ejecutarse en el navegador (edición local instantánea) y en el servidor (agente, imagen, XMI). Por eso son un paquete TypeScript compartido, y por eso el servidor que toca el documento colaborativo es Node.

Un core en Java obligaría a implementar el modelo canónico y el validador dos veces, y a que el módulo de IA no pudiera aplicar comandos directamente sobre el documento. Se descarta.

Opción aceptable si el equipo es predominantemente Java: mantener Node para el modelo vivo y colaboración, y aislar el generador como servicio Java que recibe un snapshot JSON y devuelve un ZIP.

**Dos procesos, una aplicación.** El servidor HTTP y el de colaboración se despliegan como procesos separados dentro del mismo monorepo, compartiendo el paquete de dominio y la base de datos. Montarlos en un único proceso es posible pero obliga a resolver la convivencia de HTTP y WebSocket sobre el mismo servidor, integración que no aporta al examen. Dos procesos no es microservicios: es una aplicación modular con dos ejecutables, y Docker Compose lo oculta.

Para la demostración conviene un proxy inverso delante, de modo que las otras computadoras del aula accedan a una sola dirección en lugar de tres puertos. Elimina de paso los problemas de origen cruzado. Opcional, P1.

### 10.4 Flujo interno

```
GUI · texto · voz · imagen · XMI
              │
              ▼
      Propuesta de lote
              │
              ▼
      Resolución estructural (desambiguación)
              │
              ▼
          Validación
              │
              ▼
     Aplicador de comandos
              │
              ▼
   ┌── Modelo canónico (documento CRDT) ──┐
   │                                       │
   ▼                                       ▼
Eventos internos              Snapshot inmutable
                                           │
                                           ▼
                                 Representación
                                 intermedia de generación
                                           │
                                           ▼
                                  Plantillas → ZIP
```

La representación intermedia es interna, análoga al IR de un compilador. Traduce el modelo conceptual directamente a modelo físico: no existe un modelo relacional visible para el usuario. Ahí viven las decisiones de persistencia — lado propietario, columnas de unión, nombres de tabla, recurso REST — que no pertenecen al modelo UML. Su existencia también deja abierta la puerta a otros generadores sin tocar el dominio.

### 10.5 Comandos y eventos

- **Comando**: intención de modificar el dominio. `CreateClass`, `AddAttribute`, `DeleteRelationship`.
- **Evento**: notificación de algo ocurrido. `DiagramChanged`, `SnapshotCreated`, `BackendGenerated`.

Los eventos son en proceso. No hay broker.

Una actualización CRDT no es un evento de dominio. La primera es un mensaje de sincronización de bajo nivel entre réplicas; el segundo es una notificación semántica. Viven en capas distintas y no deben mezclarse.

Puede existir un registro de operaciones para auditoría. Un registro de operaciones no es event sourcing: el estado no se reconstruye reproduciéndolo.

### 10.6 Estructura del modelo canónico

```
Project
├── id, schemaVersion, name
└── diagram

Diagram
├── semantic
│   ├── classes[]
│   └── relationships[]
└── layout
    ├── nodePositions
    └── viewport

UmlClass
├── id (UUID), displayName, codeName, databaseName
└── attributes[]

UmlAttribute
├── id (UUID), displayName, codeName, databaseName
├── type, primaryKey, nullable, unique

UmlRelationship
├── id (UUID)
├── sourceClassId, targetClassId
├── sourceMultiplicity, targetMultiplicity
└── sourceRoleName, targetRoleName
```

`semantic` y `layout` viajan en el mismo documento colaborativo pero están separados conceptualmente. El generador consume solo `semantic`; el editor consume ambos.

El modelo canónico no contiene `mappedBy`, `ownerSide`, `joinColumn`, `cascade` ni `fetch`: son decisiones de persistencia y pertenecen a la representación intermedia.

### 10.7 Stack de la herramienta

| Pieza | Tecnología |
|---|---|
| Lenguaje | TypeScript de extremo a extremo |
| Monorepo | Workspaces del gestor de paquetes elegido |
| Frontend | React + Vite |
| Canvas | React Flow |
| Estado de interfaz | Zustand — nunca el modelo colaborativo |
| Colaboración | Yjs + servidor Hocuspocus, con su extensión de persistencia |
| API | Node + Fastify |
| Contratos | Librería de esquemas TypeScript como fuente única |
| Persistencia | PostgreSQL con un ORM ligero |
| Generador | Plantillas sobre la representación intermedia |
| IA | Modelo con salida estructurada por esquema JSON; modelo de visión para imagen |
| Voz en la herramienta | Reconocimiento del navegador, con respaldo de transcripción en servidor |
| XMI | Parser y serializador XML |
| Pruebas | Unitarias para el dominio, integración para el generador, y tres pruebas de extremo a extremo con dos navegadores |
| Integración continua | Ejecución del banco de regresión en cada cambio |
| Contenedores | Docker y Docker Compose |

Los contratos se declaran una sola vez y de ahí se derivan los tipos estáticos, el validador en ejecución y el esquema JSON que se le pasa al modelo como formato de salida. Mantener a mano un esquema JSON y aparte los tipos TypeScript garantiza que en algún momento discrepen, y el síntoma será un lote que el agente produce y el validador rechaza sin motivo aparente.

**Esquema de datos de la herramienta:**

```
projects            id · name · schema_version
collab_documents    project_id · yjs_state (binario) · updated_at
diagram_snapshots   project_id · canonical_json · version · updated_at
generations         id · project_id · snapshot_version · created_at
```

El estado binario sirve para reabrir la colaboración. El JSON canónico sirve para validar, generar e inspeccionar. El JSON no reemplaza al binario.

### 10.8 Stack del backend generado

Java LTS, Spring Boot rama estable verificada, Maven, Spring Web, Spring Data JPA, Bean Validation, driver PostgreSQL, springdoc.

Arquitectura en cuatro capas clásicas más DTO, tal como pide la consigna. No se aplica hexagonal al código generado: el docente pidió Modelo, Repositorio, Servicio, Controlador.

```
model/  dto/  repository/  service/  controller/  exception/
```

Sin Lombok, sin MapStruct, sin Flyway, sin Security, sin Redis.

### 10.9 Stack de la aplicación móvil

Flutter, gestor de estado y cliente HTTP a elección, base local SQLite con una capa tipada. Arquitectura offline-first con patrón repositorio y dos orígenes de datos, local y remoto.

Para el reconocimiento de voz en dispositivo hay que evaluar al menos dos motores y decidir sobre el teléfono real que se llevará al examen, no sobre el emulador. Criterios: tamaño del modelo en español, latencia y consumo de memoria.

La interpretación es híbrida y esa separación es deliberada: un modelo de intenciones local clasifica la orden (`CREATE_ATTENTION`, `CREATE_SALE`, `LIST_SALES`), y código determinista resuelve las entidades contra el catálogo local. El modelo nunca produce identificadores; produce un nombre, y el resolver lo busca en la base local.

Para el clasificador no hace falta un modelo de lenguaje grande. Con cuatro o cinco intenciones, un clasificador clásico entrenado fuera del dispositivo — vectorización de texto más un modelo lineal — exportado como vocabulario y pesos en JSON pesa kilobytes, responde de inmediato, funciona sin conexión y sin GPU, y sigue siendo aprendizaje automático. Un modelo de lenguaje local es P2: agrega cientos de megabytes y latencia para un problema que no los necesita.

Presentar solo coincidencia de cadenas como inteligencia artificial es arriesgado frente al docente. El clasificador entrenado es la pieza que sostiene el requisito, y es explicable en un minuto.

### 10.10 Infraestructura

| Nivel | Herramienta | Cuándo |
|---|---|---|
| Desarrollo y examen | Docker Compose | Desde el día uno |
| Backend generado | Dockerfile y compose dentro del ZIP | Salvaguarda de la demostración |
| Servidor de demostración | VPS con Docker o plataforma de despliegue simple | Cuando el core funcione |
| Infraestructura como código | Terraform u OpenTofu, solo para VPS, DNS y red | Después del parcial |

No se usa infraestructura como código en el MVP: el retorno es negativo a tres semanas de la entrega, y el problema a resolver es modelado UML colaborativo, no aprovisionamiento de redes. Sí se usa Docker, que es lo que reduce riesgo real el día de la defensa.

Redis para escalar la colaboración a varias instancias: previsto en el diseño, no implementado. Kubernetes: no.

El servidor no compila el proyecto generado en tiempo de ejecución. La garantía de que compila la da el banco de regresión en integración continua.

### 10.11 Estructura del repositorio

```
apps/
  web/          api/          collab/       mobile-demo/

packages/
  contracts/    domain-core/  yjs-adapter/
  generation-ir/ generator/   xmi/          ai/

fixtures/
  uml/          xmi/

infra/
  compose/

docs/
  requirements/ architecture/ adr/
```

### 10.12 Decisiones a documentar como ADR

Una página cada una. Sirven directamente para responder en la defensa.

```
ADR-001  Monolito modular en lugar de microservicios
ADR-002  CRDT para colaboración en tiempo real
ADR-003  Modelo UML canónico único con comandos atómicos
ADR-004  Entidad intermedia explícita para N:M
ADR-005  Sin event sourcing ni CQRS completo
ADR-006  Generación determinista por plantillas, no por modelo de lenguaje
ADR-007  DTO planos con relaciones por identificador
ADR-008  Docker Compose en el artefacto generado
ADR-009  Runtime único para el aplicador de comandos
ADR-010  Relaciones unidireccionales más finders por clave foránea
ADR-011  Infraestructura como código diferida
ADR-012  Matriz de versiones congelada (con fecha de verificación)
```

---

## 11. Calidad

### Definition of Done del generador

Terminado cuando el pipeline completo pasa en verde para los siete modelos del banco, cada uno contra una base de datos limpia:

```
MODELO
  ↓ validar
  ↓ snapshot
  ↓ generar
  ↓ compilar
  ↓ arrancar
  ↓ crear esquema
  ↓ OpenAPI carga
  ↓ POST entidades raíz          (orden topológico de dependencias)
  ↓ POST entidades dependientes
  ↓ GET colección
  ↓ GET por identificador
  ↓ GET por clave foránea
  ↓ PUT
  ↓ POST repetido con mismo UUID → 200, sin duplicado
  ↓ DELETE de padre con hijos    → 409 esperado
  ↓ DELETE en orden inverso
  ↓ reiniciar
  ↓ los datos siguen ahí
  ✓
```

La compilación exitosa por sí sola no significa que el generador funciona. El ciclo de serialización, la violación de clave foránea, el error sin traducir y el borrado accidental del esquema solo aparecen ejecutando.

Dos aclaraciones: el `409` al borrar un padre con hijos es un caso de éxito, no un fallo. Y el paso final verifica que la configuración de esquema no destruye datos entre arranques.

### Banco de regresión

| ID | Modelo | Qué ejercita |
|---|---|---|
| T01 | Cliente · Producto · Venta · DetalleVenta | 1:N, N:1, Decimal, Date, entidad intermedia |
| T02 | Proveedor · Compra · DetalleCompra · Producto | Mismo patrón, otra terminología |
| T03 | Cliente · Barbero · Servicio · Atencion | El caso de la aplicación móvil |
| T04 | Activo · Categoria · Responsable · Asignacion | Múltiples claves foráneas sobre una misma entidad |
| T05 | Cliente · Cuenta · Movimiento | Cadena de tres niveles |
| T06 | Alumno · Materia · Inscripcion | N:M con atributos propios |
| T07 | Modelo hostil | Ver abajo |

**T07 es obligatorio.** Contiene deliberadamente: una clase `Order` (reservada en PostgreSQL), una clase `Número de Cuenta` (tildes y espacios), un atributo `class` (reservada en Java), una clase sin clave primaria, dos clases que normalizan al mismo identificador, dos relaciones entre el mismo par de clases con roles distintos, una relación `0..1` y un atributo `unique`. Ejercita de una sola vez normalización, las tres listas de reservadas, inferencia de clave primaria, detección de colisiones, derivación de campos por rol y opcionalidad.

Generación aleatoria de modelos para detectar casos no imaginados: después del banco manual, P2.

### Pruebas de colaboración

Tres pruebas de extremo a extremo con dos navegadores, no más:

1. A crea una clase, B la ve.
2. A mueve una clase, B lo ve.
3. A cambia una cardinalidad, B lo ve.

Protegen el requisito más diferenciador del proyecto sin convertir las pruebas en un segundo proyecto.

---

## 12. Plan de trabajo

### Principio del cronograma

Un plan estrictamente secuencial deja los riesgos desconocidos para el final, que es donde no hay margen. Los riesgos que no dependen del esfuerzo del equipo se atacan en la primera semana aunque nada más esté listo.

### Semana 1 (28 ago – 3 sep) — Núcleo, spikes y sondeos

Frente común:

1. Esquema del modelo canónico, vocabulario de comandos y lote, en `contracts/`.
2. Aplicador de comandos y validador como paquete compartido, con pruebas sin navegador ni base de datos.

Dos spikes que validan la arquitectura, en paralelo:

3. **Generación**: un JSON de T01 escrito a mano entra al generador, sale un proyecto Spring Boot, compila.
4. **Colaboración**: dos navegadores modifican el mismo documento a través del paquete de dominio y convergen.

Dos sondeos de riesgo externo, también en paralelo:

5. Obtener la versión de Enterprise Architect del laboratorio, exportar dos o tres XMI de referencia como fixtures. Confirmar con el docente si exige ambos sentidos o basta con exportar.
6. Probar el reconocimiento de voz sin conexión en el teléfono real. Solo transcribir una frase, sin app alrededor. Comparar al menos dos motores.

Si los dos spikes funcionan, la arquitectura está validada y el resto es construcción. El riesgo aquí no es React Flow, que es una librería madura; es que el paquete de dominio y el documento colaborativo encajen limpiamente.

### Semana 2 (4 – 10 sep) — Vertical slice y arranque de frentes

- Generación completa de T01 con el pipeline hasta el `409` esperado, incluidos los DTO planos. Valida de una vez clave primaria, DTO, nombres, N:M y borrado restrictivo.
- Editor con React Flow sobre el documento colaborativo, dos navegadores editando de verdad.
- Arranque de la app Flutter contra el backend de T01, aunque sea con una pantalla y sin voz.
- Integración continua en marcha con T01.

La app móvil no puede empezar en la última semana. Es la pieza con más incógnitas y la única que depende de hardware.

### Semana 3 (11 – 17 sep) — Frentes en paralelo

- Agente de IA por texto y voz, y reconocimiento por imagen.
- Exportación e importación XMI contra los fixtures reales.
- Resto del banco: T02 a T07.
- Móvil: catálogos descendentes, operación offline y cola de sincronización.

### Semana 4 (18 – 22 sep) — Integración y ensayo

- 18 y 19: integración de todos los frentes. Ninguna funcionalidad nueva a partir del 19.
- 20: banco completo en verde, incluido T07.
- 21: ensayo completo de la defensa, cronometrado.
- 22: congelamiento. Solo corrección de defectos del ensayo. Segundo ensayo si el primero reveló problemas.

### 23 sep — Presentación

### Guion del ensayo

```
dos PC en la misma sala → clase por GUI en una, visible en la otra
→ clase por voz → foto del pizarrón → corrección del candidato
→ exportar XMI → abrir en Enterprise Architect
→ generar backend → descargar ZIP → abrir en el IDE → configurar BD → ejecutar
→ verificar tablas en PostgreSQL → probar endpoints con Postman
→ abrir la app Flutter → registrar por voz → modo avión → registrar de nuevo
→ reconectar → verificar sincronización sin duplicados
```

Si un paso falla en el ensayo, hay dos días. Si falla el 23, no hay ninguno.

### Preparativos del día 22

Todo lo descargable debe estar en caché local:

- repositorio Maven local poblado (si el banco corrió, ya lo está);
- imágenes Docker construidas;
- dependencias de Node y Flutter instaladas;
- modelo de voz y clasificador instalados en el teléfono;
- Enterprise Architect abierto y probado en la máquina que se llevará.

### Plan de degradación sin conexión

| Funcionalidad | ¿Necesita internet? |
|---|---|
| Editor gráfico y colaboración entre computadoras | No, red local |
| Generación del backend y descarga del ZIP | No, plantillas locales |
| Compilar y ejecutar el proyecto generado | No, con repositorio Maven poblado |
| PostgreSQL y pruebas con Postman | No |
| App móvil: voz, IA local, registro sin conexión | No, es el requisito |
| Agente de IA de la herramienta | **Sí** |
| Reconocimiento de la fotografía | **Sí** |

Solo dos funcionalidades dependen de conexión, y son dos de las tres vías con las que el docente cargará el modelo. Mitigación: punto de acceso móvil de respaldo, verificado antes de empezar. La tercera vía, el dibujo manual, funciona siempre y sirve de plan alternativo.

---

## 13. Riesgos

| Riesgo | Mitigación |
|---|---|
| El ZIP no compila con el modelo que dibuje el docente | Banco T01–T07, con T07 hostil |
| El XMI exportado no abre en la instalación del docente | Fixtures reales de esa instalación, semana 1 |
| La aplicación queda muda sin conexión | Reconocimiento en dispositivo, verificado en modo avión |
| No se puede registrar nada offline por falta de catálogos | Sincronización descendente, CA-04.1 |
| Colisión de nombres al normalizar | Validación sobre `codeName`, no sobre `displayName` |
| El JDK del docente no coincide con el generado | Verificar y fijar la versión de destino |
| Ciclo de serialización al consultar entidades relacionadas | DTO planos desde el primer generador |
| El aula no tiene internet | Plan de degradación y punto de acceso de respaldo |
| Análisis interminable sin código | Este documento está congelado. Todo problema nuevo aparece primero como test fallando |

---

## 14. Nota de cierre

El alcance está congelado. A partir de aquí, cualquier problema debería manifestarse primero como una prueba fallando en T01–T07, y solo convertirse en cambio de especificación si la implementación realmente lo exige.

El siguiente artefacto del proyecto es código, no otro documento.
````

---

### `docs/referencia/plan-integral-plataforma-uml.md`

````markdown
# Plataforma colaborativa de diseño de bases de datos

Plan integral de punta a punta
Entrega: 23 de septiembre · Versión 2.0 · Alcance congelado

---

# Índice

1. Producto y alcance
2. Clasificación de requisitos
3. Estructura del repositorio
4. Arquitectura
5. Autenticación, proyectos y membresías
6. Capa de IA desacoplada
7. Reglas de modelado
8. Reglas de transformación
9. Requisitos funcionales
10. Requisitos de la aplicación móvil
11. Requisitos no funcionales
12. Fuera de alcance
13. Docker: servicios, perfiles y control individual
14. Escalabilidad futura
15. Calidad
16. Plan de trabajo
17. ADR obligatorios
18. Riesgos

---

# 1. Producto y alcance

## 1.1 Definición

Plataforma web colaborativa de modelado conceptual de datos basada en un subconjunto de diagramas de clases UML. Los usuarios se registran, crean proyectos, y dentro de cada proyecto abren varias pizarras. Cada pizarra es un diagrama editable simultáneamente por varias personas, mediante interfaz gráfica o mediante un asistente de IA por texto y voz.

Desde una pizarra seleccionada la plataforma genera un backend Spring Boot con PostgreSQL listo para compilar y ejecutar, más los artefactos para probarlo.

Interopera con Enterprise Architect mediante XMI para continuar allí los diagramas que esta herramienta no cubre.

## 1.2 Flujo del producto

```
Registro → Proyecto → Pizarra colaborativa → Modelo validado
        → Backend Spring Boot + PostgreSQL → App móvil
```

## 1.3 Tres decisiones de alcance

**Varias pizarras por proyecto.** Cada pizarra tiene su propia sesión colaborativa y su propio documento. La generación opera sobre una pizarra seleccionada. No existen relaciones cruzadas entre pizarras, y fusionar varias en un solo sistema generado queda fuera del parcial.

**Generación del cliente móvil: solo capa de datos.** El docente dijo dos cosas explícitas: que no verá aplicaciones móviles generadas por la herramienta, y que el frontend se construye en vivo durante la defensa. Generar una aplicación completa con pantallas, formularios y navegación cuesta tanto como el generador de Spring Boot, compite con trabajo P0 y sustituiría justamente el ejercicio en vivo que él pidió.

El cliente móvil no se genera en ninguna de sus partes: se construye entero durante la defensa sobre el backend generado y su colección de Postman. Generarlo sustituiría el ejercicio que el docente quiere ver hecho en vivo.

**IA local solo en el móvil.** El enunciado lo acota explícitamente. La herramienta web usa proveedores en la nube a través de puertos desacoplados.

---

# 2. Clasificación de requisitos

## Procedencia

| Código | Significado |
|---|---|
| `DOC` | Pedido explícitamente por el docente |
| `DER` | Derivado, necesario para cumplir un requisito del docente |
| `PROY` | Alcance propio adoptado por el equipo |
| `OPT` | Mejora opcional |

## Prioridad

| Código | Significado |
|---|---|
| `P0` | Sin esto falla la demostración |
| `P1` | Necesario para una demostración confiable |
| `P2` | Posterior al núcleo |
| `P3` | Fuera del parcial |

Procedencia y prioridad son independientes. Un requisito `DER` puede ser `P0`: que el docente no lo haya verbalizado no significa que se pueda postergar.

Otros bloques: `CA` criterio de aceptación · `RNF` requisito no funcional · `RT` restricción tecnológica · `RA` restricción arquitectónica · `RM` regla de modelado · `RTM` regla de transformación · `FA` fuera de alcance.

---

# 3. Estructura del repositorio

```
plataforma-uml/
│
├── frontend/                  Aplicación web React
│   ├── src/
│   │   ├── features/          editor, proyectos, auth, asistente, importación
│   │   ├── components/
│   │   ├── lib/
│   │   └── main.tsx
│   ├── index.html
│   └── package.json
│
├── backend/                   Servidor de la plataforma
│   ├── api/                   Proceso HTTP
│   │   └── src/
│   │       ├── modules/       auth, projects, boards, ai, image, xmi, generation
│   │       ├── plugins/
│   │       └── server.ts
│   ├── collab/                Proceso WebSocket
│   │   └── src/
│   │       ├── auth/
│   │       ├── persistence/
│   │       └── server.ts
│   └── prisma/
│       └── schema.prisma
│
│   └── lib/
│       ├── core/
│       ├── data/              local, remote
│       ├── features/
│       ├── agent/             STT local, intención, registro de herramientas
│       └── sync/
│
├── shared/                    Código compartido navegador ↔ servidor
│   ├── contracts/             esquemas: modelo canónico, comandos, lotes, API
│   ├── domain-core/           modelo, comandos, validador, reglas de nombres
│   ├── yjs-adapter/           puerto del documento colaborativo
│   ├── generation-ir/         representación intermedia de generación
│   ├── generator-backend/     emisión del proyecto Spring Boot
│   ├── xmi/                   parser y serializador
│   └── ai/                    puertos y adaptadores de proveedores
│
├── templates/
│   ├── spring/                plantillas del backend generado
│
├── fixtures/
│   ├── uml/                   T01–T08
│   ├── xmi/                   archivos reales exportados de Enterprise Architect
│   └── voice/                 frases de prueba del agente móvil
│
├── infra/
│   ├── compose.yml
│   ├── compose.override.yml
│   ├── caddy/
│   └── .env.example
│
├── docs/
│   ├── requirements/
│   ├── architecture/
│   └── adr/
│
└── .github/workflows/
```

## 3.1 Por qué existe `shared/`

La carpeta compartida no es opcional: es la consecuencia directa de RA-05. El aplicador de comandos y el validador tienen que ejecutarse en el navegador (para que la edición sea instantánea) y en el servidor (para que el asistente, la importación por imagen y XMI apliquen los mismos comandos con las mismas reglas). Una sola implementación, dos lugares de ejecución.

Si ese código viviera dentro de `backend/`, el navegador tendría que reimplementarlo, y en algún momento las dos versiones divergirían. El síntoma sería un lote que el asistente produce y el editor rechaza sin motivo aparente.

`frontend/` y `backend/` son las aplicaciones de la plataforma. `shared/` y `templates/` son las bibliotecas de las que se alimentan, y de `templates/` sale el artefacto generado: el backend Spring Boot.

---

# 4. Arquitectura

## 4.1 Principio rector

Todas las entradas modifican un único modelo UML canónico mediante lotes de comandos atómicos. Colaboración, IA, imagen, XMI y generación son adaptadores alrededor de ese núcleo.

Si esa pieza está bien hecha, las seis funcionalidades se conectan al mismo centro. Si está mal hecha, habrá seis implementaciones peleándose por ser la verdad.

## 4.2 Estilo

Monolito modular orientado al dominio, desplegado como dos procesos especializados. Arquitectura hexagonal aplicada de forma ligera y solo en `shared/domain-core`, que no depende de React, del documento colaborativo, del servidor HTTP, de la base de datos ni de ningún proveedor de IA.

Fuera de ese paquete, código directo. Nada de convertir cada operación en un puerto con su adaptador, su fábrica y su mapeador.

Dos procesos no es una arquitectura de microservicios: es una aplicación modular con dos ejecutables. Están separados porque montar HTTP y WebSocket sobre el mismo servidor obliga a resolver una convivencia que no aporta nada al examen, y porque escalan distinto.

## 4.3 Vista de despliegue

```
                    Navegador
              React + editor + documento
                        │
              ┌─────────┴─────────┐
            HTTPS               WSS
              │                   │
         ┌────▼─────┐      ┌──────▼──────┐
         │   api    │      │   collab    │
         │          │      │             │
         │ auth     │      │ salas       │
         │ proyectos│      │ presencia   │
         │ pizarras │      │ persistencia│
         │ ia       │      │ autorización│
         │ imagen   │      └──────┬──────┘
         │ xmi      │             │
         │ generación│            │
         └────┬─────┘             │
              └──────────┬────────┘
                         ▼
                    PostgreSQL
```

Delante puede ir un proxy inverso que expone un único origen. Elimina los problemas de origen cruzado y, sobre todo, permite que las otras computadoras del aula lleguen a una sola dirección en lugar de tres puertos.

## 4.4 Flujo interno de una modificación

```
GUI · texto · voz · imagen · XMI
              │
              ▼
     Propuesta de lote
              │
              ▼
     Resolución estructural (desambiguación)
              │
              ▼
         Validación
              │
              ▼
    Aplicador de comandos
              │
              ▼
  Documento colaborativo (transacción única)
              │
   ┌──────────┴──────────┐
   ▼                     ▼
Actualización        Snapshot inmutable
incremental                │
a los demás                ▼
                    Representación intermedia
                           │
                           ▼
                    Plantillas → ZIP
```

## 4.5 Fuentes de verdad

| Representación | Responsabilidad |
|---|---|
| Esquema canónico | Contrato semántico: qué significa el estado |
| Documento colaborativo | Estado vivo replicado |
| Layout | Posición y viewport, sin valor semántico |
| PostgreSQL | Persistencia durable y metadatos |
| Snapshot de generación | Entrada inmutable al generador |
| Representación intermedia | Traducción temporal para emitir código |

El editor visual siempre es una proyección del documento, nunca la fuente de verdad.

## 4.6 Modelo canónico

```
Project
├── id · schemaVersion · displayName · ownerId
└── boards[]

Board
├── id · projectId · displayName · type
├── semantic
└── layout

SemanticModel
├── classes[]
└── relationships[]

UmlClass
├── id (UUID) · displayName · codeName · databaseName
└── attributes[]

UmlAttribute
├── id (UUID) · displayName · codeName · databaseName
├── type · primaryKey · nullable · unique

UmlRelationship
├── id (UUID)
├── sourceClassId · targetClassId
├── sourceMultiplicity · targetMultiplicity
└── sourceRoleName? · targetRoleName?
```

El modelo canónico no contiene `mappedBy`, lado propietario, columnas de unión, `cascade` ni `fetch`. Son decisiones de persistencia y viven en la representación intermedia.

Sala de colaboración por pizarra: `project:{projectId}:board:{boardId}`.

## 4.7 Comandos

Vocabulario cerrado:

```
CREATE_CLASS · RENAME_CLASS · DELETE_CLASS · MOVE_CLASS
ADD_ATTRIBUTE · UPDATE_ATTRIBUTE · DELETE_ATTRIBUTE
CREATE_RELATIONSHIP · UPDATE_RELATIONSHIP · DELETE_RELATIONSHIP
CHANGE_MULTIPLICITY
```

Cada comando lleva `commandId`, `type`, `payload`, `origin`, `actorId` y marca de tiempo. Cada lote lleva `batchId` y `origin` (`GUI`, `AI_TEXT`, `AI_VOICE`, `IMAGE`, `XMI`).

Secuencia obligatoria: planificar → validar el lote completo → si hay un solo error no aplicar nada → si todo es válido aplicar dentro de una transacción del documento.

La transacción del documento agrupa el cambio para que produzca una sola actualización a los demás participantes. No se usa como mecanismo de deshacer: la validación ocurre antes.

## 4.8 Restricciones arquitectónicas

| ID | Restricción |
|---|---|
| RA-01 | Un único modelo canónico. Toda entrada es un adaptador que produce comandos |
| RA-02 | Deltas durante la edición. Snapshot solo al incorporarse a una sesión |
| RA-03 | Lotes transaccionales: todo o nada |
| RA-04 | Identidad UUID interna independiente del nombre. Renombrar no rompe relaciones |
| RA-05 | Aplicador y validador: una implementación, dos lugares de ejecución |
| RA-06 | El asistente dispone de vocabulario cerrado. Nunca mutación arbitraria |
| RA-07 | Generación determinista por plantillas. Ningún modelo de lenguaje escribe Java |
| RA-08 | La generación opera sobre snapshot inmutable, no sobre el estado vivo |
| RA-09 | Todo modelo persistido declara la versión de su esquema |
| RA-10 | La sincronización del diagrama y la de datos del móvil son mecanismos distintos |
| RA-11 | El documento colaborativo se persiste en su representación binaria nativa. El JSON canónico es proyección derivada y nunca reconstruye el documento |
| RA-12 | La colaboración garantiza convergencia estructural, no validez semántica |
| RA-13 | Entre modelo canónico y plantillas existe una representación intermedia |
| RA-14 | Los proveedores de IA se consumen a través de puertos. Ningún módulo del dominio conoce un proveedor concreto |
| RA-15 | Toda conexión al servidor de colaboración se autentica y autoriza antes de unirse a una sala |

---

# 5. Autenticación, proyectos y membresías

## 5.1 Por qué entra ahora

Con identidad real, tres cosas que antes no se sostenían pasan a ser implementables: los roles tienen dónde apoyarse, la atribución de cambios en la presencia es fiable, y las pizarras dejan de ser accesibles por quien adivine un identificador de sala.

El costo es acotado si se mantiene el alcance mínimo. Lo que se construye: registro, inicio y cierre de sesión, invitación por enlace y tres roles. Lo que no: verificación por correo, recuperación de contraseña, inicio de sesión con terceros, administración de organizaciones.

## 5.2 Modelo de datos

```
users
├── id (UUID) · email (único) · displayName
├── passwordHash · createdAt

refresh_tokens
├── id · userId · tokenHash · expiresAt · revokedAt

projects
├── id (UUID) · displayName · ownerId · schemaVersion · createdAt

project_members
├── projectId · userId · role (OWNER | EDITOR | VIEWER) · joinedAt

project_invites
├── id · projectId · code · role · expiresAt · createdBy

boards
├── id (UUID) · projectId · displayName · type · createdAt

board_documents
├── boardId · state (binario) · updatedAt

board_snapshots
├── boardId · canonicalJson · version · updatedAt

generations
├── id · boardId · snapshotVersion · createdAt · createdBy

audit_operations
├── id · boardId · batchId · origin · actorId · payload · createdAt
```

## 5.3 Mecanismo

Contraseñas con una función de derivación moderna y lenta. Nunca cifrado reversible, nunca hash simple.

Token de acceso de vida corta más token de refresco rotativo guardado en cookie de solo HTTP. El token de acceso es el que se pasa al abrir el WebSocket, que es la razón por la que conviene un token y no solo una cookie de sesión.

## 5.4 Autorización del WebSocket

Esta es la parte que suele olvidarse. El servidor de colaboración valida en el momento de la conexión, antes de entregar el documento:

```
Conexión entrante
      ↓
Token válido y no expirado
      ↓
El usuario es miembro del proyecto de esa pizarra
      ↓
Rol determina el modo:
   OWNER  → lectura y escritura
   EDITOR → lectura y escritura
   VIEWER → solo lectura
      ↓
Se une a la sala
```

Sin esta verificación, proteger las rutas HTTP no sirve de nada: cualquiera con el identificador de la sala editaría la pizarra.

## 5.5 Roles

| Rol | Puede |
|---|---|
| `OWNER` | Todo, más invitar, cambiar roles y eliminar el proyecto |
| `EDITOR` | Crear y editar pizarras, usar el asistente, generar código |
| `VIEWER` | Ver pizarras y consultar al asistente sin modificar |

## 5.6 Requisitos

| ID | Requisito | Origen | Prio |
|---|---|---|---|
| RF-A01 | Registro con correo y contraseña | PROY | P0 |
| RF-A02 | Inicio y cierre de sesión | PROY | P0 |
| RF-A03 | Renovación de sesión mediante token de refresco | DER | P0 |
| RF-A04 | Crear proyecto y quedar como propietario | DER | P0 |
| RF-A05 | Invitar por enlace con código y rol asignado | PROY | P0 |
| RF-A06 | Aceptar invitación y quedar como miembro | PROY | P0 |
| RF-A07 | Listar miembros y cambiar roles | PROY | P1 |
| RF-A08 | Autorizar la conexión de colaboración y aplicar el rol | DER | P0 |
| RF-A09 | Atribuir cada lote de comandos a un usuario identificado | DER | P0 |
| RF-A10 | Revocar sesiones activas | PROY | P2 |

**CA-A08.1** — Dado un usuario que no es miembro del proyecto, cuando intenta conectarse a la sala de una pizarra con un identificador válido, la conexión se rechaza.

**CA-A08.2** — Dado un miembro con rol de lectura, cuando intenta modificar la pizarra, el documento no acepta su escritura y la interfaz muestra el modo de solo lectura.

---

# 6. Capa de IA desacoplada

## 6.1 Principio

Ningún módulo del dominio conoce un proveedor concreto. La IA se consume a través de tres puertos, y cada proveedor es un adaptador intercambiable por configuración.

Esto no es purismo arquitectónico: es la diferencia entre cambiar de proveedor en una tarde y reescribir tres módulos a una semana de la entrega.

## 6.2 Los tres puertos

```
LlmPort
├── proposeCommands(instruccion, snapshot) → PropuestaDeLote
└── answer(pregunta, snapshot) → respuesta consultiva

VisionPort
└── extractModel(imagen) → ModeloCandidato

SpeechPort
└── transcribe(audio) → texto
```

`SpeechPort` existe solo como respaldo del reconocimiento del navegador. La app móvil no usa estos puertos: su agente es local y se construye durante la defensa.

## 6.3 Adaptadores

```
shared/ai/
├── ports/
├── adapters/
│   ├── provider-a/
│   ├── provider-b/
│   └── mock/
├── registry.ts
└── config.ts
```

Selección por variables de entorno:

```
# Un primario y un respaldo por puerto
AI_LLM_PROVIDER=gemini
AI_LLM_MODEL=gemini-3.6-flash
AI_LLM_FALLBACK_PROVIDER=openrouter
AI_LLM_FALLBACK_MODEL=anthropic/claude-sonnet-4.5

AI_VISION_PROVIDER=gemini
AI_VISION_MODEL=gemini-3.6-flash
AI_VISION_FALLBACK_PROVIDER=openrouter
AI_VISION_FALLBACK_MODEL=anthropic/claude-sonnet-4.5

AI_SPEECH_PROVIDER=groq
AI_SPEECH_FALLBACK_PROVIDER=cloudflare

# Las credenciales son del proveedor, no del puerto
GEMINI_API_KEY=...
OPENROUTER_API_KEY=...
GROQ_API_KEY=...
```

Cada puerto se configura por separado: pueden usar un proveedor para comandos y otro distinto para imágenes sin tocar código. El respaldo también es por puerto, y el proceso rechaza al arrancar un respaldo idéntico al primario, un proveedor que no sabe atender ese puerto o una credencial que falta ([ADR-019](docs/adr/ADR-019-pasarela-ia-credenciales-y-respaldo.md)).

## 6.4 El adaptador simulado no es opcional

El adaptador `mock` devuelve respuestas fijas y deterministas. Es lo que permite que las pruebas del dominio y el banco de regresión corran en integración continua sin llamar a un servicio de pago ni depender de la red.

Sin él, cada ejecución del banco cuesta dinero y falla cuando el proveedor tiene un mal día. Es media hora de trabajo y se paga sola la primera semana.

## 6.5 Reglas de la capa

| Regla | Detalle |
|---|---|
| Claves solo en el servidor | Ninguna clave de proveedor llega al navegador |
| Salida estructurada | La propuesta de lote se pide con el esquema JSON derivado de los contratos, no se parsea texto libre |
| Tiempo límite y reintentos | Con espera creciente. Un proveedor lento no cuelga la interfaz |
| Cadena de respaldo | Si el proveedor primario falla, se intenta el secundario si está configurado |
| Registro de uso | Peticiones, latencia y coste por proveedor, para diagnosticar y para la defensa |
| El modelo nunca toca el estado | Devuelve una propuesta; el sistema valida y aplica |
| El modelo nunca resuelve identificadores | Devuelve nombres; el resolver los busca en el modelo |

## 6.6 Desambiguación estructural

La decisión de preguntar no se toma con un umbral numérico de confianza: los modelos están mal calibrados y ese umbral produce falsos positivos y negativos sin patrón. Se toma consultando el estado del modelo.

| Situación | Comportamiento |
|---|---|
| El objetivo resuelve a un único elemento | Ejecutar |
| Objetivo ambiguo | Preguntar cuál |
| Faltan operandos | Preguntar el faltante |
| Destructivo de alcance amplio | Confirmar antes de ejecutar |

## 6.7 El asistente no autogenera

El agente asiste, no construye el diagrama completo desde una descripción. El docente fue explícito. La única excepción es la importación desde fotografía o XMI, que por naturaleza produce un lote grande y por eso pasa por vista previa y confirmación.

---

# 7. Reglas de modelado

| ID | Regla |
|---|---|
| RM-01 | Toda relación muchos-a-muchos se modela con clase intermedia explícita y dos relaciones N:1. La herramienta ofrece crearla al detectar una N:M |
| RM-02 | Relaciones directas solo entre dos clases. Tres o más participantes se modelan como entidad |
| RM-03 | Claves primarias de un solo atributo. Sin claves compuestas |
| RM-04 | Multiplicidades soportadas: `1`, `0..1`, `0..*`, `1..*` |
| RM-05 | La generación opera sobre una pizarra seleccionada. Sin relaciones cruzadas entre pizarras |
| RM-06 | Las entidades que se crean sin conexión desde el móvil deben tener clave primaria UUID |
| RM-07 | La generalización se proyecta a tabla por clase unida por la clave primaria. Una sola superclase por clase, sin ciclos, y ningún miembro repetido a lo largo de la cadena |

Sin métodos, sin interfaces, sin clases abstractas y sin herencia múltiple. Cuando aparece algo no soportado, el validador lo identifica con claridad y sugiere cómo modelarlo.

**RM-07 no estaba en la versión 2.0 de este plan**, que excluía la herencia y la trataba como error de validación. Se incorporó porque el diagrama de clases UML sin generalización no es un diagrama de clases: la notación ya estaba en el editor —el triángulo hueco, junto al rombo de composición y al de agregación— y dibujarla sin que llegara al código generado producía un artefacto que no correspondía al modelo. La composición y la agregación siguen compartiendo proyección con la asociación: se distinguen por su notación y por lo que documentan, no por lo que generan.

---

# 8. Reglas de transformación

## RTM-01 — Tipos

| Conceptual | Java | PostgreSQL |
|---|---|---|---|
| String | `String` | `VARCHAR(255)` | `String` |
| Integer | `Integer` | `INTEGER` | `int` |
| Long | `Long` | `BIGINT` | `int` |
| Decimal | `BigDecimal` | `NUMERIC(19,2)` | `double` |
| Boolean | `Boolean` | `BOOLEAN` | `bool` |
| Date | `LocalDate` | `DATE` | `DateTime` |
| DateTime | `LocalDateTime` | `TIMESTAMP` | `DateTime` |
| UUID | `UUID` | `UUID` | `String` |

Longitud de texto y precisión decimal configurables: P2.

## RTM-02 — Nombres

Tres nombres por elemento:

| Campo | Contenido | Ejemplo |
|---|---|---|
| `displayName` | Lo que escribe el usuario | `Número de Teléfono` |
| `codeName` | Identificador válido de código | `numeroTelefono` |
| `databaseName` | Identificador snake_case | `numero_telefono` |

Clases: `Detalle de Venta` → `DetalleVenta` → `detalle_venta`.

Secuencia obligatoria: nombre visual → normalización → validación de identificador → detección de colisión → nombre técnico.

La unicidad se valida sobre los nombres técnicos, nunca sobre el visual. `Número` y `Numero` colapsan al mismo identificador: es error.

## RTM-03 — Palabras reservadas

Se validan tres listas: reservadas del lenguaje de destino, reservadas de PostgreSQL y nombres reservados del generador.

Si el nombre de base de datos es reservado se antepone `app_`:

```
order → app_order
user  → app_user
```

No se usan identificadores entre comillas: dejan la tabla sensible a mayúsculas para siempre y complican cualquier consulta manual.

## RTM-04 — Clave primaria

```
1. ¿Atributo marcado como clave?              → usarlo
2. ¿Un solo candidato por convención
   (id, id<Clase>, <clase>Id)?                → promoverlo + aviso
3. ¿Dos o más candidatos?                     → error, el usuario elige
4. Ninguno                                    → generar id : UUID + aviso
```

La inferencia es deliberadamente estrecha. `ci`, `nit`, `codigoCliente` no se promueven: son identificadores de negocio, no necesariamente claves técnicas. La herramienta no inventa semántica.

## RTM-05 — Relaciones

Solo se genera el lado propietario:

| Modelo | Generado |
|---|---|
| `Cliente 1 ── N Venta` | `Venta` recibe `@ManyToOne Cliente cliente` |
| `Cliente 1 ── 1 Perfil` | `Perfil` recibe `@OneToOne Cliente cliente` |
| N:M | No existe. Resuelto por RM-01 |

Sin colección inversa, sin `mappedBy`, sin `cascade`, sin `orphanRemoval`. Desaparecen los ciclos, la propiedad bidireccional y las colecciones perezosas, y la clave foránea queda igual de correcta.

**Nombre del campo.** Si hay rol, se usa el rol. Si no, se deriva del nombre técnico de la clase destino. Dos relaciones entre el mismo par sin rol producirían campos colisionantes: es error de validación.

**La generalización no produce clave foránea.** Produce una jerarquía, y su proyección está en RTM-13.

**Compensación.** Por cada clave foránea se emite un finder con navegación explícita de propiedad, expuesto como parámetro de consulta:

```java
List<Venta> findByCliente_Id(UUID clienteId);
```
```
GET /api/venta?clienteId={uuid}
```

Sin esto no habría forma de consultar las ventas de un cliente, que es exactamente lo que la app móvil necesita.

## RTM-06 — Opcionalidad

| Multiplicidad del destino | Generado | Columna |
|---|---|---|
| `1` | `@ManyToOne(optional = false)` | `NOT NULL` |
| `0..1` | `@ManyToOne(optional = true)` | `NULL` |

Atributos:

| Marcador | Generado |
|---|---|
| `nullable = false` | `@Column(nullable = false)` |
| `unique = true` | `@Column(unique = true)` |

## RTM-07 — Propietario en uno a uno

La clase destino recibe la clave foránea. `Persona 1 ── 1 Perfil` produce `perfil.persona_id`. La elección es arbitraria; lo que importa es que sea invariable, y vive en la representación intermedia.

## RTM-08 — Rutas REST

```
GET    /api/{recurso}
GET    /api/{recurso}/{id}
GET    /api/{recurso}?{fk}={uuid}
POST   /api/{recurso}
PUT    /api/{recurso}/{id}
DELETE /api/{recurso}/{id}
```

El recurso es el nombre técnico en kebab-case y singular: `Cliente` → `cliente`, `DetalleVenta` → `detalle-venta`, `Order` → `order`.

Singular para eliminar la pluralización del español, que introduce irregulares sin aportar nada. Derivado del nombre de código y no del de base de datos, para que el prefijo `app_` no se filtre a las URL.

## RTM-09 — DTO

Un registro plano por entidad, para entrada y salida. Las relaciones se expresan como identificador, nunca como objeto anidado.

```java
public record VentaDTO(UUID id, LocalDate fecha, BigDecimal total, UUID clienteId) {}
```

Elimina por construcción los ciclos de serialización. No se usan anotaciones de referencia gestionada: ocultan el ciclo pero también el dato, y la app móvil recibiría ventas sin cliente.

Se implementa desde el primer generador aunque el docente lo haya planteado como opcional: introducirlo después obliga a reescribir todos los controladores.

## RTM-10 — Errores

Integridad referencial restrictiva, sin cascada. La restricción por sí sola no basta: sin traducción, una violación sale como error de servidor. El generador emite un manejador global fijo:

| Situación | Respuesta |
|---|---|
| Violación de integridad referencial | `409` |
| Entidad no encontrada | `404` |
| Validación de campos | `400` |
| Conflicto de versión | `409` |

Con cuerpo de error uniforme.

## RTM-11 — Identificadores del cliente e idempotencia

1. La clave primaria UUID se declara sin generación automática. Si la llevara, el identificador enviado por el cliente se ignoraría o dispararía una actualización en lugar de un alta.
2. El servicio asigna un UUID solo si la petición no trae uno.
3. `POST` sobre un identificador existente devuelve el recurso existente. No duplica ni falla.

El punto 3 hace idempotentes las creaciones sin infraestructura adicional: un reintento tras un tiempo de espera agotado devuelve el mismo registro. Las demás operaciones ya son idempotentes por naturaleza.

Esto depende de RM-06. Como la creación sin conexión está restringida a entidades con clave UUID, una tabla de operaciones procesadas sería infraestructura para un caso que no existe. Queda P2.

## RTM-12 — Paquete y artefacto

```
Proyecto:  Sistema de Ventas
codeName:  sistemaVentas
artifact:  sistema-ventas
paquete:   bo.edu.sw1.sistemaventas
```

Determinista. Nunca decidido por un modelo.

---

## RTM-13 — Generalización

Tabla por clase, unida por la clave primaria. `Estudiante ▷ Persona` produce:

```java
@Entity @Table(name = "persona")
@Inheritance(strategy = InheritanceType.JOINED)
public class Persona { @Id private UUID id; private String nombre; }

@Entity @Table(name = "estudiante")
@PrimaryKeyJoinColumn(name = "id")
public class Estudiante extends Persona { private String matricula; }
```

| Decisión | Por qué |
|---|---|
| La clave primaria sale de la **raíz** de la jerarquía, no de la superclase directa | Es la columna por la que se unen todas las tablas de la cadena. Una subclase que declara clave propia recibe aviso y esa clave pasa a ser una columna más |
| La subclase **no** vuelve a declarar nada heredado | Un segundo `@Id`, o un campo repetido, compila y rompe el arranque de Hibernate. Es error de validación (CA-017.1) |
| El DTO y el servicio **sí** trabajan con la entidad completa | Crear un estudiante por su propia ruta tiene que poder mandar el nombre, que vive en `persona`. `EstudianteDTO` lleva las columnas de toda la cadena |
| Solo la raíz declara la estrategia | `@Inheritance` en un nivel intermedio no significa nada |

La colección de una superclase devuelve también las filas de sus subclases: en JPA una subclase **es** una superclase, y `GET /api/persona` con un estudiante dado de alta devuelve dos registros.

Otras estrategias —tabla única con discriminador, tabla por clase concreta— quedan fuera. La unida es la única que conserva las columnas de cada clase en su propia tabla sin columnas nulas ni datos repetidos, que es lo que el modelo conceptual dice.

---

# 9. Requisitos funcionales

## M0 · Cuenta, proyectos y pizarras

Ver sección 5.6 para los requisitos de autenticación y membresía.

| ID | Requisito | Origen | Prio |
|---|---|---|---|
| RF-001 | Crear, abrir, listar y eliminar proyectos | DER | P0 |
| RF-002 | Crear varias pizarras dentro de un proyecto | PROY | P0 |
| RF-003 | Renombrar, abrir, cerrar y eliminar pizarras | PROY | P0 |
| RF-004 | Sesión colaborativa independiente por pizarra | DER | P0 |
| RF-005 | Seleccionar la pizarra objetivo para generar | DER | P0 |

**CA-004.1** — Dos pizarras del mismo proyecto abiertas simultáneamente no mezclan actualizaciones.

## M1 · Editor

| ID | Requisito | Origen | Prio |
|---|---|---|---|
| RF-010 | Crear, renombrar, mover y eliminar clases | DOC | P0 |
| RF-011 | Agregar, modificar y eliminar atributos | DOC | P0 |
| RF-012 | Definir tipo, clave primaria, nulabilidad y unicidad | DER | P0 |
| RF-013 | Crear, modificar y eliminar relaciones | DOC | P0 |
| RF-014 | Definir multiplicidad en ambos extremos | DOC | P0 |
| RF-015 | Definir nombre de rol en los extremos | DER | P1 |
| RF-016 | Seleccionar, mover, conectar, eliminar, zoom y desplazamiento | DOC | P0 |
| RF-017 | Validar con niveles de error y aviso | DER | P0 |
| RF-018 | Deshacer el último comando propio | OPT | P2 |

**CA-015.1** — Dadas dos relaciones entre `Venta` y `Cliente` con roles `facturacion` y `envio`, el backend generado produce dos campos distintos y compila.

**CA-017.1 — Error, bloquea la generación:** clase sin nombre · nombres duplicados tras normalizar · tipo no soportado · relación a clase inexistente · varios candidatos a clave · clave compuesta · dos relaciones entre el mismo par sin rol · una clase que se generaliza a sí misma · dos superclases · un ciclo de herencia · un miembro declarado que tapa a otro heredado.

**CA-017.2 — Aviso, permite generar:** clave inferida · clave autogenerada · nombre normalizado · nombre reservado con prefijo · clase sin relaciones.

## M2 · Colaboración

| ID | Requisito | Origen | Prio |
|---|---|---|---|
| RF-020 | Varios usuarios editan la misma pizarra | DOC | P0 |
| RF-021 | Cada participante tiene identidad autenticada | DER | P0 |
| RF-022 | Propagación en tiempo real sin recargar | DOC | P0 |
| RF-023 | Sincronización incremental | DOC | P0 |
| RF-024 | Entrega del estado actual a quien se incorpora | DER | P0 |
| RF-025 | Convergencia ante operaciones concurrentes | DOC | P0 |
| RF-026 | Presencia: conectados y elemento en edición | DER | P1 |

**CA-022.1** — Dados dos navegadores con la misma pizarra abierta, cuando A crea `Producto`, B lo ve sin recargar.

**CA-023.1** — Durante la edición se transmiten actualizaciones incrementales del documento, nunca una sustitución completa. El protocolo de tiempo real no transporta comandos de dominio: el comando se aplica localmente y viaja la actualización resultante. Los comandos se registran para auditoría, no para sincronizar.

**CA-024.1** — Dada una pizarra de 10 clases construida durante 20 minutos, cuando un tercer usuario la abre recibe las 10 clases y luego solo actualizaciones.

**CA-025.1** — Dos usuarios crean concurrentemente nombres que colapsan al mismo identificador. El documento converge y el validador marca error antes de permitir generar.

## M3 · Asistente

| ID | Requisito | Origen | Prio |
|---|---|---|---|
| RF-030 | Instrucciones por texto | DOC | P0 |
| RF-031 | Instrucciones por voz | DOC | P0 |
| RF-032 | Traducir la instrucción a un lote validado como unidad | DER | P0 |
| RF-033 | Modificar solo lo afectado, con las mismas reglas que la interfaz | DOC | P0 |
| RF-034 | Pedir aclaración ante ambigüedad | DER | P1 |
| RF-035 | Confirmar operaciones destructivas amplias | DER | P1 |
| RF-036 | Responder consultas sobre la pizarra sin modificarla | PROY | P1 |
| RF-037 | Señalar problemas y sugerir mejoras sin aplicarlas | PROY | P1 |

**CA-032.1** — Dado `Cliente` con `nombre`, cuando el usuario dice "agrega teléfono tipo String a Cliente", queda con `nombre` y `telefono` y ningún otro elemento cambia.

**CA-032.2** — Dado "crea Cliente con nombre, teléfono y correo", si un comando del lote es inválido no se aplica ninguno.

## M4 · Importación por imagen

| ID | Requisito | Origen | Prio |
|---|---|---|---|
| RF-040 | Cargar la foto de un diagrama, subiéndola o tomándola con la cámara | DOC | P0 |
| RF-041 | Producir un modelo candidato con clases, atributos, relaciones y multiplicidades | DOC | P0 |
| RF-042 | Corregir el candidato antes de aplicarlo | DER | P0 |
| RF-043 | Aplicarlo como lote validado | DER | P0 |
| RF-044 | Elegir entre agregar o reemplazar el contenido | DER | P1 |

**CA-042.1** — El resultado se presenta como propuesta editable y nunca se aplica automáticamente. El reconocimiento de un pizarrón se va a equivocar en algo; un candidato que no se puede corregir no sirve.

## M5 · Interoperabilidad

| ID | Requisito | Origen | Prio |
|---|---|---|---|
| RF-050 | Exportar la pizarra a XMI abrible en Enterprise Architect | DOC | P0 |
| RF-051 | Importar XMI de Enterprise Architect | DOC | P1 |
| RF-052 | Validar la importación contra las reglas del dominio | DER | P0 |
| RF-053 | Round-trip con preservación de identidad | OPT | P2 |

La variante de XMI se determina con archivos reales exportados de la instalación del laboratorio, no con el estándar teórico. Si hay que recortar, exportar es lo que no se sacrifica: el caso de uso del docente es hacer el diagrama de secuencia sobre clases que ya existen.

## M6 · Generación del backend

| ID | Requisito | Origen | Prio |
|---|---|---|---|
| RF-060 | Tomar un snapshot inmutable al iniciar la generación | DER | P0 |
| RF-061 | Generar el proyecto Spring Boot en ZIP | DOC | P0 |
| RF-062 | Generar Entity, Repository, Service y Controller por entidad | DOC | P0 |
| RF-063 | Generar DTO plano por entidad | DER | P0 |
| RF-064 | Traducir relaciones a mapeo de persistencia | DOC | P0 |
| RF-065 | Crear el esquema PostgreSQL desde las entidades | DOC | P0 |
| RF-066 | Exponer CRUD REST y finders por clave foránea | DER | P0 |
| RF-067 | Generar el manejador global de errores | DER | P0 |
| RF-068 | Producir código que compila y arranca sin editar fuente | DOC | P0 |
| RF-069 | Generar colección Postman | DOC | P1 |
| RF-070 | Generar contrato OpenAPI e interfaz de exploración | DER | P1 |
| RF-071 | Incluir Dockerfile, compose, ejemplo de entorno, README y manifiesto | PROY | P1 |
| RF-072 | Cada generación produce un artefacto independiente | DER | P0 |

**CA-068.1** — Dado un modelo válido, la compilación termina con éxito sin editar código.
**CA-068.2** — Lo único configurable externamente son los datos de conexión a la base.
**CA-060.1** — Si durante la generación otro usuario modifica la pizarra, el ZIP corresponde al snapshot inicial.

# 10. Aplicación móvil que consume el backend generado

La herramienta **no** genera esta aplicación, ni sus pantallas ni su capa de datos. El equipo la construye durante la defensa sobre el backend generado, usando su contrato REST y su colección de Postman como punto de partida.

Los requisitos que siguen describen esa aplicación, no un artefacto de la herramienta.

| ID | Requisito | Origen | Prio |
|---|---|---|---|
| RFM-01 | Consumir el backend generado | DOC | P0 |
| RFM-02 | Operar las funciones principales por voz | DOC | P0 |
| RFM-03 | Reconocimiento de voz en el dispositivo | DOC | P0 |
| RFM-04 | Interpretación de intenciones en el dispositivo | DOC | P0 |
| RFM-05 | Ejecutar acciones contra la base local | DER | P0 |
| RFM-06 | Descargar y mantener catálogos localmente | DER | P0 |
| RFM-07 | Resolver entidades contra datos locales | DER | P0 |
| RFM-08 | Registrar operaciones sin conexión | DOC | P0 |
| RFM-09 | Cola de sincronización persistente | DER | P0 |
| RFM-10 | Sincronizar al recuperar la conexión sin duplicar | DOC | P0 |
| RFM-11 | Detectar conflictos de actualización por versión | DER | P1 |
| RFM-12 | Respuesta hablada | OPT | P1 |

**CA-03.1** — En modo avión la cadena completa funciona sin ninguna petición de red: micrófono → reconocimiento local → intención local → acción → base local.

**CA-06.1** — Antes de perder conexión la aplicación tiene localmente los clientes, productos o servicios que necesita referenciar. Sin esto no puede crear ningún registro con clave foránea, que es casi cualquier registro útil. La sincronización descendente es tan obligatoria como la ascendente.

**CA-07.1** — Dado "registra una atención a Carlos Pérez", la aplicación resuelve el nombre contra el catálogo local. Si hay varias coincidencias, pregunta. Nunca inventa un identificador.

**CA-10.1** — Un reintento tras tiempo de espera agotado no duplica el registro.

## 10.1 Arquitectura del agente local

```
Micrófono
    ↓
Reconocimiento en dispositivo
    ↓
Clasificador de intenciones local
    ↓
Selección de acción
    ↓
Resolución determinista de entidades (base local)
    ↓
Escritura local + cola de sincronización
```

El modelo interpreta; el código resuelve los datos reales. El modelo nunca produce identificadores: produce un nombre, y el resolver lo busca.

Para cuatro o cinco intenciones no hace falta un modelo de lenguaje grande. Un clasificador entrenado fuera del dispositivo y exportado como vocabulario y pesos pesa kilobytes, responde de inmediato, funciona sin conexión y sin acelerador gráfico, y sigue siendo aprendizaje automático. Un modelo de lenguaje local con selección de herramientas es la alternativa a evaluar en el sondeo de la primera semana; el clasificador es el plan, no el respaldo improvisado.

Presentar coincidencia de cadenas como inteligencia artificial es indefendible frente al docente. El clasificador entrenado se explica en un minuto.

## 10.2 Estados de la cola

```
PENDIENTE → SINCRONIZANDO → SINCRONIZADO
                ↓
            FALLIDO / EN CONFLICTO
```

Cada operación lleva identificador propio, identificador de entidad, tipo, carga, estado, intentos y último error.

---

# 11. Requisitos no funcionales

| ID | Objetivo |
|---|---|
| RNF-01 | Propagación colaborativa por debajo de 500 ms (P95) en red local estable |
| RNF-02 | Al menos 5 participantes simultáneos por pizarra |
| RNF-03 | Edición fluida con 30 clases, 100 atributos y 40 relaciones |
| RNF-04 | Un proyecto abre y alterna entre al menos 10 pizarras sin mezclar sesiones |
| RNF-05 | Determinismo: mismo snapshot y misma versión del generador producen el mismo código, salvo metadatos |
| RNF-06 | Código generado legible, convencional, sin dependencias que requieran plugins de IDE |
| RNF-07 | Generación por debajo de 10 segundos para los modelos del banco |
| RNF-08 | Seguridad: contraseñas con derivación lenta, claves de proveedores solo en el servidor, secretos por variables de entorno, autorización en HTTP y en WebSocket, límites de tipo y tamaño en cargas, validación de todo lote recibido |
| RNF-09 | En modo avión la cadena de voz del móvil funciona sin ninguna petición de red |
| RNF-10 | Cerrar y reabrir la app sin conexión no pierde operaciones pendientes |
| RNF-11 | Conjunto de al menos 20 frases de prueba del agente móvil, con 90% de acierto antes de la defensa |
| RNF-12 | La plataforma se levanta completa con un solo comando |
| RNF-13 | Integración continua: cada cambio al generador ejecuta al menos T01; la rama principal ejecuta el banco completo |
| RNF-14 | Registro estructurado con proyecto, pizarra, sesión, lote, comando, generación, actor y origen |
| RNF-15 | El paquete de dominio se prueba sin navegador, sin base de datos, sin WebSocket, sin proveedor de IA y sin sistema de archivos |

Estos números son objetivos de ingeniería adoptados por el equipo, no cifras exigidas por el docente. Se miden antes de comprometerse en la defensa.

---

# 12. Fuera de alcance

Métodos e interfaces · clases abstractas · herencia múltiple · estrategias de herencia distintas de la tabla por clase · agregación y composición con semántica de persistencia propia · otros diagramas UML · claves compuestas · relaciones ternarias directas · relación muchos-a-muchos directa en el generador · cascadas destructivas · regeneración incremental sobre código ya generado · ingeniería inversa de código a modelo · generación de pantallas y navegación móvil (P2) · IA local en la herramienta web · paginación, filtrado avanzado y seguridad en el CRUD generado · migraciones versionadas · correspondencia de identificadores para claves no UUID · inicio de sesión con terceros, verificación por correo y recuperación de contraseña · fusión de varias pizarras en un sistema · infraestructura como código · microservicios · brokers de mensajería · Kubernetes · event sourcing · CQRS completo.

Cada una de estas exclusiones está declarada, no omitida. Cuando el validador encuentra una construcción no soportada la identifica y sugiere cómo modelarla.

---

# 13. Docker: servicios, perfiles y control individual

## 13.1 Objetivo

Que cualquier integrante levante el entorno completo con un comando, y que pueda apagar o reiniciar piezas individuales sin tocar el resto. Cada servicio tiene una responsabilidad y se documenta para qué sirve, de qué depende y cómo se apaga.

## 13.2 Servicios

| Servicio | Responsabilidad | Depende de | Perfil |
|---|---|---|---|
| `db` | PostgreSQL de la plataforma | — | por defecto |
| `api` | Proceso HTTP: sesión, proyectos, pizarras, IA, imagen, XMI, generación | `db` | por defecto |
| `collab` | Proceso WebSocket: salas, presencia, persistencia del documento | `db` | por defecto |
| `web` | Interfaz React | `api` | por defecto |
| `proxy` | Origen único para la demostración | `api`, `collab`, `web` | `demo` |
| `adminer` | Inspección de la base durante el desarrollo | `db` | `tools` |

Los perfiles hacen que un servicio no arranque salvo que se pida expresamente. Así el entorno diario queda liviano y el de demostración se enciende solo cuando hace falta.

## 13.3 Comandos

```bash
# Todo el entorno de desarrollo
docker compose up -d

# Añadir el proxy para la demostración
docker compose --profile demo up -d

# Añadir las herramientas de inspección
docker compose --profile tools up -d

# Apagar un solo servicio
docker compose stop collab

# Reiniciar uno solo tras un cambio
docker compose restart api

# Reconstruir uno solo
docker compose up -d --build api

# Ver el estado y la salud de todos
docker compose ps

# Seguir los registros de uno
docker compose logs -f collab

# Apagar todo conservando los datos
docker compose down

# Apagar y borrar los datos
docker compose down -v
```

## 13.4 Reglas de la composición

- Cada servicio declara una comprobación de salud, y quien depende de él espera a que esté sano. Evita el error clásico del servidor que arranca antes que la base.
- Los datos viven en volúmenes con nombre. Reiniciar un contenedor no borra nada; solo `down -v` lo hace.
- Toda la configuración entra por variables de entorno, con un archivo de ejemplo versionado y el real ignorado.
- Ningún secreto queda escrito en la composición.
- Los puertos se exponen solo donde hacen falta. Con el perfil de demostración, únicamente el proxy queda expuesto.
- Los procesos `api` y `collab` no guardan estado en memoria propia: todo va a la base. Es lo que permitirá replicarlos más adelante sin rediseñar.

## 13.5 El backend generado trae su propia composición

Independiente de la plataforma. Dentro del ZIP:

```
compose.yaml     base de datos + aplicación
Dockerfile
.env.example
README.md
```

Un solo comando levanta el proyecto generado con su base. Es la salvaguarda para el día de la defensa: si la máquina donde se abre el proyecto no tiene PostgreSQL instalado, o tiene otra versión, o el puerto ocupado, la composición lo resuelve.

---

# 14. Escalabilidad futura

El diseño deja el camino abierto sin construir nada ahora.

| Cuándo | Qué se hace | Por qué se puede |
|---|---|---|
| Varias instancias de colaboración | Adaptador de mensajería compartida entre instancias | Los procesos no guardan estado propio |
| Generación pesada | Extraer la generación a un proceso trabajador con cola | Ya recibe un snapshot y devuelve un artefacto: frontera limpia |
| Procesamiento de imágenes lento | Mismo patrón que la generación | Mismo tipo de frontera |
| Muchas peticiones HTTP | Replicar el proceso HTTP detrás del proxy | Sin sesión en memoria |
| Almacenamiento de fotografías | Almacenamiento de objetos externo | Hoy son temporales |
| Despliegue persistente real | Infraestructura como código para servidor, red y DNS | La aplicación ya está en contenedores |

Los primeros candidatos a separar son generación e imágenes, porque consumen tiempo y son fáciles de aislar. Nunca separar por moda: dividir el módulo de proyectos o el de usuarios en servicios propios no resuelve ningún problema real de este sistema.

No se implementa nada de esto durante el parcial.

---

# 15. Calidad

## 15.1 Definition of Done del generador

Para cada modelo del banco, contra una base limpia:

```
MODELO
 ↓ validar
 ↓ snapshot inmutable
 ↓ representación intermedia
 ↓ generar backend
 ↓ compilar el backend
 ↓ arrancar
 ↓ crear esquema
 ↓ el contrato OpenAPI carga
 ↓ alta de entidades raíz        (orden topológico de dependencias)
 ↓ alta de entidades dependientes
 ↓ consulta de colección
 ↓ consulta por identificador
 ↓ consulta por clave foránea
 ↓ modificación
 ↓ alta repetida con mismo identificador → sin duplicado
 ↓ borrado de padre con hijos           → 409 esperado
 ↓ borrado en orden inverso
 ↓ reiniciar
 ↓ los datos siguen ahí
 ✓
```

La compilación exitosa por sí sola no significa que el generador funciona. El ciclo de serialización, la violación de clave foránea, el error sin traducir y el borrado accidental del esquema solo aparecen ejecutando.

El `409` al borrar un padre con hijos es un caso de éxito, no un fallo. El reinicio final verifica que la configuración de esquema no destruye datos entre arranques.

## 15.2 Banco de regresión

| ID | Modelo | Cobertura |
|---|---|---|
| T01 | Cliente · Producto · Venta · DetalleVenta | 1:N, N:1, decimales, fechas, entidad intermedia |
| T02 | Proveedor · Compra · DetalleCompra · Producto | Mismo patrón, otra terminología |
| T03 | Cliente · Barbero · Servicio · Atencion | Caso de la aplicación móvil |
| T04 | Activo · Categoria · Responsable · Asignacion | Varias claves foráneas sobre una entidad |
| T05 | Cliente · Cuenta · Movimiento | Cadena de tres niveles |
| T06 | Alumno · Materia · Inscripcion | Muchos a muchos con atributos |
| T07 | Modelo hostil | Ver abajo |
| T08 | Persona · Empleado · Docente · Estudiante · Departamento · Materia · Inscripcion | Generalización (RM-07) |

T08 se añadió con RM-07 y es el único modelo del banco con herencia. Encadena tres niveles —`Docente ▷ Empleado ▷ Persona`—, pone dos hermanas bajo la misma raíz, deja que `Docente` herede una clave foránea que declara `Empleado` y hace que otra clave foránea apunte a una subclase. Con dos niveles no se distinguiría heredar de la superclase de heredar de la raíz, que es de donde sale la clave primaria.

T07 es obligatorio y contiene deliberadamente: una clase `Order`, una clase `Número de Cuenta`, un atributo `class`, una clase sin clave primaria, dos clases que normalizan al mismo identificador, dos relaciones entre el mismo par con roles distintos, una multiplicidad `0..1` y un atributo único. Ejercita de una sola vez normalización, las tres listas de reservadas, inferencia de clave, colisiones, derivación por rol y opcionalidad.

Generación aleatoria de modelos: P2, después del banco manual.

## 15.3 Definition of Done del móvil sin conexión

```
Aplicación instalada
 ↓ sincronización inicial de catálogos con conexión
 ↓ modo avión
 ↓ orden por voz
 ↓ reconocimiento local
 ↓ intención local
 ↓ acción seleccionada
 ↓ entidad resuelta contra la base local
 ↓ escritura local
 ↓ consulta del resultado por voz
 ↓ cerrar y reabrir la aplicación
 ↓ los datos siguen ahí
 ↓ salir de modo avión
 ↓ sincronizar
 ↓ el servidor recibe exactamente una operación
 ✓
```

## 15.4 Pruebas de colaboración

Cinco pruebas de extremo a extremo, no más:

1. A crea una clase, B la ve.
2. A mueve una clase, B lo ve.
3. A cambia una multiplicidad, B lo ve.
4. Un tercer usuario entra tarde y recibe el estado actual.
5. Dos pizarras del mismo proyecto no mezclan actualizaciones.

Más una de seguridad: un no miembro no puede conectarse a una sala.

## 15.5 Adaptador simulado en integración continua

El banco de regresión y las pruebas del dominio usan el adaptador simulado de IA. Nunca llaman a un proveedor real. Sin esto, cada ejecución cuesta dinero y falla cuando el proveedor tiene un mal día.

---

# 16. Plan de trabajo

## 16.1 Principio

Un plan secuencial deja los riesgos desconocidos para el final, que es donde no hay margen. Los riesgos que no dependen del esfuerzo del equipo se atacan en la primera semana aunque nada más esté listo.

## Semana 1 (28 ago – 3 sep) — Contratos, spikes y sondeos

Bloque común:

1. Esquemas de proyecto, pizarra y modelo canónico en `shared/contracts`, como fuente única de tipos, validación y esquema para el modelo de lenguaje.
2. Aplicador de comandos y validador en `shared/domain-core`, con pruebas sin ninguna dependencia externa.
3. Esquema de base de datos con usuarios, proyectos, membresías y pizarras.

Dos spikes que validan la arquitectura:

4. **Generación**: un modelo T01 escrito a mano entra al generador, sale un proyecto Spring Boot, compila.
5. **Colaboración**: dos navegadores modifican el mismo documento a través del paquete de dominio y convergen, con autorización en la conexión.

Dos sondeos de riesgo externo:

6. Obtener la versión de Enterprise Architect del laboratorio, exportar dos o tres archivos de referencia como fixtures, y confirmar con el docente si exige ambos sentidos o basta con exportar.
7. Probar el reconocimiento de voz sin conexión en el teléfono real, comparando al menos dos motores por tamaño del modelo en español, latencia y memoria. Solo transcribir una frase, sin aplicación alrededor.

Si los dos spikes funcionan, la arquitectura está validada y el resto es construcción. El riesgo aquí no es la librería de canvas, que es madura; es que el paquete de dominio y el documento colaborativo encajen limpiamente.

## Semana 2 (4 – 10 sep) — Vertical slice

- Registro, sesión, proyectos, pizarras e invitación.
- Generación completa de T01 con el pipeline hasta el `409` esperado, con DTO desde el principio.
- Editor sobre el documento colaborativo, dos navegadores editando de verdad.
- Integración continua con T01 y el adaptador simulado.
- Arranque de la aplicación móvil contra el backend de T01, aunque sea con una pantalla y sin voz.

La aplicación móvil no puede empezar en la última semana: es la pieza con más incógnitas y la única que depende de hardware.

## Semana 3 (11 – 17 sep) — Frentes en paralelo

- Asistente por texto y voz, y consultas sobre la pizarra.
- Importación por imagen con vista previa y corrección.
- Exportación e importación XMI contra los fixtures reales.
- Resto del banco: T02 a T08.
- Móvil: catálogos descendentes, agente local, operación sin conexión y cola de sincronización.

## Semana 4 (18 – 22 sep) — Integración y ensayo

- 18 y 19: integración de todos los frentes. Ninguna funcionalidad nueva a partir del 19.
- 20: banco completo en verde, incluido T07.
- 21: ensayo completo cronometrado.
- 22: congelamiento y preparativos. Solo corrección de defectos del ensayo.

## 23 sep — Presentación

## 16.2 Guion del ensayo

```
Iniciar sesión en dos computadoras con dos cuentas
→ crear proyecto y dos pizarras
→ invitar al segundo usuario por enlace
→ abrir la misma pizarra en ambas
→ crear una clase por interfaz en una, verla en la otra
→ crear y modificar elementos por voz
→ hacer una consulta al asistente sobre el modelo
→ importar una fotografía del pizarrón y corregir el candidato
→ exportar XMI y abrirlo en Enterprise Architect
→ seleccionar la pizarra y generar
→ descargar el ZIP, abrirlo en el IDE, configurar la base y ejecutar
→ verificar las tablas en PostgreSQL
→ probar los endpoints con Postman
→ construir el frontend móvil en vivo sobre la capa de datos generada
→ registrar por voz, activar modo avión, registrar de nuevo
→ reconectar y verificar la sincronización sin duplicados
```

Si un paso falla en el ensayo, hay dos días. Si falla el 23, no hay ninguno.

## 16.3 Preparativos del día 22

Todo lo descargable debe estar en caché local antes de salir:

- repositorio de dependencias Java poblado (si el banco corrió, ya lo está);
- imágenes de contenedor construidas;
- dependencias del monorepo y del proyecto móvil instaladas;
- modelo de voz y clasificador instalados en el teléfono;
- Enterprise Architect abierto y probado en la máquina que se llevará;
- cuentas de prueba creadas y proyecto de demostración listo.

## 16.4 Plan de degradación sin conexión

El aula puede no tener internet. Conviene saber de antemano qué sigue funcionando:

| Funcionalidad | ¿Necesita internet? |
|---|---|
| Registro, sesión y proyectos | No, servidor local |
| Editor y colaboración entre computadoras | No, red local |
| Generación del backend | No, plantillas locales |
| Compilar y ejecutar el proyecto generado | No, con dependencias en caché |
| Base de datos y pruebas con Postman | No |
| App móvil: voz, agente local, registro sin conexión | No, es el requisito |
| Asistente de la herramienta por texto y voz | **Sí** |
| Reconocimiento de la fotografía | **Sí** |

Solo dos funcionalidades dependen de conexión, y son dos de las tres vías con las que el docente cargará el modelo. Mitigación: punto de acceso móvil de respaldo verificado antes de empezar. La tercera vía, el dibujo manual, funciona siempre y sirve de plan alternativo si la red cae en mitad de la demostración.

---

# 17. ADR obligatorios

Una página cada uno. Sirven directamente para responder en la defensa.

```
ADR-001  Monolito modular con dos procesos, no microservicios
ADR-002  CRDT para la colaboración en tiempo real
ADR-003  Modelo canónico único con comandos y lotes atómicos
ADR-004  Varias pizarras, generación sobre una pizarra seleccionada
ADR-005  Entidad intermedia explícita para muchos a muchos
ADR-006  Sin event sourcing ni CQRS completo
ADR-007  Generación por representación intermedia y plantillas
ADR-008  DTO planos y relaciones unidireccionales
ADR-009  Runtime compartido entre navegador y servidor
ADR-010  Docker Compose, infraestructura como código diferida
ADR-011  Generación limitada a la capa de datos del cliente móvil
ADR-012  Agente móvil local con resolución determinista de entidades
ADR-013  Creación sin conexión requiere clave primaria UUID
ADR-014  Autenticación propia mínima con roles por proyecto
ADR-015  Proveedores de IA detrás de puertos intercambiables
ADR-016  Matriz de versiones congelada, con fecha de verificación
```

---

# 18. Riesgos

| Riesgo | Mitigación |
|---|---|
| El ZIP no compila con el modelo que dibuje el docente | Banco T01–T08, con el modelo hostil y la jerarquía |
| El XMI exportado no abre en la instalación del docente | Fixtures reales de esa instalación, semana 1 |
| La aplicación móvil queda muda sin conexión | Reconocimiento en dispositivo, verificado en modo avión |
| No se puede registrar nada sin conexión por falta de catálogos | Sincronización descendente, CA-06.1 |
| Colisión de nombres al normalizar | Validación sobre los nombres técnicos |
| El entorno del docente no coincide con el generado | Verificar la versión de destino y llevar la composición de contenedores |
| Ciclo de serialización al consultar entidades relacionadas | DTO planos desde el primer generador |
| Cualquiera entra a una pizarra conociendo su identificador | Autorización en la conexión de colaboración, no solo en HTTP |
| El aula no tiene internet | Plan de degradación y punto de acceso de respaldo |
| Análisis interminable sin código | El alcance está congelado. Todo problema nuevo aparece primero como prueba fallando |

---

# 19. Criterio de congelamiento

A partir de este documento no se agregan requisitos P0 ni P1, salvo que una prueba, un spike o una aclaración explícita del docente demuestre que falta algo necesario. Toda idea nueva se registra en P2.

Sobre las versiones: verificar cada una el primer día, comprobar la compatibilidad entre las piezas que dependen entre sí, y clavarlas en los archivos de bloqueo. Registrar la matriz con su fecha en el ADR-016. Un número copiado de un documento es una suposición, no una decisión.

El objetivo desde este momento es transformar especificación en software.
````

---

## Material de defensa

### Estructura

```text
docs/examen/
|-- parte-1-fundamentacion-teorica.md
|-- parte-2-proceso-de-desarrollo.md
`-- perfil-del-proyecto.md
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `docs/examen/parte-1-fundamentacion-teorica.md` | 1276 |
| `docs/examen/parte-2-proceso-de-desarrollo.md` | 1979 |
| `docs/examen/perfil-del-proyecto.md` | 387 |

---

### `docs/examen/parte-1-fundamentacion-teorica.md`

````markdown
# PARTE I — FUNDAMENTACIÓN TEÓRICA

> **Proyecto:** UMLFORGE AI — Plataforma colaborativa asistida por inteligencia
> artificial para el modelado de diagramas de clases UML, reconocimiento de
> bocetos y generación automática de backend Spring Boot a partir de los
> diagramas.
> **Materia:** Ingeniería de Software 1 · Primer Examen Parcial · Periodo 02/2026
> **Estudiante:** Blanco Camacho Brayan Edgar · Registro 219182965 · Grupo SB
> **Docente:** Ing. Martínez Canedo Rolando Antoni
> **Universidad Autónoma Gabriel René Moreno — Facultad de Ingeniería en
> Ciencias de la Computación y Telecomunicaciones**
> **Santa Cruz de la Sierra — Bolivia**

*La numeración de las secciones (1 a 7) corresponde exactamente al índice del
documento del examen.*

---

## 1. Ingeniería de Software Asistido por Computadoras (C.A.S.E.)

### 1.1 Definición

**C.A.S.E.** son las siglas de *Computer-Aided Software Engineering* —Ingeniería
de Software Asistida por Computadora—. Designa al conjunto de herramientas y
métodos informáticos que dan soporte automatizado a las actividades del proceso
de desarrollo de software: análisis, diseño, construcción, prueba,
documentación y mantenimiento.

La idea de fondo es simple y proviene de la ingeniería tradicional: así como un
ingeniero civil no calcula estructuras a mano ni dibuja planos con tiralíneas,
el ingeniero de software no debería producir modelos, código repetitivo y
documentación de forma artesanal. La herramienta CASE traslada al computador el
trabajo mecánico, repetible y propenso a error, y deja al ingeniero el trabajo
de decisión.

Pressman define la tecnología CASE como el conjunto de herramientas que
proporcionan al ingeniero de software la capacidad de automatizar actividades
manuales y de mejorar su comprensión del sistema, del mismo modo en que el CAD
(*Computer-Aided Design*) transformó el diseño mecánico y electrónico
(Pressman & Maxim, 2020).

### 1.2 Clasificación de las herramientas CASE

La clasificación clásica —recogida por Sommerville (2016) y formalizada por
Fuggetta (1993)— distingue tres niveles según su alcance:

| Nivel | Nombre | Alcance | Ejemplos |
|---|---|---|---|
| **Upper CASE** | CASE superior | Fases tempranas: requisitos, análisis, diseño, modelado | Herramientas de diagramación UML, diccionarios de datos, modeladores E-R |
| **Lower CASE** | CASE inferior | Fases tardías: codificación, pruebas, depuración, despliegue | Generadores de código, depuradores, herramientas de prueba automatizada |
| **I-CASE** | CASE integrado | Cubre el ciclo completo con un repositorio único compartido | Suites que integran modelado, generación, versionado y trazabilidad |

Fuggetta (1993) propone además la distinción operativa que hoy sigue vigente:

- **Tools (herramientas):** apoyan una tarea concreta y aislada.
- **Workbenches (bancos de trabajo):** integran varias herramientas que
  comparten un mismo modelo de datos y dan soporte a una fase completa.
- **Environments (entornos):** integran bancos de trabajo a lo largo de todo el
  proceso, con un repositorio común y control del flujo de trabajo.

### 1.3 Componentes de una herramienta CASE

Una herramienta CASE completa suele articularse sobre cinco piezas:

1. **Repositorio central o diccionario de datos:** almacena de manera única y
   consistente los elementos del modelo (clases, atributos, relaciones,
   requisitos). Es la fuente de verdad; todo lo demás se deriva de él.
2. **Editores gráficos:** permiten construir los modelos con la notación
   estándar (UML, E-R, DFD).
3. **Verificador de consistencia:** valida que el modelo cumpla las reglas de la
   notación y del dominio antes de permitir avanzar.
4. **Generador de código:** transforma el modelo en artefactos ejecutables.
5. **Generador de documentación e informes:** produce la documentación técnica
   a partir del mismo repositorio.

### 1.4 Beneficios y limitaciones

**Beneficios** (Pressman & Maxim, 2020; Sommerville, 2016):

- Reduce el esfuerzo en tareas repetitivas y el error humano asociado.
- Impone consistencia entre modelo, código y documentación.
- Mejora la trazabilidad entre requisitos, diseño e implementación.
- Facilita el mantenimiento: el cambio se hace en el modelo, no en cien
  archivos.
- Acorta el ciclo de retroalimentación con el usuario.

**Limitaciones:** la literatura es explícita en que CASE no es una bala de
plata. Brooks (1987), en *No Silver Bullet*, argumenta que las herramientas
atacan la **complejidad accidental** —la que introduce la tecnología— pero no la
**complejidad esencial** —la del problema mismo—. Una herramienta CASE no
sustituye el análisis: si el modelo está mal concebido, la herramienta generará
código correcto de un diseño incorrecto, más rápido.

Otras limitaciones documentadas: curva de aprendizaje, costo de licencias,
rigidez cuando la herramienta impone un método, y el riesgo de generar código
que después se modifica a mano y deja de corresponder al modelo (*round-trip
problem*).

### 1.5 Evolución hacia el Desarrollo Dirigido por Modelos (MDD/MDE)

La descendencia directa de CASE es el **Desarrollo Dirigido por Modelos**
(*Model-Driven Engineering*, MDE) y su formalización por la OMG como
**Arquitectura Dirigida por Modelos** (*Model-Driven Architecture*, MDA). En MDA
el modelo deja de ser documentación y pasa a ser el artefacto primario:

- **CIM** (*Computation Independent Model*): modelo del negocio.
- **PIM** (*Platform Independent Model*): modelo del sistema sin compromisos
  tecnológicos. **Aquí vive el diagrama de clases UML.**
- **PSM** (*Platform Specific Model*): modelo ya comprometido con una
  plataforma (JPA, Spring, PostgreSQL).
- **Código:** generado por transformación desde el PSM.

Kleppe, Warmer & Bast (2003) y Brambilla, Cabot & Wimmer (2017) desarrollan
este encadenamiento de transformaciones modelo-a-modelo y modelo-a-texto.

### 1.6 Aplicación en UMLFORGE AI

**UMLFORGE AI es, en sí mismo, una herramienta CASE integrada (I-CASE).** No
usa una herramienta CASE: es una.

| Componente CASE | Realización en el proyecto |
|---|---|
| Repositorio central | **Modelo canónico único** (`shared/contracts`), versionado con `SCHEMA_VERSION = '1.0.0'`, persistido y replicado |
| Editor gráfico | Editor de diagramas de clases en React 19, con la notación UML de las cuatro relaciones |
| Verificador de consistencia | `shared/domain-core` — validador que corre **idéntico** en navegador y servidor, con severidades ERROR/WARNING |
| Generador de código | `shared/generation-ir` + plantillas Handlebars en `templates/spring/` → proyecto Spring Boot completo |
| Generador de documentación | OpenAPI/Swagger emitido en el proyecto generado; XMI 2.5.1 para intercambio |

El encadenamiento MDA es explícito en la arquitectura del proyecto y está
recogido en la decisión **ADR-007**:

```
Modelo canónico (PIM)   ← qué significa el diagrama
        ↓
Snapshot inmutable      ← entrada congelada de la generación
        ↓
Generation-IR (PSM)     ← ya sabe qué es una clave foránea y una tabla
        ↓
Plantillas Handlebars   ← transformación modelo-a-texto
        ↓
Proyecto Spring Boot    ← código
```

La regla arquitectónica **RA-13** enuncia la separación con precisión: *«el
modelo canónico no sabe qué es una clave foránea; las plantillas no saben qué es
una multiplicidad»*. Esa frase es exactamente la frontera PIM/PSM de MDA.

El proyecto aborda además, de forma deliberada, dos de las limitaciones
clásicas de CASE:

- **El problema del *round-trip*** se evita por decisión de alcance
  (**ADR-018**): los artefactos generados **no se almacenan**. Se entrega un ZIP
  con manifiesto y SHA-256. No hay ida y vuelta que pueda desincronizarse: el
  modelo es siempre la fuente de verdad, el código es siempre derivado.
- **El determinismo** (RNF-05, **ADR-007 / RA-07**): *ningún modelo de lenguaje
  escribe Java*. El mismo modelo produce siempre exactamente el mismo ZIP. La IA
  interviene antes, en la construcción del diagrama, nunca en la generación.

---

## 2. Desarrollo de Software Basado en Componentes

### 2.1 Definición

El **Desarrollo de Software Basado en Componentes** (*Component-Based Software
Engineering*, CBSE o CBD) es el enfoque que construye sistemas ensamblando
unidades de software preexistentes, independientes y sustituibles, en lugar de
escribir cada sistema desde cero.

La definición canónica es la de Clemens Szyperski (2002):

> «Un componente de software es una unidad de composición con interfaces
> especificadas contractualmente y únicamente dependencias de contexto
> explícitas. Un componente de software puede ser desplegado independientemente
> y está sujeto a composición por terceras partes.»

Tres condiciones se desprenden de esa definición y son las que separan un
componente de un simple módulo:

1. **Interfaz contractual explícita:** lo que el componente ofrece y lo que
   exige está declarado, no descubierto leyendo su código.
2. **Dependencias de contexto explícitas:** no hay estado global oculto ni
   acoplamientos implícitos.
3. **Despliegue y sustitución independientes:** se puede reemplazar por otra
   implementación que respete el mismo contrato, sin tocar a los consumidores.

### 2.2 Principios

- **Reutilización:** el componente se escribe una vez y se usa en muchos
  contextos. Es el objetivo económico del enfoque.
- **Sustituibilidad:** cualquier implementación que cumpla el contrato sirve.
- **Encapsulamiento:** el consumidor conoce la interfaz, nunca la
  implementación.
- **Composición sobre herencia:** los sistemas se arman conectando componentes,
  no derivando jerarquías.
- **Separación entre especificación e implementación:** el contrato es un
  artefacto de primera clase, independiente del código que lo satisface.

### 2.3 El proceso CBSE

Heineman & Councill (2001) y Sommerville (2016) describen el ciclo:

1. **Análisis de requisitos** y esbozo de la arquitectura.
2. **Búsqueda y selección** de componentes candidatos.
3. **Adaptación** de los requisitos a los componentes disponibles (el paso
   incómodo: en CBSE los requisitos se negocian contra lo que existe).
4. **Composición** de la arquitectura a partir de los componentes elegidos.
5. **Integración y verificación** del ensamblado.

Sommerville advierte del compromiso central de CBSE: se gana velocidad y
fiabilidad, se pierde control sobre la evolución del componente ajeno.

### 2.4 Ventajas y riesgos

**Ventajas:** menor tiempo de desarrollo, mayor fiabilidad (el componente
reutilizado ya fue probado en producción por otros), menor riesgo, división
clara del trabajo en equipo, mantenimiento localizado.

**Riesgos:** confianza en el componente ajeno (*trust*), incompatibilidades de
versiones (*dependency hell*), pérdida de control sobre la evolución,
sobrecostos de integración cuando el componente casi encaja pero no del todo, y
requisitos que se deforman para acomodarse a lo disponible.

### 2.5 Aplicación en UMLFORGE AI

El proyecto está organizado como un **monorepo con espacios de trabajo npm**
(*npm workspaces*), donde cada paquete de `shared/` es un componente con
contrato explícito, frontera de dependencias controlada y batería de pruebas
propia:

| Componente | Responsabilidad | Contrato que expone |
|---|---|---|
| `shared/contracts` | Vocabulario cerrado y esquemas Zod del modelo canónico | Tipos y validadores; **nadie más define qué es una clase UML** |
| `shared/domain-core` | Reglas del dominio: aplicación de comandos, validación, grafo de herencia | `apply()`, validador, `buildInheritanceGraph()` |
| `shared/generation-ir` | Traducción del modelo canónico a representación intermedia orientada a persistencia | `IrEntity`, `IrProject` |
| `shared/generator-backend` | Renderizado de plantillas y armado del proyecto Spring Boot | Generador determinista → ZIP |
| `shared/ai` | Pasarela de IA: puertos, adaptadores, resolución de propuestas | `LlmPort`, `VisionPort`, `SpeechPort` |
| `shared/xmi` | Serialización e importación XMI 2.5.1 | Exportador / importador |
| `shared/yjs-adapter` | Puente entre el documento CRDT y el modelo canónico | Adaptador de sincronización |

Los consumidores —`frontend`, `backend/api`, `backend/collab`— componen estos
paquetes sin conocer sus internos.

**El caso más claro de sustituibilidad es la pasarela de IA (ADR-015 / RA-14):**

> *«Ningún módulo del dominio conoce un proveedor concreto. La IA se consume a
> través de tres puertos —`LlmPort`, `VisionPort`, `SpeechPort`— y cada proveedor
> es un adaptador intercambiable por variable de entorno.»*

Esto es CBSE en su forma más pura: hoy el puerto de lenguaje resuelve contra
Groq, Z.AI, Mistral, Moonshot o SambaNova; mañana puede resolver contra un
modelo local. **El dominio no cambia una sola línea.** La ADR lo justifica en
términos económicos, no estéticos: *«es la diferencia entre cambiar de proveedor
en una tarde y reescribir tres módulos a una semana de la entrega»*.

Además, los componentes de terceros que el proyecto integra son un ejercicio de
CBSE explícito: Yjs/Hocuspocus (colaboración CRDT), Fastify (HTTP), Prisma
(persistencia), Zod (validación de contratos), Handlebars (plantillas),
React Flow (lienzo), Playwright (pruebas E2E). Ninguno se reimplementó.

---

## 3. Arquitectura de Software

### 3.1 Definición

La definición más citada es la de Bass, Clements & Kazman (2021):

> «La arquitectura de software de un sistema es el conjunto de estructuras
> necesarias para razonar sobre el sistema, que comprende elementos de software,
> las relaciones entre ellos y las propiedades de ambos.»

Perry & Wolf (1992), en el trabajo fundacional del área, la formulan como
**Arquitectura = Elementos + Forma + Racionalidad**, incorporando explícitamente
el *porqué* de las decisiones.

El estándar **ISO/IEC/IEEE 42010:2022** la define como *«los conceptos o
propiedades fundamentales de un sistema en su entorno, encarnados en sus
elementos, relaciones y en los principios de su diseño y evolución»*, e
introduce el vocabulario de **partes interesadas** (*stakeholders*),
**preocupaciones** (*concerns*), **puntos de vista** (*viewpoints*) y
**vistas** (*views*).

Existe además una definición pragmática y muy repetida, atribuida a Martin
Fowler y a Ralph Johnson: **la arquitectura es el conjunto de decisiones que son
difíciles de cambiar después**. De ahí que documentar el *porqué* importe tanto
como documentar el *qué*.

### 3.2 Vistas arquitectónicas: el modelo 4+1

Kruchten (1995) propone organizar la descripción arquitectónica en cinco vistas
complementarias, modelo que después se incorpora al RUP:

| Vista | Responde a | Notación UML habitual |
|---|---|---|
| **Lógica** | ¿Qué funcionalidad ofrece? | Diagrama de **clases**, de objetos |
| **De procesos** | ¿Cómo se comporta en ejecución? | Actividad, secuencia |
| **De desarrollo** | ¿Cómo se organiza el código? | Componentes, paquetes |
| **Física / de despliegue** | ¿Dónde corre? | Despliegue |
| **+1: Escenarios** | ¿Cómo se conectan las anteriores? | Casos de uso |

### 3.3 Atributos de calidad

La arquitectura es el vehículo principal para alcanzar los **requisitos no
funcionales** o **atributos de calidad**: rendimiento, disponibilidad,
seguridad, modificabilidad, testeabilidad, usabilidad, escalabilidad e
interoperabilidad. Bass, Clements & Kazman insisten en que un atributo de
calidad sin **escenario medible** —estímulo, entorno, respuesta, medida— no es
un requisito, es un deseo.

### 3.4 Estilos y patrones arquitectónicos

- **Monolito y monolito modular:** un solo despliegue, dividido internamente por
  dominio.
- **Microservicios:** servicios pequeños, desplegables e independientes.
- **Capas (*layered*):** presentación, negocio, persistencia.
- **Cliente-servidor.**
- **Hexagonal / Puertos y Adaptadores** (Cockburn, 2005): el núcleo del dominio
  no depende de ninguna tecnología; toda entrada y salida ocurre a través de
  puertos con adaptadores intercambiables.
- **Arquitectura orientada a eventos**, **CQRS**, **Event Sourcing**.
- **Pipes and Filters:** cadena de transformaciones, cada una con una entrada y
  una salida bien definidas.

Richards & Ford (2020) subrayan que en arquitectura *no hay decisiones
correctas, solo compromisos* (*trade-offs*), y que el error más común es elegir
un estilo por moda y no por atributo de calidad.

### 3.5 Registros de Decisión Arquitectónica (ADR)

Nygard (2011) propone documentar cada decisión significativa en un **ADR**
(*Architecture Decision Record*): un documento corto e inmutable con contexto,
decisión, consecuencias y estado (propuesta, aceptada, superada). El valor está
en preservar la **racionalidad** —la *forma* de Perry & Wolf— para quien llegue
después.

### 3.6 Aplicación en UMLFORGE AI

El proyecto documenta su arquitectura mediante **veinte ADR** (`docs/adr/`), lo
que constituye evidencia directa de esta sección. Las decisiones estructurales:

**ADR-001 — Monolito modular con dos procesos, no microservicios.**
La plataforma atiende dos perfiles de carga distintos sobre el mismo dominio:
tráfico HTTP (sesión, proyectos, IA, generación) y tráfico WebSocket (salas,
presencia, persistencia del documento colaborativo). Se resuelve con **dos
ejecutables** —`backend/api` y `backend/collab`— que comparten repositorio,
paquetes de `shared/` y base de datos. No son microservicios: no hay
descubrimiento de servicios, ni consistencia eventual entre ellos, ni bases de
datos separadas. Es la decisión de compromiso apropiada al tamaño del equipo y
al plazo.

**Arquitectura hexagonal aplicada con criterio.** La misma ADR-001 declara algo
que merece destacarse porque contradice la aplicación dogmática del patrón:

> *«Arquitectura hexagonal aplicada de forma ligera y **solo** en
> `shared/domain-core`, que no depende de React, del documento colaborativo, del
> servidor HTTP, de la base de datos ni de ningún proveedor de IA. Fuera de ese
> paquete, código directo: nada de convertir cada operación en un puerto con su
> adaptador, su fábrica y su mapeador.»*

Ese aislamiento tiene una consecuencia verificable: **el mismo validador corre
en el navegador y en el servidor** (regla RA-05), sin duplicar reglas y sin
posibilidad de que ambos discrepen.

**ADR-003 — Modelo canónico único con comandos y lotes atómicos.**
Seis entradas distintas modifican el mismo diagrama —interfaz gráfica, texto,
voz, imagen, XMI y cualquier futura—. Ninguna escribe el estado directamente.
Todas producen **lotes de comandos** de un vocabulario cerrado de once
operaciones:

```
GUI · texto · voz · imagen · XMI
              ↓
     Propuesta de lote
              ↓
     Resolución estructural
              ↓
         Validación          ← si hay un solo error, no se aplica nada
              ↓
     Aplicador de comandos
```

Este es un caso claro de arquitectura al servicio de un atributo de calidad: la
**modificabilidad** (agregar una séptima entrada cuesta un adaptador, no un
rediseño) y la **integridad** (atomicidad del lote).

**ADR-002 — CRDT para colaboración.** La concurrencia se resuelve con un
**Conflict-free Replicated Data Type** (Shapiro et al., 2011) sobre Yjs
(Nicolaescu et al., 2016), no con bloqueos. La restricción **CA-023.1** es
arquitectónicamente significativa: *el protocolo de tiempo real nunca transporta
comandos de dominio, solo las actualizaciones resultantes*. Se evita así que dos
caminos distintos —el comando y la réplica— puedan producir estados divergentes.

**ADR-006 — Sin Event Sourcing ni CQRS.** Ejemplo de decisión por descarte
razonado: se documenta explícitamente el estilo que **no** se adopta y por qué,
que es tan valioso como documentar el adoptado.

**ADR-007 — Generación por representación intermedia y plantillas.** Estilo
*pipes and filters* aplicado a la generación, con la garantía de determinismo
(RNF-05) como atributo de calidad rector.

**ADR-010 — Docker Compose, infraestructura como código diferida.** Vista física
del 4+1: la plataforma se despliega con `docker compose up -d --build`, con
PostgreSQL, migraciones Prisma y Nginx como *reverse proxy*.

---

## 4. UML (Unified Modeling Language)

*(Con énfasis en el Diagrama de Clases)*

### 4.1 Definición y origen

**UML** (*Unified Modeling Language*) es un lenguaje gráfico de propósito
general para **especificar, visualizar, construir y documentar** los artefactos
de un sistema con gran cantidad de software (Booch, Rumbaugh & Jacobson, 2005).

Es importante precisar qué **no** es: UML **no es una metodología**. Es una
notación. No dice en qué orden trabajar ni qué entregar en cada iteración; dice
cómo dibujar lo que se decidió. Por eso puede usarse con PUDS, con Scrum o con
cualquier otro proceso.

**Origen histórico.** A comienzos de los años noventa coexistían más de
cincuenta métodos orientados a objetos incompatibles entre sí —la llamada
«guerra de los métodos»—. Tres de ellos dominaban:

- **OMT** (*Object Modeling Technique*), de **James Rumbaugh** (1991).
- **Método Booch**, de **Grady Booch**.
- **OOSE** (*Object-Oriented Software Engineering*), de **Ivar Jacobson**,
  que aportó los casos de uso.

En 1994 Rumbaugh se une a Booch en Rational Software; en 1995 se suma Jacobson.
Los «tres amigos» unifican sus notaciones. En 1997 la **OMG** (*Object
Management Group*) adopta UML 1.1 como estándar. La versión vigente es
**UML 2.5.1** (OMG, 2017), y desde 2005 es también estándar internacional
ISO/IEC 19501 (para 1.4.2) y ISO/IEC 19505 (para 2.x).

### 4.2 Los diagramas de UML 2.5.1

UML 2.5.1 define catorce tipos de diagrama en dos grandes familias:

**Estructurales (7):** Clases, Objetos, Componentes, Estructura Compuesta,
Paquetes, Despliegue, Perfiles.

**De comportamiento (7):** Casos de Uso, Actividades, Máquina de Estados, y los
cuatro de interacción: Secuencia, Comunicación, Tiempos, Visión General de la
Interacción.

### 4.3 El Diagrama de Clases

El **diagrama de clases** es el diagrama estructural central de UML y el más
utilizado en la práctica. Describe la **estructura estática** del sistema: qué
tipos de objetos existen, qué información guardan, qué pueden hacer y cómo se
relacionan entre sí. Es la vista lógica del modelo 4+1 y, en términos de MDA, el
PIM por excelencia.

#### a) La clase

Se representa con un rectángulo dividido en tres compartimentos:

```
┌─────────────────────────┐
│       Estudiante        │   ← Nombre (obligatorio)
├─────────────────────────┤
│ - id : UUID             │   ← Atributos
│ - matricula : String    │
│ - fechaIngreso : Date   │
├─────────────────────────┤
│ + inscribir() : void    │   ← Operaciones
│ + promedio() : Decimal  │
└─────────────────────────┘
```

**Visibilidad de los miembros:**

| Símbolo | Visibilidad | Significado |
|---|---|---|
| `+` | Pública (*public*) | Visible para cualquier elemento |
| `-` | Privada (*private*) | Visible solo dentro de la clase |
| `#` | Protegida (*protected*) | Visible para la clase y sus descendientes |
| `~` | De paquete (*package*) | Visible dentro del mismo paquete |

Los atributos se declaran con la sintaxis
`visibilidad nombre : tipo [multiplicidad] = valorInicial {propiedades}`.
Un atributo subrayado es **estático** (de clase, no de instancia). Un nombre de
clase en *cursiva* indica clase **abstracta**.

#### b) Las relaciones

| Relación | Notación | Semántica |
|---|---|---|
| **Asociación** | Línea continua | Vínculo estructural entre dos clases. Puede tener nombre, roles y navegabilidad |
| **Agregación** | Rombo **hueco** en el todo | «Tiene un». El todo agrupa partes que **existen independientemente** |
| **Composición** | Rombo **relleno** en el todo | «Está compuesto de». La parte **no vive sin el todo**; su ciclo de vida depende de él |
| **Generalización** | Triángulo **hueco** apuntando a la superclase | «Es un». Herencia: la subclase hereda estructura y comportamiento |
| **Dependencia** | Línea discontinua con flecha abierta | Uso puntual: un cambio en el proveedor puede afectar al cliente |
| **Realización** | Línea discontinua con triángulo hueco | Una clase implementa una interfaz |

La distinción agregación/composición es la que más confusión genera. Fowler
(2003) es franco al respecto: la diferencia es sutil, y recomienda usar
composición cuando la destrucción del todo implica la destrucción de las partes
—una `Factura` y sus `LineasDeFactura`— y agregación cuando no —un
`Departamento` y sus `Empleados`—.

#### c) Multiplicidad

Indica cuántas instancias de una clase pueden vincularse con una instancia de la
otra:

| Notación | Lectura |
|---|---|
| `1` | Exactamente uno |
| `0..1` | Cero o uno (opcional) |
| `0..*` o `*` | Cero o muchos |
| `1..*` | Uno o muchos (al menos uno) |
| `n..m` | Entre n y m |

#### d) La generalización en detalle

La generalización expresa la relación **«es un»** (*is-a*). La subclase hereda
los atributos, operaciones y relaciones de la superclase, y puede añadir los
suyos propios o redefinir el comportamiento heredado (polimorfismo).

Reglas relevantes para el modelado:

- El **principio de sustitución de Liskov** exige que toda instancia de la
  subclase pueda usarse donde se espera la superclase.
- UML admite **herencia múltiple** en el metamodelo, pero la mayoría de los
  lenguajes de destino (Java, C#) no la soportan para clases.
- Los conjuntos de generalización pueden marcarse `{disjoint}` / `{overlapping}`
  y `{complete}` / `{incomplete}`.
- Una jerarquía **no puede contener ciclos**: una clase no puede ser, directa o
  indirectamente, su propia superclase.

#### e) Del diagrama de clases al modelo relacional

Aquí está el nexo entre UML y la generación de código. Fowler (2003), en
*Patterns of Enterprise Application Architecture*, formaliza las tres
estrategias para proyectar una jerarquía de herencia sobre tablas relacionales:

| Patrón (Fowler) | Estrategia JPA | Descripción |
|---|---|---|
| **Single Table Inheritance** | `SINGLE_TABLE` | Una sola tabla para toda la jerarquía, con columna discriminadora. Rápida, pero llena de columnas nulas |
| **Class Table Inheritance** | `JOINED` | Una tabla por clase, unidas por la clave primaria. Normalizada; exige *joins* |
| **Concrete Table Inheritance** | `TABLE_PER_CLASS` | Una tabla por clase concreta, con todas las columnas heredadas repetidas. Duplica estructura |

### 4.4 Aplicación en UMLFORGE AI

El proyecto implementa un **subconjunto deliberadamente cerrado y finito** del
diagrama de clases UML. El archivo `shared/contracts/src/vocabulary.ts` lo
declara en su encabezado con esta justificación:

> *«Vocabulario cerrado de la plataforma. Todo lo que está aquí es una lista
> finita y deliberada. Ampliarla es una decisión de alcance, no un detalle de
> implementación.»*

El vocabulario UML soportado es:

**Cuatro tipos de relación** (`RELATIONSHIP_KINDS`), cada una dibujada con su
notación UML propia:

```ts
export const RELATIONSHIP_KINDS = [
  'ASSOCIATION',
  'GENERALIZATION',
  'COMPOSITION',
  'AGGREGATION',
] as const;
```

**Cuatro multiplicidades** (`MULTIPLICITIES`), regla RM-04:

```ts
export const MULTIPLICITIES = ['1', '0..1', '0..*', '1..*'] as const;
```

Las multiplicidades `0..*` y `1..*` se marcan como *de colección*, y su
combinación en ambos extremos es la que detecta una relación **muchos a muchos**
(RM-01), resuelta con una **entidad intermedia** según **ADR-005**.

**Ocho tipos conceptuales** (`CONCEPTUAL_TYPES`), regla RTM-01:

```ts
export const CONCEPTUAL_TYPES = [
  'String', 'Integer', 'Long', 'Decimal',
  'Boolean', 'Date', 'DateTime', 'UUID',
] as const;
```

Son **conceptuales** —no `VARCHAR` ni `java.lang.String`—: pertenecen al PIM. La
traducción a tipo Java y a tipo SQL ocurre después, en la representación
intermedia.

**Once comandos** (`COMMAND_TYPES`) que constituyen la única forma de modificar
el diagrama, y **cinco orígenes de lote** (`BATCH_ORIGINS`: `GUI`, `AI_TEXT`,
`AI_VOICE`, `IMAGE`, `XMI`).

#### La generalización: del triángulo hueco a `InheritanceType.JOINED`

El caso más ilustrativo de la relación entre teoría UML y generación de código
en este proyecto es la implementación de la herencia, documentada en
**ADR-020**. El contexto que registra la ADR es honesto y vale la pena citarlo,
porque describe con exactitud el peligro de una herramienta CASE mal
sincronizada:

> *«Una generalización se proyectaba como una clave foránea más: `Estudiante`
> recibía un campo `persona` y una columna `persona_id`, exactamente igual que si
> alguien hubiera dibujado una asociación 1:1. El diagrama decía una cosa y el
> proyecto Spring Boot decía otra. Eso es peor que no soportarla. Un usuario que
> dibuja el triángulo, genera y abre el ZIP encuentra código que no corresponde a
> su modelo, y nada se lo advierte: compila, arranca y guarda filas.»*

La decisión adoptada fue la **tabla por clase unida por la clave primaria** —el
*Class Table Inheritance* de Fowler, `InheritanceType.JOINED` de Jakarta
Persistence—. Sus consecuencias en el código generado:

- La **clase raíz** de la jerarquía recibe
  `@Inheritance(strategy = InheritanceType.JOINED)`.
- La **clave primaria se declara una sola vez, en la raíz**. Las subclases la
  comparten mediante `@PrimaryKeyJoinColumn`.
- La subclase **no declara nada heredado**: por eso la plantilla
  `entity.java.hbs` itera sobre `declaredAttributes` y `declaredRelationships`
  —lo propio— mientras el DTO y el servicio trabajan con los atributos
  **efectivos** (heredados + propios).
- El grafo de herencia se construye una sola vez en
  `shared/domain-core/src/inheritance.ts` (`buildInheritanceGraph`,
  `ancestorsOf`, `rootOf`, `inTopologicalOrder`) y es la **única fuente de
  verdad** sobre la jerarquía para el editor, el validador y el generador.

Las reglas UML de la jerarquía se validan y se reportan al usuario con
severidad, no se ignoran:

| Código de validación | Severidad | Regla UML que protege |
|---|---|---|
| `SELF_GENERALIZATION` | ERROR | Una clase no puede heredar de sí misma |
| `INHERITANCE_CYCLE` | ERROR | La jerarquía no puede tener ciclos |
| `MULTIPLE_INHERITANCE` | ERROR | Java no admite herencia múltiple de clases |
| `INHERITED_MEMBER_COLLISION` | ERROR | Una subclase no puede redeclarar un miembro heredado |
| `PRIMARY_KEY_INHERITED` | WARNING | La clave primaria pertenece a la raíz de la jerarquía |

Finalmente, la interoperabilidad con otras herramientas CASE se resuelve
mediante **XMI 2.5.1** (*XML Metadata Interchange*, OMG), el estándar de
intercambio de modelos: la generalización se emite como el elemento
`<generalization>` que Enterprise Architect reconoce.

---

## 5. Metodología OMT (Object Modeling Technique)

### 5.1 Origen

La **Técnica de Modelado de Objetos** (*Object Modeling Technique*, OMT) fue
desarrollada por **James Rumbaugh** junto a Michael Blaha, William Premerlani,
Frederick Eddy y William Lorensen en los laboratorios de investigación de
**General Electric**, y publicada en 1991 en el libro
***Object-Oriented Modeling and Design*** (Prentice Hall).

OMT fue una de las metodologías orientadas a objetos más influyentes de los
noventa. Su notación gráfica es el antecedente directo del diagrama de clases de
UML: cuando Rumbaugh se incorpora a Rational Software en 1994 y unifica su
trabajo con el de Booch y Jacobson, la notación estructural que aporta a UML es
esencialmente la de OMT.

Blaha & Rumbaugh publicaron en 2005 una segunda edición del libro,
***Object-Oriented Modeling and Design with UML***, que reescribe la metodología
usando la notación UML ya estandarizada, dejando claro que OMT y UML no compiten:
OMT es el método, UML la notación.

### 5.2 Los tres modelos de OMT

La contribución conceptual central de OMT es que **un sistema no se describe con
un solo modelo, sino con tres vistas ortogonales y complementarias**, cada una
respondiendo a una pregunta distinta:

| Modelo | Pregunta que responde | Contenido | Notación heredada por UML |
|---|---|---|---|
| **Modelo de Objetos** | **¿QUÉ?** — ¿Cuál es la estructura estática? | Clases, atributos, operaciones, asociaciones, agregación, herencia | Diagrama de **clases** |
| **Modelo Dinámico** | **¿CUÁNDO?** — ¿Cómo cambia el sistema en el tiempo? | Estados, eventos, transiciones, escenarios | Diagrama de **estados** y de **secuencia** |
| **Modelo Funcional** | **¿CÓMO?** — ¿Cómo se transforman los datos? | Procesos, flujos de datos, almacenes, entidades externas | Diagrama de **flujo de datos** (DFD) |

Rumbaugh es explícito en que **el Modelo de Objetos es el más importante de los
tres**, porque describe la estructura sobre la que los otros dos operan: los
estados del modelo dinámico son estados *de objetos*, y los procesos del modelo
funcional transforman *atributos de objetos*. Si el modelo de objetos está mal,
los otros dos heredan el error.

### 5.3 Las cuatro fases del proceso OMT

**1. Análisis.**
Se construye un modelo abstracto y preciso de **qué** debe hacer el sistema,
nunca de cómo. Se parte de la descripción del problema (*problem statement*) y
se derivan los tres modelos. Rumbaugh propone una técnica que se hizo célebre
por su simplicidad: extraer del enunciado del problema los **sustantivos** como
candidatos a clases y atributos, y los **verbos** como candidatos a operaciones y
asociaciones; después depurar la lista eliminando redundancias, clases
irrelevantes, atributos disfrazados de clases y nombres vagos.

**2. Diseño del Sistema (*System Design*).**
Decisiones de alto nivel: arquitectura general, división en subsistemas,
asignación de subsistemas a procesadores, elección de la estrategia de
almacenamiento de datos, manejo de la concurrencia, control global del software,
condiciones de frontera y compromisos de prioridad. **Esta fase es, en el
vocabulario actual, arquitectura de software.**

**3. Diseño de Objetos (*Object Design*).**
Se refinan los modelos del análisis con los detalles de implementación: se
eligen algoritmos, se optimizan los caminos de acceso, se ajusta la estructura
de clases para reutilización, se diseñan las asociaciones como referencias o
colecciones, se determina la representación física de los atributos y se
empaquetan las clases en módulos.

**4. Implementación.**
Traducción del diseño a un lenguaje concreto, a una base de datos o a hardware.
Rumbaugh insiste en que el código debe ser **trazable** hacia el diseño y que el
diseño debe mantenerse actualizado; el objetivo es que la implementación sea
mecánica, precisamente la ambición que hoy realiza la generación automática de
código.

### 5.4 Aportes duraderos de OMT

- **La separación en tres vistas ortogonales**, que sobrevive en el modelo 4+1
  de Kruchten y en la organización de los diagramas de UML 2.5.1.
- **La notación de clases y asociaciones** con multiplicidad, que UML adopta casi
  sin cambios.
- **La técnica sustantivos/verbos** para descubrir clases, que sigue enseñándose
  y que es exactamente la heurística que hoy se le pide a un modelo de lenguaje
  cuando se le dicta una descripción del dominio.
- **La idea de que el modelo precede al código** y de que el código es su
  consecuencia: el fundamento intelectual de CASE y MDD.

### 5.5 Aplicación en UMLFORGE AI

El proyecto puede leerse íntegramente como una automatización de las fases de
OMT:

**Modelo de Objetos → es el modelo canónico.** Lo que Rumbaugh llama el modelo
de objetos —clases, atributos, asociaciones, agregación, herencia— es
exactamente lo que `shared/contracts` define y `shared/domain-core` valida. La
plataforma se concentra en este modelo, coherente con la afirmación de Rumbaugh
de que es el más importante de los tres, y con la instrucción del examen de
enfocarse en el diagrama de clases.

**Análisis → asistido por IA.** La técnica de sustantivos y verbos que Rumbaugh
aplica a mano sobre el enunciado del problema es, literalmente, lo que hace el
asistente de UMLFORGE AI: recibe una descripción en lenguaje natural —escrita,
dictada por voz, o una fotografía de un diagrama de pizarra— y propone las
clases, atributos y relaciones candidatas. La diferencia es que aquí la
propuesta se valida contra el modelo antes de aplicarse, y el analista la
acepta o la corrige.

**Diseño del Sistema → los ADR.** Las decisiones que Rumbaugh sitúa en esta fase
—arquitectura, subsistemas, almacenamiento, concurrencia— están tomadas y
documentadas: ADR-001 (dos procesos), ADR-002 (concurrencia por CRDT), ADR-010
(despliegue), ADR-005 (estrategia para N:M).

**Diseño de Objetos → la representación intermedia.** El refinamiento del modelo
de análisis con detalles de implementación —asociaciones convertidas en
referencias, atributos con representación física, clases empaquetadas en
módulos— es precisamente la función del `generation-ir`: convierte
multiplicidades en claves foráneas, tipos conceptuales en tipos Java y columnas
SQL, y la generalización en una jerarquía JOINED.

**Implementación → generación determinista.** La aspiración de Rumbaugh de que
la implementación sea mecánica y trazable se cumple aquí de forma literal: las
plantillas Handlebars producen el proyecto Spring Boot, y el manifiesto con
SHA-256 hace la trazabilidad verificable.

---

## 6. Inteligencia Artificial Aplicada en el Desarrollo de Software

### 6.1 Panorama general

La aplicación de inteligencia artificial al desarrollo de software no es nueva
—los generadores de código y los sistemas expertos son contemporáneos de las
primeras herramientas CASE—, pero el salto cualitativo llega con los **modelos
de lenguaje de gran escala** (*Large Language Models*, LLM) entrenados sobre
código fuente.

El trabajo fundacional de esta generación es **Codex** (Chen et al., 2021), que
demostró que un modelo entrenado sobre repositorios públicos podía resolver
problemas de programación descritos en lenguaje natural, y que dio origen a
GitHub Copilot. Estudios posteriores midieron su impacto: Peng et al. (2023)
reportaron que los desarrolladores que usaban Copilot completaron una tarea de
programación un 55,8 % más rápido que el grupo de control.

Las aplicaciones actuales de IA en el ciclo de vida del software incluyen:

| Fase | Aplicación de IA |
|---|---|
| Requisitos | Extracción de entidades y reglas desde texto; detección de ambigüedad y contradicción |
| Análisis y diseño | Generación de modelos y diagramas desde descripciones en lenguaje natural |
| Codificación | Autocompletado contextual, generación de funciones, traducción entre lenguajes |
| Pruebas | Generación de casos de prueba, datos sintéticos, detección de casos límite |
| Revisión | Detección de defectos, vulnerabilidades y *code smells* |
| Documentación | Generación de documentación técnica y comentarios |
| Mantenimiento | Explicación de código heredado, sugerencias de refactorización |

**Limitaciones documentadas y no negociables:**

- **Alucinación:** el modelo produce texto plausible pero falso —APIs que no
  existen, identificadores inventados—.
- **No determinismo:** la misma entrada puede producir salidas distintas, lo que
  es incompatible con un artefacto que debe ser reproducible.
- **Ausencia de garantías de corrección:** el código generado compila con
  frecuencia y es correcto con menos frecuencia.
- **Riesgos de licencia y privacidad** al enviar código propietario a servicios
  de terceros.
- **Sesgo de automatización:** la tendencia humana a aceptar la sugerencia sin
  revisarla.

### 6.2 Desarrollo de Software Basado en Especificaciones (*Spec-Driven Development*)

El **desarrollo dirigido por especificaciones** es la respuesta metodológica a
esas limitaciones. Su premisa invierte la práctica habitual del desarrollo
asistido por IA:

> La especificación —versionada, estructurada y revisable— es la **fuente de
> verdad**. El código es un **artefacto derivado**, generado y mantenido contra
> esa especificación por humanos y agentes de IA.

Es, conceptualmente, la misma tesis de MDA y de CASE —el modelo antes que el
código— trasladada a la era de los agentes de IA. La diferencia es el medio: en
MDA la especificación es un modelo formal (UML, un metamodelo); en *spec-driven
development* es un documento estructurado en lenguaje natural que el agente
puede leer y contra el cual puede validarse.

En septiembre de 2025 GitHub publicó **Spec Kit**, un conjunto de herramientas de
código abierto (licencia MIT) que operacionaliza el enfoque mediante un flujo
estructurado: captura de la intención en una especificación en lenguaje natural,
análisis de consistencia, descomposición en tareas acotadas e implementación bajo
gobernanza de la especificación. El ciclo se resume en cinco pasos: **definir la
intención, eliminar la ambigüedad, planificar con restricciones, implementar con
IA y validar contra la especificación**.

Para 2026 el enfoque se había consolidado como práctica emergente, con las
especificaciones tratadas como artefactos de código —versionadas, revisadas en
*pull requests* y aplicadas automáticamente por asistentes de IA—, y con un
ecosistema que se extiende más allá de Spec Kit: **Kiro** de AWS (un IDE
dedicado a SDD), **Tessl** (que lleva la idea hasta *spec-as-source*) e
implementaciones de IBM adaptadas a infraestructura como código.

La literatura académica reciente identifica lo que denomina la **«paradoja
productividad-fiabilidad»** del desarrollo aumentado por IA: la velocidad de
producción de código aumenta mientras la fiabilidad no lo hace en la misma
proporción, y propone la gobernanza por especificaciones como mecanismo de
control (arXiv:2605.01160, 2026).

**Ventajas del enfoque:**

- El artefacto revisable es la especificación, no diez mil líneas generadas.
- La ambigüedad se resuelve **antes** de generar, no depurando después.
- La regeneración es barata: si la especificación cambia, se regenera.
- La trazabilidad requisito → código es explícita.
- Reduce la alucinación al acotar el espacio de decisión del modelo.

### 6.3 Modelos Locales y Personalización (*Fine-tuning*)

**Motivación.** Ejecutar el modelo en infraestructura propia responde a
preocupaciones que no son técnicas sino de riesgo: **privacidad** (el código y
los datos no salen de la organización), **costo** (sin tarifa por token),
**disponibilidad** (sin dependencia de un proveedor externo ni de su cuota),
**latencia** y **cumplimiento normativo**.

**Herramientas de ejecución local.** **llama.cpp** —motor de inferencia en C/C++
que popularizó el formato **GGUF** y la ejecución cuantizada en CPU y GPU de
consumo— y **Ollama**, que lo envuelve en una interfaz de línea de comandos y una
API compatible con OpenAI, son hoy el camino estándar para servir un modelo en
una máquina propia. Para servicio de alto rendimiento con lotes continuos, la
referencia es **vLLM**.

**Personalización: las tres estrategias.**

| Estrategia | Qué hace | Costo | Cuándo usarla |
|---|---|---|---|
| ***Prompt engineering*** | Instrucciones y ejemplos en el contexto | Nulo | Primera opción siempre |
| **RAG** (*Retrieval-Augmented Generation*) | Recupera documentos relevantes y los inyecta en el contexto | Bajo | Cuando falta **conocimiento** actualizado o propietario |
| ***Fine-tuning*** | Ajusta los pesos del modelo con ejemplos propios | Alto | Cuando falta **comportamiento**: formato, estilo, terminología del dominio |

La regla práctica que la literatura repite: *RAG para conocimiento, fine-tuning
para comportamiento*. La mayoría de los problemas atribuidos a «el modelo no
sabe» se resuelven con RAG (Lewis et al., 2020), no con reentrenamiento.

**Fine-tuning eficiente en parámetros (PEFT).** El ajuste completo de un modelo
de miles de millones de parámetros es inviable fuera de un centro de datos. Dos
técnicas lo hicieron accesible:

- **LoRA** (*Low-Rank Adaptation*, Hu et al., 2021): congela los pesos del
  modelo base y entrena únicamente pequeñas **matrices adaptadoras de rango
  bajo** insertadas en las capas de atención. Reduce los parámetros entrenables
  en varios órdenes de magnitud sin pérdida apreciable de calidad.
- **QLoRA** (Dettmers et al., 2023): carga el modelo base **cuantizado a 4 bits**
  en formato NF4 y entrena el adaptador LoRA sobre esos pesos cuantizados,
  manteniendo la aritmética del adaptador en mayor precisión (bfloat16). Permite
  ajustar modelos de 7B–8B parámetros en una sola GPU de 24 GB de VRAM.

**Flujo de trabajo típico (2026):** curar el conjunto de datos → entrenar el
adaptador con LoRA/QLoRA (herramientas como **Unsloth** aceleran el
entrenamiento cerca de 2× con hasta ~70 % menos memoria) → fusionar el adaptador
con el modelo base → exportar a **GGUF** → servir con **Ollama** o **llama.cpp**.

**Sobre los datos:** la evidencia práctica indica que para un ajuste de tarea
única y acotada bastan de unos cientos a unos pocos miles de ejemplos bien
curados, y que **la consistencia del formato y del etiquetado importa más que el
volumen bruto**.

### 6.4 Aplicación en UMLFORGE AI

El proyecto adopta las tres ideas anteriores de manera explícita y verificable.

#### a) La frontera: dónde interviene la IA y dónde no

La decisión más importante del proyecto en materia de IA es una **frontera**:

> **La IA construye el diagrama. La IA no escribe el código.**

Está enunciada como regla arquitectónica **RA-07** en **ADR-007**:

> *«La generación es determinista por plantillas. Ningún modelo de lenguaje
> escribe Java.»*

La justificación es directamente la limitación de no determinismo de la sección
6.1: un requisito no funcional del sistema (RNF-05) exige que el mismo diagrama
produzca siempre el mismo ZIP, y eso es incompatible con un generador
probabilístico. La IA aporta donde el no determinismo es tolerable —interpretar
lenguaje natural ambiguo— y se retira donde no lo es.

#### b) Arquitectura de la pasarela de IA

Tres puertos (**ADR-015 / RA-14**), cada uno con proveedor primario y hasta
**siete respaldos** encadenados (**ADR-019**):

| Puerto | Función | Entrada del usuario |
|---|---|---|
| `LlmPort` | Interpretar instrucciones de modelado | Texto escrito |
| `VisionPort` | Reconstruir un diagrama desde una imagen | Fotografía de pizarra o captura de cámara |
| `SpeechPort` | Transcribir dictado | Voz |

#### c) Dos reglas que hacen la IA segura

**ADR-015** enuncia dos invariantes que neutralizan directamente el riesgo de
alucinación:

> **1. El modelo nunca toca el estado.**
> *«Devuelve una propuesta. El sistema la resuelve, la valida y la aplica. En
> ningún punto del recorrido el proveedor escribe en la pizarra.»*
>
> **2. El modelo nunca resuelve identificadores.**
> *«Devuelve nombres; el resolver los busca contra el modelo real. Un
> identificador inventado por el modelo sería imposible de detectar como error
> —tiene la forma correcta— y produciría un comando que apunta a nada.»*

La segunda regla es un ejemplo preciso de diseño defensivo contra alucinación:
un UUID inventado es indistinguible de uno real por su forma, así que
sencillamente **no se le permite al modelo producir uno**.

#### d) Desarrollo basado en especificaciones, aplicado dos veces

El principio de *spec-driven development* aparece en dos niveles distintos:

**Nivel del sistema generado.** El diagrama de clases **es la especificación** y
el proyecto Spring Boot **es el artefacto derivado**. No se almacena código
generado (ADR-018): si el modelo cambia, se regenera. Esto es exactamente la
tesis «la especificación es la fuente de verdad, el código es derivado»,
implementada con un modelo formal (UML) en lugar de un documento en lenguaje
natural.

**Nivel de la interacción con la IA.** La salida del modelo de lenguaje no es
texto libre: está restringida por un **esquema JSON** (`PROPOSAL_JSON_SCHEMA`)
con `additionalProperties: false`, que solo admite comandos del vocabulario
cerrado de once operaciones. El modelo no puede proponer una operación que no
exista, porque el esquema no la admite. La propuesta se valida además con Zod
contra los contratos de `shared/contracts` antes de resolverse, y el lote es
**atómico**: si un solo comando falla la validación, no se aplica ninguno
(ADR-003).

Esa cadena —esquema restringido → validación de contrato → resolución de nombres
contra el modelo real → validación de dominio → aplicación atómica— es la
«gobernanza por especificación» que la literatura de 2026 propone como respuesta
a la paradoja productividad-fiabilidad.

#### e) Preparación para modelos locales

La arquitectura de puertos y adaptadores deja el camino abierto sin trabajo
adicional. Como Ollama y vLLM exponen una **API compatible con OpenAI**, y el
proyecto ya enruta todos los proveedores compatibles a través de un único
adaptador (la lista `COMPATIBLE` en `shared/ai/src/registry.ts`), incorporar un
modelo local ejecutándose en la máquina del usuario se reduce a **añadir una
entrada con su URL base** en la configuración. Ningún módulo del dominio se
entera. Es la ventaja de CBSE (sección 2) cobrada en el escenario concreto de
la sección 6.3.

En cuanto al *fine-tuning*, el proyecto genera de manera natural el conjunto de
datos que haría falta: cada par (instrucción en lenguaje natural → lote de
comandos válido y aplicado) es un ejemplo de entrenamiento perfectamente
formateado y ya validado. Con unos cientos de esos pares —el orden de magnitud
que la literatura señala como suficiente para una tarea única y acotada— sería
viable especializar un modelo pequeño mediante QLoRA para la tarea concreta de
traducir descripciones de dominio a comandos UML, y servirlo localmente en GGUF.

---

## 7. PUDS - Proceso Unificado de Desarrollo de Software

> *Esta sección **ya está escrita en el documento del examen**, con sus
> subsecciones 7.1, 7.2 y 7.3. Lo que sigue conserva esa numeración y solo añade
> dos cosas: un párrafo de origen bibliográfico al inicio, y una subsección 7.4
> que conecta el PUDS con el desarrollo real del proyecto. Si prefiere no tocar
> lo que ya tiene, tome únicamente el párrafo de origen y la subsección 7.4.*

**Origen y bibliografía.**
El **Proceso Unificado de Desarrollo de Software** (*Unified Software
Development Process*, PUDS o UP) fue publicado en 1999 por **Ivar Jacobson,
Grady Booch y James Rumbaugh** —los mismos «tres amigos» que unificaron UML— en
el libro *The Unified Software Development Process*. Su versión comercial,
desarrollada por Rational Software, es el **RUP** (*Rational Unified Process*),
descrito por Kruchten (2003).

La relación entre ambos estándares es de complementariedad: **UML es la notación,
PUDS es el proceso que dice cuándo y para qué usarla.**

### 7.1 Características principales del PUDS

- **Dirigido por casos de uso:** los casos de uso capturan los requisitos
  funcionales y guían todo el desarrollo, desde el análisis hasta las pruebas.
- **Centrado en la arquitectura:** la arquitectura se establece y valida
  tempranamente, y sirve de esqueleto para el resto del desarrollo.
- **Iterativo e incremental:** el proyecto se divide en iteraciones cortas, cada
  una produciendo un incremento ejecutable del producto.
- **Orientado a la gestión de riesgos:** los riesgos mayores se atacan en las
  primeras iteraciones, cuando aún hay margen para cambiar de rumbo.

### 7.2 Fases del PUDS

| Fase | Objetivo | Hito |
|---|---|---|
| **Inicio** (*Inception*) | Alcance, visión, caso de negocio, riesgos principales | Objetivos del ciclo de vida |
| **Elaboración** (*Elaboration*) | Arquitectura ejecutable de referencia, mayoría de requisitos, riesgos mitigados | Arquitectura del ciclo de vida |
| **Construcción** (*Construction*) | Desarrollo del grueso de la funcionalidad | Capacidad operativa inicial |
| **Transición** (*Transition*) | Despliegue, pruebas de aceptación, capacitación | Entrega del producto |

### 7.3 Flujos de trabajo del PUDS

Los cinco flujos de trabajo **de ingeniería** —Requisitos, Análisis, Diseño,
Implementación y Pruebas— atraviesan las cuatro fases, variando su intensidad:
en Inicio predominan los Requisitos; en Elaboración, el Análisis y el Diseño; en
Construcción, la Implementación y las Pruebas. RUP añade tres flujos **de
apoyo**: Gestión de Configuración y Cambios, Gestión del Proyecto y Entorno.

### 7.4 Aplicación del PUDS en UMLFORGE AI

El desarrollo de la plataforma siguió una estructura **iterativa e incremental
organizada en fases numeradas**, con la arquitectura establecida y validada
antes de construir el editor —la característica «centrado en la arquitectura» de
PUDS—. Cada ADR registra en su encabezado la **fase** en la que se tomó la
decisión, lo que hace visible la progresión:

- **Fases 0–1 (Inicio y Elaboración):** ADR-001 (arquitectura de dos procesos),
  ADR-002 (CRDT), ADR-003 (modelo canónico y comandos). Los riesgos mayores
  —¿funciona la colaboración concurrente sin bloqueos? ¿es viable la generación
  determinista?— se atacaron mediante *spikes* técnicos **antes** de construir el
  editor.
- **Fase 2 (Elaboración):** ADR-007 (generación por IR y plantillas) — la
  arquitectura ejecutable de referencia.
- **Fases 7–10 (Construcción):** ADR-015 y ADR-019 (pasarela de IA), ADR-018
  (artefactos no almacenados), generación completa desde el editor.
- **Posterior a la fase 10:** ADR-020 (generalización), que además **supera** a
  ADR-011 y ADR-017 —evidencia de que la arquitectura evolucionó de forma
  controlada y documentada, no por deriva—.

Los **flujos de trabajo de prueba** están automatizados y se ejecutan de forma
continua: `npm run check` (formato, *lint*, verificación de tipos y 455 pruebas
unitarias), pruebas de integración de la API, pruebas del código generado,
pruebas de extremo a extremo con Playwright, y un banco de pruebas que compila
con Maven cada proyecto generado, lo levanta contra PostgreSQL y verifica el
CRUD completo.

---

## FUENTES DE INFORMACIÓN

### Libros y obras de referencia

**Ingeniería de Software y CASE**

1. Pressman, R. S., & Maxim, B. R. (2020). *Software Engineering: A
   Practitioner's Approach* (9.ª ed.). McGraw-Hill Education.
2. Sommerville, I. (2016). *Software Engineering* (10.ª ed.). Pearson Education.
3. Fuggetta, A. (1993). «A Classification of CASE Technology». *IEEE Computer*,
   26(12), 25-38. https://doi.org/10.1109/2.247645
4. Brooks, F. P. (1987). «No Silver Bullet: Essence and Accidents of Software
   Engineering». *IEEE Computer*, 20(4), 10-19.
   https://doi.org/10.1109/MC.1987.1663532

**Desarrollo Basado en Componentes**

5. Szyperski, C. (2002). *Component Software: Beyond Object-Oriented
   Programming* (2.ª ed.). Addison-Wesley.
6. Heineman, G. T., & Councill, W. T. (2001). *Component-Based Software
   Engineering: Putting the Pieces Together*. Addison-Wesley.
7. Brown, A. W. (2000). *Large-Scale Component-Based Development*. Prentice
   Hall.

**Arquitectura de Software**

8. Bass, L., Clements, P., & Kazman, R. (2021). *Software Architecture in
   Practice* (4.ª ed.). Addison-Wesley.
9. Perry, D. E., & Wolf, A. L. (1992). «Foundations for the Study of Software
   Architecture». *ACM SIGSOFT Software Engineering Notes*, 17(4), 40-52.
   https://doi.org/10.1145/141874.141884
10. Kruchten, P. (1995). «Architectural Blueprints — The "4+1" View Model of
    Software Architecture». *IEEE Software*, 12(6), 42-50.
    https://doi.org/10.1109/52.469759
11. Richards, M., & Ford, N. (2020). *Fundamentals of Software Architecture: An
    Engineering Approach*. O'Reilly Media.
12. Fowler, M. (2003). *Patterns of Enterprise Application Architecture*.
    Addison-Wesley. *(Patrones Single Table / Class Table / Concrete Table
    Inheritance.)*
13. Cockburn, A. (2005). «Hexagonal Architecture (Ports and Adapters)».
    https://alistair.cockburn.us/hexagonal-architecture/
14. Nygard, M. (2011). «Documenting Architecture Decisions».
    https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions
15. **ISO/IEC/IEEE 42010:2022** — *Software, systems and enterprise —
    Architecture description*. https://www.iso.org/standard/74393.html

**UML**

16. Booch, G., Rumbaugh, J., & Jacobson, I. (2005). *The Unified Modeling
    Language User Guide* (2.ª ed.). Addison-Wesley.
17. Rumbaugh, J., Jacobson, I., & Booch, G. (2004). *The Unified Modeling
    Language Reference Manual* (2.ª ed.). Addison-Wesley.
18. Fowler, M. (2003). *UML Distilled: A Brief Guide to the Standard Object
    Modeling Language* (3.ª ed.). Addison-Wesley.
19. **Object Management Group (2017).** *OMG Unified Modeling Language (OMG
    UML), Version 2.5.1*. Documento formal/2017-12-05.
    https://www.omg.org/spec/UML/2.5.1/
20. **Object Management Group (2015).** *XML Metadata Interchange (XMI)
    Specification, Version 2.5.1*. Documento formal/2015-06-07.
    https://www.omg.org/spec/XMI/2.5.1/
21. **Jakarta EE.** *Jakarta Persistence 3.1 Specification* — estrategias de
    herencia `SINGLE_TABLE`, `JOINED`, `TABLE_PER_CLASS`.
    https://jakarta.ee/specifications/persistence/3.1/

**OMT y Metodología Orientada a Objetos**

22. **Rumbaugh, J., Blaha, M., Premerlani, W., Eddy, F., & Lorensen, W. (1991).
    *Object-Oriented Modeling and Design*. Prentice Hall.** ← *Obra original de
    OMT.*
23. Blaha, M., & Rumbaugh, J. (2005). *Object-Oriented Modeling and Design with
    UML* (2.ª ed.). Prentice Hall.

**Proceso Unificado**

24. Jacobson, I., Booch, G., & Rumbaugh, J. (1999). *The Unified Software
    Development Process*. Addison-Wesley.
25. Kruchten, P. (2003). *The Rational Unified Process: An Introduction*
    (3.ª ed.). Addison-Wesley.
26. Larman, C. (2004). *Applying UML and Patterns: An Introduction to
    Object-Oriented Analysis and Design and Iterative Development* (3.ª ed.).
    Prentice Hall.

**Desarrollo Dirigido por Modelos**

27. Kleppe, A., Warmer, J., & Bast, W. (2003). *MDA Explained: The Model Driven
    Architecture — Practice and Promise*. Addison-Wesley.
28. Brambilla, M., Cabot, J., & Wimmer, M. (2017). *Model-Driven Software
    Engineering in Practice* (2.ª ed.). Morgan & Claypool.
29. **Object Management Group (2014).** *MDA Guide Revision 2.0*. Documento
    ormsc/2014-06-01. https://www.omg.org/cgi-bin/doc?ormsc/14-06-01

**Colaboración y CRDT**

30. Shapiro, M., Preguiça, N., Baquero, C., & Zawirski, M. (2011).
    «Conflict-Free Replicated Data Types». *Stabilization, Safety, and Security
    of Distributed Systems (SSS 2011)*, LNCS 6976, 386-400. INRIA RR-7687.
    https://doi.org/10.1007/978-3-642-24550-3_29
31. Nicolaescu, P., Jahns, K., Derntl, M., & Klamma, R. (2016). «Near Real-Time
    Peer-to-Peer Shared Editing on Extensible Data Types». *Proceedings of the
    19th International Conference on Supporting Group Work (GROUP '16)*, 39-49.
    https://doi.org/10.1145/2957276.2957310 *(Artículo fundacional de Yjs.)*

### Inteligencia Artificial aplicada al software

**Artículos académicos**

32. Chen, M., et al. (2021). «Evaluating Large Language Models Trained on Code».
    arXiv:2107.03374. https://arxiv.org/abs/2107.03374 *(Codex, base de GitHub
    Copilot.)*
33. Peng, S., Kalliamvakou, E., Cihon, P., & Demirer, M. (2023). «The Impact of
    AI on Developer Productivity: Evidence from GitHub Copilot».
    arXiv:2302.06590. https://arxiv.org/abs/2302.06590
34. Hu, E. J., et al. (2021). «LoRA: Low-Rank Adaptation of Large Language
    Models». arXiv:2106.09685. https://arxiv.org/abs/2106.09685
35. Dettmers, T., Pagnoni, A., Holtzman, A., & Zettlemoyer, L. (2023). «QLoRA:
    Efficient Finetuning of Quantized LLMs». arXiv:2305.14314.
    https://arxiv.org/abs/2305.14314
36. Lewis, P., et al. (2020). «Retrieval-Augmented Generation for
    Knowledge-Intensive NLP Tasks». *NeurIPS 2020*. arXiv:2005.11401.
    https://arxiv.org/abs/2005.11401
37. [The Productivity-Reliability Paradox: Specification-Driven Governance for
    AI-Augmented Software Development](https://arxiv.org/pdf/2605.01160) (2026).
    arXiv:2605.01160.
38. [4D-ARE: Bridging the Attribution Gap in LLM Agent Requirements
    Engineering](https://arxiv.org/pdf/2601.04556) (2026). arXiv:2601.04556.

**Desarrollo basado en especificaciones**

39. [Spec-driven development with AI: Get started with a new open source
    toolkit](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/)
    — The GitHub Blog (septiembre de 2025).
40. [GitHub Spec Kit — Toolkit to help you get started with Spec-Driven
    Development](https://github.com/github/spec-kit) — repositorio oficial,
    licencia MIT.
41. [spec-kit/spec-driven.md — Metodología completa de Spec-Driven
    Development](https://github.com/github/spec-kit/blob/main/spec-driven.md)
42. [Spec-Driven Development: A Spec-First Approach to AI-Native
    Engineering](https://developer.microsoft.com/blog/spec-driven-development-ai-native-engineering/)
    — Microsoft for Developers.
43. [Diving Into Spec-Driven Development With GitHub Spec
    Kit](https://developer.microsoft.com/blog/spec-driven-development-spec-kit/)
    — Microsoft for Developers.
44. [Spec-Driven Development (SDD): The Definitive 2026
    Guide](https://www.thebcms.com/blog/spec-driven-development/) — BCMS.
45. [GitHub Spec Kit: A Guide to Spec-Driven AI
    Development](https://intuitionlabs.ai/articles/spec-driven-development-spec-kit)
    — IntuitionLabs.

**Modelos locales y personalización**

46. [Fine-Tune LLMs with LoRA and QLoRA: 2026
    Guide](https://dev.to/jangwook_kim_e31e7291ad98/fine-tune-llms-with-lora-and-qlora-2026-guide-33lf)
    — DEV Community.
47. [Fine-Tune Local LLMs 2026: Practical
    Guide](https://www.sitepoint.com/fine-tune-local-llms-2026/) — SitePoint.
48. [The Complete Guide to Fine-Tuning LLMs Locally (LoRA, QLoRA, Unsloth &
    Ollama)](https://medium.com/@shreetejghodekar/the-complete-guide-to-fine-tuning-llms-locally-lora-qlora-unsloth-ollama-7330fad756eb)
    — Medium.
49. [How to Fine-Tune an LLM With LoRA: 12 Steps, 90 Min
    (2026)](https://tech-insider.org/how-to-fine-tune-llm-lora-2026/) —
    Tech-Insider.
50. **Ollama** — ejecución local de modelos de lenguaje. https://ollama.com/
51. **llama.cpp** — motor de inferencia y formato GGUF.
    https://github.com/ggml-org/llama.cpp
52. **vLLM** — servicio de alto rendimiento con lotes continuos.
    https://github.com/vllm-project/vllm

### Documentación técnica de las tecnologías empleadas

53. **Spring Boot** — Documentación de referencia.
    https://spring.io/projects/spring-boot
54. **PostgreSQL 16** — Documentación oficial.
    https://www.postgresql.org/docs/16/
55. **Yjs** — Framework CRDT para aplicaciones colaborativas.
    https://docs.yjs.dev/
56. **Hocuspocus** — Servidor de colaboración para Yjs.
    https://tiptap.dev/docs/hocuspocus
57. **React 19** — Documentación oficial. https://react.dev/
58. **Prisma ORM** — Documentación. https://www.prisma.io/docs
59. **Zod** — Validación de esquemas con inferencia de tipos.
    https://zod.dev/
60. **OpenAPI Specification 3.1** — https://spec.openapis.org/oas/v3.1.0

### Documentación propia del proyecto

61. `docs/adr/` — Veinte Registros de Decisión Arquitectónica (ADR-001 a
    ADR-020) del proyecto UMLFORGE AI.
62. `docs/requirements/` — Requisitos funcionales (RF), no funcionales (RNF),
    reglas de modelo (RM), reglas de transformación (RTM), reglas
    arquitectónicas (RA) y criterios de aceptación (CA).
63. `shared/contracts/src/vocabulary.ts` — Vocabulario cerrado del modelo
    canónico.

---

*Documento preparado el 10 de septiembre de 2026.*
````

---

### `docs/examen/parte-2-proceso-de-desarrollo.md`

````markdown
# PARTE II — PROCESO DE DESARROLLO

> **Proyecto:** UMLFORGE AI — Plataforma colaborativa asistida por inteligencia
> artificial para el modelado de diagramas de clases UML, reconocimiento de
> bocetos y generación automática de backend Spring Boot.
> **Materia:** Ingeniería de Software 1 · Primer Examen Parcial · Periodo 02/2026
> **Estudiante:** Blanco Camacho Brayan Edgar · Registro 219182965 · Grupo SB
> **Docente:** Ing. Martínez Canedo Rolando Antoni

---

## Nota de lectura

Esta parte documenta el **proceso de desarrollo** de UMLFORGE AI siguiendo los
cinco flujos de trabajo de ingeniería del Proceso Unificado (PUDS), descritos en
la sección 7 de la Parte I: Captura de Requisitos, Análisis, Diseño,
Implementación y Prueba.

Los bloques marcados así indican un **diagrama que debe elaborarse en Enterprise
Architect** e insertarse en ese punto exacto del documento:

> **📐 DIAGRAMA D-xx — Nombre**
> *Tipo EA · Qué debe contener · Notas de elaboración*

El **Anexo A** reúne todos los diagramas en una sola tabla de control, con su
tipo, su ubicación y su estado.

Las referencias entre corchetes —`RF-001`, `RA-03`, `RM-04`, `ADR-007`— apuntan
al catálogo de requisitos (`docs/requirements/`), a las restricciones
arquitectónicas y a los registros de decisión arquitectónica (`docs/adr/`) del
propio repositorio, y funcionan como matriz de trazabilidad viva.

---

# 1. Flujo de Trabajo: Captura de Requisitos

El propósito de este flujo es acordar **qué** debe hacer el sistema, expresado en
el lenguaje del usuario y no en el del programador. En PUDS el artefacto central
es el **modelo de casos de uso**, que se convierte después en el hilo conductor
del análisis, el diseño y las pruebas: cada caso de uso se realiza en el
análisis, se diseña, se implementa y se prueba.

## 1.1 Actores

Un actor representa un **rol** que alguien o algo desempeña frente al sistema, no
a una persona concreta. Una misma persona puede ser propietaria de un proyecto y
lectora de otro; son dos actores distintos frente al sistema.

### 1.1.1 Actores humanos

| Actor | Descripción | Frontera con el sistema |
|---|---|---|
| **Visitante** | Persona no autenticada que llega a la plataforma. Es el estado inicial de todo usuario. | Registro, inicio de sesión, recuperación de contraseña y aceptación de una invitación |
| **Usuario autenticado** | *Actor abstracto.* Generaliza lo que puede hacer cualquier persona con sesión iniciada, con independencia de su rol en un proyecto concreto. | Administrar su perfil, listar los proyectos de los que forma parte, cerrar sesión |
| **Propietario (`OWNER`)** | Creador del proyecto. Especializa al Usuario autenticado. | Todo lo del Editor, más invitar participantes, cambiar roles, expulsar participantes y eliminar el proyecto |
| **Editor (`EDITOR`)** | Participante invitado con permiso de escritura. Especializa al Usuario autenticado. | Crear y administrar pizarras, editar el diagrama, usar el asistente, importar bocetos y XMI, generar y descargar el backend |
| **Lector (`VIEWER`)** | Participante invitado sin permiso de escritura. Especializa al Usuario autenticado. | Abrir y consultar el diagrama en tiempo real, consultar al asistente sin aplicar cambios, exportar XMI |

La relación entre los tres roles de proyecto **no es una jerarquía lineal de
permisos acumulativos**, sino una especialización con un tronco común: los tres
heredan del Usuario autenticado, y `OWNER` añade sobre `EDITOR` únicamente las
capacidades de administración del proyecto. El rol se resuelve por proyecto en
`ProjectMember.role` y se verifica en cada petición
([`membership.ts`](../../backend/api/src/modules/projects/membership.ts)).

### 1.1.2 Actores no humanos (sistemas externos)

| Actor | Descripción | Interacción |
|---|---|---|
| **Proveedor de IA** | Servicio externo de modelos de lenguaje y de visión, accedido tras un puerto con encadenamiento de respaldo [ADR-015, ADR-019]. | Recibe instrucción en lenguaje natural o imagen; devuelve una **propuesta** de lote de comandos, nunca código ni estado |
| **Servicio de transcripción de voz** | Convierte el dictado del usuario en texto antes de que llegue al asistente. | Recibe audio; devuelve transcripción |
| **Servicio de correo** | Envía el enlace de recuperación de contraseña [RF-A10]. | Recibe destinatario y testigo; entrega el mensaje |
| **Herramienta CASE externa** | Enterprise Architect u otra herramienta compatible con XMI 2.5.1 de la OMG. | Consume el XMI exportado y produce el XMI importado |

> **📐 DIAGRAMA D-01 — Diagrama de actores**
> *Tipo EA: Use Case Diagram (solo actores).*
> Dibujar los nueve actores y las relaciones de **generalización** entre ellos:
> `Propietario`, `Editor` y `Lector` heredan de `Usuario autenticado`; `Usuario
> autenticado` **no** hereda de `Visitante` (son estados excluyentes de sesión,
> no una especialización). Marcar `Usuario autenticado` como abstracto (nombre en
> cursiva). Los cuatro actores no humanos van a la derecha, con estereotipo
> `«external system»`.

## 1.2 Casos de Uso

El modelo de casos de uso de UMLFORGE AI comprende **29 casos de uso** agrupados
en **siete paquetes**, que corresponden uno a uno con los siete módulos
funcionales declarados en el alcance (sección 1.5.1 de la Parte I). Esa
correspondencia es deliberada: el paquete de casos de uso, el paquete de análisis
y el subsistema de implementación llevan el mismo nombre, de modo que la
trazabilidad del requisito al código es directa.

### 1.2.1 Catálogo de casos de uso

**Paquete M0a · Gestión de Acceso**

| Código | Caso de uso | Actor principal | Requisitos |
|---|---|---|---|
| CU-01 | Registrar cuenta | Visitante | RF-A01 |
| CU-02 | Iniciar sesión | Visitante | RF-A02 |
| CU-03 | Cerrar sesión | Usuario autenticado | RF-A04 |
| CU-04 | Recuperar contraseña | Visitante | RF-A10 |
| CU-05 | Administrar perfil | Usuario autenticado | RF-A05, RF-A06 |

**Paquete M0b · Gestión de Espacios de Trabajo**

| Código | Caso de uso | Actor principal | Requisitos |
|---|---|---|---|
| CU-06 | Administrar proyectos | Propietario | RF-001, RF-002, RF-003 |
| CU-07 | Administrar pizarras | Editor | RF-004, RF-005 |
| CU-08 | Invitar participante | Propietario | RF-A07 |
| CU-09 | Aceptar invitación | Usuario autenticado | RF-A08 |
| CU-10 | Administrar participantes y roles | Propietario | RF-A07, RF-A09 |

**Paquete M1 · Edición del Modelo**

| Código | Caso de uso | Actor principal | Requisitos |
|---|---|---|---|
| CU-11 | Administrar clases | Editor | RF-010, RF-011, RF-012 |
| CU-12 | Administrar atributos | Editor | RF-013, RF-014 |
| CU-13 | Administrar relaciones | Editor | RF-015, RF-016 |
| CU-14 | Validar el modelo | Editor | RF-017, RM-01 a RM-07 |
| CU-15 | *Aplicar lote de comandos* | — *(caso de uso incluido)* | RA-03, RA-05, RA-06 |

**Paquete M2 · Colaboración**

| Código | Caso de uso | Actor principal | Requisitos |
|---|---|---|---|
| CU-16 | Unirse a la sesión colaborativa | Editor / Lector | RF-020, RF-021, RA-15 |
| CU-17 | Sincronizar cambios concurrentes | Editor | RF-022, RF-024, RNF-01 |
| CU-18 | Consultar la atribución y la auditoría | Propietario | RF-023, RF-026 |

**Paquete M3 · Asistencia por IA**

| Código | Caso de uso | Actor principal | Requisitos |
|---|---|---|---|
| CU-19 | Instruir al asistente por texto | Editor | RF-030, RF-031 |
| CU-20 | Dictar instrucción por voz | Editor | RF-034, RF-035 |
| CU-21 | Consultar al asistente | Lector | RF-037 |
| CU-22 | *Revisar propuesta de comandos* | — *(caso de uso incluido)* | RF-032, RF-033 |

**Paquete M4/M5 · Importación e Interoperabilidad**

| Código | Caso de uso | Actor principal | Requisitos |
|---|---|---|---|
| CU-23 | Reconstruir diagrama desde boceto | Editor | RF-040, RF-041, RF-042 |
| CU-24 | Importar modelo XMI | Editor | RF-051 |
| CU-25 | Exportar modelo XMI | Lector | RF-050 |
| CU-26 | *Revisar candidato importado* | — *(caso de uso incluido)* | RF-043, RF-044, ADR-012 |

**Paquete M6 · Generación del Backend**

| Código | Caso de uso | Actor principal | Requisitos |
|---|---|---|---|
| CU-27 | Generar backend Spring Boot | Editor | RF-060 a RF-068, RA-07, RA-08 |
| CU-28 | Descargar artefacto generado | Editor | RF-069, RF-072 |
| CU-29 | Consultar historial de generaciones | Editor | RF-070, RF-071, ADR-018 |

### 1.2.2 Relaciones entre casos de uso

Los tres casos de uso en cursiva —CU-15, CU-22 y CU-26— son **casos de uso
incluidos**: no los inicia ningún actor, se ejecutan siempre como parte de otro.
Su existencia es la expresión, en el modelo de casos de uso, de la restricción
arquitectónica más importante del sistema:

> **CU-15 · Aplicar lote de comandos** es incluido por **todos** los casos de uso
> que modifican el modelo: CU-11, CU-12, CU-13, CU-19, CU-20, CU-23 y CU-24.

Esto es RA-06 y RA-03 hechos visibles: **ninguna entrada escribe el estado del
diagrama directamente**. La interfaz gráfica, el asistente de texto, el dictado
por voz, el boceto fotografiado y la importación XMI convergen todos en el mismo
punto —validar y aplicar un lote atómico de comandos del vocabulario cerrado—.
Si un caso de uso futuro necesitara escribir el modelo sin pasar por CU-15, sería
una violación de la arquitectura, y el diagrama de casos de uso la delataría.

| Relación | Origen | Destino | Justificación |
|---|---|---|---|
| `«include»` | CU-11, CU-12, CU-13 | CU-15 | Toda edición gráfica produce un lote |
| `«include»` | CU-19, CU-20 | CU-22 → CU-15 | La propuesta de la IA se revisa y luego se aplica |
| `«include»` | CU-23, CU-24 | CU-26 → CU-15 | El candidato importado se revisa y luego se aplica |
| `«include»` | CU-15 | CU-14 | La validación ocurre **antes** de aplicar; si hay un solo error, no se aplica nada |
| `«include»` | CU-27 | CU-14 | No se genera desde un modelo inválido |
| `«extend»` | CU-20 | CU-19 | El dictado por voz extiende la instrucción de texto: transcribe y continúa el mismo flujo |
| `«extend»` | CU-09 | CU-02 | Si el invitado no tiene sesión, aceptar la invitación extiende el inicio de sesión |
| Generalización | CU-23, CU-24 | *Importar modelo* | Boceto y XMI son dos especializaciones del mismo flujo de candidato editable |

> **📐 DIAGRAMA D-02 — Diagrama general de casos de uso**
> *Tipo EA: Use Case Diagram.*
> Vista de conjunto con los cinco actores humanos a la izquierda, los cuatro
> actores externos a la derecha, y los **siete paquetes** dibujados como paquetes
> (no como casos de uso sueltos). Este diagrama no muestra los 29 casos de uso:
> muestra qué actor entra en qué paquete. Es el mapa de una página que se enseña
> primero. Dibujar el límite del sistema (`System Boundary`) rotulado
> **UMLFORGE AI**.

> **📐 DIAGRAMA D-03 — Casos de uso · Paquete M0a Gestión de Acceso**
> *Tipo EA: Use Case Diagram.* CU-01 a CU-05, actores Visitante y Usuario
> autenticado, y el actor externo Servicio de correo conectado a CU-04.

> **📐 DIAGRAMA D-04 — Casos de uso · Paquete M0b Gestión de Espacios de Trabajo**
> *Tipo EA: Use Case Diagram.* CU-06 a CU-10. Mostrar el `«extend»` de CU-09
> sobre CU-02 con una nota que indique la condición de extensión: *«el invitado
> no tiene sesión iniciada»*.

> **📐 DIAGRAMA D-05 — Casos de uso · Paquete M1 Edición del Modelo**
> *Tipo EA: Use Case Diagram.* **El diagrama más importante del modelo.** CU-11 a
> CU-14 con sus `«include»` convergiendo en CU-15, y CU-15 incluyendo a CU-14.
> Dibujar CU-15 en el centro y abajo, de modo que la convergencia se vea a simple
> vista. Añadir una nota anclada a CU-15 con el texto de RA-03: *«Lote
> transaccional: la validación ocurre antes de aplicar; todo o nada»*.

> **📐 DIAGRAMA D-06 — Casos de uso · Paquete M2 Colaboración**
> *Tipo EA: Use Case Diagram.* CU-16 a CU-18. Nota anclada a CU-16 con RA-15:
> *«toda conexión se autentica y autoriza antes de unirse a la sala»*.

> **📐 DIAGRAMA D-07 — Casos de uso · Paquete M3 Asistencia por IA**
> *Tipo EA: Use Case Diagram.* CU-19 a CU-22, con el actor externo Proveedor de
> IA y el Servicio de transcripción. Mostrar el `«extend»` de CU-20 sobre CU-19 y
> el `«include»` de ambos hacia CU-22. Nota con RA-06 y RA-07: *«vocabulario
> cerrado; ningún modelo de lenguaje escribe Java»*.

> **📐 DIAGRAMA D-08 — Casos de uso · Paquete M4/M5 Importación e Interoperabilidad**
> *Tipo EA: Use Case Diagram.* CU-23 a CU-26, con la generalización de CU-23 y
> CU-24 hacia un caso de uso abstracto *Importar modelo*, y el actor externo
> Herramienta CASE externa conectado a CU-24 y CU-25.

> **📐 DIAGRAMA D-09 — Casos de uso · Paquete M6 Generación del Backend**
> *Tipo EA: Use Case Diagram.* CU-27 a CU-29. Nota anclada a CU-27 con RA-08:
> *«la generación opera sobre snapshot inmutable, no sobre estado vivo»*.

## 1.3 Priorizar Casos de Uso

En PUDS la priorización no es una lista de deseos ordenada por gusto: es una
**decisión de gestión de riesgo**. Se atacan primero los casos de uso
**arquitectónicamente significativos** —los que, si resultan inviables, obligan a
rediseñar el sistema entero— y no los más vistosos ni los más fáciles.

### 1.3.1 Criterios de priorización aplicados

| Criterio | Peso | Qué mide |
|---|---|---|
| **Riesgo técnico** | Alto | ¿Sé con certeza que esto se puede construir? ¿Hay un supuesto sin verificar? |
| **Impacto arquitectónico** | Alto | Si falla, ¿cuántos otros casos de uso hay que rehacer? |
| **Valor para la demostración** | Medio | ¿Aparece en el criterio de cierre del proyecto (sección 1.5.7 de la Parte I)? |
| **Dependencia** | Medio | ¿Bloquea a otros casos de uso? |

### 1.3.2 Clasificación por prioridad

| Prioridad | Significado | Casos de uso |
|---|---|---|
| **P0 · Crítico** | Sin esto falla la demostración. Arquitectónicamente significativo. | CU-15, CU-14, CU-11, CU-12, CU-13, CU-16, CU-17, CU-27 |
| **P1 · Alto** | Necesario para una demostración confiable y completa. | CU-01, CU-02, CU-06, CU-07, CU-19, CU-23, CU-28 |
| **P2 · Medio** | Completa el alcance; posterior al núcleo. | CU-03, CU-05, CU-08, CU-09, CU-10, CU-18, CU-20, CU-21, CU-22, CU-24, CU-25, CU-26, CU-29 |
| **P3 · Bajo** | Mejora de conveniencia. | CU-04 |

### 1.3.3 Casos de uso arquitectónicamente significativos

Cinco casos de uso concentran el riesgo del proyecto. Sobre ellos se construyó la
**línea base de la arquitectura** durante la fase de Elaboración, mediante
*spikes* técnicos ejecutados **antes** de escribir el editor:

| Caso de uso | Riesgo que verifica | ADR que lo resuelve | Resultado del *spike* |
|---|---|---|---|
| **CU-17 · Sincronizar cambios concurrentes** | ¿Convergen dos ediciones simultáneas sin bloqueo ni pérdida de trabajo? | ADR-002 (CRDT) | Yjs/Hocuspocus converge; se adopta CRDT frente a bloqueo de elementos |
| **CU-15 · Aplicar lote de comandos** | ¿Puede un único núcleo canónico recibir cinco orígenes de entrada distintos? | ADR-003 (modelo canónico y comandos por lotes) | Vocabulario cerrado de once comandos; aplicador y validador únicos [RA-05] |
| **CU-27 · Generar backend Spring Boot** | ¿Es viable generar un proyecto que **compile y arranque** sin tocar nada a mano? | ADR-007 (generación por IR y plantillas) | Representación intermedia + plantillas; determinismo verificable |
| **CU-16 · Unirse a la sesión colaborativa** | ¿Basta con proteger las rutas HTTP? | ADR-001 (dos procesos), RA-15 | No basta: el proceso WebSocket autoriza antes de admitir en la sala |
| **CU-19 · Instruir al asistente por texto** | ¿Puede la IA proponer sin poder corromper el modelo? | ADR-015, ADR-019 (puertos y respaldo) | La IA emite propuestas sobre vocabulario cerrado; el usuario confirma |

### 1.3.4 Plan de iteraciones

El desarrollo se organizó en **once fases numeradas** (0 a 10), agrupadas en las
cuatro fases del PUDS. La tabla siguiente traduce el plan real de desarrollo del
repositorio al vocabulario del Proceso Unificado:

| Fase PUDS | Iteración (fase del proyecto) | Casos de uso abordados | Hito alcanzado |
|---|---|---|---|
| **Inicio** | Fase 0 · Entorno y esqueleto | — | Un solo comando levanta el entorno [RNF-12]; base de integración continua [RNF-13]; dominio aislado [RNF-15] |
| **Elaboración** | Fase 1 · Núcleo canónico | CU-15, CU-14 | Vocabulario, aplicador y validador únicos [RM-01 a RM-07, RTM-01 a RTM-04] |
| **Elaboración** | Fase 2 · *Spike* de generación | CU-27 (parcial) | El proyecto generado compila y arranca [RTM-05 a RTM-13, RNF-05, RNF-07] |
| **Construcción** | Fase 3 · Cuentas, proyectos y pizarras | CU-01, CU-02, CU-06, CU-07 | Persistencia y sesión funcionando |
| **Construcción** | Fase 4 · Colaboración | CU-16, CU-17, CU-18 | Cinco usuarios por pizarra, propagación bajo 500 ms [RNF-01, RNF-02] |
| **Construcción** | Fase 5 · Editor gráfico | CU-11, CU-12, CU-13, CU-14 | Editor completo con validación en vivo [RNF-03, RNF-04] |
| **Construcción** | Fase 6 · Generación desde la interfaz | CU-27, CU-28 | Del diagrama al ZIP descargable |
| **Construcción** | Fase 7 · Asistente de IA | CU-19, CU-20, CU-21, CU-22 | Texto y voz sobre vocabulario cerrado |
| **Construcción** | Fase 8 · Boceto e interoperabilidad | CU-23, CU-24, CU-25, CU-26 | Imagen y XMI 2.5.1 como candidatos editables |
| **Construcción** | Fase 9 · Histórico | — | Módulo móvil evaluado y **retirado** del alcance ejecutable |
| **Transición** | Fase 10 · Integración y ensayo | CU-29 + integración | Snapshot y manifiesto congelados; guion de demostración |

Obsérvese el orden: **la colaboración y la generación se construyeron antes que
el editor gráfico**. Es contraintuitivo desde el punto de vista del usuario
—¿cómo se colabora si no hay editor?— pero es exactamente lo que prescribe PUDS:
el editor es trabajo conocido y de bajo riesgo; la convergencia CRDT y la
generación determinista no lo eran. Se atacó primero lo que podía hundir el
proyecto.
## 1.4 Detallar Casos de Uso

Se detallan los casos de uso mediante la plantilla estándar del Proceso
Unificado. Los **ocho casos de uso P0** se desarrollan por completo, con flujo
básico, flujos alternativos, precondiciones, poscondiciones y requisitos
especiales. Los de prioridad P1 a P3 se presentan en forma resumida al final de
la sección, con el mismo esqueleto, listos para expandirse a la plantilla
completa si el docente lo requiere.

### 1.4.0 Plantilla empleada

| Campo | Contenido |
|---|---|
| **Código y nombre** | Identificador y nombre en infinitivo |
| **Descripción** | Una frase: qué logra el actor |
| **Actor principal / secundarios** | Quién lo inicia y quién más participa |
| **Precondiciones** | Lo que debe ser cierto **antes**; si no lo es, el caso de uso no arranca |
| **Poscondiciones de éxito** | Lo que es cierto **después** de un flujo básico completo |
| **Disparador** | El suceso que lo inicia |
| **Flujo básico** | Camino feliz, numerado, alternando actor y sistema |
| **Flujos alternativos** | Ramas nombradas `An`, ancladas al paso del que se desvían |
| **Requisitos especiales** | No funcionales que aplican a este caso de uso |
| **Frecuencia / prioridad** | Uso esperado y prioridad asignada |
| **Puntos de extensión / inclusión** | Relaciones con otros casos de uso |

---

### CU-15 · Aplicar lote de comandos

| | |
|---|---|
| **Descripción** | Validar y aplicar de forma atómica un conjunto de comandos del vocabulario cerrado sobre el modelo canónico de una pizarra. |
| **Tipo** | **Caso de uso incluido.** No lo inicia ningún actor directamente. |
| **Actores** | Ninguno directo. Incluido por CU-11, CU-12, CU-13, CU-19, CU-20, CU-23 y CU-24. |
| **Prioridad** | **P0** — Arquitectónicamente significativo |
| **Frecuencia** | Altísima: cada operación de edición de cada usuario de cada pizarra |

**Precondiciones**
1. Existe una sesión colaborativa abierta sobre la pizarra (CU-16 completado).
2. El actor que originó el lote tiene rol `OWNER` o `EDITOR` en el proyecto.
3. El lote trae declarados su identificador (`batchId`), su origen (`GUI`,
   `AI_TEXT`, `AI_VOICE`, `IMAGE` o `XMI`) y la atribución del actor.

**Poscondiciones de éxito**
1. El modelo canónico refleja **todos** los comandos del lote.
2. Se emitió **una sola** actualización incremental a los demás participantes,
   no una por comando [RA-03].
3. El lote quedó registrado en `audit_operations` con su origen y su actor.
4. El documento colaborativo se persistió en su representación binaria nativa
   [RA-11].

**Flujo básico**

| # | Actor / origen | Sistema |
|---|---|---|
| 1 | Un caso de uso incluyente entrega una **propuesta de lote** | |
| 2 | | Comprueba que cada comando pertenece al vocabulario cerrado de once operaciones [RA-06] |
| 3 | | Resuelve las referencias estructurales por identificador **UUID interno**, nunca por nombre [RA-04] |
| 4 | | Ejecuta el validador sobre el estado resultante hipotético — **antes de aplicar nada** |
| 5 | | El validador no devuelve ningún diagnóstico de severidad `error` |
| 6 | | Abre una **transacción única** sobre el documento colaborativo |
| 7 | | Aplica los comandos en orden mediante el aplicador único [RA-05] |
| 8 | | Cierra la transacción: el documento emite **una sola** actualización |
| 9 | | Propaga la actualización incremental a los demás participantes |
| 10 | | Registra el lote en la auditoría, deduplicando por `(boardId, batchId)` |
| 11 | | Devuelve al incluyente el resultado con los diagnósticos de severidad `aviso`, si los hubiera |

**Flujos alternativos**

**A1 · Comando fuera del vocabulario** *(del paso 2)*
El sistema rechaza el lote completo sin aplicar nada e informa qué comando es
inválido. No se registra en auditoría. **El caso de uso termina en fallo.**

**A2 · Referencia estructural no resoluble** *(del paso 3)*
Un comando apunta a una clase o relación que ya no existe —fue eliminada por otro
participante mientras se componía el lote—. El sistema rechaza el lote completo e
informa qué referencia falta. **El caso de uso termina en fallo.**

**A3 · El validador devuelve al menos un error** *(del paso 5)*
El sistema **no aplica ningún comando del lote**, ni siquiera los que habrían sido
válidos por separado, y devuelve la lista completa de diagnósticos con su
severidad y el elemento afectado. **El caso de uso termina en fallo.** Esta rama
es la manifestación literal de RA-03: *todo o nada*.

**A4 · Lote duplicado por reintento de red** *(del paso 10)*
El cliente reintentó el envío tras un corte. La restricción única
`(boardId, batchId)` detecta la repetición; el sistema descarta el registro
duplicado sin aplicar los comandos por segunda vez y devuelve el resultado
original. **El caso de uso termina con éxito** (idempotencia).

**A5 · Conflicto de convergencia** *(del paso 8)*
Dos participantes aplicaron lotes simultáneos sobre los mismos elementos. El CRDT
converge estructuralmente sin intervención, pero **la convergencia no garantiza
validez semántica** [RA-12]: el modelo resultante puede ser inválido. El sistema
ejecuta el validador sobre el estado convergido y marca los diagnósticos en la
interfaz de ambos participantes. **El caso de uso termina con éxito**; la
corrección queda a cargo de los usuarios y la generación permanece bloqueada
mientras haya errores.

**Requisitos especiales**
- RNF-01: la actualización alcanza a los demás participantes en menos de 500 ms.
- RA-05: el validador que se ejecuta aquí es **el mismo módulo** que se ejecuta en
  el navegador. Una implementación, dos lugares de ejecución.

---

### CU-14 · Validar el modelo

| | |
|---|---|
| **Descripción** | Comprobar que el modelo canónico cumple las reglas del subconjunto UML soportado, e informar las violaciones con severidad diferenciada. |
| **Actor principal** | Editor (de forma continua, mientras edita) |
| **Prioridad** | **P0** |
| **Incluido por** | CU-15 (antes de aplicar) y CU-27 (antes de generar) |

**Precondiciones**
1. Hay una pizarra abierta con un modelo canónico, aunque esté vacío.

**Poscondiciones de éxito**
1. El panel de validación muestra la lista actualizada de diagnósticos.
2. Cada diagnóstico identifica el elemento afectado y su severidad.
3. Si existe al menos un diagnóstico de severidad `error`, la generación (CU-27)
   queda **bloqueada**.

**Flujo básico**

| # | Actor | Sistema |
|---|---|---|
| 1 | El Editor modifica el modelo, o solicita la validación explícitamente | |
| 2 | | Recorre el modelo canónico aplicando las reglas de modelado RM-01 a RM-07 |
| 3 | | Verifica las reglas de la jerarquía de herencia: ausencia de ciclos, herencia simple, coherencia de la clave primaria heredada |
| 4 | | Verifica las reglas de transformación exigibles ya en el modelo: tipos conceptuales soportados, multiplicidades del conjunto cerrado, nombres no vacíos y únicos por ámbito |
| 5 | | Clasifica cada hallazgo como `error` (impide generar) o `aviso` (no impide generar) |
| 6 | | Presenta los diagnósticos en el panel de validación, con enlace al elemento afectado |
| 7 | El Editor selecciona un diagnóstico | |
| 8 | | Resalta y enfoca el elemento correspondiente en el lienzo |

**Flujos alternativos**

**A1 · Construcción UML fuera de alcance** *(del paso 2)*
El modelo contiene una construcción declarada explícitamente fuera de alcance
—herencia múltiple, clave compuesta, relación ternaria directa—. El sistema no se
limita a rechazarla: la identifica por su nombre y **sugiere cómo modelarla**
dentro del subconjunto soportado (por ejemplo, resolver la relación ternaria
mediante una entidad intermedia). La exclusión es una decisión documentada, no
una omisión.

**A2 · Modelo válido pero vacío** *(del paso 6)*
No hay diagnósticos, pero tampoco hay clases. El sistema informa que no hay nada
que generar, con severidad `aviso`.

**A3 · Nombre que colisiona con palabra reservada** *(del paso 4)*
El nombre de una clase o de un atributo coincide con una palabra reservada de SQL
o de Java. El sistema emite un `aviso` —no un `error`— e indica que en la
generación se aplicará el escape correspondiente. El modelo es válido; el usuario
solo debe saberlo.

**Requisitos especiales**
- RNF-04: el resultado de la validación se refleja en la interfaz sin que el
  usuario perciba interrupción del trabajo de edición.
- RA-05: mismas reglas en navegador y servidor, un solo módulo
  ([`validate.ts`](../../shared/domain-core/src/validate.ts)).

---

### CU-11 · Administrar clases

| | |
|---|---|
| **Descripción** | Crear, renombrar, mover y eliminar las clases del diagrama desde la interfaz gráfica. |
| **Actor principal** | Editor |
| **Prioridad** | **P0** |
| **Incluye** | CU-15 |

**Precondiciones**
1. El Editor tiene una pizarra abierta y sesión colaborativa establecida.
2. Su rol en el proyecto es `OWNER` o `EDITOR`.

**Poscondiciones de éxito**
1. El modelo canónico contiene la clase con su identificador UUID propio.
2. Los demás participantes ven el cambio.
3. La operación quedó atribuida a su autor en la auditoría.

**Flujo básico — Crear clase**

| # | Actor | Sistema |
|---|---|---|
| 1 | El Editor selecciona la herramienta *Clase* y hace clic en el lienzo | |
| 2 | | Genera un identificador **UUID** para la nueva clase [RA-04] |
| 3 | | Compone un lote con el comando `CREATE_CLASS` y origen `GUI` |
| 4 | | **Incluye CU-15** para validar y aplicar el lote |
| 5 | | Dibuja el nodo de la clase en la posición indicada y lo deja en edición de nombre |
| 6 | El Editor escribe el nombre y confirma | |
| 7 | | Compone un lote con `RENAME_CLASS` e **incluye CU-15** |

**Flujos alternativos**

**A1 · Nombre duplicado** *(del paso 7)*
Ya existe una clase con ese nombre en la pizarra. CU-15 devuelve un diagnóstico
de severidad `error` y el nombre no se aplica; el nodo conserva el anterior y el
campo queda marcado.

**A2 · Renombrar una clase con relaciones** *(flujo de renombrado)*
El cambio de nombre **no rompe ninguna relación**: las relaciones referencian el
UUID interno, no el nombre [RA-04]. Las etiquetas del lienzo se actualizan solas.

**A3 · Eliminar una clase con relaciones** *(flujo de eliminación)*
El sistema advierte cuántas relaciones se eliminarán en cascada y pide
confirmación. Si el Editor confirma, el lote contiene `DELETE_CLASS` **y** los
`DELETE_RELATIONSHIP` correspondientes: la eliminación es una sola unidad
atómica, no una secuencia que pueda quedar a medias.

**A4 · Eliminar una superclase** *(flujo de eliminación)*
La clase tiene subclases. El sistema advierte que las relaciones de generalización
se eliminarán y que las subclases quedarán independientes, y pide confirmación.

**A5 · Mover clase** *(flujo de movimiento)*
El comando `MOVE_CLASS` modifica el *layout*, que **no tiene valor semántico**. Se
aplica igualmente por lote para que los demás participantes lo vean, pero no
altera el snapshot de generación.

**Requisitos especiales**
- RNF-03: el lienzo mantiene fluidez con el número de clases previsto por el
  requisito.

---

### CU-12 · Administrar atributos

| | |
|---|---|
| **Descripción** | Añadir, modificar y eliminar los atributos de una clase, con su tipo conceptual, su condición de clave primaria, su nulabilidad y su unicidad. |
| **Actor principal** | Editor |
| **Prioridad** | **P0** |
| **Incluye** | CU-15 |

**Precondiciones**
1. Hay una clase seleccionada en el inspector.

**Poscondiciones de éxito**
1. La clase contiene el atributo con su tipo del conjunto cerrado de ocho tipos
   conceptuales: `String`, `Integer`, `Long`, `Decimal`, `Boolean`, `Date`,
   `DateTime`, `UUID`.

**Flujo básico**

| # | Actor | Sistema |
|---|---|---|
| 1 | El Editor selecciona una clase y abre el inspector de atributos | |
| 2 | El Editor añade una fila e indica nombre y tipo | |
| 3 | | Ofrece únicamente los ocho tipos conceptuales soportados [RTM-01] |
| 4 | El Editor marca, si procede, clave primaria, nulable o único | |
| 5 | | Compone el lote con `ADD_ATTRIBUTE` e **incluye CU-15** |
| 6 | | Actualiza el compartimento de atributos del nodo en el lienzo |

**Flujos alternativos**

**A1 · Segunda clave primaria en la misma clase** *(del paso 4)*
Las claves compuestas están fuera de alcance. El sistema desmarca la anterior o
rechaza la segunda con un `error`, e informa la razón.

**A2 · Clave primaria en una subclase** *(del paso 4)*
La clase hereda de otra. Bajo la estrategia de tabla por clase unida por la clave
primaria [ADR-020], la subclase **no declara su propia clave**: la hereda. El
sistema lo impide y lo explica.

**A3 · Nombre de atributo duplicado en la clase** *(del paso 5)*
CU-15 devuelve `error`; el atributo no se añade.

**A4 · Cambiar el tipo de un atributo ya usado** *(flujo de modificación)*
El sistema aplica `UPDATE_ATTRIBUTE`. Advierte, con severidad `aviso`, que el
cambio alterará el tipo de la columna en el próximo proyecto generado.

---

### CU-13 · Administrar relaciones

| | |
|---|---|
| **Descripción** | Crear, modificar y eliminar las relaciones entre clases, con su tipo, su multiplicidad y su nombre de rol en ambos extremos. |
| **Actor principal** | Editor |
| **Prioridad** | **P0** |
| **Incluye** | CU-15 |

**Precondiciones**
1. Existen al menos dos clases en la pizarra (o una, para una relación reflexiva).

**Poscondiciones de éxito**
1. La relación existe en el modelo con uno de los cuatro tipos soportados
   —asociación, generalización, composición, agregación— y con multiplicidad del
   conjunto cerrado `1`, `0..1`, `0..*`, `1..*` en ambos extremos.
2. La relación se dibuja con su **notación UML propia**: rombo relleno para
   composición, rombo hueco para agregación, triángulo hueco para generalización,
   línea simple para asociación.

**Flujo básico**

| # | Actor | Sistema |
|---|---|---|
| 1 | El Editor arrastra desde el conector de una clase hasta otra | |
| 2 | | Muestra el selector del tipo de relación |
| 3 | El Editor elige el tipo | |
| 4 | | Asigna multiplicidad por omisión según el tipo elegido |
| 5 | | Compone el lote con `CREATE_RELATIONSHIP` e **incluye CU-15** |
| 6 | | Dibuja el conector con la notación UML del tipo elegido |
| 7 | El Editor ajusta multiplicidades y nombres de rol en el inspector | |
| 8 | | Compone lotes con `CHANGE_MULTIPLICITY` o `UPDATE_RELATIONSHIP` e **incluye CU-15** |

**Flujos alternativos**

**A1 · Generalización que crea un ciclo** *(del paso 5)*
`A` hereda de `B` y se intenta que `B` herede de `A`. CU-14 devuelve `error` y la
relación no se crea.

**A2 · Segunda superclase para la misma clase** *(del paso 5)*
La herencia múltiple está fuera de alcance. El sistema lo impide y sugiere modelar
la segunda relación como asociación o composición.

**A3 · Multiplicidad muchos-a-muchos** *(del paso 8)*
Ambos extremos son `0..*` o `1..*`. El sistema emite un `aviso` informando que en
la generación la relación se resolverá mediante una **entidad intermedia**
[ADR-005, RM-01], y ofrece crearla explícitamente para que el usuario controle su
nombre y sus atributos propios.

**A4 · Multiplicidad en una generalización** *(del paso 7)*
La generalización no tiene multiplicidad. El sistema no ofrece el campo.

---

### CU-16 · Unirse a la sesión colaborativa

| | |
|---|---|
| **Descripción** | Establecer la conexión en tiempo real con la sala de una pizarra, previa autenticación y autorización, y recibir el estado actual del documento. |
| **Actor principal** | Editor o Lector |
| **Prioridad** | **P0** |

**Precondiciones**
1. El usuario tiene sesión iniciada y credencial vigente.
2. Es miembro del proyecto al que pertenece la pizarra.

**Poscondiciones de éxito**
1. El navegador tiene una réplica local del documento colaborativo.
2. Los demás participantes ven la presencia del recién llegado.
3. El editor visual muestra la **proyección** del documento; el documento, y no el
   lienzo, es la fuente de verdad.

**Flujo básico**

| # | Actor | Sistema |
|---|---|---|
| 1 | El usuario abre una pizarra | |
| 2 | | Abre la conexión al proceso de colaboración presentando la credencial |
| 3 | | **Autentica la conexión y autoriza el acceso a la sala antes de admitirla** [RA-15] |
| 4 | | Carga el estado binario nativo del documento desde la base [RA-11] |
| 5 | | Sincroniza la réplica local del cliente |
| 6 | | Registra y difunde la presencia del participante con su nombre y color |
| 7 | | Proyecta el documento sobre el lienzo del editor |
| 8 | | Si el rol es `VIEWER`, deshabilita las herramientas de edición |

**Flujos alternativos**

**A1 · Credencial ausente, inválida o caducada** *(del paso 3)*
La conexión se rechaza **antes** de unirse a la sala. No basta con proteger las
rutas HTTP: sin este paso, cualquiera con la dirección de la sala vería y
editaría el diagrama.

**A2 · El usuario no es miembro del proyecto** *(del paso 3)*
La conexión se rechaza con el motivo correspondiente.

**A3 · Sesión invalidada por cambio de contraseña** *(del paso 3)*
La versión de sesión del usuario no coincide con la vigente. La conexión se
rechaza y el cliente retorna al inicio de sesión.

**A4 · Pérdida de conexión durante la sesión** *(en cualquier momento posterior)*
El cliente encola localmente los lotes pendientes y reintenta la conexión. Al
restablecerse, reenvía la cola; el servidor **deduplica por `(boardId, batchId)`**
y aplica solo lo que falte. El usuario no pierde trabajo ni lo duplica.

**A5 · Primera apertura de la pizarra** *(del paso 4)*
No existe todavía documento persistido. El sistema crea uno vacío con la versión
de esquema declarada [RA-09].

**Requisitos especiales**
- RNF-02: al menos cinco participantes simultáneos por pizarra sin degradación.

---

### CU-17 · Sincronizar cambios concurrentes

| | |
|---|---|
| **Descripción** | Propagar entre todos los participantes las modificaciones del modelo, garantizando convergencia sin bloqueo de elementos ni pérdida de trabajo ajeno. |
| **Actor principal** | Editor |
| **Prioridad** | **P0** — Arquitectónicamente significativo |

**Precondiciones**
1. Dos o más participantes tienen la misma pizarra abierta (CU-16 completado).

**Poscondiciones de éxito**
1. Todas las réplicas convergen al **mismo estado estructural**.
2. Cada participante ve quién hizo cada cambio y qué elemento está editando otro.
3. El documento quedó persistido en su representación binaria nativa.

**Flujo básico**

| # | Actor | Sistema |
|---|---|---|
| 1 | Dos Editores modifican elementos distintos al mismo tiempo | |
| 2 | | Cada cliente aplica su lote sobre su réplica local (CU-15) y emite la actualización incremental |
| 3 | | El proceso de colaboración recibe ambas actualizaciones y las difunde |
| 4 | | Cada réplica integra la actualización ajena mediante el CRDT, **sin bloquear ningún elemento** |
| 5 | | Todas las réplicas convergen al mismo estado |
| 6 | | Difunde el indicador de presencia: qué elemento está editando cada participante |
| 7 | | Persiste el estado del documento |

**Flujos alternativos**

**A1 · Modificación simultánea del mismo atributo** *(del paso 4)*
El CRDT resuelve el conflicto de forma determinista y **sin pérdida del
documento**; prevalece una de las dos escrituras según la regla del tipo de dato
replicado. Ambos usuarios ven el mismo resultado final y la atribución indica
quién escribió lo que quedó.

**A2 · Un usuario elimina lo que otro está editando** *(del paso 4)*
Las réplicas convergen a la eliminación. El cliente del segundo usuario cierra el
inspector del elemento desaparecido e informa qué ocurrió y quién lo hizo.

**A3 · Convergencia a un modelo semánticamente inválido** *(del paso 5)*
Dos lotes válidos por separado producen, al converger, un modelo que viola una
regla de modelado. **El CRDT garantiza convergencia estructural, no validez
semántica** [RA-12]. El validador (CU-14) marca el problema en la interfaz de
todos los participantes y la generación queda bloqueada hasta corregirlo. Este
flujo alternativo **no es un defecto**: es una consecuencia asumida y documentada
de haber elegido convergencia sin bloqueo.

**Requisitos especiales**
- RNF-01: propagación por debajo de 500 ms.
- RNF-02: al menos cinco participantes simultáneos.

---

### CU-27 · Generar backend Spring Boot

| | |
|---|---|
| **Descripción** | Producir, a partir del modelo validado de la pizarra seleccionada, un proyecto Spring Boot completo, determinista y listo para compilar y ejecutar. |
| **Actor principal** | Editor |
| **Prioridad** | **P0** — Arquitectónicamente significativo |
| **Incluye** | CU-14 |

**Precondiciones**
1. La pizarra contiene al menos una clase.
2. La validación (CU-14) no devuelve ningún diagnóstico de severidad `error`.
3. El Editor indicó el nombre del proyecto, el identificador de artefacto y el
   paquete base Java.

**Poscondiciones de éxito**
1. Existe una fila de generación con su **manifiesto congelado**: nombre de
   proyecto, artefacto, paquete base, versión de esquema y huella de plantillas.
2. El snapshot del modelo quedó congelado e inmutable, con su número de versión.
3. Se registró la suma de verificación SHA-256 del artefacto.
4. El artefacto **no se almacena**: se regenera desde el snapshot y el manifiesto
   [ADR-018].

**Flujo básico**

| # | Actor | Sistema |
|---|---|---|
| 1 | El Editor abre el panel de Generación y confirma los datos del proyecto | |
| 2 | | **Incluye CU-14**: valida el modelo |
| 3 | | Proyecta el documento colaborativo al JSON canónico y **congela el snapshot** con su versión [RA-08] |
| 4 | | Crea la fila de generación en estado `CREATING`, con el manifiesto completo |
| 5 | | Traduce el snapshot a la **representación intermedia** aplicando las reglas de transformación: tipos conceptuales a tipos Java y SQL, multiplicidades a claves foráneas, muchos-a-muchos a entidad intermedia, escape de palabras reservadas, generalización a `InheritanceType.JOINED` |
| 6 | | Emite el proyecto mediante **plantillas deterministas**: entidades JPA, repositorios, servicios, controladores REST con CRUD completo, DTO planos, configuración Maven, esquema PostgreSQL, OpenAPI y archivos de contenedor |
| 7 | | Empaqueta el resultado y calcula su SHA-256 |
| 8 | | Marca la generación como `READY` y registra la huella |
| 9 | | Habilita la descarga (CU-28) |

**Flujos alternativos**

**A1 · El modelo tiene errores de validación** *(del paso 2)*
La generación no comienza. El sistema presenta los diagnósticos y enfoca el
primero. **El caso de uso termina en fallo.**

**A2 · La pizarra está vacía** *(del paso 2)*
No hay nada que generar. El sistema lo informa y no crea fila de generación.

**A3 · Fallo durante la emisión** *(del paso 6)*
La generación queda en estado `FAILED` con el motivo **saneado** del fallo. La
fila **se conserva deliberadamente**: sirve para explicar qué ocurrió. El Editor
puede reintentar; el reintento crea una generación nueva, no reutiliza la fallida.

**A4 · Palabra reservada como nombre de tabla o columna** *(del paso 5)*
El generador aplica el escape correspondiente de forma automática y determinista.
No interrumpe el flujo.

**A5 · La pizarra se renombra después de generar** *(posterior al caso de uso)*
El artefacto de la generación anterior **no cambia**: el nombre está congelado en
el manifiesto y no se relee de la pizarra. Esta es precisamente la razón de existir
del manifiesto.

**A6 · Regeneración del mismo snapshot con las mismas plantillas** *(caso de verificación)*
El sistema produce **exactamente los mismos bytes**, comprobable por la suma
SHA-256. Es la definición operativa del determinismo exigido por RA-07.

**Requisitos especiales**
- RA-07: la generación es determinista por plantillas. **Ningún modelo de lenguaje
  escribe Java.**
- RNF-05, RNF-07: el proyecto generado compila y arranca sin intervención manual.
- El banco de pruebas verifica esto de forma automatizada sobre ocho modelos
  distintos (`npm run test:bank`).

---

### 1.4.1 Casos de uso de prioridad P1 a P3 — forma resumida

| CU | Precondición clave | Flujo básico (resumen) | Flujos alternativos |
|---|---|---|---|
| **CU-01 Registrar cuenta** | No existe cuenta con ese correo | Datos → validación → derivación lenta de la contraseña [RNF-08] → cuenta creada → sesión iniciada | A1 correo ya registrado · A2 contraseña débil · A3 formato de correo inválido |
| **CU-02 Iniciar sesión** | La cuenta existe | Credenciales → verificación → emisión de credencial de acceso y testigo de refresco | A1 credenciales incorrectas (mensaje genérico, sin revelar si el correo existe) · A2 sesión invalidada |
| **CU-03 Cerrar sesión** | Sesión activa | Solicitud → revocación del testigo de refresco → retorno al inicio | A1 el testigo ya estaba revocado |
| **CU-04 Recuperar contraseña** | La cuenta existe | Correo → se guarda el **hash** del testigo, nunca el testigo → envío del enlace → un solo uso y caducidad → nueva contraseña → invalidación de sesiones | A1 correo no registrado (respuesta idéntica, para no revelar existencia) · A2 enlace caducado · A3 enlace ya usado |
| **CU-05 Administrar perfil** | Sesión activa | Cambiar nombre visible · subir foto recortada a 256×256, almacenada en la base · cambiar contraseña | A1 imagen que excede el límite de la ruta · A2 formato no soportado |
| **CU-06 Administrar proyectos** | Sesión activa | Crear con versión de esquema declarada · listar los propios y aquellos donde es miembro · renombrar · eliminar en cascada | A1 eliminar sin ser propietario · A2 eliminación con pizarras (advertencia de cascada) |
| **CU-07 Administrar pizarras** | Ser miembro con escritura | Crear dentro del proyecto · listar · renombrar · eliminar · **seleccionar la pizarra objetivo de la generación** | A1 eliminar una pizarra con generaciones previas · A2 rol `VIEWER` |
| **CU-08 Invitar participante** | Ser `OWNER` | Generar código único con rol y caducidad → compartir | A1 código caducado · A2 revocar invitación |
| **CU-09 Aceptar invitación** | Código vigente | Abrir el código → si no hay sesión, `«extend»` CU-02 → alta como miembro con el rol del código | A1 ya es miembro · A2 código caducado o revocado |
| **CU-10 Administrar participantes y roles** | Ser `OWNER` | Listar miembros · cambiar rol · expulsar | A1 el propietario intenta degradarse a sí mismo · A2 expulsar a un participante conectado (su sesión colaborativa se cierra) |
| **CU-18 Consultar atribución y auditoría** | Ser miembro | Listar los lotes de la pizarra con origen, actor y momento | A1 pizarra sin operaciones |
| **CU-19 Instruir al asistente por texto** | Pizarra abierta, rol con escritura | Instrucción en lenguaje natural → pasarela de IA → **propuesta** de lote sobre vocabulario cerrado → `«include»` CU-22 | A1 instrucción ambigua: el asistente **pide aclaración** en vez de adivinar · A2 proveedor no disponible: encadenamiento de respaldo · A3 la propuesta no es aplicable al estado actual |
| **CU-20 Dictar por voz** | Micrófono disponible | Audio → transcripción → **continúa el flujo de CU-19** con origen `AI_VOICE` | A1 permiso de micrófono denegado · A2 transcripción vacía o ininteligible |
| **CU-21 Consultar al asistente** | Pizarra abierta | Pregunta sobre el modelo → respuesta **sin proponer mutación** | A1 pregunta fuera del dominio del modelo |
| **CU-22 Revisar propuesta** | Existe una propuesta | Mostrar los comandos propuestos en lenguaje comprensible → el usuario acepta, edita o descarta → si acepta, `«include»` CU-15 | A1 el usuario descarta · A2 el modelo cambió mientras revisaba: la propuesta se revalida |
| **CU-23 Reconstruir desde boceto** | Rol con escritura | Foto con la cámara o archivo → pasarela de visión → **candidato editable** [ADR-012] → `«include»` CU-26 | A1 imagen ilegible · A2 imagen que excede el límite · A3 no se reconoce ninguna clase |
| **CU-24 Importar XMI** | Rol con escritura | Archivo XMI 2.5.1 → análisis → candidato editable → `«include»` CU-26 | A1 XMI mal formado · A2 construcciones fuera de alcance: se informan y se omiten, no se falla en silencio · A3 archivo que excede el límite |
| **CU-25 Exportar XMI** | Pizarra con contenido | Proyección del modelo a XMI 2.5.1 de la OMG → descarga | A1 pizarra vacía |
| **CU-26 Revisar candidato** | Existe un candidato | Presentar el diagrama reconstruido junto al actual → el usuario corrige → aplica o descarta → si aplica, `«include»` CU-15 | A1 descarta · A2 aplica solo una parte |
| **CU-28 Descargar artefacto** | Generación en estado `READY` | Solicitud → regeneración desde snapshot + manifiesto → descarga del ZIP con suma SHA-256 | A1 generación `FAILED` · A2 generación `CREATING` en curso |
| **CU-29 Consultar historial** | Ser miembro | Listar generaciones de la pizarra con estado, autor, momento y huella; permitir descargar cualquiera | A1 sin generaciones previas |

## 1.5 Estructurar Modelos de Casos de Uso

Estructurar el modelo consiste en organizar los casos de uso en paquetes y
extraer el comportamiento común, de modo que el modelo sea comprensible y no
repita descripciones.

### 1.5.1 Paquetes del modelo de casos de uso

| Paquete | Casos de uso | Depende de | Justificación del agrupamiento |
|---|---|---|---|
| **M0a · Gestión de Acceso** | CU-01 a CU-05 | — | Identidad del usuario. Ningún otro paquete funciona sin él |
| **M0b · Gestión de Espacios de Trabajo** | CU-06 a CU-10 | M0a | Proyecto, pizarra, membresía y rol: el marco de autorización de todo lo demás |
| **M1 · Edición del Modelo** | CU-11 a CU-15 | M0b | El núcleo canónico. **CU-15 es el punto de convergencia de todo el sistema** |
| **M2 · Colaboración** | CU-16 a CU-18 | M0b, M1 | Replicación y presencia sobre el modelo del paquete M1 |
| **M3 · Asistencia por IA** | CU-19 a CU-22 | M1 | Adaptador de entrada: produce propuestas que M1 valida y aplica |
| **M4/M5 · Importación e Interoperabilidad** | CU-23 a CU-26 | M1 | Adaptadores de entrada y salida: boceto y XMI |
| **M6 · Generación del Backend** | CU-27 a CU-29 | M1 | Adaptador de salida: consume un snapshot inmutable de M1 |

La forma de estas dependencias no es casual y merece subrayarse: **M3, M4/M5 y M6
dependen de M1, y M1 no depende de ninguno de ellos**. Esa es la expresión, en el
modelo de casos de uso, del principio rector de la arquitectura: colaboración, IA,
imagen, XMI y generación son **adaptadores alrededor de un núcleo canónico**. La
dependencia apunta siempre hacia el centro, nunca hacia afuera.

### 1.5.2 Comportamiento común extraído

| Comportamiento | Extraído como | Reutilizado por |
|---|---|---|
| Validar y aplicar atómicamente | **CU-15** (`«include»`) | 7 casos de uso |
| Revisar antes de aplicar lo que produjo la IA | **CU-22** (`«include»`) | CU-19, CU-20 |
| Revisar antes de aplicar lo que se importó | **CU-26** (`«include»`) | CU-23, CU-24 |
| Comprobar consistencia del modelo | **CU-14** (`«include»`) | CU-15, CU-27 |
| Autenticar y autorizar en la frontera | Precondición común | Todos salvo CU-01, CU-02, CU-04 |

### 1.5.3 Generalización de casos de uso

*Importar modelo* es un caso de uso **abstracto** que generaliza a CU-23
(reconstruir desde boceto) y CU-24 (importar XMI). Ambos comparten flujo —obtener
una fuente externa, interpretarla, producir un **candidato editable**, revisarlo y
aplicarlo— y difieren solo en el analizador de la fuente. La generalización
documenta que un tercer origen de importación futuro heredaría el mismo flujo sin
tocar el núcleo.

> **📐 DIAGRAMA D-10 — Diagrama de paquetes del modelo de casos de uso**
> *Tipo EA: Package Diagram.*
> Los siete paquetes con sus dependencias `«use»` según la tabla 1.5.1. **La
> disposición importa:** colocar M1 en el centro, M0a y M0b debajo como base, y
> M2, M3, M4/M5 y M6 alrededor, con todas las flechas apuntando hacia M1. El
> diagrama debe *verse* como un núcleo con adaptadores. Añadir una nota con el
> principio rector: *«Todas las entradas modifican un único modelo canónico
> mediante lotes de comandos atómicos»*.

> **📐 DIAGRAMA D-11 — Diagrama de casos de uso incluidos y extendidos**
> *Tipo EA: Use Case Diagram.*
> Vista transversal que muestra **solo** las relaciones `«include»`, `«extend»` y
> de generalización de la sección 1.2.2, sin actores. Su propósito es hacer
> evidente la convergencia de los siete casos de uso de entrada sobre CU-15.
> Dibujar CU-15 grande y centrado.

---
# 2. Flujo de Trabajo: Análisis

El análisis refina y estructura los requisitos en el lenguaje del desarrollador,
pero **sin comprometerse todavía con una tecnología**. Su artefacto es el
**modelo de análisis**: clases de análisis —frontera, control y entidad— y
realizaciones de casos de uso que muestran cómo esas clases colaboran.

## 2.1 Análisis de Arquitectura

### 2.1.1 Principio rector

> Todas las entradas modifican un **único modelo UML canónico** mediante lotes de
> comandos atómicos. Colaboración, IA, imagen, XMI y generación son **adaptadores**
> alrededor de ese núcleo.

Si esa pieza está bien hecha, las siete funcionalidades se conectan al mismo
centro. Si está mal hecha, habrá siete implementaciones peleándose por ser la
verdad.

### 2.1.2 Estratificación en capas de análisis

| Capa | Responsabilidad | Conoce a |
|---|---|---|
| **Presentación** | Proyectar el modelo sobre el lienzo, capturar la intención del usuario, mostrar diagnósticos y presencia | Aplicación |
| **Aplicación** | Orquestar los casos de uso: componer lotes, coordinar validación y aplicación, congelar snapshots | Dominio, Puertos |
| **Dominio** | Modelo canónico, vocabulario de comandos, aplicador, validador, reglas de modelado y de transformación | **Nada** |
| **Puertos (adaptadores)** | Colaboración, pasarela de IA, analizador XMI, generador, persistencia | Dominio (solo a través de interfaces) |
| **Infraestructura** | Base de datos, transporte, sistema de archivos temporal, servicios externos | Puertos |

La regla que gobierna el diagrama es una sola: **las dependencias apuntan hacia
el dominio, nunca desde él** [RNF-15]. El dominio no sabe que existe una base de
datos, ni un proveedor de IA, ni un navegador. Esto es lo que permite que el
mismo validador se ejecute en el cliente y en el servidor [RA-05].

### 2.1.3 Flujo de una modificación (vista de análisis)

```
GUI · texto · voz · imagen · XMI
              ↓
     Propuesta de lote
              ↓
  Resolución estructural (desambiguación)
              ↓
        Validación            ← si hay un solo error, no se aplica nada
              ↓
    Aplicador de comandos
              ↓
  Documento colaborativo (transacción única)
              ↓
   ┌──────────┴──────────┐
   ↓                     ↓
Actualización        Snapshot inmutable
incremental                ↓
a los demás      Representación intermedia
                           ↓
                    Plantillas → ZIP
```

### 2.1.4 Nodos y procesos identificados en el análisis

| Nodo | Responsabilidad | Justificación [ADR] |
|---|---|---|
| **Cliente** (navegador) | Réplica del documento, editor, validación en vivo | El editor es proyección, nunca fuente de verdad |
| **Proceso HTTP** | Casos de uso de petición-respuesta: cuentas, proyectos, pizarras, IA, importación, generación | ADR-001: monolito modular en dos procesos |
| **Proceso de Colaboración** | Sesiones en tiempo real, autorización de sala, persistencia del documento | ADR-001, RA-15 |
| **Base de datos** | Persistencia durable y metadatos | — |
| **Proxy inverso** | Un solo origen en el perfil de demostración | ADR-010 |

Separar el proceso HTTP del de colaboración no es un capricho: sus perfiles de
carga y de ciclo de vida son distintos —uno atiende peticiones cortas, el otro
mantiene conexiones largas con estado en memoria—, y mezclarlos habría acoplado
el reinicio de uno a la caída de las sesiones del otro.

### 2.1.5 Atributos de calidad y tácticas de análisis

| Atributo | Requisito | Táctica arquitectónica |
|---|---|---|
| **Rendimiento** | RNF-01: propagación < 500 ms | Actualizaciones incrementales, no envío del documento completo |
| **Escalabilidad de sesión** | RNF-02: ≥ 5 participantes por pizarra | CRDT sin coordinación central por operación |
| **Fiabilidad** | RA-03: todo o nada | Validación previa + transacción única del documento |
| **Reproducibilidad** | RA-07, RA-08 | Snapshot inmutable + plantillas + huella SHA-256 |
| **Seguridad** | RA-15, RNF-08 | Autorización en la frontera de la sala; derivación lenta de contraseñas |
| **Modificabilidad** | ADR-015 | Puertos y adaptadores: cambiar proveedor de IA es configuración, no código |
| **Consistencia cliente-servidor** | RA-05 | Un solo módulo de dominio compartido entre navegador y servidor |

> **📐 DIAGRAMA D-12 — Arquitectura en capas (vista de análisis)**
> *Tipo EA: Package Diagram, o Component Diagram con paquetes estereotipados
> `«layer»`.*
> Las cinco capas de 2.1.2 apiladas, con flechas de dependencia **todas
> apuntando hacia la capa de Dominio**. Marcar el Dominio con una nota: *«No
> conoce infraestructura. Se ejecuta idéntico en navegador y servidor [RA-05,
> RNF-15]»*. Dibujar los adaptadores (Colaboración, IA, XMI, Generación,
> Persistencia) como cajas de la capa de Puertos, cada una con su interfaz
> (círculo `«interface»`) definida **en el Dominio**.

> **📐 DIAGRAMA D-13 — Diagrama de actividad del flujo de una modificación**
> *Tipo EA: Activity Diagram.*
> Traducir el esquema de 2.1.3 a notación UML formal. Elementos obligatorios:
> un nodo inicial con **cinco flujos de entrada** (GUI, texto, voz, imagen, XMI)
> convergiendo en un nodo de unión; la actividad *Validar*; un **nodo de decisión**
> rotulado *«¿hay algún error?»* con la rama *sí* llevando a *Rechazar lote
> completo* y nodo final, y la rama *no* continuando; la actividad *Aplicar
> comandos* dentro de una **región de actividad interrumpible** o rotulada
> `«transacción»`; y un **nodo de bifurcación** (*fork*) que separa la
> actualización incremental del snapshot inmutable. Usar **calles** (*partitions*)
> para Cliente, Proceso HTTP y Proceso de Colaboración.

## 2.2 Análisis de Casos de Uso

Cada realización de caso de uso identifica las clases de análisis que colaboran
para cumplirlo, clasificadas según el estereotipo del Proceso Unificado:

| Estereotipo | Papel | Regla |
|---|---|---|
| **`«boundary»`** Frontera | Media entre el sistema y un actor | Una por cada par actor–caso de uso |
| **`«control»`** Control | Coordina la secuencia del caso de uso | Normalmente una por caso de uso significativo |
| **`«entity»`** Entidad | Información persistente o de larga vida del dominio | Compartida entre casos de uso |

### 2.2.1 Realización de CU-15 · Aplicar lote de comandos

| Clase de análisis | Estereotipo | Responsabilidad |
|---|---|---|
| `GestorDeLotes` | `«control»` | Orquesta el ciclo completo: resolver, validar, aplicar, propagar, auditar |
| `ResolutorEstructural` | `«control»` | Traduce referencias ambiguas a identificadores UUID; desambigua |
| `ValidadorDeModelo` | `«control»` | Ejecuta las reglas de modelado; produce diagnósticos |
| `AplicadorDeComandos` | `«control»` | Aplica cada comando del vocabulario sobre el modelo |
| `LoteDeComandos` | `«entity»` | Identificador, origen, actor, lista ordenada de comandos |
| `ModeloCanonico` | `«entity»` | Clases, atributos y relaciones del diagrama |
| `Diagnostico` | `«entity»` | Severidad, mensaje, elemento afectado |
| `RegistroDeAuditoria` | `«entity»` | Lote registrado con su atribución |
| `DocumentoColaborativo` | `«boundary»` | Frontera hacia el mecanismo de replicación |

### 2.2.2 Realización de CU-17 · Sincronizar cambios concurrentes

| Clase de análisis | Estereotipo | Responsabilidad |
|---|---|---|
| `LienzoDeEdicion` | `«boundary»` | Proyecta el documento; captura la intención del Editor |
| `SesionColaborativa` | `«control»` | Mantiene la conexión, encola y reintenta, gestiona reconexión |
| `SalaDePizarra` | `«control»` | Del lado servidor: admite participantes, difunde actualizaciones |
| `AutorizadorDeSala` | `«control»` | Verifica credencial y membresía **antes** de admitir [RA-15] |
| `RegistroDePresencia` | `«entity»` | Quién está conectado y qué elemento edita |
| `DocumentoColaborativo` | `«entity»` | Estado replicado convergente |
| `AlmacenDeDocumentos` | `«boundary»` | Persiste el estado binario nativo [RA-11] |

### 2.2.3 Realización de CU-27 · Generar backend Spring Boot

| Clase de análisis | Estereotipo | Responsabilidad |
|---|---|---|
| `PanelDeGeneracion` | `«boundary»` | Recoge nombre, artefacto y paquete base; muestra progreso e historial |
| `GestorDeGeneracion` | `«control»` | Orquesta: validar, congelar, traducir, emitir, empaquetar, registrar |
| `CongeladorDeSnapshot` | `«control»` | Proyecta el documento al JSON canónico y lo versiona [RA-08] |
| `TraductorAIR` | `«control»` | Aplica las reglas de transformación al modelo canónico |
| `EmisorPorPlantillas` | `«control»` | Rellena las plantillas de forma determinista [RA-07] |
| `Empaquetador` | `«control»` | Comprime y calcula la suma SHA-256 |
| `Snapshot` | `«entity»` | Modelo congelado con su versión |
| `Manifiesto` | `«entity»` | Nombre, artefacto, paquete, versión de esquema, huella de plantillas |
| `RepresentacionIntermedia` | `«entity»` | Entidades, campos, relaciones y tablas ya resueltos a términos de Java y SQL |
| `Generacion` | `«entity»` | Estado (`CREATING`/`READY`/`FAILED`), autor, momento, huellas |

### 2.2.4 Realización de CU-19 · Instruir al asistente por texto

| Clase de análisis | Estereotipo | Responsabilidad |
|---|---|---|
| `PanelDelAsistente` | `«boundary»` | Recibe la instrucción; presenta la propuesta para revisión |
| `GestorDelAsistente` | `«control»` | Orquesta la interpretación y la construcción de la propuesta |
| `PasarelaDeIA` | `«boundary»` | Puerto hacia el proveedor externo, con encadenamiento de respaldo |
| `ConstructorDePropuesta` | `«control»` | Convierte la interpretación en comandos del **vocabulario cerrado** [RA-06] |
| `PropuestaDeLote` | `«entity»` | Comandos propuestos, aún no aplicados |
| `ModeloCanonico` | `«entity»` | Contexto que se entrega al proveedor y sobre el que se valida la propuesta |

> **📐 DIAGRAMA D-14 — Realización de CU-15 · Diagrama de clases de análisis (VOPC)**
> *Tipo EA: Class Diagram.*
> Las nueve clases de 2.2.1 con sus estereotipos `«boundary»`, `«control»` y
> `«entity»` (EA los dibuja con la notación circular de Jacobson si se activa
> *Use Case* en las propiedades del elemento). Mostrar asociaciones simples entre
> ellas, sin tipos ni operaciones: esto es análisis, no diseño.

> **📐 DIAGRAMA D-15 — Realización de CU-15 · Diagrama de comunicación**
> *Tipo EA: Communication Diagram.*
> Los mismos objetos de D-14, con los mensajes **numerados** siguiendo los once
> pasos del flujo básico de CU-15. Es el diagrama que hace visible que la
> validación ocurre **antes** que la aplicación.

> **📐 DIAGRAMA D-16 — Realización de CU-17 · Diagrama de comunicación**
> *Tipo EA: Communication Diagram.*
> Clases de 2.2.2. **Dibujar dos instancias de `SesionColaborativa`** —`:Sesión
> (Ana)` y `:Sesión (Beto)`— para que la concurrencia se vea. Numerar los mensajes
> del flujo básico de CU-17.

> **📐 DIAGRAMA D-17 — Realización de CU-27 · Diagrama de clases de análisis (VOPC)**
> *Tipo EA: Class Diagram.* Las diez clases de 2.2.3. Anotar `Snapshot` y
> `Manifiesto` con `{frozen}` para señalar su inmutabilidad.

> **📐 DIAGRAMA D-18 — Realización de CU-19 · Diagrama de clases de análisis (VOPC)**
> *Tipo EA: Class Diagram.* Las seis clases de 2.2.4. Marcar `PasarelaDeIA` como
> `«boundary»` hacia el actor externo Proveedor de IA, y anclar una nota:
> *«Devuelve propuestas sobre vocabulario cerrado. Nunca escribe el modelo ni
> genera código [RA-06, RA-07]»*.

## 2.3 Análisis de Clases

Consolidando las realizaciones anteriores, el modelo de análisis identifica las
clases de entidad que forman el corazón conceptual del sistema. Estas son
**clases de análisis**, no de diseño: no llevan tipos de implementación ni
decisiones de persistencia.

### 2.3.1 Clases de entidad del dominio del modelado

| Clase | Atributos conceptuales | Responsabilidad |
|---|---|---|
| `ModeloCanonico` | versión de esquema | Contiene las clases y relaciones; es la fuente de verdad |
| `ClaseUML` | identidad, nombre, posición | Elemento del diagrama |
| `Atributo` | nombre, tipo conceptual, es clave primaria, es nulable, es único | Propiedad de una clase |
| `Relacion` | identidad, tipo, extremo origen, extremo destino | Vínculo entre dos clases |
| `ExtremoDeRelacion` | multiplicidad, nombre de rol | Un lado de la relación |
| `Comando` | tipo del vocabulario, argumentos | Unidad mínima de modificación |
| `LoteDeComandos` | identidad, origen, actor, momento | Unidad **transaccional** y de identidad |
| `Diagnostico` | severidad, mensaje, elemento afectado | Resultado de la validación |
| `Layout` | posición, viewport | **Sin valor semántico**: no entra en la generación |

### 2.3.2 Clases de entidad del dominio de la plataforma

| Clase | Responsabilidad |
|---|---|
| `Usuario` | Identidad de la persona; credencial derivada; versión de sesión |
| `Proyecto` | Agrupa pizarras; declara su versión de esquema; tiene propietario |
| `Membresia` | Asocia usuario y proyecto **con un rol**; es la entidad intermedia de la relación muchos-a-muchos [ADR-005] |
| `Invitacion` | Código, rol ofrecido y caducidad |
| `Pizarra` | Contiene un documento y su historia de snapshots y generaciones |
| `DocumentoColaborativo` | Estado replicado convergente, persistido en binario nativo |
| `Snapshot` | Proyección canónica congelada, versionada |
| `Generacion` | Manifiesto, estado y huellas de una emisión |
| `RegistroDeAuditoria` | Lote aplicado, con origen y atribución |

### 2.3.3 Las seis fuentes de verdad

Una de las decisiones de análisis más consecuentes fue delimitar **qué
representación responde de qué**. Confundirlas es la causa habitual de que una
herramienta CASE se vuelva incoherente:

| Representación | Responsabilidad |
|---|---|
| **Esquema canónico** | Contrato semántico: qué significa el estado |
| **Documento colaborativo** | Estado vivo replicado |
| **Layout** | Posición y viewport, sin valor semántico |
| **Base de datos** | Persistencia durable y metadatos |
| **Snapshot de generación** | Entrada inmutable al generador |
| **Representación intermedia** | Traducción temporal para emitir código |

El editor visual siempre es una **proyección** del documento, nunca la fuente de
verdad. Y el JSON canónico es proyección derivada del documento: **nunca lo
reconstruye** [RA-11].

> **📐 DIAGRAMA D-19 — Diagrama de clases de análisis del dominio de modelado**
> *Tipo EA: Class Diagram.*
> Las nueve clases de 2.3.1 con sus asociaciones, multiplicidades y agregaciones:
> `ModeloCanonico` ◆— `ClaseUML` (composición, `1` a `0..*`); `ClaseUML` ◆—
> `Atributo`; `Relacion` —— `ExtremoDeRelacion` (`1` a `2`); `LoteDeComandos` ◆—
> `Comando`. Sin tipos de implementación. **Este diagrama es el modelo de dominio
> de la propia herramienta: una herramienta de modelar clases, modelada con
> clases.** Vale la pena señalarlo en la defensa.

> **📐 DIAGRAMA D-20 — Diagrama de clases de análisis del dominio de plataforma**
> *Tipo EA: Class Diagram.* Las nueve clases de 2.3.2. Destacar `Membresia` como
> **clase asociativa** entre `Usuario` y `Proyecto`, portando el atributo `rol`:
> es el mismo patrón que el generador aplica automáticamente a toda relación
> muchos-a-muchos [ADR-005], aquí aplicado al propio sistema.

## 2.4 Análisis de Paquetes

Los paquetes de análisis se derivan de los paquetes de casos de uso de la sección
1.5.1, más los paquetes de servicio que recogen lo que varios comparten.

### 2.4.1 Paquetes de análisis

| Paquete | Contenido | Depende de |
|---|---|---|
| `dominio.modelo` | Modelo canónico, clases, atributos, relaciones, layout | — |
| `dominio.comandos` | Vocabulario, comandos, lotes, aplicador | `dominio.modelo` |
| `dominio.validacion` | Reglas de modelado, herencia, diagnósticos, severidad | `dominio.modelo` |
| `dominio.transformacion` | Reglas de tipos, multiplicidades, herencia, palabras reservadas | `dominio.modelo` |
| `aplicacion.acceso` | Registro, sesión, perfil, recuperación | `dominio` |
| `aplicacion.espacios` | Proyectos, pizarras, membresías, invitaciones | `dominio` |
| `aplicacion.edicion` | Orquestación de lotes de origen `GUI` | `dominio.comandos`, `dominio.validacion` |
| `aplicacion.colaboracion` | Sesión, sala, presencia, autorización | `dominio.comandos` |
| `aplicacion.asistente` | Interpretación, propuesta, aclaración | `dominio.comandos` |
| `aplicacion.importacion` | Boceto, XMI, candidato editable | `dominio.comandos` |
| `aplicacion.generacion` | Snapshot, manifiesto, IR, emisión, empaquetado | `dominio.transformacion` |
| `puertos` | Interfaces: persistencia, IA, transporte, correo | `dominio` |
| `presentacion` | Lienzo, inspector, paneles, validación visual | `aplicacion` |

### 2.4.2 Paquetes de servicio compartidos

| Paquete | Por qué es compartido |
|---|---|
| `dominio.modelo` | Lo usan **todos** los paquetes de aplicación. Es el vocabulario común |
| `dominio.validacion` | Se ejecuta en presentación (navegador) **y** en aplicación (servidor) [RA-05] |
| `puertos` | Permite que ningún paquete de aplicación conozca un proveedor concreto [ADR-015] |

### 2.4.3 Verificación de la regla de dependencia

Ningún paquete `dominio.*` depende de `aplicacion.*`, de `puertos` ni de
`presentacion`. La dependencia es unidireccional hacia el centro. Esta regla no
es una aspiración documental: está verificada de forma automatizada por la
configuración de compilación y por la comprobación de tipos del monorepositorio
[RNF-15], de modo que una violación **rompe la compilación**, no queda como deuda.

> **📐 DIAGRAMA D-21 — Diagrama de paquetes de análisis**
> *Tipo EA: Package Diagram.*
> Los trece paquetes de 2.4.1 con sus dependencias `«use»`. Agrupar visualmente
> en tres bandas horizontales: `presentacion` arriba, `aplicacion.*` en medio,
> `dominio.*` abajo, y `puertos` a un lado atravesando. **Toda flecha debe
> apuntar hacia abajo o hacia el centro; ninguna hacia arriba.** Si al dibujarlo
> aparece una flecha hacia arriba, es un hallazgo real de arquitectura, no un
> error de dibujo.

---

# 3. Flujo de Trabajo: Diseño

El diseño toma el modelo de análisis y lo lleva al terreno de la tecnología
concreta: procesos, componentes, clases con tipos y firmas, y el esquema físico
de la base de datos.

## 3.1 Arquitectura de Diseño

### 3.1.1 Estilo arquitectónico adoptado

**Monolito modular desplegado en dos procesos** [ADR-001], con **puertos y
adaptadores** en el interior [ADR-015] y **desarrollo dirigido por modelos** en
la cadena de generación [ADR-007].

Se evaluaron y **descartaron explícitamente**: microservicios (ADR-010),
*event sourcing* y CQRS completo (ADR-006), e infraestructura como código
(ADR-010). En los tres casos la razón fue la misma: el costo operativo excedía el
beneficio para el tamaño real del sistema y del equipo. Descartar con motivo
registrado es una decisión de arquitectura; no evaluarlo habría sido una omisión.

### 3.1.2 Componentes de diseño

| Componente | Tecnología | Responsabilidad |
|---|---|---|
| `frontend` | React 19 · TypeScript · Vite | Editor, paneles, réplica del documento, validación en vivo |
| `backend/api` | Node.js · Fastify | Rutas HTTP de los siete módulos; autenticación; orquestación de generación |
| `backend/collab` | Hocuspocus sobre Yjs | Salas por pizarra, autorización de conexión, persistencia del documento |
| `shared/contracts` | Zod | Esquemas compartidos: modelo, comandos, validación, severidad, vocabulario |
| `shared/domain-core` | TypeScript puro | Aplicador, validador, herencia, nombres, clave primaria, palabras reservadas |
| `shared/generation-ir` | TypeScript puro | Representación intermedia y reglas de transformación |
| `shared/generator-backend` | Handlebars | Plantillas del proyecto Spring Boot |
| `shared/xmi` | TypeScript puro | Lectura y escritura de XMI 2.5.1 |
| `shared/ai` | TypeScript puro | Puerto de IA y encadenamiento de proveedores de respaldo |
| `shared/yjs-adapter` | Yjs | Proyección documento ⇄ modelo canónico |
| `infra` | Docker Compose · Caddy | Orquestación local y proxy de un solo origen |

Obsérvese que **`shared/domain-core` y `shared/contracts` no dependen de ninguna
tecnología de entrada o salida**. Esa es la condición que hace posible ejecutar
el mismo validador en el navegador y en el servidor [RA-05], y es también lo que
permite probar el dominio sin base de datos ni Docker.

### 3.1.3 Vista de despliegue

```
                    Navegador
              React + editor + documento
                        │
              ┌─────────┴─────────┐
            HTTPS               WSS
              ↓                   ↓
         ┌──────────┐      ┌─────────────┐
         │   api    │      │   collab    │
         │  :3001   │      │   :3002     │
         └────┬─────┘      └──────┬──────┘
              └──────────┬────────┘
                         ↓
                    PostgreSQL
```

Con el perfil `demo`, Caddy queda delante y expone un único origen en el puerto
80: `/api/*` al proceso HTTP, `/collab/*` al de colaboración, el resto a la
interfaz.

### 3.1.4 Mecanismos de diseño

| Mecanismo de análisis | Mecanismo de diseño | Realización |
|---|---|---|
| Persistencia | ORM sobre base relacional | Prisma sobre PostgreSQL |
| Replicación | CRDT con transporte por socket | Yjs + Hocuspocus |
| Validación de contratos | Esquemas declarativos compartidos | Zod, un solo esquema para cliente y servidor |
| Autorización | Credencial de acceso + verificación de rol por proyecto | Complemento de autenticación + resolución de membresía |
| Acceso a servicios externos | Puerto con adaptadores intercambiables y respaldo encadenado | Pasarela de IA [ADR-015, ADR-019] |
| Emisión de código | Plantillas sobre representación intermedia | Handlebars sobre IR [ADR-007] |
| Transaccionalidad del lote | Transacción del documento replicado | Una sola actualización emitida [RA-03] |

> **📐 DIAGRAMA D-22 — Diagrama de componentes**
> *Tipo EA: Component Diagram.*
> Los once componentes de 3.1.2, con sus **interfaces provistas y requeridas**
> (notación de bola y zócalo). Puntos clave que el diagrama debe dejar ver:
> `frontend`, `backend/api` y `backend/collab` **los tres** requieren
> `shared/domain-core` —esa triple flecha es RA-05 hecha visible—; y
> `backend/api` requiere el puerto de IA, que `shared/ai` provee.

> **📐 DIAGRAMA D-23 — Diagrama de despliegue**
> *Tipo EA: Deployment Diagram.*
> Nodos: `«device» Navegador del usuario`, y `«device» Servidor` conteniendo los
> nodos de ejecución `«container» caddy`, `«container» api`, `«container» collab`
> y `«container» postgres`. Artefactos desplegados en cada uno. Rotular las rutas
> de comunicación con su protocolo y puerto: HTTPS `:80→:3001`, WSS `:80→:3002`,
> TCP `:5432`. Añadir una nota con RNF-12: *«el entorno íntegro se levanta con un
> solo comando»*.

## 3.2 Diseño de Casos de Uso

Cada caso de uso significativo se diseña como una **secuencia de mensajes entre
objetos concretos**, ya con nombres de componentes y métodos reales.

### 3.2.1 CU-15 · Aplicar lote de comandos — secuencia de diseño

Participantes: `BoardCanvas` (React) → `useBatch` (compositor de lotes) →
`validate` (`shared/domain-core`) → `apply` (`shared/domain-core`) →
`Y.Doc.transact` (`shared/yjs-adapter`) → `HocuspocusProvider` →
`backend/collab` → `board-store` → PostgreSQL, y en paralelo
`backend/api · POST /boards/:boardId/audit`.

Puntos que la secuencia debe mostrar sin ambigüedad:
1. `validate` se invoca **antes** que `apply`, y su resultado gobierna una
   condición de guarda.
2. `apply` ocurre **dentro** de `Y.Doc.transact`, de modo que se emite una sola
   actualización.
3. La auditoría es una rama asíncrona: **no bloquea** la propagación.

### 3.2.2 CU-17 · Sincronizar cambios concurrentes — secuencia de diseño

Dos líneas de vida de cliente —`Cliente A` y `Cliente B`— contra un único
`backend/collab`, mostrando el cruce de actualizaciones y la convergencia. Debe
incluir el fragmento de **reconexión** con la cola reintentable y la
deduplicación por `(boardId, batchId)`.

### 3.2.3 CU-27 · Generar backend Spring Boot — secuencia de diseño

`GenerationPanel` → `POST /boards/:boardId/generations` → `GenerationService`
→ `boardStore.freezeSnapshot` → `prisma.generation.create({status: CREATING})`
→ `toIR` (`shared/generation-ir`) → `emit` (`shared/generator-backend`) →
`zip + sha256` → `prisma.generation.update({status: READY})` →
`GET /generations/:id/download`.

### 3.2.4 CU-19 · Instruir al asistente — secuencia de diseño

`AssistantPanel` → `POST /boards/:boardId/assistant/instruction` →
`AssistantService` → `AiGateway.complete` → *(fallo del proveedor primario)* →
`AiGateway` encadena al proveedor de respaldo → `ProposalBuilder` →
`checkPreconditions` (`proposal-preconditions.ts`) → propuesta devuelta al panel
→ el usuario confirma → CU-15.

### 3.2.5 Estados de una generación

La entidad `Generation` tiene un ciclo de vida explícito que conviene diseñar
como máquina de estados, porque de él dependen qué acciones ofrece la interfaz:

| Estado | Significado | Transiciones salientes |
|---|---|---|
| `CREATING` | La fila existe; el artefacto todavía no se ha emitido | → `READY` (emisión correcta) · → `FAILED` (error) |
| `READY` | Los objetivos se emitieron y su huella quedó registrada | *(terminal)* — admite descarga (CU-28) |
| `FAILED` | La emisión falló. Se conserva para poder explicar por qué | *(terminal)* — admite reintento, que crea una generación **nueva** |

### 3.2.6 Estados de una sesión colaborativa

| Estado | Transiciones |
|---|---|
| `Desconectada` | → `Autorizando` (abrir pizarra) |
| `Autorizando` | → `Sincronizando` (credencial y membresía correctas) · → `Rechazada` |
| `Sincronizando` | → `Conectada` (réplica al día) |
| `Conectada` | → `Reconectando` (pérdida de red) · → `Desconectada` (cerrar) |
| `Reconectando` | → `Autorizando` (reintento; al volver, vacía la cola con deduplicación) |
| `Rechazada` | *(terminal)* — el cliente retorna al inicio de sesión |

> **📐 DIAGRAMA D-24 — CU-15 · Diagrama de secuencia de diseño**
> *Tipo EA: Sequence Diagram.* Participantes de 3.2.1. **Obligatorio:** un
> fragmento combinado `alt` sobre el resultado de `validate` (`[sin errores]` /
> `[hay errores]`), y un fragmento `critical` o una nota rotulada `«transacción»`
> encerrando la llamada a `apply`. Marcar la rama de auditoría como mensaje
> asíncrono (punta de flecha abierta).

> **📐 DIAGRAMA D-25 — CU-17 · Diagrama de secuencia de diseño (concurrencia)**
> *Tipo EA: Sequence Diagram.* Según 3.2.2. **Obligatorio:** dos líneas de vida de
> cliente, y un fragmento `par` para las dos ediciones simultáneas, más un
> fragmento `opt` para la reconexión con cola y deduplicación.

> **📐 DIAGRAMA D-26 — CU-27 · Diagrama de secuencia de diseño**
> *Tipo EA: Sequence Diagram.* Según 3.2.3. Marcar con una nota el punto exacto
> donde el snapshot se congela: a partir de ahí, el modelo vivo puede cambiar sin
> afectar a esta generación [RA-08].

> **📐 DIAGRAMA D-27 — CU-19 · Diagrama de secuencia de diseño (con respaldo de IA)**
> *Tipo EA: Sequence Diagram.* Según 3.2.4. **Obligatorio:** un fragmento `alt`
> que muestre el encadenamiento al proveedor de respaldo cuando el primario falla
> [ADR-019], y el hecho de que la propuesta **vuelve al usuario** antes de tocar
> el modelo.

> **📐 DIAGRAMA D-28 — Diagrama de estados de `Generation`**
> *Tipo EA: StateMachine Diagram.* Los tres estados de 3.2.5 con sus transiciones
> rotuladas, estado inicial y estados finales.

> **📐 DIAGRAMA D-29 — Diagrama de estados de la sesión colaborativa**
> *Tipo EA: StateMachine Diagram.* Los seis estados de 3.2.6. Rotular la
> transición `Reconectando → Autorizando` con el efecto
> `/ vaciar cola con deduplicación por (boardId, batchId)`.

## 3.3 Diseño de Datos

### 3.3.1 Modelo físico de la plataforma

El esquema real está declarado en
[`schema.prisma`](../../backend/prisma/schema.prisma). Comprende **once tablas**:

| Tabla | Clave primaria | Notas de diseño |
|---|---|---|
| `users` | `id` UUID | `passwordHash` por derivación lenta [RNF-08]; `sessionVersion` invalida sesiones; el avatar se guarda como `Bytes` en la propia base |
| `password_resets` | `id` UUID | Guarda el **hash** del testigo, nunca el testigo; de un solo uso (`usedAt`) y con caducidad |
| `refresh_tokens` | `id` UUID | Mismo criterio: hash único, caducidad, revocación |
| `projects` | `id` UUID | `schemaVersion` declarada por proyecto [RA-09] |
| `project_members` | **`(projectId, userId)`** | **Entidad intermedia** de la relación muchos-a-muchos, portando `role` [ADR-005] |
| `project_invites` | `id` UUID | `code` único, `role` ofrecido, caducidad |
| `boards` | `id` UUID | Pertenece a un proyecto; `type` por omisión `CLASS_DIAGRAM` |
| `board_documents` | `boardId` UUID | **`state Bytes`**: representación binaria nativa del documento [RA-11] |
| `board_snapshots` | **`(boardId, version)`** | `canonicalJson`: proyección derivada, versionada |
| `generations` | `id` UUID | Manifiesto congelado + estado + huellas SHA-256 |
| `audit_operations` | `id` UUID | **`@@unique([boardId, batchId])`**: el lote es la unidad de identidad; el reintento no duplica |

### 3.3.2 Decisiones de diseño de datos que merecen defensa

| Decisión | Alternativa descartada | Razón |
|---|---|---|
| El documento se persiste **en binario nativo** | Reconstruirlo desde el JSON canónico | El JSON es proyección **derivada**; reconstruir desde él perdería la historia de convergencia del CRDT y rompería la replicación [RA-11] |
| El artefacto generado **no se almacena** | Guardar cada ZIP | Se regenera desde snapshot + manifiesto, que sí están congelados. Almacenar bytes derivados es costo sin información [ADR-018] |
| El manifiesto congela **también** el nombre y el paquete | Releerlos de la pizarra al descargar | Renombrar la pizarra cambiaba el artefacto de una generación pasada. Fue un defecto real, corregido por diseño |
| `@@unique([boardId, batchId])` | Deduplicar en memoria | Un reintento tras un corte de red llegaba dos veces. La restricción lo resuelve en el único lugar donde es infalsificable: la base |
| Avatar como `Bytes` en la base | Almacenamiento de objetos o disco | La plataforma no tiene ninguno de los dos, y una imagen de 256×256 ocupa decenas de kilobytes. La complejidad no se justificaba |
| `sessionVersion` en `users` | Lista de revocación | Cambiar la contraseña invalida todas las sesiones incrementando un entero |

### 3.3.3 Reglas de transformación del modelo UML al modelo relacional

Estas reglas son el corazón del generador y **también** son diseño de datos: no
del esquema de la plataforma, sino del esquema que la plataforma **produce**.

| Regla | Modelo UML | Modelo relacional / Java |
|---|---|---|
| RTM-01 | Ocho tipos conceptuales | `String`→`VARCHAR`/`String`, `Integer`→`INTEGER`/`Integer`, `Long`→`BIGINT`/`Long`, `Decimal`→`NUMERIC`/`BigDecimal`, `Boolean`→`BOOLEAN`/`Boolean`, `Date`→`DATE`/`LocalDate`, `DateTime`→`TIMESTAMP`/`LocalDateTime`, `UUID`→`UUID`/`UUID` |
| RTM | Atributo con clave primaria | `@Id` + columna de clave primaria |
| RTM | Asociación `1` — `0..*` | Clave foránea en el lado **muchos** |
| RTM | Asociación `0..1` — `0..*` | Clave foránea nulable en el lado muchos |
| RTM | Asociación `0..*` — `0..*` | **Entidad intermedia** con clave foránea a ambos lados [ADR-005, RM-01] |
| RTM | Composición | Clave foránea no nulable; el todo gobierna el ciclo de vida |
| RTM | Agregación | Clave foránea nulable; ciclos de vida independientes |
| RTM | **Generalización** | `InheritanceType.JOINED`: **una tabla por clase**, unidas por la clave primaria heredada [ADR-020] |
| RTM | Nombre reservado en SQL o Java | Escape automático y determinista |
| RTM | Nombre de clase | Tabla en su forma convenida; columna según el atributo |

### 3.3.4 Estructura del proyecto generado

Por cada clase del diagrama, el generador emite: entidad JPA anotada, repositorio
Spring Data, servicio, controlador REST con el CRUD completo y DTO plano. Al
conjunto añade: configuración Maven, `application.yml`, esquema PostgreSQL creado
al arrancar, documentación OpenAPI con Swagger UI, colección de Postman y
archivos de contenedor.

> **📐 DIAGRAMA D-30 — Modelo entidad-relación de la plataforma**
> *Tipo EA: **Data Model** (Extended > Data Modeling), no Class Diagram.*
> Las once tablas de 3.3.1 con sus columnas, tipos, claves primarias y foráneas.
> Destacar las dos claves primarias compuestas —`project_members` y
> `board_snapshots`— y la restricción única `(boardId, batchId)` de
> `audit_operations`. Generar desde EA el DDL si se quiere anexar.

> **📐 DIAGRAMA D-31 — Diagrama de clases de diseño del núcleo de dominio**
> *Tipo EA: Class Diagram.*
> Refinamiento de D-19 **ya con tipos y firmas**: `apply(model, batch): Result`,
> `validate(model): Diagnostic[]`, el enumerado `CommandType` con sus **once**
> literales, el enumerado `ConceptualType` con sus **ocho**, `RelationshipKind`
> con sus **cuatro** y `Multiplicity` con sus **cuatro**. Estos cuatro enumerados
> son el «vocabulario cerrado» que tanto se cita: conviene que aparezcan
> enumerados de forma exhaustiva, porque su carácter finito **es** la decisión de
> diseño.

> **📐 DIAGRAMA D-32 — Diagrama de clases de diseño de la cadena de generación**
> *Tipo EA: Class Diagram.*
> `Snapshot` → `IRBuilder` → `IntermediateRepresentation` (con `IREntity`,
> `IRField`, `IRRelation`, `IRTable`) → `TemplateEmitter` → `Artifact`. Marcar
> `Snapshot` e `IntermediateRepresentation` como `{immutable}`. Anclar una nota
> con RA-07: *«determinista: mismo snapshot + mismas plantillas = mismos bytes»*.

> **📐 DIAGRAMA D-33 — Diagrama de clases del proyecto generado (patrón por entidad)**
> *Tipo EA: Class Diagram.*
> **No** el diagrama del usuario, sino el **patrón** que el generador emite para
> *cada* clase: `«Entity» Xxx` → `«Repository» XxxRepository` → `«Service»
> XxxService` → `«RestController» XxxController` → `«DTO» XxxDto`. Dibujarlo una
> sola vez con una `Clase` genérica y una nota: *«este patrón se emite una vez por
> cada clase del diagrama»*. Añadir un segundo fragmento que muestre la herencia
> `JOINED` con dos clases concretas.

---
# 4 Flujo de Trabajo: Implementación

La implementación materializa el modelo de diseño en componentes ejecutables:
código fuente, archivos de compilación, imágenes de contenedor. Su artefacto es
el **modelo de implementación**, que organiza el código en subsistemas y describe
cómo se compilan y se despliegan.

## 4.1 Implementación de la arquitectura del Sistema

### 4.1.1 Organización del monorepositorio

El sistema se implementa como un **monorepositorio con espacios de trabajo**, de
modo que el código compartido entre navegador y servidor sea literalmente el
mismo módulo y no dos copias que puedan divergir:

```
Examen1SW1/
├── backend/
│   ├── api/          → proceso HTTP  (:3001)
│   ├── collab/       → proceso WebSocket (:3002)
│   └── prisma/       → esquema y migraciones
├── frontend/         → interfaz React (:5173 en desarrollo)
├── shared/           → siete paquetes de dominio y adaptadores
│   ├── contracts/         esquemas y vocabulario
│   ├── domain-core/       aplicador, validador, reglas
│   ├── generation-ir/     representación intermedia
│   ├── generator-backend/ plantillas Spring Boot
│   ├── xmi/               XMI 2.5.1
│   ├── ai/                puerto de IA y respaldo
│   └── yjs-adapter/       proyección documento ⇄ modelo
├── fixtures/         → banco de modelos de prueba
├── e2e/              → pruebas de extremo a extremo
├── infra/            → Compose, Dockerfiles, proxy
├── templates/        → plantillas del artefacto generado
├── scripts/          → siembra de demostración, generación de ejemplo
├── config/           → configuración de pruebas de integración
└── docs/             → ADR, requisitos, arquitectura, este documento
```

Los espacios de trabajo declarados son `shared/*`, `fixtures`, `backend/api`,
`backend/collab` y `frontend`.

### 4.1.2 Correspondencia paquete de análisis → subsistema de implementación

| Paquete de análisis (§2.4.1) | Subsistema de implementación | Ejecuta en |
|---|---|---|
| `dominio.modelo`, `dominio.comandos` | `shared/contracts`, `shared/domain-core` | **Navegador y servidor** |
| `dominio.validacion` | `shared/domain-core/validate.ts`, `inheritance.ts` | **Navegador y servidor** |
| `dominio.transformacion` | `shared/generation-ir`, `shared/domain-core/naming.ts`, `reserved-words.ts`, `primary-key.ts` | Servidor |
| `aplicacion.acceso` | `backend/api/src/modules/auth` | Servidor |
| `aplicacion.espacios` | `backend/api/src/modules/projects`, `modules/boards` | Servidor |
| `aplicacion.edicion` | `frontend/src/features/editor` + `shared/yjs-adapter` | Navegador |
| `aplicacion.colaboracion` | `backend/collab` | Servidor |
| `aplicacion.asistente` | `backend/api/src/modules/ai` + `shared/ai` | Servidor |
| `aplicacion.importacion` | `backend/api/src/modules/import` + `shared/xmi` | Servidor |
| `aplicacion.generacion` | `backend/api/src/modules/generation` + `shared/generator-backend` | Servidor |
| `puertos` | `backend/api/src/plugins`, `shared/ai` | Servidor |
| `presentacion` | `frontend/src/features`, `frontend/src/components` | Navegador |

La fila que conviene señalar en la defensa es la primera: **`shared/domain-core`
se ejecuta en ambos lados**. No es una biblioteca duplicada ni un contrato
replicado; es el mismo archivo importado por el navegador y por los dos procesos
de servidor. Eso es RA-05 implementado, no prometido.

### 4.1.3 Compilación y verificación de la regla de dependencia

| Comando | Qué hace |
|---|---|
| `npm ci` | Instala las dependencias exactas del archivo de bloqueo |
| `npm run build` | Compila todos los espacios de trabajo que declaren compilación |
| `npm run typecheck` | `tsc --build` sobre todo el grafo de proyectos, más la configuración de pruebas |
| `npm run lint` | Análisis estático con cero tolerancia a advertencias (`--max-warnings=0`) |
| `npm run format:check` | Verificación de formato |
| `npm run check` | **Puerta de calidad completa**: formato + análisis estático + tipos + pruebas |

La regla de dependencia de la sección 2.4.3 **no se verifica leyendo el código**:
está codificada en el grafo de referencias de proyectos de TypeScript. Si un
paquete de dominio importara uno de aplicación, `npm run typecheck` fallaría. La
arquitectura se defiende sola.

### 4.1.4 Despliegue con contenedores

| Archivo | Contenido |
|---|---|
| `infra/compose.yml` | Orquestación: base de datos, proceso HTTP, proceso de colaboración, interfaz y proxy |
| `infra/api.Dockerfile` | Imagen del proceso HTTP |
| `infra/collab.Dockerfile` | Imagen del proceso de colaboración |
| `infra/web.Dockerfile` | Imagen de la interfaz servida estáticamente |
| `infra/caddy/` | Proxy inverso del perfil de demostración: un solo origen |
| `infra/.env.example` | Plantilla de configuración; **el `.env` real nunca se versiona** [RNF-08] |

Ciclo completo de arranque:

```bash
npm ci                              # dependencias exactas
cp infra/.env.example infra/.env    # configuración local
npm run up                          # todo el entorno            [RNF-12]
npm run seed                        # dos cuentas y un proyecto con dos pizarras
```

> **📐 DIAGRAMA D-34 — Diagrama de componentes de implementación (subsistemas)**
> *Tipo EA: Component Diagram con paquetes `«subsystem»`.*
> Los subsistemas de 4.1.2 organizados en tres bandas —Navegador, Servidor,
> Compartido— con sus dependencias de compilación. **Destacar en color distinto
> los tres paquetes de `shared/` que cruzan la frontera navegador/servidor**:
> `contracts`, `domain-core` y `yjs-adapter`. Es el diagrama que hace visible por
> qué el monorepositorio no es una comodidad, sino una decisión arquitectónica.

> **📐 DIAGRAMA D-35 — Diagrama de artefactos y despliegue de contenedores**
> *Tipo EA: Deployment Diagram con artefactos.*
> Refinamiento de D-23 mostrando **qué artefacto** se despliega en cada contenedor
> (`api.Dockerfile` → `«artifact» api`, etc.), el volumen de datos de PostgreSQL y
> el archivo de configuración `infra/.env` como artefacto de despliegue marcado
> `«not versioned»`.

## 4.2 Implementación de la arquitectura del subsistema

### 4.2.1 Subsistema `shared/domain-core` — el núcleo

| Módulo | Responsabilidad |
|---|---|
| `apply.ts` | Aplicador único del vocabulario de comandos [RA-05] |
| `validate.ts` | Validador único; produce diagnósticos con severidad |
| `inheritance.ts` | Reglas de la jerarquía: ciclos, herencia simple, clave heredada |
| `naming.ts` | Convenciones de nombre de clase, tabla y columna |
| `primary-key.ts` | Resolución de la clave primaria, incluida la heredada |
| `reserved-words.ts` | Palabras reservadas de SQL y Java, y su escape |
| `proposal-preconditions.ts` | Comprueba que una propuesta de la IA sea aplicable al estado actual |

**Sin dependencias de entrada o salida.** Es lo que permite probarlo sin base de
datos, sin red y sin Docker, y ejecutarlo idéntico en el navegador.

### 4.2.2 Subsistema `shared/contracts` — el vocabulario

| Módulo | Contenido |
|---|---|
| `vocabulary.ts` | Los cuatro conjuntos cerrados: **11** comandos, **8** tipos conceptuales, **4** relaciones, **4** multiplicidades; más los 5 orígenes de lote y la versión de esquema |
| `commands.ts` | Esquema de cada comando y del lote |
| `model.ts` | Esquema del modelo canónico |
| `validation.ts`, `severity.ts` | Esquema del diagnóstico y sus niveles |

Que el vocabulario viva en un solo archivo, como listas literales, no es
cosmético: **ampliarlo es una decisión de alcance, no un detalle de
implementación**, y el sistema de tipos obliga a tratar cada ampliación en todos
los lugares que la consumen.

### 4.2.3 Subsistema `backend/api` — organización por módulos

```
backend/api/src/
├── server.ts                    arranque del proceso
├── app.ts                       ensamblado de complementos y rutas
├── config.ts                    configuración validada
├── plugins/
│   ├── auth.ts                  verificación de credencial; decorador `authenticate`
│   └── prisma.ts                cliente de base de datos como recurso del servidor
├── lib/
│   ├── http-error.ts            errores con código y mensaje saneado
│   ├── mail.ts                  envío del enlace de recuperación
│   └── request-cancellation.ts  cancelación de peticiones largas
└── modules/
    ├── auth/        routes · passwords · tokens · profile
    ├── projects/    routes · membership
    ├── boards/      routes
    ├── ai/          routes
    ├── import/      routes
    ├── generation/  routes
    └── audit/       routes
```

Cada módulo corresponde a un paquete de análisis y expone sus rutas. La
separación `plugins/` (recursos transversales del servidor) frente a `modules/`
(casos de uso) mantiene la orquestación aislada de la infraestructura.

### 4.2.4 Subsistema `backend/collab` — la sala

| Módulo | Responsabilidad |
|---|---|
| `server.ts`, `app.ts` | Arranque y ensamblado del servidor de colaboración |
| `auth/authorize.ts` | **Autoriza la conexión antes de admitirla en la sala** [RA-15] |
| `persistence/board-store.ts` | Carga y persiste el estado binario nativo del documento [RA-11] |
| `config.ts` | Configuración validada |

Cuatro archivos. El subsistema es deliberadamente pequeño: toda la lógica de
modelado vive en `shared/domain-core`, no aquí. Si este subsistema creciera,
sería señal de que la regla de dependencia se está erosionando.

### 4.2.5 Subsistema `frontend` — organización por funcionalidad

```
frontend/src/
├── main.tsx · App.tsx
├── components/     AppBar · ThemeProvider · icons
├── lib/            cliente HTTP, utilidades
└── features/
    ├── auth/        LoginPage · ProfilePage · ResetPage · session
    ├── projects/    ProjectsPage · ProjectMembers
    ├── editor/      BoardPage · BoardCanvas · ClassNode · AsociacionEdge
    │                EditorToolbox · Inspector · ValidationPanel
    ├── assistant/   AssistantPanel
    ├── import/      ImportPanel · CapturaCamara · CandidateEditor
    └── generation/  GenerationPanel
```

La organización **por funcionalidad y no por tipo de archivo** hace que cada
carpeta de `features/` corresponda a un paquete de casos de uso de la sección
1.5.1. Abrir `features/generation/` es abrir M6.

### 4.2.6 Subsistema `shared/ai` — puertos y adaptadores

El puerto define qué necesita el dominio —interpretar una instrucción, interpretar
una imagen— y los adaptadores lo satisfacen contra proveedores concretos, con
**encadenamiento de respaldo** [ADR-019]: si el primario falla, se intenta el
siguiente sin que ningún módulo de aplicación se entere.

Sustituir un proveedor es cambiar configuración, no código. Ese es el criterio
con el que se juzga si un puerto está bien trazado.

> **📐 DIAGRAMA D-36 — Diagrama de paquetes de implementación del monorepositorio**
> *Tipo EA: Package Diagram.*
> La estructura de 4.1.1 con las dependencias reales entre espacios de trabajo.
> Comprobar al dibujarlo que ningún paquete de `shared/` dependa de `backend/` ni
> de `frontend/`: si aparece esa flecha, es un defecto arquitectónico real.

> **📐 DIAGRAMA D-37 — Diagrama de clases de diseño del puerto de IA**
> *Tipo EA: Class Diagram.*
> La interfaz `«interface» AiPort` definida en el dominio, los adaptadores
> concretos que la realizan, y el `AiGateway` que los encadena. Es el ejemplo
> canónico del patrón de puertos y adaptadores en el sistema, y el que mejor
> demuestra el concepto de «componente sustituible» de la Parte I.

---

# 5 Flujo de Trabajo: Prueba

La prueba verifica que la implementación realiza los casos de uso. En este
proyecto **está automatizada y se ejecuta de forma continua**: no es una fase
final, sino un flujo que atraviesa todas las iteraciones, como prescribe PUDS.

## 5.1 Estrategia de prueba

### 5.1.1 Niveles

| Nivel | Herramienta | Alcance | Comando |
|---|---|---|---|
| **Unitaria** | Vitest | Dominio puro: aplicador, validador, herencia, nombres, transformación. **Sin Docker, sin base de datos, sin red** | `npm test` |
| **Integración** | Vitest | Rutas de la interfaz de programación contra un PostgreSQL efímero | `npm run test:api` |
| **Sistema (generado)** | Maven + PostgreSQL | Genera el proyecto, lo **compila**, lo **arranca** y ejerce el CRUD | `npm run test:generated` |
| **Banco de regresión** | Maven + PostgreSQL | Lo mismo sobre los **ocho modelos** del banco de pruebas | `npm run test:bank` |
| **Extremo a extremo** | Playwright | Dos navegadores contra el entorno levantado | `npm run test:e2e` |
| **Puerta de calidad** | Todas | Formato + análisis estático + tipos + pruebas rápidas | `npm run check` |

El nivel que distingue a este proyecto es el tercero. No se comprueba que el
generador «produzca archivos con el aspecto esperado»: se comprueba que el
proyecto generado **compile con Maven, arranque contra una base de datos real y
responda correctamente al ciclo CRUD**. Es la única forma de verificar
objetivamente el criterio de cierre declarado en la sección 1.5.7 de la Parte I.

### 5.1.2 Casos de prueba de extremo a extremo

El repositorio contiene **veinte especificaciones** de extremo a extremo, que
cubren los casos de uso significativos:

| Especificación | Casos de uso verificados |
|---|---|
| `cuenta.spec.ts`, `sesion.spec.ts` | CU-01, CU-02, CU-03, CU-05 |
| `proyectos.spec.ts`, `tarjetas.spec.ts` | CU-06, CU-07, CU-08, CU-09, CU-10 |
| `usabilidad-editor.spec.ts`, `notacion.spec.ts` | CU-11, CU-12, CU-13, CU-14 |
| `colaboracion.spec.ts`, `colaboracion-concurrente.spec.ts` | CU-16, CU-17 |
| `auditoria-regresiones.spec.ts` | CU-18 |
| `ia-contexto.spec.ts`, `voz.spec.ts` | CU-19, CU-20, CU-21, CU-22 |
| `xmi-asociativa.spec.ts`, `colaboracion-xmi-completa.spec.ts` | CU-24, CU-25, CU-26 |
| `generacion.spec.ts` | CU-27, CU-28, CU-29 |
| `borradores.spec.ts` | Persistencia de trabajo no confirmado |
| `carga.spec.ts` | RNF-02, RNF-03 |
| `movil.spec.ts`, `apariencia.spec.ts` | Responsividad y presentación |

La especificación `generacion.spec.ts` incluye el paso de la defensa que va del
diagrama al archivo: **dibujar una clase, generar y comprobar que el ZIP
descargado contiene lo esperado**.

### 5.1.3 Casos de prueba por caso de uso — matriz

| Caso de uso | Unitaria | Integración | Sistema | E2E |
|---|:---:|:---:|:---:|:---:|
| CU-15 Aplicar lote | ✔ (aplicador, atomicidad, idempotencia) | ✔ | — | ✔ |
| CU-14 Validar modelo | ✔ (reglas RM, herencia, severidad) | ✔ | — | ✔ |
| CU-11/12/13 Editar | ✔ (comandos) | — | — | ✔ |
| CU-16 Unirse a sesión | — | ✔ (autorización de sala) | — | ✔ |
| CU-17 Sincronizar | — | ✔ (convergencia) | — | ✔ (dos navegadores) |
| CU-19/20 Asistente | ✔ (precondiciones de propuesta) | ✔ (respaldo de proveedor) | — | ✔ |
| CU-23/24 Importar | ✔ (analizador XMI) | ✔ | — | ✔ |
| CU-27 Generar | ✔ (reglas de transformación) | ✔ | ✔ **compila y arranca** | ✔ |
| CU-28 Descargar | — | ✔ (SHA-256 estable) | — | ✔ (ZIP descargado) |

### 5.1.4 Pruebas de los requisitos no funcionales

| Requisito | Cómo se verifica |
|---|---|
| RNF-01 propagación < 500 ms | Medición en `colaboracion-concurrente.spec.ts` |
| RNF-02 ≥ 5 participantes | `carga.spec.ts` |
| RNF-03 fluidez del lienzo | `carga.spec.ts` con el número de clases previsto |
| RNF-05, RNF-07 el generado compila y arranca | `test:bank` sobre ocho modelos |
| RNF-08 secretos y derivación de contraseñas | Revisión y pruebas de integración de autenticación |
| RNF-12 un solo comando | El propio `npm run up` en integración continua |
| RNF-13 integración continua | `.github/workflows/ci.yml` |
| RNF-15 aislamiento del dominio | `npm run typecheck` falla si se viola |
| **Determinismo** [RA-07] | Regenerar el mismo snapshot y comparar la suma SHA-256 |

### 5.1.5 Integración continua

El flujo de trabajo `.github/workflows/ci.yml` ejecuta la puerta de calidad en
cada cambio. El criterio es binario: **si la puerta no pasa, el cambio no
entra**. Ni advertencias toleradas (`--max-warnings=0`), ni formato negociable,
ni tipos aproximados.

### 5.1.6 Datos de prueba

El espacio de trabajo `fixtures/` contiene el **banco de modelos generables**:
ocho modelos UML que cubren, entre todos, las cuatro relaciones, las cuatro
multiplicidades, los ocho tipos conceptuales, la relación muchos-a-muchos con
entidad intermedia, la jerarquía de generalización y los nombres que colisionan
con palabras reservadas. Cada uno se genera, se compila y se ejerce. Añadir un
caso límite al banco es la forma normal de registrar un defecto encontrado.

Adicionalmente, `npm run seed` crea de forma idempotente dos cuentas y un
proyecto con dos pizarras, para ensayar la colaboración sin registrarse a mano.

> **📐 DIAGRAMA D-38 — Diagrama de actividad de la estrategia de prueba**
> *Tipo EA: Activity Diagram.*
> El encadenamiento de los seis niveles de 5.1.1 desde el cambio de código hasta
> la aceptación, con **nodos de decisión** que representan las puertas: si
> `typecheck` falla, no se llega a las pruebas; si `test:bank` falla, no se
> acepta el cambio. Usar calles para *Desarrollo local* e *Integración continua*.

> **📐 DIAGRAMA D-39 — Diagrama de casos de prueba y su trazabilidad**
> *Tipo EA: Use Case Diagram con elementos `«testcase»`, o una matriz de
> trazabilidad generada por EA (Relationship Matrix).*
> Vincular cada caso de uso de la sección 1.2.1 con las especificaciones que lo
> verifican, según la matriz de 5.1.3. **EA genera esta matriz automáticamente** si
> se crean los elementos de prueba y las relaciones `«verifies»`; conviene usar
> esa función en lugar de dibujarla a mano.

---

# Anexo

## Anexo A · Catálogo de diagramas a elaborar en Enterprise Architect

Treinta y nueve diagramas, ordenados por su aparición en el documento.

| # | Diagrama | Tipo EA | Sección | Estado |
|---|---|---|---|:---:|
| D-01 | Actores y su generalización | Use Case | 1.1.2 | ☐ |
| D-02 | Casos de uso — vista general por paquetes | Use Case | 1.2.2 | ☐ |
| D-03 | Casos de uso — M0a Gestión de Acceso | Use Case | 1.2.2 | ☐ |
| D-04 | Casos de uso — M0b Espacios de Trabajo | Use Case | 1.2.2 | ☐ |
| D-05 | **Casos de uso — M1 Edición del Modelo** | Use Case | 1.2.2 | ☐ |
| D-06 | Casos de uso — M2 Colaboración | Use Case | 1.2.2 | ☐ |
| D-07 | Casos de uso — M3 Asistencia por IA | Use Case | 1.2.2 | ☐ |
| D-08 | Casos de uso — M4/M5 Importación | Use Case | 1.2.2 | ☐ |
| D-09 | Casos de uso — M6 Generación | Use Case | 1.2.2 | ☐ |
| D-10 | **Paquetes del modelo de casos de uso** | Package | 1.5.3 | ☐ |
| D-11 | Inclusiones, extensiones y generalizaciones | Use Case | 1.5.3 | ☐ |
| D-12 | **Arquitectura en capas (análisis)** | Package / Component | 2.1.5 | ☐ |
| D-13 | Actividad — flujo de una modificación | Activity | 2.1.5 | ☐ |
| D-14 | Realización CU-15 — clases de análisis | Class | 2.2.4 | ☐ |
| D-15 | Realización CU-15 — comunicación | Communication | 2.2.4 | ☐ |
| D-16 | Realización CU-17 — comunicación | Communication | 2.2.4 | ☐ |
| D-17 | Realización CU-27 — clases de análisis | Class | 2.2.4 | ☐ |
| D-18 | Realización CU-19 — clases de análisis | Class | 2.2.4 | ☐ |
| D-19 | **Clases de análisis — dominio de modelado** | Class | 2.3.3 | ☐ |
| D-20 | Clases de análisis — dominio de plataforma | Class | 2.3.3 | ☐ |
| D-21 | Paquetes de análisis | Package | 2.4.3 | ☐ |
| D-22 | **Componentes** | Component | 3.1.4 | ☐ |
| D-23 | **Despliegue** | Deployment | 3.1.4 | ☐ |
| D-24 | Secuencia CU-15 | Sequence | 3.2.6 | ☐ |
| D-25 | Secuencia CU-17 (concurrencia) | Sequence | 3.2.6 | ☐ |
| D-26 | Secuencia CU-27 | Sequence | 3.2.6 | ☐ |
| D-27 | Secuencia CU-19 (respaldo de IA) | Sequence | 3.2.6 | ☐ |
| D-28 | Estados de `Generation` | StateMachine | 3.2.6 | ☐ |
| D-29 | Estados de la sesión colaborativa | StateMachine | 3.2.6 | ☐ |
| D-30 | **Modelo entidad-relación de la plataforma** | Data Model | 3.3.4 | ☐ |
| D-31 | **Clases de diseño del núcleo de dominio** | Class | 3.3.4 | ☐ |
| D-32 | Clases de diseño de la cadena de generación | Class | 3.3.4 | ☐ |
| D-33 | Clases del proyecto generado (patrón) | Class | 3.3.4 | ☐ |
| D-34 | Componentes de implementación (subsistemas) | Component | 4.1.4 | ☐ |
| D-35 | Artefactos y contenedores | Deployment | 4.1.4 | ☐ |
| D-36 | Paquetes del monorepositorio | Package | 4.2.6 | ☐ |
| D-37 | Puerto de IA (puertos y adaptadores) | Class | 4.2.6 | ☐ |
| D-38 | Actividad — estrategia de prueba | Activity | 5.1.6 | ☐ |
| D-39 | Trazabilidad casos de uso ⇄ casos de prueba | Relationship Matrix | 5.1.6 | ☐ |

### A.1 Los nueve diagramas imprescindibles

Si el tiempo obliga a priorizar, estos nueve sostienen la defensa completa. Los
demás la enriquecen.

| Orden | Diagrama | Qué demuestra |
|---|---|---|
| 1 | **D-02** Vista general de casos de uso | El alcance entero en una página |
| 2 | **D-05** Casos de uso de M1 | Que toda entrada converge en CU-15 |
| 3 | **D-10** Paquetes de casos de uso | El núcleo con adaptadores alrededor |
| 4 | **D-12** Arquitectura en capas | La regla de dependencia hacia el dominio |
| 5 | **D-19** Clases de análisis del modelado | El modelo de dominio de la herramienta |
| 6 | **D-22** Componentes | Que los tres procesos comparten un solo dominio |
| 7 | **D-23** Despliegue | Que el sistema es desplegable y con un solo comando |
| 8 | **D-30** Modelo entidad-relación | El diseño de datos real |
| 9 | **D-24** Secuencia de CU-15 | Que validar precede a aplicar, y que el lote es atómico |

### A.2 Recomendaciones de elaboración en Enterprise Architect

1. **Crear el proyecto con vistas según el Proceso Unificado.** En el navegador de
   proyecto, cuatro vistas raíz: `1 Requisitos`, `2 Análisis`, `3 Diseño`,
   `4 Implementación`, más `5 Pruebas`. Los diagramas de este documento se
   distribuyen por su número de sección.

2. **Modelar los elementos una sola vez y reutilizarlos.** Un caso de uso es un
   elemento del repositorio, no un dibujo: arrastrar `CU-15` a los diagramas D-05,
   D-11, D-14 y D-39 debe ser **el mismo elemento**, no cuatro copias. De lo
   contrario, la matriz de trazabilidad de D-39 no funcionará.

3. **Registrar los requisitos como elementos `«requirement»`** y vincularlos con
   `«realizes»` a los casos de uso. Con eso, EA genera sola la matriz de
   trazabilidad requisito ⇄ caso de uso ⇄ caso de prueba, que es exactamente lo
   que la sección 1.2.1 tabula a mano.

4. **Usar los estereotipos de análisis de Jacobson.** En las propiedades del
   elemento, activar `«boundary»`, `«control»` o `«entity»` para que EA los dibuje
   con su notación circular propia. Sin eso, los diagramas D-14 a D-18 parecen
   diagramas de diseño y pierden su propósito.

5. **Generar el DDL desde D-30.** EA puede producir el guion SQL desde el modelo
   de datos; compararlo con el esquema real de `schema.prisma` es una verificación
   útil, y su coincidencia es un argumento de defensa.

6. **Exportar como imagen a 300 ppp** para insertar en el documento final
   (*Diagram > Save Image to File*), no capturas de pantalla.

## Anexo B · Trazabilidad ADR ⇄ decisiones de este documento

| ADR | Decisión | Dónde aparece en la Parte II |
|---|---|---|
| ADR-001 | Monolito modular en dos procesos | 2.1.4, 3.1.1, 3.1.3 |
| ADR-002 | CRDT para colaboración | 1.3.3, CU-17, 2.2.2 |
| ADR-003 | Modelo canónico, comandos por lotes | 1.2.2, CU-15, 2.3.1 |
| ADR-004 | Varias pizarras, generación seleccionada | CU-07, CU-27 |
| ADR-005 | Entidad intermedia para muchos-a-muchos | CU-13 A3, 2.3.2, 3.3.3 |
| ADR-006 | Sin *event sourcing* ni CQRS | 3.1.1 |
| ADR-007 | Generación por IR y plantillas | 1.3.3, CU-27, 3.1.1, 3.3.3 |
| ADR-008 | DTO planos, relaciones unidireccionales | 3.3.4 |
| ADR-009 | Tiempo de ejecución compartido | 4.1.2 |
| ADR-010 | Compose; infraestructura como código diferida | 2.1.4, 3.1.1 |
| ADR-011 | Generación limitada a la capa de datos | *(superada por ADR-020)* |
| ADR-012 | Importación como candidato editable | CU-23, CU-24, CU-26 |
| ADR-013 | UUID para creación sin conexión | CU-11, 3.3.1 |
| ADR-014 | Autenticación propia mínima | CU-01, CU-02, 3.3.1 |
| ADR-015 | Proveedores de IA tras puertos | 2.1.5, 3.1.4, 4.2.6 |
| ADR-016 | Matriz de versiones | 4.1.3 |
| ADR-017 | Agente móvil local | *(retirado del alcance; fase 9)* |
| ADR-018 | Los artefactos no se almacenan | CU-27, CU-28, 3.3.2 |
| ADR-019 | Pasarela de IA: credenciales y respaldo | CU-19 A2, 3.2.4, 4.2.6 |
| ADR-020 | Generalización por tabla por clase | CU-12 A2, 3.3.3 |

## Anexo C · Glosario de códigos

| Prefijo | Significado |
|---|---|
| `CU-nn` | Caso de uso de este documento |
| `D-nn` | Diagrama a elaborar en Enterprise Architect |
| `RF-nnn` | Requisito funcional |
| `RNF-nn` | Requisito no funcional medible |
| `RA-nn` | Restricción arquitectónica (quince en total) |
| `RM-nn` | Regla de modelado UML |
| `RTM-nn` | Regla de transformación al modelo relacional |
| `CA-nnn` | Criterio de aceptación |
| `ADR-nnn` | Registro de decisión arquitectónica |
| `An` | Flujo alternativo dentro de un caso de uso |

---

*Documento preparado el 12 de septiembre de 2026.*
*Parte II del informe del Primer Examen Parcial de Ingeniería de Software 1.*
````

---

### `docs/examen/perfil-del-proyecto.md`

```markdown
# 1. PERFIL DEL PROYECTO

> **Proyecto:** UMLFORGE AI — Plataforma colaborativa asistida por inteligencia
> artificial para el modelado de diagramas de clases UML, reconocimiento de
> bocetos y generación automática de backend Spring Boot a partir de los
> diagramas.
> **Materia:** Ingeniería de Software 1 · Primer Examen Parcial · Periodo 02/2026
> **Estudiante:** Blanco Camacho Brayan Edgar · Registro 219182965 · Grupo SB
> **Docente:** Ing. Martínez Canedo Rolando Antoni
> **Universidad Autónoma Gabriel René Moreno — Facultad de Ingeniería en
> Ciencias de la Computación y Telecomunicaciones**
> **Santa Cruz de la Sierra — Bolivia**

---

## 1.1 Introducción

El diagrama de clases UML es el artefacto central del análisis y diseño orientado
a objetos. Es donde el equipo acuerda qué entidades existen en el dominio, qué
información guardan y cómo se relacionan entre sí. De ese acuerdo se derivan
después el modelo de datos, las entidades de persistencia, los servicios y las
interfaces de programación de la aplicación.

Sin embargo, entre el momento en que un equipo dibuja ese diagrama —normalmente
en una pizarra, durante una reunión— y el momento en que existe código
ejecutable, se abre una brecha que hoy se sigue cruzando a mano. La fotografía
del pizarrón se guarda en un grupo de mensajería y nunca se transcribe. Alguien
redibuja el diagrama en una herramienta de escritorio, en solitario, días
después. Otra persona escribe a mano las entidades, los repositorios, los
controladores y el esquema de base de datos, repitiendo el mismo código
estructural para cada clase. Y a partir del primer cambio, el diagrama y el
código empiezan a divergir: el diagrama envejece hasta volverse documentación
falsa.

**UMLFORGE AI** es una plataforma web que cierra esa brecha de extremo a extremo.
Permite a varias personas construir el mismo diagrama de clases simultáneamente
y en tiempo real, incorporar contenido mediante lenguaje natural —escribiendo,
dictando por voz o fotografiando un boceto de pizarra— y generar, a partir del
diagrama validado, un proyecto **Spring Boot** completo y funcional: entidades
JPA, repositorios, servicios, controladores REST con operaciones CRUD,
documentación OpenAPI y esquema de base de datos **PostgreSQL**, listo para
compilar, ejecutar y probar en Postman.

La plataforma es, en términos de la disciplina, una **herramienta CASE integrada
(I-CASE)**: cubre el modelado, la validación, la generación de código y el
intercambio de modelos sobre un repositorio único. Su diseño incorpora dos
decisiones que la distinguen de las herramientas de generación asistidas por
inteligencia artificial que se han popularizado recientemente:

1. **El modelo es la fuente de verdad, no el código.** El código generado es un
   artefacto derivado y desechable; si el modelo cambia, se regenera. No existe
   ingeniería de ida y vuelta que pueda desincronizarse.
2. **La inteligencia artificial construye el diagrama, pero no escribe el
   código.** La IA interpreta lenguaje natural ambiguo —donde su capacidad es
   valiosa y su margen de error es tolerable porque el usuario revisa la
   propuesta antes de aplicarla—, mientras que la generación de código es
   estrictamente determinista mediante plantillas: el mismo diagrama produce
   siempre exactamente el mismo proyecto.

El sistema está construido como un monorepositorio con **React 19** en el
frontend, **Node.js con Fastify** en el backend, **Yjs/Hocuspocus** para la
colaboración en tiempo real mediante CRDT, **Prisma** y **PostgreSQL** para la
persistencia, y una pasarela de inteligencia artificial con proveedores
intercambiables. Todo el entorno se levanta con un solo comando mediante
**Docker Compose**.

---

## 1.2 Objetivo General

> **Desarrollar una plataforma web colaborativa asistida por inteligencia
> artificial que permita a varios usuarios construir simultáneamente y en tiempo
> real diagramas de clases UML —mediante interfaz gráfica, lenguaje natural
> escrito, comandos de voz o el reconocimiento automático de bocetos
> fotografiados—, validar la consistencia del modelo resultante y generar a
> partir de él, de forma determinista, un proyecto backend Spring Boot funcional
> con persistencia PostgreSQL y servicios REST documentados, verificable
> mediante Postman.**

---

## 1.3 Objetivos Específicos

**Sobre el modelado y la colaboración**

1. **Implementar un editor gráfico de diagramas de clases UML** que soporte la
   creación y manipulación de clases con sus atributos tipados, y las cuatro
   relaciones del subconjunto definido —asociación, generalización, composición
   y agregación— con su notación UML propia y multiplicidad en ambos extremos.

2. **Desarrollar un mecanismo de edición colaborativa concurrente en tiempo
   real** basado en tipos de datos replicados sin conflicto (CRDT), que permita
   la participación simultánea de al menos cinco usuarios por pizarra sin
   bloqueos, con indicadores de presencia y propagación de cambios por debajo de
   500 milisegundos.

3. **Diseñar un modelo canónico único con un vocabulario cerrado de comandos**,
   de modo que toda entrada al sistema —interfaz gráfica, texto, voz, imagen o
   importación XMI— produzca lotes atómicos de comandos validados, y que ninguna
   entrada escriba el estado del diagrama directamente.

4. **Construir un validador de consistencia del modelo** que ejecute las mismas
   reglas en el navegador y en el servidor, y que informe al usuario con niveles
   de severidad diferenciados (error y aviso) las violaciones de las reglas de
   modelado UML, incluidas las de la jerarquía de herencia.

**Sobre la asistencia por inteligencia artificial**

5. **Integrar un asistente de inteligencia artificial** capaz de interpretar
   instrucciones de modelado expresadas en lenguaje natural escrito y dictadas
   por voz, y de traducirlas en propuestas de comandos que el usuario revisa
   antes de aplicar.

6. **Implementar el reconocimiento automático de bocetos** que, a partir de una
   fotografía de un diagrama dibujado en pizarra —tomada con la cámara del
   dispositivo o importada desde un archivo—, reconstruya el diagrama de clases
   como un candidato editable.

7. **Diseñar una pasarela de inteligencia artificial con proveedores
   intercambiables** mediante el patrón de puertos y adaptadores, con
   encadenamiento de proveedores de respaldo, de forma que ningún módulo del
   dominio conozca un proveedor concreto y la sustitución sea una decisión de
   configuración y no de código.

**Sobre la generación de software**

8. **Desarrollar un generador determinista de proyectos Spring Boot** que
   transforme el diagrama de clases en código mediante una representación
   intermedia y plantillas, garantizando que el mismo modelo produzca siempre el
   mismo resultado, y que el proyecto generado compile y arranque sin
   intervención manual.

9. **Definir e implementar las reglas de transformación** del modelo UML al
   modelo relacional y de persistencia: correspondencia de tipos conceptuales a
   tipos Java y SQL, proyección de multiplicidades a claves foráneas, resolución
   de relaciones muchos-a-muchos mediante entidad intermedia, escape de palabras
   reservadas y proyección de la generalización mediante la estrategia de tabla
   por clase unida por la clave primaria.

10. **Generar el esquema de base de datos PostgreSQL y la documentación OpenAPI**
    del proyecto resultante, de modo que sus servicios REST puedan verificarse
    inmediatamente mediante Postman o la interfaz Swagger.

**Sobre la interoperabilidad y la calidad**

11. **Implementar la exportación e importación de modelos en formato XMI 2.5.1**,
    el estándar de intercambio de la OMG, para garantizar la interoperabilidad
    con otras herramientas CASE.

12. **Establecer una estrategia de verificación automatizada** que comprenda
    pruebas unitarias del dominio sin dependencias externas, pruebas de
    integración de la interfaz de programación, pruebas de extremo a extremo de
    la interfaz de usuario, y un banco de pruebas que compile cada proyecto
    generado, lo ejecute contra una base de datos real y verifique el ciclo CRUD
    completo.

13. **Empaquetar el despliegue completo de la plataforma** mediante contenedores,
    de forma que el entorno íntegro —base de datos, procesos de servidor,
    interfaz y proxy— se levante con un único comando.

---

## 1.4 Descripción del Problema

### 1.4.1 Situación problemática

El modelado de clases UML es una actividad **inherentemente colectiva**: el valor
del diagrama está en el acuerdo que representa. Sin embargo, las herramientas
disponibles no acompañan esa naturaleza colectiva, y el proceso que va del
acuerdo al software funcionando presenta rupturas en cada transición.

**a) El boceto de pizarra muere como fotografía.**
El diseño de un modelo de dominio ocurre casi siempre en una pizarra, con el
equipo reunido. Ese trabajo termina en fotografías dispersas en un grupo de
mensajería. La transcripción posterior a una herramienta formal es manual,
tediosa y se posterga; cuando finalmente ocurre, la realiza una sola persona
—normalmente días después—, sin el contexto de la discusión, introduciendo
omisiones e interpretaciones propias.

**b) La colaboración está serializada artificialmente.**
Las herramientas de modelado tradicionales son aplicaciones de escritorio
monousuario. En la práctica, el trabajo en equipo se degrada a que **una sola
persona maneja el ratón mientras el resto dicta**. Cuando se intenta trabajar en
paralelo, aparecen archivos con sufijos de versión que alguien debe fusionar a
mano, con el riesgo de perder trabajo ajeno. Las herramientas web que sí
permiten concurrencia normalmente resuelven los conflictos mediante bloqueo de
elementos, lo que vuelve a serializar el trabajo.

**c) El salto del diagrama al código es manual y repetitivo.**
Una vez acordado el modelo, alguien escribe a mano —para **cada** clase— la
entidad JPA con sus anotaciones, el repositorio, el servicio, el controlador REST
con sus cinco operaciones CRUD, los objetos de transferencia de datos y el
esquema de tablas. Es código estructural, predecible y sin decisiones de diseño
relevantes, pero consume una parte desproporcionada del tiempo del equipo y
concentra errores mecánicos: una anotación olvidada, un tipo mal
correspondido, una clave foránea en el extremo equivocado, una palabra reservada
de SQL usada como nombre de tabla.

**d) El modelo y el código divergen.**
Cuando el código generado o escrito se modifica a mano, el diagrama deja de
describir el sistema. A partir de ese punto la documentación es activamente
engañosa: quien la consulta toma decisiones sobre un modelo que ya no existe. Es
el conocido problema del *round-trip* de las herramientas CASE.

**e) Las herramientas existentes obligan a elegir.**
El panorama actual plantea un compromiso entre capacidades que deberían
coexistir:

| Tipo de herramienta | Colaboración en tiempo real | Generación de backend ejecutable | Asistencia por IA / bocetos | Costo y accesibilidad |
|---|---|---|---|---|
| Escritorio profesional (tipo Enterprise Architect) | No | Parcial | No | Licencia comercial |
| Diagramación web genérica (tipo Draw.io, Lucidchart) | Sí | No | No | Gratuita / freemium |
| Generadores de código a partir de esquemas | No | Sí | No | Variable |
| Asistentes de IA generativa de propósito general | No | No determinista | Sí | Por consumo |

Ninguna reúne las cuatro capacidades. Y en el caso particular de los asistentes
de IA generativa, la generación de código carece de un modelo formal como fuente
de verdad: el resultado es **no determinista** —la misma petición produce
resultados distintos—, no es trazable a un diagrama revisable, y su corrección no
está garantizada.

**f) La barrera de entrada para el estudiante y el equipo pequeño.**
Las herramientas CASE profesionales con capacidad de generación son de licencia
comercial y de instalación local, lo que las hace inaccesibles en el contexto
académico y para equipos pequeños, particularmente en entornos donde el acceso a
licencias y a hardware de gama alta es limitado.

### 1.4.2 Formulación del problema

De lo anterior se desprende la pregunta que orienta el proyecto:

> **¿Cómo lograr que un equipo construya colaborativamente y en tiempo real un
> diagrama de clases UML —partiendo incluso de un boceto de pizarra o de una
> descripción en lenguaje natural— y obtenga a partir de él, de forma automática,
> confiable y reproducible, un backend funcional con persistencia y servicios
> REST verificables, manteniendo el diagrama como única fuente de verdad?**

### 1.4.3 Causas y efectos

| Causa | Efecto |
|---|---|
| Herramientas de modelado monousuario | Trabajo serializado; una persona edita y el resto observa |
| Ausencia de captura automática del boceto | El diseño de pizarra se pierde o se transcribe tarde y con errores |
| Codificación manual del CRUD estructural | Alto consumo de tiempo en código sin valor de diseño; errores mecánicos |
| Generación no determinista o inexistente | Imposibilidad de reproducir y auditar el resultado |
| Ausencia de validación formal del modelo | Se genera código a partir de modelos inconsistentes; el error se descubre al compilar o en producción |
| Divergencia entre modelo y código | Documentación engañosa; pérdida de trazabilidad |
| Licencias comerciales y aplicaciones de escritorio | Barrera de acceso en el contexto académico y para equipos pequeños |

### 1.4.4 Justificación

El proyecto se justifica en cuatro planos:

- **Técnico:** demuestra la viabilidad de una cadena completa de desarrollo
  dirigido por modelos —del boceto al backend ejecutable— con garantías de
  determinismo y validación formal, integrando inteligencia artificial en el
  punto donde aporta valor sin comprometer la reproducibilidad del artefacto
  final.
- **Académico:** materializa de forma verificable los conceptos centrales de la
  materia: herramientas CASE, desarrollo basado en componentes, arquitectura de
  software, UML, la metodología OMT de Rumbaugh y el Proceso Unificado. La
  plataforma no *usa* una herramienta CASE: **es** una herramienta CASE.
- **Práctico:** reduce de forma medible el tiempo entre el acuerdo de diseño y el
  software ejecutable, y elimina una clase entera de errores mecánicos de
  transcripción.
- **Social y económico:** ofrece una alternativa web, accesible desde cualquier
  navegador y sin licencias comerciales, a herramientas CASE de costo elevado,
  lo que la hace utilizable en el contexto universitario boliviano y por equipos
  de desarrollo pequeños.

---

## 1.5 Alcance del Sistema

### 1.5.1 Alcance funcional

El sistema comprende siete módulos funcionales, con más de sesenta requisitos
funcionales catalogados y quince requisitos no funcionales medibles:

| Módulo | Contenido |
|---|---|
| **M0 · Cuenta, proyectos y pizarras** | Registro e inicio de sesión propios; creación, apertura, listado y eliminación de proyectos; múltiples pizarras por proyecto; sesión colaborativa independiente por pizarra; selección de la pizarra objetivo para generar |
| **M1 · Editor** | Creación, renombrado, movimiento y eliminación de clases; gestión de atributos con tipo, clave primaria, nulabilidad y unicidad; creación y modificación de relaciones con multiplicidad y nombre de rol en ambos extremos; selección, conexión, acercamiento y desplazamiento del lienzo; validación con niveles de error y aviso |
| **M2 · Colaboración** | Edición concurrente en tiempo real mediante CRDT; presencia de participantes; indicador del elemento que otro usuario está editando; atribución de cada operación; reconexión con recuperación del estado |
| **M3 · Asistente** | Interpretación de instrucciones de modelado en lenguaje natural escrito; dictado por voz con transcripción; propuesta de comandos revisable antes de aplicarse; solicitud de aclaración ante instrucciones ambiguas |
| **M4 · Importación por imagen** | Captura mediante la cámara del dispositivo o carga de un archivo de imagen; reconstrucción del diagrama como candidato editable; revisión y corrección antes de incorporarlo al modelo |
| **M5 · Interoperabilidad** | Exportación e importación de modelos en formato XMI 2.5.1 (OMG) |
| **M6 · Generación del backend** | Congelación del snapshot del modelo; generación determinista del proyecto Spring Boot completo; descarga como archivo comprimido con manifiesto y suma de verificación SHA-256; historial de generaciones |

### 1.5.2 Alcance del artefacto generado

El proyecto Spring Boot generado incluye:

- **Entidades JPA** con anotaciones de persistencia, correspondencia de tipos y
  de nombres de tabla y columna, incluida la jerarquía de herencia mediante la
  estrategia `InheritanceType.JOINED` (tabla por clase unida por la clave
  primaria).
- **Repositorios** Spring Data JPA.
- **Servicios** con la lógica de acceso y validación.
- **Controladores REST** con el ciclo CRUD completo por entidad.
- **Objetos de transferencia de datos (DTO)** planos.
- **Esquema de base de datos PostgreSQL**, creado automáticamente al arrancar.
- **Documentación OpenAPI / Swagger UI**, que permite probar los servicios desde
  el navegador o desde Postman sin configuración adicional.
- **Configuración de compilación Maven** y archivos de contenedor para su
  despliegue independiente.

### 1.5.3 Actores y roles

| Actor | Descripción | Permisos |
|---|---|---|
| **Visitante** | Persona no autenticada | Registrarse e iniciar sesión |
| **Propietario (`OWNER`)** | Creador del proyecto | Todo lo del editor, más invitar participantes, cambiar roles y eliminar el proyecto |
| **Editor (`EDITOR`)** | Participante invitado con permiso de escritura | Crear y modificar pizarras, editar el diagrama, usar el asistente, importar y generar |
| **Lector (`VIEWER`)** | Participante invitado sin permiso de escritura | Consultar el diagrama y usar el asistente sin modificar el modelo |

### 1.5.4 Alcance tecnológico

| Capa | Tecnología |
|---|---|
| Interfaz de usuario | React 19, TypeScript, Vite |
| Servidor HTTP | Node.js con Fastify |
| Servidor de colaboración | Hocuspocus sobre Yjs (CRDT) |
| Persistencia de la plataforma | PostgreSQL con Prisma ORM |
| Validación de contratos | Zod, compartida entre navegador y servidor |
| Generación de código | Representación intermedia propia y plantillas Handlebars |
| Backend generado | Spring Boot, Java, Spring Data JPA, PostgreSQL, OpenAPI |
| Inteligencia artificial | Pasarela con puertos intercambiables y proveedores de respaldo encadenados |
| Interoperabilidad | XMI 2.5.1 (OMG) |
| Despliegue | Docker y Docker Compose |
| Verificación | Vitest, Playwright, banco de compilación Maven con base de datos real |

### 1.5.5 Alcance de las reglas de modelado soportadas

El sistema implementa un **subconjunto cerrado y deliberado** del diagrama de
clases UML:

- **Cuatro tipos de relación:** asociación, generalización, composición y
  agregación.
- **Cuatro multiplicidades:** `1`, `0..1`, `0..*`, `1..*`.
- **Ocho tipos conceptuales de atributo:** `String`, `Integer`, `Long`,
  `Decimal`, `Boolean`, `Date`, `DateTime`, `UUID`.
- **Once operaciones de modelado** que constituyen el vocabulario completo de
  comandos.
- **Cinco orígenes de entrada:** interfaz gráfica, texto, voz, imagen e
  importación XMI.

### 1.5.6 Límites y exclusiones declaradas

Las siguientes construcciones quedan **explícitamente fuera del alcance**. La
exclusión es una decisión documentada, no una omisión: cuando el validador
encuentra una construcción no soportada, la identifica y sugiere cómo modelarla.

**Del modelado UML:**
métodos e interfaces · clases abstractas · herencia múltiple · otros diagramas
UML distintos del de clases · claves compuestas · relaciones ternarias directas.

**De la generación:**
estrategias de herencia distintas de la tabla por clase · relación
muchos-a-muchos directa sin entidad intermedia · cascadas destructivas ·
regeneración incremental sobre código ya modificado · ingeniería inversa de
código a modelo · paginación, filtrado avanzado y seguridad en el CRUD generado ·
migraciones versionadas · generación de interfaz de usuario y navegación móvil.

**De la infraestructura:**
inteligencia artificial de ejecución local dentro de la herramienta web ·
infraestructura como código · microservicios · intermediarios de mensajería ·
Kubernetes · *event sourcing* y CQRS completo.

**De la gestión de cuentas:**
inicio de sesión con proveedores externos · verificación por correo electrónico ·
recuperación de contraseña · fusión de varias pizarras en un solo sistema.

### 1.5.7 Criterio de cierre

El proyecto se considera completo cuando, partiendo de un boceto dibujado en
pizarra y fotografiado, el sistema permita reconstruir el diagrama de clases,
corregirlo colaborativamente entre varios participantes, validarlo, generar el
proyecto Spring Boot correspondiente, y que dicho proyecto **compile, arranque
contra una base de datos PostgreSQL y responda correctamente a las operaciones
CRUD verificadas desde Postman**, sin intervención manual sobre el código
generado.

---

*Documento preparado el 10 de septiembre de 2026.*
```

---

## Notas sueltas

Auditorias, revisiones y guias por fecha.

### Estructura

```text
docs/
|-- actualizacion.md
|-- apariencia-2026-09-10.md
|-- auditoria-2026-09-05.md
|-- auditoria-2026-09-09.md
|-- auditoria-2026-09-20.md
|-- colaboracion-xmi-2026-09-10.md
|-- comparacion-manual.md
|-- compatibilidad-xmi-2026-09-05.md
|-- despliegue.md
|-- estado-aplicacion-2026-09-05.md
|-- estrategia-mobile-offline-agente.md
|-- generacion-backend-gestion.md
|-- generacion-flutter-android.md
|-- guia-pruebas-despliegue-app-generada.md
|-- guia-uso-y-pruebas-completa.md
|-- importacion-clase-asociativa.md
|-- modelos-ia-2026-09-10.md
|-- pendientes.md
|-- proveedores-ia.md
|-- requisitos-docente-2026-09-06.md
|-- responsividad-movil-2026-09-05.md
|-- revision-bugs-flutter-2026-09-11.md
|-- revision-colaboracion-xmi-2026-09-09.md
|-- revision-despliegue-vps-2026-09-17.md
|-- revision-generador-crud.md
|-- revision-ia-2026-09-06.md
|-- revision-ia-2026-09-10.md
|-- revision-ia-local-flutter.md
`-- voz-y-consumo-ia.md
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `docs/actualizacion.md` | 697 |
| `docs/apariencia-2026-09-10.md` | 22 |
| `docs/auditoria-2026-09-05.md` | 109 |
| `docs/auditoria-2026-09-09.md` | 158 |
| `docs/auditoria-2026-09-20.md` | 35 |
| `docs/colaboracion-xmi-2026-09-10.md` | 71 |
| `docs/comparacion-manual.md` | 158 |
| `docs/compatibilidad-xmi-2026-09-05.md` | 72 |
| `docs/despliegue.md` | 337 |
| `docs/estado-aplicacion-2026-09-05.md` | 169 |
| `docs/estrategia-mobile-offline-agente.md` | 59 |
| `docs/generacion-backend-gestion.md` | 70 |
| `docs/generacion-flutter-android.md` | 84 |
| `docs/guia-pruebas-despliegue-app-generada.md` | 541 |
| `docs/guia-uso-y-pruebas-completa.md` | 733 |
| `docs/importacion-clase-asociativa.md` | 44 |
| `docs/modelos-ia-2026-09-10.md` | 56 |
| `docs/pendientes.md` | 101 |
| `docs/proveedores-ia.md` | 92 |
| `docs/requisitos-docente-2026-09-06.md` | 62 |
| `docs/responsividad-movil-2026-09-05.md` | 96 |
| `docs/revision-bugs-flutter-2026-09-11.md` | 29 |
| `docs/revision-colaboracion-xmi-2026-09-09.md` | 79 |
| `docs/revision-despliegue-vps-2026-09-17.md` | 61 |
| `docs/revision-generador-crud.md` | 73 |
| `docs/revision-ia-2026-09-06.md` | 60 |
| `docs/revision-ia-2026-09-10.md` | 46 |
| `docs/revision-ia-local-flutter.md` | 39 |
| `docs/voz-y-consumo-ia.md` | 53 |

---

### `docs/actualizacion.md`

````markdown
# Fase 11 - robustecimiento, recuperación y entrega

> Documento histórico del 31 de agosto. Para el alcance y las pruebas actuales,
> consultar [el informe del 5 de septiembre](estado-aplicacion-2026-09-05.md).
> Las referencias a Dart y al módulo móvil preceden su retirada del código.

**Estado:** en ejecución; primera corrección integral aplicada  
**Fecha de revisión:** 31 de agosto de 2026  
**Entrega de referencia:** 23 de septiembre de 2026

Esta fase nace del contraste entre tres fuentes:

1. el *Manual de Usuario - 1er Parcial* de Parada Burgos Klaus;
2. el documento *Primer Parcial - Semestre* del mismo proyecto;
3. el estado real de esta plataforma: código, pruebas, ADR, plan maestro y
   pendientes.

Los dos PDF son **antecedentes de un examen parecido**, no una nueva
especificación del docente para este proyecto. Sus funciones no entran por el
solo hecho de aparecer allí. Se adoptan únicamente cuando cierran un requisito
nuestro, corrigen una contradicción o mejoran de forma comprobable la defensa.

El plan maestro y las aclaraciones directas del docente siguen teniendo
precedencia. En particular, esta fase no cambia las decisiones de generar solo
la capa de datos Dart ni de modelar únicamente diagramas de clases.

## 0. Estado de la implementación al 31 de agosto de 2026

Esta revisión ya no es solamente una propuesta. Se aplicó y comprobó el primer
bloque de robustecimiento:

- el importador XMI distingue entre un candidato aplicable y un archivo cuyo
  contenido ya está en la pizarra; los duplicados dejan de terminar en una
  pregunta sin botones;
- la vista previa permite corregir nombres de clases y atributos, tipos,
  nulabilidad, claves primarias y multiplicidades antes de aplicar;
- los avisos están plegados, las acciones permanecen visibles y la herramienta
  reserva altura suficiente para no tapar los campos editables;
- el mismo archivo puede reintentarse en modo `REPLACE` sin volver a buscarlo;
- la exportación XMI renueva una sesión vencida igual que el resto del cliente;
- una generación valida el modelo antes de congelar el snapshot, rechaza
  paquetes Java reservados y marca como fallida una emisión interrumpida;
- la auditoría conserva los lotes localmente y los reintenta; su idempotencia es
  por `boardId + batchId`, no global entre pizarras;
- un cambio de rol afecta una conexión WebSocket ya abierta y un token vencido
  intenta renovarse antes de abandonar la colaboración.
- la configuración de referencia de Gemini usa `gemini-3.6-flash`: el anterior
  `gemini-2.5-flash` devuelve 404 para cuentas nuevas. Los errores de proveedor
  muestran ahora la causa saneada en lugar del ambiguo «no se pudo interpretar».
- el asistente conserva la solicitud y sus aclaraciones mientras existe una
  pregunta pendiente, tanto si la respuesta se escribe como si se dicta. El
  contexto se limita a diez turnos, se limpia al obtener una propuesta, cambia
  de pizarra o pulsar `Empezar de nuevo`, y nunca se mezcla con otra solicitud;
- el prompt reconstruye la petición completa dando prioridad al dato más
  reciente e infiere tipos omitidos por semántica (`id -> Integer`,
  `descripcion -> String`, fechas, importes, cantidades y booleanos). Una
  normalización determinista completa también el tipo si el proveedor lo omite
  en su JSON, sin reemplazar tipos que el usuario sí indicó.

### Pendiente después de esta corrección

- decidir si las aclaraciones del asistente deben sobrevivir a una recarga o
  continuar en otro dispositivo. Ahora son deliberadamente locales a la sesión
  visible y se descartan al recargar para no mezclar solicitudes antiguas;
- completar en la vista previa la edición de roles de relación, eliminación de
  operaciones individuales y validación reactiva antes de habilitar `Aplicar`;
- probar XMI en ambos sentidos con Enterprise Architect 15 real;
- conectar proveedores reales de IA y comprobar el reconocimiento de voz en el
  teléfono objetivo sin conexión;
- implementar copia JSON, restauración, vista de código, reparación N:M y las
  mejoras documentales restantes de esta fase;
- medir RNF, revisar dependencias reportadas por `npm audit`, dividir el paquete
  JavaScript principal y realizar el ensayo completo cronometrado.

### Evidencia ejecutada en esta revisión

- `npm run check`: 275 pruebas pasan; la única omitida es la que necesita un
  XMI exportado por Enterprise Architect real;
- regresión del asistente contextual: 71 pruebas unitarias de IA y 11 de
  integración pasan, incluidas transmisión de contexto, límite de turnos e
  inferencia de tipos;
- dos pruebas contra Gemini real y los contenedores reconstruidos: la
  aclaración acumulada produjo las nueve operaciones de Cliente/Producto sin
  perder atributos, y una instrucción sin tipos infirió `Integer`, `String`,
  `Decimal`, `Date` y `Boolean` sin preguntar;
- `npm run test:api`: 99 pruebas de integración pasan, incluida la recuperación
  de una generación interrumpida;
- `npm run test:e2e`: 36 recorridos de navegador pasan;
- `npm run test:bank`: siete backends Spring generados compilan, arrancan y
  completan persistencia y operaciones CRUD contra PostgreSQL;
- `npm run test:dart`: siete capas Dart pasan análisis estático;
- `flutter analyze` y `flutter test`: sin hallazgos y 31 pruebas pasan;
- `npm run build` y `npm run db:validate`: construcción completa y esquema
  Prisma válidos.

La construcción web aún avisa que el paquete principal minificado mide cerca de
656 kB; debe dividirse antes de considerar cerrada la optimización de carga.
`npm audit` informa tres hallazgos altos que representan la misma cadena de
desarrollo (`prisma -> @prisma/config -> deepmerge-ts 7.1.5`). La solución que
propone npm es bajar Prisma 7.10 a 6.12, un cambio mayor que no se aplicó a
ciegas. Las imágenes de ejecución instalan dependencias de producción y durante
su construcción informaron cero vulnerabilidades; aun así debe actualizarse la
cadena cuando Prisma publique/valide una combinación compatible.

---

## 1. Resultado del contraste

### 1.1 Lo que ya está cubierto

| Capacidad del proyecto anterior | Estado aquí | Diferencia relevante |
|---|---|---|
| Registro, inicio y cierre de sesión | Implementado | Sesión propia con acceso y refresco rotativo |
| Crear, abrir, renombrar y eliminar proyectos/pizarras | Implementado | Un proyecto contiene varias pizarras |
| Compartir una pizarra | Implementado | Invitaciones con OWNER, EDITOR y VIEWER |
| Edición colaborativa | Implementado | CRDT, presencia y autorización también en WebSocket |
| Editor manual de clases, atributos y relaciones | Implementado | Validación de errores y avisos antes de generar |
| Asistente por texto y voz | Implementado con reserva | El entorno de demostración todavía usa el adaptador `mock` |
| Importación por imagen o boceto | Implementado con reserva | La vista previa básica ya es editable; faltan roles, validación reactiva y una IA real |
| Generación Spring Boot | Implementado | Banco T01-T07R, OpenAPI, Postman y Compose |
| Generación para Flutter | Decisión diferente | Se genera la capa de datos Dart, no pantallas ni navegación |
| Exportación de proyecto comprimido | Implementado | ZIP regenerado desde un snapshot |
| Prueba del backend con Postman | Implementado | La colección viaja dentro del ZIP |

### 1.2 Aportes que sí mejoran el proyecto

| Aporte | Valor para esta plataforma | Prioridad en fase 11 |
|---|---|---|
| Copia JSON exacta de la pizarra | Recuperación rápida durante la defensa | P1 |
| Historial de versiones y restauración | Recupera errores humanos sin depender de un archivo local | P1 |
| Candidato de importación editable antes de aplicar | Cierra RF-042 y ADR-012 de verdad | P0 |
| Vista del código generado por capas | Permite revisar y explicar antes de descargar | P1 |
| Manifiesto inmutable de generación | Corrige parámetros perdidos y descargas históricas variables | P0 |
| Arreglo N:M con entidad intermedia en un clic | Convierte un error bloqueante en una acción guiada | P1 |
| Manual de usuario reproducible | Entregable y guion de la demostración | P1 |
| Casos de uso, secuencias y trazabilidad | Completa la documentación académica sin duplicar requisitos | P1 |
| Bloqueo temporal de pizarra | Útil al exponer o revisar en grupo | P2 |
| Indicador de zoom y mejoras de accesibilidad | Mejora orientación y uso proyectado | P1/P2 |

### 1.3 Ideas del antecedente que no se copian

| Idea | Decisión |
|---|---|
| Generar una aplicación Flutter completa | No entra. ADR-011 limita la salida móvil a la capa de datos porque el frontend se construye en vivo. |
| Editar Java generado dentro de la plataforma | No entra en esta fase. Introduciría un segundo IDE, mezcla código manual con regeneración y abre conflictos que el modelo canónico no puede resolver. Se adopta una vista **solo lectura** por capas. |
| Autenticación obligatoria con Google | No entra. Contradice el alcance de autenticación propia mínima y añade una dependencia externa a la demostración. |
| Guardar todos los ZIP o cada archivo generado en la base | No entra por defecto. Se conserva ADR-018, pero se completa el manifiesto necesario para regenerar exactamente. Si no puede garantizarse, se reconsiderará almacenar el artefacto. |
| Roles globales de diseñador, desarrollador y colaborador | No entra. Los permisos por proyecto son más precisos y ya están autorizados en HTTP y WebSocket. |
| Bloqueo duro por elemento durante edición concurrente | No entra. El CRDT debe seguir aceptando concurrencia; se mejora la indicación de presencia, no se reemplaza por exclusión pesimista. |
| Más tipos de diagramas UML | Fuera de alcance. Enterprise Architect recibe el XMI para continuar allí con secuencia u otros diagramas. |

---

## 2. Objetivo de la fase

Convertir el incremento actual, que ya demuestra el flujo principal, en una
versión recuperable, reproducible y defendible:

```text
modelo vivo
   -> candidato realmente revisable
   -> versión recuperable
   -> generación con manifiesto inmutable
   -> vista previa por capas
   -> ZIP reproducible
   -> manual y evidencia trazable
```

La fase no agrega otro núcleo. Reutiliza el modelo canónico, los lotes atómicos,
el documento Yjs, los snapshots y los generadores existentes.

---

## 3. Alcance ejecutable

## 3.1 F11-00 - corregir la fuente documental de verdad

**Prioridad:** P0  
**Coste:** bajo

Antes de añadir funcionalidad, la documentación debe dejar de afirmar como
cerrado lo que sigue sin comprobarse.

### Cambios documentales previstos

- `README.md`: separar `implementado`, `probado automáticamente`, `validado en
  herramienta externa` y `ensayado en hardware real`.
- `docs/pendientes.md`: no afirmar que no falta ninguna fase mientras sigan
  abiertas las validaciones de EA, teléfono, IA real y ensayo completo.
- `docs/requirements/README.md`: actualizar la nota antigua que todavía presenta
  la persistencia de auditoría como pendiente.
- `docs/comparacion-manual.md`: retirar afirmaciones absolutas sobre auditoría,
  XMI real, modo avión y reproducibilidad histórica hasta tener evidencia.
- `docs/adr/ADR-012-importacion-como-candidato-editable.md`: resolver la
  contradicción entre “editable antes de aplicar” y “se corrige después de
  aplicarlo”.
- `docs/adr/ADR-018-artefactos-no-se-almacenan.md`: documentar todos los datos
  que deben congelarse para poder prometer el mismo artefacto.
- `docs/despliegue.md` e `infra/compose.yml`: alinear las variables de IA que el
  instructivo pide con las que realmente recibe el contenedor.

### Criterio de aceptación AC-11.00

Una búsqueda de cada requisito P0/P1 lleva a un único estado y a evidencia
concreta. Ningún documento dice “completo” si su única prueba está omitida o
depende de un dispositivo todavía no usado.

---

## 3.2 F11-01 - candidato de importación realmente editable

**Prioridad:** P0  
**Coste:** medio

La primera iteración ya permite corregir nombres, tipos, nulabilidad, claves y
multiplicidades. Todavía falta cerrar la edición de roles, la eliminación de
operaciones y la validación reactiva para considerar completo RF-042.

### Resultado esperado

- La imagen o XMI produce un modelo temporal separado de la pizarra viva.
- Se pueden corregir nombres, tipos, nulabilidad, multiplicidades y roles antes
  de aplicar.
- Los avisos del parser o proveedor quedan vinculados al elemento afectado.
- El usuario ve el resultado de la validación sobre el candidato.
- `Aplicar` genera un único lote contra el estado actual.
- Si la pizarra cambió mientras se revisaba, el lote se vuelve a resolver; no se
  sobrescriben cambios de otra persona silenciosamente.

No hace falta duplicar React Flow. Una tabla estructurada de clases, atributos y
relaciones, con vista de resumen, es suficiente para esta fase.

### Áreas afectadas

- `frontend/src/features/import/ImportPanel.tsx`
- nuevo componente de revisión de candidato;
- contratos de propuesta en `shared/ai` y `shared/xmi`;
- resolver estructural y validación del dominio;
- pruebas de integración y navegador.

### Criterios de aceptación

- **AC-11.01.1:** cambiar `String` por `Integer` en el candidato modifica el lote
  aplicado, sin tocar la pizarra antes de pulsar `Aplicar`.
- **AC-11.01.2:** descartar deja el documento Yjs byte a byte sin cambios.
- **AC-11.01.3:** un candidato inválido muestra errores y no permite aplicar.
- **AC-11.01.4:** `REPLACE` sigue siendo todo o nada.

---

## 3.3 F11-02 - manifiesto y reproducibilidad de la generación

**Prioridad:** P0  
**Coste:** medio  
**Estado: hecho el 30 de agosto de 2026.** Diagnóstico confirmado punto por
punto contra el código; ver [ADR-018](adr/ADR-018-artefactos-no-se-almacenan.md),
enmienda. Los cuatro criterios de aceptación tienen prueba de integración con su
nombre.

El snapshot semántico está congelado, pero no todos los datos de entrada. Hoy el
`basePackage` introducido en la interfaz no se guarda; la descarga histórica
reconstruye con el nombre actual de la pizarra y con la versión actual de las
plantillas. Dos descargas futuras pueden dejar de representar la misma decisión
de generación.

> **Lo que se encontró al implementarlo.** El `basePackage` no es que «se pueda
> perder»: se perdía siempre. La interfaz lo aceptaba, la respuesta lo incluía y
> **ninguna** descarga lo llevaba, porque la ruta de descarga construía la
> representación intermedia sin él. La prueba que existía comprobaba que la
> petición se aceptaba, no que el ZIP tuviera el paquete.
>
> Y la concurrencia era peor de lo previsto. La primera corrección —calcular la
> versión dentro del `INSERT`— **no** sirvió: en el nivel de aislamiento por
> defecto, dos transacciones no ven la fila que la otra no ha confirmado, así que
> las dos calculan el mismo número. Con cuatro peticiones simultáneas seguían
> saliendo dos `500`. Se resolvió bloqueando la fila de la versión viva mientras
> se decide el número: las generaciones de la misma pizarra se ponen en fila, las
> de pizarras distintas no se estorban.

### Manifiesto mínimo

Cada generación debe congelar:

- `boardId` y `snapshotVersion`;
- nombre de proyecto usado para generar;
- `artifactId` y `basePackage`;
- versión del esquema canónico;
- versión del generador y huella de las plantillas;
- fecha y autor;
- objetivos disponibles (`spring`, `dart`);
- hash SHA-256 del ZIP emitido por objetivo;
- estado `CREATING`, `READY` o `FAILED`, con error saneado si corresponde.

El manifiesto permite mantener ADR-018 sin almacenar el ZIP. Si una versión del
generador ya no está disponible y el hash cambia, la descarga debe decirlo; no
entregar un archivo distinto bajo el mismo identificador.

### Correcciones asociadas

- ✅ Crear la versión de snapshot de forma transaccional; dos generaciones
  simultáneas no producen un `500`.
- ✅ No registrar una generación como exitosa antes de comprobar que el artefacto
  se puede emitir: la fila nace `CREATING` y solo pasa a `READY` cuando los dos
  objetivos se han emitido de verdad.
- ⏳ Definir retención de snapshots: conservar los referenciados por generaciones
  y una ventana limitada de versiones manuales. **Sigue pendiente**, y ahora
  crecen algo más rápido: cada generación deja su versión congelada. Sobre un
  modelo de treinta clases son decenas de kilobytes y la defensa dura una tarde
  ([`pendientes.md`](pendientes.md) §2.3).

### Criterios de aceptación

Los cuatro están cubiertos por pruebas de integración con ese mismo nombre en
[`generation.integration.test.ts`](../backend/api/tests/integration/generation.integration.test.ts).

- **AC-11.02.1:** ✅ un paquete `bo.edu.demo` aparece en el ZIP inmediato y en una
  descarga posterior — con otra generación de otro paquete por medio, para que la
  prueba distinga «lo congeló» de «coincide con la última».
- **AC-11.02.2:** ✅ renombrar la pizarra no cambia nombre, contenido ni hash de
  una generación anterior. Se compara byte a byte.
- **AC-11.02.3:** ✅ cuatro solicitudes simultáneas crean cuatro versiones
  distintas, nunca un error interno por clave duplicada.
- **AC-11.02.4:** ✅ dos descargas del mismo objetivo producen el mismo SHA-256, y
  coincide con el registrado al generar.

Además: una generación cuyos bytes ya no se pueden reproducir responde 409
`artifact_drifted` en vez de entregar otro archivo, y una `FAILED` no se descarga
y dice por qué.

---

## 3.4 F11-03 - recuperación JSON y versiones de usuario

**Prioridad:** P1  
**Coste:** medio

El manual anterior aporta una red de seguridad local; el examen añade gestión de
versiones con guardar, visualizar y restaurar. Son necesidades relacionadas, pero
no idénticas.

### A. Exportar e importar una copia JSON

- Exportar `BoardState` completo: versión de esquema, semántica, layout y
  metadatos mínimos.
- Validar con `boardStateSchema` antes de mostrar la vista previa.
- `REPLACE` debe conservar UUID y posiciones cuando el archivo pertenece a esa
  pizarra o está libre de colisiones.
- `ADD` debe definir una política explícita: conservar UUID libres y remapear
  colisiones, actualizando relaciones y layout en el mismo lote.
- Rechazar versiones futuras del esquema con un mensaje que indique qué versión
  puede leer la aplicación.

La copia JSON es una función de recuperación, no sustituye XMI. XMI sigue siendo
el formato de interoperabilidad con Enterprise Architect.

### B. Puntos de restauración dentro de la plataforma

- Crear versión manual con nombre opcional, autor y fecha.
- Listar versiones manuales y snapshots usados en generaciones.
- Ver resumen: clases, atributos, relaciones y diferencias respecto al estado
  actual.
- Restaurar mediante un lote atómico, nunca escribiendo directamente una
  proyección JSON sobre el documento colaborativo.
- Crear automáticamente un punto de restauración del estado anterior.

### Criterios de aceptación

- **AC-11.03.1:** exportar, vaciar e importar recupera UUID, relaciones y
  posiciones.
- **AC-11.03.2:** JSON manipulado se rechaza sin aplicar cambios parciales.
- **AC-11.03.3:** restaurar una versión llega a dos navegadores sin recargar.
- **AC-11.03.4:** después de restaurar se puede volver al estado previo.

---

## 3.5 F11-04 - vista del código por capas

**Prioridad:** P1  
**Coste:** medio-bajo

El antecedente propone editar el código en la plataforma. Para este proyecto se
adopta solo la parte de valor: **inspeccionarlo antes de descargar**.

### Resultado esperado

- Árbol de archivos de la generación seleccionada.
- Filtros por entidad, DTO, repositorio, servicio, controlador, configuración,
  OpenAPI/Postman y capa Dart.
- Visor de texto solo lectura con copia al portapapeles.
- Descarga de un archivo individual y del ZIP completo.
- La vista usa el mismo manifiesto y snapshot que la descarga; no genera contra
  el estado vivo.
- Límites de tamaño y rutas permitidas para que el visor no exponga archivos del
  servidor.

### Criterios de aceptación

- **AC-11.04.1:** seleccionar `ClienteController.java` muestra exactamente los
  bytes que contiene el ZIP.
- **AC-11.04.2:** editar la pizarra después de generar no cambia la vista de esa
  generación.
- **AC-11.04.3:** un VIEWER puede revisar y descargar, pero no crear una nueva
  generación.

---

## 3.6 F11-05 - acciones guiadas y experiencia del editor

**Prioridad:** P1 para N:M y accesibilidad; P2 para detalles cosméticos  
**Coste:** medio

### Resolver N:M con una entidad intermedia

El error `MANY_TO_MANY_RELATIONSHIP` debe ofrecer `Crear entidad intermedia`.
La acción genera en un solo lote:

1. la clase asociativa con nombre editable;
2. dos relaciones N:1;
3. los roles derivados, también editables;
4. el borrado de la relación N:M original.

No se genera una N:M directa ni se inventan atributos de negocio. El usuario
puede agregar después los atributos de la asociación.

### Mejoras de UX tomadas de la fundamentación del examen

- indicador de zoom en porcentaje y acción `Ajustar al contenido`;
- navegación por teclado de controles críticos;
- nombre accesible para botones de icono y estados no comunicados solo por color;
- foco visible y retorno del foco tras cerrar diálogos;
- mensajes con acción concreta, no solo “algo salió mal”;
- prueba responsive para portátil de aula y proyector;
- estado visible del proveedor de IA: `real`, `respaldo` o `simulado`.

### Criterios de aceptación

- **AC-11.05.1:** arreglar una N:M elimina el error y habilita generación sin
  dejar operaciones parciales.
- **AC-11.05.2:** el flujo login -> proyecto -> pizarra -> generar se completa
  solo con teclado.
- **AC-11.05.3:** una revisión automatizada de accesibilidad no encuentra fallos
  críticos en login, proyectos y editor.

---

## 3.7 F11-06 - control colaborativo y auditoría confiable

**Prioridad:** P1 para permisos/auditoría; P2 para bloqueo temporal  
**Coste:** medio-alto

### Permisos vivos

Cambiar un EDITOR a VIEWER o quitarlo del proyecto debe afectar las conexiones
WebSocket ya abiertas. No basta con aplicar el nuevo rol al reconectar.

Opciones aceptables:

- invalidar las conexiones del usuario afectado para que vuelvan a autorizarse;
- o propagar el cambio de permiso y convertir la conexión a solo lectura.

### Auditoría entregable

La interfaz registra el lote por HTTP después de aplicarlo y hoy puede perderlo
si esa petición falla. Para sostener “cada lote tiene actor” se necesita:

- cola de reintento local o confirmación persistente;
- estado visible si hay auditoría pendiente;
- idempotencia por `boardId + batchId`;
- registro estructurado de proyecto, pizarra, lote, comandos, actor y origen.

### Bloqueo temporal de pizarra - opcional

Solo el OWNER puede bloquear. Debe tener:

- motivo y autor visibles;
- vencimiento automático configurable;
- desbloqueo desde otra sesión del OWNER;
- aplicación inmediata a conexiones abiertas;
- lectura permitida y escritura rechazada también en el servidor.

### Criterios de aceptación

- **AC-11.06.1:** un editor degradado con la pizarra abierta no puede seguir
  escribiendo.
- **AC-11.06.2:** cortar la API al editar y recuperarla después termina con una
  única entrada de auditoría.
- **AC-11.06.3:** un bloqueo vencido nunca deja la pizarra inutilizable.

---

## 3.8 F11-07 - integración real y requisitos no funcionales

**Prioridad:** P0  
**Coste:** bajo en código, dependiente de herramientas y hardware

Este bloque no se sustituye con más pruebas simuladas.

### IA de texto y visión

- ~~Reenviar en Compose las variables de IA que el instructivo pide y el
  contenedor no recibía.~~ **Hecho el 30 de agosto de 2026.** Compose reenvía
  ahora la lista completa, las credenciales pasaron a ser por proveedor y cada
  puerto tiene su propio respaldo
  ([ADR-019](adr/ADR-019-pasarela-ia-credenciales-y-respaldo.md),
  [`despliegue.md`](despliegue.md) §1). Una prueba comprueba que
  `infra/.env.example` es configuración válida y que la cadena que documenta es
  la que el código construye, así que el instructivo no puede volver a
  divergir en silencio.
- ~~Decidir si `SpeechPort` tendrá adaptador real.~~ **Decidido: lo tiene.**
  Groq con respaldo en Cloudflare. Sigue sin ser el camino normal —el
  reconocimiento lo hace el navegador— pero deja de ser un puerto simulado
  donde el navegador no lo trae.
- Probar al menos tres imágenes reales: diagrama digital, boceto legible y
  entrada no interpretable. **Sigue pendiente:** los adaptadores nuevos están
  probados contra un `fetch` sustituido, que verifica la petición que se envía,
  no que el proveedor la entienda.
- Mostrar claramente cuándo respondió `mock`; nunca presentarlo como lectura
  real de la fotografía.

### Enterprise Architect

- Exportar dos o tres XMI desde EA 15 a `fixtures/xmi/`.
- Importarlos y verificar avisos.
- Abrir en EA un XMI nuestro.
- Registrar versión exacta, dirección probada y limitaciones.

### Móvil real

- Instalar el APK firmado para demostración.
- Descargar el modelo español antes de activar modo avión.
- Probar cadena completa: micrófono -> reconocimiento local -> intención ->
  SQLite -> cola -> reconexión -> backend generado.
- Definir IP y puerto con `API_BASE_URL`; no usar el 8080 de la plataforma.

### Mediciones pendientes

- RNF-01: P95 de propagación sobre varias decenas de cambios.
- RNF-02: cinco participantes reales o automatizados.
- RNF-03: React Flow con 30 clases, 100 atributos y 40 relaciones.
- RNF-04: alternar entre diez pizarras sin mezclar estado.
- Determinismo Dart y estabilidad de dos descargas por generación.

### Estabilidad del banco

- El comando oficial del móvil debe pasar sin depender de
  `--concurrency=1`, o debe declarar esa opción.
- El banco Spring debe esperar la liberación del puerto después de reiniciar.
- Ejecutar ambos comandos completos tres veces consecutivas antes de cerrar.

---

## 3.9 F11-08 - documentación de usuario y documentación académica

**Prioridad:** P1  
**Coste:** medio-bajo después de estabilizar la interfaz

El examen anterior dedica buena parte de su entrega a requisitos, casos de uso,
arquitectura, datos, implementación y pruebas. No se debe copiar esa extensión ni
duplicar el plan maestro, pero sí completar los artefactos que ayudan a demostrar
trazabilidad.

### Manual de usuario

Crear `docs/manual-usuario.md`, con capturas reproducibles en `docs/img/`:

1. registro, inicio y cierre de sesión;
2. proyectos, pizarras e invitaciones;
3. roles y presencia;
4. edición manual y validación;
5. asistente por texto y voz;
6. importación de imagen, XMI y JSON;
7. revisión del candidato;
8. versiones y restauración;
9. generación, vista por capas y descarga;
10. ejecución del backend y Postman;
11. app móvil en línea y modo avión;
12. solución de problemas: IA mock, puertos, red y permisos del micrófono.

Las capturas deben generarse desde Playwright con datos conocidos para que puedan
actualizarse cuando cambie la interfaz.

### Casos de uso actuales

Crear `docs/casos-uso.md` sin inventar actores globales. Para cada flujo principal:

- propósito;
- actor iniciador y permisos;
- precondiciones;
- flujo normal;
- alternativas y errores;
- postcondición;
- requisitos y pruebas relacionadas.

Casos mínimos: sesión, proyecto, invitación, edición, colaboración, asistente,
importación, versionado, generación y sincronización móvil.

### Arquitectura y datos

- Diagrama de contexto: persona, navegador, móvil, IA, EA y backend generado.
- Diagrama de contenedores: web, API, colaboración y PostgreSQL.
- Secuencias: edición colaborativa, importación revisada, generación congelada y
  sincronización móvil.
- ERD derivado de Prisma, no dibujado manualmente con otra fuente de verdad.
- Tabla de volumen estimada para documentos Yjs, snapshots, auditoría y
  generaciones, con política de retención.

### Matriz de trazabilidad

Crear una tabla generable:

```text
requisito -> criterio de aceptación -> módulo -> prueba -> estado -> evidencia externa
```

No duplicar descripciones completas; enlazar al plan maestro. La matriz sirve para
detectar requisitos que dicen “completo” sin una prueba o medición.

### Criterio de aceptación AC-11.08

Una persona que no desarrolló el sistema completa el guion principal usando solo
el manual, y un revisor puede partir de cualquier RF P0/P1 y llegar a su prueba o
a un pendiente explícito.

---

## 4. Orden de implementación

### Fase 11A - verdad y cierre de riesgos P0

1. F11-00: corregir estados documentales.
2. F11-02: manifiesto de generación y concurrencia.
3. F11-01: candidato editable.
4. F11-07: IA real, EA, teléfono, métricas y estabilidad de pruebas.
5. Ensayo completo con el reparto de puertos definitivo.

### Fase 11B - recuperación y explicación del resultado

1. F11-03A: copia JSON exacta.
2. F11-04: vista de código por capas.
3. F11-03B: versiones manuales y restauración.
4. F11-05: arreglo N:M y accesibilidad.
5. F11-08: manual y documentación académica.

### Fase 11C - colaboración adicional, solo si 11A y 11B están verdes

1. permisos vivos y auditoría confiable de F11-06;
2. bloqueo temporal de pizarra;
3. indicador de zoom y mejoras cosméticas restantes.

El bloqueo temporal no debe desplazar EA, teléfono, IA real, generación
reproducible ni ensayo completo.

---

## 5. Definition of Done de la fase 11

La fase está completa cuando:

- [ ] los PDF de referencia están reflejados como antecedente, no como requisitos
      automáticos;
- [ ] la documentación no contiene estados contradictorios;
- [ ] el candidato de imagen y XMI se corrige antes de aplicar (campos básicos
      hechos; faltan roles, eliminación y validación reactiva);
- [ ] una generación conserva todos sus parámetros y hash;
- [ ] JSON recupera semántica, identidad, relaciones y layout;
- [ ] existe al menos un punto de restauración reversible;
- [ ] el código puede revisarse por capas sin salir de la plataforma;
- [ ] la relación N:M tiene una reparación guiada y atómica;
- [x] los cambios de rol afectan conexiones abiertas;
- [x] la auditoría reintenta y no pierde lotes en cortes controlados;
- [ ] IA real, EA 15 y teléfono en modo avión tienen evidencia fechada;
- [ ] RNF-01 a RNF-04 tienen medición reproducible;
- [ ] `npm run check`, `npm run test:api`, `npm run test:e2e`,
      `npm run test:bank`, `npm run test:dart` y `npm run mobile:test` pasan
      completos;
- [ ] el APK se construye con la URL y firma previstas para la demostración;
- [ ] el manual de usuario fue probado por una persona ajena al desarrollo;
- [ ] el ensayo 16.2 se completó de principio a fin y quedó registrado el tiempo.

---

## 6. Decisiones que esta fase debe registrar

Si se implementan, requieren ADR o enmienda explícita:

1. formato y política de identidad para copia JSON;
2. modelo de versiones manuales y retención de snapshots;
3. contenido del manifiesto de generación y estrategia ante versiones antiguas
   del generador;
4. representación temporal del candidato editable;
5. propagación de cambios de permisos a WebSocket abiertos;
6. semántica, vencimiento y recuperación del bloqueo de pizarra.

Una función no se da por cerrada porque tenga interfaz. Debe conservar las
invariantes del modelo canónico, funcionar en colaboración y tener una prueba que
recorra el mismo camino que usará la persona durante la defensa.
````

---

### `docs/apariencia-2026-09-10.md`

```markdown
# Apariencia y temas — 10 de septiembre

Se revisaron acceso, proyectos, editor, propiedades y observaciones. La presentación usa tipografías IBM Plex servidas localmente con sus licencias, jerarquía tipográfica, listas de proyectos y menos recuadros decorativos. Las observaciones ajustan sus líneas sin desplazamiento horizontal.

## Modos de apariencia

- **Claro:** superficies cálidas y acento verde sobrio.
- **Oscuro:** grises neutros inspirados en Dark de VS Code, lienzo `#1e1e1e`, paneles `#252526` y acento azul. Sustituye la primera propuesta de oscuro verdoso tras la revisión del usuario.
- **Sistema:** sigue `prefers-color-scheme`, incluidos los cambios con la aplicación abierta.

El menú de apariencia está disponible en acceso, proyectos, cuenta y editor. Usa iconos y una marca de selección; admite flechas, Inicio/Fin, Enter y Escape. Cierra al pulsar fuera o abandonar el control con Tab. La preferencia se guarda en `localStorage`, se sincroniza entre pestañas y funciona en la pestaña actual aunque el navegador restrinja el almacenamiento. Un script previo al renderizado evita el destello del tema opuesto.

El cambio de tema no remonta la pizarra ni altera el documento colaborativo. Los colores del lienzo, controles, relaciones y clases siguen la apariencia elegida. Los formatos de exportación conservan su comportamiento.

## Comprobación

TypeScript, ESLint, formato y compilación web aprobados. La suite completa inicial obtuvo 92 aprobaciones y detectó un fallo de tamaño táctil en móvil horizontal: el botón medía 36 px. Se corrigió a 44 px en ese tamaño y se volvieron a aprobar las seis resoluciones móviles.

Las pruebas de apariencia cubren persistencia, cambios del sistema, sincronización entre pestañas, almacenamiento restringido, teclado del menú, ausencia de desbordamiento y conservación del diagrama. **20/20 pruebas finales en Docker aprobadas**, incluyendo apariencia, seis tamaños móviles y regresiones de colaboración/XMI. Capturas y resultados locales en `reports/apariencia/`, ignorados por Git; resultado final en `docker-final.xml`.

Se reconstruyó y actualizó únicamente el servicio web. API, colaboración, base de datos y volúmenes se conservan.
```

---

### `docs/auditoria-2026-09-05.md`

```markdown
# Auditoría consolidada — 5 de septiembre de 2026

**Estado: el núcleo web y la generación Spring Boot están implementados y verificados; la entrega aún tiene validaciones externas pendientes y el despliegue público necesita robustecimiento.** No corresponde presentar la aplicación como completamente terminada ni libre de vulnerabilidades.

Este informe reúne las correcciones de la auditoría y su continuación sobre el código del commit `5bfbfdf`. Conserva las mejoras ya incorporadas, incluidas las de interfaz táctil. La [revisión anterior](estado-aplicacion-2026-09-05.md) contiene evidencia adicional de regresiones y del proxy Vite; los resultados finales de esta continuación se indican aquí.

## Alcance y limpieza

Se revisaron cuentas y recuperación, proyectos e invitaciones, autorización HTTP y WebSocket, persistencia PostgreSQL/Yjs, editor, importación y exportación, IA, auditoría, generación, pruebas y contenedores. El alcance actual es **web adaptable a móviles + generador Spring**. La aplicación nativa y el generador Dart fueron retirados; una página usable en un teléfono no sustituye esos entregables si todavía los exige el docente.

La separación del dominio, contratos, representación intermedia y adaptadores permite probar las reglas sin red ni base de datos. El generador tiene pruebas de determinismo y ejecución real. Formato, lint y tipos pasan. Como deuda de mantenimiento quedan componentes grandes del editor y rutas que mezclan coordinación HTTP con operaciones Prisma; no requieren una reescritura para cerrar la demostración.

La documentación anterior tenía resultados y tareas móviles obsoletos. Se actualizó la lista de pendientes. El plan maestro bajo `docs/referencia/` está excluido de Git: un clon nuevo no contiene esa referencia y necesita una copia autorizada del alcance vigente.

## Defectos corregidos y comprobados

| Área | Fallo y resultado de la corrección | Evidencia |
|---|---|---|
| Sesión y cambio de cuenta | Se impide que respuestas tardías, reintentos de JSON o descargas XMI/ZIP iniciadas por una cuenta continúen con otra. Un refresh tardío tampoco restaura una sesión cerrada. | `frontend/tests/api.test.ts`, pruebas de sesión en navegador. |
| Renovación entre pestañas | Se comparte el refresh en vuelo y se serializa entre pestañas mediante Web Locks cuando está disponible. | Regresión de renovación y recarga simultánea de dos pestañas. |
| Cola de auditoría | Cada cuenta envía únicamente sus lotes. Un lote de una pizarra eliminada o sin acceso no bloquea el envío de los demás; los errores de envío en segundo plano se controlan. | Regresiones de aislamiento y cola bloqueada en `api.test.ts`. |
| Recuperación de contraseña | El consumo del enlace y el cambio de clave son atómicos. Recuperaciones simultáneas no pueden ganar las dos; cambiar la clave invalida enlaces anteriores. La interfaz abandona la sesión previa tras restablecer. | 21 pruebas de integración de perfil y regresión de navegador. |
| Permisos colaborativos | Antes de procesar sincronizaciones se revisan también los receptores conectados. Un miembro retirado o con JWT vencido deja de recibir nuevas ediciones; degradar a lector bloquea escritura. | 16 pruebas de colaboración, incluyendo miembros pasivos y caducidad. |
| Persistencia colaborativa | La comprobación de permisos conserva la última actualización recibida aunque el cliente se desconecte mientras se consulta la base. | Regresión de persistencia y reconexión. |
| Endpoint de sincronización | `/flush` rechaza cuerpos JSON inválidos, nulos o de tipo incorrecto con 400. | 12 pruebas unitarias de salud/entrada del proceso colaborativo. |
| Pizarra y generaciones | Consultar una pizarra usa la proyección viva, en lugar del snapshot histórico más reciente creado al generar. El ZIP conserva su snapshot inmutable. | Integración de generación. |
| Invitaciones concurrentes | Aceptar el mismo código simultáneamente no provoca errores 500 ni duplica membresías. | Integración de proyectos. |
| Importación a través de Nginx | El límite implícito de 1 MiB bloqueaba archivos aceptados por la API. El proxy admite ahora 24 MiB y un tiempo de espera mayor para visión. | Importación XMI de más de 1 MiB desde el navegador. |
| Errores del proveedor de IA | Un fallo al leer el cuerpo HTTP entra en el mecanismo de reintentos y de proveedor no disponible. | Tres regresiones de transporte en `shared/ai/tests/http.test.ts`. |
| Navegación | Las cargas fallidas de proyectos muestran error recuperable; la recuperación de cuenta vuelve al acceso. El proxy Vite elimina los prefijos correctos. | Pruebas de ruta inexistente, sesión y verificación previa de Vite. |
| Carga inicial | El editor se carga bajo demanda. JavaScript inicial: aproximadamente 331 kB, 99 kB comprimidos; antes eran aproximadamente 705 kB y 215 kB. | Build Vite final; el editor añade su propio bloque al abrirse. |
| Prueba de carga | Se corrigieron la multiplicidad de la muestra y la selección de la clase antes de moverla con teclado. | RNF-03 verifica 30 clases, 100 atributos y 40 relaciones en dos navegadores. |
| Interfaz móvil | A 320/360 px se desbordaba la cabecera; los participantes interceptaban «Salir» y algunos controles quedaban recortados. La cabecera distribuye identidad, acciones y estado, el acceso ajusta su ancho y el panel inferior usa todo el ancho del teléfono. | Los seis recorridos táctiles pasan; revisión de capturas a 320 px. Cambios en `frontend/src/styles.css`. |
| Enlaces de recuperación locales | La web funciona en 8080, pero `WEB_ORIGIN` apuntaba a 5173. Se ajustó el origen a `http://localhost:8080` en el entorno local y se recreó la API. | Configuración efectiva del contenedor; `infra/.env` permanece fuera de Git. |

La revocación WebSocket anterior ocurre al procesar sincronizaciones, no mediante un temporizador de expulsión instantánea. Las correcciones están respaldadas por regresiones; eso no equivale a demostrar ausencia de cualquier otro defecto.

## Verificación final

| Comprobación | Resultado |
|---|---|
| `npm run check` | Formato, ESLint y TypeScript correctos; **352 pruebas pasan**. La muestra real de Architect se procesa con avisos explícitos para clases asociativas y conectores auxiliares. |
| `npm run test:api` | **126 pruebas pasan**, con PostgreSQL efímero y WebSocket real. |
| `npm run build` y `npm run db:validate` | Compilación completa y esquema correctos. |
| Reconstrucción Docker | API, colaboración, migraciones y web reconstruidos en el proyecto aislado `uml-audit`. |
| Playwright contra Nginx y contenedores actuales | **68 escenarios distintos verificados:** 62 de escritorio y 6 táctiles; detalle de las pasadas debajo. |
| Banco de backends generado, ejecutado durante esta auditoría | **8 modelos**: T01–T06, T07R y T08; compilación Java 21/Maven, PostgreSQL, OpenAPI, CRUD, reinicio y restricciones de borrado. |
| Cinco participantes, 30 cambios | P95 de propagación **39,4 ms** en la última ejecución. Es loopback y excluye el render del navegador; no acredita la red del aula. |
| Diez pizarras | Aislamiento de estados verificado en integración. |
| `npm audit` | **4 paquetes afectados de severidad alta**, 0 críticos; siguen pendientes. |

La muestra de Enterprise Architect proporcionada ya se procesa en las pruebas del repositorio. Las pruebas de IA del entorno aislado utilizan adaptadores `mock`; la API, los permisos, los contenedores y PostgreSQL son reales. En una pasada anterior con Gemini real hubo respuestas válidas, pero también seis fallos de expectativas o tiempo de espera en la suite pensada para mocks. Esto requiere una aceptación específica con fotografías y consultas reales; no permite concluir que toda la integración de IA esté rota ni que ya esté validada.

La pasada completa de esta continuación terminó con **66 aprobadas y 2 fallidas**,
ambas de distribución móvil a 320/360 px. Después de corregir exclusivamente el
CSS adaptable se repitieron los seis recorridos táctiles: **6/6 aprobados en 24,8 s**,
sin omisiones ni reintentos. Los otros 62 recorridos ya estaban aprobados; no se
presentan estos resultados como una única pasada de 68 después del cambio CSS.
Los tamaños táctiles son 320×568, 360×800, 390×844, 430×932, 768×1024 y 844×390.
Es emulación Chromium, no validación de seis dispositivos físicos.

## Qué falta para completar la aplicación

### Prioridad para cerrar la entrega

1. **Enterprise Architect 15:** importar un XMI suyo y abrir uno nuestro allí; guardar archivos y resultados como fixtures/evidencia. Es la interoperabilidad que las pruebas internas no pueden acreditar.
2. **Demostración real:** ejecutar el recorrido completo en los equipos previstos, con red del aula, micrófono y fotografía de un diagrama real. Separar puertos de plataforma y backend generado, por ejemplo 8080 y 8081.
3. **Configuración efectiva:** usar `WEB_ORIGIN` con la URL que realmente abrirán los usuarios. Se corrigió el entorno local de 5173 a 8080; en la red del aula o internet deberá usarse su URL correspondiente. El correo `log` no entrega emails; configurar y probar el proveedor si se demostrará esa función.
4. **Alcance acordado:** confirmar que la retirada nativa/Dart está reflejada en la entrega exigida. La interfaz web táctil sí forma parte del código actual.
5. **Criterios todavía sin cierre:** completar contexto de registros RNF-14 y añadir la comprobación explícita de CA-068.2 sobre la configuración externa del proyecto generado.

### Funciones incompletas o mejoras de producto

| Pendiente | Estado actual | Criterio de cierre |
|---|---|---|
| Administración de miembros e invitaciones | La API tiene operaciones de roles, retirada y revocación; la web permite crear códigos pero no ofrece toda esa administración. | El propietario puede listar, modificar y retirar accesos desde la interfaz; una segunda sesión respeta el cambio. |
| Edición del candidato importado | Se pueden corregir nombres, tipos, nulabilidad, claves y multiplicidades. | Añadir roles, descarte de operaciones y validación reactiva antes de aplicar. |
| Copias y restauración para el usuario | Hay XMI y snapshots de generaciones; no hay copia/restauración JSON ni restauración de versiones desde la interfaz. | Recuperar un modelo de prueba sin depender de acceso a PostgreSQL. |
| Trabajo sin conexión prolongada | Se recuperan desconexiones transitorias con la pestaña abierta. La cola local guarda auditoría, no el documento Yjs completo. | Si se ofrece modo offline, persistir y recuperar el diagrama tras cerrar o recargar sin red. |
| Auditoría rechazada | Los lotes se conservan, pero no hay pantalla para recuperar o descartar errores permanentes. El almacenamiento compartido entre pestañas necesita más robustez. | Mostrar los lotes y su causa, permitir recuperación y probar escrituras concurrentes de la cola. |
| Reparación muchos a muchos | Se detecta el modelo no generable y se explica la entidad intermedia. | Si se incluye en el alcance, ofrecer una reparación guiada y atómica. |
| Accesibilidad y otros navegadores | Hay interacción por teclado y pruebas táctiles; no una auditoría WCAG completa ni pruebas equivalentes en Safari/Firefox. | Revisar foco, lector de pantalla y dispositivos físicos, además de emulación Chromium. |

### Antes de una publicación pública

- **Dependencias:** los cuatro avisos se agrupan en la cadena `prisma → @prisma/config → deepmerge-ts/mysql2`. La imagen de ejecución de la API no instala esos paquetes, comprobado con `npm ls`; el entorno de herramientas/migración sigue afectado. El arreglo automático propone bajar Prisma 7 a 6, por lo que no se aplicó un cambio mayor incompatible. Resolver con versiones compatibles y repetir esquema, migraciones e integración. Referencias: [deepmerge-ts](https://github.com/advisories/GHSA-ggr8-5vv4-36mx), [descompresión mysql2](https://github.com/advisories/GHSA-rgwj-5xj2-c3m3), [autenticación mysql2](https://github.com/advisories/GHSA-3f6p-5ww8-9rcr).
- **Sesiones revocables:** cambiar/restablecer contraseña revoca refresh tokens; los JWT de acceso emitidos siguen válidos hasta caducar, por defecto 15 minutos. Añadir comprobación revocable en HTTP y WebSocket si se promete cierre inmediato de todas las sesiones.
- **Abuso y exposición:** limitar intentos de autenticación/recuperación y consumo costoso de IA/generación; configurar HTTPS, cookies seguras y cabeceras de seguridad. Los puertos de base/API/colaboración no necesitan estar expuestos públicamente.
- **Operación:** copias de seguridad y ensayo de restauración, límites de recursos, rotación de logs, alertas y retención de tokens/snapshots. Las sondas de salud no sustituyen un ensayo de recuperación.
- **Integridad de auditoría:** los cambios que pasan por el editor se registran, pero un cliente Yjs directo autorizado puede editar sin enviar el lote HTTP de auditoría. No presentar ese registro como una bitácora inviolable del servidor.

## Evidencia y reproducción

El [índice de pendientes](pendientes.md) resume el orden de trabajo. Los artefactos locales de las pasadas anteriores están en `reports/revision-2026-09-05/` y los de esta continuación en `reports/auditoria-2026-09-05/`; esas carpetas están excluidas de Git.

- `antes-movil/`: capturas y trazas de la pasada completa, incluidos ambos fallos reproducidos y el editor de 30 clases.
- `movil-final.json` y `movil-final/`: resultados y capturas de los seis recorridos táctiles corregidos.
- `npm-audit.json`: los avisos de dependencias vigentes al finalizar.

Se reconstruyeron también los servicios de la aplicación local en el puerto 8080
conservando el volumen PostgreSQL y ajustando únicamente `WEB_ORIGIN` al 8080. Los proveedores reales
configurados allí no se sustituyeron por mocks. El entorno `uml-audit` fue
exclusivamente el entorno de pruebas de esta auditoría.
Se retiraron sus contenedores y su volumen de datos sintéticos al terminar;
se conservaron las capturas y los informes. La web local, `/api/health` y
`/collab/health` respondieron 200 después de actualizar la configuración.

Para repetir las comprobaciones: `npm run check`, `npm run test:api`, `npm run build`, `npm run db:validate` y `npm run test:bank`. Para navegador, levantar los contenedores actuales con proveedores simulados y ejecutar `npm run test:e2e`, definiendo `E2E_BASE_URL` si no se usa el puerto 8080. La aceptación de proveedores reales debe ejecutarse por separado.
```

---

### `docs/auditoria-2026-09-09.md`

```markdown
# Auditoría de la aplicación — 9 de septiembre de 2026

Revisión posterior solicitada sobre colaboración y XMI: [hallazgos adicionales y estado actualizado](revision-colaboracion-xmi-2026-09-09.md). Los conteos de este documento corresponden a la primera ronda de correcciones.

La auditoría confirmó cinco defectos concretos, incluido uno que rompía la suite de integración. **B01–B05 ya están corregidos en el código del árbol de trabajo**, con pruebas de regresión. Esto no declara cerrado todo el proyecto: siguen pendientes las funcionalidades y verificaciones externas descritas más abajo.

Se auditó el árbol de trabajo existente, incluidos cambios sin commit. La fase inicial fue de diagnóstico; después se aplicaron las correcciones solicitadas, conservando los cambios previos. Las reproducciones iniciales están en `reports/audit-2026-09-09/` y las verificaciones de navegador de las correcciones en `reports/fixes-2026-09-09/` —directorios ignorados por Git—. El paquete Flutter utilizado en la revisión se generó en `generated-output/demo-ventas-ty1ZIh/`.

## Correcciones realizadas y verificación

| Bug | Corrección y regresión |
| --- | --- |
| B01 · Permisos desactualizados | La interfaz toma los permisos de la sesión colaborativa. El servidor notifica cambios de rol y el cliente consulta también cada cinco segundos y al recuperar el foco. Al perder escritura descarta su réplica local y carga una nueva desde el servidor, avisando de los cambios rechazados. Dos pruebas de navegador cubren degradación/ascenso de un participante pasivo y reconexión tras editar sin red. |
| B02 · Relaciones XMI omitidas | La deduplicación compara tipo, ambos roles y cardinalidades; solo permite invertir asociaciones simétricas. Reconoce los roles predeterminados escritos por el exportador para conservar la reimportación sin duplicados. Regresiones con T07R, extremos invertidos y cambios de tipo/cardinalidad. |
| B03 · Colisiones XMI bloqueadas | La resolución XMI conserva los nombres exactos para distinguir los elementos antes de editar el candidato. La fusión ADD dirige atributos y enlaces al nombre real de la clase existente. RF-052 comprueba clases con nombres técnicos coincidentes, sus atributos y el enlace entre ellas; la prueba de navegador corrige el nombre y aplica el candidato con dos usuarios. |
| B04 · Propuestas obsoletas | Antes de aplicar se comparan los elementos afectados con el modelo enviado al preparar la propuesta, incluyendo relaciones eliminadas indirectamente. Si cambiaron, se rechaza el lote, se retira el botón de aplicación y se recupera la instrucción para enviarla y revisarla de nuevo. Cinco pruebas de dominio y una de navegador cubren cambios relevantes y cambios ajenos que sí deben permitirse. |
| B05 · Límite de transcripción | La ruta acepta el máximo de 8.000.000 caracteres base64 más la envoltura JSON. Se prueban 1.100.000 y 8.000.000 caracteres aceptados, exceso de contrato con HTTP 400 y exceso del cuerpo con HTTP 413; las demás rutas mantienen su límite. |

Verificación posterior: **464/464 pruebas unitarias**, **129/129 pruebas de integración** y **80/80 recorridos de navegador** aprobados, incluidos los cuatro nuevos casos de regresión. TypeScript, ESLint, Prettier y compilación de producción aprobados. Las suites de API y navegador aislado usan PostgreSQL temporal y proveedores IA simulados; no acreditan inferencia real, micrófono ni dispositivos físicos.

También se reconstruyeron y actualizaron los contenedores locales `api`, `collab` y `web`, conservando PostgreSQL y sus datos, sin ejecutar migraciones. Los cuatro servicios quedaron saludables y `/`, `/api/health` y `/collab/health` respondieron HTTP 200 en `http://localhost:8080`. Las **4/4 regresiones nuevas** se repitieron satisfactoriamente contra ese despliegue con cuentas de prueba independientes; la propuesta de IA de ese recorrido se intercepta de forma determinista y no consume un proveedor real.

Comandos de verificación: `npm test`, `npm run test:api`, `npm run typecheck`, `npm run lint`, `npm run format:check`, `npm run build`; suite aislada mediante `node --import tsx reports/fixes-2026-09-09/run-current.mjs`; regresiones Docker mediante `node node_modules/@playwright/test/cli.js test --config e2e/playwright.config.ts auditoria-regresiones`. El ejecutor aislado y los resultados E2E están en el directorio local de evidencia; las pruebas nuevas están en `e2e/specs/auditoria-regresiones.spec.ts`, `shared/domain-core/tests/proposal-preconditions.test.ts` y las suites existentes de XMI e integración.

Los resultados de la sección siguiente son la evidencia **anterior a las correcciones**, conservada para contrastar el diagnóstico.

## Alcance y evidencia de esta ejecución

Se contrastaron el plan maestro local, los requisitos del docente del 6 de septiembre, los pendientes, el código y las pruebas. La revisión comprende cuentas, proyectos, permisos, editor, colaboración, IA, importación/exportación, generación Spring y base Flutter. Las verificaciones de PostgreSQL usaron contenedores temporales.

| Comprobación | Resultado de la auditoría inicial |
| --- | --- |
| TypeScript, ESLint y Prettier | Aprobados antes de añadir este informe |
| Compilación de los workspaces y frontend de producción | Aprobada |
| Pruebas rápidas | **455/455** aprobadas, 28 archivos |
| Integración HTTP y colaboración con PostgreSQL | **126/127** aprobadas; falla RF-052 de importación |
| E2E sobre los contenedores locales existentes y proveedores reales configurados | **71/76** aprobadas; cinco fallos por espera agotada en asistente/fotografía |
| E2E aislado: compilación actual, PostgreSQL temporal, API y colaboración reales, IA simulada | **76/76** aprobadas; 6,1 minutos |
| Banco Spring T01, T02, T03, T04, T05, T06, T07R y T08 | **8/8**: emisión, compilación, arranque, OpenAPI/Postman, CRUD, reinicio/persistencia y restricciones de borrado |
| Backend del paquete móvil | Aprobados login, renovación persistente, revocación por dispositivo/cambio de clave, CORS, CRUD, reintentos, reinicio y conflictos |
| Flutter recién generado: dependencias, análisis y pruebas | `flutter pub get` completado, `flutter analyze` sin incidencias y **18/18** pruebas aprobadas; no se compiló un APK nuevo ni se ejecutó GGUF físico |
| Reproducciones adicionales | Confirmados permisos desactualizados en UI, dos fallos XMI, propuesta obsoleta y límite de audio |
| Auditoría npm | Seis paquetes afectados: cuatro de severidad alta y dos moderada; cero críticos. Con `--omit=dev` siguen apareciendo cuatro altos |

Los fallos iniciales de Vitest/Vite por acceso denegado fueron restricciones del sandbox: al ejecutar con acceso autorizado pasaron. No se contabilizan como bugs. La repetición E2E aislada usa un proxy Vite sobre el frontend compilado; no acredita por sí sola una reconstrucción nueva de la imagen nginx. El recorrido inicial sí ejercitó el despliegue local existente.

Los cinco fallos de IA real no prueban cinco defectos distintos de interfaz: esas pruebas esperan respuestas y tiempos propios del adaptador simulado. Su resultado sí muestra que el entorno real necesita ensayo y diagnóstico antes de la defensa. No se acreditó la calidad de reconocimiento de una fotografía real ni de dictado físico.

## Defectos confirmados

P1 significa corregir antes de cerrar la entrega; P2, defecto de alcance más acotado. No se encontró un P0 que bloquee todos los recorridos principales.

### B01 · P1 · Permisos desactualizados producen cambios aparentes que se pierden

- **Reproducción:** propietario y editor abren la misma pizarra; el propietario cambia al editor a `VIEWER` mediante la API; el editor crea una clase.
- **Resultado:** “Nueva clase” sigue habilitado, la clase aparece localmente y el estado sigue mostrando “En vivo”. La auditoría recibe 403, el propietario no recibe esa clase y al recargar desaparece. Tras recargar los controles sí quedan deshabilitados.
- **Causa:** `BoardPage` consulta el rol al abrir la pizarra y `useBoardDocument.dispatch` conserva ese permiso. El servidor actualiza su autorización, pero el frontend no refleja el nuevo rol ni descarta/reconcilia la modificación rechazada.
- **Ubicación:** [BoardPage.tsx](../frontend/src/features/editor/BoardPage.tsx), líneas 80–99; [useBoardDocument.ts](../frontend/src/features/editor/useBoardDocument.ts), desde la línea 207.
- **Cierre:** comunicar/reconsultar cambios de permiso, deshabilitar edición y avisar de escrituras rechazadas. Probar degradación y expulsión con pestañas ya abiertas, además del acceso inicial como lector.
- **Evidencia:** `reproduction.json`, apartado `roleDowngrade`, y `role-downgrade.png`.

El control del servidor funcionó: este hallazgo es una inconsistencia de interfaz/estado local, no una demostración de escritura no autorizada en PostgreSQL.

### B02 · P1 · Importar XMI omite relaciones distintas entre el mismo par de clases

- **Reproducción:** usar T07R, conservar la relación `facturacion` entre Cliente y Order y quitar solo `envio`; importar en modo ADD el XMI completo.
- **Resultado:** el parser lee las cuatro relaciones, pero el conversor no emite ninguna operación de creación. El modelo actual tiene tres relaciones y no recupera la cuarta; se informa incorrectamente que la relación ya existe.
- **Causa:** la deduplicación compara solamente el par de clases en ambas direcciones. No compara los roles, el tipo ni las multiplicidades.
- **Ubicación:** [to-proposal.ts](../shared/xmi/src/to-proposal.ts), líneas 105–113.
- **Cierre:** identificar relaciones considerando sus extremos y semántica, conservar relaciones paralelas y distinguir “igual” de “diferente”. Añadir regresión de importación incremental con facturación/envío.
- **Evidencia:** `domain-reproduction.json`, apartado `parallelRelationship`.

### B03 · P1 · Colisiones de nombres en XMI dejan la importación sin camino de corrección

- **Reproducción:** importar en una pizarra vacía un XMI con `Detalle de Venta` y `detalle venta`, ambas normalizadas a `DetalleVenta`.
- **Resultado:** la API responde `QUESTION`; no hay candidato editable ni botón Aplicar. “Reintentar reemplazando” devuelve la misma pregunta aun sobre un modelo vacío.
- **Causa:** el resolver por nombres corta la conversión al encontrar la segunda clase. La UI de importación solo permite corregir un `BATCH`/`CONFIRMATION`; no puede responder ni editar el contenido de ese `QUESTION`.
- **Ubicación:** [resolver.ts](../shared/ai/src/resolver.ts), líneas 179–187; [ImportPanel.tsx](../frontend/src/features/import/ImportPanel.tsx), líneas 398–419.
- **Cierre:** preservar identidad de elementos XMI durante la preparación y ofrecer corrección de nombres antes de resolver/aplicar, o un flujo real para solucionar la colisión. Cambiar simplemente el esperado del test a `QUESTION` no resuelve el bloqueo de usuario.
- **Evidencia:** falla existente en [import.integration.test.ts](../backend/api/tests/integration/import.integration.test.ts), línea 190; `reproduction.json`, apartado `xmiCollision`; `xmi-collision.png`.

### B04 · P1 · Una propuesta obsoleta puede borrar trabajo añadido después de su preparación

- **Reproducción:** preparar una propuesta “Eliminar Cliente” cuando la clase está vacía; otro colaborador añade un atributo; aplicar la propuesta original.
- **Resultado:** el lote se acepta y elimina también el atributo nuevo, aunque el resumen revisado solo hablaba de la clase vacía. El alcance destructivo se calculó contra el estado anterior.
- **Causa:** el panel guarda comandos resueltos por ID y aplica directamente el lote. Su contador `revision` protege cambios de pizarra/desmontaje, no cambios semánticos de colaboradores.
- **Ubicación:** [AssistantPanel.tsx](../frontend/src/features/assistant/AssistantPanel.tsx), líneas 177–178; [resolver.ts](../shared/ai/src/resolver.ts), cálculo inicial del alcance destructivo.
- **Cierre:** comprobar antes de aplicar que los elementos afectados mantienen las precondiciones revisadas. Ante cambios, recalcular la propuesta y solicitar de nuevo la confirmación con el alcance vigente. No basta con verificar que siga existiendo el UUID.
- **Evidencia:** `domain-reproduction.json`, apartado `staleProposal`; reproducción directa del resolver y aplicador actuales, contrastada con el flujo del panel.

### B05 · P2 · El endpoint de transcripción rechaza audio permitido por su propio contrato

- **Reproducción:** enviar a `/assistant/transcribe` un cuerpo con 1.100.000 caracteres base64, por debajo del máximo declarado de 8.000.000.
- **Resultado:** HTTP 413 `fst_err_ctp_body_too_large` antes de llegar al proveedor.
- **Causa:** la ruta conserva el límite HTTP general de Fastify; la ruta de imagen sí declara un límite mayor.
- **Ubicación:** [routes.ts de IA](../backend/api/src/modules/ai/routes.ts), líneas 57–61 y 147.
- **Cierre:** alinear el límite HTTP con el contrato y verificar cuerpos justo por debajo/encima del límite.
- **Evidencia:** `reproduction.json`, apartado `audioLimit`. No se llamó al proveedor en esta reproducción.

El dictado web actual utiliza reconocimiento del navegador y no llama a este endpoint. Su impacto afecta al respaldo de transcripción de la API, no a todo el dictado existente.

## Riesgos y verificaciones adicionales

- **Dependencias:** `npm audit` señala `prisma`, `@prisma/config`, `deepmerge-ts`, `mysql2`, `vitest` y `@vitest/mocker`. Son seis paquetes afectados, no necesariamente seis vulnerabilidades independientes. Hay propagación de avisos por dependencias transitivas. El escaneo no demuestra explotación de la API desplegada; su Dockerfile instala un subconjunto y no se auditó el contenido de la imagen como SBOM. Revisar una actualización compatible, no aplicar automáticamente la degradación mayor de Prisma sugerida por npm. Los JSON completos están guardados en el directorio de evidencia.
- **Móvil con red lenta:** `AppModel.sync()` marca `busy=true` antes de verificar el contrato remoto; guardar/eliminar se bloquea mientras tanto y el temporizador repite sincronización cada 30 segundos. El cliente HTTP espera hasta 20 segundos por petición. Puede perjudicar el uso local con una conexión que no responde. Es un riesgo inferido del código, pendiente de reproducción temporal/dispositivo; no se incluye entre los cinco bugs confirmados.
- **Auditoría de operaciones:** la cola utiliza lecturas/escrituras de un JSON compartido en localStorage sin exclusión entre pestañas. Los rechazos permanentes se conservan, pero no existe una recuperación guiada. La auditoría depende del cliente HTTP y no cubre autoritativamente cualquier escritura de un cliente Yjs directo.
- **Historial de artefactos:** por diseño, los ZIP se regeneran desde snapshot/manifiesto. Si cambia el generador, una descarga antigua puede devolver `artifact_drifted`. Es una limitación conocida, no un defecto nuevo. Si se exige recuperar siempre exactamente los ZIP anteriores, falta almacenarlos o versionar el emisor.
- **Cobertura móvil en CI:** el workflow actual ejecuta Node, API, Spring y navegador, pero no incorpora `flutter analyze`, `flutter test` ni el verificador del backend móvil. La nueva ampliación puede romperse sin bloquear el CI existente.

## Funciones y trabajo que faltan para cerrar el proyecto

### Entrega según las notas del docente

| Pendiente | Estado real y criterio de cierre |
| --- | --- |
| Aplicación Flutter de demostración adaptada al caso presentado | Hay generador opcional y base reutilizable. Falta preparar y ensayar las pantallas/caso de gestión que se construirán o adaptarán durante la presentación. Las notas no exigen generar Flutter automáticamente. |
| Agente GGUF en Android físico | Motor, contrato y revisión CRUD existen. Falta elegir/cargar pesos compatibles y demostrar altas, consultas, cambios, negaciones y ambigüedad con calidad, memoria y latencia aceptables. No se validó inferencia real en esta auditoría. |
| Voz y operación móvil completamente offline | Probar en modo avión, cerrar/reabrir, conservar los datos, recuperar conexión y enviar una sola vez. Probar también dos dispositivos con modificaciones incompatibles. SQLite y recibos ya existen; falta acreditar el recorrido físico completo. |
| Interacción sin teclado ni mouse, si se evalúa literalmente | El flujo web y móvil aún usa botones para enviar/revisar/aplicar. Faltan órdenes de control y confirmación por voz. Si se exige escucha offline garantizada, falta un STT local controlado por la app; el reconocedor Android no lo garantiza en todos los equipos. |
| Enterprise Architect 15 | Cerrar app → EA → app después de la corrección del exportador. Revisar tipos, claves, roles, cardinalidades y posiciones. Los tests propios no sustituyen abrir el archivo en EA real. |
| Fotografía y proveedores reales | Usar fotografías reales del aula y micrófono real; diagnosticar tiempos, permisos, cuotas y fallbacks. Un PNG de un píxel y respuestas simuladas solo prueban el flujo. |
| Ensayo integrado | Usuarios distintos → colaboración → modelo nuevo → ZIP → IDE → PostgreSQL vacío → Postman → Flutter → offline → reconexión. Cronometrarlo en los equipos/red previstos y comprobar puertos/configuración. |

### Funcionalidad incompleta de la plataforma

1. **Administración web de miembros:** cambiar roles, retirar miembros, listar/revocar invitaciones. La API ya ofrece operaciones; faltan controles en la interfaz.
2. **Completar la revisión de importación:** editar roles de relaciones, quitar operaciones, validar reactivamente y resolver otras ambigüedades. La colisión XMI descrita en B03 ya permite editar el candidato y corregir los nombres.
3. **Respaldo y recuperación por el usuario:** exportación/restauración JSON o equivalente y recuperación de versiones de la pizarra. El historial de generaciones no equivale a restaurar el documento.
4. **Auditoría recuperable:** mostrar causa y acciones para lotes rechazados; coordinación durable de la cola entre pestañas y política para evitar pérdida/crecimiento indefinido.
5. **Robustez del asistente:** cancelar peticiones remotas en curso, limitar consumo por usuario y conservar trazabilidad de intentos/resultados según el alcance acordado. La detección de propuestas obsoletas descrita en B04 ya está implementada.
6. **Actualización compartida del historial:** ver generaciones creadas por otros colaboradores sin reabrir/refrescar el panel.
7. **Accesibilidad y compatibilidad:** completar auditoría de teclado/lector de pantalla y probar navegadores distintos de Chromium y dispositivos físicos.

### Publicación y opciones que no deben confundirse con requisitos obligatorios

- Antes de publicar: HTTPS, cookies seguras, puertos mínimos, límites de acceso/recuperación/IA/generación, correo operativo, backups con restauración ensayada, supervisión y retención de datos/registros. Si se promete cierre instantáneo de todas las sesiones web, falta revocación inmediata de JWT de acceso, además de refresh tokens.
- Si se distribuye Android: firma y configuración release/HTTPS y una estrategia de actualización; el APK debug previo no equivale a una distribución final.
- Si se ofrece edición web offline a través de recargas: persistir el Y.Doc localmente. Hoy la recuperación de desconexión transitoria requiere conservar la pestaña.
- Sincronización móvil con la app cerrada, sincronización incremental, migración automática de contratos, reglas de negocio compuestas y perfil semántico configurable son ampliaciones; no se deducen todas como obligaciones del parcial.
- Deshacer propio, reparación guiada de muchos a muchos y bloqueo exclusivo por elemento siguen siendo opcionales o requieren confirmación del alcance. CRDT ya resuelve convergencia; no equivale a bloqueo exclusivo.

## Documentación que debe ponerse al día

- `docs/pendientes.md` todavía menciona renovación móvil automática como faltante, pero `templates/flutter/lib/data/api.dart.tpl`, `MobileSessions.java.tpl` y sus pruebas ya la implementan.
- El índice de requisitos y varios párrafos siguen diciendo que nativo/Dart fue retirado sin distinguir esa retirada histórica de la nueva base Flutter Android.
- El plan maestro está disponible localmente, pero `docs/referencia/` se ignora en Git. Un clon limpio no recibe la especificación completa enlazada por el README; se necesita una referencia versionable/autorizada.
- La evidencia histórica de 8/23/442 pruebas no debe reemplazar los resultados de esta ejecución ni presentarse como verificación de GGUF/voz reales.

## Orden de cierre propuesto

1. **Completado:** corregir B01–B05 y añadir regresiones; integración 129/129, incluido RF-052 con expectativas reforzadas.
2. Resolver los avisos de dependencias con una actualización evaluada.
3. Completar administración web y revisión de importación; definir recuperación/auditoría según el alcance de entrega.
4. Validar Android físico, GGUF, voz/foto y Enterprise Architect.
5. Ensayar de punta a punta y consolidar requisitos, evidencia, configuración de despliegue y pendientes reconocidos.

Pasar todas las suites existentes no garantiza ausencia de bugs: cuatro de los cinco defectos confirmados requirieron casos adicionales a los tests habituales. Tampoco acredita por sí solo el comportamiento de dispositivos, proveedores y programas externos.
```

---

### `docs/auditoria-2026-09-20.md`

```markdown
# Revisión de bugs — 20 de septiembre de 2026

## Correcciones

1. **Sesión al reconectar y recargar.** Se renovaba la cookie incluso cuando el token de acceso seguía vigente. Una recarga inmediata podía cancelar la respuesta después de consumir la cookie anterior y terminar en el formulario de acceso. Ahora se valida primero el acceso existente consultando el perfil y se renueva cuando hace falta.
2. **Fallo temporal durante una renovación.** Una petición con acceso vencido devolvía el primer 401 aunque la renovación hubiera fallado por red, tiempo agotado o un error 503. Esto impedía abrir la copia local de una pizarra. El cliente conserva la causa del fallo de renovación para permitir la recuperación offline.
3. **Proyectos después de una desconexión.** La lista y el detalle de proyectos no volvían a cargar al recuperar la conexión. Ahora consultan nuevamente los datos y conservan los formularios que el usuario estaba completando.
4. **Controles de importación y exportación XMI.** El formulario de exportación y la vista previa se insertaban debajo de los controles existentes y podían quedar recortados por el panel. Al abrirlos, el panel se desplaza hasta el contenido nuevo; escribir en sus campos no provoca nuevos desplazamientos.

## Pruebas de regresión

- Fallos de red, servidor y tiempo agotado durante la renovación del acceso.
- Recuperación de lista y detalle de proyectos sin perder formularios.
- Reconexión con un acceso vigente sin rotar innecesariamente la cookie.
- Apertura de copia local y sincronización posterior cuando falla la renovación de una consulta.
- Reutilización de las pruebas de XMI en escritorio y móvil, y de la guía offline que reproducía la pérdida de sesión.
- Las pruebas de voz y móvil completan ahora la activación por correo antes de iniciar sesión. El servidor offline de pruebas exige Bearer para los datos y reserva la cookie para renovar o cerrar la sesión, como producción.

## Verificación

- `npm run check`: formato, lint, tipos y 597 pruebas rápidas correctos.
- `npm run test:api`: 144 pruebas de integración correctas en PostgreSQL temporal.
- `npm run test:generated`: T01 correcto; generación, compilación Java/Maven, CRUD, persistencia tras reinicio y restricciones de borrado.
- Compilación del monorepo y del frontend de producción correctas.
- La regresión de reconexión y recarga pasó cinco repeticiones consecutivas.
- Las cinco pruebas dirigidas de visibilidad, importación y exportación XMI pasaron.
- Las 22 pruebas del modo offline pasaron con el servidor de pruebas que reproduce la separación entre cookie y token de acceso.
- La pasada final completa de Chromium terminó con **106 pruebas aprobadas**, sin fallos, sobre el frontend compilado con las correcciones.

La validación completa del navegador utiliza el frontend compilado de este directorio mediante Vite Preview y los servicios API/colaboración locales. IA y correo usan proveedores simulados; no valida servicios externos reales. Los resultados finales se guardan en `reports/audit-final.log` y `reports/audit-offline-complete.log`, con sus directorios de pruebas en `reports/`.

## Alcance

Se conservaron los cambios que ya existían en el directorio. Esta revisión verifica el entorno local; no publica cambios ni certifica la configuración del servidor de producción. No se ejecutó el banco completo de ocho backends ni la compilación de APK Android.
```

---

### `docs/colaboracion-xmi-2026-09-10.md`

```markdown
# Colaboración e intercambio XMI: revisión del 10 de septiembre

Se completaron los controles de colaboración y la revisión del candidato XMI, y se corrigieron errores de permisos y de compatibilidad detectados durante pruebas con navegadores y Enterprise Architect 15.1 (build 1514). Este informe actualiza el estado de la [revisión anterior](revision-colaboracion-xmi-2026-09-09.md).

## Funcionalidades completadas

- Administración desde el proyecto: listar participantes, cambiar Editor/Lector, retirar miembros, salir del proyecto, listar y revocar invitaciones. Los cambios de permisos alcanzan las pizarras abiertas. Una invitación revocada deja de mostrarse como disponible.
- Candidato editable: nombres, tipos, clave primaria, obligatoriedad, unicidad, extremos de relaciones, roles, multiplicidades y clase de relación. Se pueden quitar operaciones; quitar una clase nueva también quita las operaciones que dependen de ella. El resumen y la validación se actualizan mientras se edita. Los errores de precondiciones impiden aplicar; los hallazgos del modelo se señalan para corregir antes de generar.
- Identidad XMI: el importador materializa comandos por UUID, sin resolver el archivo por nombres aproximados de IA. Añadir conserva elementos existentes, evita duplicados y avisa de definiciones diferentes. Reemplazar conserva las identidades válidas del archivo y exige revisar de nuevo si otro colaborador cambió el modelo.
- Disposición: exportar/importar conserva posiciones y tamaños de clases, tanto en el perfil UML propio como en el perfil EA. El archivo propio permite recuperar coordenadas negativas; si EA modifica o reexporta su diagrama, se interpreta su geometría nativa.
- Selector de exportación: **Enterprise Architect 15 — XMI 2.1** y **UML 2.5.1 — XMI 2.5.1**. La segunda opción completa la versión solicitada por el objetivo 11 del perfil del proyecto; la API acepta `format: "UML_251"` y conserva `EA_21` como valor predeterminado. Ambos archivos se importan por la misma revisión de candidato.
- Se mantienen las correcciones anteriores de concurrencia por campos, rechazo de XML mal formado, permisos del servidor, reconexión y persistencia en PostgreSQL.

## Errores adicionales corregidos

| Error reproducido | Corrección |
| --- | --- |
| Al retirar un participante, el servidor cerraba su sala pero la interfaz seguía permitiendo editar localmente. | Manejar el evento `close` de la sala de Hocuspocus; bloquear escritura por acceso revocado y renovar la sesión cuando corresponde a expiración. Si el participante permanece en la página del proyecto, la revisión periódica lo devuelve a sus proyectos cuando pierde acceso. |
| EA importaba clases y tipos, pero omitía completamente el diagrama. | Emitir primero la extensión nativa de EA. EA 15 ignoraba ese bloque cuando los metadatos propios aparecían antes. |
| EA invertía los extremos de asociaciones conservando las cardinalidades en las posiciones anteriores. | Emitir `memberEnd` en el orden destino/origen que utiliza EA y respetar la orientación nativa al leer, incluidas autorrelaciones. |
| EA descartaba las marcas propias de clave primaria y unicidad. | Guardarlas además como tagged values nativos identificados, `umlforge.primaryKey` y `umlforge.unique`, y leer esas marcas al importar. |
| Quitar operaciones desplazaba fuera del área visible un campo del candidato. | Integrar el control de eliminación dentro de la fila y volver a comprobar campos y acciones en el navegador. |

## Verificación real con Enterprise Architect

Se crearon proyectos EAP temporales independientes usando su API de automatización. Se importaron los ocho modelos del banco y un noveno modelo con todos los tipos y clases de relación. Se consultaron los elementos realmente almacenados por EA y se compararon con los modelos de entrada, sin modificar proyectos del usuario.

**Nueve modelos aprobados: 36 clases, 114 atributos, 32 relaciones y 36 cajas de diagrama.** Se comprobaron UUID, nombres, tipos, nulabilidad, claves y unicidad en tagged values, extremos, roles, cardinalidades, herencia, composición, agregación, autorrelaciones, posiciones y tamaños.

La evidencia y los ejecutores locales están en `reports/completar-colaboracion-xmi/`: `ea-validation.json`, `ea-fixtures.mjs`, `ea-roundtrip.ps1`, `verify-ea.mjs` y las consultas `T*-*.xml`. El directorio está ignorado por Git.

**Límite de esta aceptación:** la reexportación automatizada mediante `ExportPackageXMI` quedó sin responder, incluso en un proyecto mínimo creado por la propia API de EA. La inspección de su ventana tampoco fue posible: `window crop is outside captured monitor`. Por ello, se acredita la importación real y la conservación interna de datos en EA; no se presenta como aprobado el recorrido completo app → EA → reexportación EA → app. Los intercambios app → archivo → app y la lectura de muestras reales exportadas por EA sí se prueban automáticamente. La interfaz utilizada se documenta en la [referencia de automatización de Sparx](https://sparxsystems.com/enterprise_architect_user_guide/15.1/automation/project_2.html).

## Verificación de la aplicación

- **505/505 pruebas unitarias** aprobadas.
- **130/130 pruebas de integración** aprobadas durante la revisión; después de añadir XMI 2.5.1 se repitió específicamente su API ampliada: **21/21** aprobadas.
- TypeScript, ESLint, Prettier y compilación de producción aprobados.
- **89/89 pruebas de navegador** aprobadas en la ejecución completa con PostgreSQL temporal y una copia aislada de la compilación web. Después de añadir el selector XMI 2.5.1 se comprobaron **10/10 regresiones finales sobre Docker**, incluyendo permisos, concurrencia, ambos formatos, persistencia tras recargar y exportación desde una pantalla de 320 × 568. Evidencia: `reports/completar-colaboracion-xmi/e2e.xml` y `docker-xmi251.xml`.
- API, colaboración y web reconstruidos. Base y volúmenes conservados, sin migraciones. `/`, `/api/health` y `/collab/health` respondieron HTTP 200 en `http://localhost:8080`.

Las pruebas de integración y navegador utilizan PostgreSQL temporal y proveedores de IA simulados. Los casos nuevos están en `e2e/specs/colaboracion-xmi-completa.spec.ts`, `frontend/tests/candidate.test.ts`, `shared/xmi/tests/identity.test.ts` y `shared/xmi/tests/ea-export.test.ts`.

## Alcance y límites

### Última verificación después de los cambios visuales

Se repitió la verificación funcional el 10 de septiembre de 2026 sobre la versión actual. No se encontraron fallos nuevos ni fue necesario modificar código en esta comprobación.

| Comprobación repetida | Resultado |
| --- | --- |
| TypeScript del proyecto y pruebas | Aprobado |
| Pruebas unitarias | 505/505, 32 archivos |
| Integración de importación, proyectos y colaboración | 56/56: 21 de importación, 19 de proyectos y 16 de colaboración |
| Chromium contra la aplicación Docker en `localhost:8080` | 45/45, sin reintentos |
| Web, API y colaboración | HTTP 200; los cuatro contenedores estaban saludables |

Se comprobaron creación, movimiento, tamaño y eliminación de clases; atributos concurrentes; relaciones, herencia y multiplicidades; presencia; participantes que entran tarde; aislamiento entre pizarras; reconexión; persistencia; roles y revocación de acceso. La integración con cinco usuarios y 30 cambios obtuvo P95 de 32,9 ms en loopback, sin incluir el renderizado del navegador; no representa latencia entre equipos físicos.

Para XMI se repitieron la descarga e importación de los perfiles EA 2.1 y UML/XMI 2.5.1, conservación de UUID y disposición para ambos usuarios y tras recargar, archivos mayores de un MiB, archivos inválidos, prevención de duplicados, edición del candidato, sustitución protegida frente a cambios concurrentes y conversión de una clase asociativa de EA en entidad intermedia.

La evidencia de navegador está en `reports/verificacion-final-uml-xmi/navegador.xml` (directorio ignorado por Git). Las pruebas de integración utilizaron PostgreSQL temporal; las de navegador atravesaron el proxy, API, WebSocket y base del entorno Docker con cuentas y proyectos propios de prueba. Esta selección excluyó asistente de IA y cámara. Los resultados de Enterprise Architect descritos arriba corresponden a la revisión anterior: no se volvió a ejecutar EA ni se resolvió su bloqueo de reexportación externa en esta pasada.

### Límites que se mantienen

El intercambio soporta diagramas de clases XMI 2.1 y 2.5.1 dentro del vocabulario de la aplicación. No representa todos los elementos de UML: operaciones/métodos, estereotipos arbitrarios, todos los tipos de diagrama ni jerarquías completas de paquetes. Las clases asociativas compatibles se convierten en entidades intermedias. Las multiplicidades finitas como `2..5` se aproximan al vocabulario admitido y producen un aviso; no se conserva esa restricción exacta.

XMI 2.5.1 usa los espacios de nombres publicados por [OMG XMI 2.5.1](https://www.omg.org/spec/XMI/2.5.1) y [UML 2.5.1](https://www.omg.org/spec/UML/2.5.1). Se validaron el contenedor y sus metadatos contra el XSD oficial `XMI/20131001/XMI.xsd`, y la semántica y geometría mediante ocho recorridos completos archivo → comandos → estado del dominio/Yjs. Esta comprobación del XSD no se presenta como una certificación de todo UML. La aceptación real de Enterprise Architect corresponde a la opción específica XMI 2.1; para abrir allí el diagrama con su disposición se debe elegir ese perfil.

La colaboración permite reconectar y combinar cambios con la pestaña abierta. La persistencia offline a través de recargas, deshacer por usuario, versiones y restauración son ampliaciones diferentes que siguen en [pendientes](pendientes.md). Queda el ensayo entre equipos físicos en la red de la presentación. Pasar estas comprobaciones no permite garantizar ausencia absoluta de errores en cualquier archivo o entorno.
```

---

### `docs/comparacion-manual.md`

```markdown
# Comparación con el manual de otro proyecto de la materia

Contraste punto por punto contra el *Manual de Usuario — 1er Parcial* de Parada
Burgos Klaus (mismo docente, misma materia). Sirve para dos cosas: detectar
funciones que damos por hechas y no lo están, y decidir a conciencia dónde
diferimos.

Revisado el 30 de agosto de 2026.

Este documento **compara**. Lo que de aquí sale y merece construirse está en
[`actualizacion.md`](actualizacion.md), con coste, sitio y forma de comprobarlo.

---

## Resumen

| # | Función del manual | Nosotros |
|---|---|---|
| 1 | Iniciar sesión | ✅ |
| 2 | Cerrar sesión | ✅ **añadido al editor hoy** |
| 3 | Entrar y crear pizarras | ✅ |
| 3b | Renombrar y eliminar pizarras | ✅ **añadido hoy** |
| 4 | Compartir con otros | ✅ (más fino: tres roles) |
| 4b | Bloquear la pizarra | ❌ **decisión, ver §2.1** |
| 5 | Vista de invitado | ✅ (más completa: presencia) |
| 6 | Asistente IA por texto y voz | ✅ |
| 7 | Crear clase manualmente | ✅ |
| 8 | Importar desde imagen | ✅ |
| 9 | Importar boceto a mano | ✅ (misma función) |
| 10 | Guardar/cargar en JSON | ⚠️ **usamos XMI, ver §2.2** |
| 11-12 | Pizarra bloqueada | ❌ ver §2.1 |
| 13 | Generar backend Spring Boot | ✅ |
| 13b | Generar app Flutter completa | ❌ **decisión, ver §2.3** |
| 14 | Ejecutar el backend generado | ✅ verificado sobre 7 modelos |
| 15 | Probar con Postman | ✅ la colección va en el ZIP |

---

## 1 · Lo que faltaba de verdad, y ya está

### 1.1 Renombrar y eliminar pizarras · eliminar proyectos

**RF-001 y RF-003 son P0 en nuestro propio plan.** Las rutas HTTP existían desde
la fase 3 y estaban probadas, pero **no había ningún botón que llegara a ellas**:
se podía crear una pizarra y no había forma de renombrarla ni de borrarla. Una
pizarra mal nombrada se quedaba así para siempre.

No lo detectó ninguna prueba porque las de integración llaman a la ruta
directamente, y las de navegador nunca intentaron hacerlo. Lo encontró este
manual.

Borrar pide **escribir el nombre**, no un «¿seguro?»: no hay papelera, un
proyecto se lleva sus pizarras por delante y para todos sus miembros, y un
diálogo de confirmación se acepta sin leerlo. Hay pruebas de que escribirlo mal y
de que cancelar no borran nada.

### 1.2 Cerrar sesión desde el editor

Estaba solo en la lista de proyectos. En el editor es donde se pasa el tiempo, y
tener que navegar hacia atrás para salir invita a dejar la sesión abierta en una
máquina compartida — que es exactamente la nota de su manual.

---

## 2 · Donde diferimos a propósito

### 2.1 Bloquear la pizarra

**Ellos:** el anfitrión pulsa «Bloquear» y nadie puede editar hasta que
desbloquee.

**Nosotros:** no existe, y no está en nuestro plan. Lo que tenemos es
**autorización por rol y por proyecto**: OWNER, EDITOR y VIEWER, resuelta tanto
en HTTP como en la conexión WebSocket (RA-15). Para que alguien no edite se le
invita como lector, y eso vale para siempre y por persona, no para todos a la vez
y hasta que alguien se acuerde de desbloquear.

**Lo que su enfoque resuelve y el nuestro no:** «paren todos un momento, quiero
explicar algo». Es una necesidad real dando una clase o una demostración.

**Coste si lo quisiéramos:** un `locked` en la pizarra, comprobado en el gancho
de autorización del proceso de colaboración, que ya rechaza escrituras de un
VIEWER — sería la misma comprobación con una condición más. Medio día con su
prueba de dos navegadores. **No lo haría antes del ensayo**: no está en los
requisitos, y el tiempo que queda rinde más en los tres riesgos P0 de
[`pendientes.md`](pendientes.md).

### 2.2 Guardar y cargar en JSON

**Ellos:** «Exportar JSON» descarga el diagrama, «Importar JSON» lo restaura. Es
una copia de seguridad local.

**Nosotros:** exportamos e importamos **XMI 2.1**, que es lo que pide RF-050 y lo
que abre Enterprise Architect. JSON no aparece en nuestro plan.

**Por qué conviene añadirlo igual:** es la red de seguridad de la demostración.
Si algo se rompe en vivo —la base, el contenedor, la red— un JSON en Descargas
recupera el diagrama en un clic. El XMI también, pero pasa por el parser y por la
resolución de nombres; el JSON canónico es el modelo tal cual y no puede perder
nada.

**Coste:** pequeño. El modelo canónico ya se serializa; es un botón que descarga
`state.semantic` y otro que lo aplica como lote. Está anotado en
[`pendientes.md`](pendientes.md).

### 2.3 Generar la aplicación Flutter completa

**Ellos:** el botón «Frontend» descarga un proyecto Flutter entero
(`flutter-mvp`).

**Nosotros:** generamos la **capa de datos** Dart —modelos, cliente HTTP tipado,
base local, repositorios y cola de sincronización— y no las pantallas. Es
[ADR-011](adr/ADR-011-generacion-limitada-capa-datos.md), y la razón está
escrita: el docente dijo que **no verá aplicaciones móviles generadas** y que el
frontend se construye en vivo durante la defensa. Generar pantallas cuesta tanto
como el generador de Spring Boot y sustituiría justo el ejercicio que él pidió.

**El riesgo de la decisión, dicho claro:** si el docente esperaba ver el botón
«Frontend» porque otro proyecto lo tiene, hay que poder explicar en treinta
segundos por qué el nuestro llega hasta la capa de datos y qué se construye
encima en vivo. La app móvil de la fase 9 —agente de voz, operación sin conexión,
cola— está construida **sobre** esa capa generada, y esa es la demostración.

---

## 3 · Donde estamos por delante

No para presumir: son cosas que conviene enseñar porque no están en su manual y
responden a requisitos del plan.

- **Proyectos con varias pizarras y tres roles.** Su modelo es anfitrión e
  invitado sobre una pizarra. El nuestro tiene proyectos, miembros, invitaciones
  con rol y varias pizarras por proyecto (RF-001 a RF-005, RF-A04 a RF-A08).
- **Presencia.** Se ve quién está conectado y qué elemento está editando cada uno
  (RF-026), no solo una etiqueta de anfitrión o invitado.
- **Validación con errores y avisos** (RF-017). El diagrama dice qué impide
  generar y qué solo es una advertencia, con la sugerencia al lado.
- **Congelado del snapshot al generar** (RA-08). Si alguien sigue editando
  mientras se arma el ZIP, el ZIP corresponde al modelo del momento en que se
  pulsó, y descargarlo de nuevo mañana da el mismo archivo.
- **Auditoría** de quién aplicó cada lote (RF-A09).
- **Interoperabilidad XMI con Enterprise Architect** en los dos sentidos.
- **La app móvil funciona en modo avión**, con reconocimiento de voz y
  clasificador de intenciones en el dispositivo, y cola de sincronización sin
  duplicados.
- **Banco de regresión de siete modelos** que compila, arranca y ejerce el CRUD
  del backend generado en cada cambio.

---

## 4 · Detalles menores del manual

| Función suya | Nosotros | Comentario |
|---|---|---|
| Indicador de zoom en % | Controles de React Flow (`+`, `−`, ajustar) | Sin el número. Cosmético. |
| «Limpiar pizarra» | No | Se borran las clases o se elimina la pizarra. Un botón que vacía todo de golpe da más sustos que servicio. |
| Botón «Muchos a Muchos» | No, y a propósito | Un N:M se marca como **error** con la sugerencia de crear la entidad intermedia ([ADR-005](adr/ADR-005-entidad-intermedia-muchos-a-muchos.md)): no se puede traducir a persistencia sin decidir qué datos lleva la relación. |
```

---

### `docs/compatibilidad-xmi-2026-09-05.md`

````markdown
# Comparación real de XMI y corrección de la cabecera

**Actualización del 10 de septiembre:** se corrigieron además orden de extensiones, extremos y marcas nativas; nueve modelos aprobaron la importación real en EA. Véase [evidencia y límite de la reexportación](colaboracion-xmi-2026-09-10.md). Este documento conserva el diagnóstico anterior.

El usuario confirmó este recorrido: app web → `ExportadoNuevo.xmi` → Import
Package from XMI en Enterprise Architect → `exportadodeimportado.xmi`.
La importación anterior falló: los tipos estaban escritos en el archivo, pero EA
no los incorporó. No era únicamente una opción de visualización.

## Resultado observado

| Dato | Archivo de la app | Archivo devuelto por EA |
|---|---|---|
| Clases | 11 | 11 |
| Atributos de datos | 44 | 44 |
| Atributos con tipo explícito | 44 | 0 |
| Tipos | 14 Integer, 21 String, 6 Date, 3 Decimal | Ninguno |
| Relaciones | 13, incluida autorrelación de Materia | 13 |
| Atributos con `isID` | 8 | 0 |
| Paquete y diagrama | Ejemplo | Package1 |
| Geometría de clases | 11 cajas con posiciones propias | Las 11 con Left=10, Top=10, Right=100, Bottom=80 |
| Identificadores de clases | UUID de la app | UUID nuevos |

Los 44 avisos del parser al leer el segundo archivo son relevantes: su fallback
`String` no significa que EA haya conservado 44 tipos String. En el XML faltan
tanto las referencias UML a los tipos como `properties.type` en la extensión.
Contar relaciones tampoco acredita todos sus detalles; EA invirtió los extremos
de asociaciones no dirigidas y escribió `1..1` donde la app escribió `1`.

## Corrección aplicada

La cabecera del perfil EA seguía diciendo `exporter="Plataforma UML"`, aunque
el documento ya tenía identificadores EAID/EAPK, tipos primitivos y diagrama
en la extensión nativa. Ahora se emite:

```xml
<xmi:Documentation exporter="Enterprise Architect" exporterVersion="6.5"/>
```

Esta combinación corresponde a la muestra nativa y a la recomendación del
[equipo de Sparx sobre el importador y los identificadores](https://sparxsystems.com/forums/smf/index.php?topic=39006.0).
El [caso de tipos y orden de atributos](https://sparxsystems.com/forums/smf/index.php?topic=41984.0)
también documenta la diferencia de comportamiento según la cabecera y el uso de
`containment.position` al importar el formato EA. La pérdida conjunta de tipos,
identidad y geometría es consistente con el uso del importador genérico.

`6.5` es la versión del formato exportado, no la versión instalada del programa.
Un comentario XML identifica a Plataforma UML como productor real. El
serializador UML genérico conserva su cabecera anterior; la API de descarga
utiliza el perfil EA corregido.

Se creó `generated-output/ExportadoCorregidoEA.xmi` a partir del archivo del
usuario. Solo cambia la cabecera y se añade el comentario de procedencia.
Una comparación estructural verificó que modelo, identificadores, extensiones
y geometría son idénticos al archivo original. Los originales de Downloads no
se modificaron. Las copias de evidencia están en `shared/xmi/tests/fixtures/`.

## Verificación y pendiente de aceptación

- 57 pruebas de XMI aprobadas, incluidas las dos muestras nuevas y la comprobación
  de la cabecera nativa, el orden de atributos y los avisos por tipos ausentes.
- 18 pruebas de integración de importación/exportación aprobadas.
- Typecheck y lint aprobados.
- API local reconstruida y saludable; las nuevas descargas usan el perfil corregido.

**Pendiente:** importar `ExportadoCorregidoEA.xmi` en un proyecto de prueba de EA,
abrir su diagrama y comprobar tipos, posiciones, relaciones y marcas de identidad.
Exportar ese paquete de nuevo permite verificar el resultado sin depender de la
captura. La corrección de la cabecera está probada en código, pero todavía no se
ha recibido el resultado de esta nueva importación en EA. Tampoco se acredita
la recuperación de `isID` ni de otras marcas de la app hasta esa comprobación.
````

---

### `docs/despliegue.md`

````markdown
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
````

---

### `docs/estado-aplicacion-2026-09-05.md`

```markdown
# Estado de la aplicación — 5 de septiembre de 2026

Actualización del 6 de septiembre: [dictado, ahorro y validación](voz-y-consumo-ia.md),
con [arquitectura de hasta siete respaldos por capacidad](proveedores-ia.md).

Esta es la revisión anterior. La continuación, con contenedores reconstruidos,
pruebas táctiles y pendientes consolidados, está en la
[auditoría final](auditoria-2026-09-05.md).

Actualización de interoperabilidad: la prueba real de EA detectó pérdida de los
44 tipos y de la geometría. Se corrigió la cabecera del exportador; la aceptación
externa sigue pendiente. Ver [comparación XMI](compatibilidad-xmi-2026-09-05.md).

La plataforma web y el generador Spring Boot funcionan en los recorridos
verificados. Se corrigieron tres defectos funcionales y una prueba incorrecta.
La revisión no acredita todavía una entrega cerrada: faltan la interoperabilidad
con Enterprise Architect real, la validación de dispositivos y proveedores reales,
el ensayo de demostración y la resolución de avisos de seguridad de dependencias.

## Alcance de esta revisión

Se revisó el código actual del monorepo, conservando los numerosos cambios previos
sin hacer commit ni revertirlos. Se ejecutaron comprobaciones estáticas, pruebas
de dominio, API, PostgreSQL, WebSocket y navegador, y el banco completo de
backends generados. Se inspeccionaron también la configuración de desarrollo,
las dependencias y las capturas de la prueba de carga.

El alcance ejecutable actual incluye cuentas, perfiles, recuperación de contraseña,
proyectos, permisos, pizarras colaborativas, editor UML, asistente, importación por
imagen/XMI, exportación XMI, auditoría y generación Spring Boot. El módulo móvil y
el generador Dart fueron retirados antes de esta revisión; sus menciones antiguas
no deben interpretarse como funciones disponibles.

## Correcciones realizadas

| Problema | Efecto anterior | Corrección y evidencia |
|---|---|---|
| Proxy de desarrollo | `/api/health` y `/collab/health` daban 404; las rutas de sesión tampoco llegaban correctamente al servidor. | Vite elimina los prefijos `/api` y `/collab`, igual que el proxy de contenedores. Ambas sondas responden 200 y la suite de navegador pasa a través de Vite. |
| Respuestas tardías tras cambiar de cuenta | Un 401 de una petición iniciada por Ana podía reenviarse con la sesión de Beto. Una respuesta exitosa anterior también podía introducir datos obsoletos en la interfaz. | Cada operación conserva la revisión de sesión que la inició y la comprueba antes de reintentar y después de recibir su cuerpo. Se aplica a JSON, exportación XMI y ZIP. Cuatro regresiones fallaban antes y pasan después. |
| Recuperación con una sesión abierta | Tras restablecer la contraseña, «Ir a entrar» llevaba a `/proyectos`, porque React conservaba el usuario anterior. | Se cierra la sesión del cliente al completar la recuperación. La prueba de navegador reproduce el fallo anterior y verifica acceso y recarga posteriores. |
| Prueba RNF-03 | Enfocaba una clase sin seleccionarla y esperaba que las flechas la movieran; producía un falso fallo de colaboración. | La prueba selecciona con Enter antes de mover. Verifica importación, 30 nodos, 40 relaciones y propagación del movimiento. |

Archivos funcionales modificados en esta revisión:

- `frontend/vite.config.ts`.
- `frontend/src/lib/api.ts`.
- `frontend/src/features/auth/ResetPage.tsx`.
- Regresiones en `frontend/tests/api.test.ts`, `e2e/specs/carga.spec.ts` y
  `e2e/specs/sesion.spec.ts`.

También se enlazó este informe desde README y se corrigieron referencias de
alcance y resultados obsoletos en la documentación de requisitos y pendientes.

## Resultados de verificación

| Comprobación | Resultado |
|---|---|
| Formato, ESLint y TypeScript | Correctos después de los cambios de código. |
| `npm test` | **352 pruebas pasan**; la muestra real de Enterprise Architect se procesa con avisos explícitos para construcciones no soportadas. |
| `npm run test:api` | **126 pruebas pasan** en 7 archivos, con PostgreSQL efímero. |
| `npm run build` | Todos los paquetes y la interfaz compilan correctamente. |
| Playwright, interfaz actual | **62 pruebas pasan**, 0 omitidas, 0 fallidas y 0 inestables; duración aproximada de 189 segundos. |
| Contenedor web local actualizado, puerto 8080 | **11 pruebas adicionales pasan**: cuenta, recuperación y generación/descarga de ZIP. Web, API y colaboración responden 200; los cuatro servicios están saludables. |
| `npm run test:bank` | **8 modelos completos**: T01, T02, T03, T04, T05, T06, T07R y T08. |
| API y colaboración por el proxy de desarrollo | Ambas sondas HTTP responden **200**, frente al **404** reproducido antes. |
| `npm audit` | **4 paquetes afectados con severidad alta**, 0 críticos; pendiente de resolver. |

El banco generado comprobó compilación Maven/Java 21, arranque con PostgreSQL
limpio, OpenAPI, altas, consultas, modificaciones, idempotencia, persistencia tras
reiniciar y rechazo 409 al borrar un padre con hijos. T07R es el modelo reparado
generable; el caso no generable T07 no se presenta como un backend compilado.

La primera pasada de navegador contra el entorno de auditoría en el puerto 18080
dio 59 aprobadas y 2 fallos: la selección incorrecta de RNF-03 y un contenedor web
antiguo que todavía mostraba «Foto del pizarrón». La pasada final usa el código
actual en Vite 6.4.3, puerto 15173, con API y colaboración del entorno aislado.
Las pruebas de integración sí ejecutan el código actual de los servidores.

Se reconstruyó y actualizó únicamente `plataforma-uml-web-1` para publicar las
correcciones en la aplicación local de `http://localhost:8080`. Los datos y los
otros servicios se conservaron. El entorno secundario de auditoría no se
reconstruyó; su interfaz antigua se identifica arriba para evitar confundirla
con el resultado final. El servidor Vite temporal se apagó al terminar.

El caso nuevo de recuperación de sesión simula solamente la respuesta exitosa de
restablecimiento. El consumo real y exclusivo del enlace, la contraseña nueva y
la revocación de refrescos se verifican en la suite de integración. No se enviaron
correos a personas ni solicitudes a proveedores reales de IA.

Evidencia local conservada en `reports/revision-2026-09-05/`:

- `e2e-output.log`: salida y resultado JSON de los 62 recorridos.
- `npm-audit.json`: detalle de los avisos de dependencias.
- `sesion-antes/`: captura y traza del fallo de recuperación reproducido.
- `regresiones/` y `e2e/`: capturas del editor con 30 clases.

## Capacidad observada

| Requisito | Medición de esta ejecución | Límite de la evidencia |
|---|---|---|
| RNF-01 / RNF-02 | Cinco clientes WebSocket, 30 cambios, P95 **34,5 ms**. | Loopback en esta máquina; no representa la red del aula. |
| RNF-03 | 30 clases, 100 atributos, 40 relaciones: importar y visualizar en el segundo navegador tomó **242 ms**; propagar un movimiento, **102 ms**. | Un escenario local en Chromium; no es una medición de FPS ni de latencia P95 del navegador. |
| RNF-04 | Diez salas del mismo proyecto mantienen estados separados. | Prueba de integración, no diez interfaces abiertas durante horas. |
| Generación y determinismo | Pruebas de carga y comparación de bytes pasan; ocho backends ejecutados. | No mide producción multiusuario ni disponibilidad prolongada. |

## Faltantes y riesgos priorizados

### Antes de la demostración

1. **Enterprise Architect 15 real.** El parser ya procesa el XMI de esa instalación;
   falta abrir en EA un archivo exportado por la plataforma y conservar la captura.
2. **Ensayo completo y puertos.** Ejecutar el guion cronometrado en el equipo y
   red previstos. Mantener la plataforma en 8080 y asignar otro puerto, por
   ejemplo 8081, al backend generado para evitar el conflicto de valores por defecto.
3. **IA, voz, imagen y correo reales.** Validar las claves y modelos configurados,
   una fotografía del pizarrón, el micrófono y los permisos del navegador. El
   adaptador de correo `log` no entrega mensajes a una bandeja de entrada;
   comprobar el proveedor de correo si la recuperación se va a demostrar por email.
4. **Versiones desplegadas coherentes.** Reconstruir los servicios modificados
   antes del ensayo. Un contenedor saludable puede servir código antiguo, como
   ocurrió en el entorno aislado de auditoría durante esta revisión.

### Robustecimiento pendiente

- **Dependencias de Prisma.** `npm audit` marca `prisma`, `@prisma/config`,
  `deepmerge-ts` y `mysql2`. Son cuatro paquetes afectados, no cuatro defectos
  independientes. La cadena instalada incluye `deepmerge-ts@7.1.5` y
  `mysql2@3.15.3`. Los avisos incluyen recursión sin límite al fusionar objetos,
  degradación de autenticación MySQL y descompresión sin límite. La aplicación
  usa PostgreSQL; la exposición de cada ruta vulnerable requiere evaluación
  específica. El arreglo automático propone retroceder Prisma 7.10.0 a 6.19.3,
  un cambio mayor incompatible con la configuración actual, por lo que no se
  ejecutó `npm audit fix --force`. Hace falta una actualización compatible o
  una sustitución transitoria validada de esas dependencias.
- **Revocación inmediata de tokens de acceso.** Cambiar o recuperar la contraseña
  revoca los tokens de refresco, pero los JWT de acceso emitidos siguen siendo
  válidos hasta su vencimiento, por defecto hasta 15 minutos. La autorización
  HTTP verifica firma y caducidad, sin consultar una sesión revocable. Si se
  promete cerrar todas las sesiones de inmediato, falta añadir esa comprobación
  también a HTTP y WebSocket. La corrección de interfaz de esta revisión no
  modifica ese diseño del servidor.
- **Protección frente a intentos repetidos.** No se encontró límite de intentos
  en login, registro o recuperación ni una regla equivalente en el Nginx del
  repositorio. Añadirlo antes de exponer la plataforma públicamente.
- **Registro estructurado RNF-14.** El middleware enlaza `actorId`; las rutas de
  auditoría y generación aún no incorporan todos los identificadores de proyecto,
  pizarra, lote, comando, generación y origen requeridos para diagnóstico.
- **CA-068.2.** La plantilla expone conexión a base y puerto, pero sigue faltando
  una aserción explícita que impida introducir otras variables configurables.
- **Persistencia y recuperación operativa.** Definir copias y restauración de la
  base, retención de snapshots y tokens, y observación de fallos de servicios.
- **Vista previa de importación.** Completar edición de roles, eliminación de
  operaciones y validación reactiva del candidato antes de aplicar.

### Mejoras que no bloquean el núcleo actual

- Copia y restauración local JSON.
- Consulta o exportación de una cola de auditoría rechazada permanentemente:
  los lotes se conservan, pero requieren una salida visible para su recuperación.
- Actualización automática del historial de generaciones de otros colaboradores.
- Pruebas prolongadas en la red del aula y en navegadores y dispositivos adicionales.
- Revisión completa de documentación histórica que aún describe móvil/Dart.

**Valoración:** núcleo web y generación verificados, con las correcciones de esta
revisión probadas. La preparación para una demostración es avanzada; la
interoperabilidad externa, los dispositivos reales y el robustecimiento de
seguridad siguen abiertos. No se asigna un porcentaje de avance porque esos
pendientes no tienen un peso comparable a una prueba unitaria aprobada.
```

---

### `docs/estrategia-mobile-offline-agente.md`

```markdown
# Estrategia de Flutter offline y agente adaptable

Revisión del código actual: 6 de septiembre de 2026. No se probó inferencia, dictado ni un modelo local. La evidencia de ejecución anterior se conserva en [revisión del generador CRUD](revision-generador-crud.md).

## Offline: qué está implementado

El primer login requiere backend disponible para autenticar y descargar `/mobile-contract`. La sesión y el contrato se guardan; SQLite conserva registros y cola, separados por servidor, cuenta y contrato. Al reabrir sin red se restaura esa sesión y se leen datos locales.

Formularios y operaciones confirmadas del agente usan el mismo repositorio. Crear, editar o eliminar registra el cambio y actualiza la vista local en una transacción SQLite antes del envío. No se guardan instrucciones ambiguas para que una IA remota las interprete después: la cola contiene operaciones CRUD ya validadas y confirmadas.

La sincronización se intenta al abrir, al regresar al primer plano, tras guardar, por botón manual y cada 30 segundos con la app abierta. Se verifica el contrato antes de enviar. El backend guarda recibos por ID de operación para que perder una respuesta no provoque otra escritura. Se procesan cambios en orden y se descargan colecciones completas conservando los pendientes locales.

Límites comprobados en código:

- No hay un servicio Android que mantenga la sincronización con la app cerrada ni un listener dedicado que dispare exactamente al recuperar internet. El temporizador y la reapertura hacen los reintentos.
- Tener internet no basta: el backend también debe ser accesible. En otro Wi-Fi no suele funcionar la dirección LAN de un equipo; usar una URL HTTPS pública para ese escenario.
- El acceso remoto vence a los 15 minutos. Si pasó más tiempo, hace falta volver a iniciar sesión con la misma cuenta; el funcionamiento y los pendientes locales se conservan. No existe refresh token automático.
- Un conflicto definitivo detiene la cola hasta resolverlo. No hay merge automático de reglas del negocio. Si el contrato cambia de forma incompatible, se bloquea el envío para no mezclar datos.
- Antes del primer envío se consolidan ediciones locales. Después de un intento, la operación queda inmutable hasta confirmar o resolver el conflicto, porque podría estar aplicada en el servidor.
- Las relaciones usan IDs; hay que crear los registros referenciados antes de los dependientes. No se genera un planificador general de transacciones entre entidades.
- Durante la comprobación/sincronización se deshabilitan escrituras en la UI. Un timeout de red puede mantener ese bloqueo temporal; separar comprobación de conectividad y edición local es una mejora pendiente de experiencia offline.

## Configuración básica

1. Generar **Android + backend** desde el diagrama.
2. Configurar el backend una sola vez, por `.env` o variables del hosting. Para desarrollo, `dart run tool/start_backend.dart 8082 5435` desde `mobile/` prepara `.env` si falta y ejecuta Compose. Si existe, respeta sus valores y puertos.
3. Abrir Flutter, introducir la URL de la API e iniciar sesión con conexión. Esperar la primera descarga de datos antes de desconectar. El modo offline y su cola ya vienen activados; no hay que programarlos por entidad.
4. Para el agente local, cargar previamente un GGUF compatible y elegir su plantilla de conversación. Para un Gemma compatible usar `gemma`. Tras reabrir, pulsar Abrir guardado. Sin pesos cargados siguen funcionando los formularios; el agente no puede interpretar instrucciones.

El motor actual es local tanto online como offline. No existe una selección automática de IA remota cuando hay internet y local cuando se pierde. Tampoco se descarga automáticamente un modelo. El formato GGUF y la opción de plantilla no garantizan que cualquier versión de Gemma u otra arquitectura esté soportada por el motor.

## Estrategia para aplicaciones diferentes

| Capa | Responsabilidad | Estado actual |
| --- | --- | --- |
| Núcleo común | Login, sesión, SQLite, cola, recibos, conflictos, revisión, operaciones CRUD | Implementado |
| Contrato de datos por aplicación | Recursos, campos, claves, tipos, anulabilidad y relaciones | Generado desde el diagrama, descargado en login y conservado offline |
| Reglas comunes del agente | Una operación JSON, no inventar registros, preguntar ante ambigüedad, conservar campos en UPDATE, confirmar antes de guardar | Implementado como texto fijo en `LocalAgent` |
| Contexto variable por solicitud | Recurso seleccionado, campos/restricciones, registros filtrados e instrucción | Implementado: se construye desde el contrato actual, sin plantilla especial para ventas o barbería |
| Perfil semántico de negocio | Sinónimos, descripción del negocio, significado de estados y ejemplos propios | No hay archivo/perfil configurable consumido por la app; aún requiere modificar código si se necesita |
| Casos de uso de negocio | Cobrar, cerrar venta, transferir saldo, reservar cupo, validar disponibilidad | Deben implementarse como lógica de servicio y operaciones explícitas; no están inferidos del diagrama ni habilitados como herramientas del agente |
| Pantallas específicas | Agenda, caja, inventario, reportes | Punto de extensión `custom_pages.dart` implementado; widgets concretos se desarrollan según la app |

El prompt no necesita reescribirse para un CRUD nuevo: sus nombres y restricciones llegan por contrato. Sí necesita información semántica adicional para entender expresiones que no correspondan directamente a esos campos. Hoy el agente opera sobre una colección seleccionada, con CREATE/UPDATE/DELETE/LIST; no navega libremente por todo el backend, no ejecuta varias entidades como una transacción y LIST devuelve la lista local filtrada, no un lenguaje de consultas o agregaciones general.

## Separación propuesta para completar la flexibilidad semántica

Mantener las reglas comunes independientes del motor GGUF. Añadir en el futuro un perfil versionado por backend con descripción breve, alias de recursos/campos, significado de valores y ejemplos de intención. Ese perfil debe validarse, guardarse offline junto al contrato y limitar su tamaño. No debe alterar las reglas de confirmación, declarar permisos ni permitir URLs o SQL arbitrarios.

Ejemplo de adaptación: en una barbería, «agendar atención» puede corresponder a crear una Cita si el usuario aporta los datos obligatorios. Comprobar que no se solape con otra cita requiere una regla de negocio. En ventas, «cobrar» puede modificar Venta, Detalle, Pago e inventario; hacerlo correctamente requiere un servicio transaccional del backend y una política explícita para su versión offline. No basta con añadir «cobra correctamente» al system prompt.

Para casos de uso complejos, definir una operación de dominio versionada (por ejemplo, `registrarVenta`) con entrada validada, permisos, reglas, idempotencia y estrategia de conflicto. Solo después puede exponerse al agente y, si admite ejecución offline, incorporarse a una cola compatible. Mientras esa herramienta no exista, el agente debe pedir aclaración o limitarse a los CRUD disponibles.

## Resultado de la revisión

La flexibilidad estructural de CRUD y el almacenamiento/cola offline están implementados. El prompt recibe el contrato de cada aplicación y no depende de clases concretas de ventas. La personalización semántica sin tocar código y las operaciones de negocio compuestas siguen pendientes. No se acredita todavía que un modelo específico interprete bien las órdenes o que la voz funcione en modo avión; estas pruebas siguen excluidas por indicación del usuario.

Referencias de implementación: `templates/flutter/lib/ui/app_model.dart.tpl`, `data/repository.dart.tpl`, `data/api.dart.tpl`, `data/local_agent.dart.tpl`, `domain/proposal.dart.tpl`, `ui/custom_pages.dart.tpl` y `templates/mobile-backend/MobileSecurity.java.tpl`.
```

---

### `docs/generacion-backend-gestion.md`

````markdown
# Backend de gestión generado desde el diagrama

Actualización: 6 de septiembre de 2026.

La herramienta genera un proyecto Maven independiente con Spring Boot 4.1.1, Java 21 y PostgreSQL. El modelo de ventas de ejemplo contiene Cliente, Producto, Venta y Detalle de Venta. La generación es determinista y no necesita una llamada de IA.

## Capas y DTO

| Capa | Contenido |
| --- | --- |
| Modelo | Entidades JPA, claves, tipos, nulabilidad, unicidad, herencia y referencias. |
| Repositorio | JpaRepository y búsquedas por clave foránea. |
| Servicio | Transacciones, CRUD, resolución de referencias y transformación entidad/DTO. |
| Controlador | GET de lista y por ID, POST, PUT y DELETE. |
| DTO | Records planos, con atributos heredados y relaciones representadas por IDs del tipo correcto. |
| Excepciones/configuración | Errores JSON y CORS configurable para clientes web. |

Flutter consume los DTOs, no entidades JPA. El ZIP ahora incluye `docs/dto-contract.json` y `docs/flutter-api.md`, generados específicamente para las clases del diagrama: nombres de campos, tipos Java/JSON/Dart, claves, anulabilidad, restricciones, filtros y ejemplos. DateTime se transmite sin zona porque el tipo Java es LocalDateTime. Decimal es un número JSON; su precisión y escala se validan antes de persistir.

Las actualizaciones PUT representan el DTO completo; no son PATCH. La clave puede omitirse del cuerpo, pero si se incluye debe coincidir con la ruta. Los errores incorporan `fieldErrors` para asociar mensajes con controles del frontend. JSON o identificadores mal formados devuelven 400 con una explicación del contrato.

## Postman

Se corrigieron ejemplos que enviaban UUID incluso para claves foráneas Integer/Long/String, y las URL dejaron de contener componentes contradictorios. La colección incluye variables de IDs, captura de la clave devuelta por POST y pruebas HTTP/JSON.

El orden es: altas de entidades referenciadas → consultas y modificaciones → bajas en orden inverso. Las modificaciones cambian un atributo simple cuando está disponible. El entorno local usa `baseUrl=http://localhost:8081`.

La colección completa elimina sus registros de ejemplo. Ejecutarla en una base de prueba; para conservar datos de demostración, omitir las solicitudes Eliminar. Las relaciones opcionales empiezan en null; los ciclos obligatorios se advierten porque no hay un orden de altas automático sobre una base vacía.

## Ejecución

- **Docker:** el ZIP contiene Dockerfile, Compose, `.env.example`, `.dockerignore` y README. Copiar el ejemplo de entorno, configurar la contraseña y ejecutar `docker compose up -d --build`.
- **IDE/local:** abrir pom.xml, configurar DATABASE_URL, DB_USER, DB_PASSWORD y PORT en el entorno de ejecución, compilar con Maven y ejecutar la clase principal o el JAR. Compose carga `.env`; Java/Maven no lo carga por sí solo.
- **Puertos predeterminados:** API 8081 y PostgreSQL 5433, publicado solamente en localhost. El diseñador puede seguir en 8080.
- **Despliegue:** Compose en un servidor o Dockerfile con PostgreSQL externo y variables de entorno. Java se ejecuta sin usuario root. La documentación del ZIP explica salud, persistencia, emulador Android, teléfono físico y CORS.

Para generar otra copia del ejemplo desde el repositorio:

```powershell
npm run typecheck
npm run demo:backend
```

Se crea una carpeta nueva bajo `generated-output/demo-ventas-*` con el ZIP, el proyecto descomprimido y el diagrama XMI/JSON. También se puede importar ese XMI en una pizarra y usar la generación normal de la interfaz.

## Verificación

- 454 pruebas unitarias y de regresión aprobadas; 22 corresponden al generador y sus artefactos para clientes.
- TypeScript, ESLint y formato aprobados.
- 29 pruebas de integración de generación y descarga HTTP aprobadas, con PostgreSQL temporal.
- Ejemplo de ventas construido y desplegado con el Dockerfile/Compose exportados: API y PostgreSQL saludables, proceso Java sin root. Las 20 solicitudes de su colección y scripts pasaron contra ese despliegue.
- Compilación y ejecución real de ventas con claves UUID, modelo con herencia y ventas con claves Integer: PostgreSQL limpio, OpenAPI, colección Postman exportada, CRUD, reinicio, persistencia y restricciones de borrado.
- Se verificaron también errores por campos obligatorios, identificadores mal formados y discrepancia entre clave del cuerpo y URL. Las solicitudes y los scripts exportados se ejecutaron mediante un arnés compatible con las APIs de Postman utilizadas; no se automatizó su aplicación de escritorio.

## Alcance

### Ejemplo disponible en este equipo

Carpeta: `generated-output/demo-ventas-N3AkPY/backend`. API: `http://localhost:8081`; PostgreSQL de este ejemplo: `localhost:5434`. Se ajustó únicamente el `.env` de la copia generada porque el PostgreSQL del diseñador ya ocupa 5433. El `.env` de `infra` se conserva.

La base del ejemplo quedó vacía después del ensayo. Importar `postman/collection.json` y `postman/local.environment.json` de esa carpeta. Para detenerlo, ejecutar `docker compose stop` desde la misma carpeta; `docker compose start` lo reanuda. Su `.env` conserva el nombre del proyecto Compose aislado. Los archivos se pueden volver a generar mediante `npm run demo:backend`.

### Límites del generado

El generado cubre gestión CRUD y restricciones estructurales. No infiere descuentos de inventario, cálculos contables ni reglas de negocio no expresadas en el diagrama. No incluye autenticación, permisos de negocio ni sincronización offline. Antes de publicar datos reales hacen falta esos controles, HTTPS y una estrategia de migraciones/respaldo.

La lista GET todavía no está paginada. Los filtros actuales por clave foránea se usan individualmente; enviarlos juntos no implementa una búsqueda combinada. Las altas con clave existente devuelven el registro previo; no actualizan ni comparan el contenido de un reintento.

Referencias oficiales consultadas para la configuración externa y variables de prueba: [Spring Boot](https://docs.spring.io/spring-boot/reference/features/external-config.html) y [Postman](https://learning.postman.com/docs/tests-and-scripts/write-scripts/postman-sandbox-reference/pm-variables/).
````

---

### `docs/generacion-flutter-android.md`

```markdown
# Generación Flutter Android y backend de gestión

Actualización de modelos locales: la plantilla incorpora biblioteca de archivos,
selección independiente de voz/texto, LiteRT-LM y GGUF para instrucciones, y
Whisper GGML para dictado local. Esta ampliación sustituye el selector de un solo
GGUF y el dictado del reconocedor de Android descritos en las revisiones históricas
de abajo. Configuración y límites en la
[guía de modelos locales de la plantilla](../templates/flutter/docs/local-models.md.tpl).
La integración remota con las IA de `infra/.env` y la lectura directa de OpenAPI
siguen pendientes; el contrato móvil y la cola SQLite se conservan.

Revisión del 6 de septiembre de 2026. Se incorporó un generador opcional de Flutter Android a partir del mismo diagrama y DTO que Spring Boot. La generación usa plantillas deterministas: no llama a proveedores IA ni consume tokens. El asistente generado utiliza un GGUF local cuando el usuario lo carga.

Comprobación posterior: [8 diagramas de gestión, 34 recursos CRUD y aclaración CORS](revision-generador-crud.md). Se verificaron los backends del perfil Android y siete pruebas de SQLite/cola, sin probar el agente IA.

## Ampliación en código: cliente reutilizable y agente offline

La revisión posterior añade `/mobile-contract` autenticado al backend y su lectura en el login Android. La misma base Flutter adopta recursos, campos, claves y relaciones del backend conectado, conserva el contrato para abrir offline y comprueba compatibilidad antes de enviar cambios. El cambio de servidor se realiza cerrando sesión e iniciando en la otra URL. Datos y colas quedan separados por servidor/cuenta/contrato; se conserva el espacio local del contrato original del APK previo.

El agente propone CREATE, UPDATE, DELETE o LIST utilizando el contrato y los registros filtrados. Las operaciones confirmadas se guardan en la misma SQLite que los formularios; LIST muestra datos locales. Los UUID de altas se generan en el dispositivo. `AgentPort` permite sustituir el motor local sin cambiar el repositorio, y la selección de plantilla GGUF (incluida `gemma`) se conserva al reabrir. El motor local funciona igual con o sin internet; la compatibilidad de pesos cuantizados concretos debe probarse.

La cola permite consolidar ediciones que nunca se intentaron enviar y cancelar altas locales eliminadas antes del primer envío. A partir del primer intento mantiene la solicitud inmutable. `tool/start_backend.dart` prepara credenciales aleatorias si falta `.env` y arranca Compose, con puertos configurables. No reemplaza configuraciones existentes.

**Estado de esta ampliación:** APK debug ARM64 compilado; análisis Flutter, TypeScript y lint aprobados. Se ejecutaron 4 pruebas Flutter de contrato/login y 23 del generador. Backend real con PostgreSQL: contrato autenticado, login, sincronización y preflight CORS permitido/rechazado para CRUD, login, contrato y cola aprobados. La revisión posterior agregó ocho modelos completos, un caso con claves enteras y siete pruebas de almacenamiento/cola, incluida consolidación offline. No se ejecutaron pruebas del agente, inferencia GGUF ni dictado, por indicación del usuario. El bloqueo anterior por límite de uso dejó de impedir estas verificaciones.

La base incluye registro de pantallas en `mobile/lib/ui/custom_pages.dart`: se muestran según los recursos disponibles en el contrato. Añadir pantallas propias requiere recompilar Flutter; cambiar URL/contrato compatible no. La guía `mobile/docs/extension-and-deployment.md` incluye un ejemplo completo, variables de despliegue, HTTPS, CORS y distribución. Se emite `backend/railway.json` para Docker y healthcheck. No se ha publicado ningún servicio externo.

La compatibilidad abarca los backends emitidos con el perfil Android de esta versión. Para usar un backend REST diferente hay que implementar el protocolo de login, contrato y sincronización. La primera configuración necesita internet; después la cola funciona offline. El envío automático ocurre con la app abierta o al reabrir, no como un servicio Android permanente. Cambios incompatibles de esquema requieren resolver la cola con el backend anterior; no se migran automáticamente datos de negocios distintos.

## Cómo usarlo

1. En la pizarra, abrir **Generación**, marcar **Incluir Flutter Android con login, datos offline y modelo GGUF** y generar.
2. Descargar **Android + backend**. El ZIP contiene `backend/`, `mobile/` y sus instrucciones. Usar el backend de este paquete para el móvil: incluye autenticación y sincronización.
3. Copiar `backend/.env.example` a `backend/.env` y configurar `DB_PASSWORD`, `AUTH_PASSWORD` y `AUTH_TOKEN_SECRET`. Los valores AUTH se entregan vacíos; reemplazar también el marcador de contraseña de PostgreSQL. La contraseña de acceso requiere al menos 12 caracteres y como máximo 72 bytes; el secreto requiere 32 caracteres como mínimo. Generarlo aleatoriamente.
4. En `backend/`, ejecutar `docker compose up -d --build`. También puede ejecutarse con Java/Maven y PostgreSQL externo, según su README. Postman incluye login y captura automática del token; configurar usuario y contraseña en un entorno privado.
5. Instalar Flutter y Android SDK/NDK. En `mobile/`, ejecutar `dart run tool/bootstrap.dart`, `flutter pub get` y `flutter run`. El bootstrap crea el proyecto Android nativo con el SDK local sin reemplazar uno existente. Compilación probada con Flutter 3.44 / Dart 3.12, Android ARM64, API mínima 26.
6. El emulador usa `http://10.0.2.2:8081`. En un teléfono configurar la dirección LAN del servidor. HTTP solo se permite en debug; release necesita HTTPS y firma propia.
7. En Asistente, cargar un GGUF compatible y elegir su plantilla de conversación. Después de reiniciar, pulsar **Abrir guardado**. Los pesos no se incluyen ni se descargan automáticamente.

Si está levantada la plataforma UML o el ejemplo anterior, sus puertos pueden estar ocupados: elegir otros `APP_PORT` y `DB_PORT` en el `.env` del backend generado (por ejemplo 8082 y 5435 si están libres) y usar ese puerto de aplicación en el login móvil. El ejemplo anterior no fue sustituido.

Ejemplo reproducible desde este repositorio: `npx tsx scripts/generate-demo-backend.ts --mobile`. Crea un directorio nuevo dentro de `generated-output/`, el ZIP, el diagrama XMI y el modelo JSON. Comprobación real del backend: `npx tsx scripts/verify-mobile-backend.ts` (Java, Maven y Docker necesarios).

## Implementado

- Spring Boot/PostgreSQL con Modelo, Repositorio, Servicio, Controlador y DTO; validaciones, errores JSON, OpenAPI, Postman, Dockerfile y Compose.
- Perfil Android con administrador configurado por entorno y Bearer token. Las rutas de datos requieren autenticación. El ZIP Spring independiente conserva su comportamiento anterior.
- Flutter Material 3 con login, colecciones, CRUD, búsqueda local, asistente y ajustes. Capas UI/ViewModel, repositorio y HTTP/SQLite; relaciones mediante IDs del contrato.
- Sesión en almacenamiento seguro; no guarda la contraseña. Datos y cola SQLite separados por servidor, cuenta y contrato.
- Guardado local transaccional antes del envío. Reintentos mantienen operación, ID, datos y base; PostgreSQL guarda recibos transaccionales para evitar duplicados, incluso después de reiniciar el backend.
- Detección de cambios remotos y conflictos; confirmación para descartar un cambio rechazado y aceptar el servidor. Un error de red no permite descartar una operación posiblemente aplicada.
- Protección contra formularios o propuestas abiertas sobre datos que cambiaron durante la revisión. Las operaciones pendientes se mantienen inmutables hasta sincronizar o resolver su conflicto.
- GGUF en el dispositivo, contexto acotado al recurso y registros filtrados, salida JSON validada y revisión antes de ejecutar. No permite SQL, URLs ni llamadas arbitrarias propuestas por el modelo.

## Evidencia

- TypeScript y ESLint: sin errores.
- 455 pruebas unitarias del repositorio aprobadas.
- Integración HTTP de generación: 29 pruebas aprobadas, incluyendo bytes/hash de ambos objetivos.
- Backend móvil real compilado y ejecutado con PostgreSQL: login válido/inválido, rutas protegidas, IDs, reintentos concurrentes, recibos tras reinicio, conflictos y borrados aprobados.
- Flutter: `analyze` sin incidencias y 8 pruebas aprobadas. Incluyen login a 360 px sin desbordamiento, persistencia SQLite tras reapertura, confirmación perdida, edición obsoleta, conflictos y validación de propuestas.
- APK debug ARM64 compilado. Esto no acredita rendimiento de un modelo GGUF ni funcionamiento del reconocedor de voz en un teléfono concreto.
- Navegador Chromium contra la app local actualizada: 2 pruebas aprobadas, incluyendo descarga de ambos ZIP y visibilidad de los botones. API y web están funcionando tras aplicar la migración de generación Android.

## Faltantes y límites concretos

| Prioridad | Pendiente | Criterio para cerrarlo |
| --- | --- | --- |
| Alta, demostración | GGUF real en Android físico | Cargar un modelo de instrucciones con licencia adecuada, probar altas/ediciones/negaciones en modo avión y medir RAM, latencia y batería. |
| Alta, demostración | Voz totalmente offline | Verificar reconocedor e idiomas locales instalados. El dictado solicita procesamiento local, pero Android puede finalizar la escucha; GGUF interpreta texto, no transcribe audio. Si se requiere voz continua garantizada, hace falta un motor STT local controlado por la app. |
| Alta, entrega | Recorrido completo con Flutter físico y PostgreSQL | Primer login, modo avión, CRUD por texto/voz, cierre/reapertura, reconexión, conflicto entre dispositivos y referencias entre entidades. |
| Antes de publicación | Distribución y acceso | Firma release, HTTPS, copias/restauración y permisos del caso de uso. El login generado es un administrador compartido, sin registro, recuperación, roles ni aislamiento por empresa. |
| Según el caso | Reglas de negocio | Cobros, inventario, totales y transacciones entre entidades no se deducen del UML; implementar el flujo específico de gestión. |
| Escala/producción | Sincronización incremental | Se descargan colecciones completas; no hay paginación incremental ni merge automático. Definir retención de recibos y migración de datos locales al cambiar el contrato. |
| Automatización | Validación Android en CI | La compilación y pruebas se ejecutaron localmente; incorporar SDK/NDK y pruebas del APK a la canalización según el entorno de CI. |

La sesión remota dura 15 minutos; volver a iniciar sesión con la misma cuenta conserva la cola. Los datos SQLite no están cifrados y dependen del aislamiento y bloqueo del dispositivo. La comparación de conflictos usa el DTO original: una modificación que vuelve al mismo contenido puede no distinguirse de su versión original. No se promete sincronización semántica entre operaciones de negocio.

## Incidencias adicionales encontradas

SambaNova estaba habilitado como respaldo con credencial vacía, impidiendo iniciar toda la API. Se desactivó únicamente esa entrada en las cadenas locales de texto/visión y se añadieron al Compose las variables SambaNova y la URL Groq que faltaban. Para activarlo, configurar su credencial y cambiar `enabled` a `true`.

La auditoría npm informa cuatro dependencias con severidad alta en el árbol de Prisma (`prisma`, `@prisma/config`, `deepmerge-ts` y `mysql2`). La solución automática propuesta baja Prisma de versión mayor; no se aplicó por riesgo de incompatibilidad. Revisar actualización compatible y exposición real por separado. El backend generado usa PostgreSQL. Gradle también advierte que tres plugins aún aplican KGP; compiló, pero habrá que validar compatibilidad al actualizar Flutter.
```

---

### `docs/guia-pruebas-despliegue-app-generada.md`

````markdown
# Pruebas y despliegue de una aplicación generada desde UML

Guía de ejecución para Windows PowerShell · Spring Boot y Flutter Android · 11 de septiembre de 2026

Este procedimiento lleva una aplicación generada desde el diagrama hasta una API probada con Postman, un backend publicado en Railway y un APK instalado en Android. Incluye pruebas de voz y texto con modelos locales, persistencia offline y sincronización al reconectar.

Sigue el perfil **Android + backend** de principio a fin. El generador produce código y un ZIP; no compila ni publica automáticamente el APK. Spring Boot se ejecuta en tu PC o en la nube. Flutter se instala en el teléfono. Los modelos de IA se importan por separado.

## Recorrido

1. Preparar herramientas y descargar el paquete correcto.
2. Configurar y ejecutar Spring Boot con PostgreSQL local.
3. Importar y ejecutar las pruebas de Postman.
4. Crear PostgreSQL y desplegar la API en Railway.
5. Repetir las pruebas contra la URL pública HTTPS.
6. Preparar Flutter, compilar e instalar el APK de prueba.
7. Importar modelos y verificar el ciclo offline completo.
8. Preparar firma release y conservar las evidencias.

## Convenciones

Los comandos son para PowerShell. Cambia los valores que empiezan por TU o MI por los de tu proyecto. Cada bloque indica su carpeta de ejecución. Usa la misma terminal para conservar las variables; si la cierras, vuelve a definirlas.

La ruta de trabajo de ejemplo será C:\Pruebas\MiApp. La variable $appRoot siempre identifica la carpeta que contiene backend y mobile. No es la carpeta del código fuente de la plataforma UML.

**Datos de prueba:** usa un backend y una base destinados a pruebas. La colección generada crea, modifica y elimina sus registros. No ejecutes su Runner completo sobre registros reales.

**Criterio de éxito:** Postman aprueba las solicitudes, la API pública devuelve salud UP, el APK inicia sesión, guarda un cambio sin red y lo envía una sola vez al reconectar.

---

## 1 Preparar herramientas y generar el paquete

Instala Docker Desktop y ejecútalo en modo contenedores Linux. Instala Postman Desktop, Flutter estable con Android Studio y Android SDK. Para Railway CLI necesitas Node.js y npm. Java 21 y Maven solo se necesitan por separado si ejecutas Spring sin Docker; Android necesita un JDK compatible con Flutter y Gradle, normalmente el incluido en Android Studio.

Verifica en PowerShell:

```powershell
docker version
docker compose version
flutter --version
flutter doctor -v
flutter doctor --android-licenses
node --version
npm --version
```

Acepta las licencias que correspondan. En Android Studio instala Android SDK Platform 36, Platform Tools, Command-line Tools y NDK 29.0.13113456. La plantilla fue compilada con Flutter 3.44 y Dart 3.12; la versión mínima de Android es API 26. La primera compilación necesita internet para dependencias.

En la plataforma UML, abre el diagrama, corrige los errores de validación y marca **Incluir Flutter Android con login, datos offline y modelos locales**. Pulsa **Generar proyecto** y luego **Descargar Android + backend**. Guarda también el diagrama y su versión para poder repetir la generación.

Descomprime en una carpeta nueva. Sustituye el nombre del ZIP:

```powershell
$zipPath = "$env:USERPROFILE\Downloads\TU-APP-android.zip"
$appRoot = 'C:\Pruebas\MiApp'
Expand-Archive -LiteralPath $zipPath -DestinationPath $appRoot
Set-Location $appRoot
Get-ChildItem
Test-Path .\backend\pom.xml
Test-Path .\mobile\pubspec.yaml
```

Los dos últimos comandos deben devolver True. Si el descompresor creó otra carpeta intermedia, ajusta $appRoot. El paquete debe contener backend\postman\collection.json, backend\postman\local.environment.json, backend\Dockerfile, backend\railway.json y mobile\tool\bootstrap.dart.

Si descargaste solo Spring, su carpeta raíz contiene pom.xml y no tiene mobile. Ese paquete no incluye el perfil de autenticación y sincronización necesario para seguir todo este manual: vuelve a descargar Android + backend.

---

## 2 Configurar y levantar el backend local

Carpeta: backend del paquete. El archivo correcto es backend\.env; **infra\.env pertenece a la plataforma UML y no configura la aplicación exportada**.

```powershell
Set-Location "$appRoot\backend"
if (!(Test-Path .env)) { Copy-Item .env.example .env }
notepad .env
```

Conserva DB_NAME y DB_USER de la plantilla. Configura APP_PORT=8082 y DB_PORT=5435 para esta guía. Cambia DB_PASSWORD, AUTH_PASSWORD y AUTH_TOKEN_SECRET. Usa AUTH_USERNAME=admin u otro nombre propio. AUTH_PASSWORD debe tener al menos 12 caracteres y como máximo 72 bytes UTF-8; AUTH_TOKEN_SECRET, al menos 32 caracteres.

Puedes generar un secreto y copiarlo en el archivo; ejecuta la función una vez por cada valor que quieras generar:

```powershell
function New-AppSecret {
  $bytes = New-Object byte[] 32
  $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
  try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
  [Convert]::ToBase64String($bytes)
}
New-AppSecret
```

Guarda el archivo y levanta los servicios:

```powershell
docker compose up -d --build
docker compose ps
docker compose logs --tail 80 api
$localUrl = 'http://localhost:8082'
Invoke-RestMethod "$localUrl/actuator/health"
```

Resultado esperado: db y api saludables y respuesta con status UP. El puerto 8082 es externo; dentro del contenedor la API escucha en 8080. PostgreSQL local se publica solo en localhost:5435. No necesitas instalar Maven en el host para este recorrido.

Abre http://localhost:8082/swagger-ui.html. OpenAPI está en http://localhost:8082/v3/api-docs. Para detener y reanudar sin borrar la base, desde backend usa docker compose stop y docker compose start. Después de modificar variables, usa docker compose up -d --build para recrear lo necesario.

No uses docker compose down -v para reiniciar una prueba: elimina el volumen de PostgreSQL. Cambiar DB_PASSWORD en un volumen ya inicializado tampoco cambia automáticamente la contraseña existente.

---

## 3 Importar Postman e iniciar sesión

Usa Postman Desktop para acceder a localhost. En Import selecciona estos archivos del paquete:

```text
backend/postman/collection.json
backend/postman/local.environment.json
```

Selecciona el entorno importado y agrega los siguientes valores locales o privados:

| Variable | Valor para esta prueba |
| --- | --- |
| baseUrl | http://localhost:8082 |
| username | El AUTH_USERNAME de backend/.env |
| password | El AUTH_PASSWORD de backend/.env |

No agregues /api ni una barra final a baseUrl. Evita una variable de entorno accessToken: el login generado guarda el token en la colección y una variable homónima de entorno podría ocultarlo. No compartas ni exportes contraseñas o tokens a un espacio público.

Abre **Iniciar sesion**, la primera solicitud de la colección. Debe usar POST {{baseUrl}}/session/login, Authorization No Auth y cuerpo raw JSON:

```json
{"username":"{{username}}","password":"{{password}}"}
```

Pulsa Send. Espera HTTP 200 con accessToken, username, expiresAt y refreshToken. El script incluido comprueba el login y guarda accessToken en las variables de la colección. Las solicitudes CRUD deben heredar su autorización Bearer.

Agrega una solicitud GET {{baseUrl}}/mobile-contract con autorización heredada. Espera HTTP 200, protocolVersion=1 y las colecciones del diagrama. Si devuelve 404, probablemente levantaste el backend Spring independiente o una exportación antigua.

Agrega también GET {{baseUrl}}/actuator/health con No Auth. Debe responder UP. Un GET de datos sin Bearer debe ser rechazado. No publiques los tokens en capturas de evidencia.

El access token dura 15 minutos. Si Postman devuelve 401 tras ese tiempo, vuelve a ejecutar Iniciar sesion. La colección no añade una renovación automática a cada solicitud; Flutter sí dispone de renovación de sesión.

Referencia de variables: https://learning.postman.com/docs/sending-requests/variables/variables/

---

## 4 Ejecutar CRUD y guardar las evidencias

En la colección selecciona Run o Collection Runner. Elige el entorno local, una iteración y el orden original. Mantén **Iniciar sesion** al principio. Ejecuta todas las solicitudes solo sobre la base de prueba.

El orden generado crea las entidades referenciadas antes de sus dependientes y elimina en orden inverso. Los scripts capturan IDs y comprueban respuestas. Si el diagrama contiene ciclos de relaciones obligatorias, consulta las notas de la colección: puede requerir datos iniciales o corregir multiplicidades.

**Resultado esperado:** tests sin fallos, altas y consultas correctas y limpieza de los registros del recorrido. Si quieres conservar datos para el móvil, ejecuta manualmente las altas y consultas y omite las eliminaciones. No repitas un alta con la misma clave sin comprobar si ya existe.

Para una prueba manual elige una colección simple de tu diagrama. Copia el cuerpo JSON que generó Postman; no inventes los campos. Completa todos los obligatorios y usa IDs existentes para las relaciones. PUT requiere el DTO completo, incluida su clave.

| Paso | Comprobación |
| --- | --- |
| Crear | La respuesta contiene el ID y los valores enviados |
| Listar y consultar ID | El registro aparece con sus campos correctos |
| Editar | Se conserva el ID y cambia únicamente lo previsto |
| Eliminar | El registro deja de aparecer y su consulta por ID devuelve 404 |
| Dato inválido | Un obligatorio vacío o tipo incorrecto recibe rechazo HTTP |

Guarda el resultado del Runner, capturas de las respuestas y el snapshot del diagrama en una carpeta de evidencias. El número de solicitudes depende del diagrama; no esperes una cantidad fija.

Como comprobación de salud independiente, desde backend puedes guardar:

```powershell
New-Item -ItemType Directory -Force "$appRoot\evidencias"
Invoke-RestMethod "$localUrl/actuator/health" |
  ConvertTo-Json -Depth 5 |
  Set-Content "$appRoot\evidencias\salud-local.json"
```

Las solicitudes CRUD directas de Postman no usan la cola del móvil. No reenvíes a ciegas un POST cuya respuesta se perdió: primero consulta si existe. La idempotencia de sincronización se implementa mediante /mobile-sync.

Referencia del Runner: https://learning.postman.com/docs/tests-and-scripts/running-collections/intro-to-collection-runs

---

## 5 Preparar Railway y PostgreSQL

Esta guía usa Railway con dos servicios en el mismo proyecto y entorno: **Postgres** y **api**. Revisa el costo en Railway antes de crearlos. La base de la nube empieza vacía; desplegar el código no copia tus datos locales.

1. En https://railway.com crea un proyecto vacío.
2. Añade un servicio PostgreSQL y conserva su nombre Postgres para las referencias siguientes.
3. Añade un servicio vacío llamado api. El código se subirá con CLI en el paso siguiente.
4. En api → Variables configura los valores de la tabla. Si tu servicio de base tiene otro nombre, sustituye Postgres por ese nombre exacto.

| Variable en api | Valor |
| --- | --- |
| DATABASE_URL | jdbc:postgresql://${{Postgres.PGHOST}}:${{Postgres.PGPORT}}/${{Postgres.PGDATABASE}} |
| DB_USER | ${{Postgres.PGUSER}} |
| DB_PASSWORD | ${{Postgres.PGPASSWORD}} |
| PORT | 8080 |
| AUTH_USERNAME | Tu administrador de nube |
| AUTH_PASSWORD | Contraseña propia de 12 caracteres mínimo y 72 bytes máximo |
| AUTH_TOKEN_SECRET | Secreto aleatorio de al menos 32 caracteres |

Copia las referencias ${{...}} en el panel de Railway, no como comandos PowerShell. Usa la función New-AppSecret de la sección 2 para generar valores nuevos. Conserva el secreto de firma durante las actualizaciones normales. Cambiar credenciales o secreto invalida las sesiones anteriores.

El código requiere una URL **JDBC**. No copies directamente el DATABASE_URL de Postgres con formato postgresql://usuario:clave@host/base: ese valor no es el formato que espera esta plantilla Spring.

Mantén PostgreSQL en la red privada del proyecto. Su PGHOST debe apuntar al servicio interno, no a localhost ni al nombre db de Docker Compose. La API será el único servicio con dominio público.

CORS_ALLOWED_ORIGINS puede omitirse para Android nativo y Postman. Si agregas una web propia, configura sus orígenes exactos. No copies las claves IA de infra/.env al teléfono: este recorrido del agente es local.

Referencias: https://docs.railway.com/databases/postgresql y https://docs.railway.com/variables

---

## 6 Subir la API y obtener una URL HTTPS

Carpeta: raíz del paquete, donde están backend y mobile. Instala Railway CLI en tu equipo e inicia sesión:

```powershell
Set-Location $appRoot
npm install -g @railway/cli
railway --version
railway login
railway link
```

En los selectores de railway link elige el proyecto, el entorno y el servicio api que acabas de crear. Antes de subir, verifica que backend\.gitignore excluya .env y target. El paquete actual ya lo hace. No uses --no-gitignore.

Como se subirá solo backend, deja Root Directory del servicio en / y usa /railway.json como archivo de configuración, si Railway pide indicarlo. No configures /backend en esta modalidad: el comando convierte esa carpeta en la raíz del archivo subido.

```powershell
railway up ./backend --path-as-root --service api
railway logs --service api
```

El primer comando sube código y despliega; puede generar cargos según tu plan. Railway debe construir con el Dockerfile del paquete y usar /actuator/health como healthcheck. No agregues un Start Command propio: el Dockerfile ya inicia Java. Si los logs siguen abiertos, Ctrl+C deja de seguirlos; no detiene el servicio.

En api → Settings → Networking → Public Networking pulsa Generate Domain y elige el puerto 8080, igual al PORT configurado. Copia el dominio HTTPS. Desde cualquier carpeta:

```powershell
$cloudUrl = 'https://TU-DOMINIO.up.railway.app'
Invoke-RestMethod "$cloudUrl/actuator/health"
```

Espera status UP. Prueba también /swagger-ui.html y /v3/api-docs. El archivo railway.json ya define el constructor Docker y la ruta de salud. Revisa build logs si falla la compilación y deploy logs si Java inicia pero no consigue conectar a PostgreSQL.

Alternativa GitHub: sube el paquete a un repositorio privado excluyendo secretos, firmas y modelos. Si el repositorio contiene backend y mobile, configura Root Directory=/backend y Config File=/backend/railway.json. Esta configuración es distinta de la subida CLI anterior; elige una modalidad.

Referencias: https://docs.railway.com/cli/deploying y https://docs.railway.com/networking/public-networking

---

## 7 Probar la nube desde Postman

Duplica el entorno local y llámalo MiApp nube pruebas. Cambia baseUrl por tu URL HTTPS sin /api ni barra final. Cambia username y password por los del servicio api en Railway.

Ejecuta Iniciar sesion otra vez: un token del backend local no autentica el de la nube. Si existe una variable accessToken en el entorno, elimínala para dejar que se use la variable de colección que actualiza el login.

Repite la prueba de salud, contrato y Runner completo de las secciones 3 y 4 sobre la base de nube destinada a pruebas. Al cambiar entre local y nube, inicia sesión cada vez. El token almacenado en la colección corresponde al último backend usado.

Luego crea un registro de prueba que quieras conservar para verificar desde el teléfono. Usa un ID nuevo, guarda el ID y no ejecutes su eliminación. El móvil deberá descargarlo tras iniciar sesión y sincronizar.

## 8 Preparar y compilar Flutter

Vía corta: desde la raíz del paquete, `.\apk.bat install` (Windows) o `sh apk.sh install` hace todo lo de esta sección, deja el APK en `mobile\dist\` y lo instala en el teléfono conectado por USB. `.\apk.bat doctor` comprueba Flutter, adb y el teléfono. Los pasos manuales equivalentes, carpeta mobile:

```powershell
Set-Location "$appRoot\mobile"
dart run tool/bootstrap.dart
flutter pub get
flutter analyze
flutter test
flutter build apk --debug --target-platform android-arm64
```

Bootstrap crea android a partir del Flutter instalado y aplica permisos, SDK y configuración de las bibliotecas locales. Si android ya existe, no la sobrescribe. Para repetir desde una exportación nueva, usa una carpeta nueva y conserva tus personalizaciones anteriores por separado.

Resultado esperado: análisis sin errores, pruebas aprobadas y mensaje Built ...app-debug.apk. El APK está aquí, relativo a la raíz del paquete:

```text
mobile/build/app/outputs/flutter-apk/app-debug.apk
```

Puedes copiarlo a la raíz para transferirlo:

```powershell
Copy-Item .\build\app\outputs\flutter-apk\app-debug.apk `
  "$appRoot\mi-app-pruebas.apk"
```

No necesitas recompilar para cambiar de backend: la URL se escribe en la pantalla de login. API_BASE_URL solo cambia el valor inicial del campo si lo pasas mediante --dart-define; nunca incluyas contraseñas allí. Este APK debug es para Android ARM64, no para iPhone.

---

## 9 Instalar y conectar el celular

Opción directa: copia mi-app-pruebas.apk al teléfono por USB u otro medio privado. Ábrelo con el gestor de archivos y permite instalar desde esa fuente cuando Android lo solicite. Abre la aplicación instalada.

Opción USB con ADB: habilita Opciones de desarrollador y Depuración USB, conecta el teléfono, desbloquéalo y acepta la autorización RSA. Android SDK Platform Tools debe estar en PATH. Desde mobile:

```powershell
adb devices
adb install -r .\build\app\outputs\flutter-apk\app-debug.apk
```

Espera device en el listado y Success al instalar. Si hay varios dispositivos, usa adb -s SERIAL install -r seguido de la misma ruta. Si aparece unauthorized, acepta el permiso en el teléfono.

En login usa **la URL HTTPS de Railway** y las credenciales de nube. Comprueba que aparezcan las colecciones de tu diagrama y el registro creado en Postman. El primer acceso necesita red para recibir el contrato y la sesión.

Para probar contra tu PC, usa la IPv4 de su adaptador Wi-Fi o Ethernet y el puerto 8082. Encuéntrala con ipconfig. Teléfono y PC deben estar en la misma red; el navegador del teléfono debe abrir http://IP-DE-TU-PC:8082/actuator/health antes de intentar el login.

| Dónde corre el cliente | URL del backend local |
| --- | --- |
| Postman en la PC | http://localhost:8082 |
| Emulador Android estándar | http://10.0.2.2:8082 |
| Teléfono físico por Wi-Fi | http://IPv4-DE-TU-PC:8082 |
| Teléfono conectado a nube | https://TU-DOMINIO.up.railway.app |

Si el firewall bloquea la prueba local, en PowerShell como administrador permite solo el puerto y la subred privada necesarios:

```powershell
New-NetFirewallRule -DisplayName 'MiApp API pruebas 8082' `
  -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8082 `
  -Profile Private -RemoteAddress LocalSubnet
```

No desactives el firewall completo. Para retirar esta regla al terminar usa Remove-NetFirewallRule -DisplayName 'MiApp API pruebas 8082'. El APK release requiere HTTPS; el permiso HTTP de la plantilla está limitado a debug.

---

## 10 Importar los modelos de voz y texto

Descarga los archivos con internet y pásalos al teléfono. La aplicación no incluye los pesos ni los descarga automáticamente. Empieza con el modelo que ya te funcionó, Gemma 4 E2B, y Whisper Base multilingüe cuantizado.

| Función | Archivo | Tamaño aproximado |
| --- | --- | --- |
| Texto principal | gemma-4-E2B-it.litertlm | 2,59 GB |
| Texto alternativo | qwen2.5-1.5b-instruct-q4_k_m.gguf | 1,12 GB |
| Voz inicial | ggml-base-q5_1.bin | 59,7 MB |
| Voz para comparar | ggml-small-q5_1.bin | 190 MB |

Enlaces de los archivos para descargar mediante el botón Download de cada página:

- Gemma: https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/blob/main/gemma-4-E2B-it.litertlm
- Qwen: https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/blob/main/qwen2.5-1.5b-instruct-q4_k_m.gguf
- Whisper Base: https://huggingface.co/ggerganov/whisper.cpp/blob/main/ggml-base-q5_1.bin
- Whisper Small: https://huggingface.co/ggerganov/whisper.cpp/blob/main/ggml-small-q5_1.bin

En **Asistente** pulsa Importar LiteRT-LM para Gemma o Importar GGUF para Qwen. Selecciona Modelo de texto. Para Gemma comienza con CPU; para Qwen selecciona plantilla chatml. Importa Whisper con su botón y selecciona Modelo de voz e idioma Español. Evita archivos .en para español.

La app guarda copias privadas, por lo que necesita espacio adicional al archivo descargado. Puedes importar varios modelos y cambiar la selección; los ajustes se conservan por modelo. La RAM necesaria no equivale al tamaño del archivo. Si un modelo no carga, prueba uno menor o CPU; conservar la misma extensión no garantiza compatibilidad de cualquier arquitectura.

Escribe una instrucción sencilla sobre la colección seleccionada y pulsa Preparar propuesta. Luego prueba Dictar con Whisper → Parar y transcribir → corregir texto → Preparar propuesta. Usa nombres de campos reales y proporciona los obligatorios. El system prompt ya está integrado. Toda mutación requiere tu confirmación.

---

## 11 Probar offline y sincronización de inicio a fin

Realiza esta prueba contra un solo backend y cuenta. Cambiar de URL, cuenta o contrato crea un ámbito local diferente; no sirve para migrar pendientes del servidor local a Railway.

1. Con internet, inicia sesión y sincroniza. Confirma que el registro de Postman aparece en el móvil. Importa los modelos antes de desconectarte.
2. Activa modo avión y apaga Wi-Fi. No cierres sesión. Abre una colección simple sin relaciones obligatorias o usa IDs de relaciones ya existentes.
3. Crea manualmente un registro con marcador PRUEBA-OFFLINE-01 en un campo de texto. Completa todos los obligatorios. Comprueba que aparece localmente y queda en Pendientes.
4. Solicita otra alta al agente por texto o voz. Revisa la transcripción y el JSON. Antes de confirmar no debe cambiar ningún dato. Confirma una sola vez y anota el ID.
5. Cierra la aplicación y ábrela aún sin red. La sesión, los registros, los pendientes y los modelos seleccionados deben conservarse. No desinstales ni borres datos de la app.
6. Restablece internet y vuelve a primer plano. Pulsa sincronizar o espera el intento periódico de unos 30 segundos con la app abierta. Espera a que termine.
7. En Postman, inicia sesión en ese mismo backend y consulta los IDs anotados. Deben existir con los valores confirmados. Repite sincronizar y comprueba que no se duplican.
8. Edita un registro desde Postman y sincroniza el móvil. Comprueba la actualización local. Luego elimina un registro de prueba desde el móvil y verifica su ausencia en Postman tras sincronizar.

## Probar un conflicto controlado

Sincroniza un registro y después deja el móvil offline. Edita localmente un campo. Desde Postman modifica ese mismo registro en el servidor con un valor distinto. Reconecta el móvil: debe mostrar conflicto y conservar el cambio local pendiente. Revisa ambos valores antes de elegir **Descartar cambio y aceptar servidor**. Esa acción descarta el cambio rechazado; después puedes volver a editar y sincronizar.

Los cambios de un mismo registro se consolidan antes del primer envío. Después de un intento incierto, la app puede exigir sincronizar antes de editarlo de nuevo para conservar el reintento original. Los conflictos detienen la cola y requieren resolución.

La sincronización no es un servicio permanente con la app cerrada. El CRUD y la IA local no necesitan internet después de preparar la sesión y los modelos; la primera autenticación y el envío al servidor sí lo necesitan. La evaluación real de memoria, voz y latencia requiere un teléfono con los pesos cargados.

---

## 12 Preparar una firma propia para distribución

El debug sirve para pruebas internas. Para distribuir una versión release usa el backend HTTPS y una clave propia. Conserva la misma clave y applicationId para actualizar instalaciones existentes. Genera una clave una sola vez y guárdala fuera del repositorio. Los comandos siguientes son preparación local, no publican en Play Store.

En PowerShell, ajusta la carpeta de firma a una ubicación privada. keytool debe estar en PATH; si no, usa su ruta dentro del JDK que muestra flutter doctor -v.

```powershell
$signingDir = "$env:USERPROFILE\MiAppFirma"
New-Item -ItemType Directory -Force $signingDir
keytool -genkeypair -v -storetype JKS -keyalg RSA -keysize 2048 `
  -validity 10000 -alias upload `
  -keystore "$signingDir\miapp-upload.jks"
Set-Location "$appRoot\mobile"
notepad .\android\key.properties
```

Completa android\key.properties. Usa barras / en storeFile y tus contraseñas reales, sin las palabras TU:

```properties
storePassword=TU_CLAVE_DEL_ALMACEN
keyPassword=TU_CLAVE_DE_LA_LLAVE
keyAlias=upload
storeFile=C:/Users/TU_USUARIO/MiAppFirma/miapp-upload.jks
```

Si keytool usó la misma contraseña para almacén y llave, escribe esa misma en ambas propiedades. No regeneres la llave para cada versión. Haz una copia de seguridad privada del JKS y sus credenciales.

Añade estas exclusiones a mobile\.gitignore; si ya existe, consérvalo y agrega las líneas que falten:

```gitignore
/android/key.properties
*.jks
*.keystore
/.dart_tool/
/build/
*.litertlm
*.gguf
*.bin
```

Antes de publicar revisa applicationId y namespace en android\app\build.gradle.kts. Para la primera distribución define un identificador propio y estable, por ejemplo com.tuorganizacion.miapp; si cambias namespace, adapta también el paquete de MainActivity.kt. Evita compartir un applicationId entre negocios que deban instalarse como aplicaciones separadas.

---

## 13 Configurar Gradle y compilar release

Edita mobile\android\app\build.gradle.kts. Añade al principio, antes de plugins:

```kotlin
import java.util.Properties
import java.io.FileInputStream
```

Después de plugins y antes de android agrega:

```kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
keystoreProperties.load(FileInputStream(keystorePropertiesFile))
```

Dentro de android, antes de buildTypes, agrega el bloque siguiente. Si ya existe una firma release, edítala sin duplicarla:

```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties.getProperty("keyAlias")
        keyPassword = keystoreProperties.getProperty("keyPassword")
        storeFile = file(keystoreProperties.getProperty("storeFile"))
        storePassword = keystoreProperties.getProperty("storePassword")
    }
}
```

En el release existente de buildTypes sustituye la referencia a debug por signingConfigs.getByName("release"). Conserva isMinifyEnabled = false e isShrinkResources = false que prepara bootstrap para esta plantilla.

Desde mobile compila y comprueba:

```powershell
flutter build apk --release --target-platform android-arm64
flutter build appbundle --release
```

APK: build/app/outputs/flutter-apk/app-release.apk. AAB: build/app/outputs/bundle/release/app-release.aab. El APK se instala en teléfonos compatibles; el AAB se sube a Play Console y no se abre directamente para instalar.

Una instalación debug y una release con firmas distintas no pueden actualizarse entre sí. Prueba release en un dispositivo o perfil de pruebas limpio; antes de desinstalar una versión, sincroniza y conserva los datos que necesites. Desinstalar elimina almacenamiento local y modelos importados.

Para Google Play crea la ficha de la aplicación, configura Play App Signing, declaraciones de datos y permisos y utiliza primero la pista de pruebas internas. Verifica los requisitos vigentes en Play Console. Para actualizaciones aumenta el número después de + en version de pubspec.yaml, conserva firma e ID y repite las pruebas.

Referencia de firma y publicación: https://docs.flutter.dev/deployment/android

---

## 14 Resolver los problemas más frecuentes

| Síntoma | Qué revisar |
| --- | --- |
| Puerto ocupado local | Cambia APP_PORT y DB_PORT en backend/.env y repite compose up; actualiza las URLs |
| API no saludable | docker compose logs --tail 100 api y docker compose logs --tail 60 db |
| Error JDBC en nube | DATABASE_URL debe comenzar con jdbc:postgresql:// y usar host privado de Postgres |
| Railway devuelve 502 | Logs de inicio, conexión a base, PORT=8080 y dominio dirigido al mismo puerto |
| Postman devuelve 401 | Ejecuta login contra ese entorno; revisa credenciales y variable accessToken oculta |
| Contrato móvil devuelve 404 | Usa Android + backend, no Spring independiente |
| POST o PUT devuelve 400 o 409 | Tipos, obligatorios, clave duplicada y relaciones; usa el JSON generado |
| APK no se instala | Verifica ARM64, Android 8 o superior, espacio libre y firma de la instalación previa |
| adb muestra unauthorized | Desbloquea teléfono y acepta la huella RSA; revisa cable de datos |
| Teléfono no conecta a PC | Misma red, IPv4 correcta, firewall y prueba /actuator/health desde el teléfono |
| Release rechaza HTTP | Usa URL HTTPS válida; no desactives la comprobación de certificados |
| Modelo no carga | Archivo completo, formato, arquitectura soportada y RAM; prueba CPU o un modelo menor |
| Pendientes no avanzan | Misma URL/cuenta/contrato, app abierta, sesión válida y conflictos resueltos |

No borres bases ni la aplicación como primera solución a un error: podrías perder datos pendientes. Un timeout no demuestra que el servidor haya rechazado el cambio.

## 15 Actualizar y cerrar la prueba

Después de corregir código del backend, desde la raíz del paquete vuelve a ejecutar railway up ./backend --path-as-root --service api. Comprueba salud y repite las solicitudes afectadas. Si cambias el diagrama, exporta primero a otra carpeta y revisa diferencias antes de reemplazar personalizaciones.

La base JPA usa ddl-auto=update para prototipos; no garantiza migraciones seguras entre esquemas. Antes de mantener datos reales prepara migraciones y copias de seguridad. El perfil actual usa un administrador compartido; roles y reglas como cobros o movimientos de stock no se deducen automáticamente del diagrama.

Al terminar la prueba local usa docker compose stop desde backend. Detener Docker local no detiene los servicios de Railway. Revisa los servicios y volúmenes facturados en Railway; no elimines una base que necesites conservar.

---

## 16 Lista final de comprobación

Marca cada punto solo después de observar el resultado. Conserva evidencias sin contraseñas ni tokens.

- [ ] ZIP Android + backend asociado al snapshot correcto.
- [ ] Backend local y PostgreSQL saludables.
- [ ] Login y contrato móvil correctos en Postman.
- [ ] Runner local sin tests fallidos sobre datos de prueba.
- [ ] PostgreSQL de nube y api configurados en el mismo proyecto.
- [ ] API pública HTTPS con salud UP y autenticación de datos.
- [ ] Runner de nube aprobado en el entorno correcto.
- [ ] Flutter analyze, flutter test y compilación terminan correctamente.
- [ ] APK instalado en teléfono y conectado al backend esperado.
- [ ] Registro de Postman visible en el móvil.
- [ ] Whisper y LLM importados y selección conservada al reabrir.
- [ ] Dictado editable y propuesta revisada antes de confirmar.
- [ ] Cambios offline conservados después de cerrar y reabrir.
- [ ] Reconexión envía cambios sin duplicarlos.
- [ ] Conflicto controlado detectado y resuelto de forma explícita.
- [ ] Firma release e identificador conservados para futuras versiones.

Registra en tus evidencias: snapshot, fecha, versión Flutter, modelo y RAM del teléfono, archivo y cuantización de cada modelo, CPU o GPU, tiempo de transcripción, tiempo de propuesta, errores observados y resultado final de cada prueba.

## Documentación de consulta

Las rutas siguientes existen dentro del paquete exportado:

- README.md explica el paquete combinado.
- backend/README.md describe ejecución y configuración del backend.
- backend/docs/dto-contract.json contiene los campos del diagrama.
- backend/postman/collection.json contiene cuerpos, orden y tests.
- mobile/README.md explica compilación y límites de sincronización.
- mobile/docs/local-models.md explica importación y prompts.
- mobile/docs/extension-and-deployment.md explica adaptación y nube.

Herramientas e instalación: https://docs.flutter.dev/install, https://developer.android.com/studio, https://docs.docker.com/desktop/setup/install/windows-install/ y https://www.postman.com/downloads/

Esta guía describe los procedimientos y los resultados que debes comprobar; la aprobación final depende de ejecutarlos con tu diagrama, tu backend desplegado y tu teléfono.
````

---

### `docs/guia-uso-y-pruebas-completa.md`

````markdown
# Guía de uso y prueba de la plataforma, de inicio a fin

Recorre **toda** la aplicación: cuenta, proyectos, colaboración, editor UML,
asistente de IA, importación por imagen y XMI, validación, generación del backend
Spring Boot y ejecución de lo generado. Cada apartado dice qué hacer, qué tiene
que verse y cómo se comprueba que salió bien.

Está escrita para ejecutarse de corrido. Si solo quieres ensayar la defensa, ve
al capítulo 12; si solo quieres probar el ZIP generado, al 10.

**Convenciones.** Los nombres entre comillas —«Generar», «Crear cuenta»— son
literales de la interfaz. Los comandos se ejecutan desde la raíz del repositorio
en PowerShell. Donde diga *dos navegadores*, usa uno normal y otro de incógnito,
o dos perfiles distintos: dos pestañas del mismo perfil comparten la sesión y no
prueban nada.

---

## 0 · Antes de empezar

### 0.1 Requisitos

| Necesitas | Para qué |
|---|---|
| Node 22.15 y npm 11+ | Construir y ejecutar la plataforma |
| Docker con Compose v2 | Base de datos y los cuatro servicios |
| Java 21 y Maven | Solo para compilar el backend generado (capítulos 10 y 11) |
| Chromium/Chrome | El editor y las pruebas de extremo a extremo |

### 0.2 Levantar el entorno

```powershell
npm ci
Copy-Item infra/.env.example infra/.env   # editar POSTGRES_PASSWORD y JWT_SECRET
npm run up
npm run ps
```

Los cuatro servicios tienen que aparecer sanos. Comprobación rápida:

```powershell
curl http://localhost:3001/health    # proceso HTTP
curl http://localhost:3002/health    # proceso de colaboración
start http://localhost:8080          # interfaz
```

Con `npm run dev:api`, `npm run dev:collab` y `npm run dev:web` tienes lo mismo
sin contenedores, y la interfaz pasa a `http://localhost:5173`. Necesitas
igualmente el PostgreSQL de Compose.

### 0.3 Reparto de puertos

Anótalo antes de la demostración: es el fallo más común del día.

| Servicio | Puerto | Se cambia en |
|---|---|---|
| Interfaz (contenedor) | 8080 | `WEB_PORT` de `infra/.env` |
| Interfaz (desarrollo) | 5173 | `npm run dev:web` |
| API | 3001 | `API_PORT` |
| Colaboración | 3002 | `COLLAB_PORT` |
| PostgreSQL de la plataforma | 5432 | `DB_PORT` |
| Adminer (perfil `tools`) | 8081 | `ADMINER_PORT` |
| Origen único (perfil `demo`) | 80 | `PROXY_PORT` |
| **Backend generado** | 8081 | variable `PORT` de su `.env` |
| PostgreSQL del generado | 5433 | su `.env` |

El backend generado y Adminer piden el mismo 8081. Si vas a usar los dos, cambia
uno. Si abres la plataforma desde otra máquina del aula, `WEB_ORIGIN` de
`infra/.env` debe ser exactamente la URL por la que entran
(`http://192.168.x.x:8080`), o el navegador bloqueará todas las llamadas.

### 0.4 Cuentas de demostración

```powershell
npm run seed
```

Es idempotente: puedes repetirlo. Deja dos cuentas y un proyecto con las pizarras
«Ventas» e «Inventario».

| Papel | Correo | Contraseña |
|---|---|---|
| Propietaria | `ana@demo.local` | `demo-plataforma-uml` |
| Editor | `beto@demo.local` | `demo-plataforma-uml` |

Para probar el recorrido completo desde cero —capítulo 1— usa cuentas nuevas y
deja estas para el ensayo.

### 0.5 IA: simulada o real

Por defecto `AI_LLM_PROVIDER=mock`. El asistente responde **sin ninguna clave y
sin internet**, con respuestas deterministas: es lo que permite ensayar y lo que
usan las pruebas. Con `mock` el asistente entiende un vocabulario fijo —capítulo
6.2— y la importación por imagen devuelve siempre el mismo par Cliente/Pedido.

Para usar un proveedor real, pon su clave y su nombre en `infra/.env`
(`AI_LLM_PROVIDER`, `AI_VISION_PROVIDER`, `ANTHROPIC_API_KEY`, `GEMINI_API_KEY`…)
y reinicia con `npm run up`. El detalle está en [`despliegue.md`](despliegue.md)
§1 y [`proveedores-ia.md`](proveedores-ia.md). Una combinación imposible no
arranca: es a propósito.

---

## 1 · Cuenta y sesión

### 1.1 Registro

1. Abre `http://localhost:8080`. Sin sesión, cualquier dirección lleva a `/entrar`.
2. Pulsa «Crear cuenta».
3. Rellena correo, nombre y contraseña (mínimo 8 caracteres) y envía.

**Tiene que pasar:** entras directo a «Mis proyectos». El nombre es el que verán
los demás en las pizarras.

**Prueba el error:** repite el mismo correo. Debe aparecer un mensaje de error y
**no** crear una segunda cuenta.

### 1.2 Entrar y salir

1. Menú de usuario, arriba a la derecha → «Salir».
2. Vuelve a entrar con el mismo correo y contraseña.
3. Prueba una contraseña equivocada: mensaje de error, sin sesión.

**Comprobación de la sesión larga:** con la sesión abierta, recarga la página.
Sigues dentro; el token de acceso se renueva solo.

### 1.3 Perfil: foto, nombre y contraseña

En el menú de usuario → «Mi cuenta» (`/cuenta`):

1. **Foto** — «Elegir foto» con un JPG, PNG o WebP. Se recorta a 256×256 antes de
   enviarse. Tu inicial deja paso a la imagen en la barra superior y en la
   presencia de la pizarra. «Quitar foto» la retira.
2. **Nombre** — cámbialo y guarda. El correo no se puede cambiar, a propósito.
3. **Contraseña** — actual, nueva y repetida. Si las dos nuevas no coinciden, el
   botón no deja seguir.

**Comprobación:** sal y entra con la contraseña nueva. Con la anterior, ya no.

### 1.4 Recuperar la contraseña

El proveedor de correo por defecto es `log`: **no envía correo**, escribe el
mensaje completo en los registros. Es lo que hace utilizable la recuperación en
una red sin salida a internet.

1. En `/entrar`, pulsa «Olvidé mi contraseña» y escribe tu correo.
2. La interfaz confirma el envío (dice lo mismo exista o no la cuenta: no filtra
   quién está registrado).
3. Saca el enlace de los registros:

```powershell
docker compose -f infra/compose.yml --env-file infra/.env logs api | Select-String "correo simulado"
```

4. Abre el enlace `/restablecer?...`, escribe la contraseña nueva dos veces y
   guarda. Luego «Ir a entrar».

**Tiene que pasar:** entras con la contraseña nueva. Reutilizar el mismo enlace
una segunda vez falla: el token se consume.

---

## 2 · Proyectos, pizarras e invitaciones

### 2.1 Crear un proyecto y sus pizarras

1. En «Mis proyectos», escribe un nombre («Sistema de ventas») y «Crear proyecto».
   Entras al proyecto.
2. En «Nueva pizarra», crea «Ventas». Repite con «Inventario».

Un proyecto guarda sus pizarras y sus miembros. La generación se hace **sobre una
pizarra**, no sobre el proyecto: por eso tener dos pizarras distintas es parte de
la demostración.

### 2.2 Renombrar y eliminar

- El lápiz de una pizarra la renombra. La papelera la elimina y **pide escribir su
  nombre** para confirmar: el diagrama se pierde y no hay papelera de reciclaje.
- El propietario puede eliminar el proyecto entero desde su tarjeta en «Mis
  proyectos»; también pide escribir el nombre, y se lleva todas sus pizarras.

**Comprobación:** tras eliminar, la pizarra desaparece para **todos** los
miembros, no solo para ti.

### 2.3 Invitar a alguien

1. En el proyecto, «Invitar al proyecto» → «Invitar como editor» o «Invitar como
   lector». Aparece un código.
2. Cópialo. En el **otro navegador**, con otra cuenta: «Mis proyectos» → pega el
   código en «Unirme con un código» → «Aceptar invitación».

**Tiene que pasar:** la segunda persona ve el proyecto y sus pizarras, con la
insignia de su rol.

### 2.4 Administrar participantes

En el panel «Colaboradores» del proyecto, el propietario puede:

- cambiar el rol de alguien entre **Editor** y **Lector** con el desplegable;
- «Retirar» a un participante, con confirmación.

**Comprobación del rol lector** (importante para la defensa): cambia a Beto a
Lector mientras tiene la pizarra abierta. Su editor pasa a solo lectura —aparece
el aviso— y no puede crear ni mover nada. Sigue viendo en vivo lo que hace Ana.

**Comprobación de retirar:** al retirarlo pierde acceso a todas las pizarras del
proyecto; si tenía una abierta, deja de recibir cambios.

### 2.5 Invitaciones activas

El panel «Invitaciones» lista las vigentes y permite revocarlas. Una invitación
revocada ya no sirve: pruébalo pegando el código después de anularla.

---

## 3 · El editor: dibujar el modelo

Abre una pizarra. Arriba a la izquierda está la caja de herramientas, en el
centro el lienzo, a la derecha las propiedades y las pestañas «Asistente»,
«Importar» y «Generar». El indicador de conexión debe decir **«En vivo»** antes de
tocar nada.

### 3.1 Crear clases

- Botón «Nueva clase», o tecla **C** y clic en el lienzo.
- Al crearla se abre el inspector: escribe el nombre («Cliente»).

Debajo del nombre ves el **código** y la **tabla**: son los nombres que se usarán
al generar Java y SQL. Cambian solos al renombrar, y renombrar **nunca** rompe una
relación: la identidad interna es un UUID, no el nombre.

### 3.2 Atributos

En el inspector, «Nuevo atributo» → nombre → Enter. Para cada uno eliges:

| Marca | Significado |
|---|---|
| Clave primaria | Se convierte en `@Id` de la entidad |
| Requerido | No admite nulos |
| Valor único | Restricción de unicidad |

Y el tipo: String, Integer, Long, Decimal, Boolean, Date, DateTime, UUID.

**Qué probar:** crea `Cliente` con `id` (clave primaria, UUID), `nombre` (String,
requerido) y `correo` (String, único). Si no marcas ninguna clave primaria, la
plataforma la infiere o la genera y te lo dice en el panel de revisión: no es un
error, es un aviso.

### 3.3 Relaciones

Dos formas, las dos hay que saberlas para la defensa:

1. **Arrastrando** — del conector derecho de una clase al conector izquierdo de
   otra.
2. **Con la herramienta** — elige «Asociación», «Generalización», «Composición» o
   «Agregación» en la caja (o teclas **1**, **2**, **3**, **4**), luego clic en la
   clase origen y clic en la clase destino. **Escape** vuelve a seleccionar.

Con la relación seleccionada, el inspector permite cambiar:

- el **tipo UML** (asociación, generalización, composición, agregación);
- la **multiplicidad** de cada extremo (`1`, `0..1`, `0..*`, `1..*`);
- el **nombre del rol** de cada extremo.

**Qué probar:** `Cliente 1 → 0..* Pedido`. La línea muestra una multiplicidad en
cada extremo. Cambia el tipo a composición: aparece el diamante relleno. A
generalización: el triángulo. En la generalización el origen es la **subclase**.

Dos roles distintos entre las mismas clases (`domicilio` y `facturación`) deben
convivir como dos relaciones separadas.

### 3.4 Mover, seleccionar y borrar

- Arrastra una clase: la posición viaja a los demás en vivo.
- **Supr** borra lo seleccionado (clase o relación). Borrar una clase se lleva sus
  relaciones.
- **V** o **Escape** vuelven a la herramienta de selección.
- La miga de pan de arriba te devuelve al proyecto; «Salir» cierra la sesión.

### 3.5 El panel de revisión

Bajo el lienzo, «Revisión del modelo» lista lo que el validador encuentra, con el
texto de qué pasa y qué hacer. Cuando no hay errores dice «El modelo no tiene
observaciones» y el pie del panel de generación muestra **«Generación
disponible»**.

Los errores que **bloquean** la generación están en el capítulo 7, con la receta
para provocar cada uno a propósito.

---

## 4 · Colaboración en vivo

Este capítulo necesita **dos navegadores** con dos cuentas del mismo proyecto,
las dos en la misma pizarra.

### 4.1 Presencia y estado

- Arriba de la pizarra, el indicador dice «En vivo» cuando la sesión colaborativa
  está conectada.
- La presencia muestra quién más está dentro, con su foto o su inicial.

**Comprobación:** cuando el segundo navegador abre la pizarra, el primero lo ve
aparecer sin recargar.

### 4.2 Edición simultánea

1. Ana crea `Cliente`. Beto la ve aparecer en menos de un segundo.
2. Beto crea `Pedido` y los dos ven las dos clases.
3. Ana arrastra `Cliente`; Beto ve moverse la tarjeta.
4. Beto relaciona `Cliente` con `Pedido`; Ana ve la línea y sus multiplicidades.

**El caso que hay que enseñar en la defensa:** los dos escriben **a la vez** en
clases distintas. Ninguno pierde su trabajo y las dos pantallas terminan iguales.

**El caso difícil:** los dos renombran la **misma** clase a la vez. Convergen al
mismo nombre —el último gana— y ninguna relación se rompe, porque las relaciones
apuntan al identificador interno, no al nombre.

### 4.3 Perder y recuperar la conexión

1. Con la pizarra abierta, corta la red del segundo navegador (modo avión, o
   `docker compose -f infra/compose.yml --env-file infra/.env stop collab`).
2. El indicador deja de decir «En vivo».
3. Restaura (`... start collab`).

**Tiene que pasar:** vuelve a «En vivo» sin recargar, y los cambios que Ana hizo
mientras tanto aparecen. Lo que se recupera son desconexiones transitorias con la
pestaña abierta; cerrar la pestaña sin conexión no conserva el trabajo.

### 4.4 Solo lectura

Con un miembro en rol **Lector** (2.4):

- ve el diagrama y los cambios en vivo;
- no puede crear, mover ni borrar: las herramientas de escritura quedan
  deshabilitadas y aparece el aviso de solo lectura;
- en la pestaña «Generar» lee «Tu rol es de solo lectura: puedes descargar, no
  generar» y el botón de generar está bloqueado, pero **sí** puede descargar un
  ZIP ya generado.

Esto no es cortesía de la interfaz: el servidor de colaboración autoriza cada
conexión antes de unirla a la sala. Proteger solo las rutas HTTP no serviría.

### 4.5 Auditoría: quién cambió qué

Cada lote de cambios se registra con su autor y su origen (interfaz, asistente,
importación). Si el registro va con retraso —por ejemplo tras un corte— la
pizarra muestra el aviso de auditoría pendiente y reintenta sola; la edición
nunca se detiene por eso.

Para verlo desde fuera, con la sesión iniciada en el navegador, abre la consola
del navegador en la pizarra y pide el historial:

```js
await fetch('/api/boards/' + location.pathname.split('/').pop() + '/audit', { credentials: 'include' }).then(r => r.json())
```

Cada entrada trae el lote, su origen y quién lo hizo. Un reintento del mismo lote
no duplica la entrada.

---

## 5 · Borradores y recuperación del editor

- Si escribes el nombre de una clase o de un atributo y se corta la conexión, el
  texto a medio escribir no se pierde al reconectar.
- Si un lote se rechaza —por ejemplo porque perdiste permiso de escritura
  mientras editabas— la pizarra lo dice en lugar de fingir que se aplicó.

**Cómo provocarlo:** con Beto editando, cámbialo a Lector desde el otro
navegador. Su siguiente intento de cambio se rechaza y aparece el aviso de
permisos.

---

## 6 · Asistente de IA: texto y voz

Pestaña «Asistente», a la derecha del editor. Tiene dos modos: **Instruir**, que
propone cambios en el modelo, y **Preguntar**, que responde sobre lo que hay.

### 6.1 Instruir, revisar y aplicar

1. Modo «Instruir».
2. Escribe `crea Cliente` y envía.
3. Aparece la **propuesta**: las operaciones que haría, en texto.
4. Pulsa «Aplicar». La clase aparece en el lienzo y el otro navegador la ve.

**Esto es lo importante de la arquitectura, y conviene decirlo en la defensa:** la
IA nunca escribe en la pizarra directamente. Propone un lote de comandos de un
vocabulario cerrado; tú lo aplicas; el validador decide. Ningún modelo de lenguaje
toca el documento ni escribe Java.

**Casos a probar:**

- **Rechazar** una propuesta: no aplicarla, seguir editando a mano. No debe pasar nada.
- **Propuesta obsoleta:** pide algo, y antes de aplicar cambia el modelo a mano (o
  deja que el otro navegador lo cambie). La propuesta se marca como obsoleta en vez
  de aplicarse sobre un modelo que ya no existe.
- **Cancelar** una petición en curso con el botón de cancelar.
- **Contexto:** el asistente encadena tus mensajes. Tras `crea Cliente`, escribe
  `agrega telefono tipo String a Cliente`. Puedes revisar el contexto o
  descartarlo para empezar de cero.

### 6.2 Qué entiende el asistente simulado

Con `AI_LLM_PROVIDER=mock` —lo de por defecto— el asistente reconoce estas seis
formas. Son deterministas: dan exactamente el mismo resultado siempre, y por eso
sirven para ensayar.

| Escribe | Hace |
|---|---|
| `crea Cliente` | Crea la clase |
| `crea Producto con nombre, precio y stock` | Crea la clase con tres atributos String |
| `agrega telefono tipo String a Cliente` | Añade un atributo con su tipo |
| `relaciona Cliente con Pedido` | Asociación `1` → `0..*` |
| `Empleado hereda de Persona` | Generalización (el origen es la subclase) |
| `elimina Producto` | Borra la clase |

Escribe algo fuera de esa lista —`hazme un sistema bonito`— y responde que no
entendió, con un ejemplo de cómo pedirlo. No inventa: un «no entendí» y un «no hay
nada que hacer» son respuestas distintas, y las distingue.

Con un proveedor real configurado, el lenguaje es libre; el resto del flujo
—propuesta, revisión, aplicación, validación— es idéntico.

### 6.3 Preguntar

Cambia a modo «Preguntar» y pregunta `¿cuántas clases hay?` o `¿qué me falta para
generar?`. Responde sobre el estado real de la pizarra: cuántas clases y
relaciones hay, cómo se llaman, y si hay errores que bloqueen la generación.

### 6.4 Voz

El botón de dictado usa el reconocimiento del navegador (Chrome/Edge lo traen;
Firefox no).

1. Pulsa «Dictar». El navegador pedirá permiso del micrófono la primera vez:
   acéptalo.
2. Di `agrega telefono tipo String a Cliente`.
3. El texto aparece en el cuadro **para que lo revises antes de enviar**. Corrígelo
   si hace falta y envía.

**Qué probar:** que al fallar el dictado no se pierde lo que ya habías escrito, y
que puedes detenerlo a mitad. Con un micrófono real, comprueba el ruido de la
sala antes de la defensa: las pruebas automáticas verifican el flujo, no la
calidad del reconocimiento.

---

## 7 · Validación: los errores que bloquean la generación

La colaboración garantiza que todos vean lo mismo, **no** que lo que vean sea
válido. Dos personas pueden converger en un modelo imposible de generar; el
validador lo marca antes de dejar generar. Provocar estos errores a propósito es
la mejor demostración de que el generador no produce basura.

| Provoca esto | Aparece | Cómo se arregla |
|---|---|---|
| Una relación `0..*` ↔ `0..*` | Muchos a muchos sin entidad intermedia | Crear la clase intermedia con dos relaciones |
| Dos atributos marcados como clave primaria | Clave compuesta no soportada | Dejar una y marcar la otra como única |
| Dos superclases para una clase | Herencia múltiple | Dejar una sola generalización |
| A hereda de B, B hereda de A | Ciclo de herencia | Romper el ciclo |
| Una clase su propia superclase | Autogeneralización | Usar una asociación con rol |
| Dos clases con el mismo nombre | Nombre duplicado | Renombrar una |
| Dos atributos iguales en una clase | Atributo duplicado | Renombrar uno |
| Un atributo repetido en la subclase | Colisión con lo heredado | Quitarlo de la subclase |
| Una clase sin nombre | Clase sin nombre | Ponerle nombre |

Los nombres se comparan sin tildes, sin espacios y sin distinguir mayúsculas:
`Detalle Venta` y `detalle_venta` son el mismo nombre.

Hay también **avisos** que no bloquean: clave primaria inferida o generada, nombre
normalizado, nombre reservado al que se le añade un prefijo, clase sin relaciones.

**Comprobación:** con un error presente, el botón «Generar» está deshabilitado y
el pie del panel no dice «Generación disponible». Arregla el error y se habilita
sin recargar.

---

## 8 · Importar desde una imagen

Pestaña «Importar y exportar». Primero elige el modo, arriba:

- **Añadir a lo que hay** — suma al diagrama actual.
- **Reemplazar el contenido** — sustituye la pizarra entera.

### 8.1 Desde un archivo

1. «Importar imagen» y elige un PNG, JPG, WebP o GIF de un diagrama.
2. Espera a que la IA lea la imagen.
3. Aparece el **candidato**: lo que propone, antes de aplicar, con sus avisos y su
   propia validación.
4. Revísalo y corrígelo ahí mismo: los nombres, los tipos, las clases que sobran.
5. «Aplicar».

Con el proveedor simulado el candidato es siempre el mismo (Cliente y Pedido
relacionados): prueba el camino completo sin gastar una llamada real. Con un
proveedor de visión configurado, lee la foto de verdad.

### 8.2 Desde la cámara

1. «Abrir cámara». El navegador pide permiso.
2. Encuadra el pizarrón y «Tomar foto».
3. Sigue el mismo camino: candidato, revisión, aplicar.

Esto exige HTTPS o `localhost`: por IP y sin certificado, el navegador no da
acceso a la cámara. Tenlo en cuenta si demuestras desde otra máquina del aula.

**Qué probar:** aplicar en modo «Añadir» sobre una pizarra con contenido, y
después repetir en modo «Reemplazar» para ver la diferencia. Y rechazar un
candidato sin aplicarlo: la pizarra no debe cambiar.

---

## 9 · XMI: importar y exportar

### 9.1 Importar

1. «Importar XMI» y elige un `.xmi` o `.xml`.
2. Igual que con la imagen: candidato editable, avisos, validación y «Aplicar».

Para probar sin salir del repositorio tienes modelos reales en
[`fixtures/xmi/`](../fixtures/xmi/). También sirve el XMI que produce
`npm run demo:backend` en `generated-output/demo-ventas-*`.

Se conservan tipos, identidad, geometría, cardinalidades y marcas. Una clase
asociativa importada llega como su entidad intermedia.

### 9.2 Exportar

1. «Exportar XMI».
2. Escribe el nombre del archivo.
3. Elige el formato:
   - **Enterprise Architect 15 — XMI 2.1**, para abrirlo en EA;
   - **UML 2.5.1 — XMI 2.5.1**, el estándar.
4. Confirma y se descarga.

**La prueba de ida y vuelta**, que es la que vale: exporta la pizarra, crea una
pizarra nueva, impórtala ahí y compara. Clases, atributos, tipos, relaciones,
multiplicidades y posiciones deben coincidir.

**Estado conocido:** la importación real en Enterprise Architect 15 está
comprobada con nueve modelos. La reexportación desde EA hacia la plataforma sigue
pendiente de validar; si la enseñas, hazlo sabiendo eso.

---

## 10 · Generar el backend Spring Boot

Pestaña «Generar», con un modelo válido (capítulo 7).

1. **Paquete Java** — escribe `bo.edu.sw1` o el que uses. Se convierte en las
   carpetas del código: compruébalo después dentro del ZIP.
2. **Incluir Flutter** — opcional. Añade un segundo paquete con la app Android y
   el backend móvil emparejado.
3. Comprueba que el pie dice **«Generación disponible»** y pulsa «Generar».

**Tiene que pasar:** el estado informa cuántas entidades se generaron, **sobre qué
versión del snapshot** y con qué paquete. Ese «snapshot v…» es la prueba visible de
que se generó sobre una foto congelada del modelo y no sobre el estado vivo: si
alguien mueve una clase mientras generas, el ZIP no cambia.

4. «Descargar Spring» baja el `.zip`.
5. Si marcaste Flutter, «Descargar Android» baja el `-android.zip`.

El **historial** de abajo guarda cada generación con su manifiesto congelado, y
permite volver a descargar una anterior. Un lector puede descargar de ahí aunque
no pueda generar.

**Comprobación que no hay que saltarse:** abre el ZIP y verifica que dentro está
la clase que acabas de dibujar (`Cliente.java`, `ClienteController.java`,
`pom.xml`, y la ruta `bo/edu/sw1/`). Que baje un archivo no prueba nada: uno vacío
también bajaría.

### 10.1 Qué trae el ZIP

| Carpeta | Contenido |
|---|---|
| `src/main/java/...` | Entidades JPA, repositorios, servicios, controladores, DTO |
| `pom.xml` | Maven, Spring Boot 4.1.1, Java 21 |
| `Dockerfile`, `compose.yaml`, `.env.example` | Ejecución en contenedores |
| `postman/` | Colección y entorno local listos para importar |
| `docs/dto-contract.json`, `docs/flutter-api.md` | Contrato para un cliente móvil |
| `README.md` | Cómo levantarlo, puertos, salud, CORS |

Cubre gestión CRUD y restricciones estructurales. No inventa reglas de negocio
—descuentos, cálculos contables—, no trae autenticación y la lista GET todavía no
está paginada. Decirlo tú antes de que lo pregunten es mejor que lo contrario.

---

## 11 · Ejecutar y probar lo generado

1. Descomprime el ZIP en una carpeta fuera del repositorio.
2. Copia `.env.example` a `.env` y pon la contraseña de la base.
3. Levántalo:

```powershell
docker compose up -d --build
docker compose ps
curl http://localhost:8081/actuator/health
```

4. Importa `postman/collection.json` y `postman/local.environment.json` en
   Postman y ejecuta la colección en orden: altas de las entidades referenciadas,
   consultas, modificaciones, y bajas en orden inverso.

**Las tres comprobaciones que valen por todas:**

- un **POST** devuelve la clave generada y un **GET** la recupera;
- borrar un padre que tiene hijos responde **409**, no un error de base de datos
  ni un borrado silencioso;
- reiniciar los contenedores (`docker compose restart`) conserva los datos.

La guía larga —Railway, HTTPS, Flutter, teléfono físico, firma y release— está en
[`guia-pruebas-despliegue-app-generada.md`](guia-pruebas-despliegue-app-generada.md).

Para preparar un ejemplo sin pasar por la interfaz:

```powershell
npm run demo:backend    # deja ZIP, proyecto y XMI en generated-output/demo-ventas-*
```

---

## 12 · Ensayo cronometrado de la defensa

Hazlo entero, con reloj, en los equipos y la red reales. Es el pendiente P0 de
la entrega y el único que no se puede improvisar.

| # | Paso | Quién | Señal de que salió bien |
|---|---|---|---|
| 1 | Entrar los dos y abrir el proyecto | Ana y Beto | Los dos ven las mismas pizarras |
| 2 | Invitar y aceptar en vivo | Ana invita, Beto acepta | Beto entra sin recargar |
| 3 | Abrir la misma pizarra | Los dos | «En vivo» y presencia con los dos |
| 4 | Dibujar dos clases y una relación a la vez | Los dos | Las dos pantallas terminan iguales |
| 5 | Instruir al asistente y aplicar | Ana | La clase aparece en las dos pantallas |
| 6 | Dictar una instrucción por voz | Beto | El texto llega al cuadro y se revisa antes de enviar |
| 7 | Importar una foto del pizarrón | Ana | Candidato revisable, luego aplicado |
| 8 | Enseñar un error de validación y arreglarlo | Beto | «Generar» pasa de bloqueado a disponible |
| 9 | Generar y descargar el ZIP | Ana | El estado dice entidades y «snapshot v…» |
| 10 | Abrir el ZIP y mostrar la clase dibujada | Ana | `Cliente.java` dentro, con el paquete pedido |
| 11 | Levantar el generado y hacer un CRUD | Ana | POST y GET desde Postman |
| 12 | Exportar XMI y abrirlo en EA | Beto | El modelo se ve en Enterprise Architect |

Antes de empezar: `npm run up`, `npm run seed`, `WEB_ORIGIN` correcto, puertos
repartidos, micrófono y cámara probados, y una foto de un diagrama ya guardada
por si la cámara falla.

---

## 13 · Las suites automáticas

Lo de arriba es el recorrido manual. Esto es lo que se ejecuta solo.

| Comando | Qué cubre | Necesita |
|---|---|---|
| `npm run check` | Formato, lint, tipos y pruebas rápidas del dominio | Nada |
| `npm run test:api` | Integración HTTP de la API | Docker |
| `npm run test:e2e` | Dos navegadores contra el entorno levantado | Docker, `npm run up`, `npm run e2e:install` |
| `npm run test:generated` | T01: genera, compila con Maven, arranca y ejerce el CRUD | Docker, Java 21, Maven |
| `npm run test:bank` | Los ocho modelos del banco, compilados y ejecutados | Docker, Java 21, Maven |
| `npm run bank:report` | Qué encuentra el validador en cada modelo | Nada |

`npm run check` es el bucle rápido y corre en segundos, a propósito: nada de lo
que cubre necesita Docker.

Para ejecutar una sola prueba de navegador:

```powershell
npx playwright test --config e2e/playwright.config.ts e2e/specs/generacion.spec.ts
```

---

## 14 · Matriz de cobertura

Qué caso de uso cubre cada prueba automática, y dónde está su capítulo manual.

| Caso de uso | Capítulo | Prueba automática |
|---|---|---|
| Registro, entrada y sesión | 1 | `e2e/specs/sesion.spec.ts` |
| Perfil, foto y contraseña | 1.3, 1.4 | `e2e/specs/cuenta.spec.ts` |
| Proyectos, pizarras e invitaciones | 2 | `e2e/specs/proyectos.spec.ts`, `proyectos-navegacion.spec.ts` |
| Dibujo, notación y multiplicidades | 3 | `e2e/specs/notacion.spec.ts`, `tarjetas.spec.ts`, `usabilidad-editor.spec.ts` |
| Colaboración y convergencia | 4 | `e2e/specs/colaboracion.spec.ts`, `colaboracion-concurrente.spec.ts` |
| Auditoría y reintentos | 4.5 | `e2e/specs/auditoria-regresiones.spec.ts` |
| Borradores y recuperación | 5 | `e2e/specs/borradores.spec.ts` |
| Asistente por texto y contexto | 6.1–6.3 | `e2e/specs/ia-contexto.spec.ts` |
| Dictado por voz | 6.4 | `e2e/specs/voz.spec.ts` |
| Validación del modelo | 7 | `npm test` (dominio) y `npm run bank:report` |
| Importación por imagen y XMI | 8, 9 | `e2e/specs/colaboracion-xmi-completa.spec.ts`, `xmi-asociativa.spec.ts` |
| Generación y descarga | 10 | `e2e/specs/generacion.spec.ts` |
| El generado compila y responde | 11 | `npm run test:generated`, `npm run test:bank` |
| Web en pantalla de teléfono | — | `e2e/specs/movil.spec.ts`, `apariencia.spec.ts` |

---

## 15 · Cuando algo falla

| Síntoma | Causa más probable | Qué hacer |
|---|---|---|
| La interfaz carga pero no entra nadie | `WEB_ORIGIN` no coincide con la URL usada | Corregirlo en `infra/.env` y `npm run up` |
| No dice «En vivo» | El proceso de colaboración está caído | `... logs collab`, luego `... restart collab` |
| «Generar» siempre bloqueado | Hay un error en «Revisión del modelo» | Capítulo 7 |
| El ZIP baja vacío o sin tus clases | Se generó antes de dibujar | Volver a generar y mirar «snapshot v…» |
| El asistente no entiende nada | Proveedor `mock` con lenguaje libre | Usar el vocabulario de 6.2, o configurar un proveedor real |
| El dictado no arranca | Navegador sin reconocimiento o permiso denegado | Chrome/Edge y revisar el permiso del micrófono |
| La cámara no abre | Origen sin HTTPS | Usar `localhost` o servir con certificado |
| El backend generado no levanta | El 8081 ya está ocupado (Adminer) | Cambiar `PORT` en su `.env` |
| Quiero empezar de cero | Datos viejos | `npm run down -- -v` y luego `npm run up` y `npm run seed` |

Registros de cualquier servicio:

```powershell
docker compose -f infra/compose.yml --env-file infra/.env logs -f api
```

---

## Qué queda fuera de esta guía

- La reexportación completa **desde** Enterprise Architect hacia la plataforma
  sigue sin validar (9.2).
- La calidad del reconocimiento de voz y de la lectura de una foto real depende
  del proveedor y del ambiente: las pruebas cubren el flujo, no el acierto.
- El historial de generaciones de otros colaboradores no se refresca solo.
- No hay copia ni restauración de versiones por el usuario.

La lista viva está en [`pendientes.md`](pendientes.md).
````

---

### `docs/importacion-clase-asociativa.md`

```markdown
# Importación de Inscripcion desde Enterprise Architect

La corrección se verificó con `PracticaProbar.xmi` suministrado por el usuario.
El archivo tiene dos elementos homónimos: una clase vacía aislada y una
`uml:AssociationClass` con fecha, estado, notaFinal e idInscripcion.
El parser anterior descartaba la clase asociativa y sus atributos.

Ahora la importación produce:

- `Estudiante (1) — (0..*) Inscripcion`.
- `Curso (1) — (0..*) Inscripcion`.
- `Inscripcion (1) ◆— (0..*) Calificacion`, conservando la composición de EA.

La relación Estudiante–Curso que sirve de base a la clase asociativa se sustituye
por los dos enlaces a la entidad intermedia. Los cuatro atributos mantienen sus
tipos Date, String, Decimal e Integer. La clase vacía homónima se omite con aviso
solo cuando carece de contenido y enlaces; las clases homónimas con contenido
se conservan con nombres diferenciados.

Los proxies de EA se resuelven usando `classifier`, sin crearlos como entidades.
También se admiten clases asociativas UML con participantes directos y extremos
guardados como atributos de otra clase. Si faltan participantes, se conservan
los atributos y se avisa; no se inventan relaciones. Se trata de una conversión
a entidades y asociaciones del modelo de la app, no de la reproducción de la
notación de clase asociativa unida mediante una línea discontinua.

Para la composición se consulta el extremo del diamante en la extensión EA.
Esto evita invertir Inscripcion y Calificacion por la ubicación de `aggregation`
en los `ownedEnd` de ese exportador.

## Validación

- 361 pruebas unitarias aprobadas, incluidas siete regresiones para este caso.
- Typecheck y lint aprobados.
- Prueba de navegador aprobada: carga del archivo, vista previa, aplicación,
  sincronización con un segundo colaborador y descarga XMI con los tres enlaces.
- API local reconstruida. No se modificaron las pizarras del usuario.

Para corregir una importación anterior, volver a seleccionar el archivo y usar
**Reemplazar**, revisando la vista previa y la confirmación de la aplicación.
Ese modo sustituye el contenido de la pizarra; si contiene cambios posteriores
que se quieren conservar, usar una pizarra nueva. El modo **Añadir** conserva
las relaciones existentes y, por tanto, puede conservar el enlace directo viejo.
```

---

### `docs/modelos-ia-2026-09-10.md`

```markdown
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
```

---

### `docs/pendientes.md`

```markdown
# Pendientes vigentes

Actualización de IA del 10 de septiembre: [prompt, texto, voz y cancelación](revision-ia-2026-09-10.md). Se corrigieron pérdida de opciones/contexto, inferencia de teléfonos e identificadores y borradores tras fallar el dictado. El asistente propaga cancelación; siguen pendientes presupuestos por usuario, alternativa de grabación y calidad comprobada con el proveedor real.

Actualización del 10 de septiembre: [colaboración, candidato editable e intercambio XMI](colaboracion-xmi-2026-09-10.md). Se completaron administración de participantes, edición del candidato, conservación de identidad/geometría y selección de XMI 2.5.1 o del perfil EA 2.1. Nueve modelos aprobaron la importación real en Enterprise Architect; queda su reexportación completa y el ensayo entre equipos.

Offline y flexibilidad del prompt móvil: [estrategia y estado implementado](estrategia-mobile-offline-agente.md). El contrato adapta CRUD; faltan perfil semántico configurable, herramientas de negocio compuestas, renovación automática de sesión y sincronización con la app cerrada si se requieren.

Revisión de cumplimiento y generación de distintas aplicaciones: [banco CRUD y configuración Spring/Flutter](revision-generador-crud.md). Ocho modelos generados con perfil móvil aprobaron contra PostgreSQL; siguen pendientes la prueba física del agente y el ensayo de presentación.

Generador Android incorporado el 6 de septiembre: [estado, validaciones y faltantes](generacion-flutter-android.md). La ampliación es opcional y no cambia el requisito docente de construir el frontend durante la presentación. Quedan la validación física de GGUF/voz en modo avión y la preparación de distribución release.

Generación de gestión actualizada el 6 de septiembre: [capas, DTO para Flutter, Postman y ejecución](generacion-backend-gestion.md). Se cerró la comprobación de configuración externa del generado indicada anteriormente como CA-068.2.

Alcance aclarado por las notas del docente del 6 de septiembre: [matriz de cumplimiento](requisitos-docente-2026-09-06.md). Flutter se construye aparte durante la presentación; su agente local y funcionamiento offline siguen siendo requisitos de la demostración. No se exige generar Flutter desde la herramienta.

Actualización de IA del 6 de septiembre: [correcciones, evidencia y pendientes priorizados](revision-ia-2026-09-06.md).

Revisado el **5 de septiembre de 2026**. Entrega prevista: **23 de septiembre**.
La evidencia y los defectos corregidos están en la
[auditoría consolidada](auditoria-2026-09-05.md). Este índice sustituye el diagnóstico
del 30 de agosto; la historia de propuestas permanece en
[actualizacion.md](actualizacion.md) y en Git.

El alcance ejecutable actual es la web colaborativa, el generador Spring Boot y,
desde el 6 de septiembre, el paquete opcional Flutter Android con su backend
protegido. La web se adapta a teléfonos; el antiguo generador Dart de capa de
datos fue retirado.

## Antes de cerrar la entrega

| Prioridad | Qué falta | Cómo se cierra |
|---|---|---|
| P1 | Reexportación completa desde Enterprise Architect 15 | Nueve modelos ya conservan tipos, posiciones, identidad, relaciones y marcas al importarse realmente. El exportador automatizado de EA no respondió; falta comprobar su archivo de vuelta. Ver [evidencia actual](colaboracion-xmi-2026-09-10.md). |
| P0 | Ensayo completo en equipos y red de la defensa | Recorrer acceso, invitación, edición simultánea, IA/importación, generación y ejecución del ZIP con reloj. |
| P0 | Confirmar el alcance después de retirar nativo/Dart | Reflejar la decisión en los requisitos acordados; no presentar la web táctil como una app nativa. |
| P1 | Voz, fotografía y proveedores reales | Probar el micrófono y una imagen real del pizarrón, permisos y respuesta de IA. Los mocks verifican el flujo, no la calidad del reconocimiento. |
| P1 | URL, correo y reparto de puertos | WEB_ORIGIN debe coincidir con la URL de acceso. Probar email real si se demuestra recuperación. Plataforma 8080 y backend generado 8081, por ejemplo. |
| P1 | RNF-14: contexto en registros | Ver proyecto, pizarra, lote, comando, generación, actor y origen en los registros correspondientes. |

Preparación del entorno: [despliegue.md](despliegue.md). El adaptador de correo
`log` muestra enlaces en registros y **no envía correo**. El plan maestro de
`docs/referencia/` no se incluye en un clon limpio; compartir una versión
autorizada del alcance con quienes revisen la entrega.

## Funciones todavía incompletas

- Copia/restauración JSON y recuperación de versiones por el usuario.
- Recuperación visible de lotes de auditoría rechazados permanentemente y
  protección de la cola frente a escrituras concurrentes entre pestañas.
- Persistencia del documento sin conexión a través de recargas, si se ofrece
  esa capacidad: hoy se recuperan desconexiones transitorias con la pestaña abierta.
- Reparación guiada muchos a muchos, si se incorpora al alcance: hoy se detecta
  y explica la entidad intermedia requerida.
- Actualización automática del historial de generaciones de otros colaboradores.
- Revisión de accesibilidad completa y validación en dispositivos físicos y
  navegadores distintos de Chromium.

## Antes de publicar en internet

- Resolver los cuatro paquetes afectados en la cadena de herramientas Prisma
  con una actualización compatible; no ejecutar una degradación mayor automática.
- Revocación inmediata de JWT de acceso si se promete cierre instantáneo de
  todas las sesiones. Hoy los refresh se revocan, pero los JWT emitidos caducan después.
- Limitar intentos de acceso/recuperación y consumo de IA/generación.
- HTTPS, cookies seguras, cabeceras de seguridad y exposición mínima de puertos.
- Copias de seguridad, ensayo de restauración, alertas, límites de recursos,
  rotación de registros y retención de tokens/snapshots.
- Si se exige auditoría autoritativa, cubrir las escrituras de clientes Yjs
  directos que no envían lotes al endpoint HTTP de auditoría.

## Verificaciones ya realizadas

- RF-053: exportar/reimportar archivos de la app conserva identidad y geometría; la reexportación externa de EA se sigue arriba.
- Formato, lint, TypeScript, pruebas unitarias e integración con PostgreSQL.
- Cinco participantes y 30 cambios; P95 local de 39,4 ms en la última ejecución.
- Diez pizarras con estados aislados.
- Modelo de 30 clases, 100 atributos y 40 relaciones importado, renderizado y
  movido con propagación a otro navegador.
- Ocho modelos Spring generados, compilados y ejecutados con CRUD y reinicio.
- Determinismo de archivos/ZIP y generación sintética bajo el presupuesto de 10 s.

Estas mediciones son locales. Falta el ensayo de red del aula y no se infiere
rendimiento prolongado de producción a partir de ellas.

## Fuera del núcleo por decisión

- RF-018: deshacer el último comando propio (P2).
- Bloqueo temporal de la pizarra, visor de código por capas y cambios cosméticos
  sin criterio de aceptación asignado.

## Preparación final de la demostración

- [ ] Contenedores reconstruidos después del último cambio.
- [ ] Dependencias Java y de Node disponibles en los equipos previstos.
- [ ] Enterprise Architect probado con los archivos del ensayo.
- [ ] Plataforma y backend generado ejecutándose simultáneamente en puertos distintos.
- [ ] Cuentas de demostración y modelo de respaldo preparados.
- [ ] Voz/cámara y acceso a proveedores comprobados; conexión de respaldo disponible.
- [ ] Guion completo cronometrado y requisitos pendientes reconocidos explícitamente.
```

---

### `docs/proveedores-ia.md`

````markdown
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
````

---

### `docs/requisitos-docente-2026-09-06.md`

```markdown
# Contraste con los requisitos del docente

Fecha: 6 de septiembre de 2026. Entrega indicada: 23 de septiembre.
Fuente de alcance: notas compartidas por el usuario en esta conversación. Actualizado después de incorporar la base Flutter y el perfil móvil Spring. El estado vigente y la nueva comprobación de diferentes aplicaciones están en [revisión del generador CRUD](revision-generador-crud.md). No se hicieron pruebas del agente ni llamadas a proveedores IA en esta revisión.

## Interpretación del alcance

Hay dos productos distintos:

1. **Herramienta principal:** pizarra colaborativa para diseñar datos mediante clases UML, con edición gráfica, instrucciones por texto/voz, fotografía, interoperabilidad XMI y generación de un backend Spring Boot/PostgreSQL independiente.
2. **Aplicación de demostración:** cliente Flutter que se construye/adapta durante la presentación y consume ese backend. Su interfaz principal utiliza voz y un agente; debe seguir operando con IA local y datos locales sin conexión, y sincronizar al recuperarla.

Las notas no exigen que la herramienta genere Flutter automáticamente. Tampoco exigen IA local en la herramienta web: expresamente la ubican en la aplicación móvil. La alternativa «diagrama de clases o entidad relación» permite cubrir el modelado conceptual con UML; no se deduce que deban existir dos editores distintos.

El antiguo generador Dart de capa de datos fue sustituido por un generador opcional Flutter Android con login, contrato de backend, repositorio SQLite, cola y configuración GGUF. La compilación del APK y las pruebas de contrato/login están acreditadas; la demostración real del agente y voz offline sigue pendiente.

## Matriz de cumplimiento

| Requisito anotado | Estado observado | Qué falta para acreditarlo |
| --- | --- | --- |
| Diseño conceptual de datos con clases, atributos, tipos y relaciones | Implementado para el subconjunto UML admitido | Ensayar ejemplos de gestión acordados; explicar las restricciones del modelo generable. No se promete todo UML de Architect ni lógica de negocio que no figure en el modelo. |
| Pizarra colaborativa en tiempo real | Implementada con Yjs/WebSocket, presencia, permisos y persistencia | Demostración con varios equipos en la red prevista; verificar edición concurrente y conflictos sobre el mismo campo, además de cambios independientes. |
| Gestión de concurrencia/exclusión mutua | Hay convergencia CRDT y pruebas de concurrencia; no un bloqueo exclusivo por elemento | Explicar cómo se resuelven escrituras simultáneas. Si se exige literalmente impedir que dos personas editen el mismo elemento, falta ese bloqueo; las notas no bastan para asumir que sea obligatorio como mecanismo. |
| Edición gráfica | Implementada | Validación final del recorrido de clases, atributos, relaciones y cardinalidades en el equipo de presentación. |
| IA que aplica únicamente el cambio solicitado | Implementada mediante operaciones y escritura incremental del documento | Probar instrucciones reales y verificar elementos ajenos intactos. La proyección de React se recalcula; escribir cambios incrementales no demuestra por sí solo que únicamente un nodo se renderice. Medir si se exige esa condición de rendimiento. |
| Edición mediante texto o voz | Implementada con dictado revisable y propuesta antes de aplicar | Voz real y calidad del proveedor. El flujo actual requiere pulsar Parar, Enviar y Aplicar. Para cubrir literalmente «sin teclado ni mouse», faltan controles equivalentes por voz, conservando confirmación explícita. |
| Fotografía del pizarrón convertida en diagrama | Ruta visual y revisión del candidato implementadas | Ensayo con fotografía real: escritura manual, luz del aula, flechas, tipos, cardinalidades y clases intermedias. Las pruebas simuladas no acreditan reconocimiento correcto. |
| Importar y exportar XMI con Architect | Implementado y corregido con archivos aportados; incluye conversión de clases asociativas | Cerrar la prueba real de app → Architect → app después de la corrección del exportador. Verificar tipos, claves, extremos, cardinalidades y posiciones; no limitarse a contar clases. |
| Backend Spring Boot independiente con cuatro capas | Implementado: entidades, repositorios, servicios, controladores y DTO | Abrir el ZIP de un modelo nuevo en el IDE previsto y ejecutarlo sin cambiar código; configurar solamente conexión/puerto. Hay evidencia previa de ocho modelos compilados y ejecutados. |
| PostgreSQL y creación de esquema desde entidades | Implementado con JPA/Hibernate y configuración PostgreSQL | Mostrar tablas, claves y relaciones creadas sobre una base vacía durante el ensayo; comprobar persistencia tras reiniciar. |
| Material para probar el backend | Se genera colección Postman, OpenAPI/Swagger y documentación | Ejercitar altas, consultas, cambios y eliminaciones del modelo del ensayo. No falta crear un generador de Postman desde cero. |
| Frontend Flutter conectado al backend generado | Base generada; contrato/login probados y APK compilado | Ensayar aplicación física con un modelo nuevo y pantallas específicas desarrolladas en vivo. |
| Agente móvil con voz como interfaz principal | Motor GGUF, propuestas CRUD y dictado local integrados en código | Prueba física de calidad, ambigüedad, negaciones y confirmación. No se probó el agente por indicación del usuario. El flujo sigue usando controles táctiles de revisión. |
| IA local móvil sin internet | Carga de GGUF preparada; ningún modelo incluido | Elegir pesos compatibles, medir memoria y latencia, comprobar modo avión. La voz offline depende del reconocedor/idioma Android; no se garantiza escucha continua controlada por la app. |
| Operación móvil offline y sincronización posterior | SQLite, cola durable, recibos transaccionales y conflictos implementados | Ensayo completo en teléfono: cierre/reapertura, reconexión y varios dispositivos. La sincronización se ejecuta con la app abierta o al reabrir; sin servicio permanente en segundo plano ni migración automática de contratos. |

## El pendiente más grande: demostración móvil offline

El ZIP Spring independiente conserva CRUD simple. El paquete Android + backend añade `/mobile-sync`, IDs de operación estables, recibos persistentes, comparación de DTO original, bloqueo y versión JPA. Esto evita repetir operaciones confirmadas y detecta cambios incompatibles; no genera reglas de negocio ni un merge semántico. La descarga de colecciones es completa, sin sincronización incremental. Debe usarse el backend del paquete móvil para el cliente Flutter.

No es indispensable imponer un único diseño de sincronización. Sí debe demostrarse este comportamiento: registrar un servicio sin red mediante el agente, cerrar y abrir la app, conservar el registro, recuperar conexión, enviarlo una sola vez al backend y reflejar el resultado localmente. Si se admiten varios clientes offline, también debe definirse qué ocurre cuando modifican el mismo registro.

La colaboración Yjs del diseñador resuelve otro problema: sincroniza diagramas. No sincroniza automáticamente los datos de ventas, clientes o servicios del backend generado. Tener varios proveedores remotos de IA tampoco cubre la inferencia local sin internet.

## Orden de cierre recomendado

1. **Ensayar Flutter + agente local + almacenamiento/sincronización offline en Android físico.** La base ya existe; falta acreditar el recorrido real con modelo y voz, cuando el usuario autorice probar el agente.
2. **Cerrar Architect con un archivo realmente reimportado después de la corrección.** Mantener evidencia del resultado y del modelo completo.
3. **Realizar voz y fotografía con entradas reales.** Si se evalúa interacción totalmente por voz, añadir órdenes de control y confirmación sin retirar el modo de revisión manual elegido.
4. **Ensayar la secuencia completa:** varios participantes → modelo nuevo → ZIP → IDE → PostgreSQL → Postman → Flutter → operación offline → reconexión sin duplicados.
5. **Cerrar los controles de IA que afectan al costo y la corrección:** cancelación, límites por usuario, registro de intentos y detección de propuestas desactualizadas. Son mejoras de robustez; no sustituyen los entregables anteriores.

## Evidencia local consultada

- [Auditoría y banco de generación](auditoria-2026-09-05.md): evidencia histórica de colaboración y ocho proyectos Spring; las cifras pertenecen a aquella ejecución.
- [Revisión reciente de IA](revision-ia-2026-09-06.md): 442 pruebas unitarias/de regresión y cinco recorridos de voz/aclaraciones; reconocimiento y proveedores simulados.
- [Compatibilidad XMI](compatibilidad-xmi-2026-09-05.md) e [Inscripcion como intermedia](importacion-clase-asociativa.md).
- [Plantillas Spring](../templates/spring/README.md.hbs), [servicios](../templates/spring/service.java.hbs), [entidades](../templates/spring/entity.java.hbs) y [configuración PostgreSQL/JPA](../templates/spring/application.properties.hbs).
- [Generador y Postman](../shared/generator-backend/src/project-generator.ts), [aplicación incremental Yjs](../shared/yjs-adapter/src/apply.ts) y [flujo actual del asistente](../frontend/src/features/assistant/AssistantPanel.tsx).

Los pendientes generales de administración, restauración de versiones, despliegue público y otros refinamientos siguen en [pendientes](pendientes.md). No se presentan aquí como requisitos obligatorios adicionales del docente cuando no aparecen en las notas.
```

---

### `docs/responsividad-movil-2026-09-05.md`

```markdown
# Verificación móvil y diagnóstico XMI — 5 de septiembre de 2026

La web local actualizada en `http://localhost:8080` pasa los seis recorridos
táctiles de esta revisión. Se corrigieron desbordamientos, distribución del
editor y desplazamientos al navegar. Es una verificación mediante Chromium
con emulación móvil; no certifica Safari ni dispositivos físicos.

El estado general y los faltantes funcionales y de operación están en la
[auditoría consolidada](auditoria-2026-09-05.md). Este informe amplía su apartado
móvil con comprobaciones de altura del lienzo y visibilidad inicial de la cabecera.

## Correcciones

- Formularios y tarjetas caben desde 320 px, incluso con nombres largos.
- En teléfonos y orientación horizontal de poca altura, las herramientas se
  distribuyen encima del lienzo y los paneles usan el ancho completo debajo.
- La cuadrícula reserva altura explícita para el lienzo. Se verifican al menos
  240 px; una versión intermedia podía dejarlo con altura cero.
- Los campos, controles táctiles, atributos, mensajes de validación e importación
  ajustan su distribución sin desbordar el documento. El botón de crear clase
  alcanza al menos 44 px de altura en teléfono y horizontal.
- La navegación comienza arriba al cambiar de ruta.
- El asistente deja de ejecutar `scrollIntoView` al abrir una conversación vacía.
  Ese efecto desplazaba toda la página y ocultaba la cabecera a 320 px y en
  horizontal. Las conversaciones con mensajes conservan su desplazamiento.
- Se mantienen los botones para ocultar paneles y dedicar el ancho al diagrama.

Archivos: `frontend/src/styles.css`, `frontend/src/App.tsx`,
`frontend/src/features/assistant/AssistantPanel.tsx` y `e2e/specs/movil.spec.ts`.

## Resultados finales

| Comprobación | Resultado |
|---|---|
| Chromium táctil, 320×568 | Pasa |
| Chromium táctil, 360×800 | Pasa |
| Chromium táctil, 390×844 | Pasa |
| Chromium táctil, 430×932 | Pasa |
| Chromium táctil, 768×1024 | Pasa |
| Chromium táctil horizontal, 844×390 | Pasa |
| Navegador contra Vite, móviles y regresiones de escritorio | 20/20, aproximadamente 60 s |
| Repetición móvil contra Nginx local actualizado, puerto 8080 | 6/6, 20,2 s |
| `npm test` | 352 pruebas pasan; la muestra real de Architect se procesa con avisos explícitos para construcciones no soportadas |
| Compilación de la imagen web | Correcta |
| Contenedores web, API, colaboración y PostgreSQL | Saludables |

Cada recorrido táctil registra una cuenta de prueba, cambia su nombre, crea un
proyecto y una invitación, abre una pizarra, crea una clase con atributo, cambia
entre importar/generar/asistente, oculta y muestra paneles y cierra sesión.
Comprueba el ancho del documento, controles fuera de pantalla, cabecera visible,
altura del lienzo y ancho al ocultar paneles. Se inspeccionaron capturas de
320 px y horizontal además de las aserciones.

Las regresiones de escritorio incluyen perfil, recuperación, generación y
descarga de ZIP, selección y movimiento por teclado y colaboración. Esta pasada
no vuelve a certificar todos los recorridos de IA ni el banco Spring completo:
sus resultados previos están en la auditoría general.

Evidencia local, excluida de Git:

- `reports/movil-2026-09-05/antes/`: fallos iniciales y capturas.
- `reports/movil-2026-09-05/verificado/`: 20 recorridos finales contra Vite.
- `reports/movil-2026-09-05/desplegado/`: seis recorridos finales en 8080.

Se actualizó únicamente el contenedor web en esta continuación. El servidor
Vite temporal se apagó al terminar. Quedan pendientes pruebas físicas Android/iOS,
Safari, teclado virtual, cambios de orientación durante una sesión, gestos de
arrastre/pellizco y cámara/micrófono reales.

## Tipos de atributo al importar XMI en Enterprise Architect

La captura aportada muestra atributos sin su tipo, pero no permite determinar
si el campo está vacío en el modelo importado o está oculto en el diagrama.

1. Abrir las propiedades del diagrama, sección **Features**, y seleccionar
   **Show Attribute Detail → Name and Type**. Esta opción controla si se
   presenta solamente el nombre o también el tipo, según la
   [documentación oficial de Sparx](https://www.sparxsystems.com/enterprise_architect_user_guide/17.1/modeling_fundamentals/appearance_options_feat.html).
2. Abrir los atributos de una clase y revisar su campo **Type/Tipo**.
   Si tiene el valor esperado, el tipo se importó y el problema es de presentación.
3. Si está vacío, descargar un XMI nuevo desde la plataforma actual e importarlo
   en un paquete de prueba. La API actual emite referencias UML a tipos
   primitivos y una extensión `Enterprise Architect` con
   `<properties type="string" .../>` para cada atributo. También incluye el
   paquete de primitivos, conectores y un diagrama `Logical` con posiciones y
   tamaños, siguiendo la muestra real proporcionada. La integración desplegada
   fue reconstruida y verificada.
4. Si persiste, conservar el XMI exacto importado y la versión de EA. Hace falta
   comparar ese archivo con lo que EA importó para corregir la incompatibilidad
   concreta. El parser ya tiene una prueba contra el archivo real de Architect;
   la apertura del archivo generado en EA sigue siendo la validación final.

La multiplicidad `[0..1]` indica un atributo opcional y no sustituye al tipo.
La distribución gráfica de las clases tampoco demuestra pérdida de tipos:
el exportador transmite el modelo semántico, sin un diagrama gráfico nativo de EA.
```

---

### `docs/revision-bugs-flutter-2026-09-11.md`

```markdown
# Revisión de errores del cliente Flutter — 11 de septiembre de 2026

Se revisaron especialmente el cliente generado, el agente local, las sesiones y la sincronización. Se conservaron los cambios que ya existían en el espacio de trabajo.

## Correcciones

| Área | Problema | Corrección |
| --- | --- | --- |
| Sesiones | Una respuesta 401 tardía podía reintentar la operación con la sesión de otra cuenta o servidor. Una respuesta exitosa podía entregarse después de cerrar sesión. | Cada inicio/cierre de sesión invalida las peticiones anteriores. Las renovaciones de token se comparten únicamente dentro de la misma sesión. El almacenamiento de la sesión ordena las escrituras y el borrado. |
| Conflictos offline | Aceptar la versión remota podía coincidir con otra resolución, una edición o la sincronización automática. El sondeo de conexión podía quitar el bloqueo de otra operación. | El repositorio excluye estas operaciones y AppModel conserva el bloqueo hasta terminar la resolución. La respuesta remota debe corresponder a la clave y al contrato esperados. |
| Micrófono y Whisper | Cancelar mientras se abría el micrófono podía dejar una grabación activa. Dos paradas simultáneas podían procesar el mismo audio. | Se controla la apertura, grabación y transcripción; se descartan resultados cancelados y se limpia el audio temporal. Salir de la app cancela también una apertura pendiente. La interfaz distingue detener el LLM de descartar una transcripción. |
| Fechas | Dart normalizaba fechas y horas inexistentes que el contrato Java no acepta, por ejemplo `2026-02-30T12:00:00`. | Se compara el valor normalizado y se limita la fracción de segundo a nueve dígitos antes del guardado local. |

## Comprobaciones

- Suite general del repositorio: 527 pruebas, 33 archivos, sin fallos.
- TypeScript: `npm run typecheck`, sin errores.
- Cliente Flutter generado: 41 pruebas, incluidas ocho regresiones nuevas.
- Análisis Flutter: sin incidencias. Compilación del APK debug ARM64: correcta.
- Las regresiones cubren respuestas tardías, renovación entre cuentas, exclusión al resolver conflictos, cancelación durante la apertura del micrófono, doble parada y fechas inválidas.

## Alcance pendiente de validación

Las pruebas de Whisper y del LLM usan adaptadores simulados; no se cargaron pesos reales ni se usó un micrófono físico. Falta comprobar latencia, memoria y calidad de reconocimiento en el teléfono objetivo, además del ciclo completo contra un backend desplegado. La suite general no sustituye las pruebas de integración o de navegador.

La sincronización sigue ejecutándose con la aplicación abierta o al reabrirla. Esta revisión no agrega un servicio Android permanente ni la conexión remota a las IA del `.env`.

Gradle advierte que `ffmpeg_kit_flutter_new_min`, `file_picker` y `llama_flutter_android` usan Kotlin Gradle Plugin: habrá que comprobar su compatibilidad antes de una futura actualización de Flutter. La advertencia no impidió compilar con las versiones actuales.
```

---

### `docs/revision-colaboracion-xmi-2026-09-09.md`

```markdown
# Revisión de colaboración e intercambio XMI

**Estado actualizado:** la [revisión del 10 de septiembre](colaboracion-xmi-2026-09-10.md) completa administración de miembros, edición del candidato e identidad/geometría, e incorpora pruebas reales con EA. El diagnóstico siguiente conserva el estado histórico del día 9.

Revisión adicional solicitada después de corregir B01–B05 de la [auditoría general](auditoria-2026-09-09.md). Se revisó el árbol de trabajo actual, conservando sus cambios previos, y se añadieron casos que las pruebas anteriores no ejercitaban.

## ¿Están completos?

| Área | Implementado | Pendiente para darla por cerrada |
| --- | --- | --- |
| Colaboración | Salas independientes, presencia, sincronización de clases/atributos/relaciones y geometría, permisos de lectura/escritura, reconexión y persistencia PostgreSQL. Se corrigió la pérdida de modificaciones concurrentes en campos distintos del mismo objeto. | Controles web para administrar miembros/roles/invitaciones y ensayo con varios equipos en la red de la presentación. No hay deshacer propio, bloqueo exclusivo ni recuperación offline a través de recargas; estas capacidades son opcionales o dependen del alcance. |
| Exportación XMI | Descarga con perfil Enterprise Architect, clases, atributos, tipos, claves, roles, multiplicidades, asociaciones, agregación, composición, herencia y geometría del diagrama. Pruebas sobre modelos propios y archivos reales aportados. | Aceptación real app → EA 15 → app con la cabecera corregida, comprobando tipos, marcas de clave, roles y posiciones. Las pruebas de XML no acreditan cómo lo interpreta el programa externo. |
| Importación XMI | Lectura del subconjunto conceptual UML admitido, tipos nativos y de extensiones EA, relaciones, conversión de clases asociativas a entidades intermedias, avisos y candidato editable; modos añadir/reemplazar y aplicación colaborativa. | Edición de roles y retirada de operaciones en el candidato, validación visible mientras se edita, recuperación de geometría y preservación de identificadores originales. No es un importador de todo UML: métodos, secuencias, estereotipos arbitrarios y restricciones numéricas exactas quedan fuera del modelo actual. |

RF-050 (exportar) es P0, RF-051 (importar) es P1 y RF-052 (validar) es P0. RF-053 (conservar identidad en el ida y vuelta) figura como **opcional P2** en el plan maestro local. No se debe confundir este último con la existencia de importación/exportación.

El exportador escribe posiciones y UUID en el archivo. El importador los lee solo parcialmente: los comandos se resuelven con identificadores nuevos y el editor coloca las clases nuevas en una rejilla. Por eso el intercambio semántico disponible no equivale a restaurar exactamente la pizarra original.

## Errores encontrados y corregidos en esta revisión

### C01 · P1 · Cambios concurrentes en campos diferentes podían perderse

**Reproducción:** dos réplicas parten de `Cliente.dato: String`; una cambia el nombre a `edad` y la otra el tipo a `Integer`, antes de sincronizarse. Otro caso modifica simultáneamente las multiplicidades de extremos distintos de una relación. Las nuevas pruebas fallaron antes de corregir el aplicador: el nombre o una cardinalidad volvía al valor anterior.

**Causa:** `UPDATE_ATTRIBUTE`, `UPDATE_RELATIONSHIP` y `CHANGE_MULTIPLICITY` reescribían todos los campos del objeto, incluso los no solicitados. Yjs resolvía conflictos artificiales sobre esas escrituras.

**Corrección:** escribir únicamente los campos expresados por el comando; al renombrar se escriben también los nombres técnicos derivados. Se mantienen el nodo y el orden de atributos. Regresiones para nombre/tipo, rol/cardinalidad y ambos extremos de una relación.

Si dos personas escriben valores distintos en **el mismo campo**, el CRDT sigue resolviendo un valor convergente; no existe una pantalla para fusionar ambas intenciones ni un bloqueo exclusivo. Esto es diferente de perder cambios en campos independientes.

### C02 · P1 · Un reemplazo importado podía borrar cambios no revisados

**Reproducción:** preparar un reemplazo; otro participante añade un atributo a una clase que será borrada; aplicar el candidato anterior. También podía aparecer una clase nueva ajena al lote, haciendo que «reemplazar» dejase un resultado distinto del revisado.

**Corrección:** conservar el modelo usado para preparar el candidato y revisar las precondiciones justo antes de escribir en Yjs. Añadir comprueba los elementos afectados; reemplazar comprueba todo el modelo semántico. Los movimientos visuales no invalidan el candidato. Ante cambios, el lote no se aplica, su botón queda deshabilitado y se permite volver a preparar el archivo contra la pizarra actual. Las correcciones manuales del candidato anterior deben revisarse de nuevo. La elección añadir/reemplazar queda fija mientras se revisa un candidato.

### C03 · P1 · XML incompleto podía producir un candidato parcial o vacío

**Reproducción:** un modelo sin etiquetas de cierre, o cerrado con una etiqueta distinta, se aceptaba sin avisos. En modo reemplazo podía terminar proponiendo eliminar contenido desde un archivo roto.

**Corrección:** validar que el XML esté bien formado antes de analizarlo. Se rechazan documentos truncados, cierres incompatibles y atributos XML duplicados con HTTP 400, sin devolver un lote de reemplazo. Esto valida integridad XML; no promete validación completa contra todos los esquemas UML/XMI.

### C04 · P2 · Colisiones técnicas de atributos bloqueaban la revisión

**Reproducción:** importar `fecha de venta` y `fechaVenta` dentro de una clase devolvía una pregunta que el panel no podía resolver, en lugar de un candidato editable.

**Corrección:** al crear atributos desde XMI, distinguir los nombres literales, como ya se hacía con las clases. El candidato conserva ambos atributos para corregirlos antes de aplicar. Las instrucciones por texto/voz conservan su búsqueda normalizada. Los errores del modelo siguen bloqueando generación, sin impedir la edición que los corrige.

### C05 · P2 · Cardinalidades finitas se convertían silenciosamente en uno

**Reproducción:** el extremo `2..5` se convertía en `1`, alterando incluso si la relación admitía varios elementos.

**Corrección:** representar ese extremo como `1..*` dentro del subconjunto admitido y mostrar un aviso que identifica el intervalo original y la aproximación. El límite exacto de cinco no está implementado ni se genera como una regla de negocio; requiere revisión por el usuario.

## Verificación

- 474 pruebas unitarias aprobadas, incluidas las nuevas regresiones de XML, nombres, cardinalidades y Yjs.
- 130 pruebas de integración aprobadas con PostgreSQL temporal. La prueba de reemplazo desde XML truncado exige HTTP 400 y ausencia de lote.
- TypeScript, ESLint, Prettier y compilación de producción aprobados.
- Suite completa de navegador: 83/84 en la primera ejecución; el único fallo era una expectativa incorrecta de la prueba nueva, que buscaba el nombre técnico en lugar del nombre visible original del atributo. Se corrigió esa expectativa y se repitieron las cuatro regresiones nuevas contra Docker: **4/4 aprobadas**. Los 80 recorridos anteriores también aprobaron. Se conservan las evidencias de la ejecución inicial; no se presenta como una ejecución única de 84/84.
- API, colaboración y web reconstruidos y actualizados en Docker, conservando la base y sus volúmenes, sin migraciones. Los servicios quedaron saludables; `/`, `/api/health` y `/collab/health` respondieron HTTP 200 en `http://localhost:8080`.
- La comprobación de rendimiento colaborativo de esta ejecución midió P95 de 66 ms con cinco participantes y treinta cambios en loopback, sin medir render de navegador ni red del aula.
- Evidencia de navegador y ejecutor aislado en `reports/revision-collab-xmi/`, directorio local ignorado por Git. Los tests versionables están en `e2e/specs/revision-colaboracion-xmi.spec.ts` y las suites existentes.

Comandos: `npm test`, `npm run test:api`, `npm run typecheck`, `npm run lint`, `npm run format:check`, `npm run build`; navegador aislado mediante `node --import tsx reports/revision-collab-xmi/run-current.mjs`; regresiones finales mediante `node node_modules/@playwright/test/cli.js test --config e2e/playwright.config.ts revision-colaboracion-xmi --output reports/revision-collab-xmi/docker-final`.

Las pruebas automatizadas usan IA simulada cuando corresponde. Esta revisión no ejecuta Enterprise Architect, inferencia GGUF, micrófono físico ni dispositivos Android.

## Qué falta del proyecto completo

1. Completar administración visual de miembros y la revisión de candidatos de importación.
2. Ofrecer restauración/versiones y recuperación visible de errores de auditoría según el alcance acordado.
3. Cerrar la aceptación real con Enterprise Architect y el ensayo colaborativo entre equipos.
4. Preparar la aplicación Flutter del caso de presentación y acreditar GGUF, voz y datos offline con sincronización en teléfono físico.
5. Si se exige operar sin teclado ni mouse, añadir controles de envío y confirmación por voz. El dictado revisable actual todavía utiliza botones.
6. Antes de publicar, atender los avisos de dependencias identificados en la auditoría, límites de acceso/consumo, HTTPS, correo y copias de seguridad con restauración ensayada.

Los detalles generales y las ampliaciones opcionales siguen en [pendientes](pendientes.md) y en la [matriz de requisitos del docente](requisitos-docente-2026-09-06.md). No se declara ausencia total de errores por aprobar las pruebas; esta revisión encontró casos fuera de la cobertura anterior.
```

---

### `docs/revision-despliegue-vps-2026-09-17.md`

```markdown
# Revisión de preparación para VPS con Docker y HTTPS

Fecha: 17 de septiembre de 2026. Base: commit `36a234a` y los ocho archivos con cambios locales que ya existían al iniciar la revisión.

> **Resuelto el mismo día.** Los faltantes de esta revisión se atendieron con `infra/compose.production.yml`, `infra/caddy/Caddyfile.production`, `scripts/production.sh`, el contenedor de copias y el monitor de systemd; el instructivo vigente es [`infra/DEPLOYMENT.md`](../infra/DEPLOYMENT.md) y la prueba `npm run test:production` verifica la configuración en contenedores. Este documento se conserva como registro de lo que se encontró.

**Dictamen original: todavía no está listo para publicarse en un VPS tal como está configurado.** La compilación y las pruebas rápidas pasan; faltan controles y configuración de producción. El entorno local responde correctamente, pero eso no acredita un despliegue con dominio, TLS y datos recuperables.

## Comprobaciones realizadas

| Comprobación | Resultado |
| --- | --- |
| Formato, lint y tipos | Correctos; se ejecutaron mediante `npm run check`. |
| Pruebas rápidas | `npm test`: 556 pruebas, 37 archivos, todas correctas. |
| Compilación | `npm run build`: todos los workspaces y frontend de producción correctos. |
| Integración de API y colaboración | `npm run test:api`: 136 pruebas, 7 archivos, todas correctas; incluye migraciones sobre PostgreSQL temporal. |
| Docker Compose | Configuración resuelta correctamente. API, colaboración, web y PostgreSQL saludables. |
| Enrutamiento HTTP local | `/api/health` y `/collab/health` responden `status: ok` a través de nginx. |
| Dependencias vulnerables | Sin dictamen: la consulta de `npm audit` requiere autorización para enviar nombres y versiones a npm. |

El primer arranque de Vitest falló por restricciones de lectura del entorno de ejecución. La repetición con permisos adecuados pasó; ese fallo inicial no se atribuye al proyecto.

No se ejecutó la suite E2E completa, el banco de compilación/ejecución de los proyectos Java/Android generados, una reconstrucción completa de imágenes Docker ni pruebas sobre un VPS real. La integración usa bases temporales y no la base con las pizarras del usuario. Los proveedores reales de IA no se certificaron en esta revisión.

## Faltantes antes de publicar

| Prioridad | Hallazgo y evidencia | Acción necesaria |
| --- | --- | --- |
| Alta | HTTPS no está configurado: `infra/caddy/Caddyfile:10` escucha en `:80`; `infra/compose.yml:224` publica solamente el puerto 80 del proxy. El proxy pertenece al perfil `demo`. | Preparar configuración de producción con dominio real, puertos 80/443, certificados persistentes y validación de HTTPS/WSS. Cambiar solamente `:80` por el dominio no publica el puerto 443 en Docker. |
| Alta | PostgreSQL, API y colaboración publican puertos en todas las interfaces. Evidencia: `infra/compose.yml:28`, `:138`, `:174`; confirmado con `docker compose ps`. Web también publica 8080. | Dejar públicos únicamente los puertos del proxy; mantener los servicios internos en la red Docker o enlazados a loopback si se necesita administración local. Revisar también el cortafuegos del VPS. |
| Alta | La configuración resuelta mantiene `NODE_ENV=development`, `COOKIE_SECURE=false`, `WEB_ORIGIN=http://localhost:8080`. Los valores por defecto de Compose son también de desarrollo (`infra/compose.yml:65`). | Crear configuración separada de producción con `NODE_ENV=production`, `COOKIE_SECURE=true` y el origen HTTPS exacto. Usar credenciales de producción y una sola clave JWT compartida por API y colaboración. |
| Alta | No se encontró limitación de peticiones en los registros de plugins/rutas de la API ni en los proxies. `backend/api/src/app.ts:40` registra CORS, cookies, Prisma y autenticación, sin rate limiting. | Limitar registro, login, recuperación de contraseña, IA y generación. Definir cuotas por usuario y controles por IP con un tratamiento correcto del proxy. Evitar abuso de cuentas, CPU y cuota de proveedores. |
| Alta | PostgreSQL persiste en `db-data`, pero no hay un proceso de backup/restauración en infraestructura, scripts o CI. `docs/despliegue.md:287` lo reconoce como pendiente. | Programar copias fuera del VPS, fijar retención y probar una restauración aislada antes de admitir datos importantes. Un volumen persistente no sustituye una copia. |
| Media | `MAIL_PROVIDER=log`: la recuperación no entrega correo; escribe el enlace completo en registros (`backend/api/src/lib/mail.ts:65`). La URL del enlace usa `WEB_ORIGIN` (`backend/api/src/modules/auth/profile.ts:248`). | Configurar Brevo y un remitente válido, probar entrega y recuperación desde el dominio público y restringir acceso a registros. |
| Media | No hay límites de CPU/memoria ni rotación de logs declarados. Los contenedores actuales confirman `memory=0`, `cpus=0` y `json-file` sin opciones. | Definir límites acordes al VPS, rotación/retención de logs y alertas mínimas de disco, memoria y disponibilidad. |
| Media | El proceso de actualización no fija una versión de release ni un rollback probado. `npm run up` no obliga a reconstruir imágenes existentes. La guía de cambio de variables recrea únicamente `api` (`docs/despliegue.md:162`). | Documentar build, migración, recreación, comprobación funcional y vuelta a una versión anterior. Si se cambia JWT, actualizar API y colaboración conjuntamente. Esto evita repetir el incidente de «Sin conexión» causado por claves distintas. |

La publicación de puertos no demuestra por sí sola que un cortafuegos externo los permita; el hallazgo es que la configuración de Docker los enlaza a todas las interfaces y no aporta una configuración de producción que los restrinja. No se ha inspeccionado un VPS ni su red.

## Lo que ya está preparado

- Dockerfiles por servicio, construcción por etapas y dependencias instaladas con lockfile.
- API y colaboración ejecutadas como usuario `node`.
- Migraciones separadas mediante `prisma migrate deploy` y dependencia del estado saludable de PostgreSQL.
- Persistencia en volumen, políticas de reinicio y cierre ordenado de API/colaboración.
- Proxy local de HTTP y WebSocket; el frontend selecciona `wss` al abrirse mediante HTTPS.
- `.env` excluido de Git y del contexto de Docker; no se imprimieron valores secretos durante la revisión.
- Flujo CI con formato, lint, tipos, pruebas rápidas, integración, generación y E2E. Se verificó su definición, no el estado de una ejecución remota de GitHub.

## Criterio para autorizar el despliegue

1. Resolver HTTPS, exposición de puertos, configuración de sesión, límites de peticiones y copias/restauración.
2. Construir las imágenes desde una versión identificada, aplicar migraciones y comprobar el arranque en un entorno aislado equivalente al VPS.
3. Completar la auditoría de dependencias y revisar las imágenes base; esta revisión no certifica ausencia de vulnerabilidades.
4. Probar con el dominio HTTPS: login/renovación de sesión, dos usuarios colaborando, reconexión, importar/exportar XMI, importar foto, generar y descargar ZIP y recuperar contraseña.
5. Verificar restauración, reinicio con datos persistentes y procedimiento de rollback compatible con las migraciones.

El camino razonable es añadir un archivo Compose específico de producción y una configuración Caddy para el dominio. Docker documenta este uso de [configuración adicional para producción](https://docs.docker.com/compose/how-tos/production/). Para el HTTPS automático de Caddy deben cumplirse las condiciones de [dominio, DNS, puertos y almacenamiento persistente](https://caddyserver.com/docs/automatic-https). La documentación de [publicación de puertos de Docker](https://docs.docker.com/engine/network/port-publishing/) explica su exposición por defecto.

Esta revisión genera este informe y artefactos de compilación; no cambia código de aplicación, configuración de despliegue ni secretos.
```

---

### `docs/revision-generador-crud.md`

```markdown
# Revisión de generación de aplicaciones CRUD

Fecha: 6 de septiembre de 2026. Alcance: código actual, configuración CORS y generación de aplicaciones de gestión desde distintos diagramas. Se excluyen las pruebas del agente IA, inferencia GGUF y dictado por indicación del usuario.

## Dónde se configura cada cosa

| Configuración | Lugar | Ejemplo |
| --- | --- | --- |
| CORS de la aplicación generada | `backend/.env` del ZIP generado, leído por `WebConfig` de Spring | `CORS_ALLOWED_ORIGINS=https://frontend.ejemplo.com,http://localhost:5173` |
| URL que consume Flutter | Campo Dirección del backend en login, o `API_BASE_URL` al compilar | `https://api.ejemplo.com` |
| PostgreSQL, credenciales de login y secreto de tokens | Entorno del backend Spring generado | `DATABASE_URL`, `DB_USER`, `DB_PASSWORD`, `AUTH_USERNAME`, `AUTH_PASSWORD`, `AUTH_TOKEN_SECRET` |
| HTTP de desarrollo, permisos Android y firma | Proyecto Android del cliente Flutter | Debug permite HTTP; distribución requiere HTTPS y firma propia |
| Configuración del diseñador UML | `infra/.env` de este repositorio | Configura la herramienta principal; no configura automáticamente los servidores independientes que generas |

**CORS vive en Spring Boot, no en Dart.** Android nativo y Postman no están sujetos a CORS del navegador. Para Flutter web u otro frontend web se habilitan orígenes exactos en el backend. El origen es el del frontend, sin rutas; no la dirección del teléfono ni un comodín. CORS no sustituye autenticación. El perfil móvil contempla CRUD, login, contrato y sincronización. Referencia: [Spring MVC CORS](https://docs.spring.io/spring-framework/reference/web/webmvc-cors.html).

## Qué genera un diagrama

Cada clase del modelo generable produce su entidad, repositorio, servicio, controlador y DTO. Relaciones y tipos forman el contrato REST y el esquema PostgreSQL. También se emiten Postman, OpenAPI, documentación, Dockerfile y Compose.

Al elegir **Android + backend**, se añaden autenticación y endpoints `/mobile-contract` y `/mobile-sync`. Flutter obtiene ese contrato en el login y adapta sus colecciones y formularios. Login, configuración GGUF, búsqueda, CRUD y cola offline son comunes; las pantallas particulares se registran en `lib/ui/custom_pages.dart`.

Ejemplos posibles: ventas/clientes/productos, compras/proveedores, barbería/citas/servicios, activos/ubicaciones/responsables e inscripciones/estudiantes/cursos. Son bases CRUD ajustadas al modelo; una aplicación bancaria completa, contabilidad, pagos o disponibilidad de citas requieren reglas adicionales.

## Verificación reproducible

`npx tsx scripts/verify-management-apps.ts` recorre los modelos generables del banco. Por cada uno genera Android + backend, compila Java con Maven, arranca PostgreSQL temporal, autentica, compara `/mobile-contract` con el contrato Flutter, crea/consulta/actualiza/borra recursos y comprueba reintentos con el mismo ID de operación. Las altas respetan dependencias y los borrados se hacen en orden inverso. No llama a ningún motor o proveedor IA.

Para repetir un caso con claves numéricas: `npx tsx scripts/verify-management-apps.ts T03 --numeric-keys`.

Resultado del banco: **8 modelos aprobados, 34 recursos en total**, con generación, compilación, contrato, CRUD, referencias y reintentos verificados contra PostgreSQL.

Además, T03 se repitió con claves Integer: sus cuatro recursos también aprobaron. Esto acredita que el perfil móvil no depende exclusivamente de claves UUID.

| Modelo | Dominio | Recursos | Resultado |
| --- | --- | ---: | --- |
| T01 | Ventas | 4 | Aprobado |
| T02 | Compras | 4 | Aprobado |
| T03 | Barbería | 4 | Aprobado |
| T04 | Inventario de activos | 4 | Aprobado |
| T05 | Cuentas y movimientos | 3 | Aprobado |
| T06 | Inscripciones | 3 | Aprobado |
| T07R | Nombres y relaciones conflictivos corregidos | 5 | Aprobado |
| T08 | Institución con jerarquía de clases | 7 | Aprobado |

Las siete pruebas Flutter de almacenamiento/cola seleccionadas en esta revisión aprobaron: consolidación antes del envío, cancelación de alta local, confirmación perdida, inmutabilidad después de intentar envío, propagación de borrados, reapertura SQLite, edición obsoleta y resolución de conflicto. Se excluyeron las pruebas de propuestas del agente. Las cuatro pruebas de contrato/login, el APK compilado y las verificaciones CORS del turno anterior siguen siendo la evidencia complementaria de la base móvil.

## Cumplimiento y faltantes

| Requisito | Estado |
| --- | --- |
| Diferentes diagramas → backends CRUD independientes | Implementado para modelos aceptados por el validador; comprobación real por banco descrita arriba |
| Spring Boot, PostgreSQL y cinco capas incluyendo DTO | Implementado |
| Postman, OpenAPI y ejecución local | Implementado |
| Flutter común adaptable al backend generado | Implementado; contrato versionado, formularios genéricos y extensión de pantallas |
| Login estándar | Administrador compartido; faltan registro, recuperación, roles y aislamiento multiempresa si la aplicación los necesita |
| Preparación de IA local | Carga GGUF y configuración implementadas; calidad y funcionamiento físico no acreditados, sin probar por solicitud del usuario |
| CRUD y persistencia offline | Implementados; siete pruebas de almacenamiento/cola aprobadas |
| Sincronización al recuperar conectividad | Se intenta con la app abierta y al reabrir; falta servicio permanente con la app cerrada, si se desea ese comportamiento |
| Despliegue sencillo | Docker/Compose y configuración Railway preparados; no hay despliegue externo acreditado |
| Aplicación lista para distribución pública | Pendientes firma release, HTTPS en servidor real, copias y migraciones de esquema versionadas |
| Todo el alcance de la presentación | Pendiente ensayo físico Flutter + voz/IA offline, foto real, recorrido Architect y demostración colaborativa en los equipos previstos |

## Límites que no deben confundirse con generación completa

- El validador admite un subconjunto UML: no claves compuestas, herencia múltiple ni ciclos de herencia. Las relaciones muchos a muchos necesitan una clase intermedia explícita. Los nombres ambiguos o duplicados deben resolverse antes de generar.
- Crear CRUD no genera automáticamente cobros, totales, descuentos de stock, intereses ni transacciones entre varios recursos. Añadir esos casos de uso en Servicio/Controlador y las pantallas correspondientes.
- Flutter usa el protocolo móvil generado; para un REST diferente hace falta un adaptador o implementar ese protocolo. Cambiar pantallas exige recompilar; cambiar URL compatible puede hacerse en login.
- El primer login requiere conexión. Después se conserva sesión/contrato/datos; un token remoto vencido requiere volver a iniciar sesión para sincronizar. La inferencia offline requiere pesos compatibles instalados previamente.
- No se promete sincronización incremental a gran escala ni migración automática entre contratos incompatibles. Una operación cuyo envío se intentó no se modifica hasta confirmar o resolver el conflicto. El usuario puede aceptar la versión del servidor y editar de nuevo.

La conclusión correcta es que la plataforma puede generar distintas **bases de aplicaciones de gestión CRUD**, con backend y cliente estándar, pero todavía no cumple por sí sola todos los requisitos de una aplicación de negocio terminada ni toda la demostración del docente.
```

---

### `docs/revision-ia-2026-09-06.md`

```markdown
# Revisión del prompt y uso de IA

Fecha: 6 de septiembre de 2026. Alcance: instrucciones, consultas, extracción visual, resolución de operaciones, contexto de aclaraciones y consumo de proveedores.

## Estado

El flujo tiene mejores reglas y validaciones, y ya evita algunas llamadas innecesarias. **Todavía falta controlar el gasto por usuario, cancelar solicitudes abandonadas y medir calidad con proveedores reales.** Añadir respaldos aumenta disponibilidad; no establece un presupuesto ni garantiza mejores respuestas.

## Correcciones realizadas en esta revisión

- Instrucciones de texto: una respuesta incompleta ya no se rescata como si fuera una propuesta completa. Se rechazan operaciones con campos desconocidos y actualizaciones sin ningún cambio indicado. La recuperación parcial de visión permanece explícita y con aviso.
- Se comprueba el motivo de finalización del proveedor: un JSON aparentemente válido no basta si el proveedor informa truncamiento. Se conserva la recuperación visual explícita de Gemini cuando corresponde.
- El resolver procesa una vista temporal actualizada tras cada operación. Crear, renombrar, añadir atributos y volver a usar el nombre nuevo dentro de un mismo pedido ya no depende del estado anterior a la solicitud.
- Corregida la asignación de multiplicidades cuando el pedido menciona los extremos de una relación en orden inverso. Los roles ahora permiten desambiguar relaciones paralelas al modificarlas o eliminarlas.
- El prompt especifica dependencias, reutilización de entidades, negaciones, autocorrecciones, roles y límites de campos. Las aclaraciones solicitan una respuesta concreta y no mezclan preguntas con operaciones para aplicar. Los nombres se serializan como datos; esto no sustituye la validación ni garantiza inmunidad a instrucciones maliciosas dentro de los datos.
- La conversación conserva el pedido y las aclaraciones. Cuando excede el contexto permitido, se ofrece recuperar la solicitud completa para editarla; no se elimina silenciosamente el inicio del pedido.
- Las consultas exactas admitidas sobre cantidad de clases, cantidad de relaciones y lista de clases se responden localmente, sin llamar a un proveedor. Otras preguntas mantienen el flujo LLM.
- Los errores de configuración de Anthropic ya no se tratan como caídas que disparen respaldos innecesarios. Se muestra la explicación breve de la propuesta cuando existe.

Implementación principal: [prompt](../shared/ai/src/prompt.ts), [contrato](../shared/ai/src/proposal.ts), [resolver](../shared/ai/src/resolver.ts), [respuestas locales](../shared/ai/src/local-answer.ts) y [panel del asistente](../frontend/src/features/assistant/AssistantPanel.tsx).

## Pendientes por prioridad

| Prioridad | Falta | Evidencia e impacto | Criterio de cierre |
| --- | --- | --- | --- |
| Alta | Cancelación de extremo a extremo | El panel ignora respuestas al cambiar de pizarra, pero el cliente HTTP y las rutas no propagan una cancelación a los puertos. La inferencia puede continuar hasta su plazo máximo. | Conectar la cancelación de la interfaz, HTTP y proveedor; comprobar desconexión, cambio de pizarra y cancelación manual. Cancelar puede evitar trabajo restante, pero no revierte tokens ya procesados. |
| Alta | Límites de consumo y concurrencia | Hay bloqueo de doble envío en el panel y un plazo por cadena, pero no presupuesto por usuario/proyecto ni deduplicación de solicitudes simultáneas en el servidor. | Limitar solicitudes concurrentes y frecuencia, establecer presupuestos configurables y reconocer solicitudes idénticas en curso sin cobrar dos llamadas. |
| Alta | Contabilidad completa y privada | La cadena conserva hasta 200 usos exitosos en memoria. Los intentos fallidos o truncados pueden consumir tokens sin quedar registrados. `/assistant/usage` muestra datos agregados del proceso a cualquier usuario autenticado. | Registrar intentos, resultados y uso disponible por usuario/proyecto/proveedor; persistirlos y restringir su consulta. Incluir tokens de razonamiento/caché cuando el proveedor los reporte, sin inventar valores ausentes. |
| Alta | Propuestas vinculadas al estado revisado | Se valida contra el modelo enviado; al aplicar después, la pizarra colaborativa puede haber cambiado. Las precondiciones de comandos no detectan todo cambio de significado. | Vincular la propuesta a una revisión o huella semántica y revisar los cambios antes de aplicarla sobre otro estado. |
| Alta | Distinguir errores semánticos nuevos | El dominio permite estados incompletos durante la edición. Que un lote sea aplicable no garantiza que deje un modelo válido para generar código. | Comparar los hallazgos anteriores y posteriores; mostrar o impedir nuevos errores relevantes sin bloquear la reparación de modelos ya incompletos. |
| Media | Reutilizar la extracción de imágenes | Cambiar de importación a «Reemplazar» vuelve a enviar la imagen y ejecuta otra extracción visual. | Conservar una extracción validada, acotada y asociada al usuario; recalcular localmente el candidato según modo y pizarra. No reutilizar comandos con identificadores o permisos de otra solicitud. |
| Media | Contrato estructurado por operación y proveedor | El esquema JSON común exige `op`, pero muchos campos siguen siendo opcionales en ese esquema. El prompt y Zod completan la protección; el modelo aún puede producir una combinación inválida. | Mantener una fuente de verdad y adaptar esquemas según las capacidades verificadas de cada proveedor. Probar campos requeridos, prohibidos y condiciones por operación. |
| Media | Presupuesto de contexto y salida por tarea | Los límites de salida son distintos entre adaptadores y amplios para consultas breves. Los turnos de aclaración tienen límite de caracteres, no un presupuesto conjunto de tokens. | Separar consulta, edición y visión; medir antes de ajustar límites. Conservar información necesaria y detectar truncamiento, sin recortar operaciones para ahorrar. |
| Media | Aclaraciones referidas a opciones | El contexto conserva la pregunta, pero no incorpora las opciones que el resolver devuelve por separado. Una respuesta como «la primera» puede perder su referente. | Enviar opciones identificables con la aclaración o exigir una selección explícita que conserve su significado. |
| Media | Calidad comprobada con APIs reales | Las regresiones verifican lógica y contratos mediante respuestas simuladas. No permiten ordenar los proveedores de mejor a peor. | Ejecutar un banco pequeño con presupuesto acordado: negaciones, correcciones, acciones encadenadas, roles, herencia, intermedias y fotos. Medir exactitud, aclaraciones, fallos, tokens y latencia por modelo. |

Referencias de código para consumo y cancelación: [rutas IA](../backend/api/src/modules/ai/routes.ts), [cliente HTTP](../frontend/src/lib/api.ts), [cadena de respaldos](../shared/ai/src/fallback-chain.ts), [importación visual](../backend/api/src/modules/import/routes.ts) y [panel de importación](../frontend/src/features/import/ImportPanel.tsx).

## Otros límites que siguen vigentes

- La pausa por cuota vive en cada proceso; varias instancias no comparten ese estado. Los reintentos internos de SDK también deben armonizarse con el tratamiento HTTP de cuotas y `Retry-After` si se habilitan.
- Conviene preparar imágenes con recorte o ajuste de tamaño conservando legibilidad y revisión del usuario. La ruta actual envía la imagen original.
- El dictado sigue usando reconocimiento del navegador. Los adaptadores de transcripción del servidor existen, pero falta conectarlos mediante grabación de audio cuando el navegador no ofrece reconocimiento. Sigue pendiente probar micrófono, teclado virtual y suspensión en teléfonos reales.
- La limpieza del dictado es local y conservadora. No se hace una llamada extra de resumen antes de la llamada de instrucciones; la interpretación de intención ocurre en esa misma respuesta.
- Completar claves en `.env` no resuelve estos pendientes de implementación. Tampoco es posible garantizar disponibilidad por tener siete respaldos: dependen de sus cuentas, cuotas y modelos habilitados.

## Verificación realizada

- **442 pruebas unitarias y de regresión aprobadas, en 26 archivos.** Incluyen casos de secuencias de operaciones, roles, respuestas truncadas, errores de proveedores, consultas locales y conservación de contexto.
- **5 pruebas de navegador del flujo de voz y aclaraciones aprobadas.** El reconocimiento y las respuestas de IA son simulados; el entorno de aplicación es local.
- TypeScript, ESLint y formato aprobados. API y web compiladas y reconstruidas en Docker; la API alcanzó estado saludable y la web arrancó correctamente.
- Medición local del resolver con 170 operaciones: mediana de aproximadamente 30 ms en diez ejecuciones medidas, tras calentamiento. No incluye inferencia remota ni representa rendimiento de producción.
- No se consumieron cuotas reales de IA en estas verificaciones. No se acredita todavía calidad comparada, disponibilidad real de todas las cuentas ni ahorro monetario medido.

La medición anterior de longitud del prompt en [voz y consumo](voz-y-consumo-ia.md) corresponde a una etapa previa. Esta revisión añadió reglas necesarias para corregir errores; menos caracteres no es por sí solo una mejora si aumenta los reintentos o pierde intención.

Para interpretar terminaciones se consultaron las referencias oficiales de [Gemini](https://ai.google.dev/api/generate-content) y [Anthropic](https://platform.claude.com/docs/en/build-with-claude/handling-stop-reasons). La disponibilidad de [salidas estructuradas de Anthropic](https://platform.claude.com/docs/en/build-with-claude/structured-outputs) no sustituye la validación semántica local.

El siguiente incremento recomendado es **cancelación + límites por usuario + registro de todos los intentos**, seguido de reutilización de visión y evaluación comparada. Son las mejoras con mayor relación directa con el control de gasto pendiente.
```

---

### `docs/revision-ia-2026-09-10.md`

```markdown
# Revisión del asistente de texto y voz

Fecha: 10 de septiembre de 2026. Actualiza la [revisión del 6 de septiembre](revision-ia-2026-09-06.md).

## Cambios implementados

- Prompt común de instrucciones reorganizado por intención, contexto, referencias, tipos, restricciones y relaciones. Explicita autocorrecciones parciales, negaciones, cardinalidades dictadas y opciones ordinales. No permite representar funciones no soportadas mediante cambios inventados ni afirmar que una propuesta ya se aplicó.
- Las propiedades `required:false` y `unique:false` se explican expresamente. Un nombre `id` no autoriza por sí solo a añadir una clave primaria. Las multiplicidades exactas fuera del vocabulario, como `2..5`, requieren aclaración en vez de una aproximación silenciosa.
- Prompt de consulta: diferencia datos existentes de sugerencias y evita equiparar ausencia de hallazgos del validador con proyecto completo, desplegado o probado.
- Contexto y hallazgos serializados como JSON para separar el texto de los datos de los encabezados. Esto reduce ambigüedad de formato; no sustituye la validación ni garantiza inmunidad a instrucciones incrustadas.
- Las opciones de una aclaración se muestran y envían con la misma numeración, sin ocultar la novena en adelante. Si el contexto excede el contrato, se recupera completo para revisión, sin truncarlo.
- Al rechazar una propuesta desactualizada, se recuperan la instrucción y sus aclaraciones originales; antes solo se recuperaba la última respuesta, como «la primera».
- Inferencia determinista corregida: `numeroTelefono`, `numeroDocumento` y `codigoPostal` son texto; `Madrid` y `Android` no se convierten en enteros por terminar en `id`. Se reconocen `clienteID`, `IDCliente` y `UUIDCliente`. Un tipo explícito conserva prioridad.
- Si el dictado falla sin reconocer palabras, el borrador anterior permanece intacto, incluidos espacios y preámbulos. Se mantiene Dictar → Parar → revisar → Enviar, sin llamadas LLM por resultados parciales ni una llamada adicional para limpiar el dictado.
- Botón **Cancelar solicitud** para instrucciones y consultas. Recupera el texto, ignora respuestas tardías y cancela HTTP. El cambio de pizarra o desmontaje del panel también cancela. La API propaga la desconexión a los puertos de instrucciones, consultas y transcripción; la cadena existente respeta esa señal. Cancelar no revierte tokens ya procesados.

## Verificación

- **527/527 pruebas unitarias**, en 33 archivos. Evidencia: `reports/revision-ia-2026-09-10/unitarias.xml`.
- **13/13 pruebas de integración** de las rutas del asistente con PostgreSQL temporal y proveedores simulados. Evidencia: `integracion.xml` en el mismo directorio.
- **7/7 pruebas de Chromium** contra Docker: voz, pausas, cancelación, permisos del micrófono, contexto largo, opciones y recuperación de una propuesta desactualizada tras edición de otro usuario. Reconocimiento y respuestas LLM simulados; cuentas y colaboración reales del entorno local. Evidencia: `navegador.xml`.
- Después del ajuste de legibilidad de la conversación, **13/13 pruebas finales de Chromium**: las siete anteriores y seis tamaños móviles, de 320 × 568 a 844 × 390. Evidencia: `navegador-final.xml`.
- TypeScript y ESLint aprobados. API y web compiladas y actualizadas en Docker.
- Comprobación final de formato y `git diff --check` aprobada. Los cuatro contenedores quedaron saludables; se conservaron la base de datos y los volúmenes.
- Prueba HTTP con servidor real: recibir un POST completo no cancela la inferencia; abortar la conexión mientras se espera la respuesta sí lo hace. La respuesta normal libera los listeners sin marcar cancelación. Se siguió la distinción entre finalización y cierre prematuro de [ServerResponse en Node.js](https://nodejs.org/api/http.html#event-close_2).

La primera ejecución unitaria falló únicamente en una expectativa que exigía el formato anterior `Usuario: ...`; se actualizó para comprobar los turnos JSON completos y la suite volvió a pasar. No se interpreta este cambio de formato como pérdida de contexto.

## Evaluación del proveedor real

Se preparó [un banco optativo de ocho casos](../scripts/verify-ai-prompts.ts): negación/autocorrección, cardinalidades habladas, restricciones negativas, herencia, acciones dependientes, aclaración ordinal, teléfono y límite no representable. Utiliza diagramas sintéticos, el principal configurado, ningún respaldo, cero reintentos y 45 segundos por llamada. No lee ni modifica pizarras del usuario.

La revisión automática bloqueó el primer intento por límite de uso de Codex, antes de ejecutar la llamada. Después de que el usuario pidió continuar, la ejecución fue autorizada. El primer caso con `gemini / gemini-3.7-flash` terminó con `ProviderUnavailableError` (plazo configurado: 45 segundos); el banco se detuvo. El registro conserva el tipo de error, no acredita su causa remota exacta. **No hay casos reales aprobados ni evidencia suficiente para afirmar mejora de exactitud, ahorro monetario o disponibilidad de todos los proveedores.** El resultado está en `reports/revision-ia-2026-09-10/proveedor-real.json`. El fallo del principal aislado no demuestra que fallen los respaldos de la aplicación.

El prompt de instrucciones tiene 3.822 caracteres, el de consulta 755 y el bloque de esquema 1.751. Son caracteres, no tokens. Se priorizaron reglas que evitan cambios incorrectos y solicitudes repetidas; no se acredita una reducción del tamaño total del prompt ni del costo.

## Límites pendientes

- Repetir el banco cuando el principal responda y comparar exactitud por proveedor. Las pruebas simuladas acreditan contratos y flujo, no comprensión del lenguaje natural.
- Micrófono físico y reconocimiento en distintos navegadores y teléfonos. Se conserva el servicio del navegador; los adaptadores de transcripción del servidor aún no están conectados mediante MediaRecorder como alternativa desde el botón Dictar. Los resultados provisionales pueden cambiar o desaparecer según [Web Speech](https://developer.mozilla.org/en-US/docs/Web/API/SpeechRecognitionEvent/results); el flujo mantiene la revisión manual.
- Límites de consumo y concurrencia por usuario/proyecto y registro privado y persistente de intentos, incluidos fallos. El registro actual de uso sigue siendo agregado en memoria.
- Cancelación y reutilización de extracciones en el panel de importación visual. Esta revisión conecta la cancelación del asistente, no la de todas las operaciones de importación.
- La consulta es sobre la pizarra actual y no tiene una conversación propia de seguimiento; las aclaraciones conservadas pertenecen a Instruir.

Las operaciones propuestas siguen pasando por el contrato, la resolución de referencias y las precondiciones colaborativas antes de aplicarse por decisión de la persona.
```

---

### `docs/revision-ia-local-flutter.md`

```markdown
# Agente local Flutter: voz y texto intercambiables

La plantilla Android + backend ahora permite importar varios modelos y seleccionar
uno de voz y otro de texto, sin conexiones a proveedores ni descarga automatica de
pesos. Los archivos se copian al almacenamiento privado y las selecciones y ajustes
se conservan al reabrir. Cada modelo guarda sus propias preferencias.

- Texto: LiteRT-LM `.litertlm` y GGUF de instrucciones, con system prompt comun.
- Voz: Whisper GGML `.bin` de whisper.cpp, incluidas cuantizaciones compatibles;
  español por defecto, sin traduccion y con vocabulario del recurso seleccionado.
- Operaciones: transcripcion editable → propuesta JSON → validacion → confirmacion
  → SQLite → cola de sincronizacion. El modelo no ejecuta llamadas ni SQL.
- Recursos: inferencia secuencial y liberacion de pesos entre voz y texto; tiempos
  visibles para comparar. Se puede quitar una copia privada sin borrar el original.
- Offline: la comprobacion de conexion ya no bloquea el guardado local. La cola
  conserva las protecciones de idempotencia y conflicto durante el envio efectivo.

El prompt vive en
[assistant_prompt.dart.tpl](../templates/flutter/lib/domain/assistant_prompt.dart.tpl).
La [guía incluida en cada ZIP](../templates/flutter/docs/local-models.md.tpl)
explica formatos, importacion, ajustes, memoria, comparacion y preparacion Android.

## Verificacion

Se aprobaron 33 pruebas Flutter: persistencia y cambio de modelos, preferencias por
archivo, configuracion de voz, cancelacion y limpieza de audio, validacion de
propuestas, guardado mientras la red no responde, reconexion, contratos, sesiones,
cola SQLite y selectores a 360 px. Las pruebas de inferencia usan motores simulados.
El analisis Flutter y la compilacion del APK debug ARM64 se verifican sobre un
proyecto emitido por el generador. La compilacion nativa requirio fijar NDK 29 y
corregir el compileSdk de la dependencia Whisper mediante configuracion del proyecto,
sin modificar el cache global de paquetes.

No se han ejecutado pesos reales ni probado el microfono de un telefono. No se
atribuye precision o rendimiento a un modelo concreto. El primer login necesita
el backend; la sincronizacion ocurre con la app abierta o al reabrir. Sigue usando
`/mobile-contract`; la pasarela a las IA de `infra/.env`, Whisper remoto y consumo
directo de OpenAPI quedan fuera de esta ampliacion local.
```

---

### `docs/voz-y-consumo-ia.md`

```markdown
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
```

