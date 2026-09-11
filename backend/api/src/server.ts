import { buildApp, SERVICE_NAME } from './app.js';
import { loadConfig } from './config.js';

const config = loadConfig();
const app = await buildApp(config);

for (const senal of ['SIGINT', 'SIGTERM'] as const) {
  process.on(senal, () => {
    app.log.info({ senal }, 'cerrando el proceso');
    void app.close().then(() => process.exit(0));
  });
}

try {
  await app.listen({ host: config.API_HOST, port: config.API_PORT });
  app.log.info({ service: SERVICE_NAME, port: config.API_PORT }, 'proceso api escuchando');
} catch (error) {
  app.log.fatal({ error }, 'el proceso api no pudo arrancar');
  process.exit(1);
}
