# CI

Every proposed change is analyzed automatically. A deployment, when one exists, goes through a controlled path.

```text
Pull request
  -> analyze
  -> security checks
  -> build
  -> staging
  -> check
  -> approval
  -> production
```

## What runs now

`.github/workflows/mobile-ci.yml` runs on pull requests and on pushes to `main`:

1. Check out the repo.
2. Install Flutter 3.47.5.
3. Install mobile dependencies.
4. Run `flutter analyze`.

## Not running

| Step | Why |
| --- | --- |
| Backend lint | No backend |
| Dependency scan | Tool [TBD] |
| Release build | [TBD] |
| Staging deploy | No host |
| Production deploy | No host |

Add a dependency scan when dependencies go past the Flutter SDK, and before the first production release.

A failed analyze blocks the change. Staging comes from a reviewed build, not from a laptop folder. Production is not automatic. It needs the approval in [release-process.md](release-process.md). Do not put secrets in the workflow file. Use the CI secret store.
