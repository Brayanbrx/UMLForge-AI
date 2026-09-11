# Colaboración e intercambio XMI: revisión del 10 de septiembre

Se completaron los controles de colaboración y la revisión del candidato XMI, y se corrigieron errores de permisos y de compatibilidad detectados durante pruebas con navegadores y Enterprise Architect 15.1 (build 1514). Este informe actualiza el estado de la [revisión anterior](revision-colaboracion-xmi-2026-09-09.md).

## Funcionalidades completadas

- Administración desde el proyecto: listar participantes, cambiar Editor/Lector, retirar miembros, salir del proyecto, listar y revocar invitaciones. Los cambios de permisos alcanzan las pizarras abiertas. Una invitación revocada deja de mostrarse como disponible.
- Candidato editable: nombres, tipos, clave primaria, obligatoriedad, unicidad, extremos de relaciones, roles, multiplicidades y clase de relación. Se pueden quitar operaciones; quitar una clase nueva también quita las operaciones que dependen de ella. El resumen y la validación se actualizan mientras se edita. Los errores de precondiciones impiden aplicar; los hallazgos del modelo se señalan para corregir antes de generar.
- Identidad XMI: el importador materializa comandos por UUID, sin resolver el archivo por nombres aproximados de IA. Añadir conserva elementos existentes, evita duplicados y avisa de definiciones diferentes. Reemplazar conserva las identidades válidas del archivo y exige revisar de nuevo si otro colaborador cambió el modelo.
- Disposición: exportar/importar conserva posiciones y tamaños de clases, tanto en el perfil UML propio como en el perfil EA. El archivo propio permite recuperar coordenadas negativas; si EA modifica o reexporta su diagrama, se interpreta su geometría nativa.
- Selector de exportación: **Enterprise Architect 15 — XMI 2.1** y **UML 2.5.1 — XMI 2.5.1**. La segunda opción completa la versión solicitada por el objetivo 11 del perfil del proyecto; la API acepta `format: "UML_251"` y conserva `EA_21` como valor predeterminado. Ambos archivos se importan por la misma revisión de candidato.
- Se mantienen las correcciones anteriores de concurrencia por campos, rechazo de XML mal formado, permisos del servidor, reconexión y persistencia en PostgreSQL.

## Errores adicionales corregidos

| Error reproducido | Corrección |
| --- | --- |
| Al retirar un participante, el servidor cerraba su sala pero la interfaz seguía permitiendo editar localmente. | Manejar el evento `close` de la sala de Hocuspocus; bloquear escritura por acceso revocado y renovar la sesión cuando corresponde a expiración. Si el participante permanece en la página del proyecto, la revisión periódica lo devuelve a sus proyectos cuando pierde acceso. |
| EA importaba clases y tipos, pero omitía completamente el diagrama. | Emitir primero la extensión nativa de EA. EA 15 ignoraba ese bloque cuando los metadatos propios aparecían antes. |
| EA invertía los extremos de asociaciones conservando las cardinalidades en las posiciones anteriores. | Emitir `memberEnd` en el orden destino/origen que utiliza EA y respetar la orientación nativa al leer, incluidas autorrelaciones. |
| EA descartaba las marcas propias de clave primaria y unicidad. | Guardarlas además como tagged values nativos identificados, `umlforge.primaryKey` y `umlforge.unique`, y leer esas marcas al importar. |
| Quitar operaciones desplazaba fuera del área visible un campo del candidato. | Integrar el control de eliminación dentro de la fila y volver a comprobar campos y acciones en el navegador. |

## Verificación real con Enterprise Architect

Se crearon proyectos EAP temporales independientes usando su API de automatización. Se importaron los ocho modelos del banco y un noveno modelo con todos los tipos y clases de relación. Se consultaron los elementos realmente almacenados por EA y se compararon con los modelos de entrada, sin modificar proyectos del usuario.

**Nueve modelos aprobados: 36 clases, 114 atributos, 32 relaciones y 36 cajas de diagrama.** Se comprobaron UUID, nombres, tipos, nulabilidad, claves y unicidad en tagged values, extremos, roles, cardinalidades, herencia, composición, agregación, autorrelaciones, posiciones y tamaños.

La evidencia y los ejecutores locales están en `reports/completar-colaboracion-xmi/`: `ea-validation.json`, `ea-fixtures.mjs`, `ea-roundtrip.ps1`, `verify-ea.mjs` y las consultas `T*-*.xml`. El directorio está ignorado por Git.

