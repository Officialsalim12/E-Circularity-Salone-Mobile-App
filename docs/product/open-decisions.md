# Open decisions

These are named in the definition and are not specs. Write the decision down, with who decided and the date, and update the note it affects. Do not let a pull request become the policy.

## Decided

- **2026-10-05.** Backend runtime is Node.js, TypeScript, and Fastify. One service: route, controller, service, repository, PostgreSQL.
- **2026-10-05.** Database product is PostgreSQL.
- **2026-10-05.** The mobile app uses a short-lived bearer access token (15 minutes) and a longer-lived refresh token (30 days). The app stores both in the platform secure store (`flutter_secure_storage`: Android Keystore, iOS Keychain). Logout revokes the refresh token. A reused revoked refresh token revokes the rest of that user's refresh tokens.
- **2026-10-05.** Create account on the phone makes a device owner, not an agent, partner, or admin. Email and phone both need a 6-digit code first. Brevo sends that code, then a welcome note on the same channel. The app opens sign-in. It does not start a session.
- **2026-10-05.** Passwords for this client are 8 to 128 characters, stored as an Argon2id hash. A stricter policy is still open.
- **2026-10-05.** Forgot password sends a 6-digit code to the email or Sierra Leone number on the account, then asks for a new password. The code lasts 10 minutes and allows 5 tries. The proof after the code lasts 15 minutes. Brevo sends it. We don't log the code.
- **2026-10-05.** Email and SMS delivery are both Brevo. The API key, verified sender address, and approved SMS sender id come from the environment.
- **2026-10-05.** Continue with Google checks a Google ID token on the API. The audience is the web client id. A new Google email becomes a device owner, gets the welcome email, and starts a session, including from the sign-in screen. The create-account screen still requires the terms box before that button can be used. Email or phone signup still does not start a session.

## Still open

- Exact pilot geography. Freetown is the city. The boundary is not fixed.
- Partner onboarding. Verification steps and required partner data are incomplete.
- Collection price or incentive. No fee rule exists.
- Points earning rules. The example activities are not a policy.
- Points redemption. Redemption is a ledger event. No catalogue and no value.
- USSD. Cost and pilot need are not checked.
- WhatsApp. Not chosen as a channel or as a notice provider.
- Payments. Not in the first release until a decision adds them.
- Exact device categories. "Small consumer electronics" has no approved list.
- Recycling partner model. Receipt and recovery are required. The commercial model is not.
- Data retention. [TBD]
- Regulatory requirements. Sierra Leone duties are not recorded in this repo.
- Device valuation. No method.
- Repair and refurbishment commercial model. Who pays and who earns is [TBD].
- Ownership transfer. The device has an ownership reference. When it changes is [TBD].
- Impact method. Categories exist. Public formulas do not.
- Dispatch. An admin or a dispatch process assigns agents. Eligibility and automation are [TBD].
- Required photos. "Where required" is not a list.
- Device owner visibility. "Where appropriate" is not a field list.
- Notice channel per event. In-app, SMS, WhatsApp, email are possible.
- Collection point login. A place, or an actor with access. Unknown.
- Admin client. In scope. Technology [TBD].
- Map provider. Agents need location. No vendor chosen.
- On-device store for offline records. [TBD]
- Flutter state management. [TBD]. Pick it with the first real screen.

## Clashes

- **C-01** `COLLECTED` and `COMPLETED` are both collection statuses, with no difference.
- **C-02** Collection statuses and device lifecycle states are not mapped.
- **C-03** Partner, technician, refurbisher, recycler, and collection point are not one role model.
- **C-04** Agent assessment and technician assessment may be one step or two.
- **C-05** Freetown is the city, and the exact pilot geography is still open.
- **C-06** Collectors and parts-recovery operators are named in the network and are not defined as roles.

Detail is in [requirements.md](requirements.md).

When a decision is made, prefer the smallest design that meets the rule, a record you can trust, field work that survives a dead radio, rules on the server, and the connectivity and cost of operating in Sierra Leone.
