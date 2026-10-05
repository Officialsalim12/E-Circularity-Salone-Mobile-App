// Checks a Google ID token. The phone never gets to tell us the email itself.
import { createRemoteJWKSet, jwtVerify } from 'jose';

const googleCerts = createRemoteJWKSet(new URL('https://www.googleapis.com/oauth2/v3/certs'));

export type GoogleIdentity = {
  sub: string;
  email: string;
  name: string;
};

export async function verifyGoogleIdToken(
  idToken: string,
  clientId: string,
): Promise<GoogleIdentity> {
  const { payload } = await jwtVerify(idToken, googleCerts, {
    issuer: ['https://accounts.google.com', 'accounts.google.com'],
    audience: clientId,
  });
  const sub = typeof payload.sub === 'string' ? payload.sub : '';
  const email = typeof payload.email === 'string' ? payload.email : '';
  const verified = payload.email_verified === true || payload.email_verified === 'true';
  const name = typeof payload.name === 'string' ? payload.name.trim() : '';
  if (!sub || !email || !verified) {
    throw new Error('incomplete google identity');
  }
  return { sub, email, name };
}
