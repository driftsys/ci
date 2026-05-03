# PR validation recipe

A complete PR validation pipeline combining commitlint with your existing test
steps.

## GitHub Actions

```yaml
# .github/workflows/pr.yml
name: PR validation
on: pull_request

jobs:
  commitlint:
    name: Lint commits
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: driftsys/ci/actions/commitlint@v0
        with:
          range: ${{ github.event.pull_request.base.sha }}..HEAD

  test:
    name: Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: just test
```

## Release workflow

Pair `release` with a release job that runs only on the default branch:

```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: driftsys/ci/actions/release@v0
```

## GitLab CI

```yaml
# .gitlab-ci.yml
include:
  - component: gitlab.com/driftsys/ci/commitlint@~latest
  - component: gitlab.com/driftsys/ci/release@~latest
    inputs:
      dry-run: false
```
