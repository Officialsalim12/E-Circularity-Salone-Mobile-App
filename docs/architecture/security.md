# Security

Controls from the product definition. Checklists get added when the backend exists.

Sign-in for every role that uses the system. Passwords stored as a one-way hash. Sessions or tokens protected. Role checks on the API, limited to the caller's records. Reject bad input. Slow abusive repeated calls. The limits are [TBD]. Treat uploads as untrusted, and only from an authorized caller. Write an audit event for important actions. Encrypt traffic in transit, which means HTTPS. Encrypt sensitive data at rest where that is warranted. IMEI is explicitly sensitive. Secrets stay out of source and out of the app binary. Development, staging, and production config stay separate. Scan dependencies for known holes. Cover the usual injection, authentication, and access-control failures.

The production availability target is [TBD]. Monitoring and an incident process are [TBD].

## Privacy

Collect only what collection, identification, operations, traceability, messages, points, or reporting need.

Personal details do not automatically go to every repairer, recycler, or partner. The assigned agent needs the contact details to finish that pickup. Wider sharing needs a reason.

Ownership, location, phone number, and device identifiers are operational. They are still personal or sensitive when they identify a person or an owner.

| Data | Handling |
| --- | --- |
| IMEI | Restrict who can see it. Protect how it is stored |
| Serial number | Same, until a privacy review says otherwise. No review yet |
| Internal Device ID | Primary id. Do not use a raw IMEI as this id |
| Collection location | Assigned agent and authorized ops staff |
| Evidence photos | May show a home, a person, or a device. Same need-to-know rule |

An audit event names the actor, the action, the subject, and the time. It does not store a password, a token, or a spare copy of an IMEI.

The Android app must not embed production secrets. Offline copies of contacts and identifiers have to be protected on the device. The mechanism is [TBD] with the storage choice. Once pilot data exists, debug logs still do not get real personal data.

Legal duties, including any registration or transfer limits, are [TBD]. Confirm them before production data is collected. This note does not claim legal compliance.

A blockchain is not a security control here, and it is not in the first release.
