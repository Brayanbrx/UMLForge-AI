# Contraste con los requisitos del docente

Fecha: 6 de septiembre de 2026. Entrega indicada: 23 de septiembre.
Fuente de alcance: notas compartidas por el usuario en esta conversación. Actualizado después de incorporar la base Flutter y el perfil móvil Spring. El estado vigente y la nueva comprobación de diferentes aplicaciones están en [revisión del generador CRUD](revision-generador-crud.md). No se hicieron pruebas del agente ni llamadas a proveedores IA en esta revisión.

## Interpretación del alcance

Hay dos productos distintos:

1. **Herramienta principal:** pizarra colaborativa para diseñar datos mediante clases UML, con edición gráfica, instrucciones por texto/voz, fotografía, interoperabilidad XMI y generación de un backend Spring Boot/PostgreSQL independiente.
2. **Aplicación de demostración:** cliente Flutter que se construye/adapta durante la presentación y consume ese backend. Su interfaz principal utiliza voz y un agente; debe seguir operando con IA local y datos locales sin conexión, y sincronizar al recuperarla.

Las notas no exigen que la herramienta genere Flutter automáticamente. Tampoco exigen IA local en la herramienta web: expresamente la ubican en la aplicación móvil. La alternativa «diagrama de clases o entidad relación» permite cubrir el modelado conceptual con UML; no se deduce que deban existir dos editores distintos.

El antiguo generador Dart de capa de datos fue sustituido por un generador opcional Flutter Android con login, contrato de backend, repositorio SQLite, cola y configuración GGUF. La compilación del APK y las pruebas de contrato/login están acreditadas; la demostración real del agente y voz offline sigue pendiente.

## Matriz de cumplimiento

| Requisito anotado | Estado observado | Qué falta para acreditarlo |
| --- | --- | --- |
| Diseño conceptual de datos con clases, atributos, tipos y relaciones | Implementado para el subconjunto UML admitido | Ensayar ejemplos de gestión acordados; explicar las restricciones del modelo generable. No se promete todo UML de Architect ni lógica de negocio que no figure en el modelo. |
| Pizarra colaborativa en tiempo real | Implementada con Yjs/WebSocket, presencia, permisos y persistencia | Demostración con varios equipos en la red prevista; verificar edición concurrente y conflictos sobre el mismo campo, además de cambios independientes. |
| Gestión de concurrencia/exclusión mutua | Hay convergencia CRDT y pruebas de concurrencia; no un bloqueo exclusivo por elemento | Explicar cómo se resuelven escrituras simultáneas. Si se exige literalmente impedir que dos personas editen el mismo elemento, falta ese bloqueo; las notas no bastan para asumir que sea obligatorio como mecanismo. |
| Edición gráfica | Implementada | Validación final del recorrido de clases, atributos, relaciones y cardinalidades en el equipo de presentación. |
| IA que aplica únicamente el cambio solicitado | Implementada mediante operaciones y escritura incremental del documento | Probar instrucciones reales y verificar elementos ajenos intactos. La proyección de React se recalcula; escribir cambios incrementales no demuestra por sí solo que únicamente un nodo se renderice. Medir si se exige esa condición de rendimiento. |
| Edición mediante texto o voz | Implementada con dictado revisable y propuesta antes de aplicar | Voz real y calidad del proveedor. El flujo actual requiere pulsar Parar, Enviar y Aplicar. Para cubrir literalmente «sin teclado ni mouse», faltan controles equivalentes por voz, conservando confirmación explícita. |
| Fotografía del pizarrón convertida en diagrama | Ruta visual y revisión del candidato implementadas | Ensayo con fotografía real: escritura manual, luz del aula, flechas, tipos, cardinalidades y clases intermedias. Las pruebas simuladas no acreditan reconocimiento correcto. |
| Importar y exportar XMI con Architect | Implementado y corregido con archivos aportados; incluye conversión de clases asociativas | Cerrar la prueba real de app → Architect → app después de la corrección del exportador. Verificar tipos, claves, extremos, cardinalidades y posiciones; no limitarse a contar clases. |
| Backend Spring Boot independiente con cuatro capas | Implementado: entidades, repositorios, servicios, controladores y DTO | Abrir el ZIP de un modelo nuevo en el IDE previsto y ejecutarlo sin cambiar código; configurar solamente conexión/puerto. Hay evidencia previa de ocho modelos compilados y ejecutados. |
| PostgreSQL y creación de esquema desde entidades | Implementado con JPA/Hibernate y configuración PostgreSQL | Mostrar tablas, claves y relaciones creadas sobre una base vacía durante el ensayo; comprobar persistencia tras reiniciar. |
| Material para probar el backend | Se genera colección Postman, OpenAPI/Swagger y documentación | Ejercitar altas, consultas, cambios y eliminaciones del modelo del ensayo. No falta crear un generador de Postman desde cero. |
| Frontend Flutter conectado al backend generado | Base generada; contrato/login probados y APK compilado | Ensayar aplicación física con un modelo nuevo y pantallas específicas desarrolladas en vivo. |
| Agente móvil con voz como interfaz principal | Motor GGUF, propuestas CRUD y dictado local integrados en código | Prueba física de calidad, ambigüedad, negaciones y confirmación. No se probó el agente por indicación del usuario. El flujo sigue usando controles táctiles de revisión. |
| IA local móvil sin internet | Carga de GGUF preparada; ningún modelo incluido | Elegir pesos compatibles, medir memoria y latencia, comprobar modo avión. La voz offline depende del reconocedor/idioma Android; no se garantiza escucha continua controlada por la app. |
| Operación móvil offline y sincronización posterior | SQLite, cola durable, recibos transaccionales y conflictos implementados | Ensayo completo en teléfono: cierre/reapertura, reconexión y varios dispositivos. La sincronización se ejecuta con la app abierta o al reabrir; sin servicio permanente en segundo plano ni migración automática de contratos. |

