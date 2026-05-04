# standard-release (GitLab CI component)

The driftsys default release pipeline as a GitLab CI component. One include line
gets you commit-message validation on every MR plus a semver bump-and-tag on
every push to the default branch.

It's a thin preset over the [commitlint](../commitlint/README.md) and
[release](../release/README.md) components — same defaults, fewer lines of YAML
in your repo.

## Inputs

| Name      | Required | Default                                 | Description                                             |
| --------- | -------- | --------------------------------------- | ------------------------------------------------------- |
| `range`   | no       | `$CI_MERGE_REQUEST_DIFF_BASE_SHA..HEAD` | Commit range commitlint validates on MRs.               |
| `remote`  | no       | `origin`                                | Remote the release job pushes to.                       |
| `dry-run` | no       | `false`                                 | If `true`, the release job bumps + tags but skips push. |

## Example

```yaml
# .gitlab-ci.yml
include:
  - component: gitlab.com/driftsys/ci/standard-release@~latest
```

## Notes

- The component pins its sub-components (`commitlint`, `release`) at
  `$CI_COMPONENT_REF`, so `standard-release@v0.2.0` reproducibly uses the v0.2.0
  sub-components.
- For finer control over a sub-component, include it directly instead of (or in
  addition to) `standard-release`; the preset only exposes the most common
  subset of inputs.
