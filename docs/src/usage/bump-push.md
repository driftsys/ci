# bump-push

Bumps the semver version via git-std, commits, tags, and pushes.

## GitHub Action

### Inputs

| Name              | Required | Default   | Description                             |
| ----------------- | -------- | --------- | --------------------------------------- |
| `remote`          | no       | `origin`  | Remote to push to.                      |
| `dry-run`         | no       | `false`   | If `true`, bump + tag but skip push.    |
| `git-std-version` | no       | `0.11.12` | git-std release to install.             |

### Example

```yaml
- uses: actions/checkout@v4
  with: { fetch-depth: 0 }
- uses: driftsys/ci/actions/bump-push@v0
  with:
    dry-run: "false"
```

## GitLab CI Component

### Inputs

| Name       | Required | Default                                    | Description                   |
| ---------- | -------- | ------------------------------------------ | ----------------------------- |
| `image`    | no       | `ghcr.io/driftsys/dock:core-v0.2.0`       | Container image.              |
| `stage`    | no       | `release`                                  | Pipeline stage.               |
| `remote`   | no       | `origin`                                   | Remote to push to.            |
| `dry-run`  | no       | `false`                                    | Skip push if true.            |

### Example

```yaml
include:
  - component: gitlab.com/driftsys/ci/bump-push@~latest
    inputs:
      dry-run: false
```
