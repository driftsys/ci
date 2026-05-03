# AGENTS.md

Agent guidance for `driftsys/ci`. Read this end-to-end before making changes.

## What this repo is

A library of **reusable CI building blocks** for the driftsys org:

- `actions/<name>/action.yml` — composite GitHub Actions. Shell logic is
  inlined directly in `run:` blocks (no external scripts) so the action is
  self-contained when consumers `uses:` it.
- `components/<name>/template.yml` — GitLab CI components. Shell logic is
  inlined in `script:` lines for the same reason: the consumer's checkout is
  CWD, and `driftsys/ci`'s files aren't on disk.
- `scripts/` — local helpers used by `just` recipes (currently just
  `schema-check.sh`). Not consumed by actions or components.
- `docs/` — mdBook (sources at the top of `docs/`) published to GitHub Pages.

GitLab components consume builder images from `driftsys/dock`
(`ghcr.io/driftsys/dock:<image>-v<version>`).

## Build commands

| Command         | What it does                                                                         |
| --------------- | ------------------------------------------------------------------------------------ |
| `just fmt`      | Format md/json/toml (dprint) and shell (shfmt).                                      |
| `just lint`     | dprint, markdownlint, shellcheck, shfmt, actionlint, action/component schema.        |
| `just lint-fix` | Apply auto-fixes for lint where supported.                                           |
| `just assemble` | Render mdBook to `_site/`.                                                           |
| `just build`    | `lint` + `assemble`.                                                                 |
| `just verify`   | `git std lint --range main..HEAD` + `just build`. Run before PR.                     |
| `just bump`     | `git std bump` (the `release` action does this in CI; `bump` is the local entry).    |

Run `./bootstrap` after clone or worktree add (installs git-std and hooks).

## Conventions

- **Conventional Commits** validated by git-std. Scopes: `repo`, `ci`, `docs`,
  `actions`, `components`, `scripts`, `tests`, `deps`, `research`.
- **Inline shell** in `action.yml`/`template.yml`. `actionlint` shellchecks the
  GH side automatically; the GL side is structurally validated by
  `scripts/schema-check.sh`. Behavioural coverage comes from live smoke tests
  (`smoke-components.yml`), not from unit-tested helper scripts.
- Every input/output is documented in both `action.yml`/`template.yml` and
  `docs/usage/<name>.md`.

## Workflow

1. Run `./bootstrap` after clone or `git worktree add`.
2. Branch from `main`. Use git-std for commits and bumps.
3. Edit the YAML directly — inline scripts are the source of truth.
4. Run `just verify` (also enforced by the pre-push hook).
5. Open PR. CI runs `just verify` and component smoke tests.

## Git hooks (installed by `git std bootstrap`)

- `commit-msg`: validates Conventional Commits via `git std lint --file {msg}`.
- `pre-commit`: `~ just fmt` (auto-format and re-stage).
- `pre-push`: `! just verify` (blocks push on failure).

## Adding a component

1. Create `actions/<name>/{action.yml,README.md}` with all logic inline in
   composite `run:` blocks.
2. Create `components/<name>/{template.yml,README.md}` with all logic inline
   in `script:` lines.
3. Add `docs/usage/<name>.md` and link from `docs/SUMMARY.md`.
4. Add a smoke step in `.github/workflows/smoke-components.yml` (happy path +
   error path).
