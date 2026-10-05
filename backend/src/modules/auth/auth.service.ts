// Signup, sign-in, codes, and sessions. The phone asks. This decides.
import { SignJWT, jwtVerify } from 'jose';

import type { AppConfig } from '../../config.js';
import { AppError } from '../../http/errors.js';
import {
  VerificationDeliveryError,
  type VerificationDelivery,
  type VerificationPurpose,
} from '../../providers/verification-delivery.js';
import {
  AuthRepository,
  type UserRecord,
} from './auth.repository.js';
import { verifyGoogleIdToken } from '../../providers/google-identity.js';
import { normalizeEmail, normalizeSierraLeonePhone } from './contact.js';
import {
  hashPassword,
  hashSecret,
  newToken,
  newVerificationCode,
  secretsMatch,
  verifyPassword,
} from './crypto.js';

const deviceOwnerRole = 'device_owner';
const invalidCodeMessage = "That code doesn't match. If it expired, ask for a new one.";
const invalidSignInMessage = "Those details don't match. Try again.";

export type PublicUser = {
  id: string;
  fullName: string;
  email: string | null;
  phone: string | null;
  role: string;
};

export type AuthSession = {
  accessToken: string;
  refreshToken: string;
  expiresInSeconds: number;
  user: PublicUser;
};

export type VerificationProofResult = {
  verificationToken: string;
  expiresInSeconds: number;
};

type RegisterInput = {
  fullName: string;
  password: string;
  acceptedTerms: boolean;
  email?: string;
  phone?: string;
  verificationToken?: string;
};

type LoginInput = {
  password: string;
  email?: string;
  phone?: string;
};

export class AuthService {
  constructor(
    private readonly repository: AuthRepository,
    private readonly delivery: VerificationDelivery,
    private readonly config: AppConfig,
  ) {}

  async register(input: RegisterInput): Promise<void> {
    if (!input.acceptedTerms) {
      throw new AppError(
        400,
        'validation_failed',
        'Accept the terms and privacy policy to continue.',
      );
    }
    const fullName = input.fullName.trim();
    if (!fullName || fullName.length > 120) {
      throw new AppError(400, 'validation_failed', 'Enter your full name.');
    }
    assertPassword(input.password);

    const email = input.email ? normalizeEmail(input.email) : null;
    const phone = input.phone ? normalizeSierraLeonePhone(input.phone) : null;
    if (Boolean(email) === Boolean(phone)) {
      throw new AppError(
        400,
        'validation_failed',
        'Enter an email or a Sierra Leone phone number.',
      );
    }
    if (input.email && !email) {
      throw new AppError(400, 'validation_failed', "That email doesn't look right.");
    }
    if (input.phone && !phone) {
      throw new AppError(400, 'validation_failed', 'Enter an 8-digit Sierra Leone number.');
    }

    const passwordHash = await hashPassword(input.password);

    try {
      const user = await this.repository.transaction(async (client) => {
        if (phone) {
          const proof = await this.requireProof(
            input.verificationToken,
            'phone_registration',
            phone,
            client,
          );
          await this.repository.consumeProof(proof.id, client);
        }
        if (email) {
          const proof = await this.requireProof(
            input.verificationToken,
            'email_registration',
            email,
            client,
          );
          await this.repository.consumeProof(proof.id, client);
        }
        return this.repository.insertUser(
          {
            fullName,
            email,
            phone,
            passwordHash,
            role: deviceOwnerRole,
          },
          client,
        );
      });
      // The account is already saved. A failed welcome note should not undo that.
      try {
        await this.delivery.sendWelcome({
          fullName: user.fullName,
          email: user.email,
          phone: user.phone,
        });
      } catch (error) {
        if (!(error instanceof VerificationDeliveryError)) {
          throw error;
        }
      }
    } catch (error) {
      if (isUniqueViolation(error)) {
        throw new AppError(
          409,
          'conflict',
          email
            ? "There's already an account with this email."
            : "There's already an account with this number.",
        );
      }
      throw error;
    }
  }

