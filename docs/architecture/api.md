# API

Clients use a versioned HTTP API.

```text
/api/v1/
```

A later incompatible API can ship as `/api/v2/` without breaking a client still on version 1.

No endpoint list is approved. The names below come from the definition. Paths and payloads get written when the module is designed, after the open decisions for that module are closed.

```text
/auth
/users
/households
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

Calls that change data or read private data require authentication. The exception is the call that creates a session or starts registration. The public registration shape is [TBD].

The server checks the caller's role and the specific record.

Bad input does not change the registry.

A write from the offline queue carries the sync transaction id. Repeating that id does not create a second official event.

Lists for field staff should stay small. Pagination is [TBD].

Photo uploads are authorized and size-limited. The limit is [TBD].

An error tells the client whether validation failed, authorization failed, or the lifecycle clashed. It does not leak another person's data.

## What each area is for

These are jobs, not URLs.

Auth signs a person in and out and establishes the role. Users and households cover the account. Devices register a device and return the fields that role may see. Collections create a request, assign it, and move collection status. Agents cover the profile and assigned work. Assessments record the assessment. Repairs, refurbishment, parts, and recycling record pathway work. Registry returns the history the caller may see. Partners cover partner records and partner-scoped activity. Points return the ledger. Only an admin posts an adjustment they are allowed to make. Notifications register a destination and record delivery where a channel exists. Reports serve admin metrics and the narrower reports other roles are allowed. Admin covers user, config, and workflow management.

Assignment may be an admin action rather than an open edit on the collection. That URL is [TBD], with the dispatch rules.

Once a pilot build is on a version, add fields in a compatible way. Removing or renaming a field needs a new version, or a migration plan for the app and any offline queue that still has the old shape.
