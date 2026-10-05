# Integrations

Verification codes go through Brevo, by email or by SMS. Google is used only to check a sign-in token. Do not add another vendor until that decision is written down.

| Need | Status |
| --- | --- |
| SMS | Brevo texts. Phone signup code, the welcome text, and a phone password reset. The sender id comes from the environment |
| WhatsApp | No provider. [TBD] |
| Email | Brevo email. Signup code, the welcome note, and password reset. The sender address and API key come from the environment |
| Google sign-in | The phone uses the Google account sheet. The API checks the ID token with Google's public certificates. The web client id is `GOOGLE_CLIENT_ID`. The Android client is the package name plus the debug SHA-1 in Google Cloud. No client secret is stored |
| USSD | No aggregator. [TBD]. Not an MVP commitment |
| Maps and routing | No provider. Agents do need location. [TBD] |
| Payments | No provider. [TBD]. Not an MVP feature |
| Government reporting | No interface. Later |
| Development-partner reporting | No interface. Later |

In-app notices do not need an outside provider.

When a provider is added:

- Send only what that call needs.
- Do not send an IMEI or a full owner profile to a messaging vendor if a short operational message will do.
- Keep credentials out of the repo.
- Record enough delivery status for ops. Do not store a second copy of sensitive device data inside the message log.
- A failed SMS is not a failed collection. The lifecycle event still stands.
- Keep one module per provider so it can be replaced.

QR, barcode, and typing are the identification methods. Scanning uses the phone camera. No external scanner is specified.

Not in the pilot: a blockchain network, a crypto rail, a marketplace payment stack, or a model that chooses the pathway. An authorized person records the pathway.
