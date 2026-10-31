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

test-installation: build-package ## Install the built wheel in a throwaway env and check the hello command loads
	@wheel=$$(ls -t dist/*.whl | head -1); \
	$(UV) run --isolated --no-project --with "$$wheel" python -c \
		"from importlib.metadata import entry_points; ep = entry_points(group='console_scripts')['hello']; ep.load(); print('OK', ep.name, '->', ep.value)"

test-smoke-cli: test-installation ## Alias of test-installation (kept for compatibility)
