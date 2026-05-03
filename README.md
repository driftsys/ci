# driftsys/ci

Reusable **GitHub Actions** and **GitLab CI components** for the driftsys org.

Canonical repo: <https://github.com/driftsys/ci>. Mirrored to GitLab so GitLab
components can be exercised on real pipelines.

## Components

| Name       | GH Action                        | GitLab Component         |
| ---------- | -------------------------------- | ------------------------ |
| commitlint | `driftsys/ci/actions/commitlint` | `driftsys/ci/commitlint` |
| release    | `driftsys/ci/actions/release`    | `driftsys/ci/release`    |

## Quick example

GitHub Actions (PR validation):

```yaml
- uses: actions/checkout@v4
  with: { fetch-depth: 0 }
- uses: driftsys/ci/actions/commitlint@v0
  with:
    range: ${{ github.event.pull_request.base.sha }}..HEAD
```

GitLab CI (merge-request validation):

```yaml
include:
  - component: gitlab.com/driftsys/ci/commitlint@~latest
```

See the per-component pages for inputs and edge cases.

## Versioning

Components follow semver. Pin to `@v0`, `@v0.1.0`, or `@~latest` per your
stability requirements.

## Local development

```sh
chmod +x bootstrap && ./bootstrap  # install git-std + hooks (first clone only)
just --list                         # see available recipes
just verify                         # run before PR (also enforced by pre-push hook)
```

## License

MIT — see [LICENSE](LICENSE).
