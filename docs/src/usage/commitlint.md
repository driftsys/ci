# commitlint

Validates Conventional Commit messages in a git range using
[git-std](https://github.com/driftsys/git-std).

## GitHub Action

### Inputs

| Name              | Required | Default   | Description                                |
| ----------------- | -------- | --------- | ------------------------------------------ |
| `range`           | yes      | —         | Git range to validate (e.g. `main..HEAD`). |
| `git-std-version` | no       | `0.11.12` | git-std release to install.                |

### Example

```yaml
- uses: actions/checkout@v4
  with: { fetch-depth: 0 }
- uses: driftsys/ci/actions/commitlint@v0
  with:
    range: ${{ github.event.pull_request.base.sha }}..HEAD
```

## GitLab CI Component

### Inputs

| Name    | Required | Default                                 | Description                   |
| ------- | -------- | --------------------------------------- | ----------------------------- |
| `range` | no       | `$CI_MERGE_REQUEST_DIFF_BASE_SHA..HEAD` | Git range to validate.        |
| `image` | no       | `ghcr.io/driftsys/dock:lint-v0.2.0`     | Container image with git-std. |
| `stage` | no       | `test`                                  | Pipeline stage.               |

### Example

```yaml
include:
  - component: gitlab.com/driftsys/ci/commitlint@~latest
    inputs:
      range: $CI_MERGE_REQUEST_DIFF_BASE_SHA..HEAD
```
