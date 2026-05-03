# Default: show the recipe list.
[private]
default:
    @just --list

# Format markdown/json/yaml/toml (dprint) and shell scripts (shfmt).
fmt:
    dprint fmt
    shfmt -w -i 2 -ci -sr scripts/ bootstrap 2>/dev/null || true

# Lint: dprint check, markdownlint, shellcheck, shfmt diff, actionlint, schema validation.
lint:
    dprint check
    npx --yes markdownlint-cli2 "**/*.md" "#node_modules" "#_site" "#docs/superpowers"
    shellcheck scripts/*.sh bootstrap
    shfmt -d -i 2 -ci -sr scripts/ bootstrap
    actionlint
    just _schema-check

# Apply formatter and auto-fix markdown lint issues.
lint-fix:
    just fmt
    npx --yes markdownlint-cli2 --fix "**/*.md" "#node_modules" "#_site" "#docs/superpowers"

# Validate action.yml and GitLab component templates against their schemas.
[private]
_schema-check:
    bash scripts/schema-check.sh

# Render the mdBook to _site/.
assemble:
    mdbook build docs

# Full build: lint then assemble.
build: lint assemble

# Pre-push gate: validate commits on branch and run a full build.
verify:
    git std lint --range main..HEAD
    just build

# Bump the project version, update changelog, commit + tag (per git-std).
bump:
    git std bump

# Remove build artifacts.
clean:
    rm -rf _site target node_modules .dprint
