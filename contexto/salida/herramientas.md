# Utilidades y pruebas de extremo a extremo

`scripts/` son las utilidades que se invocan desde npm: preparar el entorno, sembrar la demostracion, generar un backend de ejemplo y verificar produccion. `e2e/` son las pruebas de Playwright que recorren la aplicacion real: colaboracion simultanea, importacion, generacion, cuenta y accesibilidad.

> Generado el 2026-09-21 00:42 por `contexto/todo.py`.
> 39 archivos, 6,239 lineas, 250.8 KiB de codigo.
> Pruebas: incluidas. Dependencias, compilados y binarios: siempre excluidos.

## Contenido

- [Utilidades](#utilidades) --- 9 archivos
- [Pruebas de extremo a extremo](#pruebas-de-extremo-a-extremo) --- 30 archivos

---

## Utilidades

`seed-demo.ts` crea las cuentas de prueba, `generate-demo-backend.ts` produce el ZIP de ejemplo y los `verify-*` comprueban despliegues.

### Estructura

```text
scripts/
|-- bootstrap-ubuntu.sh
|-- generate-demo-backend.ts
|-- production.sh
|-- seed-demo.ts
|-- verify-ai-prompts.ts
|-- verify-management-apps.ts
|-- verify-mobile-backend.ts
|-- verify-production-client.mjs
`-- verify-production.mjs
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `scripts/bootstrap-ubuntu.sh` | 23 |
| `scripts/generate-demo-backend.ts` | 37 |
| `scripts/production.sh` | 158 |
| `scripts/seed-demo.ts` | 219 |
| `scripts/verify-ai-prompts.ts` | 220 |
| `scripts/verify-management-apps.ts` | 194 |
| `scripts/verify-mobile-backend.ts` | 245 |
| `scripts/verify-production-client.mjs` | 247 |
| `scripts/verify-production.mjs` | 154 |

---

### `scripts/bootstrap-ubuntu.sh`

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
test "$(id -u)" = 0 || { echo 'Ejecuta con sudo' >&2; exit 1; }
. /etc/os-release
test "$ID" = ubuntu || { echo 'Este instalador es para Ubuntu; usa la guía Docker de tu distribución.' >&2; exit 1; }
apt-get update
apt-get install -y ca-certificates curl git openssl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME:-$VERSION_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker
docker compose version
```

---

### `scripts/generate-demo-backend.ts`

```ts
import { mkdir, mkdtemp, writeFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fixture } from '@uml/fixtures';
import { buildGenerationIr } from '@uml/generation-ir';
import { generateSpringProject, generateMobileProject } from '@uml/generator-backend';
import { serializeToEnterpriseArchitect } from '@uml/xmi';

const model = fixture('T01').model;
const generated = await (
  process.argv.includes('--mobile') ? generateMobileProject : generateSpringProject
)(
  buildGenerationIr({
    projectName: 'Sistema de Ventas',
    snapshotVersion: 1,
    model,
  }),
);
const output = resolve('generated-output');
await mkdir(output, { recursive: true });
const root = await mkdtemp(resolve(output, 'demo-ventas-'));
const projectRoot = process.argv.includes('--mobile') ? root : resolve(root, 'backend');
for (const file of generated.files) {
  const target = resolve(projectRoot, file.path);
  await mkdir(dirname(target), { recursive: true });
  await writeFile(target, file.content, 'utf8');
}
await writeFile(resolve(root, generated.artifactName), generated.zip);
await writeFile(resolve(root, 'modelo.json'), JSON.stringify(model, null, 2), 'utf8');
await writeFile(
  resolve(root, 'modelo.xmi'),
  serializeToEnterpriseArchitect(model, { modelName: 'Sistema de Ventas' }),
  'utf8',
);
process.stdout.write(
  `Backend: ${resolve(root, 'backend')}\nZIP: ${resolve(root, generated.artifactName)}\nDiagrama: ${resolve(root, 'modelo.xmi')}\n`,
);
```

---

### `scripts/production.sh`

```bash
#!/usr/bin/env bash
# Linux host entry point. Does not source dotenv files as executable shell code.
set -Eeuo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"
ENV_FILE=${UML_ENV_FILE:-/etc/uml/production.env}
PROJECT=${UML_PROJECT:-plataforma-uml-production}
STATE_DIR=${UML_STATE_DIR:-${HOME}/.local/state/uml-deploy}
[[ "$PROJECT" =~ ^[a-z0-9][a-z0-9_-]*$ ]] || { echo 'UML_PROJECT inválido' >&2; exit 2; }
test -f "$ENV_FILE" || { echo "Falta configuración: $ENV_FILE" >&2; exit 2; }
export APP_VERSION=${APP_VERSION:-$(git rev-parse --short=12 HEAD)}
[[ "$APP_VERSION" =~ ^[a-zA-Z0-9][a-zA-Z0-9_.-]*$ ]] || exit 2
compose() {
  docker compose --project-name "$PROJECT" --env-file "$ENV_FILE" \
    -f infra/compose.yml -f infra/compose.production.yml "$@"
}
schema_hash() { find backend/prisma/migrations -name migration.sql -type f -print0 | sort -z | xargs -0 sha256sum | sha256sum | cut -d' ' -f1; }
check() {
  compose config --quiet
  compose run --rm --no-deps api node --input-type=module -e '
    import {loadConfig} from "./backend/api/dist/config.js";
    const c = loadConfig();
    if (decodeURIComponent(new URL(c.DATABASE_URL).password).length < 32) throw Error("POSTGRES_PASSWORD requiere 32 caracteres aleatorios o mas");
    console.log("Configuracion de API validada");'
  compose run --rm --no-deps proxy caddy validate --config /etc/caddy/Caddyfile
  compose run --rm --no-deps --entrypoint sh backup -ec '
    case "$BACKUP_S3_URI" in
      local-only) echo "AVISO: las copias se quedan en la VM (BACKUP_S3_URI=local-only). Configura un bucket S3 compatible antes de admitir datos importantes." >&2 ;;
      s3://*/*) ;;
      *) echo "BACKUP_S3_URI debe ser s3://bucket/prefijo o local-only" >&2; exit 1;;
    esac
    case "$BACKUP_S3_URI" in *YOUR_PRIVATE_BUCKET*) echo "Sustituye el bucket de ejemplo" >&2; exit 1;; esac'
}
smoke() {
  compose exec -T api node --input-type=module -e '
    for (const path of ["/", "/api/health", "/api/ready", "/collab/health"]) {
      const r = await fetch(process.env.WEB_ORIGIN + path, {signal:AbortSignal.timeout(15000)});
      if (!r.ok) throw Error(path + " -> " + r.status);
      console.log(path + " OK");
    }'
}
notify_failure() {
  echo 'La monitorización de UML detectó un fallo. Revisa journalctl -u uml-monitor.service' >&2
  if [ -n "${ALERT_WEBHOOK_URL:-}" ]; then
    curl --fail --silent --show-error --max-time 15 \
      -H 'Content-Type: application/json' \
      --data '{"text":"UML: fallo de disponibilidad, copia de seguridad o espacio en disco. Revisar servidor."}' \
      "$ALERT_WEBHOOK_URL" || true
  fi
}

case "${1:-help}" in
  build) compose config --quiet; compose build --pull api collab web migrate backup ;;
  check) check ;;
  deploy)
    if [ -n "$(git status --porcelain)" ]; then
      echo 'Confirma y sube los cambios antes de desplegar; la versión debe ser reproducible.' >&2; exit 1
    fi
    mkdir -p "$STATE_DIR"
    exec 9>"$STATE_DIR/deploy.lock"
    flock -n 9 || { echo 'Hay otro despliegue en curso' >&2; exit 1; }
    compose config --quiet
    compose build --pull api collab web migrate backup
    check
    compose up -d --wait --wait-timeout 120 db
    # A remote copy must succeed before any migration is applied.
    compose run --rm --no-deps backup once
    compose run --rm --no-deps migrate
    compose up -d --wait --wait-timeout 300
    smoke
    schema_hash > "$STATE_DIR/$APP_VERSION.schema"
    if [ -f "$STATE_DIR/current" ]; then cp "$STATE_DIR/current" "$STATE_DIR/previous"; fi
    printf '%s\n' "$APP_VERSION" > "$STATE_DIR/current"
    echo "Desplegado: $APP_VERSION. Ejecuta restore-check para comprobar recuperación."
    ;;
  rollback)
    test -n "${2:-}" || { echo 'Uso: production.sh rollback VERSION' >&2; exit 2; }
    export APP_VERSION=$2
    [[ "$APP_VERSION" =~ ^[a-zA-Z0-9][a-zA-Z0-9_.-]*$ ]] || exit 2
    test -f "$STATE_DIR/$APP_VERSION.schema"
    if [ "$(cat "$STATE_DIR/$APP_VERSION.schema")" != "$(schema_hash)" ]; then
      echo 'Las migraciones cambiaron: rollback automático rechazado. Usa el procedimiento de restauración.' >&2; exit 1
    fi
    for service in api collab web; do docker image inspect "uml-$service:$APP_VERSION" >/dev/null; done
    compose up -d --no-deps --no-build --wait api collab web
    smoke
    printf '%s\n' "$APP_VERSION" > "$STATE_DIR/current"
    ;;
  backup) compose run --rm --no-deps backup once ;;
  restore-check)
    db_id=$(compose ps -q db)
    test -n "$db_id"
    network=$(docker inspect "$db_id" --format '{{range $name, $value := .NetworkSettings.Networks}}{{$name}}{{end}}')
    restore_name="$PROJECT-restore-$(date +%s)-$$"
    restore_password=$(openssl rand -hex 24)
    trap 'docker rm -f -v "$restore_name" >/dev/null 2>&1 || true' EXIT
    docker run --detach --name "$restore_name" --network "$network" \
      --memory 512m --label uml.restore-check=true \
      -e POSTGRES_USER=restore_check -e POSTGRES_DB=restore_check \
      -e "POSTGRES_PASSWORD=$restore_password" postgres:17-alpine >/dev/null
    ready=false
    for attempt in $(seq 1 60); do
      if docker exec "$restore_name" pg_isready -U restore_check -d restore_check >/dev/null 2>&1; then ready=true; break; fi
      sleep 2
    done
    "$ready" || { echo 'PostgreSQL temporal no está listo' >&2; exit 1; }
    compose run --rm --no-deps --entrypoint sh \
      -e "RESTORE_HOST=$restore_name" -e "RESTORE_PASSWORD=$restore_password" backup -ec '
      file=$(ls -t /backups/uml-*.dump | head -n 1)
      test -n "$file"
      export PGHOST="$RESTORE_HOST" PGUSER=restore_check PGPASSWORD="$RESTORE_PASSWORD" PGDATABASE=restore_check
      pg_restore --exit-on-error --no-owner --no-acl --dbname "$PGDATABASE" "$file"
      count=$(psql -Atc "SELECT count(*) FROM information_schema.tables WHERE table_schema = '\''public'\''")
      test "$count" -gt 0
      echo "Restauración aislada correcta: $count tablas"'
    ;;
  smoke) smoke ;;
  monitor)
    trap notify_failure ERR
    smoke
    compose exec -T backup sh /opt/backup.sh health
    used=$(df -P "$ROOT" | awk 'NR==2 {gsub(/%/, "", $5); print $5}')
    test "$used" -lt 85 || { echo "Disco ocupado: $used%" >&2; exit 1; }
    ;;
  ps) compose ps ;;
  logs) compose logs --tail 100 "${2:-api}" ;;
  disk)
    # Que ocupa espacio en la VM. Los ZIP generados no aparecen: no se guardan,
    # se regeneran desde la version congelada que vive en PostgreSQL.
    echo '== Disco de la VM =='; df -h "$ROOT" | tail -n 1
    echo; echo '== Docker (imagenes, cache de construccion, volumenes) =='; docker system df
    echo; echo '== Imagenes de la plataforma por version =='
    docker images --filter 'reference=uml-*' --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}'
    echo; echo '== Base de datos =='
    compose exec -T db sh -ec 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Atc "
      SELECT '"'"'base completa: '"'"' || pg_size_pretty(pg_database_size(current_database()))
      UNION ALL SELECT '"'"'versiones congeladas de pizarras (generaciones): '"'"' || pg_size_pretty(pg_total_relation_size('"'"'board_snapshots'"'"'))
      UNION ALL SELECT '"'"'generaciones registradas: '"'"' || count(*) FROM generations
      UNION ALL SELECT '"'"'documentos colaborativos: '"'"' || pg_size_pretty(pg_total_relation_size('"'"'board_documents'"'"'))
      UNION ALL SELECT '"'"'auditoria: '"'"' || pg_size_pretty(pg_total_relation_size('"'"'audit_operations'"'"'))"'
    echo; echo '== Copias locales =='
    compose exec -T backup sh -c 'ls -lh /backups/uml-*.dump 2>/dev/null || echo "sin copias locales"'
    ;;
  prune)
    # Borra imagenes de versiones que ya no sirven para rollback (se conservan
    # la actual y la anterior), imagenes colgantes y cache de construccion.
    # Nunca toca volumenes: ni la base, ni las copias, ni los certificados.
    current=$(cat "$STATE_DIR/current" 2>/dev/null || echo "$APP_VERSION")
    previous=$(cat "$STATE_DIR/previous" 2>/dev/null || echo "$current")
    docker images --filter 'reference=uml-*' --format '{{.Repository}}:{{.Tag}}' \
      | grep -v -e ":$current\$" -e ":$previous\$" | xargs -r docker image rm
    docker image prune --force
    docker builder prune --force --keep-storage 2g
    echo "Conservadas las versiones $current y $previous."
    ;;
  *) echo 'Uso: bash scripts/production.sh build|check|deploy|smoke|backup|restore-check|monitor|ps|logs [servicio]|disk|prune|rollback VERSION' ;;
esac
```

---

### `scripts/seed-demo.ts`

```ts
/**
 * Siembra una cuenta y un proyecto de demostracion contra el entorno levantado.
 *
 * La seccion 16.3 lo pide para el dia 22: "cuentas de prueba creadas y proyecto
 * de demostracion listo". Tambien sirve para probar la plataforma sin tener que
 * registrarse a mano cada vez.
 *
 *   npm run up
 *   npm run seed
 *
 * Es idempotente: si la cuenta ya existe, inicia sesion en lugar de fallar.
 */

import { execFile } from 'node:child_process';
import { promisify } from 'node:util';

const BASE = process.env['SEED_BASE_URL'] ?? 'http://localhost:8080';

const CUENTAS = [
  { email: 'ana@demo.local', displayName: 'Ana', password: 'demo-plataforma-uml' },
  { email: 'beto@demo.local', displayName: 'Beto', password: 'demo-plataforma-uml' },
] as const;

interface Sesion {
  readonly accessToken: string;
  readonly cookie: string;
  readonly user: { id: string; email: string; displayName: string };
}

async function main(): Promise<void> {
  const ana = await cuenta(CUENTAS[0]);
  const beto = await cuenta(CUENTAS[1]);

  const proyecto = await pedir<{ id: string; displayName: string }>('/api/projects', {
    token: ana.accessToken,
    method: 'POST',
    body: { displayName: 'Sistema de Ventas' },
  });

  for (const pizarra of ['Ventas', 'Inventario']) {
    await pedir('/api/projects/' + proyecto.id + '/boards', {
      token: ana.accessToken,
      method: 'POST',
      body: { displayName: pizarra },
    });
  }

  const invitacion = await pedir<{ code: string }>(`/api/projects/${proyecto.id}/invites`, {
    token: ana.accessToken,
    method: 'POST',
    body: { role: 'EDITOR' },
  });
  await pedir(`/api/invites/${invitacion.code}/accept`, {
    token: beto.accessToken,
    method: 'POST',
  });

  console.warn(`
Entorno de demostracion listo en ${BASE}

  Propietaria   ${CUENTAS[0].email}   ${CUENTAS[0].password}
  Editor        ${CUENTAS[1].email}   ${CUENTAS[1].password}

  Proyecto      ${proyecto.displayName}
  Pizarras      Ventas · Inventario

Abre ${BASE} en dos navegadores distintos —o uno normal y otro de incognito—
e inicia sesion con cada cuenta para ver la colaboracion en vivo.
`);
}

async function cuenta(datos: (typeof CUENTAS)[number]): Promise<Sesion> {
  const registro = await intentar('/api/auth/register', {
    email: datos.email,
    displayName: datos.displayName,
    password: datos.password,
  });
  if (registro !== null) return registro;

  // Ya existia, o quedo pendiente de activacion. En los dos casos se intenta
  // entrar: sembrar dos veces no debe fallar.
  const acceso = await intentar('/api/auth/login', {
    email: datos.email,
    password: datos.password,
  });
  if (acceso !== null) return acceso;

  const activada = await activar(datos.email);
  const segundoIntento = activada
    ? await intentar('/api/auth/login', { email: datos.email, password: datos.password })
    : null;
  if (segundoIntento === null) {
    throw new Error(
      `No se pudo crear ni abrir la cuenta ${datos.email}. ` +
        'Activa la cuenta desde el correo (o los logs de API con MAIL_PROVIDER=log) y vuelve a ejecutar npm run seed.',
    );
  }
  return segundoIntento;
}

/**
 * Activa la cuenta con el enlace que la API escribio en su registro.
 *
 * Desde que el registro exige confirmar el correo, sembrar contra una base
 * recien creada terminaba siempre en el error de arriba: `register` devuelve
 * «pendiente de activacion» y `login` responde 403 hasta que alguien copia el
 * enlace a mano. Con `MAIL_PROVIDER=log` —el valor por defecto de la
 * composicion local— ese enlace esta en `docker compose logs api`, asi que se
 * lee de ahi. Con un proveedor real no hay nada que leer y se devuelve `false`:
 * el mensaje de error explica el paso manual.
 */
async function activar(email: string): Promise<boolean> {
  let token = await tokenDeActivacion(email);
  if (token === null) {
    // Un registro anterior pudo salir de la ventana de lineas que se consulta.
    // El reenvio tiene un minuto de espera propio; si no entrega, no hay token.
    await fetch(BASE + '/api/auth/verification/resend', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ email }),
    }).catch(() => undefined);
    token = await tokenDeActivacion(email);
  }
  if (token === null) return false;

  const respuesta = await fetch(BASE + '/api/auth/verification/confirm', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ token }),
  });
  return respuesta.ok;
}

async function tokenDeActivacion(email: string): Promise<string | null> {
  // Solo contra la composicion de esta maquina: leer el registro de un servidor
  // remoto no es posible, y su proveedor de correo tampoco seria `log`.
  if (!/^https?:\/\/(?:localhost|127\.0\.0\.1)(?::\d+)?(?:\/|$)/.test(BASE)) return null;

  let salida: string;
  try {
    const resultado = await promisify(execFile)(
      'docker',
      [
        'compose',
        '-f',
        'infra/compose.yml',
        '--env-file',
        'infra/.env',
        'logs',
        '--no-color',
        '--no-log-prefix',
        '--tail',
        '500',
        'api',
      ],
      { maxBuffer: 16 * 1024 * 1024 },
    );
    salida = resultado.stdout;
  } catch {
    return null;
  }

  return (
    salida
      .split(/\r?\n/)
      .flatMap((linea) => {
        try {
          return [JSON.parse(linea) as { destinatario?: string; cuerpo?: string }];
        } catch {
          return [];
        }
      })
      .findLast((correo) => correo.destinatario === email && correo.cuerpo?.includes('/activar#'))
      ?.cuerpo?.match(/#token=(\S+)/)?.[1] ?? null
  );
}

async function intentar(ruta: string, cuerpo: object): Promise<Sesion | null> {
  const respuesta = await fetch(BASE + ruta, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(cuerpo),
  });

  if (!respuesta.ok) return null;

  const datos = (await respuesta.json()) as Omit<Sesion, 'cookie'> & {
    verificationRequired?: boolean;
  };
  if (datos.verificationRequired) return null;
  return { ...datos, cookie: respuesta.headers.get('set-cookie') ?? '' };
}

interface PedirOpciones {
  readonly token: string;
  readonly method?: string;
  readonly body?: object;
}

async function pedir<T>(ruta: string, opciones: PedirOpciones): Promise<T> {
  const respuesta = await fetch(BASE + ruta, {
    method: opciones.method ?? 'GET',
    headers: {
      authorization: `Bearer ${opciones.token}`,
      // Solo se declara JSON cuando hay cuerpo: declararlo sin cuerpo hace que
      // el servidor rechace la peticion antes de mirar la ruta.
      ...(opciones.body === undefined ? {} : { 'content-type': 'application/json' }),
    },
    ...(opciones.body === undefined ? {} : { body: JSON.stringify(opciones.body) }),
  });

  if (!respuesta.ok) {
    throw new Error(`${ruta} devolvio ${respuesta.status}: ${await respuesta.text()}`);
  }
  return (await respuesta.json()) as T;
}

await main();
```

---

### `scripts/verify-ai-prompts.ts`

```ts
/** Evaluación optativa: ocho llamadas como máximo al proveedor principal, sin
 * respaldos ni reintentos. Nunca lee ni modifica pizarras del usuario.
 * node --env-file=infra/.env --import tsx scripts/verify-ai-prompts.ts --live
 */
import { mkdir, writeFile } from 'node:fs/promises';
import {
  createAiPorts,
  loadAiConfig,
  type AssistantOperation,
  type ConversationTurn,
} from '@uml/ai';
import type { SemanticModel } from '@uml/contracts';

if (!process.argv.includes('--live'))
  throw new Error('Usa --live para autorizar llamadas reales de evaluación.');
const model = (...names: string[]): SemanticModel => ({
  classes: names.map((name, index) => ({
    id: `33333333-3333-4333-8333-${String(index + 1).padStart(12, '0')}`,
    displayName: name,
    codeName: name,
    databaseName: name.toLowerCase(),
    attributes: [],
  })),
  relationships: [],
});
const cliente = model('Cliente');
const withEmail: SemanticModel = {
  ...cliente,
  classes: cliente.classes.map((item) => ({
    ...item,
    attributes: [
      {
        id: '44444444-4444-4444-8444-444444444444',
        displayName: 'correo',
        codeName: 'correo',
        databaseName: 'correo',
        type: 'String',
        primaryKey: false,
        nullable: false,
        unique: true,
      },
    ],
  })),
};
type Case = {
  name: string;
  instruction: string;
  snapshot: SemanticModel;
  context?: readonly ConversationTurn[];
  expected?: readonly Partial<AssistantOperation>[];
  clarification?: boolean;
};
const cases: readonly Case[] = [
  {
    name: 'negación y autocorrección',
    instruction: 'Eh, no borres Cliente. Agrega edad entero, perdón decimal, a Cliente.',
    snapshot: cliente,
    expected: [
      { op: 'ADD_ATTRIBUTE', className: 'Cliente', attributeName: 'edad', type: 'Decimal' },
    ],
  },
  {
    name: 'cardinalidades dictadas',
    instruction:
      'Relaciona Cliente y Venta. Cada venta tiene exactamente un cliente; cada cliente tiene cero a muchas ventas.',
    snapshot: model('Cliente', 'Venta'),
    expected: [
      {
        op: 'CREATE_RELATIONSHIP',
        fromClass: 'Cliente',
        toClass: 'Venta',
        fromMultiplicity: '1',
        toMultiplicity: '0..*',
      },
    ],
  },
  {
    name: 'restricciones negativas',
    instruction: 'El correo de Cliente debe ser opcional y no único. Mantén el nombre y tipo.',
    snapshot: withEmail,
    expected: [
      {
        op: 'UPDATE_ATTRIBUTE',
        className: 'Cliente',
        attributeName: 'correo',
        required: false,
        unique: false,
      },
    ],
  },
  {
    name: 'herencia',
    instruction: 'Crea Estudiante que hereda de Persona, sin agregar atributos.',
    snapshot: model('Persona'),
    expected: [
      { op: 'CREATE_CLASS', className: 'Estudiante' },
      {
        op: 'CREATE_RELATIONSHIP',
        kind: 'GENERALIZATION',
        fromClass: 'Estudiante',
        toClass: 'Persona',
        fromMultiplicity: '1',
        toMultiplicity: '1',
      },
    ],
  },
  {
    name: 'acciones dependientes',
    instruction:
      'Crea Producto, renómbralo a Articulo y agrega stock entero a Articulo. No agregues otros campos.',
    snapshot: model(),
    expected: [
      { op: 'CREATE_CLASS', className: 'Producto' },
      { op: 'RENAME_CLASS', className: 'Producto', newName: 'Articulo' },
      { op: 'ADD_ATTRIBUTE', className: 'Articulo', attributeName: 'stock', type: 'Integer' },
    ],
  },
  {
    name: 'aclaración ordinal',
    instruction: 'la segunda',
    snapshot: model('Empleado', 'Cliente'),
    context: [
      { role: 'user', text: 'Agrega telefono String a esa clase; no borres nada.' },
      { role: 'assistant', text: '¿En qué clase?\n1. "Empleado"\n2. "Cliente"' },
    ],
    expected: [
      { op: 'ADD_ATTRIBUTE', className: 'Cliente', attributeName: 'telefono', type: 'String' },
    ],
  },
  {
    name: 'teléfono conserva ceros',
    instruction: 'Añade numeroTelefono a Cliente, sin indicar clave primaria.',
    snapshot: cliente,
    expected: [
      {
        op: 'ADD_ATTRIBUTE',
        className: 'Cliente',
        attributeName: 'numeroTelefono',
        type: 'String',
      },
    ],
  },
  {
    name: 'límite no representable',
    instruction:
      'Cada Grupo debe tener exactamente entre 2 y 5 Personas. Relaciona ambas clases y conserva ese límite exacto.',
    snapshot: model('Grupo', 'Persona'),
    clarification: true,
  },
];
const config = loadAiConfig({
  ...process.env,
  AI_LLM_FALLBACK_PROVIDER: '',
  AI_LLM_FALLBACK_MODEL: '',
  AI_LLM_FALLBACKS: '[]',
  AI_VISION_PROVIDER: 'mock',
  AI_VISION_FALLBACK_PROVIDER: '',
  AI_VISION_FALLBACK_MODEL: '',
  AI_VISION_FALLBACKS: '[]',
  AI_SPEECH_PROVIDER: 'mock',
  AI_SPEECH_FALLBACK_PROVIDER: '',
  AI_SPEECH_FALLBACK_MODEL: '',
  AI_SPEECH_FALLBACKS: '[]',
  AI_MAX_RETRIES: '0',
  AI_TIMEOUT_MS: '45000',
  AI_CHAIN_TIMEOUT_MS: '45000',
});
if (config.AI_LLM_PROVIDER === 'mock')
  throw new Error('El proveedor es simulado; no se puede acreditar calidad real.');
const ports = createAiPorts(config);
const results: object[] = [];
let failed = false;
for (const item of cases) {
  try {
    const result = await ports.llm.proposeCommands(item);
    const passed = item.clarification
      ? Boolean(result.proposal.needsClarification) && result.proposal.operations.length === 0
      : !result.proposal.needsClarification &&
        result.proposal.operations.length === item.expected?.length &&
        item.expected.every((expected, index) =>
          Object.entries(expected).every(
            ([key, value]) =>
              (result.proposal.operations[index] as unknown as Record<string, unknown>)[key] ===
              value,
          ),
        );
    results.push({ name: item.name, passed, proposal: result.proposal, usage: result.usage });
    process.stdout.write(`${passed ? 'PASS' : 'FAIL'} ${item.name}\n`);
    failed ||= !passed;
  } catch (error) {
    // No imprimir objetos de SDK: pueden contener cabeceras con credenciales.
    results.push({
      name: item.name,
      blocked: true,
      errorType: error instanceof Error ? error.name : 'UnknownError',
    });
    process.stdout.write(
      `BLOCKED ${item.name}: ${error instanceof Error ? error.name : 'UnknownError'}\n`,
    );
    failed = true;
    break;
  }
}
await mkdir('reports/revision-ia-2026-09-10', { recursive: true });
await writeFile(
  'reports/revision-ia-2026-09-10/proveedor-real.json',
  JSON.stringify(
    {
      date: new Date().toISOString(),
      provider: config.AI_LLM_PROVIDER,
      model: config.AI_LLM_MODEL,
      planned: cases.length,
      results,
    },
    null,
    2,
  ),
);
process.exitCode = failed ? 1 : 0;
```

---

### `scripts/verify-management-apps.ts`

```ts
import assert from 'node:assert/strict';
import { randomBytes, randomUUID } from 'node:crypto';
import { mkdtemp } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fixture, GENERABLE_FIXTURE_IDS } from '@uml/fixtures';
import { buildGenerationIr } from '@uml/generation-ir';
import { generateMobileProject, GENERATED_BACKEND_VERSION } from '@uml/generator-backend';
import {
  buildSampleRecords,
  firstMutableAttribute,
  modifiedValue,
} from '../shared/generator-backend/tests/support/sample-data.js';
import {
  freePort,
  mavenCommand,
  publishedPort,
  removeVerifiedTemporaryDirectory,
  runCommand,
  startApplication,
  stopApplication,
  waitForPostgres,
  writeProject,
  type RunningApplication,
} from '../shared/generator-backend/tests/support/runtime.js';

// No AI provider, model runtime or inference is involved in this regression bank.
const selected = process.argv.slice(2).filter((arg) => !arg.startsWith('--'));
for (const fixtureId of selected.length ? selected : GENERABLE_FIXTURE_IDS) {
  const sample = fixture(fixtureId);
  const model = process.argv.includes('--numeric-keys')
    ? {
        ...sample.model,
        classes: sample.model.classes.map((entity) => ({
          ...entity,
          attributes: entity.attributes.map((a) =>
            a.primaryKey ? { ...a, type: 'Integer' as const } : a,
          ),
        })),
      }
    : sample.model;
  const project = await generateMobileProject(
    buildGenerationIr({ projectName: sample.title, snapshotVersion: 1, model }),
  );
  const work = await mkdtemp(join(tmpdir(), 'uml-generated-management-'));
  const container = `uml-management-${randomUUID()}`;
  let app: RunningApplication | undefined;
  let databaseStarted = false;
  try {
    process.stdout.write(
      `${fixtureId} ${sample.title}: compilando ${project.ir.entities.length} entidades...\n`,
    );
    await writeProject(
      work,
      project.files
        .filter((f) => f.path.startsWith('backend/'))
        .map((f) => ({ ...f, path: f.path.slice(8) })),
    );
    await runCommand(mavenCommand(), ['-q', '-DskipTests', 'package'], { cwd: work });
    await runCommand('docker', [
      'run',
      '-d',
      '--name',
      container,
      '-e',
      'POSTGRES_DB=gestion',
      '-e',
      'POSTGRES_PASSWORD=postgres',
      '-p',
      '127.0.0.1::5432',
      'postgres:17-alpine',
    ]);
    databaseStarted = true;
    await waitForPostgres(container);
    const port = await freePort();
    const password = randomBytes(20).toString('hex');
    app = await startApplication(
      join(work, 'target', `${project.ir.project.artifactId}-${GENERATED_BACKEND_VERSION}.jar`),
      port,
      await publishedPort(container),
      'gestion',
      {
        AUTH_USERNAME: 'admin',
        AUTH_PASSWORD: password,
        AUTH_TOKEN_SECRET: randomBytes(32).toString('hex'),
      },
    );
    const baseUrl = `http://127.0.0.1:${port}`;
    let token = '';
    async function request(path: string, method = 'GET', body?: object): Promise<unknown> {
      const response = await fetch(baseUrl + path, {
        method,
        headers: {
          'content-type': 'application/json',
          ...(token ? { authorization: `Bearer ${token}` } : {}),
        },
        ...(body ? { body: JSON.stringify(body) } : {}),
      });
      const text = await response.text();
      assert.equal(
        response.status,
        200,
        `${fixtureId} ${method} ${path}: ${response.status} ${text}`,
      );
      return JSON.parse(text) as unknown;
    }
    token = (
      (await request('/session/login', 'POST', { username: 'admin', password })) as {
        accessToken: string;
      }
    ).accessToken;
    const contract = (await request('/mobile-contract')) as {
      protocolVersion: number;
      contract: unknown;
    };
    assert.equal(contract.protocolVersion, 1);
    assert.deepEqual(
      contract.contract,
      JSON.parse(project.files.find((f) => f.path === 'mobile/assets/contract.json')!.content),
    );
    const records = buildSampleRecords(project.ir);
    for (const record of records) {
      const resource = record.entity.resourcePath;
      const operation = {
        operationId: randomUUID(),
        resource,
        method: 'POST',
        id: record.body[record.entity.primaryKey.fieldName],
        data: record.body,
        base: null,
      };
      const result = (await request('/mobile-sync', 'POST', operation)) as {
        data: Record<string, unknown>;
      };
      assert.deepEqual(
        await request('/mobile-sync', 'POST', operation),
        result,
        'El reintento debe recuperar el recibo',
      );
      const dto = (await request(`/api/${resource}/${encodeURIComponent(record.id)}`)) as Record<
        string,
        unknown
      >;
      assert.deepEqual(dto, result.data);
      assert.deepEqual(dto, record.body, 'Tipos, atributos y referencias deben conservarse');
      const list = (await request(`/api/${resource}`)) as Record<string, unknown>[];
      assert.ok(list.some((row) => String(row[record.entity.primaryKey.fieldName]) === record.id));
      const field = firstMutableAttribute(record.entity);
      if (field) {
        const data = { ...dto, [field.fieldName]: modifiedValue(field) };
        await request('/mobile-sync', 'POST', {
          operationId: randomUUID(),
          resource,
          method: 'PUT',
          id: operation.id,
          data,
          base: dto,
        });
        const changed = (await request(
          `/api/${resource}/${encodeURIComponent(record.id)}`,
        )) as Record<string, unknown>;
        assert.deepEqual(changed, data);
      }
    }
    for (const record of [...records].reverse()) {
      const resource = record.entity.resourcePath;
      // Fetch current DTO in case another operation affected an inherited view.
      const dto = await request(`/api/${resource}/${encodeURIComponent(record.id)}`);
      const operation = {
        operationId: randomUUID(),
        resource,
        method: 'DELETE',
        id: record.body[record.entity.primaryKey.fieldName],
        data: null,
        base: dto,
      };
      const result = await request('/mobile-sync', 'POST', operation);
      assert.deepEqual(await request('/mobile-sync', 'POST', operation), result);
      const absent = await fetch(`${baseUrl}/api/${resource}/${encodeURIComponent(record.id)}`, {
        headers: { authorization: `Bearer ${token}` },
      });
      assert.equal(absent.status, 404);
    }
    process.stdout.write(
      `OK ${fixtureId}: contrato Flutter, CRUD, relaciones y reintentos (${records.length} recursos).\n`,
    );
  } finally {
    if (app) await stopApplication(app);
    if (databaseStarted)
      await runCommand('docker', ['rm', '-f', container], { allowFailure: true });
    await removeVerifiedTemporaryDirectory(work);
  }
}
```

---

### `scripts/verify-mobile-backend.ts`

```ts
import assert from 'node:assert/strict';
import { randomBytes, randomUUID } from 'node:crypto';
import { mkdtemp } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fixture } from '@uml/fixtures';
import { buildGenerationIr } from '@uml/generation-ir';
import { generateMobileProject } from '@uml/generator-backend';
import {
  freePort,
  mavenCommand,
  publishedPort,
  removeVerifiedTemporaryDirectory,
  runCommand,
  startApplication,
  stopApplication,
  waitForPostgres,
  writeProject,
  type RunningApplication,
} from '../shared/generator-backend/tests/support/runtime.js';

