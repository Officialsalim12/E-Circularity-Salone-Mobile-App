# Circular Salone

Circular Salone tracks used phones and small electronics in Sierra Leone from registration through collection, assessment, repair, refurbishment, parts recovery, or recycling.

The record of that journey is the Circularity Registry. The first release is a Freetown pilot. It has to show that a real device can be collected by a real agent, assessed, sent down a circular path, and recorded the whole way.

Nothing in the app does that yet. This repository has the product notes, the architecture notes, and an Android app shell.

## Status

| Item | State |
| --- | --- |
| Product definition | Draft 1.0 |
| Mobile | Flutter, Android only |
| Backend | Not chosen |
| Database | Relational. Product not chosen |
| Admin and web clients | Not chosen |
| Pilot boundary inside Freetown | Not fixed |

Where a rule is missing, the docs say **[TBD]**. Do not fill those gaps in code.

## People who use it

Households, Circularity Agents, repair technicians, refurbishers, recyclers, businesses, collection points, partners, and administrators. What each one can do is in [docs/product/user-roles.md](docs/product/user-roles.md).

## Layout

```text
.
├── frontend/mobile/ Android app shell
├── backend/         Not started
├── database/        Not started
├── docs/
├── scripts/
├── .github/workflows/
├── CONTRIBUTING.md
├── SECURITY.md
└── CHANGELOG.md
```

The product definition sketched `apps/web` and `apps/admin`. Those clients are not in the repo. The mobile client is `frontend/mobile`. Admin is in the first release. The app that delivers it is [TBD].

## Read this first

[docs/README.md](docs/README.md)

The original definition is [docs/product/prd.md](docs/product/prd.md). If a working note and that file disagree, fix the notes. If the definition disagrees with itself, the clash is written up in [docs/product/requirements.md](docs/product/requirements.md). Do not pick a side in code.

## App

`frontend/mobile` currently shows the name and nothing else. Setup is in [docs/development/setup.md](docs/development/setup.md).

## License

[TBD]
