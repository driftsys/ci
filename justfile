# Default: show the recipe list.
[private]
default:
    @just --list

# Format markdown/json/yaml/toml (dprint) and shell scripts (shfmt).
fmt:
    dprint fmt
    shfmt -w -i 2 -ci -sr scripts/ tests/ actions/*/scripts/ bootstrap 2>/dev/null || true

# Lint: dprint check, markdownlint, shellcheck, shfmt diff, schema validation.
lint:
    dprint check
    npx --yes markdownlint-cli2 "**/*.md" "#node_modules" "#_site" "#docs/superpowers"
    shellcheck scripts/*.sh tests/*.sh actions/*/scripts/*.sh bootstrap
    shfmt -d -i 2 -ci -sr scripts/ tests/ actions/*/scripts/ bootstrap
    just _schema-check

# Apply formatter and auto-fix markdown lint issues.
lint-fix:
    just fmt
    npx --yes markdownlint-cli2 --fix "**/*.md" "#node_modules" "#_site" "#docs/superpowers"

# Validate action.yml and GitLab component templates against their schemas.
[private]
_schema-check:
    bash scripts/schema-check.sh

# Run bash_unit test suites in tests/.
test:
    bash tools/bash_unit tests/*_test.sh

# Run tests then lint.
check: test lint

# Render the mdBook to _site/.
assemble:
    mdbook build docs

# Full build: check then assemble.
build: check assemble

# Pre-push gate: validate commits on branch and run a full build.
verify:
    git std lint --range main..HEAD
    just build

# Bump version, update changelog, commit, and tag (per git-std).
release:
    git std bump

# Remove build artifacts.
clean:
    rm -rf _site target node_modules .dprint
