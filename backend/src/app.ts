// Wires Fastify, auth, and the error shape the app already expects.
import Fastify, { type FastifyInstance } from 'fastify';
import type { Pool } from 'pg';

import type { AppConfig } from './config.js';
import { AppError } from './http/errors.js';
import { AuthRepository } from './modules/auth/auth.repository.js';
import { authRoutes } from './modules/auth/auth.routes.js';
import { AuthService } from './modules/auth/auth.service.js';
import { createVerificationDelivery } from './providers/verification-delivery.js';

export function buildApp(config: AppConfig, pool: Pool): FastifyInstance {
  const app = Fastify({
    logger: true,
    bodyLimit: 16 * 1024,
  });

  const delivery = createVerificationDelivery(config.brevo);
  const service = new AuthService(new AuthRepository(pool), delivery, config);

  // A browser on this machine sends Origin. The phone app doesn't, so it skips this.
  if (config.appEnv === 'development') {
    app.addHook('onRequest', async (request, reply) => {
      const origin = request.headers.origin;
      if (typeof origin === 'string' && origin.length > 0) {
        reply.header('Access-Control-Allow-Origin', origin);
        reply.header('Access-Control-Allow-Headers', 'Authorization, Content-Type, Accept');
        reply.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
      }
      if (request.method === 'OPTIONS') {
        return reply.code(204).send();
      }
    });
  }

  app.setErrorHandler((error, request, reply) => {
    if (error instanceof AppError) {
      return reply.status(error.statusCode).send({
        error: { code: error.code, message: error.message },
      });
    }

    const statusCode =
      'statusCode' in error && typeof (error as { statusCode?: unknown }).statusCode === 'number'
        ? (error as { statusCode: number }).statusCode
        : 500;
    if (statusCode >= 400 && statusCode < 500) {
      return reply.status(statusCode).send({
        error: { code: 'validation_failed', message: 'Check the form and try again.' },
      });
    }

    request.log.error({ err: error }, 'request failed');
    return reply.status(500).send({
      error: { code: 'unavailable', message: 'Something went wrong. Try again.' },
    });
  });

  app.get('/api/v1/health', async () => ({ status: 'ok' }));
  app.register(async (instance) => authRoutes(instance, service), { prefix: '/api/v1' });

  return app;
}
