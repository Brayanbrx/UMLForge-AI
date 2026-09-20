import { expect, test, type Page } from '@playwright/test';

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

test('conserva edición offline si la sesión funciona pero la consulta de pizarra falla', async ({
  page,
}) => {
  await enter(page);
  await create(page, 'Guardada');
  await page.route(`**/api${board.replace('/pizarras/', '/boards/')}`, (route) =>
    route.fulfill({
      status: 503,
      json: { error: { message: 'Servicio de pizarras no disponible' } },
    }),
  );
  await page.reload();
  await expect(page.getByTestId('modo-offline')).toBeVisible();
  await expect(page.getByTestId('clase-Guardada')).toBeVisible();
  await create(page, 'MientrasFalla');
  await page.unroute(`**/api${board.replace('/pizarras/', '/boards/')}`);
  await expect(page.getByTestId('estado-conexion')).toHaveText('En vivo');
  await page.reload();
  await expect(page.getByTestId('clase-MientrasFalla')).toBeVisible();
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
  await page.goto('/proyectos');
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
