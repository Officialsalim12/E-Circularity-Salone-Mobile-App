# Backend

The backend owns the business rules. The phone must not carry a second copy of them.

Not started. Language and framework are not chosen. Do not add a scaffold until they are. An empty framework in the repo would become the decision by accident.

What is already set:

- Versioned API. The prefix in the product definition is `/api/v1/`.
- A request goes route, controller, service, repository, database.
- Rules live in the service layer, not in the controller.
- The transactional store is relational unless a later review shows a real reason to use something else.
- Lifecycle writes have to survive a process crash.

Still open: language, database product, host, and whether auth is a server session or a token.

See [docs/architecture/backend.md](../docs/architecture/backend.md) and [docs/architecture/api.md](../docs/architecture/api.md).
