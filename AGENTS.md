# AGENTS.md

Agent guidance for `driftsys/ci`. Read this end-to-end before making changes.

## What this repo is

A library of **reusable CI building blocks** for the driftsys org. There are two
kinds of artifact:

- **Components** — single-purpose, one job each.
  - `actions/<name>/{action.yml,README.md}` — composite GitHub Actions. Shell
    logic is inlined directly in `run:` blocks (no external scripts) so the
    action is self-contained when consumers `uses:` it.
  - `components/<name>/{template.yml,README.md}` — GitLab CI components. Shell
    logic is inlined in `script:` lines for the same reason: the consumer's
    checkout is CWD, and `driftsys/ci`'s files aren't on disk.
- **Presets** — opinionated combinations of components plus orchestration (event
  gates, permissions, job ordering) for a common scenario.
  - `.github/workflows/<name>.yml` — reusable workflow (`on: workflow_call`).
    Composite actions can't span multiple jobs / triggers, so presets on the GH
    side are reusable workflows, not composite actions.
  - `actions/<name>/README.md` — the docs chapter for the GH preset (paired with
    the workflow file above; the directory holds docs only).
  - `components/<name>/{template.yml,README.md}` — same shape as a component;
    the template body is just an `include:` of the preset's sub-components,
    pinned at `$CI_COMPONENT_REF` for reproducibility.

Other repo content:

- `scripts/` — local helpers used by `just` recipes (schema validation, GL
  inline-shell extraction). Not consumed by actions or components.
- `book.toml` + `SUMMARY.md` at the repo root — mdBook published to GitHub
  Pages. Each component / preset README doubles as its book chapter.
- `docs/intro.md`, `docs/recipes/`, `docs/research/` — narrative book content.
- `.gitlab-ci.yml` at the repo root — Layer 3 smoke pipeline that runs on the
  GitLab mirror (`gitlab.com/driftsys/ci`, kept in sync by
  `.github/workflows/mirror-gitlab.yml` on every push). It also publishes the
  components to the GitLab CI Catalog on tag.

GitLab components consume builder images from `driftsys/dock`
(`ghcr.io/driftsys/dock:<image>-v<version>`).

## Build commands

| Command         | What it does                                                                      |
| --------------- | --------------------------------------------------------------------------------- |
| `just fmt`      | Format md/json/toml (dprint) and shell (shfmt).                                   |
| `just lint`     | dprint, markdownlint, shellcheck, shfmt, actionlint, schemas, GL inline shell.    |
| `just lint-fix` | Apply auto-fixes for lint where supported.                                        |
| `just assemble` | Render mdBook to `_site/`.                                                        |
| `just build`    | `lint` + `assemble`.                                                              |
| `just verify`   | `git std lint --range main..HEAD` + `just build`. Run before PR.                  |
| `just bump`     | `git std bump` (the `release` action does this in CI; `bump` is the local entry). |

Run `./bootstrap` after clone or worktree add (installs git-std and hooks).

## Conventions

- **Conventional Commits** validated by git-std. Scopes: `repo`, `ci`, `docs`,
  `actions`, `components`, `scripts`, `tests`, `deps`, `research`.
- **Inline shell** in `action.yml`/`template.yml`. `actionlint` shellchecks the
  GH side automatically; `scripts/lint-gitlab-shell.sh` extracts and shellchecks
  the GL side. Behavioural coverage comes from live smoke tests
  (`smoke-components.yml`), not from unit-tested helper scripts.
- **GitLab inputs go through `variables:`.** Inside a `template.yml`, every
  `$[[ inputs.x ]]` reference must live in the `variables:` block; `script:`
  bodies reference the resulting `$VAR` only. That keeps `script:` bodies pure
  bash and shellcheckable. (`stage:` / `image:` etc. that are GitLab YAML keys,
  not shell, can use `$[[ inputs.x ]]` directly.)
- Every input is documented in both the YAML and the component's `README.md`.
  The README doubles as the published book chapter — there is no separate
  `usage/<name>.md`.

## Workflow

1. Run `./bootstrap` after clone or `git worktree add`.
2. Branch from `main`. Use git-std for commits and bumps.
3. Edit the YAML directly — inline scripts are the source of truth.
4. Run `just verify` (also enforced by the pre-push hook).
5. Open PR. CI (`.github/workflows/ci.yml`) runs the same checks `just verify`
   does, plus dogfoods `./actions/commitlint` to lint the PR's commits.
   `smoke-components.yml` runs the live component smoke tests in parallel.

`just` is a local-developer-experience tool only — CI calls each lint / build
step directly so each one is its own named step in the GitHub UI.

## Releases

Releases are cut with git-std locally on `main`:

```sh
git std bump --release-as <X.Y.Z>      # updates project.yaml + CHANGELOG.md, commits, tags vX.Y.Z
git push origin main --follow-tags
```

For a major-version bump (or the first release of a new major), also move the
rolling-major branch so consumers pinned to `@vN` pick up the new release:

```sh
git branch -f vN vX.Y.Z   # or `git branch vN vX.Y.Z` for the very first time
git push origin vN --force-with-lease
```

Then `gh release create vX.Y.Z --generate-notes` for the GH-side release notes.
Once the `release` action / `standard-release` reusable workflow is wired into
CI on push-to-main, this becomes automatic.

## Git hooks (installed by `git std bootstrap`)

- `commit-msg`: validates Conventional Commits via `git std lint --file {msg}`.
- `pre-commit`: `~ just fmt` (auto-format and re-stage).
- `pre-push`: `! just verify` (blocks push on failure).

## Adding a component

1. Create `actions/<name>/{action.yml,README.md}` with all logic inline in
   composite `run:` blocks.
2. Create `components/<name>/{template.yml,README.md}` with all logic inline in
   `script:` lines (inputs piped through `variables:`).
3. Link the two READMEs from the root `SUMMARY.md` under
   `# GitHub Actions → Components` and `# GitLab CI/CD → Components`.
4. Add a smoke step in `.github/workflows/smoke-components.yml` (happy path +
   error path).

## Adding a preset

1. Create `.github/workflows/<name>.yml` — a reusable workflow
   (`on: workflow_call`) that composes component actions across multiple jobs
   with appropriate `if:` event gates and least-privilege `permissions:`.
2. Create `actions/<name>/README.md` — the docs chapter for the GH preset (no
   `action.yml`; the directory only holds docs).
3. Create `components/<name>/{template.yml,README.md}` — the GitLab side. The
   template's body is an `include:` list pinning each sub-component at
   `$CI_COMPONENT_REF` so the preset's tag propagates to its parts.
4. Link both READMEs from `SUMMARY.md` under `# GitHub Actions → Presets` and
   `# GitLab CI/CD → Presets`.
5. Smoke coverage is usually inherited from the underlying components; only add
   a dedicated preset smoke if the orchestration itself has a non-trivial
   failure mode.
