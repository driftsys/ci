# Testing CI/CD frameworks

This note surveys how projects test their own reusable actions and components,
evaluates each approach for `driftsys/ci`, and closes with the strategy we
adopt.

## What we are testing

Two distinct layers need coverage:

1. **Action / component glue** — the `action.yml` and `template.yml` files,
   including the inline shell in their `run:` / `script:` blocks. Errors here
   are usually typos, missing `env:` bindings, or quoting bugs in the inline
   shell.
2. **End-to-end behaviour** — does the action do the right thing when a real
   runner executes it against a real repository?

We deliberately inline the shell into the YAML rather than calling out to shared
`scripts/*.sh` files. The reason is portability: a GitLab component running in a
consumer's pipeline has the consumer's checkout as CWD and cannot reach
`driftsys/ci/scripts/`. Inlining keeps each component self-contained when
published.

## Approach A: Static checks

**What it covers:** YAML schema validation of `action.yml` and `template.yml`,
plus shellcheck on the inline shell in GH Actions via `actionlint`, plus a
`yq + shellcheck` extractor for GitLab `script:` lines.

**Tooling:** `check-jsonschema`, `actionlint`, `shellcheck`, `shfmt`, `dprint`,
`markdownlint-cli2`, `yq`.

**Strengths:** Fast (seconds), no runner required, catches the most common class
of glue errors (wrong field names, invalid YAML structure, shell syntax errors
and unquoted-variable bugs in inline `run:` / `script:` blocks).

**Weaknesses:** Doesn't catch missing `env:` bindings, wrong `uses:` path
references, or runner-environment mismatches.

**Verdict:** Necessary and sufficient for layer 1.

### Convention enabling the GitLab `script:` lint

GitLab templates must pipe `$[[ inputs.x ]]` through `variables:` and reference
the resulting `$VAR` from `script:` lines. That keeps `script:` bodies pure
bash, which `scripts/lint-gitlab-shell.sh` extracts via `yq` and feeds to
`shellcheck`. Inline `$[[ inputs.x ]]` inside `script:` would parse as a bash
arithmetic expansion and confuse shellcheck.

## Approach B: bash_unit for shared scripts

**Verdict for `driftsys/ci`:** Skipped. We inline shell into the YAML rather
than share `scripts/*.sh` between components, so there's nothing to unit-test in
isolation. If a future component needs more than ~10 lines of branching shell,
re-introduce `scripts/<name>.sh` for that one and add a sibling
`tests/<name>_test.sh`.

## Approach C: `act` (local GH Actions emulator)

**What it covers:** Runs `action.yml` composite steps locally in a docker
container that approximates the GitHub-hosted runner environment.

