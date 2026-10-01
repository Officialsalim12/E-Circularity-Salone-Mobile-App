# Open decisions

These are named in the definition and are not specs. Write the decision down, with who decided and the date, and update the note it affects. Do not let a pull request become the policy.

- Exact pilot geography. Freetown is the city. The boundary is not fixed.
- Partner onboarding. Verification steps and required partner data are incomplete.
- Collection price or incentive. No fee rule exists.
- Points earning rules. The example activities are not a policy.
- Points redemption. Redemption is a ledger event. No catalogue and no value.
- USSD. Cost and pilot need are not checked.
- WhatsApp. Not chosen as a channel or as a notice provider.
- SMS provider. None selected.
- Payments. Not in the first release until a decision adds them.
- Exact device categories. "Small consumer electronics" has no approved list.
- Recycling partner model. Receipt and recovery are required. The commercial model is not.
- Data retention. [TBD]
- Regulatory requirements. Sierra Leone duties are not recorded in this repo.
- Device valuation. No method.
- Repair and refurbishment commercial model. Who pays and who earns is [TBD].
- Ownership transfer. The device has an ownership reference. When it changes is [TBD].
- Impact method. Categories exist. Public formulas do not.
- Dispatch. An admin or a dispatch process assigns agents. Eligibility and automation are [TBD].
- Required photos. "Where required" is not a list.
- Device owner visibility. "Where appropriate" is not a field list.
- Notice channel per event. In-app, SMS, WhatsApp, email are possible.
- Collection point login. A place, or an actor with access. Unknown.
- Admin client. In scope. Technology [TBD].
- Backend language and framework. [TBD]
- Database product. Relational direction. Product [TBD].
- Session or token. [TBD]
- Map provider. Agents need location. No vendor chosen.
- On-device store for offline records. [TBD]
- Flutter state management. [TBD]. Pick it with the first real screen.

## Clashes

- **C-01** `COLLECTED` and `COMPLETED` are both collection statuses, with no difference.
- **C-02** Collection statuses and device lifecycle states are not mapped.
- **C-03** Partner, technician, refurbisher, recycler, and collection point are not one role model.
- **C-04** Agent assessment and technician assessment may be one step or two.
- **C-05** Freetown is the city, and the exact pilot geography is still open.
- **C-06** Collectors and parts-recovery operators are named in the network and are not defined as roles.

Detail is in [requirements.md](requirements.md).

When a decision is made, prefer the smallest design that meets the rule, a record you can trust, field work that survives a dead radio, rules on the server, and the connectivity and cost of operating in Sierra Leone.
