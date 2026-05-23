# Run targets
# This file contains targets for running the application

.PHONY: run

run: ## Run the Application
	@echo "Starting Application..."
	@$(UV) run python src/python_package_template/example.py
