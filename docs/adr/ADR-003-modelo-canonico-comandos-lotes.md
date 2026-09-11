# ADR-003 · Modelo canónico único con comandos y lotes atómicos

**Estado:** aceptada
**Fecha:** 29 de agosto de 2026
**Fase:** 1

## Contexto

Seis entradas distintas modifican el mismo diagrama: interfaz gráfica, texto,
voz, imagen, XMI y, en el futuro, cualquier otra. Cada una podría escribir
directamente sobre el estado.

## Decisión

Existe **un solo modelo canónico**, y toda entrada es un adaptador que produce
**lotes de comandos** de un vocabulario cerrado de once operaciones (ver la
enmienda del 31 de agosto: sigue siendo once). Ninguna
entrada escribe el estado directamente.

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

## Por qué el vocabulario es cerrado

El asistente de IA propone comandos. Si el vocabulario fuera abierto —o peor, si
el modelo pudiera emitir mutaciones arbitrarias— cada respuesta del proveedor
sería una superficie de ataque y una fuente de estados imposibles. Once
operaciones con carga tipada se validan por esquema antes de tocar nada.

Esto es RA-06, y es también lo que permite que el esquema JSON entregado al
modelo como formato de salida se derive de los mismos contratos que validan la
entrada, en lugar de mantenerse a mano en paralelo.

## Enmienda del 31 de agosto de 2026 · el tamaño de una tarjeta

Redimensionar una clase en el lienzo, como se hace en Enterprise Architect,
necesitaba un sitio donde guardar el tamaño. Había dos caminos y se eligió el
que **no** amplía el vocabulario: `MOVE_CLASS` lleva ahora un `size` opcional.

**Por qué ahí y no en un comando nuevo.** Redimensionar es colocar. Igual que la
posición, el tamaño es disposición pura: no entra en el modelo semántico, no
puede invalidarlo y no llega al snapshot que congela la generación —ese se
construye con `readSemanticModel`—, así que no puede cambiar una línea del código
generado ni del XMI. Un duodécimo comando para una variante de lo mismo habría
ampliado la superficie que el asistente puede proponer sin ninguna ganancia:
**el asistente no tiene por qué redimensionar cajas.**

**Por qué opcional.** Arrastrar emite `MOVE_CLASS` sin tamaño, y entonces el que
hubiera se conserva; si lo borrara, mover una tarjeta desharía el ancho que
alguien acaba de ajustar. Además, todos los lotes anteriores a este cambio
siguen validando contra el esquema nuevo.

**Dónde se impone el mínimo.** En el contrato, no en el aplicador. `applyBatch`
recibe comandos ya tipados y no revalida: quien filtra es el esquema, en el borde
por donde entra un lote. Lo descubrió una prueba que esperaba lo contrario.

El tamaño manual gana al alto calculado por número de atributos. Si no, añadir un
atributo desharía el ajuste.

## Por qué el lote es la unidad transaccional

CA-032.2 lo exige: ante "crea Cliente con nombre, teléfono y correo", si un
comando es inválido no se aplica ninguno. El usuario dictó una intención, no tres
operaciones independientes; dejarla a medias produce un modelo que él no pidió.

La implementación es una función pura sobre el estado: recibe uno y devuelve
otro, sin mutar el que recibe. Un lote rechazado no deja rastro por construcción,
no por disciplina al escribir cada rama.

## La consecuencia que no era obvia

La validación del lote **no puede** limitarse a "¿el modelo resultante es
válido?". Dos usuarios pueden crear concurrentemente nombres que colapsan al
mismo identificador (CA-025.1): el documento converge en un modelo inválido, y el
validador debe marcarlo. Pero si un lote se rechazara por cualquier error presente
en el resultado, esa pizarra quedaría congelada — incluido el lote que arreglaría
la colisión.

Por eso el aplicador compara los hallazgos **antes** y **después**, y solo
rechaza los que el lote introduce. Cada hallazgo tiene una identidad estable
(código más elementos implicados) que hace posible esa comparación.

RA-12 dice que la colaboración garantiza convergencia estructural, no validez
semántica. Esta es la pieza que hace esa frase vivible.

## Consecuencias

- Los comandos se registran para auditoría, **no** para sincronizar (CA-023.1).
  Lo que viaja en tiempo real es la actualización del documento, no el comando.
- El validador es el mismo que decide si se puede generar. Una sola definición de
  "modelo válido".
- Añadir una entrada nueva —otro formato de importación, otro proveedor— no toca
  el núcleo: se escribe un adaptador que produzca comandos.

## Alternativas descartadas

**Cada entrada escribe el estado.** Seis implementaciones peleándose por ser la
verdad, y seis sitios donde arreglar cada regla de validación.

**Event sourcing.** Ver ADR-006. El comando aquí es una instrucción, no un evento
persistido del que se reconstruya el estado.