  async login(input: LoginInput): Promise<AuthSession> {
    assertPassword(input.password);
    if (Boolean(input.email) === Boolean(input.phone)) {
      throw new AppError(
        400,
        'validation_failed',
        'Enter an email or a Sierra Leone phone number.',
      );
    }

    let user: UserRecord | null = null;
    if (input.email) {
      const email = normalizeEmail(input.email);
      user = email ? await this.repository.findUserByEmail(email) : null;
    } else if (input.phone) {
      const phone = normalizeSierraLeonePhone(input.phone);
      user = phone ? await this.repository.findUserByPhone(phone) : null;
    }
    if (!user?.passwordHash || !(await verifyPassword(user.passwordHash, input.password))) {
      throw new AppError(401, 'unauthorized', invalidSignInMessage);
    }
    return this.issueSession(user);
  }

  async continueWithGoogle(input: {
    idToken: string;
    intent: 'sign_in' | 'sign_up';
    acceptedTerms?: boolean;
  }): Promise<AuthSession> {
    if (!this.config.googleClientId) {
      throw new AppError(503, 'unavailable', "Google sign-in isn't set up.");
    }
    if (input.intent === 'sign_up' && input.acceptedTerms !== true) {
      throw new AppError(400, 'validation_failed', 'Accept the terms and privacy policy to continue.');
    }

    let identity;
    try {
      identity = await verifyGoogleIdToken(input.idToken, this.config.googleClientId);
    } catch {
      throw new AppError(401, 'unauthorized', "Google sign-in didn't work. Try again.");
    }

    const email = normalizeEmail(identity.email);
    if (!email) {
      throw new AppError(401, 'unauthorized', "That Google account doesn't have a verified email.");
    }

    const existing = await this.repository.findUserByEmail(email);
    if (existing?.googleSub && existing.googleSub !== identity.sub) {
      throw new AppError(409, 'conflict', 'That email is already linked to a different Google account.');
    }

    if (!existing) {
      const fullName = (identity.name || email.split('@')[0] || 'Circular Salone').slice(0, 120);
      try {
        const user = await this.repository.insertUser({
          fullName,
          email,
          phone: null,
          passwordHash: null,
          googleSub: identity.sub,
          role: deviceOwnerRole,
        });
        try {
          await this.delivery.sendWelcome({
            fullName: user.fullName,
            email: user.email,
            phone: null,
          });
        } catch (error) {
          if (!(error instanceof VerificationDeliveryError)) {
            throw error;
          }
        }
        return this.issueSession(user);
      } catch (error) {
        if (isUniqueViolation(error)) {
          throw new AppError(409, 'conflict', "There's already an account with this email.");
        }
        throw error;
      }
    }

    if (!existing.googleSub) {
      await this.repository.linkGoogleSub(existing.id, identity.sub);
    }
    return this.issueSession(existing);
  }

  async refresh(refreshToken: string): Promise<AuthSession> {
    const tokenHash = hashSecret(refreshToken, this.config.tokenHashSecret);
    const result = await this.repository.transaction(async (client) => {
      const existing = await this.repository.findRefreshToken(tokenHash, client, true);
      if (!existing || existing.expiresAt.getTime() <= Date.now()) {
        return null;
      }
      // A reused old refresh token means the others should die too.
      if (existing.revokedAt) {
        await this.repository.revokeRefreshTokensForUser(existing.userId, client);
        return null;
      }

      const user = await this.repository.findUserById(existing.userId, client);
      if (!user) {
        return null;
      }

      const nextRefreshToken = newToken();
      const expiresAt = new Date(Date.now() + this.config.refreshTokenTtlSeconds * 1000);
      await this.repository.revokeRefreshToken(existing.id, client);
      await this.repository.insertRefreshToken(
        {
          userId: user.id,
          tokenHash: hashSecret(nextRefreshToken, this.config.tokenHashSecret),
          expiresAt,
        },
        client,
      );

      const session: AuthSession = {
        accessToken: await this.signAccessToken(user),
        refreshToken: nextRefreshToken,
        expiresInSeconds: this.config.accessTokenTtlSeconds,
        user: toPublicUser(user),
      };
      return session;
    });

    if (!result) {
      throw new AppError(401, 'unauthorized', 'Sign in to continue.');
    }
    return result;
  }

