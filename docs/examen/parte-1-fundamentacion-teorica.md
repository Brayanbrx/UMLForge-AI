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
