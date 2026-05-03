#!/usr/bin/env bash
# Extract `script:` lines from each GitLab component template and run
# shellcheck against them.
#
# Convention: GL component templates must pipe `$[[ inputs.x ]]` through the
# `variables:` block; `script:` bodies use plain bash variables only. That
# keeps script bodies parseable by shellcheck.
set -euo pipefail

fail=0
for f in components/*/template.yml; do
  [ -f "$f" ] || continue
  shell=$(yq eval-all \
    'select(documentIndex == 1) | .. | select(has("script")) | .script[]' "$f")
  if [ -z "$shell" ]; then
    echo "$f: no script lines (skipping)"
    continue
  fi
  echo "==> shellcheck script lines in $f"
  if ! printf '#!/usr/bin/env bash\nset -e\n%s\n' "$shell" \
    | shellcheck -s bash -; then
    fail=1
  fi
done
exit "$fail"
