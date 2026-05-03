# Testing CI/CD frameworks

This note surveys how projects test their own reusable actions and components,
evaluates each approach for `driftsys/ci`, and closes with the strategy we
adopt.

## What we are testing

Two distinct layers need coverage:

1. **Action / component glue** — the `action.yml` and `template.yml` files,
   including the inline shell in their `run:` / `script:` blocks. Errors
   here are usually typos, missing `env:` bindings, or quoting bugs in the
   inline shell.
2. **End-to-end behaviour** — does the action do the right thing when a real
   runner executes it against a real repository?

We deliberately inline the shell into the YAML rather than calling out to
shared `scripts/*.sh` files. The reason is portability: a GitLab component
running in a consumer's pipeline has the consumer's checkout as CWD and
cannot reach `driftsys/ci/scripts/`. Inlining keeps each component
self-contained when published. The trade-off is that shell logic isn't unit
testable in isolation — but for the small (< 10-line) scripts our components
run today, the value of unit tests is low and live smoke tests catch the
interesting bugs.

## Approach A: Static checks

**What it covers:** YAML schema validation of `action.yml` and `template.yml`,
plus shellcheck on the inline shell in GH Actions via `actionlint`, plus
`shfmt`/`shellcheck` on the standalone helper scripts under `scripts/`.

**Tooling:** `check-jsonschema` (Python, reads from schemastore.org / gitlab.com),
`actionlint`, `shellcheck`, `shfmt`, `dprint`, `markdownlint-cli2`.

**Strengths:** Fast (seconds), no runner required, catches the most common
class of glue errors (wrong field names, invalid YAML structure, shell syntax
errors and unquoted-variable bugs in inline `run:` blocks).

**Weaknesses:**

- `actionlint` is GitHub-only — GitLab `script:` lines are not shellchecked
  by anything off the shelf. Acceptable today because each component's
  inline shell is short; revisit with a `yq`+`shellcheck` extractor if a
  component grows non-trivial branching.
- Does not catch missing `env:` bindings, wrong `uses:` path references, or
  runner-environment mismatches.

**Verdict:** Necessary and sufficient for layer 1.

## Approach B: bash_unit for shared scripts

**What it covers:** Unit tests for `scripts/*.sh` using a test framework that
fakes `git`, `git-std`, etc. via PATH manipulation.

**Verdict for `driftsys/ci`:** Skipped. We inline shell into the YAML rather
than share `scripts/*.sh` between components, so there's nothing to unit-test
in isolation. If a future component needs more than ~10 lines of branching
shell, re-introduce `scripts/<name>.sh` for that one and add a sibling
`tests/<name>_test.sh`.

## Approach C: `act` (local GH Actions emulator)

**What it covers:** Runs `action.yml` composite steps locally in a docker
container that approximates the GitHub-hosted runner environment.

**Tooling:** [`nektos/act`](https://github.com/nektos/act).

**Strengths:** Developer can iterate locally without pushing. Catches `env:`
binding errors and path issues that static checks miss.

**Weaknesses:** Image-fidelity gaps, unreliable composite-action path
resolution, Docker-in-Docker maintenance overhead, and mocked context
variables that diverge from production.

**Verdict for `driftsys/ci`:** Skip in CI. The real runner (Approach D)
covers the same ground with higher fidelity. `act` remains useful as an
optional developer tool but is not part of the required test suite.

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
`action.yml` path resolution, and all runner context variables. No
maintenance overhead beyond writing the fixture.

**Weaknesses:** Slower than static checks (minutes per run, not seconds).
Error paths need explicit `continue-on-error: true` + outcome assertion.

**Verdict:** Essential for every action. Run on every PR and on push to main.

## Approach E: GitLab mirror smoke pipeline

**What it covers:** A GitLab CI pipeline on the GL mirror that includes each
component and runs it against a fixture merge request.

**Tooling:** A `.gitlab-ci.yml` in the mirror that uses `include: component:`
to pull in the components from the same repo. Triggered on tag push or
manually via `glab pipeline run`.

**Strengths:** Tests the actual GitLab component YAML syntax, the dock image
integration, and `$CI_*` variable bindings. This is the only way to catch
GitLab-specific issues, and the only way to shellcheck the inline `script:`
lines (by actually running them).

**Weaknesses:** Requires a GitLab mirror to be set up first. Slower feedback
loop. Limited to what free GitLab CI minutes allow.

**Verdict:** Required for GitLab components, but blocked on the mirror setup.
First green run lands once the mirror is wired.

## Approach F: Static GitLab CI lint

**What it covers:** `glab ci lint` (or the GitLab API
`POST /projects/:id/ci/lint`) validates `template.yml` syntax and component
spec structure without running a pipeline.

**Verdict:** Already covered by `scripts/schema-check.sh` (Approach A). No
additional step required.

## Recommended strategy for `driftsys/ci`

We adopt a two-layer strategy (the third was a unit-test layer; we dropped it
when we inlined the scripts).

### Layer 1 — Static checks (every PR, < 1 min)

Run by `just verify` → `just build` → `just lint`:

- `dprint check` — formatting.
- `markdownlint-cli2` — markdown structure.
- `shellcheck` + `shfmt -d` — shell quality (helper scripts under `scripts/`).
- `actionlint` — shellchecks inline shell in `action.yml` and validates GH
  Actions structure.
- `scripts/schema-check.sh` — `action.yml` + `template.yml` schema validation.

### Layer 2 — Live GH Actions smoke (every PR, ~ 5 min)

Run by `.github/workflows/smoke-components.yml`:

- One smoke job per action, using `uses: ./actions/<name>` against a
  synthesized fixture commit.
- At least one error-path smoke per action (bad input should fail the step,
  and we assert `outcome == 'failure'`).

### Layer 3 — GitLab mirror smoke (on tag, async)

- A `.gitlab-ci.yml` on the GitLab mirror that uses `include: component:` for
  each component.
- Triggered on tag push to the mirror.
- First green run lands once the mirror is wired up (post-PR follow-up).

### What we explicitly skip

- **bash_unit** for shared scripts: components inline their shell, so there
  are no shared scripts to unit-test. Re-introduce per-component if a
  component grows non-trivial branching.
- **`act`** in CI: too much maintenance overhead vs. the real runner.
- **`gitlab-runner exec`**: deprecated and not supported on current versions.
- **Contract / schema mutation testing**: valuable eventually, but out of
  scope for `v0`.

### Applying the strategy

The layers are implemented as follows in this repo:

| Layer | Location                                   | Status               |
| ----- | ------------------------------------------ | -------------------- |
| 1     | `just verify` + `.github/workflows/ci.yml` | Shipped              |
| 2     | `.github/workflows/smoke-components.yml`   | Shipped              |
| 3     | `.gitlab-ci.yml` on GL mirror              | Pending mirror setup |

Every new component added to this repo must include Layer 2 coverage (a smoke
step in `smoke-components.yml`, happy path + error path). This is enforced by
the AGENTS.md checklist for adding a component.