  async logout(refreshToken: string): Promise<void> {
    const tokenHash = hashSecret(refreshToken, this.config.tokenHashSecret);
    const existing = await this.repository.findRefreshToken(tokenHash);
    if (!existing || existing.revokedAt) {
      return;
    }
    await this.repository.revokeRefreshToken(existing.id);
  }

  async currentUser(userId: string): Promise<PublicUser> {
    const user = await this.repository.findUserById(userId);
    if (!user) {
      throw new AppError(401, 'unauthorized', 'Sign in to continue.');
    }
    return toPublicUser(user);
  }

  async requestVerificationCode(purpose: VerificationPurpose, destinationInput: string): Promise<void> {
    const destination = this.destinationFor(purpose, destinationInput);
    const channel = destination.startsWith('+') ? 'sms' : 'email';
    if (purpose === 'phone_registration') {
      const existing = await this.repository.findUserByPhone(destination);
      if (existing) {
        throw new AppError(409, 'conflict', "There's already an account with this number.");
      }
    } else if (purpose === 'email_registration') {
      const existing = await this.repository.findUserByEmail(destination);
      if (existing) {
        throw new AppError(409, 'conflict', "There's already an account with this email.");
      }
    } else {
      const account =
        channel === 'sms'
          ? await this.repository.findUserByPhone(destination)
          : await this.repository.findUserByEmail(destination);
      // Unknown reset address: same response, no email or text.
      if (!account) {
        return;
      }
    }

    const code = newVerificationCode();
    try {
      await this.delivery.send({
        channel,
        destination,
        code,
        purpose,
      });
    } catch (error) {
      if (error instanceof VerificationDeliveryError) {
        throw new AppError(503, 'unavailable', error.message);
      }
      throw error;
    }

    const expiresAt = new Date(Date.now() + this.config.verificationCodeTtlSeconds * 1000);
    await this.repository.transaction(async (client) => {
      await this.repository.consumeOpenChallenges(purpose, destination, client);
      await this.repository.insertChallenge(
        {
          purpose,
          destination,
          codeHash: hashSecret(code, this.config.tokenHashSecret),
          expiresAt,
        },
        client,
      );
    });
  }

  async confirmVerificationCode(
    purpose: VerificationPurpose,
    destinationInput: string,
    code: string,
  ): Promise<VerificationProofResult> {
    if (!/^\d{6}$/.test(code)) {
      throw new AppError(400, 'validation_failed', 'Enter the 6-digit code.');
    }
    const destination = this.destinationFor(purpose, destinationInput);
    const challenge = await this.repository.findOpenChallenge(purpose, destination);
    const expired = !challenge || challenge.expiresAt.getTime() <= Date.now();
    const exhausted = !challenge || challenge.attemptCount >= this.config.verificationMaxAttempts;
    if (!challenge || expired || exhausted) {
      if (challenge) {
        await this.repository.consumeChallenge(challenge.id);
      }
      throw new AppError(400, 'validation_failed', invalidCodeMessage);
    }

    const presented = hashSecret(code, this.config.tokenHashSecret);
    if (!secretsMatch(challenge.codeHash, presented)) {
      const attempts = challenge.attemptCount + 1;
      await this.repository.incrementChallengeAttempts(challenge.id);
      if (attempts >= this.config.verificationMaxAttempts) {
        await this.repository.consumeChallenge(challenge.id);
      }
      throw new AppError(400, 'validation_failed', invalidCodeMessage);
    }

    const verificationToken = newToken();
    const expiresAt = new Date(Date.now() + this.config.verificationProofTtlSeconds * 1000);
    await this.repository.transaction(async (client) => {
      await this.repository.consumeChallenge(challenge.id, client);
      await this.repository.insertProof(
        {
          purpose,
          destination,
          tokenHash: hashSecret(verificationToken, this.config.tokenHashSecret),
          expiresAt,
        },
        client,
      );
    });

    return {
      verificationToken,
      expiresInSeconds: this.config.verificationProofTtlSeconds,
    };
  }

