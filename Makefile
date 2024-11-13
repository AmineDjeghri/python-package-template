ENV_FILE_PATH := .env
-include $(ENV_FILE_PATH) # keep the '-' to ignore this file if it doesn't exist.(Used in gitlab ci)

# Colors
GREEN=\033[0;32m
YELLOW=\033[0;33m
NC=\033[0m

NVM_USE := export NVM_DIR="$$HOME/.nvm" && . "$$NVM_DIR/nvm.sh" && nvm use
UV := "$$HOME/.local/bin/uv" # keep the quotes incase the path contains spaces

# installation
install-uv:
	@echo "${YELLOW}=========> installing uv ${NC}"
	@if [ -f $(UV) ]; then \
		echo "${GREEN}uv exists at $(UV) ${NC}"; \
		$(UV) self update; \
	else \
	     echo "${YELLOW}Installing uv${NC}"; \
		 curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="$$HOME/.local/bin" sh ; \
	fi

install-prod: install-uv
	@echo "${YELLOW}=========> Installing dependencies...${NC}"
	@$(UV) run hello
	@echo "${GREEN}Dependencies installed.${NC}"

install-dev: install-uv
	@echo "${YELLOW}=========> Installing dependencies...\n  \
	 Development dependencies will be installed by default in uv run and uv sync, but will not appear in the project's published metadata.${NC}"
	@$(UV) sync
	@echo "${GREEN}Dependencies installed.${NC}"

test-installation:
	@echo "${YELLOW}=========> Testing installation...${NC}"
	@$(UV) run --directory . hello

test:
	@echo "${YELLOW}Running tests...${NC}"
	@$(UV) run pytest tests


build-package:
	@echo "${YELLOW}=========> Building python package and wheel...${NC}"
	@$(UV) build


# git
#configure-git:
#	@echo "${YELLOW}=========> Configuring git and pre-commits ...${NC}"
#	git config --global commit.template $(realpath assets/commit-template.txt)
#	@echo "${GREEN}Git and pre-commits configured.${NC}"

pre-commit:
	@echo "${YELLOW}=========> Running pre-commit...${NC}"
	@$(UV) run pre-commit run --all-files


########### Docker & deployment
CONTAINER_NAME = python-package-template
export PROJECT_ROOT = $(shell pwd)
docker-build:
	@echo "${YELLOW}Building docker image...${NC}"
	docker build -t $(CONTAINER_NAME) -f docker/Dockerfile --progress=plain .
docker-prod: docker-build
	@echo "${YELLOW}Running docker for production...${NC}"
	docker run -it --rm --name $(CONTAINER_NAME)-prod $(CONTAINER_NAME) /bin/bash

# Developing in a container
docker-dev: docker-build
	@echo "${YELLOW}Running docker for development...${NC}"
	# Docker replaces the contents of the /app directory when you mount a project directory
	# need fix :  the .venv directory is unfortunately not retained in the container ( we need to solve it to retain it)
	docker run -it --rm -v $(PROJECT_ROOT):/app -v /app/.venv --name $(CONTAINER_NAME)-dev $(CONTAINER_NAME) /bin/bash

####### local CI / CD ########
# uv caching :
cache-uv:
	@echo "${YELLOW}=========> Caching uv...${NC}"
	@$(UV) cache prune --ci
# Github actions locally
install-act:
	@echo "${YELLOW}=========> Installing github actions act to test locally${NC}"
	curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/nektos/act/master/install.sh | bash
	@echo -e "${YELLOW}Github act version is :"
	@./bin/act --version

act:
	@echo "${YELLOW}Running Github Actions locally...${NC}"
	@./bin/act --env-file .env --secret-file .secrets

# Gitlab CI locally
###### Evaluation app ########
install-nvm:
	echo "${YELLOW}=========> Installing Evaluation app ${NC}"

	@if [ -d "$$HOME/.nvm" ]; then \
		echo "${YELLOW}NVM is already installed.${NC}"; \
	else \
		echo "${YELLOW}=========> Installing NVM...${NC}"; \
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash; \
	fi
	# Activate NVM (makefile runs in a subshell, always use this)
	@$(NVM_USE) && npm ci
	@echo "${GREEN} Restart your teminal to use nvm.${NC}"
install-gitlab-ci-local: install-nvm
    # gitlab-ci-local is an npm package and is installed within the install-evaluation-app step
	@echo "${GREEN}Installed gitlab-ci-local${NC}"

gitlab-ci-local:
	@echo "${YELLOW}Running Gitlab Runner locally...${NC}"
	@$(NVM_USE) && \
	./node_modules/.bin/gitlab-ci-local --network=host --variables-file .env

# clear GitHub and Gitlab CI local caches
clear_ci_cache:
	@echo "${YELLOW}Clearing CI cache...${NC}"
	@echo "${YELLOW}Clearing gitlab ci local cache...${NC}"
	rm -rf .gitlab-ci-local/cache
	@echo "${YELLOW}Clearing Github ACT local cache...${NC}"
	rm -rf ~/.cache/act ~/.cache/actcache



# This build the documentation based on current code 'src/' and 'docs/' directories
# This is to run the documentation locally to see how it looks
serve-docs: install-dev
	@echo "${YELLOW}Serving documentation locally...${NC}"

	@$(UV) run mkdocs build && $(UV) run mkdocs serve

# Deploy it to the gh-pages branch in your GitHub repository (you need to setup the GitHub Pages in github settings to use the gh-pages branch)
deploy-pages:
	@$(UV) run mkdocs build && $(UV) run mkdocs gh-deploy
