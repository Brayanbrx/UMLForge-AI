# Comparación con el manual de otro proyecto de la materia

Contraste punto por punto contra el *Manual de Usuario — 1er Parcial* de Parada
Burgos Klaus (mismo docente, misma materia). Sirve para dos cosas: detectar
funciones que damos por hechas y no lo están, y decidir a conciencia dónde
diferimos.

Revisado el 30 de agosto de 2026.

Este documento **compara**. Lo que de aquí sale y merece construirse está en
[`actualizacion.md`](actualizacion.md), con coste, sitio y forma de comprobarlo.

---

## Resumen

| # | Función del manual | Nosotros |
|---|---|---|
| 1 | Iniciar sesión | ✅ |
| 2 | Cerrar sesión | ✅ **añadido al editor hoy** |
| 3 | Entrar y crear pizarras | ✅ |
| 3b | Renombrar y eliminar pizarras | ✅ **añadido hoy** |
| 4 | Compartir con otros | ✅ (más fino: tres roles) |
| 4b | Bloquear la pizarra | ❌ **decisión, ver §2.1** |
| 5 | Vista de invitado | ✅ (más completa: presencia) |
| 6 | Asistente IA por texto y voz | ✅ |
| 7 | Crear clase manualmente | ✅ |
| 8 | Importar desde imagen | ✅ |
| 9 | Importar boceto a mano | ✅ (misma función) |
| 10 | Guardar/cargar en JSON | ⚠️ **usamos XMI, ver §2.2** |
| 11-12 | Pizarra bloqueada | ❌ ver §2.1 |
| 13 | Generar backend Spring Boot | ✅ |
| 13b | Generar app Flutter completa | ❌ **decisión, ver §2.3** |
| 14 | Ejecutar el backend generado | ✅ verificado sobre 7 modelos |
| 15 | Probar con Postman | ✅ la colección va en el ZIP |

---

## 1 · Lo que faltaba de verdad, y ya está

### 1.1 Renombrar y eliminar pizarras · eliminar proyectos

**RF-001 y RF-003 son P0 en nuestro propio plan.** Las rutas HTTP existían desde
la fase 3 y estaban probadas, pero **no había ningún botón que llegara a ellas**:
se podía crear una pizarra y no había forma de renombrarla ni de borrarla. Una
pizarra mal nombrada se quedaba así para siempre.

No lo detectó ninguna prueba porque las de integración llaman a la ruta
directamente, y las de navegador nunca intentaron hacerlo. Lo encontró este
manual.

Borrar pide **escribir el nombre**, no un «¿seguro?»: no hay papelera, un
proyecto se lleva sus pizarras por delante y para todos sus miembros, y un
diálogo de confirmación se acepta sin leerlo. Hay pruebas de que escribirlo mal y
de que cancelar no borran nada.

### 1.2 Cerrar sesión desde el editor

Estaba solo en la lista de proyectos. En el editor es donde se pasa el tiempo, y
tener que navegar hacia atrás para salir invita a dejar la sesión abierta en una
máquina compartida — que es exactamente la nota de su manual.

---

## 2 · Donde diferimos a propósito

### 2.1 Bloquear la pizarra

**Ellos:** el anfitrión pulsa «Bloquear» y nadie puede editar hasta que
desbloquee.

**Nosotros:** no existe, y no está en nuestro plan. Lo que tenemos es
**autorización por rol y por proyecto**: OWNER, EDITOR y VIEWER, resuelta tanto
en HTTP como en la conexión WebSocket (RA-15). Para que alguien no edite se le
invita como lector, y eso vale para siempre y por persona, no para todos a la vez
y hasta que alguien se acuerde de desbloquear.

**Lo que su enfoque resuelve y el nuestro no:** «paren todos un momento, quiero
explicar algo». Es una necesidad real dando una clase o una demostración.

**Coste si lo quisiéramos:** un `locked` en la pizarra, comprobado en el gancho
de autorización del proceso de colaboración, que ya rechaza escrituras de un
VIEWER — sería la misma comprobación con una condición más. Medio día con su
prueba de dos navegadores. **No lo haría antes del ensayo**: no está en los
requisitos, y el tiempo que queda rinde más en los tres riesgos P0 de
[`pendientes.md`](pendientes.md).