const work = await mkdtemp(join(tmpdir(), 'uml-generated-mobile-'));
const container = `uml-mobile-test-${randomUUID()}`;
let running: RunningApplication | undefined;
try {
  const project = await generateMobileProject(
    buildGenerationIr({ projectName: 'Ventas', snapshotVersion: 1, model: fixture('T01').model }),
  );
  await writeProject(
    work,
    project.files
      .filter((f) => f.path.startsWith('backend/'))
      .map((f) => ({ ...f, path: f.path.slice(8) })),
  );
  await runCommand(mavenCommand(), ['-q', '-DskipTests', 'package'], { cwd: work });
  await runCommand('docker', [
    'run',
    '-d',
    '--name',
    container,
    '-e',
    'POSTGRES_DB=ventas',
    '-e',
    'POSTGRES_PASSWORD=postgres',
    '-p',
    '127.0.0.1::5432',
    'postgres:17-alpine',
  ]);
  await waitForPostgres(container);
  const port = await freePort();
  const dbport = await publishedPort(container);
  const password = randomBytes(20).toString('hex');
  const auth = {
    AUTH_USERNAME: 'admin',
    AUTH_PASSWORD: password,
    AUTH_TOKEN_SECRET: randomBytes(32).toString('hex'),
    CORS_ALLOWED_ORIGINS: 'https://frontend.example.test',
  };
  const jar = join(work, 'target', 'ventas-0.0.1-SNAPSHOT.jar');
  running = await startApplication(jar, port, dbport, 'ventas', auth);
  const url = `http://127.0.0.1:${port}`;
  let token = '';
  async function request(
    path: string,
    method = 'GET',
    body?: object,
    expected = 200,
    authorize = true,
  ) {
    const response = await fetch(url + path, {
      method,
      headers: {
        'content-type': 'application/json',
        ...(authorize && token ? { authorization: `Bearer ${token}` } : {}),
      },
      ...(body ? { body: JSON.stringify(body) } : {}),
    });
    const text = await response.text();
    assert.equal(response.status, expected, `${method} ${path}: ${response.status} ${text}`);
    return text ? (JSON.parse(text) as Record<string, unknown>) : {};
  }
  const resource = project.ir.entities.find((e) => e.className === 'Cliente')!;
  const path = `/api/${resource.resourcePath}`;
  for (const [corsPath, method] of [
    [path, 'PUT'],
    ['/session/login', 'POST'],
    ['/session/refresh', 'POST'],
    ['/session/logout', 'POST'],
    ['/mobile-contract', 'GET'],
    ['/mobile-sync', 'POST'],
  ]) {
    const preflight = await fetch(url + corsPath, {
      method: 'OPTIONS',
      headers: {
        Origin: 'https://frontend.example.test',
        'Access-Control-Request-Method': method!,
        'Access-Control-Request-Headers': 'authorization,content-type',
      },
    });
    assert.equal(preflight.status, 200);
    assert.equal(
      preflight.headers.get('access-control-allow-origin'),
      'https://frontend.example.test',
    );
    const denied = await fetch(url + corsPath, {
      method: 'OPTIONS',
      headers: { Origin: 'https://other.example.test', 'Access-Control-Request-Method': method! },
    });
    assert.equal(denied.status, 403);
    assert.equal(denied.headers.get('access-control-allow-origin'), null);
  }
  await request('/mobile-contract', 'GET', undefined, 401, false);
  await request(path, 'GET', undefined, 401, false);
  await request(
    '/session/login',
    'POST',
    { username: 'admin', password: 'incorrecta' },
    401,
    false,
  );
  const login = await request(
    '/session/login',
    'POST',
    { username: 'admin', password },
    200,
    false,
  );
  token = login['accessToken'] as string;
  const refreshToken = login['refreshToken'] as string;
  assert.match(refreshToken, /^[0-9a-f]{64}$/);
  const contract = await request('/mobile-contract');
  assert.equal(contract['protocolVersion'], 1);
  assert.deepEqual(
    contract['contract'],
    JSON.parse(project.files.find((f) => f.path === 'mobile/assets/contract.json')!.content),
  );
  const id = randomUUID();
  const data = { id, nombre: 'Ana', correo: 'ana@example.com', telefono: null };
  const change = {
    operationId: randomUUID(),
    resource: resource.resourcePath,
    method: 'POST',
    id,
    data,
    base: null,
  };
  const first = await request('/mobile-sync', 'POST', change);
  assert.deepEqual(await request('/mobile-sync', 'POST', change), first);
  await request('/mobile-sync', 'POST', { ...change, data: { ...data, nombre: 'otro' } }, 409);
  await request(
    '/mobile-sync',
    'POST',
    { ...change, operationId: randomUUID(), id: randomUUID() },
    400,
  );
  await stopApplication(running);
  running = await startApplication(jar, port, dbport, 'ventas', auth);
  for (let retry = 0; retry < 2; retry++) {
    const refreshed = await request('/session/refresh', 'POST', { refreshToken }, 200, false);
    assert.equal(refreshed['refreshToken'], refreshToken);
    assert.equal(refreshed['username'], 'admin');
    token = refreshed['accessToken'] as string;
  }
  assert.deepEqual(
    await request('/mobile-sync', 'POST', change),
    first,
    'recibo persistido tras reinicio',
  );
  const update = {
    operationId: randomUUID(),
    resource: resource.resourcePath,
    method: 'PUT',
    id,
    data: { ...data, nombre: 'Nueva' },
    base: first['data'],
  };
  const attempts = await Promise.all([
    request('/mobile-sync', 'POST', update),
    request('/mobile-sync', 'POST', update),
  ]);
  assert.deepEqual(attempts[0], attempts[1]);
  await request(
    '/mobile-sync',
    'POST',
    { ...update, operationId: randomUUID(), data: { ...data, nombre: 'Obsoleta' } },
    409,
  );
  const current = await request(`${path}/${id}`);
  assert.equal(current['nombre'], 'Nueva');
  const deletion = {
    operationId: randomUUID(),
    resource: resource.resourcePath,
    method: 'DELETE',
    id,
    data: null,
    base: current,
  };
  await request('/mobile-sync', 'POST', deletion);
  await request('/mobile-sync', 'POST', deletion);
  await request(`${path}/${id}`, 'GET', undefined, 404);
  const otherDevice = await request(
    '/session/login',
    'POST',
    { username: 'admin', password },
    200,
    false,
  );
  assert.notEqual(otherDevice['refreshToken'], refreshToken);
  await request('/session/logout', 'POST', { refreshToken }, 204, false);
  await request('/session/logout', 'POST', { refreshToken }, 204, false);
  await request(path, 'GET', undefined, 401);
  await request('/session/refresh', 'POST', { refreshToken }, 401, false);
  token = otherDevice['accessToken'] as string;
  await request(path);
  await stopApplication(running);
  running = await startApplication(jar, port, dbport, 'ventas', {
    ...auth,
    AUTH_PASSWORD: 'admin',
  });
  await request(path, 'GET', undefined, 401);
  await request(
    '/session/refresh',
    'POST',
    { refreshToken: otherDevice['refreshToken'] },
    401,
    false,
  );
  const seeded = await request(
    '/session/login',
    'POST',
    { username: 'admin', password: 'admin' },
    200,
    false,
  );
  token = seeded['accessToken'] as string;
  await request(path);
  process.stdout.write(
    'Spring movil: semilla admin/admin, renovacion persistente, revocacion por dispositivo y cambio de clave, CORS, CRUD, reintentos, reinicio y conflictos aprobados.',
  );
} finally {
  if (running) await stopApplication(running);
  await runCommand('docker', ['rm', '-f', container], { allowFailure: true });
  await removeVerifiedTemporaryDirectory(work);
}
```

---

### `scripts/verify-production-client.mjs`

```js
import assert from 'node:assert/strict';
import console from 'node:console';
import process from 'node:process';
import { setTimeout, clearTimeout } from 'node:timers';
import { randomUUID } from 'node:crypto';
import { HocuspocusProvider } from '@hocuspocus/provider';
import { chromium, expect } from '@playwright/test';
import { readFile, mkdir } from 'node:fs/promises';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
const { fetch, AbortSignal } = globalThis;

const origin = 'https://localhost:18443';
const request = (path, options = {}) =>
  fetch(`${origin}${path}`, {
    ...options,
    signal: AbortSignal.timeout(15000),
  });
