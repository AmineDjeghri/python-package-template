# Python Package Template

[![python](https://img.shields.io/badge/python-3.12--3.14.8-blue?logo=python)](https://www.python.org/downloads/)
[![Debian](https://img.shields.io/badge/Debian-A81D33?logo=debian&logoColor=fff)](https://www.debian.org/)
[![macOS](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=F0F0F0)](https://www.apple.com/macos/)
[![Style: Ruff](https://img.shields.io/badge/style-ruff-41B5BE?style=flat)](https://github.com/astral-sh/ruff)
[![mkdocs-material](https://img.shields.io/badge/Material_for_MkDocs-526CFE?logo=materialformkdocs&logoColor=white)](https://squidfunk.github.io/mkdocs-material/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=fff)](https://www.docker.com/)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?logo=github-actions&logoColor=white)](https://github.com/features/actions)

<img src="docs/images/logo.svg" alt="Python Package Template logo" width="160" />

A Python library template with uv, Pydantic settings, loguru, pytest, Ruff, Git hooks,
generated API docs and Conventional Commit releases. Supports Python 3.12–3.14.8.

## Get started

With Make, Bash, Git and uv available:

```bash
git clone https://github.com/AmineDjeghri/python-package-template.git
cd python-package-template
make install-dev
make pre-commit-install
make check
make run
```

This installs the editable package and tools, sets up hooks, validates the checkout and runs the example.
No live service or integration credentials are required. `make help` lists all commands.

## Use the package

Download a wheel from this repository's GitHub Releases, then install that file:

```bash
uv pip install "/path/to/python_package_template-<version>-py3-none-any.whl"
```

```python
from python_package_template.example import hello

hello()
```

Releases attach a wheel and sdist to GitHub and publish documentation on GitHub Pages;
this template does not publish to a package index.

## Guides

| Task                                             | Guide                                                                              |
|--------------------------------------------------|------------------------------------------------------------------------------------|
| Install tools, configure an editor or use Docker | [Setup](docs/developer/1.setup.md)                                                 |
| Add code or settings                             | [Project structure](docs/developer/2.project-structure.md)                         |
| Contribute a change                              | [Contributing](CONTRIBUTING.md) and [conventions](docs/developer/3.conventions.md) |
| Run tests and checks                             | [Testing](docs/developer/4.testing.md) and [test map](tests/README.md)             |
| Publish or retry a release                       | [Release](docs/developer/5.release.md)                                             |
| Start your own package                           | [Fork this template](docs/developer/6.fork.md)                                     |

Use `make deploy-doc-local` to preview the documentation.
For a frontend/backend application, see the
[Generative AI Project Template](https://github.com/AmineDjeghri/generative-ai-project-template).

Created by [Amine Djeghri](https://github.com/AmineDjeghri).
