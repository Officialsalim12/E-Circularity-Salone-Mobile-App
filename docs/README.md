# Documentation

Start here if you are new to the repo.

The product definition is [product/prd.md](product/prd.md). The other files are notes taken from it so the team can work without rereading the whole definition. If a note and the definition disagree, fix the note. If the definition disagrees with itself, that clash is listed in [product/requirements.md](product/requirements.md). Do not resolve it in code.

Anything the definition does not say is marked **[TBD]**.

The setup brief and the definition named two different doc trees. We kept one tree:

```text
docs/
├── product/
├── architecture/
├── operations/
├── development/
├── deployment/
└── impact/
```

A few names differ from the definition's sketch:

| Sketch in the definition | File we use |
| --- | --- |
| users-and-roles | [product/user-roles.md](product/user-roles.md) |
| user-journeys | [product/user-flows.md](product/user-flows.md) |
| system, frontend | [architecture/overview.md](architecture/overview.md), [architecture/mobile-app.md](architecture/mobile-app.md) |
| coding-standards | [development/coding-guidelines.md](development/coding-guidelines.md) |
| operations/agents | No separate file. Agent work is in the role, flow, and collection notes. |
| one deployment file | [deployment/environments.md](deployment/environments.md), [deployment/ci-cd.md](deployment/ci-cd.md), [deployment/release-process.md](deployment/release-process.md) |

Read [product/vision.md](product/vision.md), then roles, flows, and requirements. Architecture after that. Open items are in [product/open-decisions.md](product/open-decisions.md). What is actually built for accounts is in [development/accounts.md](development/accounts.md).

| | |
| --- | --- |
| Definition | Draft 1.0 |
| Devices | Phones and small consumer electronics |
| Place | Freetown |
| Pilot boundary | [TBD] |
