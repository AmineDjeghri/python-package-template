<div style="text-align: center;">

  <img src="./assets/icon.svg" width="200" />

  <h1>Python Package Template</h1>

  <p>This project is a template for a Python package.</p>
  <p>Check my <a href="https://github.com/AmineDjeghri/generative-ai-project-template">Generative AI Project Template</a></p>

  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="400" />

</div>

[![python](https://img.shields.io/badge/python-3.11+-blue?logo=python)](https://www.python.org/downloads/release/python-3110/)
[![Debian](https://img.shields.io/badge/Debian-A81D33?logo=debian&logoColor=fff)](https://www.debian.org/)
[![macOS](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=F0F0F0)](#)

[![Style: Ruff](https://img.shields.io/badge/style-ruff-41B5BE?style=flat)](https://github.com/charliermarsh/ruff)
[![MkDocs](https://img.shields.io/badge/MkDocs-526CFE?logo=materialformkdocs&logoColor=fff)](#)
[![mkdocs-material](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/juftin/mkdocs-material/66d65cf/src/templates/assets/images/badge.json)]()
[![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=fff)](#)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?logo=github-actions&logoColor=white)](#)


This package is a template for a python package.
This project uses [uv](https://docs.astral.sh/uv) for package management. We will follow the same naming conventions. For example, there is a difference between a library (package) project and an application project. This is a library (package) project.

It contains the following parts :

- **The Python package (python_package_template)**: contains the code for the project. It can be used by users by pip installing the wheel and is maintained by the maintainers.

- **Autogenerated documentation**: Docs made using MkDocs.


<div style="text-align: center;">
    <img src="assets/img.png" alt="site-img" width="800" style="display: block; margin: 0 auto; border: 2px solid grey;" />
</div>

## 👥  Authors
- (Author) Amine Djeghri

## 🧠 Features

**Engineering tools:**

- [x] Use UV to manage packages
- [x] pre-commit hooks: use ``ruff`` to ensure the code quality & ``detect-secrets`` to scan the secrets in the code.
- [x] Logging using loguru (with colors)
- [x] Pytest for unit tests
- [x] Dockerized project (Dockerfile) both for development and production
- [x] Make commands to handle everything for you: install, run, test

**CI/CD & Maintenance tools:**

- [x] CI/CD pipelines: ``.github/workflows`` for GitHub
- [x] Local CI/CD pipelines: GitHub Actions using ``github act``
- [x] GitHub Actions for deploying to GitHub Pages with mkdocs gh-deploy
- [x] Dependabot for automatic dependency and security updates

**Documentation tools:**

- [x] Wiki creation and setup of documentation website using Mkdocs
- [x] GitHub Actions for deploying to GitHub Pages with mkdocs gh-deploy


Upcoming features:
- [ ] optimize caching in CI/CD
- [ ] [Pull requests templates](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository)


## 1. Getting started

The following files are used in the contribution pipeline:

- ``.env.example``: example of the .env file.
- ``.env`` : contains the environment variables used by the app.
- ``Makefile``: contains the commands to run the app locally.
- ``Dockerfile``: the dockerfile used to build the project inside a container. It uses the Makefile commands to run the app.
- ``.pre-commit-config.yaml``: pre-commit hooks configuration file
- ``pyproject.toml``: contains the pytest, ruff & other configurations.
- ``src/python_package_tempalte/utils.py``: logger using logguru and settings  using pydantic.
  the frontend.
- `.github/workflows/**.yml`: GitHub actions configuration files.
- ``.github/dependabot.yml``: dependabot configuration file.
- ``.gitignore``: contains the files to ignore in the project.

### 1.1.  Local Prerequisites
- Ubuntu 22.04 or MacOS
- Python 3.11

### ⚙️ Steps for Installation (Users)
Use pip or uv pip to install the package :
```bash
pip install "dist/dist/python_package_template-0.1.0-py3-none-any.whl"
# or
uv pip install "dist/dist/python_package_template-0.1.0-py3-none-any.whl"
```

#### Usage

````python
from python_package_template.example import hello
hello()
# Output: 2025-01-05 08:05:38.143 | INFO     | python_package_template.example:hello:5 - Hello world
````

#### Check the documentation

You can check the documentation (website), or the ``notebook.ipynb``.

### 1.3 ⚙️ Steps for Installation (Contributors and maintainers)
Check the [CONTRIBUTING.md](CONTRIBUTING.md) file for installation instructions

## 2. Contributing
Check the [CONTRIBUTING.md](CONTRIBUTING.md) file for more information.
