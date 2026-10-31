# Contributing

1. Follow [Setup](docs/developer/1.setup.md), then coordinate on an issue.
2. Branch from `dev`: `feature/<name>` or `bugfix/<name>`.
3. Update the relevant docs and run `make check` ([Testing](docs/developer/4.testing.md)).
4. Open a PR to `dev` using a [Conventional Commit title](docs/developer/3.conventions.md#commit-convention).
   PRs are squash-merged; the title determines the version.

See [Release](docs/developer/5.release.md) for publication and recovery.
Coding agents need explicit approval for commits, pushes and publishing.
Follow the [Code of Conduct](CODE_OF_CONDUCT.md); report security issues through
[SECURITY.md](SECURITY.md), never a public issue.
