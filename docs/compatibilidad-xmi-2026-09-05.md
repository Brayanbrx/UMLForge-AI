# Comparación real de XMI y corrección de la cabecera

**Actualización del 10 de septiembre:** se corrigieron además orden de extensiones, extremos y marcas nativas; nueve modelos aprobaron la importación real en EA. Véase [evidencia y límite de la reexportación](colaboracion-xmi-2026-09-10.md). Este documento conserva el diagnóstico anterior.

El usuario confirmó este recorrido: app web → `ExportadoNuevo.xmi` → Import
Package from XMI en Enterprise Architect → `exportadodeimportado.xmi`.
La importación anterior falló: los tipos estaban escritos en el archivo, pero EA
no los incorporó. No era únicamente una opción de visualización.

## Resultado observado

| Dato | Archivo de la app | Archivo devuelto por EA |
|---|---|---|
| Clases | 11 | 11 |
| Atributos de datos | 44 | 44 |
| Atributos con tipo explícito | 44 | 0 |
| Tipos | 14 Integer, 21 String, 6 Date, 3 Decimal | Ninguno |
| Relaciones | 13, incluida autorrelación de Materia | 13 |
| Atributos con `isID` | 8 | 0 |
| Paquete y diagrama | Ejemplo | Package1 |
| Geometría de clases | 11 cajas con posiciones propias | Las 11 con Left=10, Top=10, Right=100, Bottom=80 |
| Identificadores de clases | UUID de la app | UUID nuevos |

Los 44 avisos del parser al leer el segundo archivo son relevantes: su fallback
`String` no significa que EA haya conservado 44 tipos String. En el XML faltan
tanto las referencias UML a los tipos como `properties.type` en la extensión.
Contar relaciones tampoco acredita todos sus detalles; EA invirtió los extremos
de asociaciones no dirigidas y escribió `1..1` donde la app escribió `1`.

## Corrección aplicada

La cabecera del perfil EA seguía diciendo `exporter="Plataforma UML"`, aunque
el documento ya tenía identificadores EAID/EAPK, tipos primitivos y diagrama
en la extensión nativa. Ahora se emite:

```xml
<xmi:Documentation exporter="Enterprise Architect" exporterVersion="6.5"/>
```

Esta combinación corresponde a la muestra nativa y a la recomendación del
[equipo de Sparx sobre el importador y los identificadores](https://sparxsystems.com/forums/smf/index.php?topic=39006.0).
El [caso de tipos y orden de atributos](https://sparxsystems.com/forums/smf/index.php?topic=41984.0)
también documenta la diferencia de comportamiento según la cabecera y el uso de
`containment.position` al importar el formato EA. La pérdida conjunta de tipos,
identidad y geometría es consistente con el uso del importador genérico.

`6.5` es la versión del formato exportado, no la versión instalada del programa.
Un comentario XML identifica a Plataforma UML como productor real. El
serializador UML genérico conserva su cabecera anterior; la API de descarga
utiliza el perfil EA corregido.

Se creó `generated-output/ExportadoCorregidoEA.xmi` a partir del archivo del
usuario. Solo cambia la cabecera y se añade el comentario de procedencia.
Una comparación estructural verificó que modelo, identificadores, extensiones
y geometría son idénticos al archivo original. Los originales de Downloads no
se modificaron. Las copias de evidencia están en `shared/xmi/tests/fixtures/`.

## Verificación y pendiente de aceptación

- 57 pruebas de XMI aprobadas, incluidas las dos muestras nuevas y la comprobación
  de la cabecera nativa, el orden de atributos y los avisos por tipos ausentes.
- 18 pruebas de integración de importación/exportación aprobadas.
- Typecheck y lint aprobados.
- API local reconstruida y saludable; las nuevas descargas usan el perfil corregido.

**Pendiente:** importar `ExportadoCorregidoEA.xmi` en un proyecto de prueba de EA,
abrir su diagrama y comprobar tipos, posiciones, relaciones y marcas de identidad.
Exportar ese paquete de nuevo permite verificar el resultado sin depender de la
captura. La corrección de la cabecera está probada en código, pero todavía no se
ha recibido el resultado de esta nueva importación en EA. Tampoco se acredita
la recuperación de `isID` ni de otras marcas de la app hasta esa comprobación.
