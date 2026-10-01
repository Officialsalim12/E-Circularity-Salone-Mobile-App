# Requirements

Working baseline from Product Definition 1.0. The original text is [prd.md](prd.md).

None of this is in the app yet.

## Objectives

1. Device owners and organizations can register unwanted electronics.
2. They can request a collection.
3. Requests connect to Circularity Agents.
4. Device details are stored.
5. A device can be followed through its circular life.
6. Assessment is a real step, not a note in a chat.
7. Repair and refurbishment have a workflow.
8. Parts recovery and recycling have a workflow.
9. The Circularity Registry is the trace.
10. Circular Points exist as an incentive.
11. Agents can work offline.
12. The product is usable on a slow connection.
13. Admins can see the operation.
14. Circularity and impact reports can be produced.
15. The design can grow from the Freetown pilot toward national use without a rewrite.

Point rules for item 10 are [TBD]. The ledger requirement still stands.

## Scope

Phones, smartphones, feature phones, and small consumer electronics. Pilot focus is Freetown.

Pilot scale: 1,000 device owners, 20 agents, 10 repair or refurbishment partners, recycling partners, one platform.

Payments are [TBD]. They are not an implied feature. The rest of the deferred list is in [features.md](features.md).

## Identity and access

Users sign in. Access is by role. A user only reaches what that role needs. Admin functions need a higher grant. Passwords are stored as a one-way hash. Sessions or tokens must be protected. Which of those we use is [TBD].

## Devices

A device owner or an agent, if they are allowed, can register an eligible device. Registration returns a unique internal Device ID. That ID is the primary identifier.

The record can also hold category, brand, model, serial number, and IMEI, when those exist.

Ways to identify a device: internal Device ID, QR code, barcode, IMEI, serial number, manual entry.

IMEI is sensitive.

Also stored: condition, an ownership reference, collection status, lifecycle status, assessment, repair status, refurbishment status, recycling status, created time, updated time.

Do not collect personal data that the pickup, the identification, the operation, the trace, the message, the points, or the report does not need.

QR and barcode mean we can identify a device from the code. Label format and who prints it are [TBD].

## Registry

A device history can hold the identity fields, owner or organization, registration date, collection and agent, assessment and condition, repair, refurbishment, parts recovery, recycling, current lifecycle status, timestamps, handovers, partners, and audit history.

An authorized user can read the part of that history their role allows. Sensitive fields stay restricted.

Keep the history of meaningful transitions. The latest status is not a substitute.

## Collection

A device owner can request collection for one or more devices, give the collection details, give or pick a time window, and submit. The platform creates the request. An admin or a dispatch process assigns it to an eligible agent. An agent can see assigned collections and confirm collection.

Collection statuses:

```text
REQUESTED
ASSIGNED
ACCEPTED
EN_ROUTE
ARRIVED
COLLECTED
CANCELLED
FAILED
COMPLETED
```

Role and business rules control the changes. The legal transitions, who counts as eligible, and the difference between `COLLECTED` and `COMPLETED` are not defined. See C-01 and C-02.

## Field app

The agent app needs sign-in, profile, assigned collections, collection detail, route and location, customer contact, device registration, scanning, assessment, handover, required photos, offline use, sync, collection history, and a performance view.

Ask for as little typing as you can.

Agents need route and location. No map vendor is chosen. Do not pick one quietly.

## Offline

With no connection, and after tasks have already been synced onto the phone, an agent can view those tasks, create collection records, register devices, capture assessment, capture required photos, record handovers, update the local lifecycle, and queue sync events.

When the connection returns, the queue syncs. Each transaction has its own id. A duplicate submission must not create a second official event. Lifecycle events that matter have to survive. The server validates. Conflicts are handled, not dropped.

## Pathways

An authorized user can record an assessment.

Technicians record diagnosis, parts, repair status, and repaired or not repairable.

Refurbishers record the work, update condition, and mark ready for reuse or resale.

Recyclers confirm receipt, record the recycling work, record material recovery when they have it, and confirm downstream processing.

Parts recovery is its own pathway and its own registry record.

Commercial terms for this work are [TBD].

## Points

Points reward participation. Example activities, not a policy: registering an eligible device, completing a handover, a verified circular action, a referral, and other actions we later validate.

Store a ledger. Do not treat an overwritten balance as the record.

