# Setup

These steps run the Android shell. There is no backend.

| Tool | Version for this shell |
| --- | --- |
| Flutter | 3.47.5, stable |
| Dart | 3.13.4, bundled with that Flutter |

You need the Android SDK to build. `flutter analyze` does not need a phone.

From the repo root:

```bash
cd frontend/mobile
flutter pub get
flutter analyze
```

To run it, connect a device or start an emulator:

```bash
cd frontend/mobile
flutter run
```

The app opens and shows "Circular Salone". No login. No sample data.

Copy `.env.example` to `.env` only when you have a local API URL. The API is not deployed. Do not commit `.env`.

Environment names are in [../deployment/environments.md](../deployment/environments.md). The package name is `circular_salone`. The display name is Circular Salone. Platform detail is in [../architecture/mobile-app.md](../architecture/mobile-app.md).

Not in the repo yet: a backend, a database, feature screens, third-party keys. Add them when the related item in [../product/open-decisions.md](../product/open-decisions.md) is closed.
