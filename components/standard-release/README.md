# standard-release

The driftsys default release pipeline. One adoption line gets you commit-message
validation on every PR / MR plus a semver bump-and-tag on every push to the
default branch.

It's a thin bundle over the [`commitlint`](../commitlint/README.md) and
[`release`](../release/README.md) components — same defaults, same behaviour,
fewer lines of YAML in your repo.

## GitHub Actions (reusable workflow)

### Inputs

| Name      | Required | Default                                              | Description                                                |
| --------- | -------- | ---------------------------------------------------- | ---------------------------------------------------------- |
| `range`   | no       | `${{ github.event.pull_request.base.sha }}..HEAD`    | Commit range commitlint validates on PRs.                  |
| `remote`  | no       | `origin`                                             | Remote the release job pushes to.                          |
| `dry-run` | no       | `false`                                              | If `true`, the release job bumps + tags but skips push.    |

### Example

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

### Notes

- The caller's job needs `contents: write` so the release job can push the tag.
- The `commitlint` job only runs on `pull_request`; the `release` job only runs
  on `push` to `main`. The reusable workflow gates them internally.

## GitLab CI (component)

### Inputs

| Name      | Required | Default                                 | Description                                              |
| --------- | -------- | --------------------------------------- | -------------------------------------------------------- |
| `range`   | no       | `$CI_MERGE_REQUEST_DIFF_BASE_SHA..HEAD` | Commit range commitlint validates on MRs.               |
| `remote`  | no       | `origin`                                | Remote the release job pushes to.                        |
| `dry-run` | no       | `false`                                 | If `true`, the release job bumps + tags but skips push.  |

### Example

```yaml
# .gitlab-ci.yml
include:
  - component: gitlab.com/driftsys/ci/standard-release@~latest
```

### Notes

- The component pins its sub-components (`commitlint`, `release`) at
  `$CI_COMPONENT_REF`, so `standard-release@v0.2.0` reproducibly uses the
  v0.2.0 sub-components.
- For finer control over a sub-component, include it directly instead of (or in
  addition to) `standard-release`; the standard pack only exposes the most
  common subset of inputs.