  async resetPassword(verificationToken: string, password: string): Promise<void> {
    assertPassword(password);
    const passwordHash = await hashPassword(password);
    await this.repository.transaction(async (client) => {
      const proof = await this.requireProof(verificationToken, 'password_reset', null, client);
      const user = proof.destination.startsWith('+')
        ? await this.repository.findUserByPhone(proof.destination, client)
        : await this.repository.findUserByEmail(proof.destination, client);
      if (!user) {
        throw new AppError(400, 'validation_failed', invalidCodeMessage);
      }
      await this.repository.consumeProof(proof.id, client);
      await this.repository.updatePassword(user.id, passwordHash, client);
      await this.repository.revokeRefreshTokensForUser(user.id, client);
    });
  }

  async verifyAccessToken(token: string): Promise<{ userId: string; role: string }> {
    try {
      const { payload } = await jwtVerify(token, this.accessKey(), {
        issuer: 'circular-salone',
      });
      if (!payload.sub || typeof payload.role !== 'string') {
        throw new Error('incomplete token');
      }
      return { userId: payload.sub, role: payload.role };
    } catch {
      throw new AppError(401, 'unauthorized', 'Sign in to continue.');
    }
  }

  private destinationFor(purpose: VerificationPurpose, value: string): string {
    if (purpose === 'phone_registration') {
      const phone = normalizeSierraLeonePhone(value);
      if (!phone) {
        throw new AppError(400, 'validation_failed', 'Enter an 8-digit Sierra Leone number.');
      }
      return phone;
    }
    if (purpose === 'email_registration') {
      const email = normalizeEmail(value);
      if (!email) {
        throw new AppError(400, 'validation_failed', "That email doesn't look right.");
      }
      return email;
    }
    const email = normalizeEmail(value);
    if (email) {
      return email;
    }
    const phone = normalizeSierraLeonePhone(value);
    if (phone) {
      return phone;
    }
    throw new AppError(
      400,
      'validation_failed',
      'Enter an email or an 8-digit Sierra Leone number.',
    );
  }

  private async requireProof(
    token: string | undefined,
    purpose: VerificationPurpose,
    destination: string | null,
    client: import('pg').PoolClient,
  ) {
    if (!token) {
      throw new AppError(400, 'validation_failed', invalidCodeMessage);
    }
    const proof = await this.repository.findOpenProof(
      hashSecret(token, this.config.tokenHashSecret),
      client,
    );
    if (!proof || proof.purpose !== purpose || proof.expiresAt.getTime() <= Date.now()) {
      throw new AppError(400, 'validation_failed', invalidCodeMessage);
    }
    if (destination && proof.destination !== destination) {
      throw new AppError(400, 'validation_failed', invalidCodeMessage);
    }
    return proof;
  }

  private async issueSession(user: UserRecord): Promise<AuthSession> {
    const refreshToken = newToken();
    const expiresAt = new Date(Date.now() + this.config.refreshTokenTtlSeconds * 1000);
    await this.repository.insertRefreshToken({
      userId: user.id,
      tokenHash: hashSecret(refreshToken, this.config.tokenHashSecret),
      expiresAt,
    });
    return {
      accessToken: await this.signAccessToken(user),
      refreshToken,
      expiresInSeconds: this.config.accessTokenTtlSeconds,
      user: toPublicUser(user),
    };
  }

  private async signAccessToken(user: UserRecord): Promise<string> {
    return new SignJWT({ role: user.role })
      .setProtectedHeader({ alg: 'HS256' })
      .setSubject(user.id)
      .setIssuer('circular-salone')
      .setIssuedAt()
      .setExpirationTime(`${this.config.accessTokenTtlSeconds}s`)
      .sign(this.accessKey());
  }

  private accessKey(): Uint8Array {
    return new TextEncoder().encode(this.config.accessTokenSecret);
  }
}

function toPublicUser(user: UserRecord): PublicUser {
  return {
    id: user.id,
    fullName: user.fullName,
    email: user.email,
    phone: user.phone,
    role: user.role,
  };
}

function assertPassword(password: string): void {
  if (password.length < 8) {
    throw new AppError(400, 'validation_failed', 'Use at least 8 characters.');
  }
  if (password.length > 128) {
    throw new AppError(400, 'validation_failed', 'That password is too long.');
  }
}

function isUniqueViolation(error: unknown): boolean {
  return typeof error === 'object' && error !== null && 'code' in error && error.code === '23505';
}
