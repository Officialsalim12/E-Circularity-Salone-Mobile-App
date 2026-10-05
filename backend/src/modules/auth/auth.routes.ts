// Auth URLs. Handlers live in the controller. Rules live in the service.
import type { FastifyInstance, FastifyRequest } from 'fastify';

import type { AuthService } from './auth.service.js';
import {
  confirmCodeHandler,
  currentUserHandler,
  googleHandler,
  loginHandler,
  logoutHandler,
  refreshHandler,
  registerHandler,
  requestCodeHandler,
  requireUser,
  resetPasswordHandler,
} from './auth.controller.js';

declare module 'fastify' {
  interface FastifyRequest {
    authUser?: { userId: string; role: string };
  }
}

export async function authRoutes(app: FastifyInstance, service: AuthService): Promise<void> {
  app.post('/auth/register', registerHandler(service));
  app.post('/auth/login', loginHandler(service));
  app.post('/auth/google', googleHandler(service));
  app.post('/auth/refresh', refreshHandler(service));
  app.post('/auth/logout', logoutHandler(service));
  app.post('/auth/verification-codes', requestCodeHandler(service));
  app.post('/auth/verification-codes/confirm', confirmCodeHandler(service));
  app.post('/auth/password-reset', resetPasswordHandler(service));
  app.get(
    '/auth/me',
    { preHandler: async (request: FastifyRequest) => requireUser(service, request) },
    currentUserHandler(service),
  );
}
