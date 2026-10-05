# Features

Status words used here:

- **MVP**: needed to answer the first-release question
- **Later**: future, or called out as not in the first release
- **Open**: named, but the rule is not solid enough to build

Nothing was added because other platforms usually have it.

## MVP

| Module | Needed behavior |
| --- | --- |
| Sign-in | Each role gets in and only reaches the actions they are allowed |
| Users | People and organizations on the platform |
| Device registration | An eligible device gets a unique internal id |
| Collection | A device owner can request pickup. The system can assign an eligible agent |
| Agent | An agent sees assigned pickups and can confirm collection |
| Assessment | An authorized person can record an assessment |
| Lifecycle | Current status, plus the history of real transitions |
| Repair, refurbishment, recycling | The basic path workflows |
| Registry | An authorized person can read the lifecycle record they are allowed to see |
| Notifications | Basic notices for the important lifecycle events |
| Admin | Operational view and the core management screens |
| Offline sync | An agent can write the supported records offline and sync them later |
| Reporting | Admins can see the core operational counts |

Device owners, parts recovery, collection points, partners, and the audit log are named modules. The registry and the admin scope need them, so they sit in the first release even where the screens are not drawn.

## Named, rules not ready

| Module | Known | Open |
| --- | --- | --- |
| Circular Points | Incentive. Ledger of transactions. Do not overwrite a balance and call that the record | Earn, redeem, expiry, referral |
| Impact | Count from records. Do not publish a number you cannot trace | Public definitions |
| Analytics | Operational and impact data should be available | Which views exist past the admin counts |
| Agent assessment | Agents can capture an early assessment | How it relates to the technician assessment. C-04 |

## Not in the first release

Do not build these unless a later decision adds them:

- Blockchain
- Cryptocurrency
- A split into many deployed services with no proven need
- Automated pathway decisions
- Nationwide rollout
- A finance system
- A marketplace
- Device categories beyond phones and small electronics
- Predictive analytics
- A shop for refurbished devices
- Take-back programs and institutional collection, beyond the organization account already in scope
- Circular finance
- A government reporting feed
- A development-partner dashboard
- National analytics

Organization accounts, bulk collection, and organization reports are in the role list and are not on the out-of-scope list. They stay in scope at the level in [user-roles.md](user-roles.md). A full institutional e-waste program is later.

## Payments

Payment integration is an open decision. It is not an MVP feature. No prices, payouts, or payment providers until that decision exists.

## Channels

The Android app is the mobile client we are building.

Mobile web, USSD, SMS, WhatsApp, and assisted access are still being considered. They are not MVP commitments. SMS and WhatsApp may also be how we send notices. Using them to request a pickup is a separate decision.

## Admin areas

Overview: devices registered, requests, completed collections, devices in processing, repaired, refurbished, reused, recycled.

Operations: collections, agents, partners, devices, lifecycle.

Users: device owners, agents, partners, organizations, administrators.

Reports: collection, lifecycle, circularity, impact, agent activity, partner activity.

The admin client technology is [TBD]. Do not assume those screens live inside the Android field app.

The Android app can sign in, create a device-owner account, confirm an email or phone, reset a password, and continue with Google. The other modules above are not in the app yet. The write-up of that account work is in [../development/accounts.md](../development/accounts.md).
