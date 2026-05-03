#!/usr/bin/env bash
# Validate action.yml and GitLab component template.yml against JSON schemas.
set -euo pipefail

ACTION_SCHEMA="https://json.schemastore.org/github-action.json"
GL_SCHEMA="https://json.schemastore.org/gitlab-ci.json"

fail=0

for f in actions/*/action.yml; do
  [ -f "$f" ] || continue
  echo "==> Validating $f"
  if ! check-jsonschema --schemafile "$ACTION_SCHEMA" "$f"; then
    fail=1
  fi
done

for f in components/*/template.yml; do
  [ -f "$f" ] || continue
  echo "==> Validating $f against GitLab CI schema"
  if ! check-jsonschema --schemafile "$GL_SCHEMA" "$f"; then
    fail=1
  fi
done

exit "$fail"