for (const path of ['/', '/api/health', '/api/ready', '/collab/health']) {
  const response = await request(path);
  assert.equal(response.status, 200, path);
  assert.ok(response.headers.get('strict-transport-security'));
  assert.equal(response.headers.get('x-frame-options'), 'DENY');
}
const redirect = await fetch('http://localhost:18080/', { redirect: 'manual' });
assert.equal(redirect.status, 308);
assert.ok(redirect.headers.get('location').startsWith('https://'));
for (const method of ['PUT', 'PATCH', 'DELETE']) {
  const preflight = await request('/api/projects', {
    method: 'OPTIONS',
    headers: {
      origin,
      'access-control-request-method': method,
      'access-control-request-headers': 'authorization,content-type',
    },
  });
  assert.equal(preflight.status, 204);
  assert.equal(preflight.headers.get('access-control-allow-origin'), origin);
  assert.equal(preflight.headers.get('access-control-allow-credentials'), 'true');
  assert.ok(
    preflight.headers
      .get('access-control-allow-methods')
      .split(',')
      .map((value) => value.trim())
      .includes(method),
  );
}
const foreign = await request('/api/health', {
  headers: { origin: 'https://untrusted.example.org' },
});
assert.equal(foreign.headers.get('access-control-allow-origin'), null);
const email = `${randomUUID()}@example.org`;
const password = randomUUID();
const registration = await request('/api/auth/register', {
  method: 'POST',
  headers: { 'content-type': 'application/json' },
  body: JSON.stringify({
    email,
    displayName: 'Production test',
    password,
  }),
});
assert.equal(registration.status, 201);
assert.equal(registration.headers.get('set-cookie'), null);
assert.deepEqual(await registration.json(), { verificationRequired: true, emailSent: true });
const composeArgs = JSON.parse(process.env.UML_TEST_COMPOSE_ARGS);
assert.ok(
  composeArgs.includes('-p') && composeArgs.some((arg) => arg.startsWith('uml-prod-test-')),
);
const { stdout: mailJson } = await promisify(execFile)('docker', [
  ...composeArgs,
  'exec',
  '-T',
  'api',
  'cat',
  '/tmp/test-mail.json',
]);
const verificationToken = JSON.parse(mailJson).textContent.match(/#token=([^\s]+)/)[1];
const browserForActivation = await chromium.launch();
try {
  const context = await browserForActivation.newContext({ ignoreHTTPSErrors: true });
  const page = await context.newPage();
  await page.goto(`${origin}/activar#token=${verificationToken}`);
  await page.getByRole('button', { name: 'Activar mi cuenta', exact: true }).click();
  await expect(page.getByTestId('cuenta-activada')).toBeVisible();
  const uiEmail = `ui-${email}`;
  await page.goto(`${origin}/entrar`);
  await page.getByRole('button', { name: 'Crear cuenta', exact: true }).click();
  await page.getByTestId('email').fill(uiEmail);
  await page.getByTestId('displayName').fill('Activación de prueba');
  await page.getByTestId('password').fill(password);
  await page.getByTestId('enviar').click();
  await expect(page.getByTestId('activacion-pendiente')).toContainText('Te enviamos un enlace');
  await page.getByTestId('password').fill(password);
  await page.getByTestId('enviar').click();
  await expect(page.getByTestId('error-sesion')).toContainText('Activa tu cuenta');
  const { stdout: uiMail } = await promisify(execFile)('docker', [
    ...composeArgs,
    'exec',
    '-T',
    'api',
    'cat',
    '/tmp/test-mail.json',
  ]);
  const uiToken = JSON.parse(uiMail).textContent.match(/#token=([^\s]+)/)[1];
  await page.goto(`${origin}/activar#token=${uiToken}`);
  await page.setViewportSize({ width: 375, height: 812 });
  await mkdir('reports', { recursive: true });
  await page.screenshot({ path: 'reports/email-activation-mobile.png', fullPage: true });
  assert.ok(
    await page.evaluate(
      () => globalThis.document.documentElement.scrollWidth <= globalThis.innerWidth,
    ),
  );
  await page.getByRole('button', { name: 'Activar mi cuenta', exact: true }).click();
  await expect(page.getByTestId('cuenta-activada')).toBeVisible();
  await page.getByRole('link', { name: 'Ir a iniciar sesión' }).click();
  await page.getByTestId('email').fill(uiEmail);
  await page.getByTestId('password').fill(password);
  await page.getByTestId('enviar').click();
  await expect(page.getByTestId('lista-proyectos')).toBeVisible();
} finally {
  await browserForActivation.close();
}
const login = await request('/api/auth/login', {
  method: 'POST',
  headers: { 'content-type': 'application/json' },
  body: JSON.stringify({ email, password }),
});
assert.equal(login.status, 200);
assert.match(login.headers.get('set-cookie'), /; Secure/i);
assert.match(login.headers.get('set-cookie'), /; HttpOnly/i);
const { accessToken } = await login.json();
const headers = { authorization: `Bearer ${accessToken}`, 'content-type': 'application/json' };
const project = await (
  await request('/api/projects', {
    method: 'POST',
    headers,
    body: JSON.stringify({ displayName: 'HTTPS smoke' }),
  })
).json();
assert.ok(project.id);
const board = await (
  await request(`/api/projects/${project.id}/boards`, {
    method: 'POST',
    headers,
    body: JSON.stringify({ displayName: 'WSS smoke' }),
  })
).json();
assert.ok(board.room);
let provider;
try {
  await new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error('WSS sync timed out')), 15000);
    provider = new HocuspocusProvider({
      url: 'wss://localhost:18443/collab',
      name: board.room,
      token: accessToken,
      onSynced: ({ state }) => {
        if (state) {
          clearTimeout(timer);
          resolve();
        }
      },
      onAuthenticationFailed: ({ reason }) => {
        clearTimeout(timer);
        reject(new Error(reason));
      },
    });
  });
} finally {
  provider?.destroy();
}
// TLS was validated above with the local CA. This option is scoped to this
// temporary localhost browser context, never to a real cloud deployment.
const browser = await chromium.launch();
try {
  const context = await browser.newContext({ ignoreHTTPSErrors: true });
  const page = await context.newPage();
  const errors = [];
  page.on('pageerror', (error) => errors.push(error.message));
  await page.goto(`${origin}/entrar`);
  await page.getByTestId('email').fill(email);
  await page.getByTestId('password').fill(password);
  await page.getByTestId('enviar').click();
  await expect(page.getByTestId('lista-proyectos')).toBeVisible();
  await page.goto(`${origin}/pizarras/${board.id}`);
  await expect(page.getByTestId('estado-conexion')).toHaveText('En vivo', { timeout: 20000 });
  // Las herramientas del panel son pestanas (role="tab"), no botones: el mismo
  // localizador que usan las pruebas E2E en e2e/support/actors.ts.
  await page.getByTestId('pestana-importar').click();
  await expect(page.getByTestId('importar-xmi')).toBeEnabled();
  await expect(page.getByTestId('exportar-png')).toBeDisabled();
  await page.getByTestId('crear-clase').click();
  await page.getByTestId('nombre-clase').fill('Persona');
  await page.getByTestId('nuevo-atributo').fill('correo');
  await page.getByRole('button', { name: 'Añadir', exact: true }).click();
  await page.getByTestId('tool-association').click();
  await page.getByTestId('clase-Persona').click();
  await page.getByTestId('clase-Persona').click();
  await expect(page.locator('.react-flow__edge')).toHaveCount(1);
  await page.getByTestId('rol-origen').fill('supervisor');
  await page.getByTestId('rol-destino').fill('subordinados');
  await expect(page.locator('.rol-asociacion')).toHaveText(['supervisor', 'subordinados']);
  // A translated/zoomed camera must not crop the diagram or its recursive edge.
  const viewport = page.locator('.react-flow__viewport');
  await viewport.evaluate((element) => {
    element.style.transform = 'translate(-1500px, -900px) scale(0.4)';
  });
  const cameraBefore = await viewport.getAttribute('style');
  await page.getByTestId('exportar-png').click();
  await page.getByRole('textbox', { name: 'Nombre de la imagen' }).fill('Diagrama UML');
  const downloaded = page.waitForEvent('download');
  await page.getByRole('button', { name: 'Guardar PNG' }).click();
  const download = await downloaded;
  assert.equal(download.suggestedFilename(), 'Diagrama UML.png');
  await mkdir('reports', { recursive: true });
  await download.saveAs('reports/diagram-export.png');
  const png = await readFile('reports/diagram-export.png');
  assert.equal(png.subarray(0, 8).toString('hex'), '89504e470d0a1a0a');
  assert.ok(png.readUInt32BE(16) >= 600, 'full class width including padding at 2x');
  assert.ok(png.readUInt32BE(20) >= 350, 'recursive edge is included below the class');
  assert.ok(png.length > 4000, 'PNG contains rendered content');
  await expect(
    page.getByRole('status').filter({ hasText: 'Exportado como Diagrama UML.png' }),
  ).toBeVisible();
  assert.equal(await viewport.getAttribute('style'), cameraBefore, 'export preserves camera');
  assert.deepEqual(errors, []);
} finally {
  await browser.close();
}
let blocked = false;
for (let i = 0; i < 22; i++) {
  const response = await request('/api/auth/login', {
    method: 'POST',
    headers: { 'content-type': 'application/json', 'x-forwarded-for': `192.0.2.${i}` },
    body: '{}',
  });
  if (response.status === 429) {
    assert.ok(response.headers.get('retry-after'));
    blocked = true;
    break;
  }
}
assert.ok(blocked, 'Spoofed forwarding headers must not bypass authentication limits');
console.warn('HTTPS/WSS, security headers, secure cookies and rate limits verified');
```

---

### `scripts/verify-production.mjs`

```js
// Cleanup applies ONLY to this uniquely named test Compose project.
import assert from 'node:assert/strict';
import console from 'node:console';
import { execFile } from 'node:child_process';
import { randomBytes } from 'node:crypto';
import { mkdir, mkdtemp, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import process from 'node:process';
import { promisify } from 'node:util';

const exec = promisify(execFile);
const project = `uml-prod-test-${randomBytes(4).toString('hex')}`;
await mkdir('tmp', { recursive: true });
const dir = await mkdtemp(resolve('tmp', 'production-check-'));
const envFile = resolve(dir, '.env');
const override = resolve(dir, 'compose.test.yml');
const mailStub = resolve(dir, 'mail-stub.mjs');
await writeFile(
  mailStub,
  `import { writeFile } from 'node:fs/promises';
const realFetch = globalThis.fetch;
globalThis.fetch = async (url, options) => {
  if (String(url) === 'https://api.brevo.com/v3/smtp/email') {
    await writeFile('/tmp/test-mail.json', options.body);
    return new Response('{}', { status: 201 });
  }
  return realFetch(url, options);
};
`,
);
const password = randomBytes(32).toString('hex');
await writeFile(
  envFile,
  `APP_VERSION=production-check
DOMAIN=localhost
WEB_ORIGIN=https://localhost:18443
ACME_EMAIL=test@example.org
POSTGRES_USER=uml
POSTGRES_DB=uml
POSTGRES_PASSWORD=${password}
JWT_SECRET=${randomBytes(48).toString('hex')}
MAIL_FROM=test@example.org
BREVO_API_KEY=local-test-no-mail-is-sent
BACKUP_S3_URI=s3://local-test/uml
AI_LLM_PROVIDER=mock
AI_VISION_PROVIDER=mock
AI_SPEECH_PROVIDER=mock
`,
  { mode: 0o600 },
);
await writeFile(
  override,
  `services:
  api:
    environment:
      NODE_OPTIONS: '--import=/opt/test-mail.mjs'
    volumes:
      - '${mailStub.replaceAll('\\', '/')}:/opt/test-mail.mjs:ro'
  proxy:
    ports: !override ['127.0.0.1:18080:80', '127.0.0.1:18443:443']
  backup:
    environment:
      BACKUP_S3_URI: ''
  restore:
    image: postgres:17-alpine
    environment:
      POSTGRES_USER: uml
      POSTGRES_DB: restored
      POSTGRES_PASSWORD: ${password}
    healthcheck:
      test: ['CMD-SHELL', 'pg_isready -U uml -d restored']
      interval: 3s
      timeout: 3s
      retries: 30
`,
);
const args = [
  'compose',
  '-p',
  project,
  '--env-file',
  envFile,
  '-f',
  'infra/compose.yml',
  '-f',
  'infra/compose.production.yml',
  '-f',
  override,
];
async function docker(...command) {
  try {
    const result = await exec('docker', command, { maxBuffer: 12 * 1024 * 1024 });
    return result.stdout;
  } catch (error) {
    console.error(error.stdout, error.stderr);
    throw error;
  }
}
const compose = (...command) => docker(...args, ...command);
try {
  console.warn('Checking production configuration and building isolated images…');
  const config = JSON.parse(await compose('config', '--format', 'json'));
  for (const service of ['db', 'api', 'collab', 'web', 'restore']) {
    assert.ok(!config.services[service].ports?.length, `${service} must not publish ports`);
  }
  assert.equal(
    config.services.api.environment.JWT_SECRET,
    config.services.collab.environment.JWT_SECRET,
  );
  assert.equal(config.services.api.environment.COOKIE_SECURE, 'true');
  assert.equal(config.services.api.environment.NODE_ENV, 'production');
  await compose('build', 'api', 'collab', 'web', 'migrate', 'backup');
  console.warn('Starting HTTPS stack with temporary PostgreSQL volumes…');
  await compose('up', '-d', '--wait', '--wait-timeout', '240');
  const proxyId = (await compose('ps', '-q', 'proxy')).trim();
  const cert = resolve(dir, 'local-ca.crt');
  await docker('cp', `${proxyId}:/data/caddy/pki/authorities/local/root.crt`, cert);
  const result = await exec(process.execPath, ['scripts/verify-production-client.mjs'], {
    env: { ...process.env, NODE_EXTRA_CA_CERTS: cert, UML_TEST_COMPOSE_ARGS: JSON.stringify(args) },
    maxBuffer: 1024 * 1024,
  });
  console.warn(result.stdout || result.stderr);
  await compose('stop', 'backup');
  await compose('run', '--rm', '--no-deps', 'backup', 'once');
  console.warn('Restoring the dump into a separate PostgreSQL container…');
  const restored = await compose(
    'run',
    '--rm',
    '--no-deps',
    '--entrypoint',
    'sh',
    '-e',
    'PGHOST=restore',
    '-e',
    'PGDATABASE=restored',
    'backup',
    '-ec',
    `file=$(ls -t /backups/uml-*.dump | head -n 1)
pg_restore --exit-on-error --no-owner --no-acl --dbname "$PGDATABASE" "$file"
test "$(psql -Atc 'SELECT count(*) FROM users')" -ge 1
echo 'Dump restored; user data preserved'`,
  );
  console.warn(restored.trim());
  console.warn(
    'Production smoke passed: HTTPS, secure session, WSS, rate limits, backup and restore.',
  );
} catch (error) {
  console.error(await compose('logs', '--tail', '35').catch(() => 'Logs unavailable'));
  throw error;
} finally {
  console.warn(`Removing only isolated test project ${project}…`);
  await compose('down', '--volumes', '--remove-orphans');
}
```

---

## Pruebas de extremo a extremo

Configuracion de Playwright, especificaciones y utilidades de apoyo.

### Estructura

```text
e2e/
|-- offline/
|   |-- offline.spec.ts
|   |-- playwright.config.ts
|   `-- server.ts
|-- specs/
|   |-- apariencia.spec.ts
|   |-- aprendizaje-ia.spec.ts
|   |-- auditoria-regresiones.spec.ts
|   |-- ayuda-software.spec.ts
|   |-- borradores.spec.ts
|   |-- carga.spec.ts
|   |-- colaboracion-concurrente.spec.ts
|   |-- colaboracion-xmi-completa.spec.ts
|   |-- colaboracion.spec.ts
|   |-- cuenta.spec.ts
|   |-- generacion.spec.ts
|   |-- ia-contexto.spec.ts
|   |-- movil.spec.ts
|   |-- notacion.spec.ts
|   |-- proyectos-navegacion.spec.ts
|   |-- proyectos.spec.ts
|   |-- recorrido-interactivo.spec.ts
|   |-- revision-colaboracion-xmi.spec.ts
|   |-- sesion.spec.ts
|   |-- tarjetas.spec.ts
|   |-- usabilidad-editor.spec.ts
|   |-- voz.spec.ts
|   |-- xmi-asociativa.spec.ts
|   `-- zz-captura.spec.ts
|-- support/
|   |-- actors.ts
|   `-- escenario.ts
`-- playwright.config.ts
```

### Archivos

| Archivo | Lineas |
| --- | ---: |
| `e2e/playwright.config.ts` | 34 |
| `e2e/offline/offline.spec.ts` | 529 |
| `e2e/offline/playwright.config.ts` | 18 |
| `e2e/offline/server.ts` | 153 |
| `e2e/specs/apariencia.spec.ts` | 145 |
| `e2e/specs/aprendizaje-ia.spec.ts` | 133 |
| `e2e/specs/auditoria-regresiones.spec.ts` | 149 |
| `e2e/specs/ayuda-software.spec.ts` | 162 |
| `e2e/specs/borradores.spec.ts` | 46 |
| `e2e/specs/carga.spec.ts` | 89 |
| `e2e/specs/colaboracion-concurrente.spec.ts` | 61 |
| `e2e/specs/colaboracion-xmi-completa.spec.ts` | 187 |
| `e2e/specs/colaboracion.spec.ts` | 843 |
| `e2e/specs/cuenta.spec.ts` | 179 |
| `e2e/specs/generacion.spec.ts` | 109 |
| `e2e/specs/ia-contexto.spec.ts` | 70 |
| `e2e/specs/movil.spec.ts` | 129 |
| `e2e/specs/notacion.spec.ts` | 352 |
| `e2e/specs/proyectos-navegacion.spec.ts` | 83 |
| `e2e/specs/proyectos.spec.ts` | 163 |
| `e2e/specs/recorrido-interactivo.spec.ts` | 144 |
| `e2e/specs/revision-colaboracion-xmi.spec.ts` | 116 |
| `e2e/specs/sesion.spec.ts` | 28 |
| `e2e/specs/tarjetas.spec.ts` | 54 |
| `e2e/specs/usabilidad-editor.spec.ts` | 168 |
| `e2e/specs/voz.spec.ts` | 244 |
| `e2e/specs/xmi-asociativa.spec.ts` | 75 |
| `e2e/specs/zz-captura.spec.ts` | 22 |
| `e2e/support/actors.ts` | 191 |
| `e2e/support/escenario.ts` | 66 |

---

### `e2e/playwright.config.ts`

```ts
import { defineConfig, devices } from '@playwright/test';

/**
 * Pruebas de extremo a extremo con dos navegadores (plan maestro 15.4).
 *
 * Se ejecutan contra el entorno de contenedores levantado, porque lo que se
 * quiere comprobar es la cadena completa: navegador → proxy → proceso HTTP y
 * proceso WebSocket → PostgreSQL. Sustituir cualquier eslabon por un doble
 * dejaria sin probar justo lo que puede fallar el dia de la defensa.
 *
 *   npm run up          (una vez)
 *   npm run test:e2e
 */
export default defineConfig({
  testDir: './specs',
  // Las salas son compartidas: dos ficheros en paralelo se pisarian.
  workers: 1,
  fullyParallel: false,
  timeout: 60_000,
  expect: { timeout: 15_000 },
  retries: process.env['CI'] ? 1 : 0,
  reporter: process.env['CI']
    ? [['list'], ['junit', { outputFile: '../reports/e2e-junit.xml' }]]
    : 'list',

  use: {
    baseURL: process.env['E2E_BASE_URL'] ?? 'http://localhost:8080',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },

  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
});
```

---

### `e2e/offline/offline.spec.ts`

```ts
import { expect, test, type Page } from '@playwright/test';
import { createDecoder, readVarString, readVarUint } from 'lib0/decoding';

const board = '/pizarras/00000000-0000-4000-8000-000000000010';
const secondBoard = '/pizarras/00000000-0000-4000-8000-000000000011';
const betoId = '00000000-0000-4000-8000-000000000002';

async function enter(page: Page, account = 'ana'): Promise<void> {
  await page.goto('/entrar');
  await page.getByTestId('email').fill(`${account}@example.com`);
  await page.getByTestId('password').fill('password-test');
  await page.getByTestId('enviar').click();
  await expect(page.getByTestId('lista-proyectos')).toBeVisible();
  await page.evaluate(async () => {
    await navigator.serviceWorker.ready;
  });
  await page.goto(board);
  await expect(page.getByTestId('estado-conexion')).toHaveText('En vivo');
  await expect(page.getByTestId('offline-disponible')).toBeVisible();
}

async function create(page: Page, name: string): Promise<void> {
  await page.getByTestId('crear-clase').click();
  await page.getByTestId('nombre-clase').fill(name);
  await page.getByTestId('nombre-clase').press('Tab');
  await expect(page.getByTestId(`clase-${name}`)).toBeVisible();
}

test.beforeEach(async ({ request }) => {
  await request.post('/test/reset');
});

test('al reconectar valida el acceso vigente sin rotar la cookie innecesariamente', async ({
  page,
}) => {
  await enter(page);
  let refreshes = 0;
  await page.route('**/api/auth/refresh', (route) => {
    refreshes++;
    return route.continue();
  });
  await page.context().setOffline(true);
  await expect(page.getByTestId('modo-offline')).toBeVisible();
  await page.context().setOffline(false);
  await expect(page.getByTestId('estado-conexion')).toHaveText('En vivo');
  expect(refreshes).toBe(0);
});

test('abre la copia local si el acceso vence y la renovación de la consulta falla', async ({
  page,
}) => {
  await enter(page);
  await create(page, 'AccesoVencido');
  await page.route(`**/api${board.replace('/pizarras/', '/boards/')}`, (route) =>
    route.fulfill({ status: 401, json: { error: { code: 'unauthorized' } } }),
  );
  let refreshes = 0;
  await page.route('**/api/auth/refresh', (route) => {
    refreshes++;
    return refreshes === 1
      ? route.continue()
      : route.fulfill({ status: 503, json: { error: { message: 'Servicio no disponible' } } });
  });
  await page.reload();
  await expect(page.getByTestId('modo-offline')).toBeVisible();
  await expect(page.getByTestId('clase-AccesoVencido')).toBeVisible();
  await create(page, 'CambioPendiente');
  await page.unroute('**/api/auth/refresh');
  await page.unroute(`**/api${board.replace('/pizarras/', '/boards/')}`);
  await expect(page.getByTestId('estado-conexion')).toHaveText('En vivo');
  await expect(page.getByTestId('clase-CambioPendiente')).toBeVisible();
});

test('carga el detalle de un proyecto abierto sin conexión al recuperarse', async ({ page }) => {
  await enter(page);
  await page.context().setOffline(true);
  await page.goto('/proyectos/recuperado');
  await expect(page.getByTestId('aviso-sin-conexion')).toBeVisible();
  await page.route('**/api/projects/recuperado', (route) =>
    route.fulfill({
      json: { id: 'recuperado', displayName: 'Proyecto recuperado', role: 'OWNER', boards: [] },
    }),
  );
  await page.context().setOffline(false);
  await expect(page.getByTestId('lista-pizarras')).toBeVisible();
  await page.getByTestId('nombre-pizarra').fill('Borrador conservado');
  await page.context().setOffline(true);
  await expect(page.getByTestId('aviso-sin-conexion')).toBeVisible();
  await page.context().setOffline(false);
  await expect(page.getByTestId('aviso-sin-conexion')).toHaveCount(0);
  await expect(page.getByTestId('nombre-pizarra')).toHaveValue('Borrador conservado');
});

test('carga los proyectos al recuperar la conexión sin perder el formulario', async ({ page }) => {
  await enter(page);
  await page.context().setOffline(true);
  await page.goto('/proyectos');
  await expect(page.getByTestId('aviso-sin-conexion')).toBeVisible();
  await page.getByTestId('nombre-proyecto').fill('Borrador conservado');
  await page.route('**/api/projects', (route) =>
    route.fulfill({
      json: [
        {
          id: 'recuperado',
          displayName: 'Proyecto recuperado',
          role: 'OWNER',
          boardCount: 1,
          memberCount: 1,
        },
      ],
    }),
  );
  await page.context().setOffline(false);
  await expect(page.getByTestId('aviso-sin-conexion')).toHaveCount(0);
  await expect(page.getByRole('link', { name: 'Proyecto recuperado', exact: true })).toBeVisible();
  await expect(page.getByTestId('nombre-proyecto')).toHaveValue('Borrador conservado');
});

test('un login en otra pestaña espera al logout pendiente antes de cambiar la cookie', async ({
  page,
}) => {
  await enter(page);
  const sibling = await page.context().newPage();
  await sibling.goto(board);
  await expect(sibling.getByTestId('estado-conexion')).toHaveText('En vivo');
  let release!: () => void;
  let started!: () => void;
  const gate = new Promise<void>((resolve) => {
    release = resolve;
  });
  const received = new Promise<void>((resolve) => {
    started = resolve;
  });
  await page.route('**/api/auth/logout', async (route) => {
    started();
    await gate;
    await route.continue();
  });
  try {
    await page.getByTestId('salir').click();
    await received;
    await expect(sibling.getByTestId('email')).toBeVisible();
    await sibling.getByTestId('email').fill('beto@example.com');
    await sibling.getByTestId('password').fill('password-test');
    await sibling.getByTestId('enviar').click();
    // Observe the shared browser lock: the old response must finish setting its
    // cookie before this other tab sends the new login request.
    await expect
      .poll(() =>
        sibling.evaluate(async () =>
          (await navigator.locks.query()).pending?.some(
            (lock) => lock.name === 'uml-refresh-session',
          ),
        ),
      )
      .toBe(true);
    release();
    await expect(sibling.getByTestId('lista-proyectos')).toBeVisible();
    await sibling.reload();
    await expect(sibling.getByTestId('lista-proyectos')).toBeVisible();
    expect(
      await sibling.evaluate(
        () => JSON.parse(localStorage.getItem('uml_offline_user_v1') ?? '{}').id,
      ),
    ).toBe(betoId);
  } finally {
    release();
    await sibling.close();
  }
});

test('un token de acceso vencido no retira la copia para abrir sin conexión', async ({
  page,
  request,
}) => {
  await enter(page);
  await create(page, 'Sobrevive');
  // Una renovación que no llega a completarse: es el caso que dejaba la pizarra
  // inabrible sin red aunque su instantánea siguiera intacta.
  await page.route('**/api/auth/refresh', (route) =>
    route.fulfill({ status: 503, json: { error: { message: 'Temporalmente no disponible' } } }),
  );
  await request.post('/test/close?reason=token-invalido');
  await expect(page.getByTestId('estado-conexion')).not.toHaveText('En vivo');
  expect(
    await page.evaluate(
      () =>
        Object.keys(localStorage).filter((key) => key.startsWith('uml_offline_board_v1:')).length,
    ),
  ).toBe(1);
  await page.context().setOffline(true);
  await page.reload();
  await expect(page.getByTestId('modo-offline')).toBeVisible();
  await expect(page.getByTestId('clase-Sobrevive')).toBeVisible();
});

test('un parpadeo de red no descarta el trabajo en curso de los paneles', async ({ page }) => {
  await enter(page);
  await create(page, 'Elegida');
  await page.getByTestId('pestana-importar').click();
  await expect(page.getByTestId('pestana-importar')).toHaveAttribute('aria-selected', 'true');
  await page.context().setOffline(true);
  await expect(page.getByTestId('modo-offline')).toBeVisible();
  await page.context().setOffline(false);
  await expect(page.getByTestId('estado-conexion')).toHaveText('En vivo');
  // El asistente y la importación guardan su conversación y su candidato en el
  // propio panel: cambiar de modo no puede remontarlos.
  await expect(page.getByTestId('pestana-importar')).toHaveAttribute('aria-selected', 'true');
  await expect(page.getByTestId('nombre-clase')).toHaveValue('Elegida');
});

for (const [path, field] of [
  ['/cuenta', 'perfil-nombre'],
  ['/proyectos', 'nombre-proyecto'],
] as const) {
  test(`conserva el formulario de ${path} durante una desconexión confirmada`, async ({ page }) => {
    await enter(page);
    await page.goto(path);
    const input = page.getByTestId(field);
    await input.fill('Trabajo sin guardar');
    await page.context().setOffline(true);
    await expect(page.getByTestId('aviso-sin-conexion')).toBeVisible();
    await expect(input).toHaveValue('Trabajo sin guardar');
    await page.context().setOffline(false);
    await expect(page.getByTestId('aviso-sin-conexion')).toHaveCount(0);
    await expect(input).toHaveValue('Trabajo sin guardar');
  });
}

test('una renovación temporalmente fallida permite editar offline y se recupera sin recargar', async ({
  page,
  request,
}) => {
  await enter(page);
  await page.route('**/api/auth/refresh', (route) =>
    route.fulfill({
      status: 503,
      json: { error: { message: 'Temporalmente no disponible' } },
    }),
  );
  await request.post('/test/close?reason=token-invalido');
  await expect(page.getByTestId('modo-offline')).toBeVisible();
  await create(page, 'DuranteRenovacion');
  await page.unroute('**/api/auth/refresh');
  // No se emite online: navigator.onLine fue true durante todo el fallo.
  await expect(page.getByTestId('estado-conexion')).toHaveText('En vivo');
  await expect(page.getByTestId('clase-DuranteRenovacion')).toBeVisible();
  await page.reload();
  await expect(page.getByTestId('clase-DuranteRenovacion')).toBeVisible();
});

test('autenticar como lector degrada la caché antes de completar la sincronización', async ({
  page,
  request,
}) => {
  await enter(page, 'beto');
  await request.post(`/test/role?id=${betoId}&role=VIEWER`);
  let authenticated = false;
  await page.routeWebSocket('**/collab', (ws) => {
    const server = ws.connectToServer();
    server.onMessage((message) => {
      if (typeof message !== 'string') {
        const decoder = createDecoder(message);
        readVarString(decoder);
        const type = readVarUint(decoder);
        // Hocuspocus: retrasar Sync y SyncStatus, dejando pasar Auth.
        if (type === 0 || type === 8) return;
        if (type === 2) authenticated = true;
      }
      ws.send(message);
    });
  });
  await page.reload();
  await expect.poll(() => authenticated).toBe(true);
  await expect
    .poll(() =>
      page.evaluate(() => {
        const key = Object.keys(localStorage).find((key) =>
          key.startsWith('uml_offline_board_v1:'),
        );
        return key === undefined ? null : JSON.parse(localStorage.getItem(key) ?? 'null')?.role;
      }),
    )
    .toBe('VIEWER');
  await page.context().setOffline(true);
  await expect(page.getByTestId('modo-offline')).toBeVisible();
  await expect(page.getByTestId('crear-clase')).toBeDisabled();
});

test('conserva edición offline si la sesión funciona pero la consulta de pizarra falla', async ({
  page,
}) => {
  await enter(page);
  await create(page, 'Guardada');
  let attempts = 0;
  await page.route(`**/api${board.replace('/pizarras/', '/boards/')}`, (route) => {
    attempts++;
    return route.fulfill({
      status: 503,
      json: { error: { message: 'Servicio de pizarras no disponible' } },
    });
  });
  await page.reload();
  await expect(page.getByTestId('modo-offline')).toBeVisible();
  await expect(page.getByTestId('clase-Guardada')).toBeVisible();
  await create(page, 'MientrasFalla');
  const countDrafts = () =>
    page.evaluate(
      () => Object.keys(localStorage).filter((key) => key.startsWith('uml_board_draft_v1:')).length,
    );
  const slots = await countDrafts();
  await expect.poll(() => attempts).toBeGreaterThanOrEqual(2);
  await create(page, 'TrasReintento');
  expect(await countDrafts()).toBe(slots);
  await page.unroute(`**/api${board.replace('/pizarras/', '/boards/')}`);
  await expect(page.getByTestId('estado-conexion')).toHaveText('En vivo');
  await page.reload();
  await expect(page.getByTestId('clase-MientrasFalla')).toBeVisible();
  await expect(page.getByTestId('clase-TrasReintento')).toBeVisible();
});

test('retira el indicador de disponibilidad si deja de poder guardar la instantánea', async ({
  page,
}) => {
  await enter(page);
  await page.evaluate(() => {
    const original = Storage.prototype.setItem;
    Storage.prototype.setItem = function (key, value) {
      if (key.startsWith('uml_board_snapshot_v1:'))
        throw new DOMException('Cuota agotada', 'QuotaExceededError');
      return original.call(this, key, value);
    };
  });
  await create(page, 'ProtegidaEnBorrador');
  await expect(page.getByTestId('aviso-permisos')).toContainText('No se pudo actualizar');
  await expect(page.getByTestId('offline-disponible')).toHaveCount(0);
});

test('recarga, cierra y abre offline, luego combina cambios con otro colaborador', async ({
  page,
  browser,
}) => {
  const errors: string[] = [];
  page.on('pageerror', (error) => errors.push(error.message));
  await enter(page);
  await create(page, 'Local');
  const other = await browser.newContext();
  const remote = await other.newPage();
  await enter(remote, 'beto');
  await expect(remote.getByTestId('clase-Local')).toBeVisible();
  await page.context().setOffline(true);
  await expect(page.getByTestId('modo-offline')).toBeVisible();
  await expect(page.getByTestId('nombre-clase')).toHaveValue('Local');
  await create(page, 'SinRed');
  await page.reload();
  await expect(page.getByTestId('clase-SinRed')).toBeVisible();
  await create(page, 'TrasRecargar');
  await expect(page.getByTestId('auditoria-pendiente')).toBeVisible();
  await create(remote, 'Remota');
  const context = page.context();
  await page.close();
  const reopened = await context.newPage();
  await reopened.goto(board);
  await expect(reopened.getByTestId('clase-TrasRecargar')).toBeVisible();
  await reopened.getByRole('link', { name: 'Ver pizarras guardadas' }).click();
  await expect(reopened.getByTestId('pizarras-offline')).toContainText('Pizarra 1');
  await reopened.getByRole('link', { name: 'Pizarra 1', exact: true }).click();
  await context.setOffline(false);
  await expect(reopened.getByTestId('estado-conexion')).toHaveText('En vivo');
  for (const name of ['Local', 'SinRed', 'TrasRecargar', 'Remota']) {
    await expect(reopened.getByTestId(`clase-${name}`)).toHaveCount(1);
    await expect(remote.getByTestId(`clase-${name}`)).toHaveCount(1);
  }
  await reopened.reload();
  await expect(reopened.getByTestId('clase-TrasRecargar')).toBeVisible();
  expect(errors).toEqual([]);
  const cachedUrls = await reopened.evaluate(async () => {
    const result: string[] = [];
    for (const key of await caches.keys())
      for (const request of await (await caches.open(key)).keys()) result.push(request.url);
    return result;
  });
  expect(cachedUrls.some((url) => /\/(api|collab)\//.test(url))).toBe(false);
  await other.close();
});

test('una pizarra visitada sin editar se abre offline; una no visitada no', async ({ page }) => {
  await enter(page);
  await page.context().setOffline(true);
  await page.reload();
  await expect(page.getByTestId('crear-clase')).toBeEnabled();
  await page.goto(secondBoard);
  await expect(page.getByRole('alert')).toContainText('no está disponible sin conexión');
});

test('un lector conserva la copia remota sin obtener permiso de edición offline', async ({
  page,
  request,
}) => {
  await request.post(`/test/role?id=${betoId}&role=VIEWER`);
  await enter(page, 'beto');
  await page.context().setOffline(true);
  await page.reload();
  await expect(page.getByTestId('crear-clase')).toBeDisabled();
  await expect(page.getByTestId('solo-lectura')).toBeVisible();
});

test('perder edición mientras está offline no publica el borrador al reconectar', async ({
  page,
  browser,
  request,
}) => {
  await enter(page, 'beto');
  await page.context().setOffline(true);
  await page.reload();
  await create(page, 'Pendiente');
  await request.post(`/test/role?id=${betoId}&role=VIEWER`);
  await page.context().setOffline(false);
  await expect(page.getByTestId('estado-conexion')).toHaveText('En vivo');
  await expect(page.getByTestId('crear-clase')).toBeDisabled();
  await expect(page.getByTestId('clase-Pendiente')).toHaveCount(0);
  const context = await browser.newContext();
  const owner = await context.newPage();
  await enter(owner);
  await expect(owner.getByTestId('clase-Pendiente')).toHaveCount(0);
  await page.context().setOffline(true);
  await page.reload();
  await expect(page.getByTestId('crear-clase')).toBeDisabled();
  await expect(page.getByTestId('clase-Pendiente')).toHaveCount(0);
  await page.context().setOffline(false);
  await request.post(`/test/role?id=${betoId}&role=EDITOR`);
  await page.reload();
  await expect(page.getByTestId('clase-Pendiente')).toBeVisible();
  await expect(owner.getByTestId('clase-Pendiente')).toBeVisible();
  await context.close();
});

test('salir offline impide que la cookie restaure la cuenta al recargar online', async ({
  page,
}) => {
  await enter(page);
  await page.goto(secondBoard);
  await expect(page.getByTestId('offline-disponible')).toBeVisible();
  await page.context().setOffline(true);
  await page.getByTestId('salir').click();
  await page.reload();
  await expect(page.getByTestId('email')).toBeVisible();
  await page.context().setOffline(false);
  await page.reload();
  await expect(page.getByTestId('email')).toBeVisible();
  await enter(page, 'beto');
  await page.context().setOffline(true);
  await page.goto('/sin-conexion');
  await expect(page.getByTestId('pizarras-offline').getByRole('link')).toHaveCount(1);
  await page.goto(secondBoard);
  await expect(page.getByRole('alert')).toContainText('no está disponible sin conexión');
});

test('revocar acceso invalida la entrada offline sin borrar el trabajo pendiente', async ({
  page,
  request,
}) => {
  await enter(page, 'beto');
  await page.context().setOffline(true);
  await create(page, 'Privada');
  await request.post(`/test/role?id=${betoId}&role=NONE`);
  await page.context().setOffline(false);
  await expect(page.getByRole('alert')).toContainText('Sin acceso');
  await page.context().setOffline(true);
  await page.reload();
  await expect(page.getByRole('alert')).toContainText('no está disponible sin conexión');
  expect(
    await page.evaluate(() =>
      Object.keys(localStorage).some((key) => key.startsWith('uml_board_draft_v1:')),
    ),
  ).toBe(true);
});

test('sesión vencida pide login y conserva los cambios para la misma cuenta', async ({
  page,
  request,
}) => {
  await enter(page, 'beto');
  await page.context().setOffline(true);
  await create(page, 'Conservar');
  await request.post(`/test/expire?id=${betoId}`);
  await page.context().setOffline(false);
  await expect(page.getByTestId('email')).toBeVisible();
  await enter(page, 'beto');
  await expect(page.getByTestId('clase-Conservar')).toBeVisible();
});

test('recupera borradores al recibir nuevamente edición sin recargar la pizarra', async ({
  page,
  request,
}) => {
  await enter(page, 'beto');
  await page.context().setOffline(true);
  await create(page, 'Recuperable');
  await request.post(`/test/role?id=${betoId}&role=VIEWER`);
  await page.context().setOffline(false);
  await expect(page.getByTestId('estado-conexion')).toHaveText('En vivo');
  await expect(page.getByTestId('crear-clase')).toBeDisabled();
  await expect(page.getByTestId('clase-Recuperable')).toHaveCount(0);
  await request.post(`/test/role?id=${betoId}&role=EDITOR`);
  await expect(page.getByTestId('crear-clase')).toBeEnabled();
  await expect(page.getByTestId('clase-Recuperable')).toBeVisible();
  await page.reload();
  await expect(page.getByTestId('clase-Recuperable')).toBeVisible();
});

test('un fallo del servidor al recargar permite editar la copia y reintenta al recuperarse', async ({
  page,
}) => {
  await enter(page);
  await create(page, 'ServidorCaido');
  await page.route('**/api/auth/refresh', (route) =>
    route.fulfill({ status: 503, json: { error: { message: 'Temporalmente no disponible' } } }),
  );
  await page.reload();
  await expect(page.getByTestId('modo-offline')).toBeVisible();
  await expect(page.getByTestId('clase-ServidorCaido')).toBeVisible();
  await create(page, 'DuranteFallo');
  await page.unroute('**/api/auth/refresh');
  await expect(page.getByTestId('estado-conexion')).toHaveText('En vivo');
  await page.reload();
  await expect(page.getByTestId('clase-DuranteFallo')).toBeVisible();
});
```

---

### `e2e/offline/playwright.config.ts`

```ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: '.',
  testMatch: '*.spec.ts',
  workers: 1,
  timeout: 60_000,
  expect: { timeout: 10_000 },
  use: { baseURL: 'http://127.0.0.1:4187', trace: 'retain-on-failure' },
  webServer: {
    command: 'npx tsx e2e/offline/server.ts',
    url: 'http://127.0.0.1:4187',
    reuseExistingServer: false,
    timeout: 30_000,
    cwd: '../..',
  },
});
```

---

### `e2e/offline/server.ts`

```ts
// Isolated browser-test fixture. Never imported by the application or deployment.
import { Server } from '@hocuspocus/server';
import { readFile } from 'node:fs/promises';
import { resolve, extname } from 'node:path';
import { seedDocument } from '@uml/yjs-adapter';
import * as Y from 'yjs';

const root = resolve('frontend/dist');
const users = {
  ana: { id: '00000000-0000-4000-8000-000000000001', email: 'ana@example.com', displayName: 'Ana' },
  beto: {
    id: '00000000-0000-4000-8000-000000000002',
    email: 'beto@example.com',
    displayName: 'Beto',
  },
};
const boards = ['00000000-0000-4000-8000-000000000010', '00000000-0000-4000-8000-000000000011'];
const roles = new Map<string, string>();
const sessions = new Set<string>();
const saved = new Map<string, Uint8Array>();
const server = new Server({
  address: '127.0.0.1',
  port: 4187,
  quiet: true,
  debounce: 0,
  async onAuthenticate(data) {
    if (!sessions.has(data.token) || roles.get(data.token) === 'NONE')
      throw new Error('sin-acceso-a-la-pizarra');
    data.connectionConfig.readOnly = roles.get(data.token) === 'VIEWER';
    return { userId: data.token };
  },
  async onStateless({ connection }) {
    const role = roles.get(connection.context.userId as string);
    if (role === undefined || role === 'NONE') return;
    const readOnly = role === 'VIEWER';
    if (connection.readOnly !== readOnly) {
      connection.readOnly = readOnly;
      connection.sendStateless(JSON.stringify({ type: 'access-changed', readOnly }));
    }
  },
  async onLoadDocument({ document, documentName }) {
    const state = saved.get(documentName);
    if (state) Y.applyUpdate(document, state);
    else seedDocument(document);
  },
  async onStoreDocument({ document, documentName }) {
    saved.set(documentName, Y.encodeStateAsUpdate(document));
  },
  async onRequest({ request, response }) {
    const url = new URL(request.url ?? '/', 'http://localhost:4187');
    const cookieId = /offline-test-session=([^;]+)/.exec(request.headers.cookie ?? '')?.[1];
    // Como en producción: la cookie solo renueva o cierra la sesión. Los datos
    // requieren acceso Bearer para ejercitar también la renovación tras un 401.
    const token = ['/api/auth/refresh', '/api/auth/logout'].includes(url.pathname)
      ? cookieId
      : request.headers.authorization?.replace('Bearer ', '');
    const user = Object.values(users).find((item) => item.id === token);
    const json = (value: unknown, status = 200): void => {
      response.writeHead(status, {
        'content-type': 'application/json',
        'cache-control': 'no-store',
      });
      response.end(JSON.stringify(value));
    };
    if (url.pathname === '/test/reset') {
      roles.clear();
      sessions.clear();
      saved.clear();
      for (const item of Object.values(users)) roles.set(item.id, 'EDITOR');
      json({ ok: true });
    } else if (url.pathname === '/test/role') {
      roles.set(url.searchParams.get('id') ?? '', url.searchParams.get('role') ?? 'VIEWER');
      json({ ok: true });
    } else if (url.pathname === '/test/expire') {
      sessions.delete(url.searchParams.get('id') ?? '');
      json({ ok: true });
    } else if (url.pathname === '/test/close') {
      // Así cierra el proceso real cuando caduca el token de acceso: la sala se
      // cierra con un motivo, sin tocar la sesión ni los permisos.
      const reason = url.searchParams.get('reason') ?? 'token-invalido';
      for (const document of server.hocuspocus.documents.values())
        for (const connection of document.getConnections())
          connection.close({ code: reason === 'token-invalido' ? 4401 : 4403, reason });
      json({ ok: true });
    } else if (url.pathname === '/api/auth/login') {
      let body = '';
      for await (const chunk of request) body += String(chunk);
      const input = JSON.parse(body) as { email: string };
      const account = Object.values(users).find((item) => item.email === input.email)!;
      sessions.add(account.id);
      response.setHeader(
        'set-cookie',
        `offline-test-session=${account.id}; HttpOnly; SameSite=Lax; Path=/`,
      );
      json({ accessToken: account.id, user: account });
    } else if (url.pathname === '/api/auth/logout') {
      if (token) sessions.delete(token);
      response.setHeader('set-cookie', 'offline-test-session=; Max-Age=0; Path=/');
      json({ ok: true });
    } else if (url.pathname.startsWith('/api/')) {
      if (!user || !token || !sessions.has(token))
        json({ error: { code: 'unauthorized', message: 'Sesión expirada' } }, 401);
      else if (url.pathname === '/api/auth/refresh') json({ accessToken: user.id, user });
      else if (url.pathname === '/api/auth/me') json(user);
      else if (url.pathname === '/api/projects') json([]);
      else if (/^\/api\/boards\/[^/]+$/.test(url.pathname)) {
        const id = url.pathname.split('/').pop()!;
        if (roles.get(token) === 'NONE') json({ error: { message: 'Sin acceso' } }, 403);
        else if (!boards.includes(id)) json({ error: { message: 'No existe' } }, 404);
        else
          json({
            id,
            projectId: 'project',
            displayName: `Pizarra ${boards.indexOf(id) + 1}`,
            room: id,
            role: roles.get(token),
          });
      } else if (url.pathname.endsWith('/audit')) json({ batchId: 'test' });
      else json([]);
    } else {
      const path = url.pathname === '/' || !extname(url.pathname) ? '/index.html' : url.pathname;
      const file = resolve(root, `.${path}`);
      if (!file.startsWith(root + '/') && !file.startsWith(root + '\\')) {
        response.writeHead(404);
        response.end();
      } else {
        const types: Record<string, string> = {
          '.html': 'text/html',
          '.js': 'text/javascript',
          '.css': 'text/css',
          '.svg': 'image/svg+xml',
          '.png': 'image/png',
          '.ttf': 'font/ttf',
        };
        try {
          const bytes = await readFile(file);
          response.writeHead(200, {
            'content-type': types[extname(file)] ?? 'application/octet-stream',
            'cache-control': 'no-cache',
          });
          response.end(bytes);
        } catch {
          response.writeHead(404);
          response.end();
        }
      }
    }
    // Hocuspocus's default HTTP handler must not write a second response.
    throw null;
  },
});
await server.listen();
```

---

### `e2e/specs/apariencia.spec.ts`

```ts
import { test, expect, type Page } from '@playwright/test';
import {
  registrarActor,
  crearProyecto,
  crearPizarra,
  abrirPizarra,
  crearClase,
} from '../support/actors.js';

async function chooseTheme(page: Page, theme: string): Promise<void> {
  await page.getByRole('button', { name: 'Apariencia', exact: true }).click();
  await page
    .getByRole('menuitemradio', {
      name: theme === 'dark' ? 'Oscuro' : theme === 'light' ? 'Claro' : 'Sistema',
      exact: true,
    })
    .click();
}

test('el menú de apariencia admite teclado, Escape y cierre al pulsar fuera', async ({ page }) => {
  await page.goto('/entrar');
  const trigger = page.getByRole('button', { name: 'Apariencia', exact: true });
  await trigger.focus();
  await trigger.press('ArrowDown');
  await expect(page.getByRole('menuitemradio', { name: 'Sistema', exact: true })).toBeFocused();
  await page.keyboard.press('Home');
  await page.keyboard.press('ArrowDown');
  await expect(page.getByRole('menuitemradio', { name: 'Oscuro', exact: true })).toBeFocused();
  await page.keyboard.press('Enter');
  await expect(trigger).toBeFocused();
  await expect(trigger).toHaveText('Oscuro');
  await trigger.click();
  await expect(page.getByRole('menuitemradio', { name: 'Oscuro', exact: true })).toHaveAttribute(
    'aria-checked',
    'true',
  );
  await page.screenshot({ path: 'reports/apariencia/menu-oscuro.png', animations: 'disabled' });
  await page.keyboard.press('Escape');
  await expect(trigger).toBeFocused();
  await expect(page.getByRole('menu')).toHaveCount(0);
  await trigger.click();
  await page.getByTestId('email').click();
  await expect(page.getByRole('menu')).toHaveCount(0);
});

test('claro, oscuro y sistema se conservan y se sincronizan sin perder el formulario', async ({
  page,
  context,
}) => {
  await page.emulateMedia({ colorScheme: 'light' });
  await page.goto('/entrar');
  const appearance = page.getByRole('button', { name: 'Apariencia', exact: true });
  await expect(appearance).toHaveText('Sistema');
  await expect(page.locator('html')).toHaveAttribute('data-theme', 'light');
  await page.getByTestId('email').fill('borrador@example.com');
  await chooseTheme(page, 'dark');
  await expect(page.locator('html')).toHaveAttribute('data-theme', 'dark');
  await expect(page.getByTestId('email')).toHaveValue('borrador@example.com');
  await page.reload();
  await expect(appearance).toHaveText('Oscuro');
  const other = await context.newPage();
  await other.goto('/entrar');
  await expect(other.getByRole('button', { name: 'Apariencia', exact: true })).toHaveText('Oscuro');
  await chooseTheme(page, 'light');
  await expect(other.locator('html')).toHaveAttribute('data-theme', 'light');
  await chooseTheme(page, 'system');
  await page.emulateMedia({ colorScheme: 'dark' });
  await expect(page.locator('html')).toHaveAttribute('data-theme', 'dark');
  await page.emulateMedia({ colorScheme: 'light' });
  await expect(page.locator('html')).toHaveAttribute('data-theme', 'light');
  await page.screenshot({
    path: 'reports/apariencia/acceso-claro.png',
    fullPage: true,
    animations: 'disabled',
  });
  await other.close();
});

test('el tema funciona con almacenamiento restringido', async ({ page }) => {
  await page.addInitScript(() => {
    Object.defineProperty(window, 'localStorage', {
      get() {
        throw new DOMException('Restringido', 'SecurityError');
      },
    });
  });
  await page.goto('/entrar');
  await chooseTheme(page, 'dark');
  await expect(page.locator('html')).toHaveAttribute('data-theme', 'dark');
  await expect(page.getByTestId('enviar')).toBeVisible();
});

test('el editor conserva su modelo al cambiar apariencia y no recorta las observaciones', async ({
  browser,
}) => {
  const actor = await registrarActor(browser, 'revision-visual');
  const { page } = actor;
  try {
    await page.setViewportSize({ width: 1440, height: 900 });
    await chooseTheme(page, 'light');
    await crearProyecto(actor, 'Estudio de arquitectura');
    await crearPizarra(actor, 'Modelo de ventas');
    await page.screenshot({
      path: 'reports/apariencia/proyecto-claro.png',
      fullPage: true,
      animations: 'disabled',
    });
    await abrirPizarra(actor, 'Modelo de ventas');
    await crearClase(actor, 'Cliente');
    const node = page.getByTestId('clase-Cliente');
    const id = await node.locator('..').getAttribute('data-id');
    for (const theme of ['light', 'dark', 'system']) {
      await chooseTheme(page, theme);
      await expect(node).toBeVisible();
      await expect(node.locator('..')).toHaveAttribute('data-id', id!);
      await expect(page.getByTestId('estado-conexion')).toHaveText('En vivo');
      const panel = page.getByTestId('panel-validacion');
      expect(await panel.evaluate((el) => el.scrollWidth <= el.clientWidth + 1)).toBe(true);
      if (theme !== 'system')
        await page.screenshot({
          path: `reports/apariencia/editor-${theme}.png`,
          fullPage: true,
          animations: 'disabled',
        });
    }
    for (const width of [320, 768, 1024]) {
      await page.setViewportSize({ width, height: 900 });
      await page.getByRole('button', { name: 'Ajustar diagrama a la vista', exact: true }).click();
      expect(
        await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth + 1),
      ).toBe(true);
      await expect(page.getByRole('button', { name: 'Apariencia', exact: true })).toBeVisible();
      await page.screenshot({
        path: `reports/apariencia/editor-${width}.png`,
        fullPage: true,
        animations: 'disabled',
      });
    }
    await page.reload();
    await expect(page.getByTestId('clase-Cliente')).toBeVisible();
  } finally {
    await actor.close();
  }
});
```

---

### `e2e/specs/aprendizaje-ia.spec.ts`

```ts
import { expect, test, type Page } from '@playwright/test';
import {
  abrirHerramienta,
  abrirPizarra,
  crearClase,
  crearPizarra,
  crearProyecto,
  registrarActor,
} from '../support/actors.js';

async function openGuide(page: Page) {
  await page.getByRole('button', { name: /Aprender a usar la IA|Repasar guía de IA/ }).click();
  const dialog = page.getByRole('dialog', { name: 'Aprende a usar el asistente' });
  await expect(dialog).toBeVisible();
  return dialog;
}

test('guía accesible, adaptable y offline: practicar no llama a IA ni modifica la pizarra', async ({
  browser,
}) => {
  const actor = await registrarActor(browser, 'aprendizaje');
  const { page } = actor;
  let calls = 0;
  await page.route('**/api/boards/*/assistant/**', async (route) => {
    calls++;
    await route.abort();
  });
  try {
    await crearProyecto(actor, 'Aprender IA');
    await crearPizarra(actor, 'Guía');
    await abrirPizarra(actor, 'Guía');
    await abrirHerramienta(actor, 'asistente');
    const dialog = await openGuide(page);
    await expect(dialog.getByRole('button', { name: 'Cerrar guía' })).toBeFocused();
    await page.keyboard.press('Escape');
    await expect(dialog).not.toBeVisible();
    await expect(page.getByRole('button', { name: 'Aprender a usar la IA' })).toBeFocused();
    await openGuide(page);
    // The lessons are bundled: no network or model is needed to learn.
    await page.context().setOffline(true);
    for (const width of [320, 768, 1024, 1440]) {
      await page.setViewportSize({ width, height: 800 });
      expect(await dialog.evaluate((element) => element.scrollWidth <= element.clientWidth)).toBe(
        true,
      );
      const box = await dialog.boundingBox();
      expect(box!.x).toBeGreaterThanOrEqual(0);
      expect(box!.x + box!.width).toBeLessThanOrEqual(width);
    }
    await dialog.getByRole('button', { name: 'Siguiente' }).click();
    await expect(dialog).toContainText('Crea una clase Cliente');
    await dialog.getByRole('button', { name: 'Siguiente' }).click();
    await expect(dialog.getByRole('heading', { name: 'También puedes dictar' })).toBeVisible();
    await dialog.getByRole('button', { name: 'Siguiente' }).click();
    await expect(dialog.getByRole('button', { name: 'Completar guía' })).toBeDisabled();
    await dialog
      .getByRole('radio', { name: 'Aplicar sin revisar porque lo propuso la IA.' })
      .check();
    await expect(dialog.getByRole('status')).toContainText('Antes de aplicar');
    await expect(dialog.getByRole('button', { name: 'Completar guía' })).toBeDisabled();
    await dialog
      .getByRole('radio', { name: 'Revisar lo que se borrará y aplicar solo si es lo que pedí.' })
      .check();
    await expect(dialog.getByRole('status')).toContainText('Correcto');
    await dialog.getByRole('button', { name: 'Completar guía' }).click();
    await expect(dialog).not.toBeVisible();
    await expect(page.locator('.react-flow__node')).toHaveCount(0);
    await expect(page.getByTestId('entrada-asistente')).toHaveValue('');
    expect(calls).toBe(0);
    await page.context().setOffline(false);
    await page.reload();
    await abrirHerramienta(actor, 'asistente');
    await expect(page.getByRole('button', { name: 'Repasar guía de IA' })).toBeVisible();
  } finally {
    await actor.close();
  }
});

