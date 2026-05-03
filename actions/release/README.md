# release

Composite GitHub Action that bumps the semver version via
[git-std](https://github.com/driftsys/git-std), commits + tags the release, then
pushes.

## Inputs

| Name              | Required | Default   | Description                          |
| ----------------- | -------- | --------- | ------------------------------------ |
| `remote`          | no       | `origin`  | Remote to push to.                   |
| `dry-run`         | no       | `false`   | If `true`, bump + tag but skip push. |
| `git-std-version` | no       | `0.11.12` | git-std release to install.          |

## Example

Canonical (all defaults):

```yaml
- uses: actions/checkout@v4
  with: { fetch-depth: 0 }
- uses: driftsys/ci/actions/release@v0
```

## More examples

Dry-run (skip push, useful for verifying the bump locally or in PR smoke):

```yaml
- uses: driftsys/ci/actions/release@v0
  with:
    dry-run: "true"
```

## Notes

- Requires a git identity (`user.email`, `user.name`) to be configured before
  this step runs.
- The calling workflow needs `contents: write` permission to push the tag.
