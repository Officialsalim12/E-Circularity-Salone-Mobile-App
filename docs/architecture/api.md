# API

Clients use a versioned HTTP API.

```text
/api/v1/
```

A later incompatible API can ship as `/api/v2/` without breaking a client still on version 1.

No endpoint list is approved beyond auth. The names below come from the definition. Paths and payloads for the other areas get written when that module is designed, after the open decisions for that module are closed.

```text
/auth
/users
/device-owners
/devices
/collections
/agents
/assessments
/repairs
/refurbishments
/parts
/recycling
/registry
/partners
/points
/notifications
/reports
/admin
```

Organizations, collection points, audit, and sync are required and are missing from that list. Add them during API design, either as their own areas or under an existing one. Do not drop them because the example list forgot them.

## Rules

The API is the only supported way for a client to change official data.

## Auth

These routes are the contract for the screens in the app today. Other areas in the list above are not implemented.

| Method and path | What it does |
| --- | --- |
| `POST /api/v1/auth/register` | Creates a device owner. Does not sign them in. Needs an email or a phone, the matching verification token, and `acceptedTerms: true`. |
| `POST /api/v1/auth/login` | Email or Sierra Leone phone, plus password. Returns tokens. An account with no password fails this the same way as a wrong password. |
| `POST /api/v1/auth/google` | Body is `idToken`, `intent` (`sign_in` or `sign_up`), and `acceptedTerms: true` when the intent is `sign_up`. The API checks the token. A new email becomes a device owner, gets the welcome email, and gets tokens. An email that already exists signs in and is linked to that Google account if it was not linked yet. |
| `POST /api/v1/auth/refresh` | Trades a refresh token for a new pair and retires the one you sent. |
| `POST /api/v1/auth/logout` | Retires the refresh token you sent. |
| `POST /api/v1/auth/verification-codes` | Sends a code for `email_registration`, `phone_registration`, or `password_reset`. Body is `purpose` and `destination`. Email goes out through Brevo email. A Sierra Leone number goes out as a Brevo text. Signing up with an address that already has an account returns a conflict. A reset for an address we don't know still returns accepted and sends nothing. |
| `POST /api/v1/auth/verification-codes/confirm` | Checks the 6-digit code and returns a `verificationToken`. |
| `POST /api/v1/auth/password-reset` | Sets a new password with that token and signs the account out everywhere. |
| `GET /api/v1/auth/me` | The signed-in account. Needs `Authorization: Bearer`. |
| `GET /api/v1/health` | The process is up. No account data. |

A token response is `accessToken`, `refreshToken`, `expiresInSeconds`, and `user` (`id`, `fullName`, `email`, `phone`, `role`). A failure is `{ "error": { "code", "message" } }`. `code` is `validation_failed`, `unauthorized`, `conflict`, or `unavailable`. The message is safe to show in the app.

Calls that change data or read private data require authentication. The exception is the call that creates a session or starts registration. Public registration from the mobile create-account screen creates a device owner.

The server checks the caller's role and the specific record.

Bad input does not change the registry.

A write from the offline queue carries the sync transaction id. Repeating that id does not create a second official event.

Lists for field staff should stay small. Pagination is [TBD].

Photo uploads are authorized and size-limited. The limit is [TBD].

An error tells the client whether validation failed, authorization failed, or the lifecycle clashed. It does not leak another person's data.

## What each area is for

These are jobs, not URLs.

Auth signs a person in and out and establishes the role. Users and device owners cover the account. Devices register a device and return the fields that role may see. Collections create a request, assign it, and move collection status. Agents cover the profile and assigned work. Assessments record the assessment. Repairs, refurbishment, parts, and recycling record pathway work. Registry returns the history the caller may see. Partners cover partner records and partner-scoped activity. Points return the ledger. Only an admin posts an adjustment they are allowed to make. Notifications register a destination and record delivery where a channel exists. Reports serve admin metrics and the narrower reports other roles are allowed. Admin covers user, config, and workflow management.

Assignment may be an admin action rather than an open edit on the collection. That URL is [TBD], with the dispatch rules.

Once a pilot build is on a version, add fields in a compatible way. Removing or renaming a field needs a new version, or a migration plan for the app and any offline queue that still has the old shape.
