# Default: show the recipe list.
[private]
default:
    @just --list

# Format markdown/json/toml (dprint) and shell scripts (shfmt).
fmt:
    dprint fmt
    shfmt -w -i 2 -ci -sr scripts/ bootstrap 2>/dev/null || true

# Lint: dprint, markdownlint, shellcheck, shfmt, actionlint, schema, GL inline shell.
lint:
    dprint check
    npx --yes markdownlint-cli2 "**/*.md" "#node_modules" "#_site" "#docs/superpowers"
    shellcheck scripts/*.sh bootstrap
    shfmt -d -i 2 -ci -sr scripts/ bootstrap
    actionlint
    just _schema-check
    just _gitlab-shell-check

# Apply formatter and auto-fix markdown lint issues.
lint-fix:
    just fmt
    npx --yes markdownlint-cli2 --fix "**/*.md" "#node_modules" "#_site" "#docs/superpowers"

# Validate action.yml and GitLab component templates against their schemas.
[private]
_schema-check:
    bash scripts/schema-check.sh

# Shellcheck the inline `script:` lines of GitLab component templates.
[private]
_gitlab-shell-check:
    bash scripts/lint-gitlab-shell.sh

# Render the mdBook to _site/.
assemble:
    mdbook build

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
