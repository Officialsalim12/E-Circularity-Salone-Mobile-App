# Environments

Three environments:

```text
Development -> Staging -> Production
```

Development is local and shared engineering work. Staging is where a release is checked before it goes live. Production is the pilot.

Nothing is hosted. The provider is [TBD].

Config that changes between environments is not hard-coded. Secrets are not committed. The secret store product is [TBD].

Do not copy production data into development unless that copy is approved and stripped of personal data and sensitive device identifiers. The masking steps are [TBD].

Each environment has its own database.

The app points at one API base URL per build. A pilot build must not be left pointed at a development API.

`.env.example` lists the variable names. It has no secrets. A real `.env` stays on the machine.

A change is tried in development, checked in staging, then deployed to production. Production needs the approval in [release-process.md](release-process.md).
