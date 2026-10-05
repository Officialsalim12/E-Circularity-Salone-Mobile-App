# Backend

The backend owns the business rules. The phone must not carry a second copy of them.

Runtime: Node.js, TypeScript, and Fastify. Store: PostgreSQL. The auth module is the part connected to the current app. Other modules are not built.

```text
backend/
├── src/
│   ├── server.ts
│   ├── app.ts
│   ├── config.ts
│   ├── db/
│   ├── http/
│   ├── modules/auth/
│   │   ├── auth.routes.ts
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   └── auth.repository.ts
│   └── providers/
└── docker-compose.yml
```

A request goes route, controller, service, repository, database. Rules live in the service. The repository does not decide whether a caller is allowed.

Local setup is in [docs/development/setup.md](../docs/development/setup.md). What the account work covers is in [docs/development/accounts.md](../docs/development/accounts.md). The auth contract is in [docs/architecture/api.md](../docs/architecture/api.md).

Still open: where this runs in production, and every module past auth. Codes and welcome notes go through Brevo. The database URL stays in the environment.
