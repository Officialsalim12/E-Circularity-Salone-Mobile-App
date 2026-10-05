// SQL applied once, in order. Add a new id. Don't edit one that has already run.
export const migrations: { id: string; sql: string }[] = [
  {
    id: '001_auth',
    sql: `
      CREATE TABLE users (
        id uuid PRIMARY KEY,
        full_name text NOT NULL,
        email text,
        phone text,
        password_hash text NOT NULL,
        role text NOT NULL,
        created_at timestamptz NOT NULL,
        updated_at timestamptz NOT NULL,
        CONSTRAINT users_email_unique UNIQUE (email),
        CONSTRAINT users_phone_unique UNIQUE (phone),
        CONSTRAINT users_contact_present CHECK (email IS NOT NULL OR phone IS NOT NULL),
        CONSTRAINT users_role_known CHECK (role IN ('device_owner'))
      );

      CREATE TABLE refresh_tokens (
        id uuid PRIMARY KEY,
        user_id uuid NOT NULL REFERENCES users (id),
        token_hash text NOT NULL,
        expires_at timestamptz NOT NULL,
        revoked_at timestamptz,
        created_at timestamptz NOT NULL,
        CONSTRAINT refresh_tokens_hash_unique UNIQUE (token_hash)
      );

      CREATE INDEX refresh_tokens_user_id_idx ON refresh_tokens (user_id);

      CREATE TABLE verification_challenges (
        id uuid PRIMARY KEY,
        purpose text NOT NULL,
        destination text NOT NULL,
        code_hash text NOT NULL,
        expires_at timestamptz NOT NULL,
        attempt_count integer NOT NULL DEFAULT 0,
        consumed_at timestamptz,
        created_at timestamptz NOT NULL,
        CONSTRAINT verification_challenges_purpose_known
          CHECK (purpose IN ('phone_registration', 'password_reset'))
      );

      CREATE INDEX verification_challenges_lookup_idx
        ON verification_challenges (purpose, destination, created_at DESC);

      CREATE TABLE verification_proofs (
        id uuid PRIMARY KEY,
        purpose text NOT NULL,
        destination text NOT NULL,
        token_hash text NOT NULL,
        expires_at timestamptz NOT NULL,
        consumed_at timestamptz,
        created_at timestamptz NOT NULL,
        CONSTRAINT verification_proofs_hash_unique UNIQUE (token_hash),
        CONSTRAINT verification_proofs_purpose_known
          CHECK (purpose IN ('phone_registration', 'password_reset'))
      );
    `,
  },
  {
    id: '002_email_registration',
    sql: `
      ALTER TABLE verification_challenges
        DROP CONSTRAINT verification_challenges_purpose_known;
      ALTER TABLE verification_challenges
        ADD CONSTRAINT verification_challenges_purpose_known
        CHECK (purpose IN ('phone_registration', 'email_registration', 'password_reset'));

      ALTER TABLE verification_proofs
        DROP CONSTRAINT verification_proofs_purpose_known;
      ALTER TABLE verification_proofs
        ADD CONSTRAINT verification_proofs_purpose_known
        CHECK (purpose IN ('phone_registration', 'email_registration', 'password_reset'));
    `,
  },
  {
    id: '003_google_sign_in',
    sql: `
      ALTER TABLE users ALTER COLUMN password_hash DROP NOT NULL;
      ALTER TABLE users ADD COLUMN google_sub text;
      ALTER TABLE users ADD CONSTRAINT users_google_sub_unique UNIQUE (google_sub);
      ALTER TABLE users ADD CONSTRAINT users_can_sign_in
        CHECK (password_hash IS NOT NULL OR google_sub IS NOT NULL);
    `,
  },
];
