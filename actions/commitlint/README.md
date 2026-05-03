# commitlint

Composite GitHub Action that validates Conventional Commits in a git range
using [git-std](https://github.com/driftsys/git-std).

## Inputs

| Name              | Required | Default   | Description                              |
| ----------------- | -------- | --------- | ---------------------------------------- |
| `range`           | yes      | —         | Range to validate (e.g. `main..HEAD`).   |
| `git-std-version` | no       | `0.11.12` | git-std release to install.              |

## Example

```yaml
- uses: actions/checkout@v4
  with: { fetch-depth: 0 }
- uses: driftsys/ci/actions/commitlint@v0
  with:
    range: ${{ github.event.pull_request.base.sha }}..HEAD
```

## Notes

- Requires `fetch-depth: 0` on the checkout step so the full commit history
  is available.
- Validation uses git-std's Conventional Commits rules. See
  [git-std docs](https://driftsys.github.io/git-std) for the rule set.
