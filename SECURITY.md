# Security

The platform will hold names, phone numbers, collection locations, and device identifiers. Treat that as production data from the first feature that stores any of it.

The control list is in [docs/architecture/security.md](docs/architecture/security.md).

## Reporting a problem

There is no public disclosure process yet.

Until there is one, tell the maintainers in private. Do not open a public ticket that includes a working attack, personal data, or a live credential.

## While you are in the code

- Do not commit secrets, keystores, or production config.
- Do not log passwords, session tokens, IMEI values, or a full contact record.
- Do not show a device owner's personal details to every shop in the network.
- IMEI is sensitive. Treat serial numbers the same way until a privacy review says otherwise. That review has not happened.
- The server decides what a caller can see. Hiding a button is not access control.

The Android app does not collect or send data yet. There is no sign-in and no backend.
