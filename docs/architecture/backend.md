# Backend

The backend is the system of record. It checks every official change to users, devices, collections, assessments, pathway work, points, and the registry.

The runtime is Node.js, TypeScript, and Fastify. The store is PostgreSQL. One service. Do not split the pilot into separately deployed services. The auth module is implemented. The other areas below are not.

```mermaid
flowchart LR
  client[Client]
  route[Route]
  controller[Controller]
  service[Service]
  repository[Repository]
  database[Database]

  client --> route --> controller --> service --> repository --> database
```

The route maps an address to a controller action. The controller reads the request, checks the shape, calls a service, and writes the response. The service applies the rule and decides if the change is allowed. The repository reads and writes the database.

Lifecycle rules, point rules, and permission rules do not belong in the controller.

## Areas

Auth, users, device owners, organizations, devices and identifiers, collections and agents, assessments, repairs, refurbishment, parts recovery, recycling, registry and lifecycle history, partners, collection points, the points ledger, notifications, audit, reporting, and sync intake.

## Sync intake

The phone submits queued transactions. The backend:

1. Reads the transaction id.
2. Rejects a duplicate of an id it already accepted.
3. Checks the caller's role.
4. Checks the lifecycle or collection change is legal.
5. Writes the official record and the audit event.
6. Returns what the phone needs to update its local copy.

Conflict rules are [TBD]. Do not drop a lifecycle event to clear a conflict.

## Rules that stay here

Whether a role may do the action. Whether a status change is legal. Whether a device identifier already exists. Whether an agent is eligible for an assignment. The official points ledger. Which fields a caller may see on a registry record.

Agent eligibility is [TBD]. The check still belongs on the server once the rule exists.

## Config and logs

Environment values come from configuration, not from source. Secrets stay out of the repo. See [../deployment/environments.md](../deployment/environments.md).

Logs should help ops and an audit review. They must not contain passwords, tokens, or a raw IMEI. Tie a client request to the server record with a correlation id. Log format is [TBD].

Do not build a second backend for admin, a separate analytics database, a chain, a crypto wallet, payment processing, or a public government feed yet.
