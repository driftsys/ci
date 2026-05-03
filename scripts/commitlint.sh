#!/usr/bin/env bash
# Validate commit messages in a range or a single file using git-std lint.
# Usage:
#   commitlint.sh <git-range>       e.g. main..HEAD
#   commitlint.sh --file <path>     validate one message file (used by commit-msg hook)
set -euo pipefail

usage() {
  cat << 'EOF'
Usage:
  commitlint.sh <git-range>        validate all commits in range
  commitlint.sh --file <msg-file>  validate a single message file
EOF
}

if [ "$#" -lt 1 ]; then
  usage >&2
  exit 2
fi

if [ "$1" = "--file" ]; then
  [ "$#" -eq 2 ] || {
    usage >&2
    exit 2
  }
  exec git std lint --file "$2"
fi

exec git std lint --range "$1"