### 2.2 Guardar y cargar en JSON

**Ellos:** «Exportar JSON» descarga el diagrama, «Importar JSON» lo restaura. Es
una copia de seguridad local.

**Nosotros:** exportamos e importamos **XMI 2.1**, que es lo que pide RF-050 y lo
que abre Enterprise Architect. JSON no aparece en nuestro plan.

**Por qué conviene añadirlo igual:** es la red de seguridad de la demostración.
Si algo se rompe en vivo —la base, el contenedor, la red— un JSON en Descargas
recupera el diagrama en un clic. El XMI también, pero pasa por el parser y por la
resolución de nombres; el JSON canónico es el modelo tal cual y no puede perder
nada.

**Coste:** pequeño. El modelo canónico ya se serializa; es un botón que descarga
`state.semantic` y otro que lo aplica como lote. Está anotado en
[`pendientes.md`](pendientes.md).

### 2.3 Generar la aplicación Flutter completa

**Ellos:** el botón «Frontend» descarga un proyecto Flutter entero
(`flutter-mvp`).

**Nosotros:** generamos la **capa de datos** Dart —modelos, cliente HTTP tipado,
base local, repositorios y cola de sincronización— y no las pantallas. Es
[ADR-011](adr/ADR-011-generacion-limitada-capa-datos.md), y la razón está
escrita: el docente dijo que **no verá aplicaciones móviles generadas** y que el
frontend se construye en vivo durante la defensa. Generar pantallas cuesta tanto
como el generador de Spring Boot y sustituiría justo el ejercicio que él pidió.

**El riesgo de la decisión, dicho claro:** si el docente esperaba ver el botón
«Frontend» porque otro proyecto lo tiene, hay que poder explicar en treinta
segundos por qué el nuestro llega hasta la capa de datos y qué se construye
encima en vivo. La app móvil de la fase 9 —agente de voz, operación sin conexión,
cola— está construida **sobre** esa capa generada, y esa es la demostración.

---

## 3 · Donde estamos por delante

No para presumir: son cosas que conviene enseñar porque no están en su manual y
responden a requisitos del plan.

- **Proyectos con varias pizarras y tres roles.** Su modelo es anfitrión e
  invitado sobre una pizarra. El nuestro tiene proyectos, miembros, invitaciones
  con rol y varias pizarras por proyecto (RF-001 a RF-005, RF-A04 a RF-A08).
- **Presencia.** Se ve quién está conectado y qué elemento está editando cada uno
  (RF-026), no solo una etiqueta de anfitrión o invitado.
- **Validación con errores y avisos** (RF-017). El diagrama dice qué impide
  generar y qué solo es una advertencia, con la sugerencia al lado.
- **Congelado del snapshot al generar** (RA-08). Si alguien sigue editando
  mientras se arma el ZIP, el ZIP corresponde al modelo del momento en que se
  pulsó, y descargarlo de nuevo mañana da el mismo archivo.
- **Auditoría** de quién aplicó cada lote (RF-A09).
- **Interoperabilidad XMI con Enterprise Architect** en los dos sentidos.
- **La app móvil funciona en modo avión**, con reconocimiento de voz y
  clasificador de intenciones en el dispositivo, y cola de sincronización sin
  duplicados.
- **Banco de regresión de siete modelos** que compila, arranca y ejerce el CRUD
  del backend generado en cada cambio.

---

## 4 · Detalles menores del manual

| Función suya | Nosotros | Comentario |
|---|---|---|
| Indicador de zoom en % | Controles de React Flow (`+`, `−`, ajustar) | Sin el número. Cosmético. |
| «Limpiar pizarra» | No | Se borran las clases o se elimina la pizarra. Un botón que vacía todo de golpe da más sustos que servicio. |
| Botón «Muchos a Muchos» | No, y a propósito | Un N:M se marca como **error** con la sugerencia de crear la entidad intermedia ([ADR-005](adr/ADR-005-entidad-intermedia-muchos-a-muchos.md)): no se puede traducir a persistencia sin decidir qué datos lleva la relación. |
