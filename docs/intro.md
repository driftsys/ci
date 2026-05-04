# Introduction

`driftsys/ci` is a catalogue of small CI building blocks for the driftsys org.

There are two kinds of artifact:

- **Components** — single-purpose, one job each. Use them when you need
  fine-grained control over which steps run when.
- **Presets** — opinionated combinations of components plus the orchestration
  (event gates, permissions, job ordering) for a common scenario. Use them when
  you want the canonical pipeline in one line.

Every artifact ships in two parallel forms:

- a **composite GitHub Action** under `actions/<name>/`, or a **reusable
  workflow** under `.github/workflows/<name>.yml` for presets
- a **GitLab CI component** at `templates/<name>/`

Pick the form that matches your platform — the inputs, defaults, and behaviour
are aligned across both.

## Components

| Component     | What it does                                                                              |
| ------------- | ----------------------------------------------------------------------------------------- |
| commitlint    | Validate commit messages against the Conventional Commits spec, using `git std lint`.     |
| release       | Bump semver per the commits since the last tag, commit + tag, then push (`git std bump`). |
| release-notes | Publish a release page with notes from a tag (GH auto-notes; GL composes from `git log`). |

## Presets

| Preset           | What it does                                                                       |
| ---------------- | ---------------------------------------------------------------------------------- |
| standard-release | `commitlint` on PRs / MRs + `release` on the default branch. The driftsys default. |

## How to use this guide

Each artifact has two chapters in the sidebar — one per platform. Start with the
chapter for the CI you actually run; the example at the top is the smallest
working invocation. The "Inputs" table covers every knob.

For end-to-end pipelines that combine multiple components, see
[Recipes](recipes/pr-validation.md).

For why each design decision was made (input naming, output shapes, versioning,
testing strategy), see [Research](research/devex.md).

## Versioning

Components and presets follow semver. Pin to `@v0`, `@v0.1.0`, or `@~latest`
depending on how strict you need to be:

- `@v0` — rolling pointer to the latest `0.x.y`. New optional inputs and bug
  fixes land automatically; breaking changes wait for `v1`.
- `@v0.1.0` — exact tag, fully reproducible.
- `@~latest` (GitLab only) — equivalent of `@v0` semantics on GitLab.

## Contributing

Source lives at <https://github.com/driftsys/ci>. The repo's `README.md` covers
local development and contribution guidance.