test('ejemplos contextuales conservan borradores y aclaraciones y requieren envío explícito', async ({
  browser,
}) => {
  const actor = await registrarActor(browser, 'ejemplo-ia');
  const { page } = actor;
  const calls: unknown[] = [];
  await page.route('**/api/boards/*/assistant/**', async (route) => {
    calls.push(route.request().postDataJSON());
    await route.fulfill({
      json: { kind: 'QUESTION', question: '¿Qué longitud quieres?', rationale: null },
    });
  });
  try {
    await crearProyecto(actor, 'Ejemplos');
    await crearPizarra(actor, 'Contexto');
    await abrirPizarra(actor, 'Contexto');
    await crearClase(actor, 'Producto');
    await abrirHerramienta(actor, 'asistente');
    const input = page.getByTestId('entrada-asistente');
    await input.fill('Mi borrador importante');
    const dialog = await openGuide(page);
    await expect(dialog.getByRole('button', { name: 'Usar ejemplo como borrador' })).toBeDisabled();
    await dialog.getByRole('button', { name: 'Cerrar guía' }).click();
    await expect(input).toHaveValue('Mi borrador importante');
    await input.fill('');
    await openGuide(page);
    await dialog.getByRole('button', { name: 'Usar ejemplo como borrador' }).click();
    await expect(input).toHaveValue('¿Qué clases hay en el diagrama y cómo se relacionan?');
    await expect(input).toBeFocused();
    await expect(page.getByTestId('modo-preguntar')).toHaveClass('activa');
    expect(calls).toHaveLength(0);
    await input.fill('');
    await openGuide(page);
    await dialog.getByRole('button', { name: 'Siguiente' }).click();
    await expect(dialog).toContainText(
      'Agrega el atributo notaIA de tipo String a la clase Producto.',
    );
    await dialog.getByRole('button', { name: 'Usar ejemplo como borrador' }).click();
    await expect(page.getByTestId('modo-instruir')).toHaveClass('activa');
    await expect(input).toHaveValue(
      'Agrega el atributo notaIA de tipo String a la clase Producto.',
    );
    await expect(page.getByTestId('clase-Producto')).not.toContainText('notaIA');
    expect(calls).toHaveLength(0);
    await page.getByTestId('enviar-asistente').click();
    await expect(page.getByTestId('contexto-asistente')).toBeVisible();
    await openGuide(page);
    await expect(dialog.getByRole('button', { name: 'Usar ejemplo como borrador' })).toBeDisabled();
    await expect(dialog).toContainText('aclaración en curso');
    expect(calls).toHaveLength(1);
  } finally {
    await actor.close();
  }
});
```

---

### `e2e/specs/auditoria-regresiones.spec.ts`

```ts
import { expect, test } from '@playwright/test';
import { resolveProposal } from '@uml/ai';
import { serializeToXmi } from '@uml/xmi';
import { abrirHerramienta, crearClase } from '../support/actors.js';
import { montarEscenario, type EscenarioCompartido } from '../support/escenario.js';

async function permisos(escenario: EscenarioCompartido, role: 'VIEWER' | 'EDITOR'): Promise<void> {
  const client = escenario.ana.page.request;
  const login = await client.post('/api/auth/login', {
    data: { email: escenario.ana.email, password: 'contrasena-de-prueba' },
  });
  expect(login.ok()).toBe(true);
  const { accessToken } = await login.json();
  const headers = { authorization: `Bearer ${accessToken}` };
  const boardId = new URL(escenario.ana.page.url()).pathname.split('/').pop();
  const board = await (await client.get(`/api/boards/${boardId}`, { headers })).json();
  const members = (await (
    await client.get(`/api/projects/${board.projectId}/members`, { headers })
  ).json()) as { id: string; email: string }[];
  const member = members.find((user) => user.email === escenario.beto.email)!;
  const response = await client.patch(`/api/projects/${board.projectId}/members/${member.id}`, {
    headers,
    data: { role },
  });
  expect(response.ok()).toBe(true);
}

test('actualiza permisos de participantes inactivos y permite recuperar el rol editor', async ({
  browser,
}) => {
  const escenario = await montarEscenario(browser, 'Permisos vivos');
  try {
    await crearClase(escenario.ana, 'Cliente');
    await expect(escenario.beto.page.getByTestId('clase-Cliente')).toBeVisible();
    await permisos(escenario, 'VIEWER');
    await expect(escenario.beto.page.getByTestId('crear-clase')).toBeDisabled();
    await expect(escenario.beto.page.getByTestId('solo-lectura')).toBeVisible();
    await expect(escenario.beto.page.getByTestId('aviso-permisos')).toContainText(
      'no se enviará sin permiso de edición',
    );
    await expect(escenario.beto.page.getByTestId('clase-Cliente')).toBeVisible();
    await permisos(escenario, 'EDITOR');
    await expect(escenario.beto.page.getByTestId('crear-clase')).toBeEnabled();
    await crearClase(escenario.beto, 'Producto');
    await expect(escenario.ana.page.getByTestId('clase-Producto')).toBeVisible();
  } finally {
    await escenario.cerrar();
  }
});

test('al reconectar como lector descarta cambios rechazados sin reintroducirlos en Yjs', async ({
  browser,
}) => {
  const escenario = await montarEscenario(browser, 'Permisos sin red');
  try {
    await crearClase(escenario.ana, 'Cliente');
    await expect(escenario.beto.page.getByTestId('clase-Cliente')).toBeVisible();
    await escenario.beto.page.context().setOffline(true);
    await expect(escenario.beto.page.getByTestId('estado-conexion')).toHaveText('Sin conexión');
    await crearClase(escenario.beto, 'Fantasma');
    await expect(escenario.beto.page.getByTestId('clase-Fantasma')).toBeVisible();
    await permisos(escenario, 'VIEWER');
    await escenario.beto.page.context().setOffline(false);
    await expect(escenario.beto.page.getByTestId('crear-clase')).toBeDisabled();
    await expect(escenario.beto.page.getByTestId('estado-conexion')).toHaveText('En vivo');
    await expect(escenario.beto.page.getByTestId('clase-Cliente')).toBeVisible();
    await expect(escenario.beto.page.getByTestId('clase-Fantasma')).toHaveCount(0);
    await expect(escenario.ana.page.getByTestId('clase-Fantasma')).toHaveCount(0);
    await escenario.beto.page.reload();
    await expect(escenario.beto.page.getByTestId('estado-conexion')).toHaveText('En vivo');
    await expect(escenario.beto.page.getByTestId('clase-Fantasma')).toHaveCount(0);
  } finally {
    await escenario.cerrar();
  }
});

test('una propuesta antigua no borra el atributo añadido por otro colaborador', async ({
  browser,
}) => {
  const escenario = await montarEscenario(browser, 'Propuesta desactualizada');
  try {
    await crearClase(escenario.ana, 'Cliente');
    await expect(escenario.beto.page.getByTestId('clase-Cliente')).toBeVisible();
    await escenario.ana.page.route('**/api/boards/*/assistant/instruction', async (route) => {
      const { model } = route.request().postDataJSON();
      const outcome = resolveProposal({
        model,
        actorId: '11111111-1111-4111-8111-111111111111',
        origin: 'AI_TEXT',
        proposal: { operations: [{ op: 'DELETE_CLASS', className: 'Cliente' }] },
      });
      await route.fulfill({ json: { ...outcome, rationale: null } });
    });
    await abrirHerramienta(escenario.ana, 'asistente');
    await escenario.ana.page.getByTestId('entrada-asistente').fill('elimina Cliente');
    await escenario.ana.page.getByTestId('enviar-asistente').click();
    await expect(escenario.ana.page.getByTestId('aplicar-propuesta')).toBeVisible();
    await escenario.beto.page.getByTestId('clase-Cliente').click();
    await escenario.beto.page.getByTestId('nuevo-atributo').fill('datoNuevo');
    await escenario.beto.page.getByRole('button', { name: 'Añadir', exact: true }).click();
    await expect(escenario.ana.page.getByTestId('clase-Cliente')).toContainText('datoNuevo');
    await escenario.ana.page.getByTestId('aplicar-propuesta').click();
    await expect(escenario.ana.page.getByTestId('propuesta-obsoleta')).toBeVisible();
    await expect(escenario.ana.page.getByTestId('entrada-asistente')).toHaveValue(
      'elimina Cliente',
    );
    await expect(escenario.ana.page.getByTestId('clase-Cliente')).toContainText('datoNuevo');
    await expect(escenario.beto.page.getByTestId('clase-Cliente')).toContainText('datoNuevo');
  } finally {
    await escenario.cerrar();
  }
});

test('el candidato XMI permite corregir nombres que colisionan antes de aplicarlo', async ({
  browser,
}) => {
  const escenario = await montarEscenario(browser, 'Colisión editable');
  try {
    const xml = serializeToXmi(
      {
        classes: ['Detalle de Venta', 'detalle venta'].map((displayName) => ({
          id: crypto.randomUUID(),
          displayName,
          codeName: 'DetalleVenta',
          databaseName: 'detalle_venta',
          attributes: [],
        })),
        relationships: [],
      },
      { modelName: 'Colision' },
    );
    await abrirHerramienta(escenario.ana, 'importar');
    await escenario.ana.page.getByTestId('archivo-xmi').setInputFiles({
      name: 'colision.xmi',
      mimeType: 'application/xml',
      buffer: Buffer.from(xml),
    });
    await expect(escenario.ana.page.getByTestId('aplicar-candidato')).toBeVisible();
    const names = escenario.ana.page.getByTestId('candidato').getByRole('textbox');
    await expect(names).toHaveCount(2);
    await names.nth(1).fill('Detalle de Compra');
    await escenario.ana.page.getByTestId('aplicar-candidato').click();
    await expect(escenario.beto.page.getByTestId('clase-DetalleVenta')).toBeVisible();
    await expect(escenario.beto.page.getByTestId('clase-DetalleCompra')).toBeVisible();
  } finally {
    await escenario.cerrar();
  }
});
```

---

### `e2e/specs/ayuda-software.spec.ts`

```ts
import { expect, test } from '@playwright/test';
import {
  abrirHerramienta,
  abrirPizarra,
  crearClase,
  crearPizarra,
  crearProyecto,
  registrarActor,
} from '../support/actors.js';

test('ayuda desde proyectos: busca dudas, recuerda progreso y funciona sin solicitudes', async ({
  page,
}) => {
  const errors: string[] = [];
  page.on('pageerror', (error) => errors.push(error.message));
  let writes = 0;
  const user = {
    id: '33333333-3333-4333-8333-333333333333',
    email: 'help@example.com',
    displayName: 'Ayuda',
  };
  await page.route('**/api/**', async (route) => {
    const path = new URL(route.request().url()).pathname;
    if (path.endsWith('/auth/refresh'))
      await route.fulfill({ json: { accessToken: 'test-token', user } });
    else if (path.endsWith('/auth/me')) await route.fulfill({ json: user });
    else {
      if (route.request().method() !== 'GET') writes++;
      await route.fulfill({ json: [] });
    }
  });
  await page.goto('/proyectos');
  await page.getByRole('button', { name: 'Aprender a usar el software' }).click();
  const dialog = page.getByRole('dialog', { name: 'Aprende a usar el software' });
  await expect(
    dialog.getByRole('heading', { name: '¿Cómo empiezo mi primer diagrama?' }),
  ).toBeVisible();
  await expect(dialog.getByRole('button', { name: 'Cerrar ayuda del software' })).toBeFocused();
  await page.keyboard.press('Escape');
  await expect(dialog).not.toBeVisible();
  await expect(page.getByRole('button', { name: 'Aprender a usar el software' })).toBeFocused();
  await page.getByRole('button', { name: 'Aprender a usar el software' }).click();
  await page.context().setOffline(true);
  await dialog.getByRole('checkbox', { name: 'Marcar este tema como leído' }).check();
  await expect(dialog.getByText('1 de 9 temas leídos')).toBeVisible();
  await dialog.getByRole('button', { name: 'Continuar recorrido' }).click();
  await expect(
    dialog.getByRole('heading', { name: '¿Cómo dibujo una clase y añado sus campos?' }),
  ).toBeVisible();
  await dialog.getByRole('searchbox').fill('¿Cómo invito a alguien?');
  await dialog.getByRole('button', { name: 'Invitar y colaborar' }).click();
  await expect(
    dialog.getByRole('heading', { name: '¿Cómo invito a alguien y qué puede hacer?' }),
  ).toBeVisible();
  await dialog.getByRole('searchbox').fill('astrofisica');
  await expect(dialog.getByText('No encontré un tema', { exact: false })).toBeVisible();
  await dialog.getByRole('button', { name: 'Ver todos los temas' }).click();
  for (const width of [320, 768, 1024, 1440]) {
    await page.setViewportSize({ width, height: 800 });
    expect(await dialog.evaluate((element) => element.scrollWidth <= element.clientWidth)).toBe(
      true,
    );
    const box = await dialog.boundingBox();
    expect(box!.x).toBeGreaterThanOrEqual(0);
    expect(box!.x + box!.width).toBeLessThanOrEqual(width);
  }
  expect(writes).toBe(0);
  await page.context().setOffline(false);
  await page.reload();
  await page.getByRole('button', { name: 'Aprender a usar el software' }).click();
  await expect(dialog.getByText('1 de 9 temas leídos')).toBeVisible();
  await dialog.getByRole('button', { name: 'Reiniciar progreso' }).click();
  await expect(dialog.getByText('0 de 9 temas leídos')).toBeVisible();
  expect(errors).toEqual([]);
});

test('ayuda contextual en editor respeta el diagrama, los atajos y el borrador de IA', async ({
  browser,
}) => {
  const actor = await registrarActor(browser, 'ayuda-editor');
  const { page } = actor;
  try {
    await crearProyecto(actor, 'Ayuda del editor');
    await crearPizarra(actor, 'Aprender');
    await abrirPizarra(actor, 'Aprender');
    await crearClase(actor, 'Cliente');
    await abrirHerramienta(actor, 'asistente');
    await page.getByTestId('entrada-asistente').fill('Conservar este borrador');
    await page.getByRole('button', { name: 'Aprender a usar el software' }).click();
    const dialog = page.getByRole('dialog', { name: 'Aprende a usar el software' });
    await expect(
      dialog.getByRole('heading', { name: '¿Cómo dibujo una clase y añado sus campos?' }),
    ).toBeVisible();
    await page.keyboard.press('Delete');
    await page.keyboard.press('Escape');
    await expect(dialog).not.toBeVisible();
    await expect(page.getByTestId('clase-Cliente')).toBeVisible();
    await expect(page.getByTestId('entrada-asistente')).toHaveValue('Conservar este borrador');
    for (const width of [320, 768, 1440]) {
      await page.setViewportSize({ width, height: 900 });
      const help = page.getByRole('button', { name: 'Aprender a usar el software' });
      await expect(help).toBeVisible();
      const box = await help.boundingBox();
      expect(box!.x).toBeGreaterThanOrEqual(0);
      expect(box!.x + box!.width).toBeLessThanOrEqual(width);
      await help.click();
      await expect(dialog).toBeVisible();
      await dialog.getByRole('button', { name: 'Cerrar ayuda del software' }).click();
    }
    await abrirHerramienta(actor, 'generar');
    await page.getByRole('button', { name: 'Aprender a usar el software' }).click();
    await expect(
      dialog.getByRole('heading', { name: '¿Cómo descargo el backend o la aplicación Android?' }),
    ).toBeVisible();
    await expect(dialog).toContainText('no es una APK lista para instalar');
    await dialog.getByRole('button', { name: 'Cerrar ayuda del software' }).click();
    await abrirHerramienta(actor, 'importar');
    await page.getByRole('button', { name: 'Aprender a usar el software' }).click();
    await expect(
      dialog.getByRole('heading', { name: '¿Cómo recupero un diagrama desde XMI o una imagen?' }),
    ).toBeVisible();
  } finally {
    await actor.close();
  }
});

test('la ayuda permite seguir leyendo cuando el navegador bloquea guardar progreso', async ({
  page,
}) => {
  await page.addInitScript(() => {
    const original = Storage.prototype.setItem;
    Storage.prototype.setItem = function (key, value) {
      if (key === 'uml.software-learning.v1') throw new DOMException('Bloqueado', 'SecurityError');
      original.call(this, key, value);
    };
  });
  const user = {
    id: '33333333-3333-4333-8333-333333333333',
    email: 'help@example.com',
    displayName: 'Ayuda',
  };
  await page.route('**/api/**', async (route) => {
    const path = new URL(route.request().url()).pathname;
    await route.fulfill({
      json: path.endsWith('/auth/refresh')
        ? { accessToken: 'test-token', user }
        : path.endsWith('/auth/me')
          ? user
          : [],
    });
  });
  await page.goto('/proyectos');
  await page.getByRole('button', { name: 'Aprender a usar el software' }).click();
  const dialog = page.getByRole('dialog', { name: 'Aprende a usar el software' });
  await dialog.getByRole('checkbox', { name: 'Marcar este tema como leído' }).check();
  await expect(dialog).toContainText('El navegador no permite guardar el progreso');
  await dialog.getByRole('button', { name: 'Tema siguiente' }).click();
  await expect(
    dialog.getByRole('heading', { name: '¿Cómo dibujo una clase y añado sus campos?' }),
  ).toBeVisible();
});
```

---

### `e2e/specs/borradores.spec.ts`

```ts
import { expect, test } from '@playwright/test';
import { crearClase } from '../support/actors.js';
import { montarEscenario } from '../support/escenario.js';

test('recupera una edicion offline tras cerrar la pestaña y la combina con cambios remotos', async ({
  browser,
}) => {
  const scenario = await montarEscenario(browser, 'Borradores offline');
  const context = scenario.ana.page.context();
  try {
    await crearClase(scenario.ana, 'Cliente');
    await expect(scenario.beto.page.getByTestId('clase-Cliente')).toBeVisible();
    await expect(scenario.ana.page.getByTestId('offline-disponible')).toBeVisible();
    const url = scenario.ana.page.url();
    await context.setOffline(true);
    await expect(scenario.ana.page.getByTestId('estado-conexion')).toHaveText('Sin conexión');
    await scenario.ana.page.getByTestId('nuevo-atributo').fill('telefono');
    await scenario.ana.page.getByRole('button', { name: 'Añadir', exact: true }).click();
    await expect(scenario.ana.page.getByTestId('clase-Cliente')).toContainText('telefono');
    await expect(scenario.beto.page.getByTestId('clase-Cliente')).not.toContainText('telefono');
    // Close while offline, so reconnection cannot rescue an in-memory document.
    await scenario.ana.page.close();
    await scenario.beto.page.getByTestId('clase-Cliente').click();
    await scenario.beto.page.getByTestId('nuevo-atributo').fill('correo');
    await scenario.beto.page.getByRole('button', { name: 'Añadir', exact: true }).click();
    const reopened = await context.newPage();
    await reopened.goto(url);
    await expect(reopened.getByTestId('clase-Cliente')).toContainText('telefono');
    await expect(reopened.getByTestId('modo-offline')).toBeVisible();
    await reopened.reload();
    await expect(reopened.getByTestId('clase-Cliente')).toContainText('telefono');
    await context.setOffline(false);
    await expect(reopened.getByTestId('estado-conexion')).toHaveText('En vivo');
    for (const page of [reopened, scenario.beto.page]) {
      await expect(page.getByTestId('clase-Cliente')).toContainText('telefono');
      await expect(page.getByTestId('clase-Cliente')).toContainText('correo');
      await expect(page.getByTestId('clase-Cliente').locator('.atributos > li')).toHaveCount(2);
    }
    await reopened.reload();
    await expect(reopened.getByTestId('clase-Cliente').locator('.atributos > li')).toHaveCount(2);
  } finally {
    await context.setOffline(false);
    await scenario.cerrar();
  }
});
```

---

### `e2e/specs/carga.spec.ts`

```ts
import { expect, test } from '@playwright/test';
import type { SemanticModel } from '@uml/contracts';
import { serializeToXmi } from '@uml/xmi';
import { abrirHerramienta, posicionEnDiagrama } from '../support/actors.js';
import { montarEscenario } from '../support/escenario.js';

test('RNF-03 — edita y sincroniza una pizarra de 30 clases, 100 atributos y 40 relaciones', async ({
  browser,
}, testInfo) => {
  const escenario = await montarEscenario(browser, 'Carga del editor');
  try {
    const classes: SemanticModel['classes'] = Array.from({ length: 30 }, (_, index) => ({
      id: crypto.randomUUID(),
      displayName: `Entidad${index}`,
      codeName: `Entidad${index}`,
      databaseName: `entidad_${index}`,
      attributes: Array.from({ length: index < 10 ? 4 : 3 }, (_, attribute) => ({
        id: crypto.randomUUID(),
        displayName: `campo${attribute}`,
        codeName: `campo${attribute}`,
        databaseName: `campo_${attribute}`,
        type: 'String',
        nullable: true,
        primaryKey: false,
        unique: false,
      })),
    }));
    const model: SemanticModel = {
      classes,
      relationships: Array.from({ length: 40 }, (_, index) => ({
        id: crypto.randomUUID(),
        sourceClassId: classes[index % 30]!.id,
        targetClassId: classes[((index % 30) + (index < 30 ? 1 : 2)) % 30]!.id,
        sourceMultiplicity: '0..1',
        targetMultiplicity: '0..*',
        sourceRoleName: `origen${index}`,
        targetRoleName: `destino${index}`,
      })),
    };
    await abrirHerramienta(escenario.ana, 'importar');
    await escenario.ana.page.getByTestId('archivo-xmi').setInputFiles({
      name: 'carga.xmi',
      mimeType: 'application/xml',
      buffer: Buffer.from(serializeToXmi(model, { modelName: 'Carga' })),
    });
    await expect(escenario.ana.page.getByTestId('candidato')).toBeVisible();
    const started = performance.now();
    await escenario.ana.page.getByTestId('aplicar-candidato').click();
    await expect(escenario.beto.page.locator('.react-flow__node')).toHaveCount(30);
    await expect(escenario.beto.page.locator('.react-flow__edge')).toHaveCount(40);
    const importedMs = performance.now() - started;
    const before = await posicionEnDiagrama(escenario.beto, 'Entidad0');
    const node = escenario.ana.page.locator('.react-flow__node', {
      has: escenario.ana.page.getByTestId('clase-Entidad0'),
    });
    await node.focus();
    // El foco permite recorrer nodos; Enter selecciona el que moveran las flechas.
    await escenario.ana.page.keyboard.press('Enter');
    await expect(node).toHaveClass(/selected/);
    const movedAt = performance.now();
    await escenario.ana.page.keyboard.press('ArrowRight');
    await expect.poll(() => posicionEnDiagrama(escenario.beto, 'Entidad0')).not.toEqual(before);
    const propagatedMs = performance.now() - movedAt;
    expect(propagatedMs).toBeLessThan(2000);
    await testInfo.attach('medicion-local', {
      body: JSON.stringify({
        classes: 30,
        attributes: 100,
        relationships: 40,
        importedMs,
        propagatedMs,
      }),
      contentType: 'application/json',
    });
    await escenario.ana.page.getByRole('button', { name: 'Ajustar diagrama a la vista' }).click();
    await escenario.ana.page.screenshot({
      path: testInfo.outputPath('editor-30-clases.png'),
      fullPage: true,
    });
    await escenario.ana.page.setViewportSize({ width: 820, height: 720 });
    await escenario.ana.page.screenshot({
      path: testInfo.outputPath('editor-820px.png'),
      fullPage: true,
    });
  } finally {
    await escenario.cerrar();
  }
});
```

---

### `e2e/specs/colaboracion-concurrente.spec.ts`

```ts
import { expect, test } from '@playwright/test';
import { crearClase } from '../support/actors.js';
import { montarEscenario } from '../support/escenario.js';

test('conserva atributos concurrentes de la misma clase al reconectar y recargar', async ({
  browser,
}, testInfo) => {
  const escenario = await montarEscenario(browser, 'Atributos concurrentes');
  const { ana, beto } = escenario;
  const contextoAna = ana.page.context();
  let sinConexion = false;

  try {
    await crearClase(ana, 'Cliente');
    await expect(beto.page.getByTestId('clase-Cliente')).toBeVisible();
    await beto.page.getByTestId('clase-Cliente').click();

    // La desconexion garantiza que ninguno parte del atributo nuevo del otro;
    // dos clics casi simultaneos en loopback no garantizan esa concurrencia.
    await contextoAna.setOffline(true);
    sinConexion = true;
    await expect(ana.page.getByTestId('estado-conexion')).toHaveText('Sin conexión');
    await ana.page.getByTestId('nuevo-atributo').fill('telefono');
    await ana.page.getByRole('button', { name: 'Añadir', exact: true }).click();
    await beto.page.getByTestId('nuevo-atributo').fill('correo');
    await beto.page.getByRole('button', { name: 'Añadir', exact: true }).click();
    await expect(ana.page.getByTestId('clase-Cliente')).toContainText('telefono');
    await expect(beto.page.getByTestId('clase-Cliente')).toContainText('correo');
    await expect(ana.page.getByTestId('clase-Cliente').locator('.atributos > li')).toHaveCount(1);
    await expect(beto.page.getByTestId('clase-Cliente').locator('.atributos > li')).toHaveCount(1);

    await contextoAna.setOffline(false);
    sinConexion = false;
    for (const actor of [ana, beto]) {
      await expect(actor.page.getByTestId('estado-conexion')).toHaveText('En vivo');
      const clase = actor.page.getByTestId('clase-Cliente');
      await expect(clase.locator('.atributos > li')).toHaveCount(2);
      await expect(clase).toContainText('telefono');
      await expect(clase).toContainText('correo');
    }

    const orden = await ana.page
      .getByTestId('clase-Cliente')
      .locator('.atributos > li')
      .allTextContents();
    // Recargar destruye ambas replicas del navegador y abre documentos nuevos.
    // La rehidratacion desde PostgreSQL se comprueba ademas en integracion RA-11.
    await Promise.all([ana.page.reload(), beto.page.reload()]);
    for (const actor of [ana, beto]) {
      await expect(actor.page.getByTestId('estado-conexion')).toHaveText('En vivo');
      await expect(actor.page.getByTestId('clase-Cliente').locator('.atributos > li')).toHaveText(
        orden,
      );
      await actor.page.screenshot({ path: testInfo.outputPath(`${actor.displayName}.png`) });
    }
  } finally {
    if (sinConexion) await contextoAna.setOffline(false);
    await escenario.cerrar();
  }
});
```

---

### `e2e/specs/colaboracion-xmi-completa.spec.ts`

```ts
import { readFile } from 'node:fs/promises';
import { expect, test } from '@playwright/test';
import { parseXmi } from '@uml/xmi';
import { abrirHerramienta, crearClase, invitar, posicionEnDiagrama } from '../support/actors.js';
import { montarEscenario } from '../support/escenario.js';

test('retirar a un participante también cierra su página de proyecto abierta', async ({
  browser,
}) => {
  const scenario = await montarEscenario(browser, 'Retirada desde proyecto', { abrirAmbos: false });
  try {
    await scenario.ana.page.getByTitle('Volver al proyecto', { exact: true }).click();
    await scenario.ana.page.getByTestId('alternar-colaboradores').click();
    scenario.ana.page.once('dialog', (dialog) => dialog.accept());
    await scenario.ana.page
      .getByRole('button', { name: `Retirar a ${scenario.beto.email}`, exact: true })
      .click();
    await expect(scenario.beto.page.getByTestId('lista-proyectos')).toBeVisible();
    await expect(
      scenario.beto.page.getByRole('link', { name: 'Retirada desde proyecto', exact: true }),
    ).toHaveCount(0);
  } finally {
    await scenario.cerrar();
  }
});

test('un participante puede salir del proyecto y desaparece de la lista del propietario', async ({
  browser,
}) => {
  const scenario = await montarEscenario(browser, 'Salida voluntaria', { abrirAmbos: false });
  try {
    await scenario.beto.page.getByTestId('alternar-colaboradores').click();
    scenario.beto.page.once('dialog', (dialog) => dialog.accept());
    await scenario.beto.page
      .getByRole('button', { name: 'Salir del proyecto', exact: true })
      .click();
    await expect(scenario.beto.page.getByTestId('lista-proyectos')).toBeVisible();
    await expect(
      scenario.beto.page.getByRole('link', { name: 'Salida voluntaria', exact: true }),
    ).toHaveCount(0);
    await scenario.ana.page.getByTitle('Volver al proyecto', { exact: true }).click();
    await expect(scenario.ana.page.getByTestId('miembros-proyecto')).toContainText(
      scenario.ana.email,
    );
    await expect(scenario.ana.page.getByText(scenario.beto.email, { exact: true })).toHaveCount(0);
  } finally {
    await scenario.cerrar();
  }
});

test('administra roles, revoca invitaciones y retira acceso desde la interfaz', async ({
  browser,
}) => {
  const scenario = await montarEscenario(browser, 'Administración completa');
  const { ana, beto } = scenario;
  try {
    await ana.page.getByTitle('Volver al proyecto', { exact: true }).click();
    await ana.page.getByTestId('alternar-colaboradores').click();
    const role = ana.page.getByRole('combobox', { name: `Rol de ${beto.email}`, exact: true });
    await role.selectOption('VIEWER');
    await expect(beto.page.getByTestId('crear-clase')).toBeDisabled();
    await expect(role).toBeEnabled();
    await role.selectOption('EDITOR');
    await expect(beto.page.getByTestId('crear-clase')).toBeEnabled();
    await crearClase(beto, 'Compartida');
    const code = await invitar(ana, 'lector');
    await ana.page.getByRole('button', { name: `Revocar invitación ${code}`, exact: true }).click();
    await expect(ana.page.getByTestId('codigo-generado')).toHaveCount(0);
    await expect(
      ana.page.getByRole('button', { name: `Revocar invitación ${code}`, exact: true }),
    ).toHaveCount(0);
    ana.page.once('dialog', (dialog) => dialog.accept());
    await ana.page.getByRole('button', { name: `Retirar a ${beto.email}`, exact: true }).click();
    await expect(ana.page.getByText(beto.email, { exact: true })).toHaveCount(0);
    await expect(beto.page.getByTestId('crear-clase')).toBeDisabled();
    await beto.page.reload();
    await expect(beto.page.getByRole('alert')).toBeVisible();
    await expect(beto.page.getByTestId('clase-Compartida')).toHaveCount(0);
  } finally {
    await scenario.cerrar();
  }
});

test('edita extremos, roles y tipo del candidato y elimina operaciones dependientes', async ({
  browser,
}) => {
  const scenario = await montarEscenario(browser, 'Candidato completo');
  const { ana, beto } = scenario;
  try {
    const xml = `<xmi:XMI xmlns:xmi="x" xmlns:uml="u"><uml:Model name="Prueba">
      <packagedElement xmi:type="uml:Class" xmi:id="a" name="Cliente"><ownedAttribute xmi:id="at" name="correo" type="String"/></packagedElement>
      <packagedElement xmi:type="uml:Class" xmi:id="b" name="Pedido"/>
      <packagedElement xmi:type="uml:Class" xmi:id="c" name="Omitida"/>
      <packagedElement xmi:type="uml:Association" xmi:id="r"><ownedEnd xmi:id="r1" type="a"/><ownedEnd xmi:id="r2" type="b"/></packagedElement>
      <packagedElement xmi:type="uml:Association" xmi:id="s"><ownedEnd xmi:id="s1" type="b"/><ownedEnd xmi:id="s2" type="c"/></packagedElement>
    </uml:Model></xmi:XMI>`;
    await abrirHerramienta(ana, 'importar');
    await ana.page
      .getByTestId('archivo-xmi')
      .setInputFiles({ name: 'editar.xmi', mimeType: 'application/xml', buffer: Buffer.from(xml) });
    await expect(ana.page.getByTestId('aplicar-candidato')).toBeEnabled();
    await ana.page.getByRole('button', { name: 'Quitar operación 4', exact: true }).click();
    await expect(ana.page.getByRole('combobox', { name: /Tipo de relación/ })).toHaveCount(1);
    await ana.page
      .getByRole('combobox', { name: 'Tipo de relación 4', exact: true })
      .selectOption('COMPOSITION');
    await ana.page.getByRole('textbox', { name: 'Rol destino 4', exact: true }).fill('pedidos');
    await ana.page
      .getByRole('combobox', { name: 'Multiplicidad destino 4', exact: true })
      .selectOption('0..*');
    await ana.page.getByRole('checkbox', { name: 'Único', exact: true }).check();
    await expect(ana.page.getByTestId('candidato')).toContainText('pedidos 0..*');
    await ana.page.getByTestId('aplicar-candidato').click();
    for (const actor of [ana, beto]) {
      await expect(actor.page.getByTestId('clase-Cliente')).toContainText('correo');
      await expect(actor.page.getByTestId('clase-Pedido')).toBeVisible();
      await expect(actor.page.getByTestId('clase-Omitida')).toHaveCount(0);
    }
    await ana.page.getByTestId('exportar-xmi').click();
    const download = ana.page.waitForEvent('download');
    await ana.page.getByTestId('confirmar-export').click();
    const parsed = parseXmi(await readFile(await (await download).path(), 'utf8'));
    expect(parsed.relationships).toHaveLength(1);
    expect(parsed.relationships[0]).toMatchObject({
      kind: 'COMPOSITION',
      targetRole: 'pedidos',
      targetMultiplicity: '0..*',
    });
    expect(parsed.classes.find((c) => c.name === 'Cliente')?.attributes[0]?.unique).toBe(true);
  } finally {
    await scenario.cerrar();
  }
});

