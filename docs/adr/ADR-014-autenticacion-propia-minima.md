# ADR-014 · Autenticación propia mínima con roles por proyecto

**Estado:** aceptada
**Fecha:** 29 de agosto de 2026
**Fase:** 3

## Contexto

Sin identidad real, tres cosas no se sostienen: los roles no tienen dónde
apoyarse, la atribución de cambios en la presencia no es fiable, y las pizarras
son accesibles por quien adivine un identificador de sala.

## Decisión

Autenticación propia, con el alcance mínimo que hace posible lo anterior.

**Lo que se construye:** registro, inicio y cierre de sesión, renovación por
token de refresco, invitación por enlace con código, y tres roles por proyecto.

**Lo que no:** verificación por correo, recuperación de contraseña, inicio de
sesión con terceros, administración de organizaciones. Cada uno de esos
arrastraría un proveedor de correo o un tercero al camino crítico, a tres semanas
de la entrega.

## Contraseñas: scrypt, no Argon2id

RNF-08 pide una función de derivación moderna y lenta. Se usa **scrypt** de
`node:crypto`, con N=2¹⁶, r=8, p=1, sal de 16 bytes y clave de 64.

Argon2id sería la primera recomendación hoy. Se descarta por una razón concreta:
las implementaciones de Argon2 para Node son **módulos nativos**, y un módulo
nativo es la fuente número uno de «en mi máquina sí funciona» — distinta
arquitectura, distinta libc entre Alpine y Windows, cadena de compilación
ausente en el portátil de un compañero. scrypt viene en el runtime, se comporta
igual en los cinco sitios donde este código corre, y con esos parámetros es
memory-hard de verdad.

Es un intercambio consciente, no un descuido. El hash es autodescriptivo
(`scrypt$N$r$p$sal$clave`), así que subir los parámetros —o migrar a Argon2id
cuando deje de ser un riesgo de despliegue— no invalida las contraseñas
existentes: cada una se comprueba con los parámetros con los que se guardó.

## Tokens: acceso corto en cabecera, refresco rotativo en cookie

El **token de acceso** es un JWT de vida corta que viaja en `Authorization`. Es
un JWT y no una cookie de sesión por una razón específica: es el que se pasa al
abrir el WebSocket, y el servidor de colaboración tiene que poder autorizar la
conexión antes de entregar el documento (RA-15, fase 4).

El **token de refresco** es un secreto opaco de 384 bits, no un JWT. No necesita
transportar información —siempre se busca en la base, para poder revocarlo— y al
no ser verificable sin consultar, uno robado deja de servir en cuanto se rota.
Viaja en cookie `httpOnly`, así que el JavaScript de la página no lo ve.

Es **rotativo**: cada renovación revoca el anterior. Reutilizar uno ya rotado no
funciona, lo que convierte el robo de un refresco en una ventana estrecha en
lugar de un acceso permanente.

Se guarda el hash SHA-256 del token, nunca el token. SHA-256 basta aquí, a
diferencia de las contraseñas: hay 384 bits de entropía aleatoria, así que no hay
diccionario que probar y una derivación lenta solo añadiría latencia a cada
renovación.

## Dos decisiones de fuga de información

**Un no miembro recibe 404, no 403.** Responder «no tienes permiso» confirmaría
que el proyecto existe a quien solo está probando identificadores.

**El inicio de sesión comprueba la contraseña aunque el correo no exista**,
contra un hash ficticio, y devuelve el mismo mensaje en los dos casos. Sin eso,
el tiempo de respuesta y el texto del error convierten el formulario en un
comprobador de qué correos están registrados.

## Roles

| Rol | Puede |
|---|---|
| `OWNER` | Todo, más invitar, cambiar roles y eliminar el proyecto |
| `EDITOR` | Crear y editar pizarras, usar el asistente, generar código |
| `VIEWER` | Ver pizarras y consultar al asistente sin modificar |

El propietario no se puede degradar ni expulsar: dejaría el proyecto sin nadie
capaz de invitar, cambiar roles ni borrarlo. Transferir la propiedad es otra
operación y no entra en este alcance.

La autorización vive en un solo módulo, `modules/projects/membership.ts`. El
proceso de colaboración resolverá lo mismo en la fase 4 reutilizando esas reglas:
proteger las rutas HTTP sin autorizar la conexión WebSocket no sirve de nada.

## Invitaciones

Enlace con código aleatorio de 32 caracteres y rol asignado en el momento de
crearlo. No se verifica quién lo abre, así que lo único que lo protege es que no
sea adivinable — de ahí la longitud y la caducidad.

Aceptar dos veces la misma invitación **no es un error**: devuelve la membresía
que ya hay. Un enlace compartido se abre más de una vez, y fallar la segunda vez
solo confunde a quien no hizo nada mal.

## Consecuencias

- Toda la configuración sensible entra por entorno y `JWT_SECRET` **no tiene
  valor por defecto**: un secreto con valor por defecto acaba desplegado, y nadie
  se entera hasta que alguien firma sus propios tokens. El proceso se niega a
  arrancar sin él.
- Las pruebas de la API son de integración contra un PostgreSQL efímero. Probar
  autorización, membresías y cascadas contra una base de mentira no prueba nada:
  las restricciones de unicidad y las claves compuestas solo existen de verdad en
  PostgreSQL.
- `RF-A10` (revocar sesiones activas) queda en P2. La tabla de tokens ya lo
  admite; falta la ruta.
