# release-notes (GitLab CI component)

Publishes a GitLab Release for a tag, with notes composed from commits since the
previous tag.

The component uses [`release-cli`](https://gitlab.com/gitlab-org/release-cli)
under the hood. Unlike GitHub's `--generate-notes`, GitLab has no native
auto-notes feature, so this component composes a simple bullet list of commit
subjects between the previous tag and the current tag.

## Inputs

| Name    | Required | Default                                             | Description                               |
| ------- | -------- | --------------------------------------------------- | ----------------------------------------- |
| `image` | no       | `registry.gitlab.com/gitlab-org/release-cli:latest` | Container image with `release-cli` + git. |
| `stage` | no       | `release`                                           | Pipeline stage for the release-notes job. |

## Example

```yaml
# .gitlab-ci.yml
include:
  - component: gitlab.com/driftsys/ci/release-notes@~latest
```

## Notes

- The job only runs on tag pipelines (`$CI_COMMIT_TAG` is set).
- Notes are composed from `git log --pretty='- %s' PREV..TAG`. If no previous
  tag exists, the full history up to the tag is used.
- This component intentionally uses the upstream `release-cli` image rather than
  a `driftsys/dock` image, since the dock catalogue doesn't ship `release-cli`
  today.
- The pipeline must be able to fetch full history (`GIT_DEPTH: 0`) so
  `git describe` can find the previous tag.
