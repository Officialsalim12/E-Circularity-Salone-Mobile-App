# Mobile app

Flutter app in `frontend/mobile`. **Android** is the pilot target; **iOS** is enabled for development and device testing (same UI). On launch it shows a branded splash screen, then onboarding, unless a refresh token is already stored. A stored session opens the signed-in screen. Auth calls the API. The app does not store a device.

The app draws the screens, captures field input, shows assignments that are already on the phone, keeps a local queue, and calls the API when a connection exists.

It does not decide the official lifecycle transition, calculate official points, or act as the only copy of a collected device. Hiding a button is not access control.

## Layout

```text
frontend/mobile/lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── app_colors.dart
├── core/
│   ├── networking/
│   ├── storage/
│   ├── authentication/
│   ├── synchronization/
│   ├── permissions/
│   └── utilities/
└── features/
    ├── authentication/
    ├── onboarding/
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

`core/authentication` stores the access token and refresh token in `flutter_secure_storage` (Android Keystore, iOS Keychain). `core/networking` is the HTTP client. `features/authentication/data` calls the auth API. `features/authentication/presentation` holds the launch splash (`SplashScreen`), login UI (`SignInScreen`), signup UI (`CreateAccountScreen`), email confirmation (`ConfirmAccountScreen`), phone verification (`VerifyPhoneNumberScreen`), password recovery (`ForgotPasswordScreen`, `ResetCodeScreen`, `NewPasswordScreen`, `PasswordChangedScreen`), and the signed-in screen (`SignedInScreen`). There is no domain layer for auth: the screens call the repository, and the server owns the rules. Continue with Google uses `google_sign_in` so the phone can open the Google account sheet and hand the API an ID token. That package is here because the button has to talk to Google. The web client id comes from `--dart-define=GOOGLE_CLIENT_ID=...`, the same way the API address comes from `--dart-define=API_BASE_URL=...`. Neither value is hard-coded in Dart.

Type, spacing, and the picture under the form come from `app/responsive_layout.dart`. Forms scroll. The picture hides while the keyboard is open, so the field you tapped stays focused. Onboarding scrolls on a short screen.

`features/onboarding/presentation` holds onboarding screens (`OnboardingScreenOne`, `OnboardingScreenTwo`, `OnboardingScreenThree`) and shared onboarding widgets (content layout, progress dots, primary and skip buttons). Screen 3 completes onboarding with **Get Started** or **Skip**, then `Navigator.pushAndRemoveUntil` to `SignInScreen`.

Startup uses `MaterialApp` with `home: SplashScreen`. After the loading animation, a saved session opens `SignedInScreen`. Otherwise `SplashScreen` replaces itself with `OnboardingScreenOne`. Onboarding pages advance with `Navigator.push`. No separate routing package. Sign-in calls the API and opens `SignedInScreen`. Create account with email or phone opens `SignInScreen` and does not start a session. Continue with Google on either screen opens `SignedInScreen`. A new Google email is registered from the sign-in screen as well. On create account, that button stays off until the terms box is ticked. Closing the Google sheet does not show an error.

Repair, refurbishment, recycling, registry, points, device owners, and partners are required product modules. They have no Flutter folders yet because we have not decided if those roles use this app. When that is decided, add a feature folder with the same three layers.

`main.dart` only starts `CircularSaloneApp` and sets a transparent status bar with light icons. Theme and the initial route live on `CircularSaloneApp` in `app/app.dart`. Do not hang product screens off `main.dart`.

## Packages

The app depends on the Flutter SDK, `http` (the auth API), `flutter_secure_storage` (access and refresh tokens), and `google_sign_in` (the Google account sheet). Do not add a package for state, a local database, maps, or the camera until the feature needs it, and write down why in the change.

Still open: on-device database, camera and barcode scanning, maps and location, state management.

## Identity

| | |
| --- | --- |
| Dart package | `circular_salone` |
| Android organization | `sl.circularsalone` |
| Android namespace | `sl.circularsalone.circular_salone` |
| Display name | Circular Salone |
| Platform | Android (pilot); iOS (dev builds) |

Web and desktop are not product targets. Web may be used locally for quick UI checks; use Android or iOS emulators/devices for reliable rendering. Add other platforms only after a product decision.

## Permissions

No camera, photo, location, or storage permission is declared. Add one with the feature that uses it, and tell the user why in plain language.

## Slow connections

Send the fields the action needs. Prefer text and smaller photos. Do not block an agent on a live map when the assignment is already on the phone. Keep the queue small enough to sync on a weak connection. Numeric budgets are [TBD].

## Roles in the client

Until C-03 is settled, do not build a permission matrix in the app. The server remains the check. `core/permissions` is reserved for caching grants the server already gave, so the UI can hide irrelevant actions. The cache is a convenience.
