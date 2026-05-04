# standard-release (GitHub reusable workflow)

The driftsys default release pipeline as a GitHub Actions reusable workflow. One
adoption line gets you commit-message validation on every PR plus a semver
bump-and-tag on every push to the default branch.

It's a thin preset over the [commitlint](../commitlint/README.md) and
[release](../release/README.md) actions — same defaults, fewer lines of YAML in
your repo.

## Inputs

| Name      | Required | Default                                           | Description                                             |
| --------- | -------- | ------------------------------------------------- | ------------------------------------------------------- |
| `range`   | no       | `${{ github.event.pull_request.base.sha }}..HEAD` | Commit range commitlint validates on PRs.               |
| `remote`  | no       | `origin`                                          | Remote the release job pushes to.                       |
| `dry-run` | no       | `false`                                           | If `true`, the release job bumps + tags but skips push. |

## Example

```yaml
# .github/workflows/ci.yml
name: CI
on:
  pull_request:
  push:
    branches: [main]

jobs:
  release:
    permissions:
      contents: write
    uses: driftsys/ci/.github/workflows/standard-release.yml@v0
```

## Notes

- The caller's job needs `contents: write` so the release job can push the tag.
- The `commitlint` job only runs on `pull_request`; the `release` job only runs
  on `push` to `main`. The reusable workflow gates them internally.
- The actual workflow file lives at `.github/workflows/standard-release.yml`;
  this directory only holds the docs chapter.
