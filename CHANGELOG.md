# Changelog

## [0.1.3] (2026-05-04)

### Bug Fixes

- **ci:** declare `release` stage in root .gitlab-ci.yml ([05f939f])

[0.1.3]: https://github.com/driftsys/ci/compare/v0.1.2...v0.1.3
[05f939f]: https://github.com/driftsys/ci/commit/05f939f

## [0.1.2] (2026-05-04)

### Bug Fixes

- **components:** move components/ -> templates/ for GitLab CI Catalog
  ([2ac54ef])

[0.1.2]: https://github.com/driftsys/ci/compare/v0.1.1...v0.1.2
[2ac54ef]: https://github.com/driftsys/ci/commit/2ac54ef

## [0.1.1] (2026-05-04)

### Bug Fixes

- **scripts:** make schema-check.sh portable to BSD mktemp (macOS) ([c2a3e35])

### Features

- **presets:** integrate release-notes into standard-release ([9bda035])
- **components:** release-notes — publish a release page from a tag
  ([91c3641])

### Documentation

- refresh AGENTS and research notes for current architecture ([af922e0])

[0.1.1]: https://github.com/driftsys/ci/compare/v0.1.0...v0.1.1
[c2a3e35]: https://github.com/driftsys/ci/commit/c2a3e35
[9bda035]: https://github.com/driftsys/ci/commit/9bda035
[91c3641]: https://github.com/driftsys/ci/commit/91c3641
[af922e0]: https://github.com/driftsys/ci/commit/af922e0

## 0.1.0 (2026-05-04)

### Bug Fixes

- **ci:** apply dprint fmt + fix shellcheck/shfmt issues in lint-gitlab-shell.sh
  ([415803b])
- **ci:** skip main-ref fetch and commit lint on push to main ([7dfe815])

### Refactoring

- **docs:** restructure book — Components vs Presets, per platform ([6c599ac])
- **ci:** drop `just` from CI; dogfood ./actions/commitlint ([c8817b9])
- **repo:** remove tools/.gitkeep (no more bash_unit dependency) ([d394133])
- **actions:** remove actions/release/scripts/run.sh (inlined) ([2526952])
- **actions:** remove actions/commitlint/scripts/run.sh (inlined) ([13b76c2])
- **tests:** remove tests/commitlint_test.sh (no shared script to test)
  ([7ac0ac1])
- **tests:** remove tests/release_test.sh (no shared script to test) ([4f8b2b1])
- **scripts:** remove scripts/commitlint.sh (inlined into action.yml +
  template.yml) ([705e82c])
- **scripts:** remove scripts/release.sh (inlined into action.yml +
  template.yml) ([91fab41])
- **docs:** remove docs/research/testing-ci-frameworks.md (moved to research/)
  ([e9d3ed2])
- **docs:** remove docs/research/devex.md (moved to research/) ([742402a])
- **docs:** remove docs/recipes/pr-validation.md (moved to recipes/) ([9a1ae43])
- **docs:** remove docs/usage/release.md (component README is the chapter)
  ([f6be27a])
- **docs:** remove docs/usage/commitlint.md (component README is the chapter)
  ([7050422])
- **docs:** remove docs/getting-started.md (folded into README.md) ([922886b])
- **docs:** remove docs/SUMMARY.md (moved to root) ([6fbaadc])
- **docs:** remove docs/book.toml (moved to root) ([f07b0b4])
- **docs+components:** hoist book to root, drop duplicate usage docs, add GL
  shell linter ([aabbd16])
- **components:** inline shell into action.yml and template.yml ([5da3a00])

### Documentation

- **book:** remove root research/testing-ci-frameworks.md (moved back to docs/)
  ([38f051a])
- **book:** remove root research/devex.md (moved back to docs/) ([4a1a125])
- **book:** remove root recipes/ (moved back to docs/) ([fdcdf43])
- **book:** add docs/intro.md as proper book intro; move narrative under docs/
  ([bf1d8b9])
