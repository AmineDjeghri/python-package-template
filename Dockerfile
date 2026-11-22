# Development image: `make docker-dev` opens a shell with this project mounted in /app.
# PYTHON_VERSION: any version allowed by `requires-python` in pyproject.toml; Renovate proposes
# updates in its "python runtime" group.
ARG PYTHON_VERSION=3.14.7
FROM python:${PYTHON_VERSION}-slim

# uv, and make to run the project's make targets (git for the pre-commit hooks)
COPY --from=ghcr.io/astral-sh/uv:0.13.6 /uv /uvx /usr/local/bin/
RUN apt-get update && apt-get install -y --no-install-recommends make git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# The environment lives outside /app, so mounting the project does not hide it
WORKDIR /app
ENV UV_PROJECT_ENVIRONMENT=/opt/venv \
    PATH="/opt/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# The whole project: the dev tools, tests and docs need it (.dockerignore keeps .env out)
COPY . ./
RUN make install-dev

CMD ["bash"]
