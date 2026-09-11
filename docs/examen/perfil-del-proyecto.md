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