for (const format of ['EA_21', 'UML_251'])
  test(`reemplazar el XMI ${format} descargado conserva UUID y posición para ambos usuarios y tras recargar`, async ({
    browser,
  }) => {
    const scenario = await montarEscenario(browser, 'Identidad completa');
    const { ana, beto } = scenario;
    try {
      await crearClase(ana, 'Cliente');
      await expect(beto.page.getByTestId('clase-Cliente')).toBeVisible();
      const node = ana.page.locator('.react-flow__node', {
        has: ana.page.getByTestId('clase-Cliente'),
      });
      const id = await node.getAttribute('data-id');
      const position = await posicionEnDiagrama(ana, 'Cliente');
      if (format === 'UML_251') await ana.page.setViewportSize({ width: 320, height: 568 });
      await abrirHerramienta(ana, 'importar');
      await ana.page.getByTestId('exportar-xmi').click();
      await ana.page
        .getByRole('combobox', { name: 'Formato XMI', exact: true })
        .selectOption(format);
      await expect(ana.page.getByTestId('confirmar-export')).toBeInViewport();
      const download = ana.page.waitForEvent('download');
      await ana.page.getByTestId('confirmar-export').click();
      const path = await (await download).path();
      const xml = await readFile(path, 'utf8');
      expect(xml).toContain(
        format === 'EA_21'
          ? 'xmi:version="2.1"'
          : 'xmlns:xmi="http://www.omg.org/spec/XMI/20131001"',
      );
      expect(parseXmi(xml).classes[0]?.xmiId).toBe(id);
      await ana.page.getByTestId('modo-importacion').selectOption('REPLACE');
      await ana.page.getByTestId('archivo-xmi').setInputFiles(path);
      await expect(ana.page.getByTestId('aplicar-candidato')).toBeEnabled();
      await ana.page.getByTestId('aplicar-candidato').click();
      for (const actor of [ana, beto]) {
        await expect(actor.page.getByTestId('clase-Cliente')).toBeVisible();
        await expect(
          actor.page.locator('.react-flow__node', { has: actor.page.getByTestId('clase-Cliente') }),
        ).toHaveAttribute('data-id', id!);
        expect(await posicionEnDiagrama(actor, 'Cliente')).toEqual(position);
      }
      await beto.page.reload();
      await expect(beto.page.getByTestId('estado-conexion')).toHaveText('En vivo');
      await expect(
        beto.page.locator('.react-flow__node', { has: beto.page.getByTestId('clase-Cliente') }),
      ).toHaveAttribute('data-id', id!);
      expect(await posicionEnDiagrama(beto, 'Cliente')).toEqual(position);
    } finally {
      await scenario.cerrar();
    }
  });
```

---

### `e2e/specs/colaboracion.spec.ts`

```ts
import { expect, test } from '@playwright/test';
import {
  abrirHerramienta,
  abrirPizarra,
  aceptarInvitacion,
  crearClase,
  crearProyecto,
  crearPizarra,
  invitar,
  posicionEnDiagrama,
  registrarActor,
  tamanoEnDiagrama,
} from '../support/actors.js';
import { montarEscenario } from '../support/escenario.js';

/**
 * Las cinco pruebas de colaboracion de la seccion 15.4, mas las de seguridad y
 * validacion.
 *
 * Dos navegadores de verdad, con sesiones distintas, contra el entorno completo:
 * navegador → proxy → proceso HTTP y proceso WebSocket → PostgreSQL.
 *
 * Cada prueba monta su propio escenario. Cuesta unos segundos mas y a cambio un
 * fallo senala exactamente una cosa.
 */

test.describe('dos navegadores sobre la misma pizarra', () => {
  test('1 — A crea una clase y B la ve sin recargar (CA-022.1)', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'Ventas 1');
    try {
      await crearClase(escenario.ana, 'Producto');

      // Sin recargar: B lleva en esa misma pagina desde antes.
      await expect(escenario.beto.page.getByTestId('clase-Producto')).toBeVisible();
    } finally {
      await escenario.cerrar();
    }
  });

  test('2 — A mueve una clase y B lo ve', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'Ventas 2');
    try {
      await crearClase(escenario.ana, 'Producto');
      await expect(escenario.beto.page.getByTestId('clase-Producto')).toBeVisible();

      const antesEnBeto = await posicionEnDiagrama(escenario.beto, 'Producto');

      const tarjeta = escenario.ana.page.getByTestId('clase-Producto');
      const rectangulo = await tarjeta.boundingBox();
      expect(rectangulo).not.toBeNull();

      // Se arrastra por la cabecera, que es de donde tira una persona.
      await escenario.ana.page.mouse.move(
        rectangulo!.x + rectangulo!.width / 2,
        rectangulo!.y + 10,
      );
      await escenario.ana.page.mouse.down();
      await escenario.ana.page.mouse.move(rectangulo!.x + 250, rectangulo!.y + 160, { steps: 15 });
      await escenario.ana.page.mouse.up();

      const despuesEnAna = await posicionEnDiagrama(escenario.ana, 'Producto');
      expect(despuesEnAna.y).toBeGreaterThan(antesEnBeto.y);

      // Y B converge a la misma posicion del diagrama.
      await expect
        .poll(async () => (await posicionEnDiagrama(escenario.beto, 'Producto')).y, {
          timeout: 15_000,
        })
        .toBe(despuesEnAna.y);
    } finally {
      await escenario.cerrar();
    }
  });

  test('A redimensiona una tarjeta y B ve el tamano nuevo', async ({ browser }) => {
    // El tamano vive en el documento, no en el estado de React: por eso viaja
    // por el mismo WebSocket que todo lo demas. Si se hubiera quedado en la
    // interfaz, esta prueba fallaria y cada persona veria el suyo.
    const escenario = await montarEscenario(browser, 'Redimensionar');
    try {
      await crearClase(escenario.ana, 'Producto');
      await expect(escenario.beto.page.getByTestId('clase-Producto')).toBeVisible();

      const original = await tamanoEnDiagrama(escenario.beto, 'Producto');

      // Los tiradores solo aparecen con la tarjeta seleccionada.
      await escenario.ana.page.getByTestId('clase-Producto').click();
      const tirador = escenario.ana.page
        .locator('.react-flow__node', {
          has: escenario.ana.page.getByTestId('clase-Producto'),
        })
        .locator('.tirador-redimension.bottom.right');
      await expect(tirador).toBeVisible();

      const caja = await tirador.boundingBox();
      expect(caja).not.toBeNull();

      await escenario.ana.page.mouse.move(caja!.x + caja!.width / 2, caja!.y + caja!.height / 2);
      await escenario.ana.page.mouse.down();
      await escenario.ana.page.mouse.move(caja!.x + 140, caja!.y + 90, { steps: 12 });
      await escenario.ana.page.mouse.up();

      // Y llega al otro navegador sin recargar.
      await expect
        .poll(async () => (await tamanoEnDiagrama(escenario.beto, 'Producto')).width, {
          timeout: 15_000,
        })
        .toBeGreaterThan(original.width + 50);

      const enBeto = await tamanoEnDiagrama(escenario.beto, 'Producto');
      expect(enBeto.height).toBeGreaterThan(original.height + 30);
    } finally {
      await escenario.cerrar();
    }
  });

  test('un lector no puede redimensionar', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'Redimensionar lector', {
      rol: 'lector',
      abrirAmbos: false,
    });
    try {
      await crearClase(escenario.ana, 'Producto');
      await abrirPizarra(escenario.beto, 'Ventas');
      await expect(escenario.beto.page.getByTestId('clase-Producto')).toBeVisible();

      await escenario.beto.page.getByTestId('clase-Producto').click();
      // Seleccionar si puede; redimensionar no.
      await expect(escenario.beto.page.locator('.tirador-redimension')).toHaveCount(0);
    } finally {
      await escenario.cerrar();
    }
  });

  test('3 — A cambia una multiplicidad y B lo ve', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'Ventas 3');
    try {
      await crearClase(escenario.ana, 'Producto');
      await crearClase(escenario.ana, 'Venta');

      // Se conectan arrastrando de un conector a otro, como lo hace una persona.
      const origen = escenario.ana.page
        .getByTestId('clase-Producto')
        .locator('.react-flow__handle-right');
      const destino = escenario.ana.page
        .getByTestId('clase-Venta')
        .locator('.react-flow__handle-left');
      await origen.dragTo(destino);

      await expect(escenario.beto.page.locator('.react-flow__edge')).toHaveCount(1);

      await escenario.ana.page.locator('.react-flow__edge').first().click();
      await expect(escenario.ana.page.getByTestId('inspector-relacion')).toBeVisible();
      await escenario.ana.page.getByTestId('multiplicidad-destino').selectOption('0..1');

      await expect(escenario.beto.page.locator('.react-flow__edge').first()).toContainText('0..1');
    } finally {
      await escenario.cerrar();
    }
  });

  test('4 — un tercero entra tarde y recibe el estado actual (CA-024.1)', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'Ventas 4');
    const carla = await registrarActor(browser, 'carla');
    try {
      await crearClase(escenario.ana, 'Producto');
      await crearClase(escenario.ana, 'Venta');
      await expect(escenario.beto.page.getByTestId('clase-Venta')).toBeVisible();

      // Carla llega cuando la pizarra ya lleva rato construyendose. RA-02: se le
      // entrega el estado actual y a partir de ahi solo deltas.
      await escenario.ana.page.goBack();
      const codigo = await invitar(escenario.ana, 'editor');
      await aceptarInvitacion(carla, codigo);
      await abrirPizarra(carla, 'Ventas');

      await expect(carla.page.getByTestId('clase-Producto')).toBeVisible();
      await expect(carla.page.getByTestId('clase-Venta')).toBeVisible();
    } finally {
      await carla.close();
      await escenario.cerrar();
    }
  });

  test('5 — dos pizarras del mismo proyecto no mezclan (CA-004.1)', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'Ventas 5', {
      pizarras: ['Ventas', 'Inventario'],
      abrirAmbos: false,
    });
    try {
      await abrirPizarra(escenario.beto, 'Inventario');

      await crearClase(escenario.ana, 'Solo En Ventas');
      await expect(escenario.ana.page.getByTestId('clase-SoloEnVentas')).toBeVisible();

      // Margen para que, si hubiera fuga entre salas, diera tiempo a manifestarse.
      await escenario.beto.page.waitForTimeout(1500);

      // Son dos documentos, no dos vistas del mismo.
      await expect(escenario.beto.page.getByTestId('clase-SoloEnVentas')).toHaveCount(0);
      await expect(escenario.beto.page.getByTestId('estado-conexion')).toHaveText('En vivo');
    } finally {
      await escenario.cerrar();
    }
  });

  test('la presencia muestra a los dos participantes (RF-026)', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'Ventas presencia');
    try {
      await expect(escenario.ana.page.getByTestId('presencia').locator('li')).toHaveCount(2);
      await expect(escenario.beto.page.getByTestId('presencia').locator('li')).toHaveCount(2);
    } finally {
      await escenario.cerrar();
    }
  });

  test('limpia la seleccion si otro colaborador elimina el elemento', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'Eliminación remota');
    try {
      await crearClase(escenario.ana, 'Temporal');
      const claseEnBeto = escenario.beto.page.getByTestId('clase-Temporal');
      await expect(claseEnBeto).toBeVisible();

      await claseEnBeto.click();
      await expect(escenario.beto.page.getByTestId('inspector-clase')).toBeVisible();

      await escenario.ana.page.getByTestId('clase-Temporal').click();
      await escenario.ana.page.getByRole('button', { name: 'Eliminar clase' }).click();

      await expect(claseEnBeto).toHaveCount(0);
      await expect(escenario.beto.page.getByText('Nada seleccionado')).toBeVisible();
      await expect(escenario.beto.page.getByText('Elemento eliminado')).toHaveCount(0);
    } finally {
      await escenario.cerrar();
    }
  });

  test('recupera y combina cambios hechos durante una desconexion', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'Reconexión colaborativa');
    const contextoAna = escenario.ana.page.context();
    let sinConexion = false;

    try {
      await contextoAna.setOffline(true);
      sinConexion = true;
      await expect(escenario.ana.page.getByTestId('estado-conexion')).toHaveText('Sin conexión');

      // Yjs conserva la edición local mientras el socket no está disponible.
      await crearClase(escenario.ana, 'Creada Sin Conexión');
      // El otro participante sigue trabajando en la misma pizarra.
      await crearClase(escenario.beto, 'Creada En Línea');

      await contextoAna.setOffline(false);
      sinConexion = false;
      await expect(escenario.ana.page.getByTestId('estado-conexion')).toHaveText('En vivo');

      // Al volver no gana una copia sobre la otra: se combinan ambos deltas.
      for (const actor of [escenario.ana, escenario.beto]) {
        await expect(actor.page.getByTestId('clase-CreadaSinConexion')).toBeVisible();
        await expect(actor.page.getByTestId('clase-CreadaEnLinea')).toBeVisible();
      }
    } finally {
      if (sinConexion) await contextoAna.setOffline(false);
      await escenario.cerrar();
    }
  });
});

test.describe('seguridad y roles', () => {
  test('un rol de solo lectura ve pero no edita (CA-A08.2)', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'Con lector', {
      rol: 'lector',
      abrirAmbos: false,
    });
    try {
      await crearClase(escenario.ana, 'Visible');

      await abrirPizarra(escenario.beto, 'Ventas');
      await expect(escenario.beto.page.getByTestId('clase-Visible')).toBeVisible();

      // La interfaz lo dice y el boton no responde. El servidor, ademas, descarta
      // sus escrituras aunque las intentara por otra via (CA-A08.2).
      await expect(escenario.beto.page.getByTestId('solo-lectura')).toBeVisible();
      await expect(escenario.beto.page.getByTestId('crear-clase')).toBeDisabled();
    } finally {
      await escenario.cerrar();
    }
  });

  test('un no miembro no puede abrir la pizarra', async ({ browser }) => {
    const duena = await registrarActor(browser, 'duena');
    const extrano = await registrarActor(browser, 'extrano');

    try {
      await crearProyecto(duena, 'Proyecto privado');
      await crearPizarra(duena, 'Privada');
      await abrirPizarra(duena, 'Privada');

      // Con la direccion exacta en la mano: es lo mas cerca que puede estar
      // alguien de entrar sin permiso.
      await extrano.page.goto(duena.page.url());

      await expect(extrano.page.getByText(/no existe|no eres miembro/i)).toBeVisible();
      await expect(extrano.page.getByTestId('crear-clase')).toHaveCount(0);
    } finally {
      await duena.close();
      await extrano.close();
    }
  });
});

test.describe('validacion en pantalla', () => {
  test('la colision se marca y bloquea la generacion, sin bloquear la edicion', async ({
    browser,
  }) => {
    const actor = await registrarActor(browser, 'valida');

    try {
      await crearProyecto(actor, 'Proyecto con errores');
      await crearPizarra(actor, 'Con colision');
      await abrirPizarra(actor, 'Con colision');

      await crearClase(actor, 'Detalle de Venta');
      await crearClase(actor, 'detalle venta');

      // Las dos clases existen: el error no impide escribir el nombre.
      await expect(actor.page.getByTestId('clase-DetalleVenta')).toHaveCount(2);

      // Pero el validador lo marca y la generacion queda bloqueada.
      await expect(actor.page.getByTestId('panel-validacion')).toContainText(
        'mismo nombre tecnico',
      );
      await expect(actor.page.getByTestId('puede-generar')).toHaveText('Generación bloqueada');

      // Y al arreglarlo, se desbloquea.
      await actor.page.getByTestId('nombre-clase').fill('Detalle de Compra');
      await expect(actor.page.getByTestId('puede-generar')).toHaveText('Generación disponible');
    } finally {
      await actor.close();
    }
  });

  test('la relacion muchos a muchos se marca y dice como modelarla (RM-01)', async ({
    browser,
  }) => {
    const actor = await registrarActor(browser, 'nm');

    try {
      await crearProyecto(actor, 'Proyecto N a M');
      await crearPizarra(actor, 'Muchos a muchos');
      await abrirPizarra(actor, 'Muchos a muchos');

      await crearClase(actor, 'Alumno');
      await crearClase(actor, 'Materia');

      const origen = actor.page.getByTestId('clase-Alumno').locator('.react-flow__handle-right');
      const destino = actor.page.getByTestId('clase-Materia').locator('.react-flow__handle-left');
      await origen.dragTo(destino);

      await actor.page.locator('.react-flow__edge').first().click();
      await actor.page.getByTestId('multiplicidad-origen').selectOption('0..*');

      // RM-01: la herramienta detecta la N:M y dice como modelarla, en lugar de
      // impedir dibujarla.
      const panel = actor.page.getByTestId('panel-validacion');
      await expect(panel).toContainText('muchos a muchos');
      await expect(panel).toContainText('clase intermedia');
      await expect(actor.page.getByTestId('puede-generar')).toHaveText('Generación bloqueada');
    } finally {
      await actor.close();
    }
  });
});

test.describe('asistente por texto (RF-030 a RF-036)', () => {
  test('una instruccion se propone, se aplica y llega al otro navegador', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'Con asistente');
    try {
      await crearClase(escenario.ana, 'Cliente');
      await expect(escenario.beto.page.getByTestId('clase-Cliente')).toBeVisible();

      // Nada se aplica sin que el usuario lo vea: llega como propuesta.
      await escenario.ana.page
        .getByTestId('entrada-asistente')
        .fill('agrega telefono tipo String a Cliente');
      await escenario.ana.page.getByTestId('enviar-asistente').click();

      const propuesta = escenario.ana.page.getByTestId('propuesta');
      await expect(propuesta).toContainText('telefono');
      await expect(escenario.ana.page.getByTestId('clase-Cliente')).not.toContainText('telefono');

      await escenario.ana.page.getByTestId('aplicar-propuesta').click();

      // Y viaja al otro navegador como cualquier otro cambio: el asistente es
      // un adaptador mas, no una via paralela.
      await expect(escenario.beto.page.getByTestId('clase-Cliente')).toContainText('telefono');
    } finally {
      await escenario.cerrar();
    }
  });

  test('tras varias instrucciones, la ultima propuesta se ve sin desplazar', async ({
    browser,
  }) => {
    // La conversacion crece hacia abajo dentro de un panel que se desplaza, y no
    // se movia sola. A la cuarta instruccion la propuesta nueva —con su boton de
    // aplicar— aparecia fuera de la vista: la persona escribe, parece que no
    // pasa nada, y vuelve a escribir.
    const escenario = await montarEscenario(browser, 'Conversacion larga');
    try {
      await crearClase(escenario.ana, 'Cliente');

      for (const atributo of ['nombre', 'correo', 'telefono', 'direccion']) {
        await escenario.ana.page
          .getByTestId('entrada-asistente')
          .fill(`agrega ${atributo} tipo String a Cliente`);
        await escenario.ana.page.getByTestId('enviar-asistente').click();

        const propuesta = escenario.ana.page.getByTestId('propuesta').last();
        await expect(propuesta).toContainText(atributo);
        await expect(propuesta.getByTestId('aplicar-propuesta')).toBeInViewport({ ratio: 1 });

        await propuesta.getByTestId('aplicar-propuesta').click();
      }

      await expect(escenario.ana.page.getByTestId('clase-Cliente')).toContainText('direccion');
    } finally {
      await escenario.cerrar();
    }
  });

  test('RF-034 — pregunta cuando el objetivo no existe', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'Asistente que pregunta');
    try {
      await crearClase(escenario.ana, 'Cliente');

      await escenario.ana.page
        .getByTestId('entrada-asistente')
        .fill('agrega telefono tipo String a Inexistente');
      await escenario.ana.page.getByTestId('enviar-asistente').click();

      const conversacion = escenario.ana.page.getByTestId('conversacion');
      await expect(conversacion).toContainText(/no (?:encuentro|existe)/i);
      await expect(escenario.ana.page.getByTestId('contexto-asistente')).toContainText(
        /recordaré la solicitud anterior/i,
      );
      // Y no propone nada que aplicar.
      await expect(escenario.ana.page.getByTestId('propuesta')).toHaveCount(0);

      // Tambien se puede descartar una aclaracion que ya no se quiere continuar.
      await escenario.ana.page.getByTestId('descartar-contexto').click();
      await expect(escenario.ana.page.getByTestId('contexto-asistente')).toHaveCount(0);
    } finally {
      await escenario.cerrar();
    }
  });

  test('RF-035 — lo destructivo pide confirmacion', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'Asistente destructivo');
    try {
      await crearClase(escenario.ana, 'Cliente');
      await escenario.ana.page.getByTestId('nuevo-atributo').fill('nombre');
      await escenario.ana.page.getByRole('button', { name: 'Añadir' }).click();
      await escenario.ana.page.getByTestId('nuevo-atributo').fill('correo');
      await escenario.ana.page.getByRole('button', { name: 'Añadir' }).click();

      await escenario.ana.page.getByTestId('entrada-asistente').fill('elimina Cliente');
      await escenario.ana.page.getByTestId('enviar-asistente').click();

      await expect(escenario.ana.page.getByTestId('confirmacion')).toContainText(/confirmas/i);
      // Sigue ahi hasta que se confirma.
      await expect(escenario.ana.page.getByTestId('clase-Cliente')).toBeVisible();

      await escenario.ana.page.getByRole('button', { name: 'Sí, aplicar' }).click();
      await expect(escenario.ana.page.getByTestId('clase-Cliente')).toHaveCount(0);
    } finally {
      await escenario.cerrar();
    }
  });

  test('RF-036 — consultar no modifica la pizarra', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'Asistente consultivo');
    try {
      await crearClase(escenario.ana, 'Cliente');

      await escenario.ana.page.getByTestId('modo-preguntar').click();
      await escenario.ana.page.getByTestId('entrada-asistente').fill('¿puedo generar?');
      await escenario.ana.page.getByTestId('enviar-asistente').click();

      await expect(escenario.ana.page.getByTestId('conversacion')).toContainText('1 clases');
      // Ni propuesta ni cambio.
      await expect(escenario.ana.page.getByTestId('propuesta')).toHaveCount(0);
      await expect(escenario.ana.page.getByTestId('clase-Cliente')).toBeVisible();
    } finally {
      await escenario.cerrar();
    }
  });
});

test.describe('importacion y exportacion (M4 y M5)', () => {
  test('RF-050 — exportar produce un archivo XMI descargable', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'Con exportacion');
    try {
      await crearClase(escenario.ana, 'Cliente');
      await expect(escenario.ana.page.getByTestId('clase-Cliente')).toBeVisible();

      await abrirHerramienta(escenario.ana, 'importar');

      // Exportar ya no descarga de golpe: pide el nombre primero, que es lo que
      // permite guardarlo como se llame el modelo en Enterprise Architect.
      await escenario.ana.page.getByTestId('exportar-xmi').click();
      const campo = escenario.ana.page.getByTestId('campo-nombre-export');
      // Viene con el nombre de la pizarra, que es lo que uno querria llamarlo.
      await expect(campo).toHaveValue('Ventas');
      await campo.fill('ventas del semestre');

      const descarga = escenario.ana.page.waitForEvent('download');
      await escenario.ana.page.getByTestId('confirmar-export').click();

      const archivo = await descarga;
      // El nombre escrito, con la extension puesta por nosotros.
      expect(archivo.suggestedFilename()).toBe('ventas del semestre.xmi');
    } finally {
      await escenario.cerrar();
    }
  });

  test('el ida y vuelta por la interfaz conserva el diagrama', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'Ida y vuelta', {
      pizarras: ['Origen', 'Destino'],
      abrirAmbos: false,
    });
    try {
      // Se construye en una pizarra...
      await crearClase(escenario.ana, 'Cliente');
      await escenario.ana.page.getByTestId('nuevo-atributo').fill('correo');
      await escenario.ana.page.getByRole('button', { name: 'Añadir' }).click();
      await expect(escenario.ana.page.getByTestId('clase-Cliente')).toContainText('correo');

      await abrirHerramienta(escenario.ana, 'importar');

      await escenario.ana.page.getByTestId('exportar-xmi').click();
      const descarga = escenario.ana.page.waitForEvent('download');
      await escenario.ana.page.getByTestId('confirmar-export').click();
      const ruta = await (await descarga).path();

      // ...y se importa en la otra.
      await abrirPizarra(escenario.beto, 'Destino');
      await abrirHerramienta(escenario.beto, 'importar');
      await escenario.beto.page.getByTestId('archivo-xmi').setInputFiles(ruta);

      const candidato = escenario.beto.page.getByTestId('candidato');
      await expect(candidato).toContainText('Cliente');
      // CA-042.1: nada se aplica solo.
      await expect(escenario.beto.page.getByTestId('clase-Cliente')).toHaveCount(0);

      await escenario.beto.page.getByTestId('aplicar-candidato').click();
      await expect(escenario.beto.page.getByTestId('clase-Cliente')).toContainText('correo');
    } finally {
      await escenario.cerrar();
    }
  });

  test('un XMI mayor de un MiB atraviesa el proxy y se aplica', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'Archivo grande');
    try {
      await abrirHerramienta(escenario.ana, 'importar');
      await escenario.ana.page.getByTestId('archivo-xmi').setInputFiles({
        name: 'grande.xmi',
        mimeType: 'application/xml',
        buffer: Buffer.from(`<?xml version="1.0"?><xmi:XMI xmi:version="2.1"
          xmlns:uml="http://schema.omg.org/spec/UML/2.1" xmlns:xmi="http://schema.omg.org/spec/XMI/2.1">
          <!-- ${'x'.repeat(1_100_000)} -->
          <uml:Model name="Grande"><packagedElement xmi:type="uml:Class" xmi:id="CLS1" name="ArchivoGrande"/></uml:Model>
          </xmi:XMI>`),
      });
      await expect(escenario.ana.page.getByTestId('candidato')).toContainText('ArchivoGrande');
      await escenario.ana.page.getByTestId('aplicar-candidato').click();
      await expect(escenario.beto.page.getByTestId('clase-ArchivoGrande')).toBeVisible();
    } finally {
      await escenario.cerrar();
    }
  });

  test('un XMI ya presente explica que no hay cambios y ofrece reemplazar', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'XMI repetido');
    try {
      await crearClase(escenario.ana, 'Usuario');
      await abrirHerramienta(escenario.ana, 'importar');

      await escenario.ana.page.getByTestId('archivo-xmi').setInputFiles({
        name: 'usuario-repetido.xmi',
        mimeType: 'application/xml',
        buffer: Buffer.from(`<?xml version="1.0" encoding="UTF-8"?>
<xmi:XMI xmi:version="2.1" xmlns:uml="http://schema.omg.org/spec/UML/2.1" xmlns:xmi="http://schema.omg.org/spec/XMI/2.1">
  <uml:Model xmi:type="uml:Model" name="Repetido">
    <packagedElement xmi:type="uml:Class" xmi:id="CLS1" name="Usuario"/>
  </uml:Model>
</xmi:XMI>`),
      });

      const candidato = escenario.ana.page.getByTestId('candidato');
      await expect(candidato).toContainText('todo su contenido ya está en la pizarra', {
        ignoreCase: true,
      });
      await expect(
        escenario.ana.page.getByRole('button', { name: 'Reemplazar con este archivo' }),
      ).toBeVisible();
      await expect(escenario.ana.page.getByTestId('aplicar-candidato')).toHaveCount(0);
      await expect(escenario.ana.page.getByTestId('clase-Usuario')).toBeVisible();
    } finally {
      await escenario.cerrar();
    }
  });

  test('la vista previa XMI permite corregir nombres y tipos antes de aplicar', async ({
    browser,
  }) => {
    const escenario = await montarEscenario(browser, 'XMI editable');
    try {
      await abrirHerramienta(escenario.ana, 'importar');
      await escenario.ana.page.getByTestId('archivo-xmi').setInputFiles({
        name: 'cliente-borrador.xmi',
        mimeType: 'application/xml',
        buffer: Buffer.from(`<?xml version="1.0" encoding="UTF-8"?>
<xmi:XMI xmi:version="2.1" xmlns:uml="http://schema.omg.org/spec/UML/2.1" xmlns:xmi="http://schema.omg.org/spec/XMI/2.1">
  <uml:Model xmi:type="uml:Model" name="Editable">
    <packagedElement xmi:type="uml:Class" xmi:id="CLS1" name="Cliente borrador">
      <ownedAttribute xmi:type="uml:Property" xmi:id="AT1" name="edadTexto" type="String"/>
    </packagedElement>
  </uml:Model>
</xmi:XMI>`),
      });

      await escenario.ana.page.getByRole('textbox', { name: 'Nombre de clase 1' }).fill('Cliente');
      await expect(
        escenario.ana.page.getByRole('textbox', { name: 'Nombre de atributo 2' }),
      ).toBeInViewport({ ratio: 1 });
      await expect(escenario.ana.page.getByTestId('aplicar-candidato')).toBeInViewport({
        ratio: 1,
      });
      await escenario.ana.page.getByRole('textbox', { name: 'Nombre de atributo 2' }).fill('edad');
      await escenario.ana.page
        .getByRole('combobox', { name: 'Tipo de atributo 2' })
        .selectOption('Integer');
      await escenario.ana.page.getByTestId('aplicar-candidato').click();

      const clase = escenario.ana.page.getByTestId('clase-Cliente');
      await expect(clase).toBeVisible();
      await expect(clase).toContainText('edad');
      await expect(clase).toContainText('Integer');
      await expect(escenario.ana.page.getByTestId('clase-Cliente borrador')).toHaveCount(0);
    } finally {
      await escenario.cerrar();
    }
  });

  test('con muchos avisos, el boton de aplicar sigue a la vista', async ({ browser }) => {
    // Reproduce lo que le pasa a quien importa un archivo de otra herramienta:
    // cada atributo con un tipo que no reconocemos deja un aviso, la lista crece
    // y empuja los botones fuera del panel. La persona ve avisos, no ve ningun
    // boton, y concluye que la importacion no funciona — cuando en realidad solo
    // falta pulsar «Aplicar», que esta unos centimetros mas abajo.
    //
    // Ninguna prueba lo detectaba porque Playwright desplaza el panel antes de
    // pulsar. Las personas no.
    const escenario = await montarEscenario(browser, 'Muchos avisos');
    try {
      await abrirHerramienta(escenario.ana, 'importar');

      const atributos = ['nombre', 'correo', 'telefono', 'direccion', 'ciudad', 'pais', 'nit']
        .map(
          (nombre, indice) =>
            `<ownedAttribute xmi:type="uml:Property" xmi:id="AT${indice}" name="${nombre}" type="tipoDesconocido"/>`,
        )
        .join('\n      ');

      await escenario.ana.page.getByTestId('archivo-xmi').setInputFiles({
        name: 'de-otra-herramienta.xmi',
        mimeType: 'application/xml',
        buffer: Buffer.from(`<?xml version="1.0" encoding="UTF-8"?>
<xmi:XMI xmi:version="2.1" xmlns:uml="http://schema.omg.org/spec/UML/2.1" xmlns:xmi="http://schema.omg.org/spec/XMI/2.1">
  <uml:Model xmi:type="uml:Model" name="Ajeno">
    <packagedElement xmi:type="uml:Class" xmi:id="CLS1" name="Usuario">
      ${atributos}
    </packagedElement>
  </uml:Model>
</xmi:XMI>`),
      });

      // Los avisos vienen desplegados: un candidato con avisos plegados se
      // aplicaba sin leerlos. Pulsar el resumen aqui los cerraria.
      const avisos = escenario.ana.page.getByTestId('avisos-importacion');
      await expect(escenario.ana.page.getByText(/7 avisos del archivo/i)).toBeVisible();
      await expect(avisos).toBeVisible();

      // Lo que importa: sin tocar la rueda del raton, la accion se ve.
      await expect(escenario.ana.page.getByTestId('aplicar-candidato')).toBeInViewport({
        ratio: 1,
      });

      await escenario.ana.page.getByTestId('aplicar-candidato').click();
      await expect(escenario.ana.page.getByTestId('clase-Usuario')).toBeVisible();
    } finally {
      await escenario.cerrar();
    }
  });

  test('con el inspector lleno, el candidato sigue teniendo su boton a la vista', async ({
    browser,
  }) => {
    // El caso real: una clase seleccionada con muchos atributos deja el
    // inspector alto, y la herramienta comparte columna con el. Si la
    // herramienta se encoge sin tope, el candidato queda reducido a su lista de
    // avisos y el boton desaparece.
    const escenario = await montarEscenario(browser, 'Inspector lleno');
    try {
      await crearClase(escenario.ana, 'Cliente');

      for (const nombre of ['a1', 'a2', 'a3', 'a4', 'a5', 'a6', 'a7', 'a8', 'a9', 'a10']) {
        await escenario.ana.page.getByTestId('nuevo-atributo').fill(nombre);
        await escenario.ana.page.getByRole('button', { name: 'Añadir' }).click();
      }

      await abrirHerramienta(escenario.ana, 'importar');
      await escenario.ana.page.getByTestId('archivo-xmi').setInputFiles({
        name: 'ajeno.xmi',
        mimeType: 'application/xml',
        buffer: Buffer.from(`<?xml version="1.0" encoding="UTF-8"?>
<xmi:XMI xmi:version="2.1" xmlns:uml="http://schema.omg.org/spec/UML/2.1" xmlns:xmi="http://schema.omg.org/spec/XMI/2.1">
  <uml:Model xmi:type="uml:Model" name="Ajeno">
    <packagedElement xmi:type="uml:Class" xmi:id="CLS1" name="Proveedor">
      <ownedAttribute xmi:type="uml:Property" xmi:id="P1" name="razon" type="raro"/>
      <ownedAttribute xmi:type="uml:Property" xmi:id="P2" name="nit" type="raro"/>
      <ownedAttribute xmi:type="uml:Property" xmi:id="P3" name="ciudad" type="raro"/>
      <ownedAttribute xmi:type="uml:Property" xmi:id="P4" name="pais" type="raro"/>
      <ownedAttribute xmi:type="uml:Property" xmi:id="P5" name="rubro" type="raro"/>
    </packagedElement>
  </uml:Model>
</xmi:XMI>`),
      });

      await expect(escenario.ana.page.getByTestId('aplicar-candidato')).toBeInViewport({
        ratio: 1,
      });
      await escenario.ana.page.getByTestId('aplicar-candidato').click();
      await expect(escenario.ana.page.getByTestId('clase-Proveedor')).toBeVisible();

      // Y no cae encima de la que ya estaba: todo lo que se creaba sin posicion
      // —asistente e importaciones— aterrizaba en (0, 0), una clase sobre otra.
      const cliente = await escenario.ana.page.getByTestId('clase-Cliente').boundingBox();
      const proveedor = await escenario.ana.page.getByTestId('clase-Proveedor').boundingBox();
      expect(cliente).not.toBeNull();
      expect(proveedor).not.toBeNull();
      expect(
        Math.abs(proveedor!.x - cliente!.x) + Math.abs(proveedor!.y - cliente!.y),
      ).toBeGreaterThan(100);
    } finally {
      await escenario.cerrar();
    }
  });

  test('un XMI que no se entiende lo dice, sin romper la pizarra', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'XMI invalido');
    try {
      await crearClase(escenario.ana, 'Cliente');
      await abrirHerramienta(escenario.ana, 'importar');

      await escenario.ana.page.getByTestId('archivo-xmi').setInputFiles({
        name: 'no-es-xmi.xmi',
        mimeType: 'application/xml',
        buffer: Buffer.from('<html><body>esto no es un modelo</body></html>'),
      });

      await expect(escenario.ana.page.getByTestId('error-importacion')).toContainText(/XMI 2\.1/);
      // La pizarra sigue como estaba.
      await expect(escenario.ana.page.getByTestId('clase-Cliente')).toBeVisible();
    } finally {
      await escenario.cerrar();
    }
  });

  test('RF-040 a RF-043 — la foto produce un candidato que se revisa antes', async ({
    browser,
  }) => {
    const escenario = await montarEscenario(browser, 'Con fotografia');
    try {
      await abrirHerramienta(escenario.ana, 'importar');

      // Un PNG minimo: con el adaptador simulado el contenido no importa, y lo
      // que se prueba es el camino completo hasta el candidato editable.
      await escenario.ana.page.getByTestId('archivo-imagen').setInputFiles({
        name: 'pizarron.png',
        mimeType: 'image/png',
        buffer: Buffer.from(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
          'base64',
        ),
      });

      const candidato = escenario.ana.page.getByTestId('candidato');
      await expect(candidato).toContainText('Cliente');
      await expect(escenario.ana.page.getByTestId('clase-Cliente')).toHaveCount(0);

      await escenario.ana.page.getByTestId('aplicar-candidato').click();

      // Y al aplicarlo viaja al otro navegador como cualquier otro cambio.
      await expect(escenario.beto.page.getByTestId('clase-Cliente')).toBeVisible();
      await expect(escenario.beto.page.getByTestId('clase-Pedido')).toBeVisible();
    } finally {
      await escenario.cerrar();
    }
  });

  test('el candidato se puede descartar sin tocar nada', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'Descartar candidato');
    try {
      await abrirHerramienta(escenario.ana, 'importar');
      // Descartar es una conducta de la vista previa, no del proveedor de
      // visión. Un XMI fijo mantiene esta regresión determinista aunque la IA
      // interprete de forma distinta una imagen ambigua de un píxel.
      await escenario.ana.page.getByTestId('archivo-xmi').setInputFiles({
        name: 'candidato.xmi',
        mimeType: 'application/xml',
        buffer: Buffer.from(`<?xml version="1.0" encoding="UTF-8"?>
<xmi:XMI xmi:version="2.1" xmlns:uml="http://schema.omg.org/spec/UML/2.1" xmlns:xmi="http://schema.omg.org/spec/XMI/2.1">
  <uml:Model xmi:type="uml:Model" name="Descartable">
    <packagedElement xmi:type="uml:Class" xmi:id="CLS1" name="Cliente"/>
  </uml:Model>
</xmi:XMI>`),
      });

      await expect(escenario.ana.page.getByTestId('candidato')).toBeVisible();
      await escenario.ana.page.getByRole('button', { name: 'Descartar' }).click();

      await expect(escenario.ana.page.getByTestId('candidato')).toHaveCount(0);
      await expect(escenario.ana.page.getByTestId('clase-Cliente')).toHaveCount(0);
    } finally {
      await escenario.cerrar();
    }
  });
});
```

---

### `e2e/specs/cuenta.spec.ts`

```ts
import { expect, test } from '@playwright/test';
import { registrarActor } from '../support/actors.js';