## El pendiente más grande: demostración móvil offline

El ZIP Spring independiente conserva CRUD simple. El paquete Android + backend añade `/mobile-sync`, IDs de operación estables, recibos persistentes, comparación de DTO original, bloqueo y versión JPA. Esto evita repetir operaciones confirmadas y detecta cambios incompatibles; no genera reglas de negocio ni un merge semántico. La descarga de colecciones es completa, sin sincronización incremental. Debe usarse el backend del paquete móvil para el cliente Flutter.

No es indispensable imponer un único diseño de sincronización. Sí debe demostrarse este comportamiento: registrar un servicio sin red mediante el agente, cerrar y abrir la app, conservar el registro, recuperar conexión, enviarlo una sola vez al backend y reflejar el resultado localmente. Si se admiten varios clientes offline, también debe definirse qué ocurre cuando modifican el mismo registro.

La colaboración Yjs del diseñador resuelve otro problema: sincroniza diagramas. No sincroniza automáticamente los datos de ventas, clientes o servicios del backend generado. Tener varios proveedores remotos de IA tampoco cubre la inferencia local sin internet.

## Orden de cierre recomendado

1. **Ensayar Flutter + agente local + almacenamiento/sincronización offline en Android físico.** La base ya existe; falta acreditar el recorrido real con modelo y voz, cuando el usuario autorice probar el agente.
2. **Cerrar Architect con un archivo realmente reimportado después de la corrección.** Mantener evidencia del resultado y del modelo completo.
3. **Realizar voz y fotografía con entradas reales.** Si se evalúa interacción totalmente por voz, añadir órdenes de control y confirmación sin retirar el modo de revisión manual elegido.
4. **Ensayar la secuencia completa:** varios participantes → modelo nuevo → ZIP → IDE → PostgreSQL → Postman → Flutter → operación offline → reconexión sin duplicados.
5. **Cerrar los controles de IA que afectan al costo y la corrección:** cancelación, límites por usuario, registro de intentos y detección de propuestas desactualizadas. Son mejoras de robustez; no sustituyen los entregables anteriores.

## Evidencia local consultada

- [Auditoría y banco de generación](auditoria-2026-09-05.md): evidencia histórica de colaboración y ocho proyectos Spring; las cifras pertenecen a aquella ejecución.
- [Revisión reciente de IA](revision-ia-2026-09-06.md): 442 pruebas unitarias/de regresión y cinco recorridos de voz/aclaraciones; reconocimiento y proveedores simulados.
- [Compatibilidad XMI](compatibilidad-xmi-2026-09-05.md) e [Inscripcion como intermedia](importacion-clase-asociativa.md).
- [Plantillas Spring](../templates/spring/README.md.hbs), [servicios](../templates/spring/service.java.hbs), [entidades](../templates/spring/entity.java.hbs) y [configuración PostgreSQL/JPA](../templates/spring/application.properties.hbs).
- [Generador y Postman](../shared/generator-backend/src/project-generator.ts), [aplicación incremental Yjs](../shared/yjs-adapter/src/apply.ts) y [flujo actual del asistente](../frontend/src/features/assistant/AssistantPanel.tsx).

Los pendientes generales de administración, restauración de versiones, despliegue público y otros refinamientos siguen en [pendientes](pendientes.md). No se presentan aquí como requisitos obligatorios adicionales del docente cuando no aparecen en las notas.
