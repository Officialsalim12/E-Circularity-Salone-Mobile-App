# Roadmap

No dates. None were given.

## Now

Notes, the Android shell, the repo layout, and a workflow that analyzes the app. No accounts, pickups, or registry in the app.

## Before the affected features

Confirm the items that change scope:

- Pilot geography and scale
- Roles, including partners and collection points
- How collection status lines up with the device lifecycle
- Whether assessment is one record or two
- Whether organization bulk collection is in the first pilot or the next slice

Close C-01 through C-05 before building the workflows they touch. C-05 does not block the technical shell. Close C-06 before adding a collector or parts-recovery login.

## Build order

```text
Product validation
Pilot definition
Technical architecture
Repository setup          <- here
Database design
Backend foundation
Auth
Device registry
Collection
Agent app
Assessment
Lifecycle
Offline sync
Repair, refurbishment, recycling
Admin
Reporting
Security pass
Pilot
Pilot review
Next iteration
```

Repository setup is the current step. Database design can start for identities, devices, collections, and lifecycle events that are already defined. Leave points, ownership transfer, and payments unset.

Design offline sync with collection and assessment. Do not build those flows as if the radio is always up and bolt sync on later.

## First release

The question is whether an owner, an agent, and a real pathway can be connected and recorded. Priorities are in [features.md](features.md). Acceptance checks are in [requirements.md](requirements.md).

## After a pilot that works

More device categories, larger businesses, institutional programs, a national network, more partners and drop-off points, heavier impact reports, government feeds, development-partner reports, use outside the pilot, a marketplace, refurbished-device sales, take-back programs, finance tools, national analytics.

Each one needs its own decision.

## Left out of the first release

Blockchain, cryptocurrency, a microservice split we do not need, automated decisions, nationwide rollout, a finance system, a marketplace, a wide device catalogue, predictive analytics.
