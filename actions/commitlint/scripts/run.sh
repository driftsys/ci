#!/usr/bin/env bash
# Thin wrapper used for local invocation; action.yml calls scripts/commitlint.sh directly.
set -euo pipefail
: "${RANGE:?RANGE is required}"
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../scripts/commitlint.sh" "$RANGE"
