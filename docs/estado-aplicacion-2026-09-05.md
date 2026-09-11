# Estado de la aplicación — 5 de septiembre de 2026

Actualización del 6 de septiembre: [dictado, ahorro y validación](voz-y-consumo-ia.md),
con [arquitectura de hasta siete respaldos por capacidad](proveedores-ia.md).

Esta es la revisión anterior. La continuación, con contenedores reconstruidos,
pruebas táctiles y pendientes consolidados, está en la
[auditoría final](auditoria-2026-09-05.md).

Actualización de interoperabilidad: la prueba real de EA detectó pérdida de los
44 tipos y de la geometría. Se corrigió la cabecera del exportador; la aceptación
externa sigue pendiente. Ver [comparación XMI](compatibilidad-xmi-2026-09-05.md).

La plataforma web y el generador Spring Boot funcionan en los recorridos
verificados. Se corrigieron tres defectos funcionales y una prueba incorrecta.
La revisión no acredita todavía una entrega cerrada: faltan la interoperabilidad
con Enterprise Architect real, la validación de dispositivos y proveedores reales,
el ensayo de demostración y la resolución de avisos de seguridad de dependencias.

## Alcance de esta revisión

Se revisó el código actual del monorepo, conservando los numerosos cambios previos
sin hacer commit ni revertirlos. Se ejecutaron comprobaciones estáticas, pruebas
de dominio, API, PostgreSQL, WebSocket y navegador, y el banco completo de
backends generados. Se inspeccionaron también la configuración de desarrollo,
las dependencias y las capturas de la prueba de carga.

El alcance ejecutable actual incluye cuentas, perfiles, recuperación de contraseña,
proyectos, permisos, pizarras colaborativas, editor UML, asistente, importación por
imagen/XMI, exportación XMI, auditoría y generación Spring Boot. El módulo móvil y
el generador Dart fueron retirados antes de esta revisión; sus menciones antiguas
no deben interpretarse como funciones disponibles.

## Correcciones realizadas

| Problema | Efecto anterior | Corrección y evidencia |
|---|---|---|
| Proxy de desarrollo | `/api/health` y `/collab/health` daban 404; las rutas de sesión tampoco llegaban correctamente al servidor. | Vite elimina los prefijos `/api` y `/collab`, igual que el proxy de contenedores. Ambas sondas responden 200 y la suite de navegador pasa a través de Vite. |
| Respuestas tardías tras cambiar de cuenta | Un 401 de una petición iniciada por Ana podía reenviarse con la sesión de Beto. Una respuesta exitosa anterior también podía introducir datos obsoletos en la interfaz. | Cada operación conserva la revisión de sesión que la inició y la comprueba antes de reintentar y después de recibir su cuerpo. Se aplica a JSON, exportación XMI y ZIP. Cuatro regresiones fallaban antes y pasan después. |
| Recuperación con una sesión abierta | Tras restablecer la contraseña, «Ir a entrar» llevaba a `/proyectos`, porque React conservaba el usuario anterior. | Se cierra la sesión del cliente al completar la recuperación. La prueba de navegador reproduce el fallo anterior y verifica acceso y recarga posteriores. |
| Prueba RNF-03 | Enfocaba una clase sin seleccionarla y esperaba que las flechas la movieran; producía un falso fallo de colaboración. | La prueba selecciona con Enter antes de mover. Verifica importación, 30 nodos, 40 relaciones y propagación del movimiento. |

Archivos funcionales modificados en esta revisión:

- `frontend/vite.config.ts`.
- `frontend/src/lib/api.ts`.
- `frontend/src/features/auth/ResetPage.tsx`.
- Regresiones en `frontend/tests/api.test.ts`, `e2e/specs/carga.spec.ts` y
  `e2e/specs/sesion.spec.ts`.

También se enlazó este informe desde README y se corrigieron referencias de
alcance y resultados obsoletos en la documentación de requisitos y pendientes.

## Resultados de verificación

