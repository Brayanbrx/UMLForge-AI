# Importación de Inscripcion desde Enterprise Architect

La corrección se verificó con `PracticaProbar.xmi` suministrado por el usuario.
El archivo tiene dos elementos homónimos: una clase vacía aislada y una
`uml:AssociationClass` con fecha, estado, notaFinal e idInscripcion.
El parser anterior descartaba la clase asociativa y sus atributos.

Ahora la importación produce:

- `Estudiante (1) — (0..*) Inscripcion`.
- `Curso (1) — (0..*) Inscripcion`.
- `Inscripcion (1) ◆— (0..*) Calificacion`, conservando la composición de EA.

La relación Estudiante–Curso que sirve de base a la clase asociativa se sustituye
por los dos enlaces a la entidad intermedia. Los cuatro atributos mantienen sus
tipos Date, String, Decimal e Integer. La clase vacía homónima se omite con aviso
solo cuando carece de contenido y enlaces; las clases homónimas con contenido
se conservan con nombres diferenciados.

Los proxies de EA se resuelven usando `classifier`, sin crearlos como entidades.
También se admiten clases asociativas UML con participantes directos y extremos
guardados como atributos de otra clase. Si faltan participantes, se conservan
los atributos y se avisa; no se inventan relaciones. Se trata de una conversión
a entidades y asociaciones del modelo de la app, no de la reproducción de la
notación de clase asociativa unida mediante una línea discontinua.

Para la composición se consulta el extremo del diamante en la extensión EA.
Esto evita invertir Inscripcion y Calificacion por la ubicación de `aggregation`
en los `ownedEnd` de ese exportador.

## Validación

- 361 pruebas unitarias aprobadas, incluidas siete regresiones para este caso.
- Typecheck y lint aprobados.
- Prueba de navegador aprobada: carga del archivo, vista previa, aplicación,
  sincronización con un segundo colaborador y descarga XMI con los tres enlaces.
- API local reconstruida. No se modificaron las pizarras del usuario.

Para corregir una importación anterior, volver a seleccionar el archivo y usar
**Reemplazar**, revisando la vista previa y la confirmación de la aplicación.
Ese modo sustituye el contenido de la pizarra; si contiene cambios posteriores
que se quieren conservar, usar una pizarra nueva. El modo **Añadir** conserva
las relaciones existentes y, por tanto, puede conservar el enlace directo viejo.