/**
 * Perfil, foto y contraseña desde el navegador (RF-A10 y RF-A11).
 *
 * Las pruebas de integración ya cubren las rutas y sus garantías. Lo que se
 * comprueba aquí es que una persona pueda llegar hasta ellas: que el menú lleve
 * a la cuenta, que la foto se recorte en el navegador y se vea después, y que
 * cambiar la contraseña sirva para volver a entrar con la nueva.
 */
test.describe('mi cuenta', () => {
  test('cambia el nombre y se refleja en la barra', async ({ browser }) => {
    const ana = await registrarActor(browser, 'ana');
    try {
      await ana.page.getByTestId('menu-usuario').click();
      await ana.page.getByTestId('mi-cuenta').click();

      await expect(ana.page.getByTestId('perfil-nombre')).toBeVisible();
      await ana.page.getByTestId('perfil-nombre').fill('Ana Torres');
      await ana.page.getByTestId('guardar-perfil').click();

      await expect(ana.page.getByTestId('perfil-guardado')).toBeVisible();
      // El nombre nuevo llega a la barra sin recargar: la ruta devuelve el
      // usuario actualizado y la sesión lo adopta.
      await expect(ana.page.getByTestId('menu-usuario')).toContainText('Ana Torres');
    } finally {
      await ana.close();
    }
  });

  test('el correo se muestra pero no se puede editar', async ({ browser }) => {
    const ana = await registrarActor(browser, 'ana');
    try {
      await ana.page.goto('/cuenta');

      const correo = ana.page.getByTestId('perfil-correo');
      await expect(correo).toBeVisible();
      // Es la identidad de la cuenta y la dirección de la recuperación.
      await expect(correo).toBeDisabled();
    } finally {
      await ana.close();
    }
  });

  test('sube una foto y aparece en la barra superior', async ({ browser }) => {
    const ana = await registrarActor(browser, 'ana');
    try {
      await ana.page.goto('/cuenta');

      // Un PNG de 2x2. El navegador lo recorta a 256x256 y lo reencoda antes
      // de subirlo, así que lo que llega al servidor no es este archivo.
      await ana.page.getByTestId('archivo-foto').setInputFiles({
        name: 'retrato.png',
        mimeType: 'image/png',
        buffer: Buffer.from(
          'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAYAAABytg0kAAAAFklEQVR4nGP8z8DAwMDAxMDAwMAABBoAB5kBAd1FhU4AAAAASUVORK5CYII=',
          'base64',
        ),
      });

      // La imagen del avatar de la barra deja de fallar en cuanto hay foto.
      const avatarBarra = ana.page.getByTestId('menu-usuario').locator('img.avatar');
      await expect(avatarBarra).toBeVisible({ timeout: 15_000 });

      // `naturalWidth` mayor que cero significa que el navegador decodifico la
      // imagen: no basta con que la etiqueta exista, tiene que haberse cargado.
      await expect
        .poll(
          async () =>
            avatarBarra.evaluate((elemento) =>
              elemento instanceof HTMLImageElement ? elemento.naturalWidth : 0,
            ),
          { timeout: 15_000 },
        )
        .toBeGreaterThan(0);
    } finally {
      await ana.close();
    }
  });

  test('cambia la contraseña y entra con la nueva', async ({ browser }) => {
    const ana = await registrarActor(browser, 'ana');
    try {
      await ana.page.goto('/cuenta');

      await ana.page.getByTestId('password-actual').fill('contrasena-de-prueba');
      await ana.page.getByTestId('password-nueva').fill('contrasena-nueva-1');
      await ana.page.getByTestId('password-repetida').fill('contrasena-nueva-1');
      await ana.page.getByTestId('cambiar-password').click();

      await expect(ana.page.getByTestId('password-cambiada')).toBeVisible();

      // Y sirve de verdad: se cierra sesión y se entra con la nueva.
      await ana.page.getByTestId('menu-usuario').click();
      await ana.page.getByTestId('salir').click();
      await expect(ana.page.getByTestId('email')).toBeVisible();

      await ana.page.getByTestId('email').fill(ana.email);
      await ana.page.getByTestId('password').fill('contrasena-nueva-1');
      await ana.page.getByTestId('enviar').click();

      await expect(ana.page.getByTestId('lista-proyectos')).toBeVisible();
    } finally {
      await ana.close();
    }
  });

  test('la repetición que no coincide bloquea el envío', async ({ browser }) => {
    const ana = await registrarActor(browser, 'ana');
    try {
      await ana.page.goto('/cuenta');

      await ana.page.getByTestId('password-actual').fill('contrasena-de-prueba');
      await ana.page.getByTestId('password-nueva').fill('contrasena-nueva-1');
      await ana.page.getByTestId('password-repetida').fill('otra-cosa');

      // Se atrapa aquí y no en el servidor: la repetición existe para detectar
      // una errata al teclear.
      await expect(ana.page.getByTestId('cambiar-password')).toBeDisabled();
    } finally {
      await ana.close();
    }
  });
});

test.describe('recuperar la contraseña', () => {
  test('pedir el enlace confirma sin decir si la cuenta existe', async ({ browser }) => {
    const contexto = await browser.newContext();
    const page = await contexto.newPage();

    try {
      await page.goto('/entrar');
      await page.getByTestId('olvide-password').click();

      // En este modo no se pide contraseña: solo el correo.
      await expect(page.getByTestId('password')).toHaveCount(0);

      await page.getByTestId('email').fill('nadie-por-aqui@example.com');
      await page.getByTestId('enviar').click();

      // Mismo mensaje exista o no la cuenta: el formulario no puede servir para
      // averiguar qué correos están registrados.
      await expect(page.getByTestId('recuperacion-enviada')).toBeVisible();
    } finally {
      await contexto.close();
    }
  });

  test('un enlace sin código lo dice, en vez de fallar en blanco', async ({ browser }) => {
    const contexto = await browser.newContext();
    const page = await contexto.newPage();

    try {
      await page.goto('/restablecer');
      await expect(page.getByText(/enlace está incompleto/i)).toBeVisible();
    } finally {
      await contexto.close();
    }
  });

  test('un código inventado se rechaza', async ({ browser }) => {
    const contexto = await browser.newContext();
    const page = await contexto.newPage();

    try {
      await page.goto(`/restablecer?token=${'a'.repeat(64)}`);

      await page.getByTestId('nueva-password').fill('contrasena-nueva-1');
      await page.getByTestId('repetir-password').fill('contrasena-nueva-1');
      await page.getByTestId('guardar-password').click();

      await expect(page.getByTestId('error-restablecer')).toContainText(/ya no sirve/i);
    } finally {
      await contexto.close();
    }
  });
});
```

---

### `e2e/specs/generacion.spec.ts`

```ts
import { readFile } from 'node:fs/promises';
import { expect, test } from '@playwright/test';
import { abrirHerramienta, crearClase } from '../support/actors.js';
import { montarEscenario } from '../support/escenario.js';

/**
 * Del diagrama al ZIP, por la interfaz (guion 16.2).
 *
 * Son los dos pasos de la defensa que hasta la fase 10 no existían: «seleccionar
 * la pizarra y generar» y «descargar el ZIP». Las pruebas de integración ya
 * cubren la ruta; esto comprueba que la persona puede llegar hasta el archivo
 * **desde el navegador**, que es lo que ocurrirá el 23.
 *
 * El contenido del ZIP no se abre aquí: de eso se ocupa `npm run test:bank`, que
 * compila y arranca siete proyectos generados. Repetirlo con un navegador
 * delante costaría minutos y no añadiría nada.
 */
test.describe('generacion desde el editor', () => {
  test('una clase nueva se puede generar y descargar', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'Generacion');

    try {
      await crearClase(escenario.ana, 'Cliente');
      await abrirHerramienta(escenario.ana, 'generar');

      // Sin errores en el modelo, el pie de página lo dice y el botón se habilita.
      await expect(escenario.ana.page.getByTestId('puede-generar')).toHaveText(
        'Generación disponible',
      );
      await expect(escenario.ana.page.getByTestId('generar')).toBeEnabled();

      // El paquete que se escribe aquí tiene que llegar al código descargado.
      // Antes no llegaba: la API lo aceptaba, lo devolvía en la respuesta, y
      // ninguna descarga lo llevaba (ADR-018, enmienda).
      await escenario.ana.page.getByTestId('paquete-base').fill('bo.edu.demo');
      await escenario.ana.page.getByTestId('incluir-flutter').check();
      await escenario.ana.page.getByTestId('generar').click();

      // El mensaje dice sobre qué versión del snapshot se generó: es la prueba
      // visible de RA-08 para quien mire la pantalla en la defensa.
      const estado = escenario.ana.page.getByTestId('estado-generacion');
      await expect(estado).toContainText('entidades', { timeout: 30_000 });
      await expect(estado).toContainText(/versión \d+ del modelo/);
      await expect(estado).toContainText('bo.edu.demo');

      // Y el historial enseña el manifiesto congelado, no el estado de ahora.
      await expect(escenario.ana.page.getByTestId('historial-generaciones')).toContainText(
        'bo.edu.demo',
      );

      const descarga = escenario.ana.page.waitForEvent('download');
      await escenario.ana.page.getByTestId('descargar-spring').click();
      const archivo = await descarga;

      expect(archivo.suggestedFilename()).toMatch(/\.zip$/);

      // Que exista un archivo no basta: uno vacío también existiría, y la
      // primera versión de esto generó cero entidades sobre una pizarra que
      // mostraba una — la proyección iba con retardo y nadie lo habría visto
      // hasta abrir el ZIP en la defensa.
      //
      // Los nombres de archivo viajan sin comprimir en el índice del ZIP, así
      // que se pueden buscar sin descomprimir nada.
      const contenido = await readFile(await archivo.path());
      expect(contenido.includes('Cliente.java')).toBe(true);
      expect(contenido.includes('ClienteController.java')).toBe(true);
      expect(contenido.includes('pom.xml')).toBe(true);
      // Las rutas llevan el paquete convertido en carpetas.
      expect(contenido.includes('bo/edu/demo')).toBe(true);
      const mobileDownload = escenario.ana.page.waitForEvent('download');
      await escenario.ana.page.getByTestId('descargar-mobile').click();
      const mobile = await mobileDownload;
      expect(mobile.suggestedFilename()).toMatch(/-android\.zip$/);
      const paired = await readFile(await mobile.path());
      expect(paired.includes('mobile/lib/main.dart')).toBe(true);
      expect(paired.includes('MobileSyncController.java')).toBe(true);
      expect(paired.includes('mobile/assets/contract.json')).toBe(true);
    } finally {
      await escenario.cerrar();
    }
  });

  test('los botones de descarga se ven sin desplazar el panel', async ({ browser }) => {
    // Misma familia que el candidato de importacion y que la propuesta del
    // asistente: la accion que sigue a lo que acabas de hacer tiene que estar a
    // la vista. Aqui el historial crece debajo, generacion tras generacion.
    const escenario = await montarEscenario(browser, 'Descargas visibles');

    try {
      await crearClase(escenario.ana, 'Cliente');
      await abrirHerramienta(escenario.ana, 'generar');

      for (let vuelta = 0; vuelta < 4; vuelta += 1) {
        await escenario.ana.page.getByTestId('generar').click();
        await expect(escenario.ana.page.getByTestId('estado-generacion')).toContainText(
          'entidades',
          { timeout: 30_000 },
        );
      }

      await expect(escenario.ana.page.getByTestId('descargar-spring')).toBeInViewport({
        ratio: 1,
      });
    } finally {
      await escenario.cerrar();
    }
  });
});
```

---

### `e2e/specs/ia-contexto.spec.ts`

```ts
import { expect, test } from '@playwright/test';
import type { SemanticModel } from '@uml/contracts';
import { resolveProposal } from '@uml/ai';
import { montarEscenario } from '../support/escenario.js';
import { crearClase } from '../support/actors.js';

test('conserva opciones de aclaración y recupera el pedido completo cuando cambia la pizarra', async ({
  browser,
}) => {
  const scenario = await montarEscenario(browser, 'Contexto IA');
  try {
    const { page } = scenario.ana;
    await crearClase(scenario.ana, 'Cliente');
    await expect(scenario.beto.page.getByTestId('clase-Cliente')).toBeVisible();
    const requests: {
      instruction: string;
      context: { role: string; text: string }[];
      model: SemanticModel;
    }[] = [];
    await page.route('**/assistant/instruction', async (route) => {
      const body = route.request().postDataJSON() as (typeof requests)[number];
      requests.push(body);
      if (requests.length === 1) {
        await route.fulfill({
          json: {
            kind: 'QUESTION',
            question: '¿En qué clase?',
            options: ['Cliente', 'Proveedor'],
            rationale: null,
          },
        });
        return;
      }
      const outcome = resolveProposal({
        proposal: {
          operations: [
            { op: 'ADD_ATTRIBUTE', className: 'Cliente', attributeName: 'correo', type: 'String' },
          ],
        },
        model: body.model,
        actorId: '22222222-2222-4222-8222-222222222222',
        origin: 'AI_TEXT',
      });
      await route.fulfill({ json: { ...outcome, rationale: null } });
    });
    await page.getByTestId('pestana-asistente').click();
    const input = page.getByTestId('entrada-asistente');
    await input.fill('Agrega correo String; no borres ninguna clase.');
    await page.getByTestId('enviar-asistente').click();
    await expect(page.getByTestId('conversacion')).toContainText('1. "Cliente"');
    await input.fill('la primera');
    await page.getByTestId('enviar-asistente').click();
    await expect(page.getByTestId('aplicar-propuesta')).toBeVisible();
    expect(requests[1]?.context[1]?.text).toBe('¿En qué clase?\n1. "Cliente"\n2. "Proveedor"');
    await scenario.beto.page.getByTestId('clase-Cliente').click();
    await scenario.beto.page.getByTestId('nuevo-atributo').fill('correo');
    await scenario.beto.page.getByRole('button', { name: 'Añadir', exact: true }).click();
    await expect(page.getByTestId('clase-Cliente')).toContainText('correo');
    await page.getByTestId('aplicar-propuesta').click();
    await expect(page.getByTestId('propuesta-obsoleta')).toBeVisible();
    await expect(input).toHaveValue('la primera');
    await page.getByTestId('enviar-asistente').click();
    await expect.poll(() => requests.length).toBe(3);
    expect(requests[2]?.context).toEqual(requests[1]?.context);
    expect(requests[2]?.context[0]?.text).toContain('no borres ninguna clase');
  } finally {
    await scenario.cerrar();
  }
});
```

---

### `e2e/specs/movil.spec.ts`

```ts
import { expect, test, type Page, type TestInfo } from '@playwright/test';
import { activarCuentaEIniciarSesion, nuevoCorreo } from '../support/actors.js';

const pantallas = [
  { width: 320, height: 568 },
  { width: 360, height: 800 },
  { width: 390, height: 844 },
  { width: 430, height: 932 },
  { width: 768, height: 1024 },
  { width: 844, height: 390 },
];

for (const viewport of pantallas) {
  test.describe(`movil ${viewport.width}x${viewport.height}`, () => {
    test.use({ viewport, isMobile: true, hasTouch: true });

    test('permite usar acceso, proyectos, cuenta y editor con tacto', async ({
      page,
    }, testInfo) => {
      await page.goto('/entrar');
      await expect(page.getByTestId('email')).toBeVisible();
      await comprobarAncho(page, testInfo, 'acceso', viewport.width);
      await page.getByRole('button', { name: 'Crear cuenta', exact: true }).tap();
      const email = nuevoCorreo('movil');
      await page.getByTestId('email').fill(email);
      await page.getByTestId('displayName').fill('Usuario de prueba en móvil');
      await page.getByTestId('password').fill('contrasena-de-prueba');
      await page.getByTestId('enviar').tap();
      await activarCuentaEIniciarSesion(page, email);
      await expect(page.getByTestId('lista-proyectos')).toBeVisible();
      await comprobarAncho(page, testInfo, 'proyectos', viewport.width);

      await page.getByTestId('menu-usuario').tap();
      await page.getByTestId('mi-cuenta').tap();
      await page.getByTestId('perfil-nombre').fill('Nombre móvil actualizado');
      await page.getByTestId('guardar-perfil').tap();
      await expect(page.getByTestId('perfil-guardado')).toBeVisible();
      await comprobarAncho(page, testInfo, 'cuenta', viewport.width);

      await page.getByRole('link', { name: 'UMLFORGE AI, ir a mis proyectos' }).tap();
      await page
        .getByTestId('nombre-proyecto')
        .fill('Proyecto de modelado desde un teléfono móvil');
      await page.getByTestId('crear-proyecto').tap();
      await expect(page.getByTestId('lista-pizarras')).toBeVisible();
      await expect(page.getByTestId('alternar-colaboradores')).toHaveAttribute(
        'aria-expanded',
        'false',
      );
      await expect(page.locator('#detalle-colaboradores')).toBeHidden();
      await page.getByTestId('alternar-colaboradores').tap();
      await expect(page.locator('#detalle-colaboradores')).toBeVisible();
      await page.getByTestId('alternar-colaboradores').tap();
      await page.getByTestId('invitar-editor').tap();
      await expect(page.getByTestId('codigo-generado')).toBeVisible();
      await expect(page.locator('#detalle-colaboradores')).toBeVisible();
      await comprobarAncho(page, testInfo, 'pizarras', viewport.width);
      await page.getByTestId('nombre-pizarra').fill('Diagrama de ventas y clientes desde el móvil');
      await page.getByTestId('crear-pizarra').tap();
      await page.getByTestId('alternar-colaboradores').tap();
      await comprobarAncho(page, testInfo, 'pizarras-compactas', viewport.width);
      await page.getByRole('link', { name: 'Diagrama de ventas y clientes desde el móvil' }).tap();
      await expect(page.getByTestId('estado-conexion')).toHaveText('En vivo');
      await expect(page.getByRole('link', { name: 'Proyecto', exact: true })).toBeInViewport();
      const canvas = await page.getByTestId('pizarra-diagrama').boundingBox();
      expect(canvas!.height).toBeGreaterThanOrEqual(240);
      const crear = await page.getByTestId('crear-clase').boundingBox();
      if (viewport.width <= 640 || viewport.height <= 500)
        expect(crear!.height).toBeGreaterThanOrEqual(44);
      await comprobarAncho(page, testInfo, 'editor-vacio', viewport.width);
      await page.getByTestId('crear-clase').tap();
      await page.getByTestId('nombre-clase').fill('Cliente');
      await page.getByTestId('nuevo-atributo').fill('nombre');
      await page.getByRole('button', { name: 'Añadir', exact: true }).tap();
      await expect(page.getByTestId('clase-Cliente')).toContainText('nombre');
      await comprobarAncho(page, testInfo, 'editor-propiedades', viewport.width);

      for (const herramienta of ['importar', 'generar', 'asistente']) {
        await page.getByTestId(`pestana-${herramienta}`).tap();
        if (herramienta === 'generar') {
          const checkbox = page.getByTestId('incluir-flutter');
          const bounds = await checkbox.boundingBox();
          expect(bounds!.height).toBeLessThanOrEqual(20);
          expect(bounds!.width).toBeLessThanOrEqual(20);
          const label = page.locator('label.opcion-checkbox');
          expect((await label.boundingBox())!.height).toBeGreaterThanOrEqual(44);
          await label.tap();
          await expect(checkbox).toBeChecked();
          await page.getByTestId('pestana-importar').tap();
          await page.getByTestId('pestana-generar').tap();
          await expect(checkbox).toBeChecked();
          await label.tap();
          await expect(checkbox).not.toBeChecked();
        }
        await comprobarAncho(page, testInfo, `editor-${herramienta}`, viewport.width);
      }
      await page.getByTestId('alternar-panel').tap();
      await expect(page.locator('#panel-editor')).toBeHidden();
      await page.getByTestId('alternar-toolbox').tap();
      await expect(page.locator('#editor-toolbox')).toBeHidden();
      await comprobarAncho(page, testInfo, 'solo-diagrama', viewport.width);
      const lienzo = await page.getByTestId('pizarra-diagrama').boundingBox();
      expect(lienzo!.width).toBeGreaterThan(viewport.width - 5);
      await page.getByTestId('alternar-panel').tap();
      await expect(page.locator('#panel-editor')).toBeVisible();
      await page.getByTestId('salir').tap();
      await expect(page.getByTestId('email')).toBeVisible();
    });
  });
}

async function comprobarAncho(page: Page, info: TestInfo, paso: string, width: number) {
  const medidas = await page.evaluate(() => ({
    documentWidth: document.documentElement.scrollWidth,
    viewport: window.innerWidth,
    controlesFuera: [...document.querySelectorAll('button, input, select, textarea')]
      .filter((element) => !element.closest('.react-flow'))
      .filter((element) => {
        const rect = element.getBoundingClientRect();
        return rect.width > 0 && (rect.left < -1 || rect.right > window.innerWidth + 1);
      })
      .map((element) => element.getAttribute('data-testid') ?? element.textContent?.trim()),
  }));
  await info.attach(paso, { body: JSON.stringify(medidas), contentType: 'application/json' });
  await page.screenshot({ path: info.outputPath(`${paso}.png`), fullPage: true });
  expect.soft(medidas.documentWidth, `${paso}: ancho de documento`).toBeLessThanOrEqual(width + 1);
  expect.soft(medidas.controlesFuera, `${paso}: controles fuera de pantalla`).toEqual([]);
}
```

---

### `e2e/specs/notacion.spec.ts`

```ts
import { expect, test } from '@playwright/test';
import { abrirHerramienta, crearClase } from '../support/actors.js';
import { montarEscenario } from '../support/escenario.js';

/**
 * Notación UML 2.5 en el lienzo.
 *
 * Lo que se fija aquí es lo que distingue un diagrama de clases de un grafo
 * cualquiera: la caja con sus compartimentos, la línea recta, y cada
 * multiplicidad en el extremo al que pertenece. Antes las dos iban juntas en el
 * medio como «1 → 0..*», y había que recordar cuál era cuál.
 */
