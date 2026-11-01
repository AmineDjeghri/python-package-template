# Run targets
# This file contains targets for running the application

.PHONY: run

run: ## Run the Application
	@printf '%b\n' "${CYAN}Starting Application...${NC}" >&2
	@$(UV) run python src/python_package_template/example.py
	@printf '%b\n' "${GREEN}run complete${NC}" >&2
