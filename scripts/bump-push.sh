#!/usr/bin/env bash
# Bump semver version via git-std, commit + tag, then push.
# Env vars:
#   REMOTE   remote to push to (default: origin)
#   DRY_RUN  set to 1 to skip the push step
set -euo pipefail

REMOTE="${REMOTE:-origin}"
DRY_RUN="${DRY_RUN:-0}"

git std bump

if [ "$DRY_RUN" = "1" ]; then
  echo "::notice::DRY_RUN=1 — skipping push"
  exit 0
fi

git push "$REMOTE" HEAD --follow-tags
