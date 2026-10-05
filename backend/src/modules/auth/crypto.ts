// Passwords, codes, and token hashes. Nothing here is written to the log.
import { createHmac, randomBytes, randomInt, timingSafeEqual } from 'node:crypto';

import argon2 from 'argon2';

export function hashSecret(value: string, pepper: string): string {
  return createHmac('sha256', pepper).update(value).digest('hex');
}

// Same-length compare so a wrong guess doesn't leak timing, and a short one doesn't throw.
export function secretsMatch(storedHex: string, presentedHex: string): boolean {
  const stored = Buffer.from(storedHex, 'utf8');
  const presented = Buffer.from(presentedHex, 'utf8');
  if (stored.length !== presented.length) {
    return false;
  }
  return timingSafeEqual(stored, presented);
}

export function newToken(): string {
  return randomBytes(32).toString('base64url');
}

export function newVerificationCode(): string {
  return randomInt(0, 1_000_000).toString().padStart(6, '0');
}

export async function hashPassword(password: string): Promise<string> {
  return argon2.hash(password, { type: argon2.argon2id });
}

export async function verifyPassword(hash: string, password: string): Promise<boolean> {
  try {
    return await argon2.verify(hash, password);
  } catch {
    return false;
  }
}
