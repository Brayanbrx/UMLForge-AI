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
