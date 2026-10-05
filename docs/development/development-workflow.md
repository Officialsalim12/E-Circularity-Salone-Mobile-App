# Development workflow

Product says what the platform does. Engineering says how it is built. Operations says how field and partner work runs. Impact says how results are counted. A pull request that needs a new business rule should link the decision. Do not hide the rule in code.

`main` is protected by review and by the mobile analyze check.

```text
feature/<short-name>
fix/<short-name>
docs/<short-name>
chore/<short-name>
```

The product plan already names `feature/device-registration`, `feature/collection-management`, `feature/offline-sync`, `feature/device-assessment`, and `feature/admin-dashboard`.

Do not commit straight to `main` once more than one person is in the repo. Do not force-push a shared branch.

Follow [../product/roadmap.md](../product/roadmap.md). Do not start points redemption, payments, or other channels ahead of the registry, collection, and offline sync.

Close C-01 through C-04 before coding the transitions, roles, or assessment records they affect. Close C-06 before adding a collector or parts-recovery account.

Write the commit the way you'd tell a teammate what you fixed. "Keep the email field focused when the keyboard opens" is better than "Update auth form viewport".

A pull request should say what changed and why, which requirement it covers, how you tried it, and what's still unfinished. Add a screenshot if the screen changed. If stored rows change, say what happens to the ones already there.

Reviewers check that the change matches a written requirement, does not invent a [TBD] rule, handles errors and authorization on the new path, updates the docs when behavior or structure changed, and contains no secrets or personal data.

A feature is done when the requirement and the acceptance checks are met, validation and error handling exist, the security impact has been looked at, the docs match, review is done, CI is green, it works in the target environment, and the offline cases have been tried when the feature is used in the field.

Merging to `main` does not deploy production. Production follows [../deployment/release-process.md](../deployment/release-process.md).
