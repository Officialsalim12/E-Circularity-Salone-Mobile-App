# Roles

A person sees the records their job needs. Admin actions need a higher grant.

The definition does not use one role list. That clash is C-03 in [requirements.md](requirements.md). The notes below repeat what the definition says. They do not merge the lists.

## Household

Can create an account, register a device, request collection, see collection status, see lifecycle detail where that is appropriate, get notifications, earn Circular Points where the rules apply, and see their own contribution history.

Point rules are [TBD]. Which lifecycle fields a household sees is [TBD].

## Circularity Agent

Field staff. They collect devices and move them on.

They receive assignments, see the location, contact the requester, confirm collection, register devices, capture device details, do a preliminary assessment, record handover, work offline, and sync when the network is back.

The agent app also needs a profile, scanning, photos where a rule requires them, collection history, and some performance view. Which photos are required is [TBD]. What the performance view shows is [TBD].

Offline behavior is in [../architecture/offline-sync.md](../architecture/offline-sync.md).

## Repair technician

Receives a device, records the diagnosis, opens a repair record, records parts used, updates repair status, and marks the device repaired or not repairable.

## Refurbisher

Receives an eligible device, does the refurbishment, records the work, updates condition, and marks it ready for reuse or resale.

What "eligible" means is [TBD].

## Recycler

Receives devices or materials, confirms receipt, records the recycling work, records material recovery when the numbers exist, and confirms downstream processing.

## Organization

Can register an organization account, register many devices, request a bulk collection, watch collection activity, and open reports.

Which reports they get is [TBD].

## Collection point

A place where devices are received and written into the system.

The definition does not say whether that place has a login or is only a location on an agent or admin screen. That sits inside C-03.

## Administrator

Manages users, agents, devices, collections, partners, categories, workflows, points, reports, configuration, and the audit log.

The audit log is who did what, and when.

They also need counts for registered devices, requests, completed collections, devices in processing, and devices repaired, refurbished, reused, or recycled.

## Partner

Repair shops, refurbishers, recyclers, community groups, development partners, government. Access follows the partner's job. A partner account is not a master key.

Technician, refurbisher, and recycler are also their own roles. We have not decided if those people sign in as a partner, as the specialist role, or as both. See C-03.

## Access-control list in the definition

Household, Circularity Agent, Technician, Refurbisher, Recycler, Organization, Partner, Administrator.

Collection point is described as a participant and is missing from this list.

## What stays private

Data collected for pickup, identification, operations, traceability, messages, points, or reports does not automatically show up for every participant.

IMEI is visible only to people who are allowed to see it. The field-by-field grants wait until C-03 is settled.