test.describe('notacion del diagrama', () => {
  test('la clase se dibuja con sus compartimentos y sus atributos en notacion UML', async ({
    browser,
  }) => {
    const escenario = await montarEscenario(browser, 'Notacion');
    try {
      await crearClase(escenario.ana, 'Persona');
      await escenario.ana.page.getByTestId('nuevo-atributo').fill('correo');
      await escenario.ana.page.getByRole('button', { name: 'Añadir' }).click();

      const caja = escenario.ana.page.getByTestId('clase-Persona');

      // Compartimento del nombre, separado del de atributos.
      await expect(caja.locator('header .nombre')).toHaveText('Persona');

      // `- correo: String`: visibilidad, nombre y tipo.
      const fila = caja.locator('.atributos li').first();
      await expect(fila.locator('.visibilidad')).toHaveText('-');
      await expect(fila.locator('.campo')).toContainText('correo');
      await expect(fila.locator('.tipo')).toHaveText('String');
    } finally {
      await escenario.cerrar();
    }
  });

  test('la relacion es una linea con una multiplicidad en cada extremo', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'Notacion relacion');
    try {
      await crearClase(escenario.ana, 'Persona');
      await crearClase(escenario.ana, 'Curso');

      await escenario.ana.page
        .getByTestId('clase-Persona')
        .locator('.react-flow__handle-right')
        .dragTo(escenario.ana.page.getByTestId('clase-Curso').locator('.react-flow__handle-left'));

      const arista = escenario.ana.page.locator('.react-flow__edge').first();

      // Dos etiquetas, una por extremo, y no una sola en el medio.
      const multiplicidades = arista.locator('text.multiplicidad');
      await expect(multiplicidades).toHaveCount(2);
      await expect(multiplicidades.nth(0)).toHaveText('1');
      await expect(multiplicidades.nth(1)).toHaveText('0..*');

      // Y el trazo es una recta: `getStraightPath` produce un `M … L …`, sin
      // curvas. Una Bezier sugiere un flujo, y esto es una asociación.
      const trazo = await arista.locator('path.asociacion-linea').getAttribute('d');
      expect(trazo).toMatch(/^M[\d\s.,-]+L[\d\s.,-]+$/);
    } finally {
      await escenario.cerrar();
    }
  });

  test('crea y conserva una asociacion recursiva como un bucle UML', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'Asociacion recursiva');
    try {
      await crearClase(escenario.ana, 'Materia');

      // Primera forma: herramienta, seleccionando dos veces la misma clase.
      await escenario.ana.page.getByTestId('tool-association').click();
      await escenario.ana.page.getByTestId('clase-Materia').click();
      await expect(escenario.ana.page.getByText(/Origen: Materia/)).toBeVisible();
      await escenario.ana.page.getByTestId('clase-Materia').click();

      const bucle = escenario.ana.page.locator('[data-relationship-kind="ASSOCIATION"]');
      await expect(bucle).toBeVisible();
      await expect(bucle.locator('text.multiplicidad')).toHaveCount(2);
      await expect(bucle.locator('text.multiplicidad').nth(0)).toHaveText('1');
      await expect(bucle.locator('text.multiplicidad').nth(1)).toHaveText('0..*');
      await expect(
        escenario.ana.page.getByRole('group', { name: 'Materia · origen' }),
      ).toBeVisible();
      await expect(
        escenario.ana.page.getByRole('group', { name: 'Materia · destino' }),
      ).toBeVisible();
      await escenario.ana.page.getByTestId('rol-origen').fill('jefe');
      await escenario.ana.page.getByTestId('rol-destino').fill('subordinados');
      await expect(bucle.locator('text.rol-asociacion')).toHaveText(['jefe', 'subordinados']);

      const bucleRemoto = escenario.beto.page.locator('[data-relationship-kind="ASSOCIATION"]');
      for (const rol of ['coordinador', 'responsable', 'jefe']) {
        await escenario.ana.page.getByTestId('rol-origen').fill(rol);
        await expect(bucleRemoto.locator('text.rol-asociacion')).toHaveText([rol, 'subordinados']);
        await escenario.beto.page.getByTestId('clase-Materia').click();
        await expect(bucleRemoto).toBeVisible();
      }

      // Es un bucle ortogonal de tres segmentos, no una linea que atraviesa la
      // caja ni una arista de longitud cero.
      await expect(bucle.locator('path.asociacion-linea')).toHaveAttribute(
        'd',
        /^M[\d\s.,-]+L[\d\s.,-]+L[\d\s.,-]+L[\d\s.,-]+$/,
      );

      // La relacion es parte del documento compartido, y sigue anclada al
      // mover la clase.
      await expect(
        escenario.beto.page.locator('[data-relationship-kind="ASSOCIATION"]'),
      ).toBeVisible();
      const materia = escenario.ana.page.getByTestId('clase-Materia');
      const posicion = await materia.boundingBox();
      expect(posicion).not.toBeNull();
      if (posicion === null) throw new Error('No se pudo medir Materia');
      await escenario.ana.page.mouse.move(posicion.x + 80, posicion.y + 12);
      await escenario.ana.page.mouse.down();
      await escenario.ana.page.mouse.move(posicion.x + 220, posicion.y + 100, { steps: 10 });
      await escenario.ana.page.mouse.up();
      await expect(bucle).toBeVisible();
      await expect(
        escenario.beto.page.locator('[data-relationship-kind="ASSOCIATION"]'),
      ).toBeVisible();

      // Segunda forma: desde los conectores de la propia clase. Se borra el
      // primer bucle para comprobar que no dependemos de la herramienta.
      const puntoSeleccion = await bucle.locator('path.asociacion-zona').evaluate((elemento) => {
        const path = elemento as unknown as {
          getTotalLength(): number;
          getPointAtLength(distancia: number): { x: number; y: number };
          getScreenCTM(): {
            a: number;
            b: number;
            c: number;
            d: number;
            e: number;
            f: number;
          } | null;
        };
        const punto = path.getPointAtLength(path.getTotalLength() / 2);
        const matriz = path.getScreenCTM();
        if (matriz === null) throw new Error('El bucle no tiene transformación SVG');
        return {
          x: matriz.a * punto.x + matriz.c * punto.y + matriz.e,
          y: matriz.b * punto.x + matriz.d * punto.y + matriz.f,
        };
      });
      await escenario.ana.page.mouse.click(puntoSeleccion.x, puntoSeleccion.y);
      await expect(escenario.ana.page.getByTestId('inspector-relacion')).toBeVisible();
      await escenario.ana.page.getByRole('button', { name: 'Eliminar relación' }).click();
      await expect(bucle).toHaveCount(0);
      await materia.click();
      const conectorOrigen = await materia.locator('.conector-rapido').boundingBox();
      const conectorDestino = await materia.locator('.conector-bucle-destino').boundingBox();
      expect(conectorOrigen).not.toBeNull();
      expect(conectorDestino).not.toBeNull();
      if (conectorOrigen === null || conectorDestino === null) {
        throw new Error('No se pudieron medir los conectores del bucle');
      }
      await escenario.ana.page.mouse.move(
        conectorOrigen.x + conectorOrigen.width / 2,
        conectorOrigen.y + conectorOrigen.height / 2,
      );
      await escenario.ana.page.mouse.down();
      await escenario.ana.page.mouse.move(
        conectorDestino.x + conectorDestino.width / 2,
        conectorDestino.y + conectorDestino.height / 2,
        { steps: 8 },
      );
      await escenario.ana.page.mouse.up();
      await expect(bucle).toBeVisible();
      await expect(
        escenario.beto.page.locator('[data-relationship-kind="ASSOCIATION"]'),
      ).toBeVisible();
    } finally {
      await escenario.cerrar();
    }
  });

  test('separa asociaciones paralelas con roles distintos', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'Relaciones paralelas');
    try {
      await crearClase(escenario.ana, 'Cliente');
      await crearClase(escenario.ana, 'Direccion');

      const relacionar = async (rol: string): Promise<void> => {
        await escenario.ana.page.getByTestId('tool-association').click();
        await escenario.ana.page.getByTestId('clase-Cliente').click();
        await escenario.ana.page.getByTestId('clase-Direccion').click();
        await escenario.ana.page.getByTestId('rol-origen').fill(rol);
      };

      await relacionar('domicilio');
      await relacionar('facturacion');

      const aristas = escenario.ana.page.locator('.react-flow__edge');
      await expect(aristas).toHaveCount(2);
      const primerTrazo = await aristas.nth(0).locator('path.asociacion-linea').getAttribute('d');
      const segundoTrazo = await aristas.nth(1).locator('path.asociacion-linea').getAttribute('d');
      expect(primerTrazo).not.toBe(segundoTrazo);

      const roles = await aristas.locator('text.rol-asociacion').allTextContents();
      expect(roles.sort()).toEqual(['domicilio', 'facturacion']);
      await expect(escenario.beto.page.locator('.react-flow__edge')).toHaveCount(2);
      await expect(escenario.ana.page.getByTestId('puede-generar')).toHaveText(
        'Generación disponible',
      );
    } finally {
      await escenario.cerrar();
    }
  });

  test('el toolbox coloca clases y crea una composicion eligiendo sus extremos', async ({
    browser,
  }) => {
    const escenario = await montarEscenario(browser, 'Toolbox UML');
    try {
      await escenario.ana.page.setViewportSize({ width: 1366, height: 768 });
      // Primera forma de crear: se arma Clase y se coloca en el punto elegido.
      await escenario.ana.page.getByTestId('tool-class').click();
      await expect(escenario.ana.page.getByTestId('modo-lienzo')).toContainText(
        'Haz clic para colocarla',
      );
      await escenario.ana.page
        .getByTestId('pizarra-diagrama')
        .locator('.react-flow__pane')
        .click({ position: { x: 260, y: 190 } });
      await escenario.ana.page.getByTestId('nombre-clase').fill('Pedido');

      await crearClase(escenario.ana, 'Detalle');

      // Segunda forma de relacionar: herramienta, origen y destino.
      await escenario.ana.page.getByTestId('tool-composition').click();
      await escenario.ana.page.getByTestId('clase-Pedido').click();
      await expect(escenario.ana.page.getByText(/Origen: Pedido/)).toBeVisible();
      await escenario.ana.page.getByTestId('clase-Detalle').click();

      const composicion = escenario.ana.page.locator('[data-relationship-kind="COMPOSITION"]');
      await expect(composicion).toBeVisible();
      await expect(composicion.locator('.marcador-relacion.diamante.relleno')).toHaveCount(1);
      await expect(escenario.ana.page.getByTestId('tipo-relacion')).toHaveValue('COMPOSITION');

      // El tipo no es decoracion local: el otro participante recibe la misma
      // relacion y la dibuja con el mismo diamante sin recargar.
      await expect(
        escenario.beto.page.locator('[data-relationship-kind="COMPOSITION"]'),
      ).toBeVisible();

      // Al cruzar el origen al otro lado del destino, la geometria pasa de
      // usar su conector derecho al izquierdo. La relacion debe seguir
      // resolviendo ambos extremos y conservar el diamante de composicion.
      const pedido = escenario.ana.page.getByTestId('clase-Pedido');
      const posicionInicial = await pedido.boundingBox();
      expect(posicionInicial).not.toBeNull();
      if (posicionInicial === null) {
        throw new Error('No se pudo determinar la posicion de Pedido');
      }

      await escenario.ana.page.mouse.move(
        posicionInicial.x + posicionInicial.width / 2,
        posicionInicial.y + 12,
      );
      await escenario.ana.page.mouse.down();
      await escenario.ana.page.mouse.move(
        posicionInicial.x + posicionInicial.width / 2 + 430,
        posicionInicial.y + 12,
        { steps: 15 },
      );
      await escenario.ana.page.mouse.up();

      await expect(composicion).toBeVisible();
      await expect(composicion.locator('.marcador-relacion.diamante.relleno')).toHaveCount(1);
      await expect(
        escenario.beto.page.locator('[data-relationship-kind="COMPOSITION"]'),
      ).toBeVisible();
    } finally {
      await escenario.cerrar();
    }
  });

  test('la generalizacion se dibuja con su triangulo y dice que hereda la subclase', async ({
    browser,
  }) => {
    const escenario = await montarEscenario(browser, 'Generalizacion');
    try {
      await crearClase(escenario.ana, 'Persona');
      await escenario.ana.page.getByTestId('nuevo-atributo').fill('nombre');
      await escenario.ana.page.getByRole('button', { name: 'Añadir' }).click();

      await crearClase(escenario.ana, 'Estudiante');
      await escenario.ana.page.getByTestId('nuevo-atributo').fill('matricula');
      await escenario.ana.page.getByRole('button', { name: 'Añadir' }).click();

      // La subclase es el origen: se elige primero, como pide el inspector.
      await escenario.ana.page.getByTestId('tool-generalization').click();
      await escenario.ana.page.getByTestId('clase-Estudiante').click();
      await escenario.ana.page.getByTestId('clase-Persona').click();

      const generalizacion = escenario.ana.page.locator(
        '[data-relationship-kind="GENERALIZATION"]',
      );
      await expect(generalizacion).toBeVisible();

      // Triangulo hueco, y ninguna multiplicidad: en una generalizacion no
      // significan nada.
      await expect(generalizacion.locator('.marcador-relacion.triangulo')).toHaveCount(1);
      await expect(generalizacion.locator('text.multiplicidad')).toHaveCount(0);

      // Y desde que la herencia se genera de verdad (RM-07), la tarjeta de la
      // subclase no cuenta toda la historia: la clave primaria y el resto de
      // columnas vienen de arriba, y eso hay que poder verlo sin abrir el ZIP.
      await escenario.ana.page.getByTestId('clase-Estudiante').click();
      const herencia = escenario.ana.page.getByTestId('herencia-clase');
      await expect(herencia).toContainText('Hereda de');
      await expect(herencia).toContainText('Persona');
      await expect(herencia.locator('.atributos-heredados li')).toContainText(['nombre']);

      // La superclase ve la relacion desde el otro lado.
      await escenario.ana.page.getByTestId('clase-Persona').click();
      await expect(escenario.ana.page.getByTestId('herencia-clase')).toContainText('Estudiante');
    } finally {
      await escenario.cerrar();
    }
  });

  test('la camara se abre en el panel y ofrece tomar la foto', async ({ browser }) => {
    // No se comprueba la foto en si: eso necesitaria una camara de verdad. Lo
    // que se fija aqui es que el boton existe, que abre la vista dentro del
    // panel —y no en un dialogo que tape el diagrama— y que un equipo sin
    // camara lo dice en vez de quedarse en blanco.
    const escenario = await montarEscenario(browser, 'Camara');
    try {
      const page = escenario.ana.page;
      await abrirHerramienta(escenario.ana, 'importar');

      await expect(page.getByTestId('importar-imagen')).toHaveText('Subir foto');
      await page.getByTestId('abrir-camara').click();

      const camara = page.getByTestId('camara');
      await expect(camara).toBeVisible();

      // Chromium sin dispositivo falla con NotFoundError, y el mensaje tiene
      // que llevar a la salida: subir el archivo.
      await expect(
        camara.getByTestId('tomar-foto').or(page.getByTestId('error-camara')),
      ).toBeVisible();
    } finally {
      await escenario.cerrar();
    }
  });
});
```

---

### `e2e/specs/proyectos-navegacion.spec.ts`

```ts
import { expect, test } from '@playwright/test';

test('cambiar de proyecto descarta respuestas e invitaciones del proyecto anterior', async ({
  page,
}) => {
  const firstId = '11111111-1111-4111-8111-111111111111';
  const secondId = '22222222-2222-4222-8222-222222222222';
  const user = {
    id: '33333333-3333-4333-8333-333333333333',
    email: 'ana@example.com',
    displayName: 'Ana',
  };
  let holdFirst = false;
  let requested!: () => void;
  let release!: () => void;
  const pendingRequest = new Promise<void>((resolve) => {
    requested = resolve;
  });
  const responseGate = new Promise<void>((resolve) => {
    release = resolve;
  });

  await page.route('**/api/**', async (route) => {
    const path = new URL(route.request().url()).pathname;
    if (path.endsWith('/auth/refresh')) {
      await route.fulfill({ json: { accessToken: 'test-token', user } });
    } else if (path.endsWith('/auth/me')) {
      await route.fulfill({ json: user });
    } else if (path === `/api/projects/${firstId}/invites` && route.request().method() === 'POST') {
      await route.fulfill({ json: { code: 'invitacion-primer-proyecto' } });
    } else if (path === `/api/projects/${firstId}` || path === `/api/projects/${secondId}`) {
      const first = path.endsWith(firstId);
      if (first && holdFirst) {
        requested();
        await responseGate;
      }
      await route.fulfill({
        json: {
          id: first ? firstId : secondId,
          displayName: first ? 'Proyecto anterior' : 'Proyecto actual',
          role: 'OWNER',
          boards: [],
        },
      });
    } else {
      await route.fulfill({ json: [] });
    }
  });

  try {
    await page.goto(`/proyectos/${firstId}`);
    await expect(page.getByRole('heading', { name: 'Proyecto anterior' })).toBeVisible();
    await page.getByTestId('invitar-editor').click();
    await expect(page.getByTestId('codigo-generado')).toHaveText('invitacion-primer-proyecto');
    holdFirst = true;
    await page.evaluate(() => window.dispatchEvent(new Event('focus')));
    await pendingRequest;
    // Simula una transición del historial que React Router resuelve sin recargar.
    await page.evaluate((id) => {
      window.history.pushState({}, '', `/proyectos/${id}`);
      window.dispatchEvent(new PopStateEvent('popstate'));
    }, secondId);
    await expect(page.getByRole('heading', { name: 'Proyecto actual' })).toBeVisible();
    const oldResponse = page.waitForResponse(
      (response) => new URL(response.url()).pathname === `/api/projects/${firstId}`,
    );
    release();
    await oldResponse;
    // Da al cliente oportunidad de consumir el JSON y a React de pintarlo.
    await page.evaluate(
      () =>
        new Promise<void>((resolve) =>
          requestAnimationFrame(() => requestAnimationFrame(() => resolve())),
        ),
    );
    await expect(page.getByRole('heading', { name: 'Proyecto actual' })).toBeVisible();
    await expect(page.getByTestId('codigo-generado')).toHaveCount(0);
  } finally {
    release();
    await page.unrouteAll({ behavior: 'wait' });
  }
});
```

---

### `e2e/specs/proyectos.spec.ts`

```ts
import { expect, test } from '@playwright/test';
import { crearPizarra, crearProyecto, registrarActor } from '../support/actors.js';

/**
 * Administrar proyectos y pizarras desde la interfaz (RF-001 y RF-003).
 *
 * Las rutas existían desde la fase 3 y estaban probadas por HTTP, pero **no
 * había forma de llegar a ellas desde el navegador**: se podía crear una pizarra
 * y nunca renombrarla ni borrarla. Se descubrió comparando la aplicación con el
 * manual de usuario de otro proyecto de la misma materia.
 *
 * Borrar pide escribir el nombre: no hay papelera, y un «¿seguro?» se acepta sin
 * leerlo. Estas pruebas responden al `prompt` como lo haría la persona.
 */
test.describe('administrar proyectos y pizarras', () => {
  test('dos pestanas de la misma cuenta pueden renovar su sesion a la vez', async ({ browser }) => {
    const ana = await registrarActor(browser, 'multipestana');
    try {
      const second = await ana.page.context().newPage();
      await Promise.all([ana.page.reload(), second.goto('/proyectos')]);
      await expect(ana.page.getByTestId('lista-proyectos')).toBeVisible();
      await expect(second.getByTestId('lista-proyectos')).toBeVisible();
    } finally {
      await ana.close();
    }
  });
  test('un proyecto inexistente muestra el error y permite volver', async ({ browser }) => {
    const ana = await registrarActor(browser, 'ana');
    try {
      await ana.page.goto('/proyectos/00000000-0000-4000-8000-000000000000');
      await expect(ana.page.getByRole('alert')).toBeVisible();
      await expect(ana.page.getByText('Cargando el proyecto…')).toHaveCount(0);
      await ana.page.getByRole('link', { name: 'Volver a mis proyectos' }).click();
      await expect(ana.page.getByTestId('lista-proyectos')).toBeVisible();
    } finally {
      await ana.close();
    }
  });
  test('RF-003 — una pizarra se renombra desde la lista', async ({ browser }) => {
    const ana = await registrarActor(browser, 'ana');
    try {
      await crearProyecto(ana, 'Con pizarras');
      await crearPizarra(ana, 'Ventas');

      ana.page.once('dialog', (dialogo) => void dialogo.accept('Ventas y Compras'));
      await ana.page.getByTestId('renombrar-Ventas').click();

      await expect(ana.page.getByRole('link', { name: 'Ventas y Compras' })).toBeVisible();
      await expect(ana.page.getByRole('link', { name: 'Ventas', exact: true })).toHaveCount(0);
    } finally {
      await ana.close();
    }
  });

  test('RF-003 — una pizarra se elimina, escribiendo su nombre', async ({ browser }) => {
    const ana = await registrarActor(browser, 'ana');
    try {
      await crearProyecto(ana, 'Para borrar');
      await crearPizarra(ana, 'Sobrante');
      await crearPizarra(ana, 'Se queda');

      ana.page.once('dialog', (dialogo) => void dialogo.accept('Sobrante'));
      await ana.page.getByTestId('eliminar-pizarra-Sobrante').click();

      await expect(ana.page.getByRole('link', { name: 'Sobrante' })).toHaveCount(0);
      await expect(ana.page.getByRole('link', { name: 'Se queda' })).toBeVisible();
    } finally {
      await ana.close();
    }
  });

  test('escribir mal el nombre no borra nada', async ({ browser }) => {
    const ana = await registrarActor(browser, 'ana');
    try {
      await crearProyecto(ana, 'Sin accidentes');
      await crearPizarra(ana, 'Importante');

      // Es la razón de pedir el nombre: un clic distraído no puede llevarse un
      // diagrama por delante.
      ana.page.once('dialog', (dialogo) => void dialogo.accept('importante'));
      await ana.page.getByTestId('eliminar-pizarra-Importante').click();

      await expect(ana.page.getByRole('link', { name: 'Importante' })).toBeVisible();
    } finally {
      await ana.close();
    }
  });

  test('cancelar el diálogo tampoco borra', async ({ browser }) => {
    const ana = await registrarActor(browser, 'ana');
    try {
      await crearProyecto(ana, 'Cancelado');
      await crearPizarra(ana, 'Intacta');

      ana.page.once('dialog', (dialogo) => void dialogo.dismiss());
      await ana.page.getByTestId('eliminar-pizarra-Intacta').click();

      await expect(ana.page.getByRole('link', { name: 'Intacta' })).toBeVisible();
    } finally {
      await ana.close();
    }
  });

  test('RF-001 — un proyecto se elimina con sus pizarras', async ({ browser }) => {
    const ana = await registrarActor(browser, 'ana');
    try {
      await crearProyecto(ana, 'Desechable');
      await crearPizarra(ana, 'Una');
      await ana.page.goto('/proyectos');

      ana.page.once('dialog', (dialogo) => void dialogo.accept('Desechable'));
      await ana.page.getByTestId('eliminar-proyecto-Desechable').click();

      await expect(ana.page.getByRole('link', { name: /Desechable/ })).toHaveCount(0);
    } finally {
      await ana.close();
    }
  });

  test('un lector no ve las acciones de administrar', async ({ browser }) => {
    const ana = await registrarActor(browser, 'ana');
    const beto = await registrarActor(browser, 'beto');
    try {
      const projectId = await crearProyecto(ana, 'Solo lectura');
      await crearPizarra(ana, 'Ventas');

      await ana.page.getByTestId('invitar-lector').click();
      const codigo = (await ana.page.getByTestId('codigo-generado').textContent()) as string;

      await beto.page.goto('/proyectos');
      await beto.page.getByTestId('codigo-invitacion').fill(codigo);
      await beto.page.getByTestId('aceptar-invitacion').click();
      await beto.page.goto(`/proyectos/${projectId}`);

      // El servidor lo rechazaría igualmente; no ofrecerlo evita el intento.
      await expect(beto.page.getByRole('link', { name: 'Ventas' })).toBeVisible();
      await expect(beto.page.getByTestId('renombrar-Ventas')).toHaveCount(0);
      await expect(beto.page.getByTestId('eliminar-pizarra-Ventas')).toHaveCount(0);
      await expect(beto.page.getByTestId('eliminar-proyecto-Solo lectura')).toHaveCount(0);
    } finally {
      await ana.close();
      await beto.close();
    }
  });

  test('se puede cerrar sesion desde el editor', async ({ browser }) => {
    const ana = await registrarActor(browser, 'ana');
    try {
      await crearProyecto(ana, 'Con salida');
      await crearPizarra(ana, 'Ventas');
      await ana.page.getByRole('link', { name: 'Ventas' }).click();

      await ana.page.getByTestId('salir').click();

      // Tener que volver a la lista de proyectos para salir invita a dejar la
      // sesión abierta en una máquina compartida.
      await expect(ana.page.getByTestId('email')).toBeVisible();
    } finally {
      await ana.close();
    }
  });
});
```

---

### `e2e/specs/recorrido-interactivo.spec.ts`

```ts
import { expect, test, type Page } from '@playwright/test';
import {
  abrirHerramienta,
  abrirPizarra,
  crearClase,
  crearPizarra,
  crearProyecto,
  registrarActor,
  invitar,
  aceptarInvitacion,
} from '../support/actors.js';

async function startTour(page: Page, resume = false) {
  await page.getByRole('button', { name: 'Aprender a usar el software' }).click();
  await page
    .getByRole('button', {
      name: resume ? 'Retomar recorrido interactivo' : 'Guiarme en esta pantalla',
    })
    .click();
  return page.locator('.tour-coach');
}

test('acompaña acciones reales de proyecto a pizarra, detecta escritura y permite retomar', async ({
  browser,
}) => {
  const actor = await registrarActor(browser, 'tour');
  const { page } = actor;
  try {
    const coach = await startTour(page);
    await expect(coach.getByRole('heading', { name: 'Ponle nombre a tu proyecto' })).toBeVisible();
    await expect(page.getByTestId('lista-proyectos').locator('li.tarjeta-recurso')).toHaveCount(0);
    await expect(page.getByTestId('nombre-proyecto')).toHaveValue('');
    await expect(coach.getByRole('button', { name: 'Siguiente' })).toBeDisabled();
    await coach.getByRole('button', { name: 'Ir al control' }).click();
    await expect(page.getByTestId('nombre-proyecto')).toBeFocused();
    await page.getByTestId('nombre-proyecto').fill('Proyecto guiado');
    await expect(coach.getByRole('status')).toContainText('Acción detectada');
    await coach.getByRole('button', { name: 'Siguiente' }).click();
    await page.getByTestId('crear-proyecto').click();
    await expect(coach.getByRole('heading', { name: 'Nombra tu diagrama' })).toBeVisible();
    await page.getByTestId('nombre-pizarra').fill('Diagrama guiado');
    await coach.getByRole('button', { name: 'Siguiente' }).click();
    await page.getByTestId('crear-pizarra').click();
    await expect(page.getByRole('link', { name: 'Diagrama guiado' })).toBeVisible();
    await coach.getByRole('button', { name: 'Siguiente' }).click();
    await page.getByRole('link', { name: 'Diagrama guiado' }).click();
    await expect(page.getByTestId('estado-conexion')).toHaveText('En vivo');
    await expect(coach.getByRole('heading', { name: 'Añade tu primera clase' })).toBeVisible();
    await page.getByTestId('crear-clase').click();
    await coach.getByRole('button', { name: 'Siguiente' }).click();
    await expect(
      coach.getByRole('heading', { name: 'Dale un nombre que describa el concepto' }),
    ).toBeVisible();
    await page.getByTestId('nombre-clase').fill('Cliente guiado');
    await page.keyboard.press('Escape');
    await expect(coach).not.toBeVisible();
    await expect(page.getByRole('button', { name: 'Aprender a usar el software' })).toBeFocused();
    await page.reload();
    await expect(page.getByTestId('estado-conexion')).toHaveText('En vivo');
    await startTour(page, true);
    await expect(
      coach.getByRole('heading', { name: 'Dale un nombre que describa el concepto' }),
    ).toBeVisible();
    await expect(coach.getByRole('status')).toContainText('Selecciona una clase');
    await coach.getByRole('button', { name: 'Omitir paso' }).click();
    await expect(coach.getByRole('heading', { name: 'Describe sus datos' })).toBeVisible();
  } finally {
    await actor.close();
  }
});

test('revela paneles sin modificar datos, se adapta al tamaño y finaliza sin generar', async ({
  browser,
}) => {
  const actor = await registrarActor(browser, 'tour-panel');
  const { page } = actor;
  try {
    await crearProyecto(actor, 'Recorrido de paneles');
    await crearPizarra(actor, 'Paneles');
    await abrirPizarra(actor, 'Paneles');
    await crearClase(actor, 'Cliente');
    await page.getByTestId('alternar-panel').click();
    const coach = await startTour(page);
    await coach.getByRole('button', { name: 'Omitir paso' }).click();
    await expect(coach.getByRole('button', { name: 'Mostrar control' })).toBeVisible();
    await coach.getByRole('button', { name: 'Mostrar control' }).click();
    await expect(page.getByTestId('nombre-clase')).toBeVisible();
    await expect(page.getByTestId('nombre-clase')).toBeFocused();
    await expect(page.getByTestId('nombre-clase')).toHaveValue('Cliente');
    for (const width of [320, 768, 1440]) {
      await page.setViewportSize({ width, height: 800 });
      await expect(page.getByTestId('tour-spotlight')).toBeVisible();
      const box = await coach.boundingBox();
      expect(box!.x).toBeGreaterThanOrEqual(0);
      expect(box!.x + box!.width).toBeLessThanOrEqual(width);
      expect(box!.y + box!.height).toBeLessThanOrEqual(801);
      expect(await coach.evaluate((element) => element.scrollWidth <= element.clientWidth)).toBe(
        true,
      );
    }
    await coach.getByRole('button', { name: 'Pausar recorrido' }).click();
    await abrirHerramienta(actor, 'generar');
    await startTour(page);
    await expect(
      coach.getByRole('heading', { name: 'Elige lo que vas a construir' }),
    ).toBeVisible();
    await expect(page.getByTestId('incluir-flutter')).not.toBeChecked();
    await coach.getByRole('button', { name: 'Siguiente' }).click();
    await coach.getByRole('button', { name: 'Terminar recorrido' }).click();
    await expect(coach.getByRole('heading', { name: 'Recorrido terminado' })).toBeVisible();
    await expect(page.getByTestId('descargar-spring')).toHaveCount(0);
    await coach.getByRole('button', { name: 'Cerrar recorrido' }).click();
    await expect(page.getByTestId('clase-Cliente')).toBeVisible();
  } finally {
    await actor.close();
  }
});

test('lector puede omitir controles bloqueados sin ejecutar acciones de edición', async ({
  browser,
}) => {
  const owner = await registrarActor(browser, 'tour-owner');
  const reader = await registrarActor(browser, 'tour-reader');
  try {
    await crearProyecto(owner, 'Recorrido lector');
    await crearPizarra(owner, 'Solo lectura');
    const code = await invitar(owner, 'lector');
    await aceptarInvitacion(reader, code);
    await abrirPizarra(reader, 'Solo lectura');
    const coach = await startTour(reader.page);
    await expect(coach.getByRole('status')).toContainText('no está disponible');
    await expect(coach.getByRole('button', { name: 'Ir al control' })).toBeDisabled();
    await coach.getByRole('button', { name: 'Omitir paso' }).click();
    await expect(
      coach.getByRole('heading', { name: 'Dale un nombre que describa el concepto' }),
    ).toBeVisible();
    await reader.page.keyboard.press('Escape');
    await expect(reader.page.locator('.react-flow__node')).toHaveCount(0);
  } finally {
    await owner.close();
    await reader.close();
  }
});
```

---

### `e2e/specs/revision-colaboracion-xmi.spec.ts`

```ts
import { expect, test } from '@playwright/test';
import { abrirHerramienta, crearClase } from '../support/actors.js';
import { montarEscenario } from '../support/escenario.js';

const xmi = (content: string): string =>
  `<xmi:XMI xmlns:xmi="x" xmlns:uml="u"><uml:Model xmi:type="uml:Model" name="Revisión">${content}</uml:Model></xmi:XMI>`;
const claseNueva = xmi('<packagedElement xmi:type="uml:Class" xmi:id="new" name="Importada"/>');

for (const cambio of ['atributo', 'clase'] as const) {
  test(`reemplazar XMI exige revisar otra vez si otro usuario añade una ${cambio === 'clase' ? 'clase' : 'propiedad'}`, async ({
    browser,
  }) => {
    const scenario = await montarEscenario(browser, `Reemplazo concurrente ${cambio}`);
    const { ana, beto } = scenario;
    try {
      await crearClase(ana, 'Cliente');
      await expect(beto.page.getByTestId('clase-Cliente')).toBeVisible();
      await abrirHerramienta(ana, 'importar');
      await ana.page.getByTestId('modo-importacion').selectOption('REPLACE');
      await ana.page.getByTestId('archivo-xmi').setInputFiles({
        name: 'nuevo.xmi',
        mimeType: 'application/xml',
        buffer: Buffer.from(claseNueva),
      });
      await expect(ana.page.getByTestId('aplicar-candidato')).toBeEnabled();
      await expect(ana.page.getByTestId('modo-importacion')).toBeDisabled();
      if (cambio === 'atributo') {
        await beto.page.getByTestId('clase-Cliente').click();
        await beto.page.getByTestId('nuevo-atributo').fill('datoReciente');
        await beto.page.getByRole('button', { name: 'Añadir', exact: true }).click();
        await expect(ana.page.getByTestId('clase-Cliente')).toContainText('datoReciente');
      } else {
        await crearClase(beto, 'Producto');
        await expect(ana.page.getByTestId('clase-Producto')).toBeVisible();
      }
      await ana.page.getByTestId('aplicar-candidato').click();
      await expect(ana.page.getByTestId('error-importacion')).toContainText('La pizarra cambió');
      await expect(ana.page.getByTestId('aplicar-candidato')).toBeDisabled();
      for (const actor of [ana, beto]) {
        await expect(actor.page.getByTestId('clase-Cliente')).toBeVisible();
        await expect(actor.page.getByTestId('clase-Importada')).toHaveCount(0);
      }
      await ana.page.getByTestId('repreparar-importacion').click();
      await expect(ana.page.getByTestId('aplicar-candidato')).toBeEnabled();
      await ana.page.getByTestId('aplicar-candidato').click();
      for (const actor of [ana, beto]) {
        await expect(actor.page.getByTestId('clase-Importada')).toBeVisible();
        await expect(actor.page.getByTestId('clase-Cliente')).toHaveCount(0);
        await expect(actor.page.getByTestId('clase-Producto')).toHaveCount(0);
      }
    } finally {
      await scenario.cerrar();
    }
  });
}

test('corrige atributos XMI que colisionan antes de compartirlos', async ({ browser }) => {
  const scenario = await montarEscenario(browser, 'Atributos XMI');
  try {
    const xml = xmi(
      '<packagedElement xmi:type="uml:Class" xmi:id="a" name="Venta"><ownedAttribute xmi:id="a1" name="fecha de venta" type="Date"/><ownedAttribute xmi:id="a2" name="fechaVenta" type="Date"/></packagedElement>',
    );
    await abrirHerramienta(scenario.ana, 'importar');
    await scenario.ana.page.getByTestId('archivo-xmi').setInputFiles({
      name: 'atributos.xmi',
      mimeType: 'application/xml',
      buffer: Buffer.from(xml),
    });
    await expect(scenario.ana.page.getByTestId('aplicar-candidato')).toBeEnabled();
    await scenario.ana.page
      .getByRole('textbox', { name: 'Nombre de atributo 3', exact: true })
      .fill('fechaPago');
    await scenario.ana.page.getByTestId('aplicar-candidato').click();
    for (const actor of [scenario.ana, scenario.beto]) {
      await expect(actor.page.getByTestId('clase-Venta')).toContainText('fecha de venta');
      await expect(actor.page.getByTestId('clase-Venta')).toContainText('fechaPago');
    }
  } finally {
    await scenario.cerrar();
  }
});

test('combina cambios concurrentes del nombre y tipo de un atributo y los conserva al recargar', async ({
  browser,
}) => {
  const scenario = await montarEscenario(browser, 'Campos concurrentes');
  const { ana, beto } = scenario;
  try {
    await crearClase(ana, 'Cliente');
    await ana.page.getByTestId('nuevo-atributo').fill('dato');
    await ana.page.getByRole('button', { name: 'Añadir', exact: true }).click();
    await expect(beto.page.getByTestId('clase-Cliente')).toContainText('dato');
    await beto.page.getByTestId('clase-Cliente').click();
    await ana.page.context().setOffline(true);
    await expect(ana.page.getByTestId('estado-conexion')).toHaveText('Sin conexión');
    await ana.page
      .getByRole('textbox', { name: 'Nombre del atributo dato', exact: true })
      .fill('edad');
    await beto.page
      .getByRole('combobox', { name: 'Tipo del atributo dato', exact: true })
      .selectOption('Integer');
    await ana.page.context().setOffline(false);
    for (const actor of [ana, beto]) {
      await expect(actor.page.getByTestId('estado-conexion')).toHaveText('En vivo');
      await expect(actor.page.getByTestId('clase-Cliente')).toContainText('edad');
      await expect(actor.page.getByTestId('clase-Cliente')).toContainText('Integer');
      await actor.page.reload();
      await expect(actor.page.getByTestId('clase-Cliente')).toContainText('edad');
      await expect(actor.page.getByTestId('clase-Cliente')).toContainText('Integer');
    }
  } finally {
    await ana.page.context().setOffline(false);
    await scenario.cerrar();
  }
});
```

---

### `e2e/specs/sesion.spec.ts`

```ts
import { expect, test } from '@playwright/test';
import { registrarActor } from '../support/actors.js';

