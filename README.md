# driftsys/ci

Reusable **GitHub Actions** and **GitLab CI components** for the driftsys org.

Canonical repo: <https://github.com/driftsys/ci>. Mirrored to GitLab so GitLab
components can be exercised on real pipelines.

## Components

| Name       | GH Action                        | GitLab Component            |
| ---------- | -------------------------------- | --------------------------- |
| commitlint | `driftsys/ci/actions/commitlint` | `driftsys/ci/commitlint`    |
| bump-push  | `driftsys/ci/actions/bump-push`  | `driftsys/ci/bump-push`     |

See the [user guide](https://driftsys.github.io/ci) for usage and recipes.

## Local development

```sh
chmod +x bootstrap && ./bootstrap  # install git-std + hooks (first clone only)
just --list                         # see available recipes
just verify                         # run before PR (also enforced by pre-push hook)
```

## License

MIT — see [LICENSE](LICENSE).
