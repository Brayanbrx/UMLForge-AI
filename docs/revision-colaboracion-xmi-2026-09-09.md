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
