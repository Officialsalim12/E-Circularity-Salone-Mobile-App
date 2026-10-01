# Partners and collection points

Partners are the organizations that do or support the circular work. They have records in the platform. They do not get open access.

Named types: repair businesses, refurbishment businesses, recycling organizations, community organizations, development partners, government.

Technician, refurbisher, and recycler are also user roles. Whether a person signs in as that role, as a partner user, or as both is C-03. Onboarding steps are [TBD].

A partner record may hold the organization name, partner type, contacts, location, services, verification status, operating status, supported device categories, capacity, and activity history.

Verification status and operating status have no approved value lists. Capacity has no unit.

| Work | What gets recorded |
| --- | --- |
| Repair | Diagnosis, parts used, repair status, repaired or not repairable |
| Refurbishment | Work done, updated condition, ready for reuse or resale |
| Recycling | Receipt, recycling activity, material recovery when known, downstream confirmation |
| Community, development, government | No separate workflow |

Repair, refurbishment, and recycling partners are linked to the pathway records. They should see the device detail they need to do the work, not the full device owner profile by default.

Who pays for repair or refurbishment, and how a partner is paid, is [TBD]. Do not encode a price list.

A collection point is a place where devices are received and recorded. It has no defined fields beyond that, and no defined login. Admins manage partners and locations. Settle the collection-point fields with C-03.

Partner activity feeds admin reports and impact counts. Record it through the pathway transactions. Do not keep a separate unverified total.
