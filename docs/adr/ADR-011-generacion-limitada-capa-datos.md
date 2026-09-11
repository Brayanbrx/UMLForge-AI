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
