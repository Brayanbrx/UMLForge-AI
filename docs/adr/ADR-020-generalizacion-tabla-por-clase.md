# ADR-020 · La generalización se genera como tabla por clase unida por la clave

- **Estado:** Aceptada
- **Fase:** posterior a la 10
- **Fecha:** 2026-09-03

## Contexto

La versión 2.0 del plan maestro excluía la herencia: aparecía en la lista de
fuera de alcance y `INHERITANCE_PRESENT` figuraba entre los errores de CA-017.1.

La realidad del repositorio era otra. El editor ya ofrecía las cuatro relaciones
UML —asociación, generalización, composición y agregación—, cada una con su
notación: el triángulo hueco de la generalización se dibujaba en el lienzo, el
inspector explicaba que «el origen es la subclase y el destino la superclase», y
el serializador XMI la emitía como `<generalization>` para Enterprise Architect.
`INHERITANCE_PRESENT` estaba declarado y **nadie lo emitía**.

Lo que faltaba era lo de después. Una generalización se proyectaba como una
clave foránea más: `Estudiante` recibía un campo `persona` y una columna
`persona_id`, exactamente igual que si alguien hubiera dibujado una asociación
1:1. El diagrama decía una cosa y el proyecto Spring Boot decía otra.

Eso es peor que no soportarla. Un usuario que dibuja el triángulo, genera y abre
el ZIP encuentra código que no corresponde a su modelo, y nada se lo advierte:
compila, arranca y guarda filas.

## Decisión

**La generalización se proyecta a tabla por clase unida por la clave primaria**
(`InheritanceType.JOINED`), y deja de producir clave foránea.

```java
@Entity @Table(name = "persona")
@Inheritance(strategy = InheritanceType.JOINED)
public class Persona { @Id private UUID id; private String nombre; }

@Entity @Table(name = "estudiante")
@PrimaryKeyJoinColumn(name = "id")
public class Estudiante extends Persona { private String matricula; }
```

De las tres estrategias de JPA es la única que conserva **lo que el modelo
conceptual dice**: cada clase tiene sus columnas en su propia tabla, sin columnas
nulas para las que no le corresponden —tabla única con discriminador— y sin
repetir las de la superclase en cada hija —tabla por clase concreta—. Es también
la que se parece a lo que alguien dibujaría a mano normalizando.

Cuatro decisiones se derivan de ahí, y las cuatro están en RTM-13:

| Decisión | Por qué |
|---|---|
| La clave primaria sale de la **raíz** de la jerarquía | Es la columna por la que se unen todas las tablas de la cadena. Con dos niveles daría igual; con tres, no |
| La subclase no vuelve a declarar nada heredado | Un segundo `@Id`, o un campo repetido, compila y rompe el arranque de Hibernate |
| El DTO y el servicio sí trabajan con la entidad completa | Crear un estudiante por su propia ruta tiene que poder mandar el nombre, que vive en `persona` |

**Y el validador gana cuatro errores**, que son los que la proyección no puede
absorber: una clase que se generaliza a sí misma, dos superclases —Java tiene
una—, un ciclo, y un miembro declarado que tapa a otro heredado. Los cuatro
bloquean la generación porque los cuatro producen código que compila y falla
después. `INHERITANCE_PRESENT` se retiró: ya no describe nada.

## Consecuencias

**A favor.** El triángulo del lienzo significa lo mismo que el `extends` del
ZIP. El asistente por texto y voz puede crear una jerarquía —«Estudiante hereda
de Persona»—, la importación por fotografía puede leer un triángulo, y el XMI
sigue redondeando contra Enterprise Architect como antes.

**En contra.** Una consulta a una subclase es una unión, y la colección de una
superclase devuelve también las filas de sus hijas: `GET /api/persona` con un
estudiante dado de alta devuelve dos registros. Es semántica correcta de JPA
—una subclase **es** una superclase— pero sorprende la primera vez, y obligó a
enseñársela a la propia Definition of Done, que contaba una fila donde la
jerarquía produce cuatro.

**Cómo se comprueba.** T08 entró al banco de regresión: tres niveles de cadena,
dos hermanas, una clave foránea heredada y otra que apunta a una subclase. Pasa
la DoD completa de la sección 15.1: compila con Maven, arranca contra PostgreSQL
limpio, altas en orden topológico, reinicio y `409` al borrar un padre con hijos.

**Efecto sobre las generaciones anteriores.** `entity.java.hbs` cambió, así que
la huella de plantillas cambió con él. Una generación registrada antes de esta
decisión ya no se puede reproducir byte a byte, y al descargarla se responde
`409` diciendo por qué, en lugar de entregar un archivo distinto bajo el mismo
identificador. Es exactamente el caso para el que
[ADR-018](ADR-018-artefactos-no-se-almacenan.md) puso esa comprobación: quien la
necesite vuelve a generar desde la pizarra.

**Lo que sigue fuera.** Herencia múltiple, clases abstractas, interfaces y
métodos. Y las otras dos estrategias de JPA: elegirlas por modelo sería una
decisión de persistencia dentro del modelo conceptual, que es justo lo que
[ADR-003](ADR-003-modelo-canonico-comandos-lotes.md) mantiene fuera.

Relacionado: [ADR-007](ADR-007-generacion-por-ir-y-plantillas.md) (la
representación intermedia es donde viven las decisiones de persistencia),
[ADR-008](ADR-008-dto-planos-relaciones-unidireccionales.md) (por qué el DTO es
plano) y
[ADR-005](ADR-005-entidad-intermedia-muchos-a-muchos.md) (la otra construcción
UML que el generador no proyecta tal cual).
