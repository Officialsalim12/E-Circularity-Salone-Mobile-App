# Reporting

Admins, and later authorized organizations, need a view of the operation and, once the method exists, the approved impact measures.

Admins need collection, lifecycle, circularity, impact, agent activity, and partner activity. Organizations can open reports. Which ones is [TBD]. Development-partner and government dashboards are later. They are not in the first release.

Agents can see performance information. What that screen contains is [TBD]. It is not the public impact report.

## Counts the definition names

Collection: number of requests, completed collections, failed collections, collection time, collection geography.

"Completed" and "failed" depend on C-01. Do not publish a completed-collection total until `COMPLETED`, `COLLECTED`, and `FAILED` are defined. Collection time and geography have no agreed calculation or map boundary.

Devices: registered, collected, categories, conditions.

Circularity: repaired, refurbished, reused, components recovered, recycled.

Participation: active households, active agents, active partners. "Active" has no time window. [TBD]

## Admin overview

Devices registered, collection requests, completed collections, devices in processing, repaired, refurbished, reused, recycled.

"In processing" means the device has entered the network and has not reached an end outcome. Which states are terminal is still open. See [../operations/lifecycle.md](../operations/lifecycle.md).

Reports read the registry and the related records. They do not create another lifecycle status.

Impact reports also need an approved definition from [metrics.md](metrics.md). Until that exists, admins can see operational counts, and those counts should be labeled as operational counts.

Aggregate reports should not list household names, phone numbers, or IMEI values. Looking up one household is a separate authorized screen, not a report export.

Export format and scheduled delivery are [TBD].