test('restablecer con una sesion abierta permite volver al formulario de acceso', async ({
  browser,
}) => {
  const ana = await registrarActor(browser, 'restablecer');
  try {
    // La integracion prueba el consumo real del enlace. Aqui se aisla el estado
    // de React tras una recuperacion exitosa, sin enviar correo ni leer secretos.
    await ana.page.route('**/api/auth/password/reset', (route) =>
      route.fulfill({ json: { reset: true } }),
    );
    await ana.page.goto(`/restablecer?token=${'a'.repeat(64)}`);
    await ana.page.getByTestId('nueva-password').fill('contrasena-renovada');
    await ana.page.getByTestId('repetir-password').fill('contrasena-renovada');
    await ana.page.getByTestId('guardar-password').click();
    await expect(ana.page.getByTestId('password-restablecida')).toBeVisible();
    await ana.page.getByTestId('ir-a-entrar').click();
    await expect(ana.page).toHaveURL(/\/entrar$/);
    await expect(ana.page.getByTestId('password')).toBeVisible();
    await ana.page.reload();
    await expect(ana.page.getByTestId('password')).toBeVisible();
  } finally {
    await ana.close();
  }
});
```

---

### `e2e/specs/tarjetas.spec.ts`

```ts
import { expect, test } from '@playwright/test';
import {
  aceptarInvitacion,
  crearPizarra,
  crearProyecto,
  invitar,
  registrarActor,
} from '../support/actors.js';

/**
 * La tarjeta de un proyecto donde no eres propietario.
 *
 * La insignia del rol llevaba el rol en minúsculas como clase suelta, así que
 * un EDITOR obtenía `class="insignia-rol editor"` — y `.editor` es la clase del
 * armazón del editor UML, que declara `height: 100vh`. La insignia medía 720
 * píxeles y estiraba la tarjeta entera. Con OWNER no se veía, porque `.owner`
 * no choca con nada, y por eso ninguna prueba lo detectó: todas creaban sus
 * propios proyectos.
 */
test('la tarjeta de un proyecto ajeno tiene una altura normal', async ({ browser }) => {
  const ana = await registrarActor(browser, 'ana');
  const beto = await registrarActor(browser, 'beto');

  try {
    await crearProyecto(ana, 'Sistema de Ventas');
    await crearPizarra(ana, 'Diagrama de clases');
    const codigo = await invitar(ana, 'editor');
    await aceptarInvitacion(beto, codigo);

    await beto.page.goto('/proyectos');
    await expect(beto.page.getByTestId('lista-proyectos')).toBeVisible();

    // La insignia lleva el rol traducido desde `ROLE_LABEL`, no el valor del
    // contrato: `toHaveText` compara el texto del nodo y no ve la mayúscula que
    // aplica la hoja de estilo.
    const insignia = beto.page.locator('.insignia-rol').first();
    await expect(insignia).toHaveText('Editor');

    // Una insignia es una línea de texto. Cualquier cosa por encima de esto
    // significa que ha vuelto a heredar el alto de otra clase.
    const caja = await insignia.boundingBox();
    expect(caja).not.toBeNull();
    expect(caja!.height).toBeLessThan(40);

    // Y la tarjeta que la contiene tampoco se estira.
    const tarjeta = beto.page.locator('.tarjeta-recurso').first();
    const cajaTarjeta = await tarjeta.boundingBox();
    expect(cajaTarjeta!.height).toBeLessThan(220);
  } finally {
    await ana.close();
    await beto.close();
  }
});
```

---

### `e2e/specs/usabilidad-editor.spec.ts`

```ts
import { expect, test } from '@playwright/test';
import { crearClase, posicionEnDiagrama } from '../support/actors.js';
import { montarEscenario } from '../support/escenario.js';

test.describe('usabilidad del editor UML', () => {
  test('orienta una pizarra vacia y permite ganar espacio ocultando paneles', async ({
    browser,
  }) => {
    const escenario = await montarEscenario(browser, 'Editor amigable');
    try {
      await escenario.ana.page.setViewportSize({ width: 1280, height: 720 });
      const erroresDePagina: string[] = [];
      escenario.ana.page.on('pageerror', (error) => erroresDePagina.push(error.message));

      const vacio = escenario.ana.page.getByTestId('lienzo-vacio');
      await expect(vacio).toContainText('Empieza con una clase');
      await vacio.getByRole('button', { name: 'Crear primera clase' }).click();

      await expect(vacio).toHaveCount(0);
      await expect(escenario.ana.page.getByTestId('inspector-clase')).toBeVisible();
      await expect(escenario.ana.page.getByLabel('Nombre del nuevo atributo')).toBeVisible();

      await escenario.ana.page.getByTestId('tool-composition').click();
      await escenario.ana.page.getByRole('button', { name: /Cancelar/ }).click();
      await expect(escenario.ana.page.getByTestId('modo-lienzo')).toHaveCount(0);
      await expect(escenario.ana.page.getByTestId('tool-select')).toHaveAttribute(
        'aria-pressed',
        'true',
      );

      const tablero = escenario.ana.page.getByTestId('pizarra-diagrama');
      const anchoInicial = (await tablero.boundingBox())?.width ?? 0;

      const alternarToolbox = escenario.ana.page.getByTestId('alternar-toolbox');
      await alternarToolbox.click();
      await expect(alternarToolbox).toHaveAttribute('aria-expanded', 'false');
      await expect(escenario.ana.page.getByLabel('Caja de herramientas UML')).toBeHidden();

      const anchoSinToolbox = (await tablero.boundingBox())?.width ?? 0;
      expect(anchoSinToolbox).toBeGreaterThan(anchoInicial + 100);

      const alternarPanel = escenario.ana.page.getByTestId('alternar-panel');
      await alternarPanel.click();
      await expect(alternarPanel).toHaveAttribute('aria-expanded', 'false');
      await expect(escenario.ana.page.locator('#panel-editor')).toBeHidden();

      const anchoCompleto = (await tablero.boundingBox())?.width ?? 0;
      expect(anchoCompleto).toBeGreaterThan(anchoSinToolbox + 200);
      expect(erroresDePagina).toEqual([]);
    } finally {
      await escenario.cerrar();
    }
  });

  test('selecciona, mueve y elimina una clase con teclado y sincroniza el cambio', async ({
    browser,
  }) => {
    const escenario = await montarEscenario(browser, 'Teclado UML');
    try {
      await crearClase(escenario.ana, 'Cliente');
      const pagina = escenario.ana.page;
      const tarjeta = pagina.getByTestId('clase-Cliente');
      const nodo = pagina.locator('.react-flow__node', { has: tarjeta });

      await pagina
        .getByTestId('pizarra-diagrama')
        .locator('.react-flow__pane')
        .click({ position: { x: 20, y: 20 } });
      await nodo.focus();
      await pagina.keyboard.press('Enter');
      await expect(pagina.getByTestId('inspector-clase')).toBeVisible();

      const antes = await posicionEnDiagrama(escenario.beto, 'Cliente');
      await pagina.keyboard.press('ArrowRight');
      await expect
        .poll(async () => (await posicionEnDiagrama(escenario.beto, 'Cliente')).x)
        .toBeGreaterThan(antes.x);

      await pagina.keyboard.press('Delete');
      await expect(pagina.getByTestId('clase-Cliente')).toHaveCount(0);
      await expect(escenario.beto.page.getByTestId('clase-Cliente')).toHaveCount(0);
    } finally {
      await escenario.cerrar();
    }
  });

  test('expone ambos extremos UML y las pestanas responden a las flechas', async ({ browser }) => {
    const escenario = await montarEscenario(browser, 'Propiedades UML');
    try {
      await crearClase(escenario.ana, 'Pedido');
      await crearClase(escenario.ana, 'Cliente');

      // Una clase creada desde la barra siempre queda completa dentro del
      // lienzo, aunque la camara estuviera centrada en la anterior.
      await expect
        .poll(async () => {
          const tablero = await escenario.ana.page.getByTestId('pizarra-diagrama').boundingBox();
          const cliente = await escenario.ana.page
            .locator('.react-flow__node', {
              has: escenario.ana.page.getByTestId('clase-Cliente'),
            })
            .boundingBox();
          if (tablero === null || cliente === null) return false;
          return (
            cliente.x >= tablero.x &&
            cliente.x + cliente.width <= tablero.x + tablero.width &&
            cliente.y >= tablero.y &&
            cliente.y + cliente.height <= tablero.y + tablero.height
          );
        })
        .toBe(true);

      await escenario.ana.page
        .getByTestId('clase-Pedido')
        .locator('.react-flow__handle-right')
        .dragTo(
          escenario.ana.page.getByTestId('clase-Cliente').locator('.react-flow__handle-left'),
        );

      await expect(escenario.ana.page.getByTestId('rol-origen')).toBeVisible();
      await expect(escenario.ana.page.getByTestId('rol-destino')).toBeVisible();
      await escenario.ana.page.getByTestId('rol-origen').fill('pedidos');
      await escenario.ana.page.getByTestId('rol-destino').fill('cliente');
      await expect(escenario.ana.page.locator('.rol-asociacion')).toHaveCount(2);
      await expect(escenario.ana.page.locator('.rol-asociacion').nth(0)).toHaveText('pedidos');
      await expect(escenario.ana.page.locator('.rol-asociacion').nth(1)).toHaveText('cliente');

      await escenario.ana.page.getByTestId('tipo-relacion').selectOption('GENERALIZATION');
      await expect(escenario.ana.page.getByTestId('multiplicidad-origen')).toHaveCount(0);
      await expect(escenario.ana.page.getByTestId('multiplicidad-destino')).toHaveCount(0);
      await expect(escenario.ana.page.locator('.rol-asociacion')).toHaveCount(0);

      const pestanaAsistente = escenario.ana.page.getByTestId('pestana-asistente');
      await pestanaAsistente.focus();
      await escenario.ana.page.keyboard.press('End');
      await expect(escenario.ana.page.getByTestId('pestana-generar')).toHaveAttribute(
        'aria-selected',
        'true',
      );
      await expect(escenario.ana.page.locator('#panel-generar')).toBeVisible();
    } finally {
      await escenario.cerrar();
    }
  });

  test('mantiene los controles principales utilizables en una pantalla estrecha', async ({
    browser,
  }) => {
    const escenario = await montarEscenario(browser, 'Editor estrecho');
    try {
      await escenario.ana.page.setViewportSize({ width: 820, height: 720 });

      await expect(escenario.ana.page.getByTestId('pizarra-diagrama')).toBeVisible();
      await expect(escenario.ana.page.getByTestId('crear-clase')).toBeVisible();
      await expect(escenario.ana.page.getByTestId('alternar-toolbox')).toBeVisible();
      await expect(escenario.ana.page.getByTestId('alternar-panel')).toBeVisible();
      await expect(escenario.ana.page.locator('.react-flow__minimap')).toBeHidden();

      const tieneDesbordeHorizontal = await escenario.ana.page.evaluate(
        'document.documentElement.scrollWidth > window.innerWidth',
      );
      expect(tieneDesbordeHorizontal).toBe(false);
    } finally {
      await escenario.cerrar();
    }
  });
});
```

---

### `e2e/specs/voz.spec.ts`

```ts
import { expect, test, type Page } from '@playwright/test';
import { activarCuentaEIniciarSesion, nuevoCorreo } from '../support/actors.js';
import type { SpeechRecognitionLike } from '../../frontend/src/features/assistant/speech-session.js';

interface SpeechControl {
  starts: number;
  stops: number;
  aborts: number;
  result(text: string): void;
  end(): void;
  error(code: string): void;
}

async function abrirAsistente(page: Page) {
  // Se sustituye solo el servicio de reconocimiento. La interfaz, cuentas,
  // pizarra y colaboracion siguen usando los contenedores reales.
  await page.addInitScript(() => {
    const engines: SpeechRecognitionLike[] = [];
    const control: SpeechControl = {
      starts: 0,
      stops: 0,
      aborts: 0,
      result(text) {
        engines.at(-1)?.onresult?.({ results: [[{ transcript: text }]] });
      },
      end() {
        engines.at(-1)?.onend?.();
      },
      error(code) {
        engines.at(-1)?.onerror?.({ error: code });
      },
    };
    class Recognition implements SpeechRecognitionLike {
      lang = '';
      continuous = false;
      interimResults = false;
      onresult: SpeechRecognitionLike['onresult'] = null;
      onerror: SpeechRecognitionLike['onerror'] = null;
      onend: SpeechRecognitionLike['onend'] = null;
      start() {
        engines.push(this);
        control.starts++;
      }
      stop() {
        control.stops++;
        queueMicrotask(() => this.onend?.());
      }
      abort() {
        control.aborts++;
      }
    }
    Object.assign(window, { SpeechRecognition: Recognition, __speechTest: control });
  });

  const calls: { instruction?: string; question?: string }[] = [];
  // Ninguna de estas pruebas consume cuotas de proveedores de IA.
  await page.route(/\/api\/(?:boards\/[^/]+\/)?assistant\//, async (route) => {
    expect(route.request().url()).not.toContain('/transcribe');
    calls.push(route.request().postDataJSON() as (typeof calls)[number]);
    await route.fulfill({
      json: route.request().url().endsWith('/question')
        ? { answer: 'La pizarra está vacía.' }
        : { kind: 'QUESTION', question: '¿Qué atributo quieres añadir?', rationale: null },
    });
  });
  await page.goto('/entrar');
  await page.getByRole('button', { name: 'Crear cuenta', exact: true }).click();
  const email = nuevoCorreo('dictado');
  await page.getByTestId('email').fill(email);
  await page.getByTestId('displayName').fill('Dictado');
  await page.getByTestId('password').fill('contrasena-de-prueba');
  await page.getByTestId('enviar').click();
  await activarCuentaEIniciarSesion(page, email);
  await page.getByTestId('nombre-proyecto').fill('Voz');
  await page.getByTestId('crear-proyecto').click();
  await page.getByTestId('nombre-pizarra').fill('Dictado');
  await page.getByTestId('crear-pizarra').click();
  await page.getByRole('link', { name: 'Dictado', exact: true }).click();
  await expect(page.getByTestId('estado-conexion')).toHaveText('En vivo');
  await page.getByTestId('pestana-asistente').click();
  return calls;
}

async function voz(page: Page, action: 'result' | 'end' | 'error', text = '') {
  await page.evaluate(
    ({ action, text }) => {
      const control = (window as unknown as { __speechTest: SpeechControl }).__speechTest;
      if (action === 'end') control.end();
      else control[action](text);
    },
    { action, text },
  );
}

test('al agotar el contexto se revisa la solicitud completa sin descartar instrucciones ni gastar otra llamada', async ({
  page,
}) => {
  const calls = await abrirAsistente(page);
  const input = page.getByTestId('entrada-asistente');
  for (let i = 0; i < 6; i++) {
    await input.fill(i === 0 ? 'No borres Persona. Agrega correo.' : `Aclaracion ${i}`);
    await page.getByTestId('enviar-asistente').click();
    await expect(
      page.getByTestId('conversacion').getByText('¿Qué atributo quieres añadir?', { exact: true }),
    ).toHaveCount(i + 1);
  }
  await expect(page.getByTestId('revisar-contexto')).toBeVisible();
  await input.fill('Tambien conserva Estudiante.');
  await expect(page.getByTestId('enviar-asistente')).toBeDisabled();
  expect(calls).toHaveLength(6);
  await page.getByTestId('revisar-contexto').click();
  await expect(input).toHaveValue(/No borres Persona/);
  await expect(input).toHaveValue(/Aclaracion 1/);
  await expect(input).toHaveValue(/Aclaracion 5/);
  await expect(input).toHaveValue(/Tambien conserva Estudiante/);
  await expect(page.getByTestId('enviar-asistente')).toBeEnabled();
  expect(calls).toHaveLength(6);
});

test('las pausas no envían; Parar prepara el texto y Enviar hace una sola solicitud', async ({
  page,
}, info) => {
  const calls = await abrirAsistente(page);
  await page.getByTestId('dictar').click();
  await voz(page, 'result', 'eh, hola, por favor quiero que agregues correo a Cliente');
  await voz(page, 'end');
  await expect
    .poll(() =>
      page.evaluate(
        () => (window as unknown as { __speechTest: SpeechControl }).__speechTest.starts,
      ),
    )
    .toBe(2);
  await voz(page, 'result', 'no borres Venta');
  await expect(page.getByTestId('dictar')).toHaveText('Parar');
  await expect(page.getByTestId('entrada-asistente')).toHaveValue(/Cliente no borres Venta$/);
  await expect(page.getByTestId('enviar-asistente')).toBeDisabled();
  expect(calls).toHaveLength(0);

  await page.getByTestId('dictar').click();
  await expect(page.getByTestId('revision-dictado')).toBeVisible();
  await expect(page.getByTestId('entrada-asistente')).toHaveValue(
    'agregues correo a Cliente no borres Venta',
  );
  expect(calls).toHaveLength(0);
  await page.screenshot({ path: info.outputPath('dictado-revisable.png') });
  await page.getByTestId('enviar-asistente').dblclick();
  await expect(page.getByTestId('conversacion')).toContainText('¿Qué atributo quieres añadir?');
  expect(calls).toHaveLength(1);
  expect(calls[0]?.instruction).toBe('agregues correo a Cliente no borres Venta');
});

test('cancelar conserva el texto previo y recuperar original restaura todo el dictado', async ({
  page,
}) => {
  const calls = await abrirAsistente(page);
  const input = page.getByTestId('entrada-asistente');
  await input.fill('No borres Cliente.');
  await page.getByTestId('dictar').click();
  await voz(page, 'result', 'agrega correo');
  await page.getByRole('button', { name: 'Cancelar dictado' }).click();
  await expect(input).toHaveValue('No borres Cliente.');
  await voz(page, 'result', 'resultado tardío');
  await expect(input).toHaveValue('No borres Cliente.');
  await input.fill('');
  await page.getByTestId('dictar').click();
  const original = 'hola, por favor quiero que agregues email String a Cliente';
  await voz(page, 'result', original);
  await page.getByTestId('dictar').click();
  await page.getByRole('button', { name: 'Recuperar dictado original' }).click();
  await expect(input).toHaveValue(original);
  expect(calls).toHaveLength(0);
});

test('un dictado largo se conserva completo y pide acortarlo antes de gastar una solicitud', async ({
  page,
}) => {
  const calls = await abrirAsistente(page);
  const original = 'agrega nombre String. '.repeat(100) + 'No elimines Persona.';
  await page.getByTestId('dictar').click();
  await voz(page, 'result', original);
  await page.getByTestId('dictar').click();
  await expect(page.getByTestId('entrada-asistente')).toHaveValue(original);
  await expect(page.getByTestId('enviar-asistente')).toBeDisabled();
  await expect(page.getByText(/Acorta el texto antes de enviar/)).toBeVisible();
  expect(calls).toHaveLength(0);
});

test('denegar el micrófono no envía ni pierde el borrador y Consultar usa su ruta', async ({
  page,
}) => {
  const calls = await abrirAsistente(page);
  const draft = '  Hola, por favor quiero que no borres Cliente.  ';
  await page.getByTestId('entrada-asistente').fill(draft);
  await page.getByTestId('dictar').click();
  await voz(page, 'error', 'not-allowed');
  await expect(page.getByText(/Revisa el permiso del navegador/)).toBeVisible();
  await expect(page.getByTestId('entrada-asistente')).toHaveValue(draft);
  expect(calls).toHaveLength(0);
  await page.getByTestId('modo-preguntar').click();
  await page.getByTestId('entrada-asistente').fill('');
  await page.getByTestId('dictar').click();
  await voz(page, 'result', '¿Cuántas clases hay?');
  await page.getByTestId('dictar').click();
  expect(calls).toHaveLength(0);
  await page.getByTestId('enviar-asistente').click();
  await expect(page.getByTestId('conversacion')).toContainText('La pizarra está vacía.');
  expect(calls).toEqual([
    { question: '¿Cuántas clases hay?', model: { classes: [], relationships: [] } },
  ]);
});

test('cancelar la solicitud recupera el texto y evita mostrar respuestas tardías', async ({
  page,
}) => {
  await abrirAsistente(page);
  let release!: () => void;
  const waiting = new Promise<void>((resolve) => {
    release = resolve;
  });
  let started = false;
  await page.route('**/assistant/question', async (route) => {
    started = true;
    await waiting;
    await route
      .fulfill({ json: { answer: 'Respuesta tardía que debe ignorarse.' } })
      .catch(() => undefined);
  });
  try {
    await page.getByTestId('modo-preguntar').click();
    await page.getByTestId('entrada-asistente').fill('¿Qué atributos faltan?');
    await page.getByTestId('enviar-asistente').click();
    await expect.poll(() => started).toBe(true);
    await page.getByTestId('cancelar-solicitud').click();
    await expect(page.getByTestId('entrada-asistente')).toHaveValue('¿Qué atributos faltan?');
    await expect(page.getByTestId('enviar-asistente')).toBeEnabled();
    release();
    await expect(page.getByTestId('conversacion')).toContainText('Solicitud cancelada');
    await expect(page.getByTestId('conversacion')).not.toContainText('Respuesta tardía');
  } finally {
    release();
  }
});
```

---

### `e2e/specs/xmi-asociativa.spec.ts`

```ts
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { expect, test } from '@playwright/test';
import { parseXmi } from '@uml/xmi';
import { abrirHerramienta } from '../support/actors.js';
import { montarEscenario } from '../support/escenario.js';

test('PracticaProbar importa Inscripcion como entidad intermedia y la conserva al exportar', async ({
  browser,
}, testInfo) => {
  const escenario = await montarEscenario(browser, 'Clase asociativa EA');
  try {
    const page = escenario.ana.page;
    await abrirHerramienta(escenario.ana, 'importar');
    await page
      .getByTestId('archivo-xmi')
      .setInputFiles(
        fileURLToPath(
          new URL('../../shared/xmi/tests/fixtures/ea-association-class.xmi', import.meta.url),
        ),
      );
    await expect(page.getByTestId('candidato')).toContainText('entidad intermedia');
    await expect(page.getByTestId('clase-Inscripcion')).toHaveCount(0);
    await page.getByTestId('aplicar-candidato').click();
    for (const actor of [escenario.ana, escenario.beto]) {
      const node = actor.page.getByTestId('clase-Inscripcion');
      await expect(node).toHaveCount(1);
      await expect(node).toContainText('fecha');
      await expect(node).toContainText('notaFinal');
      await expect(node).toContainText('idInscripcion');
    }
    await page.getByTestId('exportar-xmi').click();
    const download = page.waitForEvent('download');
    await page.getByTestId('confirmar-export').click();
    const path = await (await download).path();
    const result = parseXmi(readFileSync(path, 'utf8'));
    const links = result.relationships.filter(
      (r) => r.sourceName === 'Inscripcion' || r.targetName === 'Inscripcion',
    );
    expect(links).toHaveLength(3);
    expect(links).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          sourceName: 'Estudiante',
          targetName: 'Inscripcion',
          sourceMultiplicity: '1',
          targetMultiplicity: '0..*',
        }),
        expect.objectContaining({
          sourceName: 'Curso',
          targetName: 'Inscripcion',
          sourceMultiplicity: '1',
          targetMultiplicity: '0..*',
        }),
        expect.objectContaining({
          sourceName: 'Inscripcion',
          targetName: 'Calificacion',
          kind: 'COMPOSITION',
        }),
      ]),
    );
    expect(
      result.relationships.some(
        (r) => [r.sourceName, r.targetName].sort().join() === 'Curso,Estudiante',
      ),
    ).toBe(false);
    await page.screenshot({
      path: testInfo.outputPath('inscripcion-importada.png'),
      fullPage: true,
    });
  } finally {
    await escenario.cerrar();
  }
});
```

---

### `e2e/specs/zz-captura.spec.ts`

```ts
import { expect, test } from '@playwright/test';
import { abrirHerramienta } from '../support/actors.js';
import { montarEscenario } from '../support/escenario.js';

test.use({
  permissions: ['camera'],
  launchOptions: { args: ['--use-fake-device-for-media-stream', '--use-fake-ui-for-media-stream'] },
});

test('captura con camara simulada', async ({ browser }, info) => {
  const escenario = await montarEscenario(browser, 'Captura');
  try {
    const page = escenario.ana.page;
    await abrirHerramienta(escenario.ana, 'importar');
    await page.getByTestId('abrir-camara').click();
    await expect(page.getByTestId('tomar-foto')).toBeEnabled({ timeout: 15_000 });
    await page.screenshot({ path: info.outputPath('camara.png') });
  } finally {
    await escenario.cerrar();
  }
});
```

---

### `e2e/support/actors.ts`

```ts
import { expect, type Browser, type Page } from '@playwright/test';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';

/**
 * Ayudantes para conducir la interfaz como lo haria una persona.
 *
 * Cada actor tiene su propio contexto de navegador, con sus propias cookies. Dos
 * pestanas del mismo contexto compartirian la sesion, y entonces no se estaria
 * probando lo que dice la seccion 15.4: dos usuarios distintos.
 */

export interface Actor {
  readonly page: Page;
  readonly email: string;
  readonly displayName: string;
  close(): Promise<void>;
}

let contador = 0;

export function nuevoCorreo(prefijo: string): string {
  contador += 1;
  return `${prefijo}-${Date.now()}-${contador}@example.com`;
}

/** Abre un navegador nuevo y registra una cuenta. */
export async function registrarActor(browser: Browser, prefijo: string): Promise<Actor> {
  const context = await browser.newContext();
  const page = await context.newPage();
  const email = nuevoCorreo(prefijo);
  const displayName = prefijo;

  await page.goto('/entrar');
  await page.getByRole('button', { name: 'Crear cuenta' }).click();
  await page.getByTestId('email').fill(email);
  await page.getByTestId('displayName').fill(displayName);
  await page.getByTestId('password').fill('contrasena-de-prueba');
  await page.getByTestId('enviar').click();
  await activarCuentaEIniciarSesion(page, email);

  return {
    page,
    email,
    displayName,
    close: () => context.close(),
  };
}

/** Completa el registro también en las pruebas que preparan su propia página. */
export async function activarCuentaEIniciarSesion(page: Page, email: string): Promise<void> {
  await expect(page.getByTestId('activacion-pendiente')).toBeVisible();
  // Solo en el entorno de pruebas local con MAIL_PROVIDER=log. No hay endpoint
  // de prueba ni tokens de activación en las respuestas públicas.
  const { stdout } = await promisify(execFile)('docker', [
    'compose',
    '-f',
    'infra/compose.yml',
    '--env-file',
    'infra/.env',
    'logs',
    '--no-color',
    '--no-log-prefix',
    '--tail',
    '500',
    'api',
  ]);
  const messages = stdout.split(/\r?\n/).flatMap((line) => {
    try {
      return [JSON.parse(line) as { destinatario?: string; cuerpo?: string }];
    } catch {
      return [];
    }
  });
  const token = messages
    .findLast((m) => m.destinatario === email && m.cuerpo?.includes('/activar#'))
    ?.cuerpo?.match(/#token=([^\s]+)/)?.[1];
  if (!token)
    throw new Error(
      'E2E necesita MAIL_PROVIDER=log y el Compose local para leer el correo de activación.',
    );
  await page.goto(`/activar#token=${token}`);
  await page.getByRole('button', { name: 'Activar mi cuenta', exact: true }).click();
  await expect(page.getByTestId('cuenta-activada')).toBeVisible();
  await page.getByRole('link', { name: 'Ir a iniciar sesión' }).click();
  await page.getByTestId('email').fill(email);
  await page.getByTestId('password').fill('contrasena-de-prueba');
  await page.getByTestId('enviar').click();

  await expect(page.getByTestId('lista-proyectos')).toBeVisible();
}

export async function crearProyecto(actor: Actor, nombre: string): Promise<string> {
  await actor.page.getByTestId('nombre-proyecto').fill(nombre);
  await actor.page.getByTestId('crear-proyecto').click();
  await expect(actor.page.getByTestId('lista-pizarras')).toBeVisible();

  const url = new URL(actor.page.url());
  return url.pathname.split('/').pop() as string;
}

export async function crearPizarra(actor: Actor, nombre: string): Promise<void> {
  await actor.page.getByTestId('nombre-pizarra').fill(nombre);
  await actor.page.getByTestId('crear-pizarra').click();
  await expect(actor.page.getByRole('link', { name: nombre })).toBeVisible();
}

export async function invitar(actor: Actor, rol: 'editor' | 'lector'): Promise<string> {
  await actor.page.getByTestId(`invitar-${rol}`).click();
  const codigo = actor.page.getByTestId('codigo-generado');
  await expect(codigo).toBeVisible();
  return (await codigo.textContent()) as string;
}

export async function aceptarInvitacion(actor: Actor, codigo: string): Promise<void> {
  await actor.page.goto('/proyectos');
  await actor.page.getByTestId('codigo-invitacion').fill(codigo);
  await actor.page.getByTestId('aceptar-invitacion').click();
  await expect(actor.page.getByTestId('lista-pizarras')).toBeVisible();
}

/** Abre la pizarra y espera a que la sesion colaborativa este en vivo. */
export async function abrirPizarra(actor: Actor, nombre: string): Promise<void> {
  await actor.page.getByRole('link', { name: nombre }).click();
  await expect(actor.page.getByTestId('estado-conexion')).toHaveText('En vivo');
}

/**
 * Posicion de una clase en coordenadas del diagrama.
 *
 * React Flow escribe la posicion del modelo en el `transform` del nodo. Se lee de
 * ahi y no del rectangulo en pantalla, porque cada navegador tiene su propio
 * zoom y desplazamiento: comparar pixeles entre dos ventanas distintas mide el
 * viewport, no el modelo.
 */
export async function posicionEnDiagrama(
  actor: Actor,
  nombreTecnico: string,
): Promise<{ x: number; y: number }> {
  const nodo = actor.page.locator('.react-flow__node', {
    has: actor.page.getByTestId(`clase-${nombreTecnico}`),
  });

  const estilo = (await nodo.first().getAttribute('style')) ?? '';
  const coincidencia = /translate\(([-\d.]+)px,\s*([-\d.]+)px\)/.exec(estilo);
  if (coincidencia === null) throw new Error(`Sin transform para ${nombreTecnico}: ${estilo}`);

  return { x: Number(coincidencia[1]), y: Number(coincidencia[2]) };
}

/**
 * Cambia a una de las tres herramientas del panel derecho.
 *
 * Antes estaban las tres apiladas y siempre visibles. Con cinco paneles en
 * veintidos centimetros ninguna se podia usar, asi que ahora van en pestanas y
 * hay que abrir la que se va a tocar.
 */
export async function abrirHerramienta(
  actor: Actor,
  herramienta: 'asistente' | 'importar' | 'generar',
): Promise<void> {
  await actor.page.getByTestId(`pestana-${herramienta}`).click();
}

export async function crearClase(actor: Actor, nombre: string): Promise<void> {
  await actor.page.getByTestId('crear-clase').click();
  await expect(actor.page.getByTestId('inspector-clase')).toBeVisible();
  await actor.page.getByTestId('nombre-clase').fill(nombre);
}

/**
 * Tamano dibujado de una tarjeta, leido del nodo de React Flow.
 *
 * React Flow escribe `width` y `height` en el estilo del nodo a partir de lo
 * que declara el modelo, asi que esto mide lo que la otra persona **ve**, no lo
 * que creemos haberle mandado.
 */
export async function tamanoEnDiagrama(
  actor: Actor,
  nombreTecnico: string,
): Promise<{ width: number; height: number }> {
  const nodo = actor.page.locator('.react-flow__node', {
    has: actor.page.getByTestId(`clase-${nombreTecnico}`),
  });

  const caja = await nodo.first().boundingBox();
  if (caja === null) throw new Error(`Sin caja para ${nombreTecnico}`);

  return { width: Math.round(caja.width), height: Math.round(caja.height) };
}
```

---

### `e2e/support/escenario.ts`

```ts
import type { Browser } from '@playwright/test';
import {
  abrirPizarra,
  aceptarInvitacion,
  crearPizarra,
  crearProyecto,
  invitar,
  registrarActor,
  type Actor,
} from './actors.js';

/**
 * Monta un proyecto con dos personas y las deja dentro de la misma pizarra.
 *
 * Cada prueba monta el suyo. Encadenarlas seria mas rapido, pero un fallo en la
 * primera arrastraria a todas las demas y el informe diria que fallaron cinco
 * cosas cuando en realidad fallo una. Playwright ademas cierra los contextos
 * creados en `beforeAll` entre pruebas, asi que compartirlos no es fiable.
 */
export interface EscenarioCompartido {
  readonly ana: Actor;
  readonly beto: Actor;
  cerrar(): Promise<void>;
}

export interface OpcionesEscenario {
  /** Rol con el que se invita a la segunda persona. */
  readonly rol?: 'editor' | 'lector';
  /** Pizarras a crear. La primera es la que se abre. */
  readonly pizarras?: readonly string[];
  /** Si la segunda persona abre tambien la primera pizarra. */
  readonly abrirAmbos?: boolean;
}

export async function montarEscenario(
  browser: Browser,
  nombreProyecto: string,
  opciones: OpcionesEscenario = {},
): Promise<EscenarioCompartido> {
  const rol = opciones.rol ?? 'editor';
  const pizarras = opciones.pizarras ?? ['Ventas'];
  const abrirAmbos = opciones.abrirAmbos ?? true;

  const ana = await registrarActor(browser, 'ana');
  const beto = await registrarActor(browser, 'beto');

  await crearProyecto(ana, nombreProyecto);
  for (const pizarra of pizarras) await crearPizarra(ana, pizarra);

  const codigo = await invitar(ana, rol);
  await aceptarInvitacion(beto, codigo);

  const primera = pizarras[0] as string;
  await abrirPizarra(ana, primera);
  if (abrirAmbos) await abrirPizarra(beto, primera);

  return {
    ana,
    beto,
    async cerrar() {
      await ana.close();
      await beto.close();
    },
  };
}
```

