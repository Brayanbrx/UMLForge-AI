# Estrategia de Flutter offline y agente adaptable

Revisión del código actual: 6 de septiembre de 2026. No se probó inferencia, dictado ni un modelo local. La evidencia de ejecución anterior se conserva en [revisión del generador CRUD](revision-generador-crud.md).

## Offline: qué está implementado

El primer login requiere backend disponible para autenticar y descargar `/mobile-contract`. La sesión y el contrato se guardan; SQLite conserva registros y cola, separados por servidor, cuenta y contrato. Al reabrir sin red se restaura esa sesión y se leen datos locales.

Formularios y operaciones confirmadas del agente usan el mismo repositorio. Crear, editar o eliminar registra el cambio y actualiza la vista local en una transacción SQLite antes del envío. No se guardan instrucciones ambiguas para que una IA remota las interprete después: la cola contiene operaciones CRUD ya validadas y confirmadas.

La sincronización se intenta al abrir, al regresar al primer plano, tras guardar, por botón manual y cada 30 segundos con la app abierta. Se verifica el contrato antes de enviar. El backend guarda recibos por ID de operación para que perder una respuesta no provoque otra escritura. Se procesan cambios en orden y se descargan colecciones completas conservando los pendientes locales.

Límites comprobados en código:

- No hay un servicio Android que mantenga la sincronización con la app cerrada ni un listener dedicado que dispare exactamente al recuperar internet. El temporizador y la reapertura hacen los reintentos.
- Tener internet no basta: el backend también debe ser accesible. En otro Wi-Fi no suele funcionar la dirección LAN de un equipo; usar una URL HTTPS pública para ese escenario.
- El acceso remoto vence a los 15 minutos. Si pasó más tiempo, hace falta volver a iniciar sesión con la misma cuenta; el funcionamiento y los pendientes locales se conservan. No existe refresh token automático.
- Un conflicto definitivo detiene la cola hasta resolverlo. No hay merge automático de reglas del negocio. Si el contrato cambia de forma incompatible, se bloquea el envío para no mezclar datos.
- Antes del primer envío se consolidan ediciones locales. Después de un intento, la operación queda inmutable hasta confirmar o resolver el conflicto, porque podría estar aplicada en el servidor.
- Las relaciones usan IDs; hay que crear los registros referenciados antes de los dependientes. No se genera un planificador general de transacciones entre entidades.
- Durante la comprobación/sincronización se deshabilitan escrituras en la UI. Un timeout de red puede mantener ese bloqueo temporal; separar comprobación de conectividad y edición local es una mejora pendiente de experiencia offline.

## Configuración básica

1. Generar **Android + backend** desde el diagrama.
2. Configurar el backend una sola vez, por `.env` o variables del hosting. Para desarrollo, `dart run tool/start_backend.dart 8082 5435` desde `mobile/` prepara `.env` si falta y ejecuta Compose. Si existe, respeta sus valores y puertos.
3. Abrir Flutter, introducir la URL de la API e iniciar sesión con conexión. Esperar la primera descarga de datos antes de desconectar. El modo offline y su cola ya vienen activados; no hay que programarlos por entidad.
4. Para el agente local, cargar previamente un GGUF compatible y elegir su plantilla de conversación. Para un Gemma compatible usar `gemma`. Tras reabrir, pulsar Abrir guardado. Sin pesos cargados siguen funcionando los formularios; el agente no puede interpretar instrucciones.

El motor actual es local tanto online como offline. No existe una selección automática de IA remota cuando hay internet y local cuando se pierde. Tampoco se descarga automáticamente un modelo. El formato GGUF y la opción de plantilla no garantizan que cualquier versión de Gemma u otra arquitectura esté soportada por el motor.

## Estrategia para aplicaciones diferentes

| Capa | Responsabilidad | Estado actual |
| --- | --- | --- |
| Núcleo común | Login, sesión, SQLite, cola, recibos, conflictos, revisión, operaciones CRUD | Implementado |
| Contrato de datos por aplicación | Recursos, campos, claves, tipos, anulabilidad y relaciones | Generado desde el diagrama, descargado en login y conservado offline |
| Reglas comunes del agente | Una operación JSON, no inventar registros, preguntar ante ambigüedad, conservar campos en UPDATE, confirmar antes de guardar | Implementado como texto fijo en `LocalAgent` |
| Contexto variable por solicitud | Recurso seleccionado, campos/restricciones, registros filtrados e instrucción | Implementado: se construye desde el contrato actual, sin plantilla especial para ventas o barbería |
| Perfil semántico de negocio | Sinónimos, descripción del negocio, significado de estados y ejemplos propios | No hay archivo/perfil configurable consumido por la app; aún requiere modificar código si se necesita |
| Casos de uso de negocio | Cobrar, cerrar venta, transferir saldo, reservar cupo, validar disponibilidad | Deben implementarse como lógica de servicio y operaciones explícitas; no están inferidos del diagrama ni habilitados como herramientas del agente |
| Pantallas específicas | Agenda, caja, inventario, reportes | Punto de extensión `custom_pages.dart` implementado; widgets concretos se desarrollan según la app |

El prompt no necesita reescribirse para un CRUD nuevo: sus nombres y restricciones llegan por contrato. Sí necesita información semántica adicional para entender expresiones que no correspondan directamente a esos campos. Hoy el agente opera sobre una colección seleccionada, con CREATE/UPDATE/DELETE/LIST; no navega libremente por todo el backend, no ejecuta varias entidades como una transacción y LIST devuelve la lista local filtrada, no un lenguaje de consultas o agregaciones general.

## Separación propuesta para completar la flexibilidad semántica

Mantener las reglas comunes independientes del motor GGUF. Añadir en el futuro un perfil versionado por backend con descripción breve, alias de recursos/campos, significado de valores y ejemplos de intención. Ese perfil debe validarse, guardarse offline junto al contrato y limitar su tamaño. No debe alterar las reglas de confirmación, declarar permisos ni permitir URLs o SQL arbitrarios.

Ejemplo de adaptación: en una barbería, «agendar atención» puede corresponder a crear una Cita si el usuario aporta los datos obligatorios. Comprobar que no se solape con otra cita requiere una regla de negocio. En ventas, «cobrar» puede modificar Venta, Detalle, Pago e inventario; hacerlo correctamente requiere un servicio transaccional del backend y una política explícita para su versión offline. No basta con añadir «cobra correctamente» al system prompt.

Para casos de uso complejos, definir una operación de dominio versionada (por ejemplo, `registrarVenta`) con entrada validada, permisos, reglas, idempotencia y estrategia de conflicto. Solo después puede exponerse al agente y, si admite ejecución offline, incorporarse a una cola compatible. Mientras esa herramienta no exista, el agente debe pedir aclaración o limitarse a los CRUD disponibles.

## Resultado de la revisión

La flexibilidad estructural de CRUD y el almacenamiento/cola offline están implementados. El prompt recibe el contrato de cada aplicación y no depende de clases concretas de ventas. La personalización semántica sin tocar código y las operaciones de negocio compuestas siguen pendientes. No se acredita todavía que un modelo específico interprete bien las órdenes o que la voz funcione en modo avión; estas pruebas siguen excluidas por indicación del usuario.

Referencias de implementación: `templates/flutter/lib/ui/app_model.dart.tpl`, `data/repository.dart.tpl`, `data/api.dart.tpl`, `data/local_agent.dart.tpl`, `domain/proposal.dart.tpl`, `ui/custom_pages.dart.tpl` y `templates/mobile-backend/MobileSecurity.java.tpl`.
