# CLAUDE.md

Guidance for Claude Code (claude.ai/code) in this repository.

## What this repo is

A template for a Python package (library), managed with uv: `src/python_package_template/`
(pydantic-settings + loguru in `settings.py`), tests, a documentation site (properdocs / MkDocs
Material) and semantic-release. A release is a GitHub release (wheel + sdist) plus the
documentation on GitHub Pages; there is no package index. Developer docs: `docs/developer/`.

## Commands

```bash
make install-dev          # .venv with dev and docs tools
make pre-commit-install   # git hooks
make test-all                 # required comprehensive software validation
make pre-commit           # static hooks; make test-all remains required
make run                  # run the example
make build-package        # dist/ wheel + sdist
make deploy-doc-local     # build and serve the documentation
make release-version      # build packages, semantic-release: version, CHANGELOG, tag, GitHub release (main/dev, clean, in sync)
make release-assets       # attach dist/ to the GitHub release
make release              # release-version + verified release-assets (manual release)
make deploy-doc-gh        # documentation to GitHub Pages
```

## Rules

- Use the `make` targets; workflows call `make`, never re-implement a step. A manual release and
  a GitHub Actions release run the same targets (`makefiles/release.mk`).
- Never commit, push, tag, create a GitHub release, run `make release*` / `make deploy-doc-gh` or
  `gh workflow run` without asking first.
- `make release-version` must keep its guards: branch `main` or `dev`, clean tree, in sync with
  `origin`, token from `GH_TOKEN`, then `gh auth login`, then a prompt. Never print a credential.
- Versions, tags and `CHANGELOG.md` belong to semantic-release (Conventional Commits,
  `docs/developer/3.conventions.md`): never edit `project.version` by hand.
- Settings in `ApplicationSettings`; secrets as `SecretStr`, set by environment or `.env`, never in
  a file of the repository. A new or renamed environment variable also goes in `.env.example` and,
  if CI needs it, in the workflow `env:`.
- Logging with the package's loguru logger (`from python_package_template.settings import logger`).
- Tests run in parallel (pytest-xdist): no shared state between tests.
- Docs: numbered pages in `docs/developer/`, one purpose line, numbered steps, short tables, no
  long prose. Keep `properdocs.yml` nav and the README table in step.

## Required software validation

`make test-all` is the required comprehensive software check for users, developers and CI.
`make test-local` is only a focused diagnostic command. A local-only pass, integration collection,
or skipped/unavailable integration does not establish full validation. Keep coverage and artifact/runtime
checks explicit alongside software validation. Never execute live authentication/integration without
the user's authorization; if it was not authorized or services are unavailable, report full validation
as incomplete instead of claiming the change fully verified.
