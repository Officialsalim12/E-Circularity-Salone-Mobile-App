# Accounts

This is the account work that is in the repo. A person can open the Android app, create a device-owner account, sign in, and reset a password. Devices, collections, and the rest of the registry are not built yet.

The contract is in [../architecture/authentication.md](../architecture/authentication.md) and [../architecture/api.md](../architecture/api.md). How to run it is in [setup.md](setup.md). Decisions are dated in [../product/open-decisions.md](../product/open-decisions.md).

## What the phone does

The first screen is the splash. If a refresh token is already stored, the app opens the signed-in screen. Otherwise it shows onboarding, then sign-in.

From sign-in a person can create an account, sign in with a password, continue with Google, or reset a password. Create account asks for a full name, an email or a Sierra Leone phone number, and a password. The terms box starts unticked. **Create Account** and **Continue with Google** on that screen stay off until the box is ticked.

Email signup sends a 6-digit code, then saves the account only after the code matches. Phone signup checks the number the same way, before the name and password form. After either of those, the app opens sign-in and says the account is ready. It does not start a session.

**Continue with Google** works on both screens. The first time that email is used, the API creates a device owner, sends the welcome email, and signs them in. The next time, the same button just signs them in. Closing the Google sheet does not show an error. While Google is working, the spinner is on the Google button. The Sign In button only spins for a password sign-in.

Forms scroll. The picture under the form hides while the keyboard is open, so the field you tapped stays focused.

## What the API decides

The server owns the account. The app does not decide the role, hash the password, or trust an email the phone typed in for Google.

Public signup creates a device owner only. Passwords are 8 to 128 characters, stored as Argon2id. A sign-in lasts 15 minutes on the access token and 30 days on the refresh token. The phone keeps both in the platform secure store. Logout retires the refresh token. Sending a refresh token that was already retired retires the rest of that person's refresh tokens.

A verification code lasts 10 minutes and allows 5 tries. The proof after a correct code lasts 15 minutes. A password reset for an address we don't know still answers the same way and sends nothing. The code is never written to the log.

A Google account is accepted only after the API checks the ID token against Google's certificates and `GOOGLE_CLIENT_ID`. The email on that token has to be verified. The name and email come from the token. If that email already belongs to a different Google account, the API refuses. An account that only came from Google has no password. Password sign-in for it fails the same way as a wrong password. If someone later signs in with Google using an email that already has a password, that account is linked and they are signed in.

## Messages

Brevo sends the email and, when a sender id is set, the text.

A code email says the code and that it expires in 10 minutes, and that they can ignore it if they didn't ask. A password-reset email does the same with the reset wording. The welcome email does not include that ignore line. It greets them by name and says the account is ready. The text versions are the short form of the same notes.

`BREVO_SMS_SENDER` is still empty in local setup, so texts do not go out yet. Email does.

A failed welcome note does not undo the account.

## What we left alone

Lockout after bad sign-in attempts is still open. Agents, partners, and admins cannot create themselves in the app. Device registration, collection, and offline sync are not started. No client secret for Google is stored. The Android OAuth client stays in Google Cloud, matched to the app id and the debug SHA-1.
