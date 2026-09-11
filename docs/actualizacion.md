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
