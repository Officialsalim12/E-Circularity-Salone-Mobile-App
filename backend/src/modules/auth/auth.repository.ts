// SQL only. It does not decide who is allowed to do what.
import { randomUUID } from 'node:crypto';

import type { Pool, PoolClient } from 'pg';

import { withTransaction } from '../../db/pool.js';
import type { VerificationPurpose } from '../../providers/verification-delivery.js';

export type Db = Pool | PoolClient;

export type UserRecord = {
  id: string;
  fullName: string;
  email: string | null;
  phone: string | null;
  passwordHash: string | null;
  googleSub: string | null;
  role: string;
};

export type ChallengeRecord = {
  id: string;
  codeHash: string;
  attemptCount: number;
  expiresAt: Date;
};

export type ProofRecord = {
  id: string;
  destination: string;
  expiresAt: Date;
};

export type RefreshTokenRecord = {
  id: string;
  userId: string;
  expiresAt: Date;
  revokedAt: Date | null;
};

type UserRow = {
  id: string;
  full_name: string;
  email: string | null;
  phone: string | null;
  password_hash: string | null;
  google_sub: string | null;
  role: string;
};

export class AuthRepository {
  constructor(private readonly db: Pool) {}

  transaction<T>(fn: (client: PoolClient) => Promise<T>): Promise<T> {
    return withTransaction(this.db, fn);
  }

  async findUserByEmail(email: string, db: Db = this.db): Promise<UserRecord | null> {
    const result = await db.query<UserRow>(
      `SELECT id, full_name, email, phone, password_hash, google_sub, role
       FROM users WHERE email = $1`,
      [email],
    );
    return mapUser(result.rows[0]);
  }

  async findUserByPhone(phone: string, db: Db = this.db): Promise<UserRecord | null> {
    const result = await db.query<UserRow>(
      `SELECT id, full_name, email, phone, password_hash, google_sub, role
       FROM users WHERE phone = $1`,
      [phone],
    );
    return mapUser(result.rows[0]);
  }

  async findUserById(id: string, db: Db = this.db): Promise<UserRecord | null> {
    const result = await db.query<UserRow>(
      `SELECT id, full_name, email, phone, password_hash, google_sub, role
       FROM users WHERE id = $1`,
      [id],
    );
    return mapUser(result.rows[0]);
  }

  async insertUser(
    input: {
      fullName: string;
      email: string | null;
      phone: string | null;
      passwordHash: string | null;
      googleSub?: string | null;
      role: string;
    },
    db: Db = this.db,
  ): Promise<UserRecord> {
    const id = randomUUID();
    const result = await db.query<UserRow>(
      `INSERT INTO users (
         id, full_name, email, phone, password_hash, google_sub, role, created_at, updated_at
       )
       VALUES ($1, $2, $3, $4, $5, $6, $7, now(), now())
       RETURNING id, full_name, email, phone, password_hash, google_sub, role`,
      [
        id,
        input.fullName,
        input.email,
        input.phone,
        input.passwordHash,
        input.googleSub ?? null,
        input.role,
      ],
    );
    const user = mapUser(result.rows[0]);
    if (!user) {
      throw new Error('User insert did not return a row');
    }
    return user;
  }

  async linkGoogleSub(userId: string, googleSub: string, db: Db = this.db): Promise<void> {
    await db.query(
      `UPDATE users SET google_sub = $2, updated_at = now() WHERE id = $1 AND google_sub IS NULL`,
      [userId, googleSub],
    );
  }

  async updatePassword(userId: string, passwordHash: string, db: Db = this.db): Promise<void> {
    await db.query(
      `UPDATE users SET password_hash = $2, updated_at = now() WHERE id = $1`,
      [userId, passwordHash],
    );
  }

  async insertRefreshToken(
    input: { userId: string; tokenHash: string; expiresAt: Date },
    db: Db = this.db,
  ): Promise<void> {
    await db.query(
      `INSERT INTO refresh_tokens (id, user_id, token_hash, expires_at, created_at)
       VALUES ($1, $2, $3, $4, now())`,
      [randomUUID(), input.userId, input.tokenHash, input.expiresAt],
    );
  }

  async findRefreshToken(
    tokenHash: string,
    db: Db = this.db,
    lock = false,
  ): Promise<RefreshTokenRecord | null> {
    const result = await db.query<{
      id: string;
      user_id: string;
      expires_at: Date;
      revoked_at: Date | null;
    }>(
      `SELECT id, user_id, expires_at, revoked_at
       FROM refresh_tokens WHERE token_hash = $1${lock ? ' FOR UPDATE' : ''}`,
      [tokenHash],
    );
    const row = result.rows[0];
    if (!row) {
      return null;
    }
    return {
      id: row.id,
      userId: row.user_id,
      expiresAt: row.expires_at,
      revokedAt: row.revoked_at,
    };
  }

