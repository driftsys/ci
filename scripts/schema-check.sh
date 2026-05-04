#!/usr/bin/env bash
# Validate action.yml and GitLab component template.yml against JSON schemas.
set -euo pipefail

ACTION_SCHEMA="https://json.schemastore.org/github-action.json"
GL_SCHEMA="https://gitlab.com/gitlab-org/gitlab-foss/-/raw/master/app/assets/javascripts/editor/schema/ci.json"

fail=0

for f in actions/*/action.yml; do
  [ -f "$f" ] || continue
  echo "==> Validating $f"
  if ! check-jsonschema --schemafile "$ACTION_SCHEMA" "$f"; then
    fail=1
  fi
done

# GitLab components use a two-document YAML: a `spec:` header followed by
# the job definition. check-jsonschema can't parse multi-document YAML, so
# we split on the `---` separator and validate only the job-definition doc
# against the GitLab CI schema. We write to a temp dir under a `.yml` name
# so check-jsonschema picks up the YAML filetype (BSD mktemp on macOS
# doesn't accept --suffix, so use a temp dir + fixed filename).
for f in templates/*/template.yml; do
  [ -f "$f" ] || continue
  echo "==> Validating $f against GitLab CI schema (job document)"
  tmpdir=$(mktemp -d)
  tmp="$tmpdir/job.yml"
  awk 'sep { print } /^---[[:space:]]*$/ { sep = 1 }' "$f" > "$tmp"
  if [ ! -s "$tmp" ]; then
    echo "warning: $f has no second YAML document; skipping" >&2
    rm -rf "$tmpdir"
    continue
  fi
  if ! check-jsonschema --schemafile "$GL_SCHEMA" "$tmp"; then
    fail=1
  fi
  rm -rf "$tmpdir"
done

exit "$fail"
