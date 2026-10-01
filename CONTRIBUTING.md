# Contributing

Read the product note for the area you are changing before you write code.

1. Check [docs/product/requirements.md](docs/product/requirements.md).
2. Check [docs/product/open-decisions.md](docs/product/open-decisions.md) and the open clashes in the requirements note.
3. Leave anything marked [TBD], and leave C-01 through C-06 alone, until someone writes the decision down.
4. If the work shows a requirement is wrong, update the docs in the same change.

## Branches

`main` is the integration branch.

```text
feature/device-registration
fix/collection-status
docs/lifecycle-notes
chore/android-gradle
```

## Pull requests

Say what changed and why, which requirement it covers, how you checked it, and what you left unfinished. Add a screenshot when the screen changes. If stored data changes, say how existing rows are handled.

## Done means

The requirement is in the build, the acceptance check passes, bad input is rejected, and the failure is handled. Someone has looked at the security impact. The docs match the behavior. Review is done. CI is green. It works in the environment it is meant for. If an agent uses it in the field, the offline cases have been tried.

## What kind of decision this is

Keep these apart:

- Product: what the platform does
- Technical: how we build it
- Operational: how collection, repair, refurbishment, and recycling run on the ground
- Impact: how we count and report results

Points rules, ownership transfer, pricing, and public impact claims are product or operations calls. Do not settle them inside a pull request.

## More

- [docs/development/development-workflow.md](docs/development/development-workflow.md)
- [docs/development/coding-guidelines.md](docs/development/coding-guidelines.md)
