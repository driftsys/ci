# Getting started

`driftsys/ci` ships reusable **GitHub Actions** and **GitLab CI components**
maintained by the driftsys org.

## Use a component (GitHub Actions)

```yaml
# .github/workflows/pr.yml
on: pull_request
jobs:
  commitlint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: driftsys/ci/actions/commitlint@v0
        with:
          range: ${{ github.event.pull_request.base.sha }}..HEAD
```

## Use a component (GitLab CI)

```yaml
# .gitlab-ci.yml
include:
  - component: gitlab.com/driftsys/ci/commitlint@~latest
```

## Versioning

Components follow semver. Pin to `@v0`, `@v0.1.0`, or `@~latest` per your
stability requirements.

## Next steps

- [commitlint](usage/commitlint.md) — commit-message validation.
- [release](usage/release.md) — semver bump, tag, and push.
- [PR validation recipe](recipes/pr-validation.md) — compose them together.
