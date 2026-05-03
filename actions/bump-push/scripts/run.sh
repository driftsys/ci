#!/usr/bin/env bash
# Thin wrapper for local invocation; action.yml calls scripts/bump-push.sh directly.
set -euo pipefail
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../scripts/bump-push.sh"
