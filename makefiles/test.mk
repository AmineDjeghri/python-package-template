N ?= 4

.PHONY: check test-local test-all test-unit test-smoke-cli test-installation

check: ## Run static checks, comprehensive software validation and strict docs
	@$(MAKE) pre-commit
	@$(MAKE) test-all
	@$(MAKE) docs-build

test-local: test-unit ## Run all self-contained software tests

test-all: ## Run every existing software suite (no integration tests exist yet)
	$(if $(strip $(ARGS)),$(error test-all requires the full suite; use a focused target for ARGS))
	@$(MAKE) test-local

test-unit: ## Run package unit tests with pytest (N=4 workers; empty selection fails)
	@$(UV) run pytest tests --numprocesses=$(N) $(ARGS)

test-smoke-cli: ## Run hello from the development environment (does not validate a built wheel)
	@$(UV) run --directory . hello

# Compatibility name; use test-smoke-cli.
test-installation: test-smoke-cli
