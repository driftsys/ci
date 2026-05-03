# Testing CI/CD frameworks

This note surveys how projects test their own reusable actions and components,
evaluates each approach for `driftsys/ci`, and closes with the strategy we
adopt.

## What we are testing

Three distinct layers need coverage:

1. **Shell logic** — the scripts in `scripts/` that implement the actual work.
   These are pure POSIX shell; they can be unit-tested without a CI runner.
2. **Action / component glue** — the `action.yml` and `template.yml` files.
   These wire inputs to scripts and configure the runner environment. Errors
   here are usually typos or missing `env:` bindings.
3. **End-to-end behaviour** — does the action do the right thing when a real
   runner executes it against a real repository?

A good testing strategy provides fast feedback on layer 1, catches glue errors
in layer 2, and provides confidence on layer 3 without requiring a full CI run
for every trivial change.

## Approach A: Static checks only

**What it covers:** JSON schema validation of `action.yml` and `template.yml`;
shellcheck and shfmt for embedded shell.

**Tooling:** `check-jsonschema` (Python, reads from schemastore.org),
shellcheck, shfmt.

**Strengths:** Fast (seconds), no runner required, catches the most common class
of glue errors (wrong field names, invalid YAML structure, shell syntax errors).

**Weaknesses:** Does not catch logic errors in scripts, missing `env:` bindings,
wrong `uses:` path references, or runner-environment mismatches.

**Verdict:** Necessary but not sufficient. Cheap enough to always run.

## Approach B: bash_unit for shell scripts

**What it covers:** Unit tests for `scripts/*.sh` using a test framework that
fakes `git`, `git-std`, and other dependencies via PATH manipulation.

**Tooling:** [`pgrange/bash_unit`](https://github.com/pgrange/bash_unit) — a
lightweight shell test framework. Tests live alongside the scripts in
`tests/<name>_test.sh`.

**Strengths:** Fast (milliseconds per test), no docker, no network. Tests the
branching logic that static analysis cannot reach. Fakes let you drive failure
paths that are hard to reproduce with real git history.

**Weaknesses:** Tests run against fakes, not real binaries. A mismatch between
the fake's behaviour and `git-std`'s actual output format would let bugs
through. Must be disciplined about keeping fakes simple and narrow.

**Verdict:** Essential. Every script in `scripts/` must have a sibling test
file.

## Approach C: `act` (local GH Actions emulator)

**What it covers:** Runs `action.yml` composite steps locally in a docker
container that approximates the GitHub-hosted runner environment.

**Tooling:** [`nektos/act`](https://github.com/nektos/act).

**Strengths:** Developer can iterate locally without pushing. Catches `env:`
binding errors and path issues that static checks miss.

**Weaknesses:**

- **Image fidelity gaps.** `act` uses a cut-down `ubuntu:latest` image, not
  `ubuntu-22.04` / `ubuntu-24.04`. Some actions rely on pre-installed tooling
  that is absent in the act container.
- **Composite action path resolution.** `${{ github.action_path }}` does not
  always resolve correctly in act, making local testing of composite actions
  unreliable.
- **Maintenance overhead.** Keeping `act` working in CI requires a
  Docker-in-Docker setup and act-specific workarounds. This overhead often
  exceeds the benefit when a real runner is available.
- **Context differences.** `${{ github.event }}` payloads, OIDC tokens, and
  GitHub App tokens are not available or are mocked in ways that differ from
  production.

**Verdict for `driftsys/ci`:** Skip `act` in CI. The real runner (Approach D)
covers the same ground with higher fidelity and less maintenance overhead. `act`
remains useful as an optional developer tool for rapid local iteration but is
not part of the required test suite.

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

**Strengths:** Exact same environment as production. Tests `action.yml` path
resolution, `github.action_path`, and all runner context variables. No
maintenance overhead beyond writing the fixture.

**Weaknesses:** Slower than bash_unit (minutes per run, not seconds). Cannot
easily test error paths (e.g. a deliberately bad commit message) without
additional fixture management.

**Error-path testing:** Use `continue-on-error: true` on a step that is expected
to fail, then assert `steps.<id>.outcome == 'failure'` in the next step. This
pattern tests the failure mode without failing the job.

**Verdict:** Essential for every action. Run on every PR and on push to main.

## Approach E: GitLab mirror smoke pipeline

**What it covers:** A GitLab CI pipeline on the GL mirror that includes each
component and runs it against a fixture merge request.

**Tooling:** A `.gitlab-ci.yml` in the mirror that uses `include: component:` to
pull in the components from the same repo. Triggered on tag push or manually via
`glab pipeline run`.

**Strengths:** Tests the actual GitLab component YAML syntax, the dock image
integration, and `$CI_*` variable bindings. This is the only way to catch
GitLab-specific issues.

**Weaknesses:** Requires a GitLab mirror to be set up first. Slower feedback
loop. Limited to what free GitLab CI minutes allow.

**Verdict:** Required for GitLab components, but blocked on the mirror setup
(out of scope for this PR). Documented here; first green run lands once the
mirror is wired.

## Approach F: Static GitLab CI lint

**What it covers:** `glab ci lint` (or the GitLab API
`POST /projects/:id/ci/lint`) validates `template.yml` syntax and component spec
structure without running a pipeline.

**Tooling:** `glab` CLI or `check-jsonschema` against the GitLab CI JSON schema
(schemastore.org).

**Verdict:** We already include this via `scripts/schema-check.sh` (Approach A).
No additional step required.

## Recommended strategy for `driftsys/ci`

We adopt a three-layer strategy:

### Layer 1 — Static + unit (every PR, < 2 min)

Run by `just verify` → `just build` → `just check`:

- `dprint check` — formatting.
- `markdownlint-cli2` — markdown structure.
- `shellcheck` + `shfmt -d` — shell quality.
- `scripts/schema-check.sh` — `action.yml` + `template.yml` schema validation.
- `bash tools/bash_unit tests/*_test.sh` — unit tests for shared scripts.

### Layer 2 — Live GH Actions smoke (every PR, ~ 5 min)

Run by `.github/workflows/smoke-components.yml`:

- One smoke job per action, using `uses: ./actions/<name>` against a synthesized
  fixture commit.
- At least one error-path smoke per action (bad input should fail the step, and
  we assert `outcome == 'failure'`).

### Layer 3 — GitLab mirror smoke (on tag, async)

- A `.gitlab-ci.yml` on the GitLab mirror that uses `include: component:` for
  each component.
- Triggered on tag push to the mirror.
- First green run lands once the mirror is wired up (post-PR follow-up).

### What we explicitly skip

- **`act`** in CI: too much maintenance overhead vs. the real runner.
- **`gitlab-runner exec`**: deprecated and not supported on current versions.
- **Contract / schema mutation testing**: valuable eventually, but out of scope
  for `v0`.

### Applying the strategy

The three layers are implemented as follows in this repo:

| Layer | Location                                   | Status               |
| ----- | ------------------------------------------ | -------------------- |
| 1     | `just verify` + `.github/workflows/ci.yml` | Shipped in this PR   |
| 2     | `.github/workflows/smoke-components.yml`   | Shipped in this PR   |
| 3     | `.gitlab-ci.yml` on GL mirror              | Pending mirror setup |

Every new component added to this repo must include Layer 1 coverage (a
`tests/<name>_test.sh` with at least the happy path and one error path) and
Layer 2 coverage (a smoke step in `smoke-components.yml`). This is enforced by
the AGENTS.md checklist for adding a component.
