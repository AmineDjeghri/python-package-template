# Installation targets
# This file contains all installation-related targets

.PHONY: docker-build docker-prod docker-dev docker-github-actions

########### Docker & deployment
CONTAINER_NAME = python-package-template
export PROJECT_ROOT = $(shell pwd)

docker-build: ## Build Docker image
	@echo "${YELLOW}Building docker image...${NC}"
	docker build -t $(CONTAINER_NAME) --progress=plain .

docker-prod: docker-build ## Run Docker container for production
	@echo "${YELLOW}Running docker for production...${NC}"
	docker run -it --rm --name $(CONTAINER_NAME)-prod $(CONTAINER_NAME) /bin/bash

docker-dev: docker-build ## Run Docker container for development
	@echo "${YELLOW}Running docker for development...${NC}"
	# Docker replaces the contents of the /app directory when you mount a project directory
	# need fix :  the .venv directory is unfortunately not retained in the container ( we need to solve it to retain it)
	docker run -it --rm -v $(PROJECT_ROOT):/app -v /app/.venv --name $(CONTAINER_NAME)-dev $(CONTAINER_NAME) /bin/bash

docker-github-actions: docker-build ## Run Docker container for GitHub Actions
	@echo "${YELLOW}Running docker for github actions...${NC}"
	docker run --rm --name $(CONTAINER_NAME)-prod $(CONTAINER_NAME) /bin/bash
