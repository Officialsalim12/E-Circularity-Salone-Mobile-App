// Starts the API. Runs migrations first, then listens on every interface so the emulator can reach it.
import { buildApp } from './app.js';
import { loadConfig } from './config.js';
import { createPool, migrate } from './db/pool.js';

const config = loadConfig();
const pool = createPool(config.databaseUrl);
await migrate(pool);

const app = buildApp(config, pool);

const shutdown = async () => {
  await app.close();
  await pool.end();
};

process.on('SIGINT', () => {
  void shutdown().then(() => process.exit(0));
});
process.on('SIGTERM', () => {
  void shutdown().then(() => process.exit(0));
});

await app.listen({ port: config.port, host: '0.0.0.0' });
