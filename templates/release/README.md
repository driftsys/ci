# release (GitLab CI component)

Bumps the semver version via [git-std](https://github.com/driftsys/git-std),
commits + tags, then pushes.

This component consumes a [driftsys/dock](https://github.com/driftsys/dock) core
image.

## Inputs

| Name      | Required | Default                             | Description        |
| --------- | -------- | ----------------------------------- | ------------------ |
| `image`   | no       | `ghcr.io/driftsys/dock:core-v0.2.0` | Container image.   |
| `stage`   | no       | `release`                           | Pipeline stage.    |
| `remote`  | no       | `origin`                            | Remote to push to. |
| `dry-run` | no       | `false`                             | Skip push if true. |

## Example

```yaml
include:
  - component: gitlab.com/driftsys/ci/release@~latest
```

## Notes

- The job only runs on the default branch
  (`CI_COMMIT_BRANCH == CI_DEFAULT_BRANCH`).
- The default `stage: release` is **not** a built-in GitLab stage. Either add it
  to your `stages:` list at the root of `.gitlab-ci.yml`, or override the
  `stage` input to one of the built-ins (`test` / `deploy` / `.post`).
- The pipeline runner must have push access to the repository.
- Override `image` to pin to a specific dock release.
