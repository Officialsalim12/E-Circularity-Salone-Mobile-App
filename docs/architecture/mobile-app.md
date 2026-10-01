# Mobile app

Flutter app in `frontend/mobile`. Android only. It starts and shows the product name. It does not sign anyone in, store a device, or call an API.

The app draws the screens, captures field input, shows assignments that are already on the phone, keeps a local queue, and calls the API when a connection exists.

It does not decide the official lifecycle transition, calculate official points, or act as the only copy of a collected device. Hiding a button is not access control.

## Layout

```text
frontend/mobile/lib/
├── main.dart
├── app/
│   └── app.dart
├── core/
│   ├── networking/
│   ├── storage/
│   ├── authentication/
│   ├── synchronization/
│   ├── permissions/
│   └── utilities/
└── features/
    ├── authentication/
    ├── users/
    ├── devices/
    ├── collections/
    ├── assessments/
    ├── agents/
    ├── notifications/
    └── profile/
```

Each feature has three layers:

| Layer | Put here |
| --- | --- |
| `presentation` | Screens and widgets |
| `domain` | Use cases local to the app flow |
| `data` | API and local storage for that feature |

`presentation` does not hold official business rules. `domain` does not call HTTP or the database. `data` does not build widgets.

`core/authentication` is for session or token storage and the authenticated client, when those exist. `features/authentication` is the sign-in screen. Neither is built.

Repair, refurbishment, recycling, registry, points, households, and partners are required product modules. They have no Flutter folders yet because we have not decided if those roles use this app. When that is decided, add a feature folder with the same three layers.

`main.dart` only starts `CircularSaloneApp`. Theme, navigation, and startup checks go on that widget later. Do not hang product screens off `main.dart`.

## Packages

The app depends on the Flutter SDK. Do not add a package for state, HTTP, a local database, maps, or the camera until the feature needs it, and write down why in the change.

Still open: HTTP client, on-device database, secure token storage, camera and barcode scanning, maps and location, state management.

## Identity

| | |
| --- | --- |
| Dart package | `circular_salone` |
| Android organization | `sl.circularsalone` |
| Android namespace | `sl.circularsalone.circular_salone` |
| Display name | Circular Salone |
| Platform | Android |

iOS, web, and desktop are not enabled. Add one only after a product decision.

## Permissions

No camera, photo, location, or storage permission is declared. Add one with the feature that uses it, and tell the user why in plain language.

## Slow connections

Send the fields the action needs. Prefer text and smaller photos. Do not block an agent on a live map when the assignment is already on the phone. Keep the queue small enough to sync on a weak connection. Numeric budgets are [TBD].

## Roles in the client

Until C-03 is settled, do not build a permission matrix in the app. The server remains the check. `core/permissions` is reserved for caching grants the server already gave, so the UI can hide irrelevant actions. The cache is a convenience.
