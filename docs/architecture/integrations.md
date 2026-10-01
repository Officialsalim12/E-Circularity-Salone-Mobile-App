# Integrations

Nothing outside Circular Salone is connected. Do not create a vendor account, add an SDK, or store a credential until the decision for that vendor is written down.

| Need | Status |
| --- | --- |
| SMS | No provider. [TBD] |
| WhatsApp | No provider. [TBD] |
| Email | No provider. [TBD] |
| USSD | No aggregator. [TBD]. Not an MVP commitment |
| Maps and routing | No provider. Agents do need location. [TBD] |
| Payments | No provider. [TBD]. Not an MVP feature |
| Government reporting | No interface. Later |
| Development-partner reporting | No interface. Later |

In-app notices do not need an outside provider.

When a provider is added:

- Send only what that call needs.
- Do not send an IMEI or a full owner profile to a messaging vendor if a short operational message will do.
- Keep credentials out of the repo.
- Record enough delivery status for ops. Do not store a second copy of sensitive device data inside the message log.
- A failed SMS is not a failed collection. The lifecycle event still stands.
- Keep one module per provider so it can be replaced.

QR, barcode, and typing are the identification methods. Scanning uses the phone camera. No external scanner is specified.

Not in the pilot: a blockchain network, a crypto rail, a marketplace payment stack, or a model that chooses the pathway. An authorized person records the pathway.