- **repo:** add CI / latest-tag / docs badges to README ([a546808])
- remove old docs/src/research/testing-ci-frameworks.md (moved to
  docs/research/) ([393356a])
- remove old docs/src/research/devex.md (moved to docs/research/) ([4cfcc29])
- remove old docs/src/recipes/pr-validation.md (moved to docs/recipes/)
  ([83e5f83])
- remove old docs/src/usage/release.md (moved to docs/usage/) ([a7023bd])
- remove old docs/src/usage/commitlint.md (moved to docs/usage/) ([36ec7d6])
- remove old docs/src/getting-started.md (moved to docs/) ([4c14946])
- remove old docs/src/SUMMARY.md (moved to docs/) ([572c4e1])
- move book sources from docs/src/ to docs/ ([8b881ca])
- **recipes:** drop redundant `dry-run: false` from GitLab release example
  ([f16f939])
- lead each component example with canonical all-defaults form ([217aa31])
- **commitlint:** document `range` choice per GH event + edge cases ([1bc9457])

### Features

- **repo:** add standard-release bundled pipeline (GH reusable + GL component)
  ([559909b])

[415803b]: https://github.com/driftsys/ci/commit/415803b
[7dfe815]: https://github.com/driftsys/ci/commit/7dfe815
[6c599ac]: https://github.com/driftsys/ci/commit/6c599ac
[c8817b9]: https://github.com/driftsys/ci/commit/c8817b9
[d394133]: https://github.com/driftsys/ci/commit/d394133
[2526952]: https://github.com/driftsys/ci/commit/2526952
[13b76c2]: https://github.com/driftsys/ci/commit/13b76c2
[7ac0ac1]: https://github.com/driftsys/ci/commit/7ac0ac1
[4f8b2b1]: https://github.com/driftsys/ci/commit/4f8b2b1
[705e82c]: https://github.com/driftsys/ci/commit/705e82c
[91fab41]: https://github.com/driftsys/ci/commit/91fab41
[e9d3ed2]: https://github.com/driftsys/ci/commit/e9d3ed2
[742402a]: https://github.com/driftsys/ci/commit/742402a
[9a1ae43]: https://github.com/driftsys/ci/commit/9a1ae43
[f6be27a]: https://github.com/driftsys/ci/commit/f6be27a
[7050422]: https://github.com/driftsys/ci/commit/7050422
[922886b]: https://github.com/driftsys/ci/commit/922886b
[6fbaadc]: https://github.com/driftsys/ci/commit/6fbaadc
[f07b0b4]: https://github.com/driftsys/ci/commit/f07b0b4
[aabbd16]: https://github.com/driftsys/ci/commit/aabbd16
[5da3a00]: https://github.com/driftsys/ci/commit/5da3a00
[38f051a]: https://github.com/driftsys/ci/commit/38f051a
[4a1a125]: https://github.com/driftsys/ci/commit/4a1a125
[fdcdf43]: https://github.com/driftsys/ci/commit/fdcdf43
[bf1d8b9]: https://github.com/driftsys/ci/commit/bf1d8b9
[a546808]: https://github.com/driftsys/ci/commit/a546808
[393356a]: https://github.com/driftsys/ci/commit/393356a
[4cfcc29]: https://github.com/driftsys/ci/commit/4cfcc29
[83e5f83]: https://github.com/driftsys/ci/commit/83e5f83
[a7023bd]: https://github.com/driftsys/ci/commit/a7023bd
[36ec7d6]: https://github.com/driftsys/ci/commit/36ec7d6
[4c14946]: https://github.com/driftsys/ci/commit/4c14946
[572c4e1]: https://github.com/driftsys/ci/commit/572c4e1
[8b881ca]: https://github.com/driftsys/ci/commit/8b881ca
[f16f939]: https://github.com/driftsys/ci/commit/f16f939
[217aa31]: https://github.com/driftsys/ci/commit/217aa31
[1bc9457]: https://github.com/driftsys/ci/commit/1bc9457
[559909b]: https://github.com/driftsys/ci/commit/559909b
