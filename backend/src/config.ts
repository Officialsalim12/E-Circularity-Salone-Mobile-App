// Reads .env. The repo root file wins, then backend/.env can override it.
import { config as loadEnv } from 'dotenv';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const backendRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..');
loadEnv({ path: resolve(backendRoot, '../.env') });
loadEnv({ path: resolve(backendRoot, '.env'), override: true });

export type AppEnv = 'development' | 'staging' | 'production';

export type AppConfig = {
  appEnv: AppEnv;
  port: number;
  databaseUrl: string;
  accessTokenSecret: string;
  tokenHashSecret: string;
  accessTokenTtlSeconds: number;
  refreshTokenTtlSeconds: number;
  verificationCodeTtlSeconds: number;
  verificationProofTtlSeconds: number;
  verificationMaxAttempts: number;
  brevo: {
    apiKey: string;
    senderEmail: string;
    senderName: string;
    smsSender: string | null;
  } | null;
  googleClientId: string | null;
};

const devSecretMarker = 'dev-only';

export function loadConfig(): AppConfig {
  const appEnv = requiredEnv('APP_ENV');
  if (appEnv !== 'development' && appEnv !== 'staging' && appEnv !== 'production') {
    throw new Error('APP_ENV must be development, staging, or production');
  }

  const accessTokenSecret = requiredEnv('ACCESS_TOKEN_SECRET');
  const tokenHashSecret = requiredEnv('TOKEN_HASH_SECRET');
  assertSecret(appEnv, 'ACCESS_TOKEN_SECRET', accessTokenSecret);
  assertSecret(appEnv, 'TOKEN_HASH_SECRET', tokenHashSecret);

  return {
    appEnv,
    port: numberEnv('PORT', 3000),
    databaseUrl: requiredEnv('DATABASE_URL'),
    accessTokenSecret,
    tokenHashSecret,
    accessTokenTtlSeconds: numberEnv('ACCESS_TOKEN_TTL_SECONDS', 900),
    refreshTokenTtlSeconds: numberEnv('REFRESH_TOKEN_TTL_SECONDS', 60 * 60 * 24 * 30),
    verificationCodeTtlSeconds: numberEnv('VERIFICATION_CODE_TTL_SECONDS', 600),
    verificationProofTtlSeconds: numberEnv('VERIFICATION_PROOF_TTL_SECONDS', 900),
    verificationMaxAttempts: numberEnv('VERIFICATION_MAX_ATTEMPTS', 5),
    brevo: brevoConfig(),
    googleClientId: optionalEnv('GOOGLE_CLIENT_ID'),
  };
}

function requiredEnv(name: string): string {
  const value = process.env[name]?.trim();
  if (!value) {
    throw new Error(`Missing ${name}`);
  }
  return value;
}

function optionalEnv(name: string): string | null {
  const value = process.env[name]?.trim() ?? '';
  return value || null;
}

function numberEnv(name: string, fallback: number): number {
  const raw = process.env[name]?.trim();
  if (!raw) {
    return fallback;
  }
  const parsed = Number(raw);
  if (!Number.isInteger(parsed) || parsed <= 0) {
    throw new Error(`${name} must be a positive integer`);
  }
  return parsed;
}

function brevoConfig(): AppConfig['brevo'] {
  const apiKey = process.env.BREVO_API_KEY?.trim() ?? '';
  const senderEmail = process.env.BREVO_SENDER_EMAIL?.trim() ?? '';
  const smsSender = process.env.BREVO_SMS_SENDER?.trim() ?? '';
  const senderName = process.env.BREVO_SENDER_NAME?.trim() || 'Circular Salone';
  if (!apiKey && !senderEmail && !smsSender) {
    return null;
  }
  if (!apiKey || !senderEmail) {
    throw new Error('Set BREVO_API_KEY and BREVO_SENDER_EMAIL');
  }
  if (!/^[^@]+@[^@]+\.[^@]+$/.test(senderEmail)) {
    throw new Error('BREVO_SENDER_EMAIL is not a valid email address');
  }
  // Empty is fine. Texts fail later, email still works.
  if (smsSender && !/^[A-Za-z0-9]{3,11}$/.test(smsSender)) {
    throw new Error('BREVO_SMS_SENDER must be 3 to 11 letters or digits');
  }
  return { apiKey, senderEmail, senderName, smsSender: smsSender || null };
}

function assertSecret(appEnv: AppEnv, name: string, value: string): void {
  if (value.length < 32) {
    throw new Error(`${name} must be at least 32 characters`);
  }
  if (appEnv === 'production' && value.includes(devSecretMarker)) {
    throw new Error(`Refusing to start production with a development ${name}`);
  }
}
