# driftsys/ci

[![ci](https://img.shields.io/github/actions/workflow/status/driftsys/ci/ci.yml?branch=main&label=ci)](https://github.com/driftsys/ci/actions/workflows/ci.yml)
[![latest](https://img.shields.io/github/v/tag/driftsys/ci?label=latest)](https://github.com/driftsys/ci/tags)
[![docs](https://img.shields.io/badge/docs-driftsys.github.io%2Fci-blue)](https://driftsys.github.io/ci/)

Reusable **GitHub Actions** and **GitLab CI components** for the driftsys org.

Canonical repo: <https://github.com/driftsys/ci>. Mirrored to GitLab so GitLab
components can be exercised on real pipelines.

## Components

| Name       | GH Action                        | GitLab Component         |
| ---------- | -------------------------------- | ------------------------ |
| commitlint | `driftsys/ci/actions/commitlint` | `driftsys/ci/commitlint` |
| release    | `driftsys/ci/actions/release`    | `driftsys/ci/release`    |

## Bundled pipelines

| Name             | GH (reusable workflow)                               | GitLab Component               |
| ---------------- | ---------------------------------------------------- | ------------------------------ |
| standard-release | `driftsys/ci/.github/workflows/standard-release.yml` | `driftsys/ci/standard-release` |

## Quick example

The lazy default — commitlint on PRs + release on main, one line:

```yaml
# .github/workflows/ci.yml
on: [pull_request, push]
jobs:
  release:
    permissions: { contents: write }
    uses: driftsys/ci/.github/workflows/standard-release.yml@v0
```

```yaml
# .gitlab-ci.yml
include:
  - component: gitlab.com/driftsys/ci/standard-release@~latest
```

Individual components are documented per platform; see the per-component pages
for inputs and edge cases.

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