**Límite de esta aceptación:** la reexportación automatizada mediante `ExportPackageXMI` quedó sin responder, incluso en un proyecto mínimo creado por la propia API de EA. La inspección de su ventana tampoco fue posible: `window crop is outside captured monitor`. Por ello, se acredita la importación real y la conservación interna de datos en EA; no se presenta como aprobado el recorrido completo app → EA → reexportación EA → app. Los intercambios app → archivo → app y la lectura de muestras reales exportadas por EA sí se prueban automáticamente. La interfaz utilizada se documenta en la [referencia de automatización de Sparx](https://sparxsystems.com/enterprise_architect_user_guide/15.1/automation/project_2.html).

## Verificación de la aplicación

- **505/505 pruebas unitarias** aprobadas.
- **130/130 pruebas de integración** aprobadas durante la revisión; después de añadir XMI 2.5.1 se repitió específicamente su API ampliada: **21/21** aprobadas.
- TypeScript, ESLint, Prettier y compilación de producción aprobados.
- **89/89 pruebas de navegador** aprobadas en la ejecución completa con PostgreSQL temporal y una copia aislada de la compilación web. Después de añadir el selector XMI 2.5.1 se comprobaron **10/10 regresiones finales sobre Docker**, incluyendo permisos, concurrencia, ambos formatos, persistencia tras recargar y exportación desde una pantalla de 320 × 568. Evidencia: `reports/completar-colaboracion-xmi/e2e.xml` y `docker-xmi251.xml`.
- API, colaboración y web reconstruidos. Base y volúmenes conservados, sin migraciones. `/`, `/api/health` y `/collab/health` respondieron HTTP 200 en `http://localhost:8080`.

Las pruebas de integración y navegador utilizan PostgreSQL temporal y proveedores de IA simulados. Los casos nuevos están en `e2e/specs/colaboracion-xmi-completa.spec.ts`, `frontend/tests/candidate.test.ts`, `shared/xmi/tests/identity.test.ts` y `shared/xmi/tests/ea-export.test.ts`.

## Alcance y límites

### Última verificación después de los cambios visuales

Se repitió la verificación funcional el 10 de septiembre de 2026 sobre la versión actual. No se encontraron fallos nuevos ni fue necesario modificar código en esta comprobación.

| Comprobación repetida | Resultado |
| --- | --- |
| TypeScript del proyecto y pruebas | Aprobado |
| Pruebas unitarias | 505/505, 32 archivos |
| Integración de importación, proyectos y colaboración | 56/56: 21 de importación, 19 de proyectos y 16 de colaboración |
| Chromium contra la aplicación Docker en `localhost:8080` | 45/45, sin reintentos |
| Web, API y colaboración | HTTP 200; los cuatro contenedores estaban saludables |

Se comprobaron creación, movimiento, tamaño y eliminación de clases; atributos concurrentes; relaciones, herencia y multiplicidades; presencia; participantes que entran tarde; aislamiento entre pizarras; reconexión; persistencia; roles y revocación de acceso. La integración con cinco usuarios y 30 cambios obtuvo P95 de 32,9 ms en loopback, sin incluir el renderizado del navegador; no representa latencia entre equipos físicos.

Para XMI se repitieron la descarga e importación de los perfiles EA 2.1 y UML/XMI 2.5.1, conservación de UUID y disposición para ambos usuarios y tras recargar, archivos mayores de un MiB, archivos inválidos, prevención de duplicados, edición del candidato, sustitución protegida frente a cambios concurrentes y conversión de una clase asociativa de EA en entidad intermedia.

La evidencia de navegador está en `reports/verificacion-final-uml-xmi/navegador.xml` (directorio ignorado por Git). Las pruebas de integración utilizaron PostgreSQL temporal; las de navegador atravesaron el proxy, API, WebSocket y base del entorno Docker con cuentas y proyectos propios de prueba. Esta selección excluyó asistente de IA y cámara. Los resultados de Enterprise Architect descritos arriba corresponden a la revisión anterior: no se volvió a ejecutar EA ni se resolvió su bloqueo de reexportación externa en esta pasada.

### Límites que se mantienen

El intercambio soporta diagramas de clases XMI 2.1 y 2.5.1 dentro del vocabulario de la aplicación. No representa todos los elementos de UML: operaciones/métodos, estereotipos arbitrarios, todos los tipos de diagrama ni jerarquías completas de paquetes. Las clases asociativas compatibles se convierten en entidades intermedias. Las multiplicidades finitas como `2..5` se aproximan al vocabulario admitido y producen un aviso; no se conserva esa restricción exacta.

XMI 2.5.1 usa los espacios de nombres publicados por [OMG XMI 2.5.1](https://www.omg.org/spec/XMI/2.5.1) y [UML 2.5.1](https://www.omg.org/spec/UML/2.5.1). Se validaron el contenedor y sus metadatos contra el XSD oficial `XMI/20131001/XMI.xsd`, y la semántica y geometría mediante ocho recorridos completos archivo → comandos → estado del dominio/Yjs. Esta comprobación del XSD no se presenta como una certificación de todo UML. La aceptación real de Enterprise Architect corresponde a la opción específica XMI 2.1; para abrir allí el diagrama con su disposición se debe elegir ese perfil.

La colaboración permite reconectar y combinar cambios con la pestaña abierta. La persistencia offline a través de recargas, deshacer por usuario, versiones y restauración son ampliaciones diferentes que siguen en [pendientes](pendientes.md). Queda el ensayo entre equipos físicos en la red de la presentación. Pasar estas comprobaciones no permite garantizar ausencia absoluta de errores en cualquier archivo o entorno.
