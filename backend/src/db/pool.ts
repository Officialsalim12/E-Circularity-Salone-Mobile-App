// Postgres pool, plus the small migrator the server runs on startup.
import { Pool } from 'pg';

import { migrations } from './migrations.js';

export function createPool(databaseUrl: string): Pool {
  return new Pool({ connectionString: withoutChannelBinding(databaseUrl) });
}

// Neon adds channel_binding=require. node-postgres rejects that, so drop it and keep sslmode.
function withoutChannelBinding(databaseUrl: string): string {
  const url = new URL(databaseUrl);
  url.searchParams.delete('channel_binding');
  return url.toString();
}

export async function migrate(pool: Pool): Promise<void> {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS schema_migrations (
      id text PRIMARY KEY,
      applied_at timestamptz NOT NULL DEFAULT now()
    )
  `);

  for (const migration of migrations) {
    const existing = await pool.query(
      'SELECT id FROM schema_migrations WHERE id = $1',
      [migration.id],
    );
    if (existing.rowCount) {
      continue;
    }
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      await client.query(migration.sql);
      await client.query('INSERT INTO schema_migrations (id) VALUES ($1)', [migration.id]);
      await client.query('COMMIT');
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }
}

export async function withTransaction<T>(
  pool: Pool,
  fn: (client: import('pg').PoolClient) => Promise<T>,
): Promise<T> {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await fn(client);
    await client.query('COMMIT');
    return result;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}
