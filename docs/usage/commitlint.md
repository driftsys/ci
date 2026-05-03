# commitlint

Validates Conventional Commit messages in a git range using
[git-std](https://github.com/driftsys/git-std).

## GitHub Action

### Inputs

| Name              | Required | Default   | Description                                |
| ----------------- | -------- | --------- | ------------------------------------------ |
| `range`           | yes      | —         | Git range to validate (e.g. `main..HEAD`). |
| `git-std-version` | no       | `0.11.12` | git-std release to install.                |

### Example

Canonical (smallest usable form on a PR — `range` has no default; see the
per-event table below):

```yaml
- uses: actions/checkout@v4
  with: { fetch-depth: 0 }
- uses: driftsys/ci/actions/commitlint@v0
  with:
    range: ${{ github.event.pull_request.base.sha }}..HEAD
```

### Picking a `range` for each event

GitHub does not expose a single "compare-against" variable, so the right value
for `range` depends on the workflow trigger.

| Event              | Recommended `range`                                       | Notes                                                                                |
| ------------------ | --------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `pull_request`     | `${{ github.event.pull_request.base.sha }}..HEAD`         | Lints commits introduced by the PR. Requires `fetch-depth: 0`.                       |
| `merge_group`      | `${{ github.event.merge_group.base_sha }}..HEAD`          | Same idea for GitHub merge queues.                                                   |
| `push` to a branch | `${{ github.event.before }}..${{ github.sha }}`           | Lints commits in this push. **Fails** on the first push to a new branch (see below). |
| `workflow_dispatch` / `schedule` | `<last-tag>..HEAD` (e.g. `$(git describe --tags --abbrev=0)..HEAD`) | No event SHA is available; pass an explicit anchor.                                  |

#### Edge cases on `push`

- **First push to a new branch.** `github.event.before` is
  `0000000000000000000000000000000000000000`, so `before..HEAD` is invalid.
  Either guard the step
  (`if: github.event.before != '0000000000000000000000000000000000000000'`) or
  fall back to `<base-branch>..HEAD`.
- **Force-push.** `github.event.before` points at the pre-push tip, which may
  no longer be reachable from the new HEAD. Lint will report `invalid range`.
  Either skip the step on force-push or always lint against the base branch.
- **Merge commits in the range.** GitHub's auto-generated `Merge {sha} into
  {sha}` commits on `refs/pull/N/merge` are *not* recognised as process commits
  by git-std. Avoid this by checking out the PR head ref directly
  (`with: { ref: ${{ github.head_ref }} }`) so HEAD is the PR tip, not the
  synthetic merge.

## GitLab CI Component

### Inputs

| Name    | Required | Default                                 | Description                   |
| ------- | -------- | --------------------------------------- | ----------------------------- |
| `range` | no       | `$CI_MERGE_REQUEST_DIFF_BASE_SHA..HEAD` | Git range to validate.        |
| `image` | no       | `ghcr.io/driftsys/dock:lint-v0.2.0`     | Container image with git-std. |
| `stage` | no       | `test`                                  | Pipeline stage.               |

### Example

Canonical (all defaults):

```yaml
include:
  - component: gitlab.com/driftsys/ci/commitlint@~latest
```

Lint against a specific anchor:

```yaml
include:
  - component: gitlab.com/driftsys/ci/commitlint@~latest
    inputs:
      range: v0.1.0..HEAD
```