  async revokeRefreshToken(id: string, db: Db = this.db): Promise<void> {
    await db.query(
      `UPDATE refresh_tokens SET revoked_at = now() WHERE id = $1 AND revoked_at IS NULL`,
      [id],
    );
  }

  async revokeRefreshTokensForUser(userId: string, db: Db = this.db): Promise<void> {
    await db.query(
      `UPDATE refresh_tokens SET revoked_at = now()
       WHERE user_id = $1 AND revoked_at IS NULL`,
      [userId],
    );
  }

  async consumeOpenChallenges(
    purpose: VerificationPurpose,
    destination: string,
    db: Db = this.db,
  ): Promise<void> {
    await db.query(
      `UPDATE verification_challenges
       SET consumed_at = now()
       WHERE purpose = $1 AND destination = $2 AND consumed_at IS NULL`,
      [purpose, destination],
    );
  }

  async insertChallenge(
    input: {
      purpose: VerificationPurpose;
      destination: string;
      codeHash: string;
      expiresAt: Date;
    },
    db: Db = this.db,
  ): Promise<void> {
    await db.query(
      `INSERT INTO verification_challenges
         (id, purpose, destination, code_hash, expires_at, attempt_count, created_at)
       VALUES ($1, $2, $3, $4, $5, 0, now())`,
      [randomUUID(), input.purpose, input.destination, input.codeHash, input.expiresAt],
    );
  }

  async findOpenChallenge(
    purpose: VerificationPurpose,
    destination: string,
    db: Db = this.db,
  ): Promise<ChallengeRecord | null> {
    const result = await db.query<{
      id: string;
      code_hash: string;
      attempt_count: number;
      expires_at: Date;
    }>(
      `SELECT id, code_hash, attempt_count, expires_at
       FROM verification_challenges
       WHERE purpose = $1 AND destination = $2 AND consumed_at IS NULL
       ORDER BY created_at DESC
       LIMIT 1`,
      [purpose, destination],
    );
    const row = result.rows[0];
    if (!row) {
      return null;
    }
    return {
      id: row.id,
      codeHash: row.code_hash,
      attemptCount: row.attempt_count,
      expiresAt: row.expires_at,
    };
  }

  async incrementChallengeAttempts(id: string, db: Db = this.db): Promise<void> {
    await db.query(
      `UPDATE verification_challenges
       SET attempt_count = attempt_count + 1
       WHERE id = $1`,
      [id],
    );
  }

  async consumeChallenge(id: string, db: Db = this.db): Promise<void> {
    await db.query(
      `UPDATE verification_challenges SET consumed_at = now() WHERE id = $1 AND consumed_at IS NULL`,
      [id],
    );
  }

  async insertProof(
    input: {
      purpose: VerificationPurpose;
      destination: string;
      tokenHash: string;
      expiresAt: Date;
    },
    db: Db = this.db,
  ): Promise<void> {
    await db.query(
      `INSERT INTO verification_proofs
         (id, purpose, destination, token_hash, expires_at, created_at)
       VALUES ($1, $2, $3, $4, $5, now())`,
      [randomUUID(), input.purpose, input.destination, input.tokenHash, input.expiresAt],
    );
  }

  async findOpenProof(tokenHash: string, db: Db = this.db): Promise<(ProofRecord & { purpose: VerificationPurpose }) | null> {
    const result = await db.query<{
      id: string;
      purpose: VerificationPurpose;
      destination: string;
      expires_at: Date;
    }>(
      `SELECT id, purpose, destination, expires_at
       FROM verification_proofs
       WHERE token_hash = $1 AND consumed_at IS NULL`,
      [tokenHash],
    );
    const row = result.rows[0];
    if (!row) {
      return null;
    }
    return {
      id: row.id,
      purpose: row.purpose,
      destination: row.destination,
      expiresAt: row.expires_at,
    };
  }

  async consumeProof(id: string, db: Db = this.db): Promise<void> {
    await db.query(
      `UPDATE verification_proofs SET consumed_at = now() WHERE id = $1 AND consumed_at IS NULL`,
      [id],
    );
  }
}

function mapUser(row: UserRow | undefined): UserRecord | null {
  if (!row) {
    return null;
  }
  return {
    id: row.id,
    fullName: row.full_name,
    email: row.email,
    phone: row.phone,
    passwordHash: row.password_hash,
    googleSub: row.google_sub,
    role: row.role,
  };
}
