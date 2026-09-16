# Testing targets
# This file contains all testing-related targets

.PHONY: test-installation test

N ?= 4

test-installation: ## Test installation
	@echo "${YELLOW}=========> Testing installation...${NC}"
	@$(UV) run --directory . hello

test: ## Run tests with pytest (parallel via pytest-xdist). Usage: make test [N=<num_workers>] (default: 4)
	@echo "${YELLOW}Running tests with $(N) worker(s)...${NC}"
	@set -e; \
	$(UV) run pytest tests --numprocesses=$(N) || rc=$$?; \
	if [ "$${rc:-0}" -eq 5 ]; then \
		echo "${YELLOW}No tests collected (pytest exit code 5) — treating as success.${NC}"; \
	else \
		exit "$${rc:-0}"; \
	fi
