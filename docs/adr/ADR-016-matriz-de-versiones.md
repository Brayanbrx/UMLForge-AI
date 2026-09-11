# ADR-016 · Matriz de versiones congelada

**Estado:** aceptada
**Fecha de verificación:** 29 de agosto de 2026
**Fase:** 0

## Contexto

RT-05 y la sección 19 del plan maestro exigen verificar cada versión el primer
día, comprobar la compatibilidad entre las piezas que dependen entre sí y
clavarlas en los archivos de bloqueo. Un número copiado de un documento escrito
semanas antes es una suposición, no una decisión.

## Decisión

Las versiones de esta tabla **no se copiaron de ningún documento**: se instalaron
y se leyeron del `package-lock.json` resultante. La fecha de verificación es la
de esa instalación.

### Herramientas del entorno

| Pieza | Versión verificada | Nota |
|---|---|---|
| Node.js | 22.15.0 | Fijada en `.nvmrc` y en las tres imágenes de contenedor |
| npm | 11.6.0 | Gestor del monorepo, ver más abajo |
| Docker | 29.6.1 | |
| Docker Compose | v5.1.4 | |
| Java | 21.0.9 LTS | Para compilar el backend generado (fase 2) |
| Maven | 3.9.9 | |
| Flutter | 3.44.2 (canal estable) | Aplicación móvil (fase 9) |

### Dependencias del monorepo

| Paquete | Versión resuelta |
|---|---|
| typescript | 5.9.3 |
| vitest | 3.2.7 |
| eslint | 10.9.1 |
| typescript-eslint | 8.68.0 |
| prettier | 3.9.6 |
| prisma | 7.10.0 |
| fastify | 5.12.1 |
| @fastify/cors | 10.1.0 |
| @fastify/cookie | 11.1.2 |
| zod | 3.25.76 |
| react / react-dom | 19.2.8 |
| vite | 6.4.3 |
| @vitejs/plugin-react | 4.7.0 |
| yjs | 13.6.32 |
| @hocuspocus/server | 4.6.0 |
| @hocuspocus/provider | 4.6.0 |
| y-protocols | 1.0.7 |
| jose | 6.2.10 |
| @prisma/client | 7.10.0 |
| @prisma/adapter-pg | 7.10.0 |
| @xyflow/react | 12.11.5 |
| zustand | 5.0.15 |
| react-router | 7.18.3 |
| @playwright/test | 1.62.1 |
| pg | 8.23.0 |
| handlebars | 4.7.9 |
| archiver | 8.0.0 |
| @anthropic-ai/sdk | 0.122.0 |
| tsx | 4.23.12 |

### Backend generado

| Pieza | Versión verificada |
|---|---|
| Spring Boot | 4.1.1 |
| springdoc-openapi | 3.1.0 |
| Java | 21.0.9 LTS |
| Maven | 3.9.9 |
| PostgreSQL | 17-alpine |

### Capa de datos Dart generada

| Pieza | Versión verificada |
|---|---|
| Dart SDK | 3.12.2 (stable) |
| `http` | ^1.2.0 |
| `sqflite` | ^2.3.0 |
| `lints` | ^5.0.0 |

Se verifican con `npm run test:dart`: la capa se genera para los siete modelos
generables del banco y cada una pasa `dart analyze --fatal-infos`.

Estas versiones se verifican con `npm run test:generated`: T01 se genera,
compila, arranca contra PostgreSQL y ejecuta su prueba HTTP completa.

### Imágenes de contenedor

| Servicio | Imagen |
|---|---|
| db | `postgres:17-alpine` |
| api / collab / web (construcción) | `node:22.15.0-alpine` |
| web (ejecución) | `nginx:1.27-alpine` |
| proxy | `caddy:2-alpine` |
| adminer | `adminer:5` |

## Tres decisiones que la verificación obligó a tomar

### npm workspaces en lugar de pnpm

La especificación de apoyo dejaba el gestor abierto («workspaces del gestor de
paquetes elegido»). `pnpm` no está instalado en las máquinas del equipo; npm 11
trae workspaces suficientes para ocho paquetes compartidos y tres aplicaciones,
y elimina un paso de arranque para cada integrante a tres semanas de la entrega.

Reversible sin coste: la estructura de carpetas y los `package.json` no cambian.

### Prisma 7.10.0, no la etiqueta `latest`

En npm, `latest` apunta hoy a `8.0.0-rc.12`, un **release candidate**. La última
versión de disponibilidad general es 7.10.0, publicada bajo la etiqueta `prev`.
Se fija 7.10.0 exacta, sin rango. Adoptar un RC a tres semanas de la defensa es
exactamente el riesgo que RT-05 pretende evitar.

Consecuencia práctica: Prisma 7 sacó la URL de conexión del archivo de esquema.
Vive en `prisma.config.ts` y se lee de `DATABASE_URL`.

### ESLint 10, no 9

`eslint@9` está en soporte de mantenimiento y npm avisa de ello en cada
instalación. `typescript-eslint@8.68.0` declara compatibilidad con `^10.0.0`, así
que se adopta la rama actual.

## Aviso de seguridad conocido y aceptado

`npm audit` reporta tres avisos de severidad alta, todos con el mismo origen:
`deepmerge-ts < 8.0.0`, alcanzado a través de `@prisma/config` desde el CLI de
Prisma. Es agotamiento de pila al fusionar grafos de objetos recursivos.

Se acepta porque el fallo está en el CLI de Prisma y solo procesa el archivo de
configuración y las migraciones del propio repositorio, que no son entrada no
confiable. El CLI es dependencia de desarrollo y queda en el target de un solo
uso con el que `migrate` ejecuta `prisma migrate deploy`; las imágenes finales de
HTTP y WebSocket solo copian el cliente generado. Prisma es además un peer
opcional de `@prisma/client`, por lo que esas imágenes omiten dependencias de
desarrollo y opcionales; `npm audit --omit=dev --omit=optional` queda sin
hallazgos. `npm audit fix --force` degradaría a `prisma@6`, un cambio mayor e
incompatible.

Revisado de nuevo tras las fases 3 y 7: Prisma 7.10.0 todavía resuelve la versión
afectada y npm sigue ofreciendo únicamente la degradación forzada a la rama 6.

## Regla permanente

Cualquier cambio de versión se hace instalando y actualizando esta tabla con la
nueva fecha de verificación. No se editan números a mano.
