# DevEx survey: reusable GH Actions and GitLab CI components

This note surveys public and corporate patterns for reusable CI building blocks.
The goal is to extract principles that make components easy to adopt, trust, and
maintain.

## Why this matters

A reusable action or component is a public API. Once consumers pin to a version,
any breaking change is a support burden. Small ergonomic decisions (unclear
input names, swallowed error codes, opaque failure messages) compound across
dozens of pipelines. Getting this right upfront is cheaper than retrofitting it.

## Inputs

**Make required inputs explicit.** Both GH Actions (`required: true`) and GitLab
components (`spec.inputs.<name>` without a `default:`) support this. Surface
missing required inputs as an error at configuration time, not as a cryptic
runtime failure.

**Use sensible defaults for optional inputs.** A consumer who only reads the
example should get a working pipeline. Defaults should reflect the most common
use case, not the safest-for-the-maintainer one.

**Document inputs with `description:`.** Both platforms render descriptions in
their UIs. A one-sentence description prevents the most common support
questions. Compare `actions/cache` (clear descriptions per input) with older
internal actions that have undocumented `SOME_FLAG` env vars.

**Single-purpose inputs beat kitchen-sink configs.** `actions/setup-node`
exposes `node-version` and `cache`; it does not expose every `npm config` flag.
The more surface area, the harder it is to keep stable. Prefer composing small
actions over building configurable monoliths.

## Outputs

**Use stable, lowercase, hyphenated output names.** Outputs are referenced in
downstream `steps.<id>.outputs.<name>` expressions. A rename is a breaking
change. Follow `actions/checkout`'s precedent: `ref`, `sha`, `token`.

**Expose structured JSON when the output is structured.**
`softprops/action-gh-release` outputs `assets` as a JSON array string. Consumers
parse it with `fromJSON(...)`. This is more stable than trying to output
separate `asset-1-url`, `asset-2-url` keys.

**Avoid implicit side-effects as outputs.** If a step writes to `$GITHUB_ENV` or
`$GITHUB_PATH` as a side effect, document it. Consumers who read only the
inputs/outputs table will be surprised.

## Versioning

**Offer a rolling major-version branch.** `actions/checkout@v4` tracks the
latest `v4.x.y` release. This lets security-conscious consumers stay current
without constant pin updates. GitLab's `~latest` serves the same purpose for
components.

**Tag every release with a full semver tag.** Rolling branches are convenient;
full tags (`v0.1.3`) are essential for reproducibility and security audits. Orgs
that mandate SHA pinning need the tag to resolve the SHA.

**Treat breaking changes as major bumps.** A new required input, a renamed
output, or a changed exit-code convention is a breaking change. Following semver
strictly builds trust.

**For pre-1.0 components,** use `v0.x` and communicate that the API may change.
Consumers who need stability should wait for `v1`.

## Discoverability

**README at the action root.** `driftsys/ci/actions/commitlint/README.md` is
what GitHub renders when a user browses to the action. Keep it short: what it
does, inputs table, minimal example.

**`branding:` in `action.yml`.** GitHub's marketplace and search use the icon
and colour for visual identification. Even if you never publish to the
marketplace, consistent branding distinguishes your actions at a glance in
third-party catalogs.

**A central index.** `driftsys.github.io/ci` lists all components with one- line
descriptions. Developers browsing for a solution see the full menu; those who
find a specific component via search can navigate to siblings.

**Consistent naming.** Use a single verb or `<verb>-<noun>` (e.g. `commitlint`,
`release`). Avoid abbreviations (`cmt` for `commitlint`) and avoid over-generic
names (`run`, `execute`, `helper`). Name by intent, not implementation
(`release` over `bump-push`).

## Failure modes

**Always exit non-zero on failure.** Composite actions can accidentally swallow
a failure if a sub-step uses `continue-on-error: true` without checking
`steps.<id>.outcome` afterwards. Test this explicitly: a smoke test that
provides bad input should make the whole job fail.

**Emit structured errors.** GitHub Actions supports `::error::message` and
`::error file=...,line=...,col=...:message`. GitLab surfaces job output
directly. Either way, tell the user _which_ commit failed and _why_, not just
that something went wrong.

**Never silently skip.** If a component has no work to do (e.g. commitlint with
an empty range), exit 0 with a notice, not silently. Silent success on an empty
range hides misconfiguration.

**Document `continue-on-error` use cases.** Some callers want lint failures to
be advisory (post a comment but not block the merge). Expose `soft-fail` as an
explicit input rather than assuming.

## Patterns from public OSS actions

**`actions/checkout`** — the gold standard for composite input design. Small
surface area, every input documented, no surprising side effects. The
`fetch-depth` default of `1` is a common gotcha (commitlint needs full history),
but the input is clearly documented and the workaround is one line.

**`actions/cache`** — demonstrates key-based invalidation as a first-class
concept. The `key` / `restore-keys` design makes cache busting explicit rather
than magic. The `cache-hit` output lets callers conditionally skip work.

**`softprops/action-gh-release`** — good structured output (`assets` JSON
array), but the `files` input accepts a glob that silently does nothing if no
files match. A strict mode would be safer for most consumers.

**`dorny/paths-filter`** — excellent discoverability (README with interactive
examples), but grew a very large input surface over time. The more inputs, the
harder semver discipline becomes.

## Patterns from corporate environments

**Internal action catalogs.** Large engineering orgs maintain an internal
catalog (e.g. a Confluence/Notion page, or a GitHub org-level topic filter) of
blessed actions. Discoverability within the org matters as much as on the
marketplace.

**SHA pinning.** Security-sensitive orgs require SHA-pinned references
(`uses: driftsys/ci/actions/commitlint@<sha>`) rather than floating tags. This
is compatible with rolling major branches: the org's Renovate/Dependabot
configuration keeps SHAs current automatically.

**OIDC over PATs.** Actions that push or publish should use OIDC tokens
(`permissions: id-token: write`) rather than long-lived PATs. This limits the
blast radius of a compromised workflow.

**Least-privilege `permissions:` blocks.** Define `permissions:` at the job
level, not the workflow level. Grant only what the action explicitly needs.

**CA certificate bootstrap.** Corporate environments often run self-signed or
custom CA certs. `driftsys/dock`'s `dock-bootstrap` utility handles this
transparently. GitLab components that use dock images should call
`dock-bootstrap` in `before_script`.

## Implications for `driftsys/ci`

Based on the above, we adopt the following concrete rules:

1. **One responsibility per component.** commitlint validates commits; release
   bumps and pushes. They do not double as general-purpose shell runners.
2. **All inputs documented** in both the YAML (`action.yml` / `template.yml`)
   and the component's `README.md` — the README doubles as the published
   chapter in the user guide.
3. **Outputs are JSON** when the value is structured (e.g. a list of failed
   commit SHAs).
4. **Rolling `v0` branch** tracks the latest release; semver tags for pinning.
5. **GitLab variants pin `image:` to `ghcr.io/driftsys/dock:<image>-v<ver>`** by
   default; consumers can override via the `image` input.
6. **Composite actions** (not Docker-based) unless the required tooling is not
   available in `:core`/`:lint` and installing it inline is unreasonable.
7. **Explicit `permissions:` blocks** at the job level in all provided example
   workflows.
8. **`continue-on-error`** is never set by default; it is an explicit opt-in
   input if we add it.
