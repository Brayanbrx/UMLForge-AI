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
