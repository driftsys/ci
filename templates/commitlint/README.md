# commitlint (GitLab CI component)

Validates Conventional Commits in a merge request using
[git-std](https://github.com/driftsys/git-std).

This component consumes a [driftsys/dock](https://github.com/driftsys/dock)
image which ships git-std preinstalled.

## Inputs

| Name    | Required | Default                                 | Description                   |
| ------- | -------- | --------------------------------------- | ----------------------------- |
| `range` | no       | `$CI_MERGE_REQUEST_DIFF_BASE_SHA..HEAD` | Git range to validate.        |
| `image` | no       | `ghcr.io/driftsys/dock:lint-v0.2.0`     | Container image with git-std. |
| `stage` | no       | `test`                                  | Pipeline stage.               |

## Example

```yaml
include:
  - component: gitlab.com/driftsys/ci/commitlint@~latest
```

## Notes

- The job only runs on merge request pipelines
  (`CI_PIPELINE_SOURCE == "merge_request_event"`).
- `GIT_DEPTH: 0` is required to access full commit history.
- Override `image` to pin to a specific dock release for reproducibility.