| Comprobación | Resultado |
|---|---|
| Formato, ESLint y TypeScript | Correctos después de los cambios de código. |
| `npm test` | **352 pruebas pasan**; la muestra real de Enterprise Architect se procesa con avisos explícitos para construcciones no soportadas. |
| `npm run test:api` | **126 pruebas pasan** en 7 archivos, con PostgreSQL efímero. |
| `npm run build` | Todos los paquetes y la interfaz compilan correctamente. |
| Playwright, interfaz actual | **62 pruebas pasan**, 0 omitidas, 0 fallidas y 0 inestables; duración aproximada de 189 segundos. |
| Contenedor web local actualizado, puerto 8080 | **11 pruebas adicionales pasan**: cuenta, recuperación y generación/descarga de ZIP. Web, API y colaboración responden 200; los cuatro servicios están saludables. |
| `npm run test:bank` | **8 modelos completos**: T01, T02, T03, T04, T05, T06, T07R y T08. |
| API y colaboración por el proxy de desarrollo | Ambas sondas HTTP responden **200**, frente al **404** reproducido antes. |
| `npm audit` | **4 paquetes afectados con severidad alta**, 0 críticos; pendiente de resolver. |

El banco generado comprobó compilación Maven/Java 21, arranque con PostgreSQL
limpio, OpenAPI, altas, consultas, modificaciones, idempotencia, persistencia tras
reiniciar y rechazo 409 al borrar un padre con hijos. T07R es el modelo reparado
generable; el caso no generable T07 no se presenta como un backend compilado.

La primera pasada de navegador contra el entorno de auditoría en el puerto 18080
dio 59 aprobadas y 2 fallos: la selección incorrecta de RNF-03 y un contenedor web
antiguo que todavía mostraba «Foto del pizarrón». La pasada final usa el código
actual en Vite 6.4.3, puerto 15173, con API y colaboración del entorno aislado.
Las pruebas de integración sí ejecutan el código actual de los servidores.

Se reconstruyó y actualizó únicamente `plataforma-uml-web-1` para publicar las
correcciones en la aplicación local de `http://localhost:8080`. Los datos y los
otros servicios se conservaron. El entorno secundario de auditoría no se
reconstruyó; su interfaz antigua se identifica arriba para evitar confundirla
con el resultado final. El servidor Vite temporal se apagó al terminar.

El caso nuevo de recuperación de sesión simula solamente la respuesta exitosa de
restablecimiento. El consumo real y exclusivo del enlace, la contraseña nueva y
la revocación de refrescos se verifican en la suite de integración. No se enviaron
correos a personas ni solicitudes a proveedores reales de IA.

Evidencia local conservada en `reports/revision-2026-09-05/`:

- `e2e-output.log`: salida y resultado JSON de los 62 recorridos.
- `npm-audit.json`: detalle de los avisos de dependencias.
- `sesion-antes/`: captura y traza del fallo de recuperación reproducido.
- `regresiones/` y `e2e/`: capturas del editor con 30 clases.

## Capacidad observada

| Requisito | Medición de esta ejecución | Límite de la evidencia |
|---|---|---|
| RNF-01 / RNF-02 | Cinco clientes WebSocket, 30 cambios, P95 **34,5 ms**. | Loopback en esta máquina; no representa la red del aula. |
| RNF-03 | 30 clases, 100 atributos, 40 relaciones: importar y visualizar en el segundo navegador tomó **242 ms**; propagar un movimiento, **102 ms**. | Un escenario local en Chromium; no es una medición de FPS ni de latencia P95 del navegador. |
| RNF-04 | Diez salas del mismo proyecto mantienen estados separados. | Prueba de integración, no diez interfaces abiertas durante horas. |
| Generación y determinismo | Pruebas de carga y comparación de bytes pasan; ocho backends ejecutados. | No mide producción multiusuario ni disponibilidad prolongada. |

## Faltantes y riesgos priorizados

### Antes de la demostración

