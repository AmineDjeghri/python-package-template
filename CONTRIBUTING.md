# Contributing to this project

First off, thanks for taking the time to contribute! ❤️ Everyone taking part follows the
[Code of Conduct](CODE_OF_CONDUCT.md); report unacceptable behavior by opening an issue.

Team members: the contributors of the repository.

1. Set up once: [Setup](docs/developer/1.setup.md) (`make install-dev`, `make pre-commit-install`).
2. Comment on (or create) the issue, then branch off `dev` (`feature/<name>`, `bugfix/<name>`) and
   follow the [Conventions](docs/developer/3.conventions.md).
3. Before pushing: `make test-all` and `make pre-commit` ([Testing](docs/developer/4.testing.md)).
4. Open a pull request to `dev`. Its title follows the
   [commit convention](docs/developer/3.conventions.md#commit-convention): it decides the next
   version. Never edit the version or create a tag by hand.

Releases (by hand or by GitHub Actions): [Release](docs/developer/5.release.md).
Security issues: [SECURITY.md](SECURITY.md), never a public issue.
