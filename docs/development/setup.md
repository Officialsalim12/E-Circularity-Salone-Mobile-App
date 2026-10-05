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

The app shows splash → onboarding → sign-in, unless a refresh token is already stored. Auth calls the local API. Continue with Google also needs `GOOGLE_CLIENT_ID` on the API and the same web client id passed to Flutter.

## API

Node.js 20 or newer. The database is the `DATABASE_URL` in `.env`. This project uses a Neon Postgres connection string there. Do not commit that file.

```bash
cp .env.example .env
```

Set `DATABASE_URL`, `BREVO_API_KEY`, and `BREVO_SENDER_EMAIL`. The email sender must already be verified in Brevo. `BREVO_SMS_SENDER` is the approved SMS sender id, 3 to 11 letters or digits. Email works without it. A text is refused until it is set. `GOOGLE_CLIENT_ID` is the web client id. Leave it empty and email and phone auth still work. Google sign-in answers that it isn't set up until the id is there. Then:

```bash
cd backend
npm install
npm run dev
```

`npm run dev` runs the auth migration and listens on port 3000. Signup and password reset send a 6-digit code by email or text, then a short welcome on the same channel once the account exists. The API never returns that code or writes it to the log.

`backend/docker-compose.yml` is only for a local Postgres, if you point `DATABASE_URL` at it instead of Neon. Local Postgres does not use `sslmode=require`.

The phone does not read `.env`. Pass the API address when you run the app. The Android emulator reaches the host machine at `10.0.2.2`. The iOS simulator and Chrome use `127.0.0.1`. A physical phone needs this computer's LAN address instead of either of those. A debug Android build allows the local `http` address. A release build does not.

```bash
cd frontend/mobile
flutter pub get
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:3000 --dart-define=GOOGLE_CLIENT_ID=<web client id>
```

Copy `.env.example` to `.env` for the API process. Do not commit `.env`.

Environment names are in [../deployment/environments.md](../deployment/environments.md). The package name is `circular_salone`. The display name is Circular Salone. Platform detail is in [../architecture/mobile-app.md](../architecture/mobile-app.md).

What the account work covers is in [accounts.md](accounts.md). Device, collection, and lifecycle modules are not in the repo yet. Add them when the related item in [../product/open-decisions.md](../product/open-decisions.md) is closed.
