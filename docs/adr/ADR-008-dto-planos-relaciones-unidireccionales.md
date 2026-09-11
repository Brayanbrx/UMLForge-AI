# ADR-008 · DTO planos y relaciones unidireccionales

**Estado:** aceptada
**Fecha:** 29 de agosto de 2026
**Fase:** 2

## Contexto

`Cliente` tiene muchas `Venta`. JPA permite mapear los dos lados: `@ManyToOne` en
`Venta` y `@OneToMany(mappedBy = "cliente")` en `Cliente`. Y el CRUD podría
devolver la entidad con su cliente anidado.

Las dos cosas parecen convenientes y las dos rompen.

## Decisión

**RTM-05: solo se genera el lado propietario.** Sin colección inversa, sin
`mappedBy`, sin `cascade`, sin `orphanRemoval`, sin `fetch` explícito.

**RTM-09: un registro plano por entidad, para entrada y salida. Las relaciones se
expresan como identificador, nunca como objeto anidado.**

```java
public record VentaDTO(UUID id, LocalDateTime fecha, BigDecimal total, UUID clienteId) {}
```

## Por qué unidireccional

Con el lado inverso desaparecen los ciclos de propiedad, las colecciones
perezosas y la pregunta de quién es el dueño de la relación. **La clave foránea
en la base de datos queda exactamente igual de correcta**: `venta.cliente_id`
existe con o sin `@OneToMany` en `Cliente`.

Lo que se pierde es `cliente.getVentas()`. Se compensa, y hay que compensarlo
explícitamente porque sin ello la app móvil no podría hacer nada útil.

## La compensación

Por cada clave foránea el generador emite un finder con navegación explícita de
propiedad, expuesto como parámetro de consulta:

```java
List<Venta> findByCliente_Id(UUID clienteId);
```
```
GET /api/venta?clienteId={uuid}
```

Sin esto no habría forma de consultar las ventas de un cliente, que es
exactamente lo que la app móvil necesita. El controlador acepta el parámetro
como opcional: sin él devuelve la colección completa.

## Por qué DTO planos

**Elimina por construcción el ciclo de serialización.** `Venta` → `Cliente` →
lista de ventas → `Venta` es un desbordamiento de pila en el primer `GET`, y es
el fallo más común de este tipo de proyecto.

**No se usan anotaciones de referencia gestionada.** `@JsonManagedReference` y
`@JsonIgnore` ocultan el ciclo, pero también ocultan el dato: la app móvil
recibiría ventas sin cliente y no sabría a quién pertenecen. El identificador
plano da el dato completo sin el ciclo.

**Separa la entidad del contrato HTTP.** La entidad puede cambiar de mapeo sin
cambiar la respuesta.

## Se implementa desde el primer generador

El docente lo planteó como opcional. Se hace igual, y desde el principio:
introducirlo después obliga a reescribir todos los controladores, todos los
servicios y todas las pruebas del banco. Es la clase de decisión que solo es
barata al principio.

## Consecuencia sobre la clave primaria

Con DTO planos, el identificador viaja en el cuerpo de la petición. Eso obliga a
RTM-11: la clave primaria UUID se declara **sin generación automática**. Si
llevara `@GeneratedValue`, el identificador enviado por el cliente se ignoraría o
dispararía una actualización en lugar de un alta.

El servicio asigna un UUID solo si la petición no trae uno, y un `POST` sobre un
identificador existente devuelve el recurso existente en lugar de duplicar o
fallar. Eso hace idempotentes las creaciones sin infraestructura adicional: un
reintento tras un tiempo de espera agotado devuelve el mismo registro, que es
justo lo que la cola de sincronización del móvil necesita (CA-10.1).

## Alternativas descartadas

**Bidireccional con `mappedBy`.** Añade la pregunta del lado propietario a cada
relación, y las colecciones perezosas provocan `LazyInitializationException`
fuera de la transacción — otro fallo clásico en demostración.

**Devolver entidades directamente.** Ciclo de serialización garantizado y
acoplamiento del contrato HTTP al mapeo de persistencia.

**Anidar el objeto relacionado en el DTO.** Vuelve el ciclo por otra puerta y
obliga a decidir hasta qué profundidad se anida.
