# Backend de gestión generado desde el diagrama

Actualización: 6 de septiembre de 2026.

La herramienta genera un proyecto Maven independiente con Spring Boot 4.1.1, Java 21 y PostgreSQL. El modelo de ventas de ejemplo contiene Cliente, Producto, Venta y Detalle de Venta. La generación es determinista y no necesita una llamada de IA.

## Capas y DTO

| Capa | Contenido |
| --- | --- |
| Modelo | Entidades JPA, claves, tipos, nulabilidad, unicidad, herencia y referencias. |
| Repositorio | JpaRepository y búsquedas por clave foránea. |
| Servicio | Transacciones, CRUD, resolución de referencias y transformación entidad/DTO. |
| Controlador | GET de lista y por ID, POST, PUT y DELETE. |
| DTO | Records planos, con atributos heredados y relaciones representadas por IDs del tipo correcto. |
| Excepciones/configuración | Errores JSON y CORS configurable para clientes web. |

Flutter consume los DTOs, no entidades JPA. El ZIP ahora incluye `docs/dto-contract.json` y `docs/flutter-api.md`, generados específicamente para las clases del diagrama: nombres de campos, tipos Java/JSON/Dart, claves, anulabilidad, restricciones, filtros y ejemplos. DateTime se transmite sin zona porque el tipo Java es LocalDateTime. Decimal es un número JSON; su precisión y escala se validan antes de persistir.

Las actualizaciones PUT representan el DTO completo; no son PATCH. La clave puede omitirse del cuerpo, pero si se incluye debe coincidir con la ruta. Los errores incorporan `fieldErrors` para asociar mensajes con controles del frontend. JSON o identificadores mal formados devuelven 400 con una explicación del contrato.

## Postman

Se corrigieron ejemplos que enviaban UUID incluso para claves foráneas Integer/Long/String, y las URL dejaron de contener componentes contradictorios. La colección incluye variables de IDs, captura de la clave devuelta por POST y pruebas HTTP/JSON.

El orden es: altas de entidades referenciadas → consultas y modificaciones → bajas en orden inverso. Las modificaciones cambian un atributo simple cuando está disponible. El entorno local usa `baseUrl=http://localhost:8081`.

La colección completa elimina sus registros de ejemplo. Ejecutarla en una base de prueba; para conservar datos de demostración, omitir las solicitudes Eliminar. Las relaciones opcionales empiezan en null; los ciclos obligatorios se advierten porque no hay un orden de altas automático sobre una base vacía.

## Ejecución

- **Docker:** el ZIP contiene Dockerfile, Compose, `.env.example`, `.dockerignore` y README. Copiar el ejemplo de entorno, configurar la contraseña y ejecutar `docker compose up -d --build`.
- **IDE/local:** abrir pom.xml, configurar DATABASE_URL, DB_USER, DB_PASSWORD y PORT en el entorno de ejecución, compilar con Maven y ejecutar la clase principal o el JAR. Compose carga `.env`; Java/Maven no lo carga por sí solo.
- **Puertos predeterminados:** API 8081 y PostgreSQL 5433, publicado solamente en localhost. El diseñador puede seguir en 8080.
- **Despliegue:** Compose en un servidor o Dockerfile con PostgreSQL externo y variables de entorno. Java se ejecuta sin usuario root. La documentación del ZIP explica salud, persistencia, emulador Android, teléfono físico y CORS.

Para generar otra copia del ejemplo desde el repositorio:

```powershell
npm run typecheck
npm run demo:backend
```

Se crea una carpeta nueva bajo `generated-output/demo-ventas-*` con el ZIP, el proyecto descomprimido y el diagrama XMI/JSON. También se puede importar ese XMI en una pizarra y usar la generación normal de la interfaz.

## Verificación

- 454 pruebas unitarias y de regresión aprobadas; 22 corresponden al generador y sus artefactos para clientes.
- TypeScript, ESLint y formato aprobados.
- 29 pruebas de integración de generación y descarga HTTP aprobadas, con PostgreSQL temporal.
- Ejemplo de ventas construido y desplegado con el Dockerfile/Compose exportados: API y PostgreSQL saludables, proceso Java sin root. Las 20 solicitudes de su colección y scripts pasaron contra ese despliegue.
- Compilación y ejecución real de ventas con claves UUID, modelo con herencia y ventas con claves Integer: PostgreSQL limpio, OpenAPI, colección Postman exportada, CRUD, reinicio, persistencia y restricciones de borrado.
- Se verificaron también errores por campos obligatorios, identificadores mal formados y discrepancia entre clave del cuerpo y URL. Las solicitudes y los scripts exportados se ejecutaron mediante un arnés compatible con las APIs de Postman utilizadas; no se automatizó su aplicación de escritorio.

## Alcance

### Ejemplo disponible en este equipo

Carpeta: `generated-output/demo-ventas-N3AkPY/backend`. API: `http://localhost:8081`; PostgreSQL de este ejemplo: `localhost:5434`. Se ajustó únicamente el `.env` de la copia generada porque el PostgreSQL del diseñador ya ocupa 5433. El `.env` de `infra` se conserva.

La base del ejemplo quedó vacía después del ensayo. Importar `postman/collection.json` y `postman/local.environment.json` de esa carpeta. Para detenerlo, ejecutar `docker compose stop` desde la misma carpeta; `docker compose start` lo reanuda. Su `.env` conserva el nombre del proyecto Compose aislado. Los archivos se pueden volver a generar mediante `npm run demo:backend`.

### Límites del generado

El generado cubre gestión CRUD y restricciones estructurales. No infiere descuentos de inventario, cálculos contables ni reglas de negocio no expresadas en el diagrama. No incluye autenticación, permisos de negocio ni sincronización offline. Antes de publicar datos reales hacen falta esos controles, HTTPS y una estrategia de migraciones/respaldo.

La lista GET todavía no está paginada. Los filtros actuales por clave foránea se usan individualmente; enviarlos juntos no implementa una búsqueda combinada. Las altas con clave existente devuelven el registro previo; no actualizan ni comparan el contenido de un reintento.

Referencias oficiales consultadas para la configuración externa y variables de prueba: [Spring Boot](https://docs.spring.io/spring-boot/reference/features/external-config.html) y [Postman](https://learning.postman.com/docs/tests-and-scripts/write-scripts/postman-sandbox-reference/pm-variables/).
