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
