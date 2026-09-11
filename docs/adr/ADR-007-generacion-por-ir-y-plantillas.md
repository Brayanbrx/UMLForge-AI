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