**Tooling:** [`nektos/act`](https://github.com/nektos/act).

**Weaknesses:** Image-fidelity gaps, unreliable composite-action path
resolution, Docker-in-Docker maintenance overhead, and mocked context variables
that diverge from production.

**Verdict for `driftsys/ci`:** Skip in CI. The real runner (Approach D) covers
the same ground with higher fidelity. `act` remains useful as an optional
developer tool but is not part of the required test suite.

## Approach D: Live GH Actions smoke tests

**What it covers:** A workflow in this repo's own CI that invokes each action
against a synthesized fixture, on real GitHub-hosted runners.

**Tooling:** `smoke-components.yml` workflow in `.github/workflows/`.

**How it works:**

```yaml
# Synthesize a known-good fixture commit, then run the action against it.
- name: Create fixture commit
  run: |
    git checkout -b smoke-fixture
    echo x > .smoke
    git add .smoke
    git commit -m "feat(repo): smoke fixture"
- uses: ./actions/commitlint
  with:
    range: HEAD~1..HEAD
```

**Strengths:** Exact same environment as production. Tests the inline shell,
`action.yml` path resolution, and all runner context variables.

**Verdict:** Essential for every action. Run on every PR and on push to main.

## Approach E: GitLab mirror smoke pipeline

**What it covers:** A GitLab CI pipeline on the GL mirror that includes each
component and runs it against a fixture merge request.

**Tooling:** A `.gitlab-ci.yml` in the mirror that uses `include: component:` to
pull in the components from the same repo. Triggered on tag push or manually via
`glab pipeline run`.

**Strengths:** Tests the actual GitLab component YAML syntax, the dock image
integration, and `$CI_*` variable bindings. This is the only way to catch
GitLab-specific issues, and the only way to actually execute the inline
`script:` lines.

**Weaknesses:** Requires a GitLab mirror to be set up first. Slower feedback
loop. Limited to what free GitLab CI minutes allow.

**Verdict:** Required for GitLab components, but blocked on the mirror setup.
First green run lands once the mirror is wired.

## Approach F: Static GitLab CI lint

**What it covers:** `glab ci lint` (or the GitLab API
`POST /projects/:id/ci/lint`) validates `template.yml` syntax and component spec
structure without running a pipeline.

**Verdict:** Already covered by `scripts/schema-check.sh` (Approach A). No
additional step required.

## Recommended strategy for `driftsys/ci`

We adopt a two-layer strategy plus a deferred third (the unit-test layer was
dropped when we inlined the scripts).

### Layer 1 — Static checks (every PR, < 1 min)

`.github/workflows/ci.yml` runs each tool as a separate, named step so the
GitHub UI surfaces granular pass/fail. The same set of checks is also driven
locally by `just verify` (which runs `git std lint --range main..HEAD` plus the
`just lint` + `just assemble` recipes — `just` is a local-developer convenience
and is not used in CI).

Per-PR, in order:

- `./actions/commitlint` — dogfooded against the PR's own commit range
  (`main..HEAD`). On `push` to main this step is skipped (the commits were
  already validated by their PR).
- `dprint check` — formatting.
- `npx markdownlint-cli2` — markdown structure.
- `shellcheck` + `shfmt -d` — quality of helper scripts under `scripts/`.
- `actionlint` — shellchecks inline shell in every `action.yml` and the reusable
  workflows under `.github/workflows/`.
- `scripts/schema-check.sh` — `action.yml` + `template.yml` schema validation.
- `scripts/lint-gitlab-shell.sh` — extracts and shellchecks inline shell in
  `template.yml`.
- `mdbook build` — book builds without broken refs.

### Layer 2 — Live GH Actions smoke (every PR, ~ 1 min)

`.github/workflows/smoke-components.yml` runs each component against a
synthesized fixture on a real GitHub-hosted runner:

- `commitlint (good commit)` — happy path, asserts success.
- `commitlint (bad commit — expect failure)` — error path, uses
  `continue-on-error: true` and asserts `steps.<id>.outcome == 'failure'`.
- `release (dry-run)` — runs `git std bump` + skips push.

Presets aren't separately smoked — they compose components that are already
covered, and the orchestration (event gates, permissions) is structurally
validated by `actionlint` + schema-check. Add a dedicated preset smoke only if a
preset grows non-trivial logic of its own.

### Layer 3 — GitLab mirror smoke (on tag, async)

- A `.gitlab-ci.yml` on the GitLab mirror that uses `include: component:` for
  each component.
- Triggered on tag push to the mirror.
- First green run lands once the mirror is wired up (post-PR follow-up).

### What we explicitly skip

- **bash_unit** for shared scripts: components inline their shell, so there are
  no shared scripts to unit-test.
- **`act`** in CI: too much maintenance overhead vs. the real runner.
- **`gitlab-runner exec`**: deprecated and not supported on current versions.
- **Contract / schema mutation testing**: out of scope for `v0`.

### Applying the strategy

The layers are implemented as follows in this repo:

| Layer | Location                                 | Status               |
| ----- | ---------------------------------------- | -------------------- |
| 1     | `.github/workflows/ci.yml`               | Shipped              |
| 2     | `.github/workflows/smoke-components.yml` | Shipped              |
| 3     | `.gitlab-ci.yml` on GL mirror            | Pending mirror setup |

Every new component added to this repo must include Layer 2 coverage (a smoke
step in `smoke-components.yml`, happy path + error path). This is enforced by
the AGENTS.md checklist for adding a component.
