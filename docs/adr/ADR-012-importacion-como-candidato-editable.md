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
