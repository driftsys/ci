# AGENTS.md

Agent guidance for `driftsys/ci`. Read this end-to-end before making changes.

## What this repo is

A library of **reusable CI building blocks** for the driftsys org:

- `actions/<name>/` — composite GitHub Actions, each with `action.yml` +
  scripts.
- `components/<name>/` — GitLab CI components, each with `template.yml`.
- `scripts/<name>.sh` — shared shell logic, bash_unit-tested under `tests/`.
- `docs/` — mdBook published to GitHub Pages.

GitLab components consume builder images from `driftsys/dock`
(`ghcr.io/driftsys/dock:<image>-v<version>`).

## Build commands

| Command         | What it does                                                          |
| --------------- | --------------------------------------------------------------------- |
| `just fmt`      | Format md/json/yaml (dprint) and shell (shfmt).                       |
| `just lint`     | dprint check, markdownlint-cli2, shellcheck, action/component schema. |
| `just lint-fix` | Apply auto-fixes for lint where supported.                            |
| `just test`     | bash_unit suites in `tests/`.                                         |
| `just check`    | `test` + `lint`.                                                      |
| `just assemble` | Render mdBook to `_site/`.                                            |
| `just build`    | `check` + `assemble`.                                                 |
| `just verify`   | `git std lint --range main..HEAD` + `just build`. Run before PR.      |

Run `./bootstrap` after clone or worktree add (installs git-std and hooks).

## Conventions

- **Conventional Commits** validated by git-std. Scopes: `repo`, `ci`, `docs`,
  `actions`, `components`, `scripts`, `tests`, `deps`.
- One concern per shell script. Shared logic lives in `scripts/`; `action.yml`
  and `template.yml` call into it.
- Every input/output is documented in both `action.yml`/`template.yml` and
  `docs/src/usage/<name>.md`.
- Tests: each `scripts/<name>.sh` has a sibling `tests/<name>_test.sh`.
  End-to-end smoke tests live in `.github/workflows/smoke-components.yml`.

## Workflow

1. Run `./bootstrap` after clone or `git worktree add`.
2. Branch from `main`. Use git-std for commits and bumps.
3. Add tests alongside any new shell script.
4. Run `just verify` (also enforced by the pre-push hook).
5. Open PR. CI runs `just verify` and component smoke tests.

## Git hooks (installed by `git std bootstrap`)

- `commit-msg`: validates Conventional Commits via `git std lint --file {msg}`.
- `pre-commit`: `~ just fmt` (auto-format and re-stage).
- `pre-push`: `! just verify` (blocks push on failure).

## Adding a component

1. Create `actions/<name>/{action.yml,README.md,scripts/run.sh}`.
2. Create `components/<name>/{template.yml,README.md}`.
3. Add `scripts/<name>.sh` (shared logic) and `tests/<name>_test.sh`.
4. Add `docs/src/usage/<name>.md` and link from `docs/src/SUMMARY.md`.
5. Add a smoke step in `.github/workflows/smoke-components.yml`.