Transaction types: `POINT_EARNED`, `POINT_ADJUSTMENT`, `POINT_REDEEMED`, `POINT_EXPIRED`, `POINT_REVERSED`.

## Notifications

Events are listed in [user-flows.md](user-flows.md). Possible channels: in-app, SMS, WhatsApp, email. Which ones we actually run is [TBD].

## Partners and collection points

A partner record can hold name, type, contacts, location, services, verification status, operating status, supported categories, capacity, and activity history. Partners do not get open access.

A collection point is a physical place where devices are received and recorded.

## Admin, reports, audit

Admins manage the areas in [user-roles.md](user-roles.md) and can see the core counts in [features.md](features.md). Important actions write an audit event. Public impact numbers wait until the method is approved.

## Organizations

They can register, register many devices, request bulk collection, watch collection activity, and open reports. Report contents for this role are [TBD].

## Non-functional

Interactions should feel responsive on a normal network. No millisecond target is set.

Lifecycle transactions that matter are durable. If the process dies, the accepted write is still there.

Set an availability target before launch. The number is [TBD].

The design should grow from the Freetown pilot to a larger national network without a rewrite.

Screens have to cope with a slow connection, a small phone, and users who are not comfortable with apps.

Keep modules small, conventions steady, and the notes current.

Field work does not depend on a live connection.

Security is in [../architecture/security.md](../architecture/security.md). Collect the least personal data that the jobs above need. Impact numbers are only as good as the records under them.

## Acceptance

| Check | Passes when |
| --- | --- |
| Device registration | A user or an authorized agent registers an eligible device and gets a unique id |
| Collection | A device owner requests collection and the system assigns an eligible agent |
| Agent | An agent sees assigned collections and confirms collection |
| Assessment | An authorized user records an assessment |
| Lifecycle | Current status and the history of transitions are both kept |
| Registry | An authorized user can read the lifecycle record they are allowed to see |
| Offline | An agent creates a supported record offline and syncs it when the connection returns |
| Security | A user cannot read or change anything outside their role |
| Reporting | An admin can see the core operational counts |

## Clashes

Settle these before building the behavior they control.

### C-01. Two endings for a collection

`COLLECTED` and `COMPLETED` are both statuses. The definition never says how they differ, which one closes the request, or whether both are required.

Do not code collection transitions until this is decided.

### C-02. Collection status and device lifecycle are separate lists

Lifecycle uses `COLLECTION_REQUESTED`, `COLLECTION_ASSIGNED`, `COLLECTED`, `RECEIVED`.

The request also uses `ACCEPTED`, `EN_ROUTE`, `ARRIVED`, `CANCELLED`, `FAILED`, `COMPLETED`.

A device can look collected on one list and not received on the other. Cancelled and failed requests have no defined effect on the device.

Do not code a mapping until product and operations agree on one.

### C-03. The role lists do not match

One section describes device owner, agent, technician, refurbisher, recycler, organization, collection point, administrator, and partner.

The access-control section lists device owner, agent, technician, refurbisher, recycler, organization, partner, and administrator. Collection point is missing.

Partner is also the umbrella for repair, refurbishment, recycling, community, development, and government, while technician, refurbisher, and recycler are separate roles.

Do not freeze a permission table until this is decided.

### C-04. Assessment is described twice

The device owner journey has one assessment after handover. Agents do a preliminary assessment. Technicians record a diagnosis and can call a device not repairable.

Nobody has said whether the agent assessment is the technician record, an input to it, or a separate event.

Do not implement the assessment model until this is decided.

### C-05. Freetown, and also not fixed

The initial geography is Freetown. The exact pilot geography is also an open decision.

Both can be true if the city is Freetown and the neighborhoods are not chosen. They clash if someone treats all of Freetown as committed scope.

Confirm the boundary before rollout planning. It does not block the shell.

### C-06. Names with no role

The overview lists collectors and parts-recovery operators next to agents, technicians, refurbishers, and recyclers. The role sections never define those two.

They might be other names for agents, recyclers, or partners. That has not been said.

Do not create account types for them until product says what they are.

## Where the detail lives

Roles in [user-roles.md](user-roles.md). Journeys in [user-flows.md](user-flows.md). Modules in [features.md](features.md). Open items in [open-decisions.md](open-decisions.md). Lifecycle in [../operations/lifecycle.md](../operations/lifecycle.md). Collection operations in [../operations/collection.md](../operations/collection.md).