1. **Enterprise Architect 15 real.** El parser ya procesa el XMI de esa instalación;
   falta abrir en EA un archivo exportado por la plataforma y conservar la captura.
2. **Ensayo completo y puertos.** Ejecutar el guion cronometrado en el equipo y
   red previstos. Mantener la plataforma en 8080 y asignar otro puerto, por
   ejemplo 8081, al backend generado para evitar el conflicto de valores por defecto.
3. **IA, voz, imagen y correo reales.** Validar las claves y modelos configurados,
   una fotografía del pizarrón, el micrófono y los permisos del navegador. El
   adaptador de correo `log` no entrega mensajes a una bandeja de entrada;
   comprobar el proveedor de correo si la recuperación se va a demostrar por email.
4. **Versiones desplegadas coherentes.** Reconstruir los servicios modificados
   antes del ensayo. Un contenedor saludable puede servir código antiguo, como
   ocurrió en el entorno aislado de auditoría durante esta revisión.

### Robustecimiento pendiente

- **Dependencias de Prisma.** `npm audit` marca `prisma`, `@prisma/config`,
  `deepmerge-ts` y `mysql2`. Son cuatro paquetes afectados, no cuatro defectos
  independientes. La cadena instalada incluye `deepmerge-ts@7.1.5` y
  `mysql2@3.15.3`. Los avisos incluyen recursión sin límite al fusionar objetos,
  degradación de autenticación MySQL y descompresión sin límite. La aplicación
  usa PostgreSQL; la exposición de cada ruta vulnerable requiere evaluación
  específica. El arreglo automático propone retroceder Prisma 7.10.0 a 6.19.3,
  un cambio mayor incompatible con la configuración actual, por lo que no se
  ejecutó `npm audit fix --force`. Hace falta una actualización compatible o
  una sustitución transitoria validada de esas dependencias.
- **Revocación inmediata de tokens de acceso.** Cambiar o recuperar la contraseña
  revoca los tokens de refresco, pero los JWT de acceso emitidos siguen siendo
  válidos hasta su vencimiento, por defecto hasta 15 minutos. La autorización
  HTTP verifica firma y caducidad, sin consultar una sesión revocable. Si se
  promete cerrar todas las sesiones de inmediato, falta añadir esa comprobación
  también a HTTP y WebSocket. La corrección de interfaz de esta revisión no
  modifica ese diseño del servidor.
- **Protección frente a intentos repetidos.** No se encontró límite de intentos
  en login, registro o recuperación ni una regla equivalente en el Nginx del
  repositorio. Añadirlo antes de exponer la plataforma públicamente.
- **Registro estructurado RNF-14.** El middleware enlaza `actorId`; las rutas de
  auditoría y generación aún no incorporan todos los identificadores de proyecto,
  pizarra, lote, comando, generación y origen requeridos para diagnóstico.
- **CA-068.2.** La plantilla expone conexión a base y puerto, pero sigue faltando
  una aserción explícita que impida introducir otras variables configurables.
- **Persistencia y recuperación operativa.** Definir copias y restauración de la
  base, retención de snapshots y tokens, y observación de fallos de servicios.
- **Vista previa de importación.** Completar edición de roles, eliminación de
  operaciones y validación reactiva del candidato antes de aplicar.

### Mejoras que no bloquean el núcleo actual

- Copia y restauración local JSON.
- Consulta o exportación de una cola de auditoría rechazada permanentemente:
  los lotes se conservan, pero requieren una salida visible para su recuperación.
- Actualización automática del historial de generaciones de otros colaboradores.
- Pruebas prolongadas en la red del aula y en navegadores y dispositivos adicionales.
- Revisión completa de documentación histórica que aún describe móvil/Dart.

**Valoración:** núcleo web y generación verificados, con las correcciones de esta
revisión probadas. La preparación para una demostración es avanzada; la
interoperabilidad externa, los dispositivos reales y el robustecimiento de
seguridad siguen abiertos. No se asigna un porcentaje de avance porque esos
pendientes no tienen un peso comparable a una prueba unitaria aprobada.
