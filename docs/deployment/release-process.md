# Releases

No production release yet. Use this when the first pilot build is ready.

The app version is `1.0.0+1` in `frontend/mobile/pubspec.yaml`. `1.0.0` is the version people see. The number after `+` is the build number. Raise it when you ship a pilot build, and note the change in `CHANGELOG.md`.

The API starts at `/api/v1/`.

## Path

1. The change meets the definition of done.
2. CI passes.
3. The build goes to staging.
4. Staging covers the acceptance checks the release touches, including an offline agent case when field behavior changed.
5. Open clashes that affect the release are either closed or listed as limits operations has accepted.
6. A named person approves production. That role is [TBD].
7. Production config and secrets are confirmed.
8. The build is deployed.
9. The core journey is checked in production with a test device, not with a device owner who did not agree to be the test.
10. The changelog is updated.

How the Android build reaches phones is [TBD]. Play Store, or a direct install file. Store accounts are not part of this repo.

A field build needs a version ops can read back, so support knows what is on the phone.

How to roll back depends on the host, which is [TBD]. Before the first production deploy, write down how to return to the previous version. Database changes need a forward fix or a reviewed down migration. Deleting pilot data is not a rollback.

A release can ship with a documented [TBD] that does not affect the journey being piloted. It cannot ship a quiet interpretation of C-01 through C-04.
