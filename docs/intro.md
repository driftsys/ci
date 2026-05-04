# Introduction

`driftsys/ci` is a catalogue of small, focused CI building blocks maintained by
the driftsys org. Every block ships in two parallel forms:

- a **composite GitHub Action** at `actions/<name>/`
- a **GitLab CI component** at `components/<name>/`

Pick the form that matches your platform — the inputs, defaults, and behaviour
are aligned across both.

## What's in here

| Component                                     | What it does                                                                                                          |
| --------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| [commitlint](../actions/commitlint/README.md) | Validate commit messages against the Conventional Commits spec, using [git-std](https://github.com/driftsys/git-std). |
| [release](../actions/release/README.md)       | Bump the semver version per the commits since the last tag, commit + tag, then push.                                  |

For the lazy default — PR commit lint plus release on main, in one line — adopt
the [standard-release](../components/standard-release/README.md) bundle.

## How to use this guide

Each component has two chapters in the sidebar — one per platform. Start with
the chapter for the CI you actually run; the example at the top is the smallest
working invocation. The "Inputs" table covers every knob.

For end-to-end pipelines that combine multiple components, see
[Recipes](recipes/pr-validation.md).

For why each design decision was made (input naming, output shapes, versioning,
testing strategy), see [Research](research/devex.md).

## Versioning

Components follow semver. Pin to `@v0`, `@v0.1.0`, or `@~latest` depending on
how strict you need to be:

- `@v0` — rolling pointer to the latest `0.x.y`. New optional inputs and bug
  fixes land automatically; breaking changes wait for `v1`.
- `@v0.1.0` — exact tag, fully reproducible.
- `@~latest` (GitLab only) — equivalent of `@v0` semantics on GitLab.

## Contributing

Source lives at <https://github.com/driftsys/ci>. The repo's `README.md` covers
local development and contribution guidance.
