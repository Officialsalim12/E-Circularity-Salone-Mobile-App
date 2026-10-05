// Checks the JSON body, then calls the service. No rules here.
import type { FastifyReply, FastifyRequest } from 'fastify';
import { z } from 'zod';

import { AppError } from '../../http/errors.js';
import type { AuthService } from './auth.service.js';

const passwordSchema = z
  .string()
  .min(8, 'Use at least 8 characters.')
  .max(128, 'That password is too long.');

const registerBody = z
  .object({
    fullName: z.string(),
    password: passwordSchema,
    acceptedTerms: z.literal(true, {
      errorMap: () => ({ message: 'Accept the terms and privacy policy to continue.' }),
    }),
    email: z.string().optional(),
    phone: z.string().optional(),
    verificationToken: z.string().optional(),
  })
  .strict();

const loginBody = z
  .object({
    password: z.string(),
    email: z.string().optional(),
    phone: z.string().optional(),
  })
  .strict();

const googleBody = z
  .object({
    idToken: z.string().min(1),
    intent: z.enum(['sign_in', 'sign_up']),
    acceptedTerms: z.literal(true).optional(),
  })
  .strict();

const refreshBody = z
  .object({
    refreshToken: z.string().min(1),
  })
  .strict();

const verificationRequestBody = z
  .object({
    purpose: z.enum(['phone_registration', 'email_registration', 'password_reset']),
    destination: z.string(),
  })
  .strict();

const verificationConfirmBody = verificationRequestBody.extend({
  code: z.string(),
});

const resetPasswordBody = z
  .object({
    verificationToken: z.string().min(1),
    password: passwordSchema,
  })
  .strict();

export function registerHandler(service: AuthService) {
  return async (request: FastifyRequest, reply: FastifyReply) => {
    const body = parseBody(registerBody, request.body);
    await service.register(body);
    return reply.code(201).send({ status: 'created' });
  };
}

export function loginHandler(service: AuthService) {
  return async (request: FastifyRequest, reply: FastifyReply) => {
    const body = parseBody(loginBody, request.body);
    return reply.send(await service.login(body));
  };
}

export function googleHandler(service: AuthService) {
  return async (request: FastifyRequest, reply: FastifyReply) => {
    const body = parseBody(googleBody, request.body);
    return reply.send(await service.continueWithGoogle(body));
  };
}

export function refreshHandler(service: AuthService) {
  return async (request: FastifyRequest, reply: FastifyReply) => {
    const body = parseBody(refreshBody, request.body);
    return reply.send(await service.refresh(body.refreshToken));
  };
}

export function logoutHandler(service: AuthService) {
  return async (request: FastifyRequest, reply: FastifyReply) => {
    const body = parseBody(refreshBody, request.body);
    await service.logout(body.refreshToken);
    return reply.code(204).send();
  };
}

export function requestCodeHandler(service: AuthService) {
  return async (request: FastifyRequest, reply: FastifyReply) => {
    const body = parseBody(verificationRequestBody, request.body);
    await service.requestVerificationCode(body.purpose, body.destination);
    return reply.code(202).send({ status: 'accepted' });
  };
}

export function confirmCodeHandler(service: AuthService) {
  return async (request: FastifyRequest, reply: FastifyReply) => {
    const body = parseBody(verificationConfirmBody, request.body);
    return reply.send(
      await service.confirmVerificationCode(body.purpose, body.destination, body.code),
    );
  };
}

export function resetPasswordHandler(service: AuthService) {
  return async (request: FastifyRequest, reply: FastifyReply) => {
    const body = parseBody(resetPasswordBody, request.body);
    await service.resetPassword(body.verificationToken, body.password);
    return reply.code(204).send();
  };
}

export function currentUserHandler(service: AuthService) {
  return async (request: FastifyRequest) => {
    const authUser = request.authUser;
    if (!authUser) {
      throw new AppError(401, 'unauthorized', 'Sign in to continue.');
    }
    return service.currentUser(authUser.userId);
  };
}

export async function requireUser(service: AuthService, request: FastifyRequest): Promise<void> {
  const header = request.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    throw new AppError(401, 'unauthorized', 'Sign in to continue.');
  }
  request.authUser = await service.verifyAccessToken(header.slice('Bearer '.length).trim());
}

function parseBody<T>(schema: z.ZodType<T>, body: unknown): T {
  const result = schema.safeParse(body);
  if (!result.success) {
    const message = result.error.issues[0]?.message ?? 'Check the form and try again.';
    throw new AppError(400, 'validation_failed', message);
  }
  return result.data;
}
