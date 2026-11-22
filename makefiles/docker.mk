# Docker targets
# This file contains the targets to build and use the development image

.PHONY: docker-build docker-prod docker-dev

CONTAINER_NAME = python-package-template
export PROJECT_ROOT = $(shell pwd)

docker-build: ## Build the development image
	@printf '%b\n' "${CYAN}Building docker image...${NC}" >&2
	@docker build -t $(CONTAINER_NAME) --progress=plain .
	@printf '%b\n' "${GREEN}docker-build complete${NC}" >&2

docker-prod: docker-build ## Open a shell in the built image (project copied at build time)
	@printf '%b\n' "${CYAN}Opening a shell in the image...${NC}" >&2
	@docker run -it --rm --name $(CONTAINER_NAME)-prod $(CONTAINER_NAME)

docker-dev: docker-build ## Open a shell with this project mounted in /app
	@printf '%b\n' "${CYAN}Opening a shell with the project mounted...${NC}" >&2
	@docker run -it --rm -v $(PROJECT_ROOT):/app --name $(CONTAINER_NAME)-dev $(CONTAINER_NAME)
