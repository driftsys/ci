# release-notes

Composite GitHub Action that publishes a GitHub Release with auto-generated
notes for a tag.

It's a thin wrapper around `gh release create --generate-notes`. Useful to run
on tag push so a `git push --follow-tags` (or the
[release](../release/README.md) action) automatically gets a Release page with
changelog notes.

## Inputs

| Name         | Required | Default                  | Description                                                                     |
| ------------ | -------- | ------------------------ | ------------------------------------------------------------------------------- |
| `tag`        | no       | `${{ github.ref_name }}` | Tag to publish a release for. Defaults to the current ref on tag-push events.   |
| `latest`     | no       | `auto`                   | `true` / `false` / `auto`. `auto` lets GitHub decide based on tag semver order. |
| `draft`      | no       | `false`                  | Create the release as a draft.                                                  |
| `prerelease` | no       | `false`                  | Mark the release as a prerelease.                                               |

## Example

```yaml
# .github/workflows/release-notes.yml
on:
  push:
    tags: ["v*.*.*"]

jobs:
  notes:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4
      - uses: driftsys/ci/actions/release-notes@v0
```

## Notes

- The caller's job needs `contents: write` to publish the release.
- Idempotent: if a release for the tag already exists, the step exits
  successfully without modifying it.
- GitHub auto-attaches source `.tar.gz` and `.zip` archives to every release;
  this action does not upload anything additional.
