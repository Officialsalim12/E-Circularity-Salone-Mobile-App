# Circular Salone

Circular Salone tracks used phones and small electronics in Sierra Leone from registration through collection, assessment, repair, refurbishment, parts recovery, or recycling.

The record of that journey is the Circularity Registry. The pilot is 1,000 device owners in Freetown. It has to show that a real device can be collected by a real agent, assessed, sent down a circular path, and recorded the whole way.

Nothing in the app does that yet. This repository has the project notes, the architecture notes, and an Android app shell.

## Status

| Item | State |
| --- | --- |
| Mobile | Flutter, Android |
| Admin and client | Web |
| Database | Neon PostgreSQL |
| Pilot | 1,000 device owners in Freetown |

Where a rule is missing, the docs say **[TBD]**. Do not fill those gaps in code.

## People who use it

Device owners, Circularity Agents, repair technicians, refurbishers, recyclers, businesses, collection points, partners, and administrators. What each one can do is in [docs/product/user-roles.md](docs/product/user-roles.md).

## Layout

```text
.
├── frontend/mobile/ Android app shell
├── backend/         Not started
├── database/        Neon PostgreSQL. Schema not started
├── docs/
├── scripts/
├── .github/workflows/
├── CONTRIBUTING.md
├── SECURITY.md
└── CHANGELOG.md
```

The mobile client is `frontend/mobile`. The admin and the client are web applications. Those web apps are not in the repo yet.

## Read this first

[docs/README.md](docs/README.md)

## App

`frontend/mobile` currently shows the name and nothing else. Setup is in [docs/development/setup.md](docs/development/setup.md).

## License

[TBD]
