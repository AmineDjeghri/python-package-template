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
	 Development dependencies (dev & docs) are installed by default in uv run and uv sync.${NC}"
	@$(UV) sync
	@echo "${GREEN}Dependencies installed.${NC}"

pre-commit-install:
	@echo "${YELLOW}=========> Installing pre-commit...${NC}"
	$(UV) run pre-commit install
pre-commit:
	@echo "${YELLOW}=========> Running pre-commit...${NC}"
	$(UV) run pre-commit run --all-files

###### NVM & npm packages ########
install-nvm:
	echo "${YELLOW}=========> Installing Evaluation app $(NC)"

	@if [ -d "$$HOME/.nvm" ]; then \
		echo "${YELLOW}NVM is already installed.${NC}"; \
		$(NVM_USE) --version; \
	else \
		echo "${YELLOW}=========> Installing NVM...${NC}"; \
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash; \
	fi

	# Activate NVM (makefile runs in a subshell, always use this)
	@echo "${YELLOW}Restart your terminal to use nvm.  If you are on MacOS, run nvm ls, if there is no node installed, run nvm install ${NC}"
	@bash -c ". $$HOME/.nvm/nvm.sh; nvm install"

install-npm-dependencies: install-nvm
	@echo "${YELLOW}=========> Installing npm packages...${NC}"
	@$(NVM_USE) && npm ci
	@echo "${GREEN} Installation complete ${NC}"


####### local CI / CD ########
# uv caching :
prune-uv:
	@echo "${YELLOW}=========> Prune uv cache...${NC}"
	@$(UV) cache prune
# clean uv caching
clean-uv-cache:
	@echo "${YELLOW}=========> Cleaning uv cache...${NC}"
	@$(UV) cache clean

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
GITLAB_CI_LOCAL_CMD=./node_modules/.bin/gitlab-ci-local
install-gitlab-ci-local: install-npm-packages
    # gitlab-ci-local is an npm package and is installed within the install-evaluation-app step
	@echo "${GREEN}Installed gitlab-ci-local${NC}"
	@echo "${GREEN}gitlab-ci-local version is $$($(NVM_USE) > /dev/null && $(GITLAB_CI_LOCAL_CMD) --version | tail -n 1) ${NC}"
gitlab-ci-local:
	@echo "${YELLOW}Running Gitlab Runner locally...${NC}"
	@$(NVM_USE) && $(GITLAB_CI_LOCAL_CMD) --network=host --variables-file .env

# clear GitHub and Gitlab CI local caches
clear_ci_cache:
	@echo "${YELLOW}Clearing CI cache...${NC}"
	@echo "${YELLOW}Clearing gitlab ci local cache...${NC}"
	rm -rf .gitlab-ci-local/cache
	@echo "${YELLOW}Clearing Github ACT local cache...${NC}"
	rm -rf ~/.cache/act ~/.cache/actcache


######## Tests ########
test-installation:
	@echo "${YELLOW}=========> Testing installation...${NC}"
	@$(UV) run --directory . hello

test:
	@echo "${YELLOW}Running tests...${NC}"
	@$(UV) run pytest tests


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


######## Builds ########
# build package (wheel)
build-package:
	@echo "${YELLOW}=========> Building python package and wheel...${NC}"
	@$(UV) build

# This build the documentation based on current code 'src/' and 'docs/' directories
# This is to run the documentation locally to see how it looks
deploy-doc-local:
	@echo "${YELLOW}Deploying documentation locally...${NC}"
	@$(UV) run mkdocs build && $(UV) run mkdocs serve

# Deploy it to the gh-pages branch in your GitHub repository (you need to setup the GitHub Pages in github settings to use the gh-pages branch)
deploy-doc-gh:
	@echo "${YELLOW}Deploying documentation in github actions..${NC}"
	@$(UV) run mkdocs build && $(UV) run mkdocs gh-deploy
