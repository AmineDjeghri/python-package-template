# Installation targets
# This file contains all installation-related targets

.PHONY: docker-build docker-prod docker-dev docker-github-actions

########### Docker & deployment
CONTAINER_NAME = python-package-template
export PROJECT_ROOT = $(shell pwd)

docker-build: ## Build Docker image
	@printf '%b\n' "${CYAN}Building docker image...${NC}" >&2
	@docker build -t $(CONTAINER_NAME) --progress=plain .
	@printf '%b\n' "${GREEN}docker-build complete${NC}" >&2

docker-prod: docker-build ## Run Docker container for production
	@printf '%b\n' "${CYAN}Running docker for production...${NC}" >&2
	@docker run -it --rm --name $(CONTAINER_NAME)-prod $(CONTAINER_NAME) /bin/bash
	@printf '%b\n' "${GREEN}docker-prod complete${NC}" >&2

docker-dev: docker-build ## Run Docker container for development
	@printf '%b\n' "${CYAN}Running docker for development...${NC}" >&2
	# Docker replaces the contents of the /app directory when you mount a project directory
	# need fix :  the .venv directory is unfortunately not retained in the container ( we need to solve it to retain it)
	@docker run -it --rm -v $(PROJECT_ROOT):/app -v /app/.venv --name $(CONTAINER_NAME)-dev $(CONTAINER_NAME) /bin/bash
	@printf '%b\n' "${GREEN}docker-dev complete${NC}" >&2

docker-github-actions: docker-build ## Run Docker container for GitHub Actions
	@printf '%b\n' "${CYAN}Running docker for github actions...${NC}" >&2
	@docker run --rm --name $(CONTAINER_NAME)-prod $(CONTAINER_NAME) /bin/bash
	@printf '%b\n' "${GREEN}docker-github-actions complete${NC}" >&2
