# Setup

These steps run the mobile app on **Android** or **iOS**. There is no backend. Prefer native devices or emulators over web to avoid Flutter web shader/GPU issues in embedded browsers.

| Tool | Version for this shell |
| --- | --- |
| Flutter | 3.47.5, stable |
| Dart | 3.13.4, bundled with that Flutter |

You need the Android SDK for Android builds and **Xcode** for iOS builds. `flutter analyze` does not need a phone.

From the repo root:

```bash
cd frontend/mobile
flutter pub get
flutter analyze
```

### Android

Start an emulator (or connect a device), then run:

```bash
cd frontend/mobile
flutter emulators --launch Medium_Phone_API_36.1   # once, if nothing is running
flutter run -d android
```

Or use the helper script (starts an AVD if needed):

```bash
cd frontend/mobile
./scripts/run-android.sh
```

### iOS

Simulator:

```bash
cd frontend/mobile
flutter emulators --launch apple_ios_simulator
flutter run -d ios
```

Or:

```bash
cd frontend/mobile
./scripts/run-ios.sh
```

Physical iPhone: unlock the phone, enable **Developer Mode**, trust this Mac (USB is most reliable on first setup), then:

```bash
cd frontend/mobile
flutter devices          # note the device id
flutter run -d <device-id>
```

In VS Code / Cursor, use **Run and Debug** → *Circular Salone (Android)*, *Circular Salone (iOS Simulator)*, or *Circular Salone (iPhone — This PC's iPhone)*.

The app shows splash → onboarding → sign-in UI. Auth is not wired to a server yet.

Copy `.env.example` to `.env` only when you have a local API URL. The API is not deployed. Do not commit `.env`.

Environment names are in [../deployment/environments.md](../deployment/environments.md). The package name is `circular_salone`. The display name is Circular Salone. Platform detail is in [../architecture/mobile-app.md](../architecture/mobile-app.md).

Not in the repo yet: a backend, a database, feature screens, third-party keys. Add them when the related item in [../product/open-decisions.md](../product/open-decisions.md) is closed.
