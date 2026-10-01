# Coding guidelines

These apply to the Flutter app now. Backend style gets added when the language is chosen.

Keep modules small. Follow the feature layout in [../architecture/mobile-app.md](../architecture/mobile-app.md). Official rules go in backend services, not in widgets and not in controllers. The phone may cache data and guide the user. The server decides. Spell lifecycle, collection, and household names in full.

In Dart, keep the types. Avoid `dynamic` unless a boundary really has no type. Use single quotes. The analyzer enforces that. Do not leave `print` in committed code. Use a logger when logging exists. `main.dart` only starts the app. Screens do not call the database or build HTTP requests. Data code does not build widgets. Add a package when a feature needs it, and say why in the change.

Validate input where it arrives. A failed action must not be reported as a lifecycle change. Show the user a plain message. Keep the technical detail in logs, without secrets or IMEI values. An offline failure stays in the sync queue with its transaction id.

Use the internal Device ID as the primary identifier. Treat IMEI and serial numbers as sensitive. Do not log personal data, tokens, or passwords. Do not hard-code environment URLs, keys, or pilot household data.

Comment a constraint that is not obvious, such as why a transaction id has to be unique. Do not comment a line that only repeats the code.

Update the note in `docs/` when a change alters a requirement, a status meaning, an API contract, or an architecture decision. If the code and a product rule would diverge, stop and update the decision first.

Review every change before it reaches `main`. Auth, uploads, and identifier storage need a security look in that review.

When the backend exists: route, controller, service, repository, database. Repositories do not authorize users. Services do not format HTTP responses. Do not edit a migration after it has run in a shared environment.
