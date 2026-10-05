// One-off: npm run migrate. The server also migrates when it starts.
import { loadConfig } from '../config.js';
import { createPool, migrate } from './pool.js';

const config = loadConfig();
const pool = createPool(config.databaseUrl);

try {
  await migrate(pool);
} finally {
  await pool.end();
}
