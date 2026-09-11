# ADR-017 · Agente móvil local con resolución determinista de entidades

- **Estado:** Aceptada
- **Fase:** 9
- **Fecha:** 2026-08-30

## Contexto

La aplicación móvil tiene que aceptar órdenes por voz y funcionar sin conexión
(RFM-03, RFM-04, CA-03.1). Hay tres formas de hacerlo y las tres se consideraron:

1. **Enviar la frase a un modelo de lenguaje en la nube.** Es lo más capaz y lo
   único que no se puede hacer: en modo avión no hay nube, y el requisito
   central de la demostración es precisamente el modo avión.
2. **Ejecutar un modelo de lenguaje pequeño en el teléfono.** Añade cientos de
   megabytes al paquete y segundos de latencia por frase, para un problema de
   cinco intenciones. Queda registrado como P2, no como carencia.
3. **Un clasificador entrenado fuera del dispositivo.** Es lo que se hizo.

También había que decidir quién convierte «Carlos Pérez» en un identificador de
fila. Es la parte donde un modelo generativo hace daño de verdad: un
identificador inventado tiene la forma correcta y es indistinguible de uno real
hasta que algo se rompe, lejos y más tarde.

## Decisión

**El modelo interpreta; el código resuelve los datos.**

- **Clasificación de intención:** bolsa de palabras (unigramas y bigramas) más
  regresión logística multinomial, entrenada por `npm run intents:train` y
  exportada como JSON de 27 kB. El teléfono solo multiplica una matriz por un
  vector. Seis clases: las cinco acciones y una **clase de rechazo** entrenada
  con frases que la aplicación no sabe hacer.
- **Resolución de entidades:** determinista, contra la base local, en Dart. El
  modelo produce un nombre; buscarlo es trabajo del código. Si hay una
  coincidencia, actúa; si hay varias, **pregunta**; si no hay ninguna, lo dice.
  Nunca inventa un identificador (CA-07.1).
- **Confirmación antes de crear:** dar de alta un cliente es lo único
  irreversible que hace el agente, y es justo donde el clasificador se equivoca
  («crea el cliente X» contra «busca el cliente X»). Equivocarse hacia una
  consulta no cuesta nada; hacia una creación deja basura en el catálogo de
  todos. Por eso se confirma.

## Por qué la clase de rechazo, y no solo un umbral

La primera versión tenía cinco clases y un umbral de confianza: por debajo de
0.45, «no entendí». No funciona, y la prueba lo demostró. Un softmax reparte
**toda** la probabilidad entre las clases que conoce, así que «cuánto cuesta un
pasaje a Santa Cruz» se parece más a una intención que a las otras cuatro y sale
con confianza alta. Rechazar requiere ejemplos de lo que hay que rechazar.

El umbral se mantiene como segunda red, no como la única.

## Consecuencias

**Medible.** 96.3% de acierto sobre 27 frases que no se usaron para entrenar
(RNF-11 exige 90% sobre al menos 20). El único fallo es «crea el cliente Tomas
Ruiz» → consulta, que es exactamente la confusión que la confirmación protege.

**Explicable en un minuto**, que es el criterio real: es un modelo entrenado, no
`if (texto.contains('registra'))`, y no un modelo de lenguaje del que no se puede
decir por qué respondió lo que respondió.

**Frágil en un punto conocido:** la tokenización está escrita dos veces, en
TypeScript para entrenar y en Dart para ejecutar. Si divergen, nada falla —el
modelo simplemente ve términos que no están en su vocabulario y acierta menos,
en silencio. Por eso el entrenador escribe cómo tokeniza cada frase del corpus y
una prueba de Dart lo compara término a término.

**Lo que no cubre ninguna prueba automática:** que el reconocedor de voz del
teléfono transcriba bien en español **y sin conexión**. `onDevice: true` pide el
modelo local, pero si el motor instalado no lo tiene descargado, Android cae al
reconocimiento por red y la demostración en modo avión se queda muda. Se
comprueba en el teléfono real que se llevará al examen; el emulador no sirve.

Relacionado: [ADR-011](ADR-011-generacion-limitada-capa-datos.md),
[ADR-013](ADR-013-uuid-para-creacion-sin-conexion.md) y
[ADR-015](ADR-015-proveedores-ia-tras-puertos.md) (en el servidor los
proveedores van tras puertos; aquí no hay proveedor que abstraer).

## Retirada del 5 de septiembre de 2026

**Superada.** La herramienta ya no emite ningún artefacto para el cliente móvil:
la generación queda en el backend Spring Boot con PostgreSQL, más su colección
de Postman. `shared/generator-dart` y `templates/dart` se retiraron del
repositorio, con la aplicación de referencia que vivía en `mobile/`.

La aplicación que consuma el backend generado se construye entera aparte. Esta
decisión queda como registro de por qué en su momento se generó solo la capa de
datos y no las pantallas; el razonamiento sigue siendo válido si algún día se
retoma. Recuperable con `git checkout <commit> -- shared/generator-dart templates/dart`.
