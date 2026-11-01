# Installation targets
# This file contains all installation-related targets

.PHONY: install-uv install-dev install-tools install-release

install-tools: ## Install quality and docs tools without application dependencies
	@$(UV) sync --only-group dev --only-group docs $(UV_SYNC_FLAGS)

install-release: ## Install release tools without application dependencies
	@$(UV) sync --only-group dev $(UV_SYNC_FLAGS)

install-uv: ## Install uv
	@printf '%b\n' "${CYAN}=========> installing uv ${NC}" >&2
ifeq ($(OS),Windows_NT)
	@powershell -NoProfile -ExecutionPolicy Bypass -Command "\
		$$ErrorActionPreference = 'Stop'; \
		$$uv = Get-Command uv -ErrorAction SilentlyContinue; \
		if ($$uv) { \
		  Write-Host 'uv exists at' $$uv.Source -ForegroundColor Green; \
		  uv --version; \
		} else { \
		  Write-Host 'Installing uv' -ForegroundColor Yellow; \
		  irm https://astral.sh/uv/install.ps1 | iex; \
		}"
else
	@if command -v uv >/dev/null 2>&1; then \
		printf '%b\n' "${GREEN}uv exists at $$(command -v uv) ${NC}"; \
		$(UV) --version; \
	else \
		printf '%b\n' "${YELLOW}Installing uv${NC}"; \
		curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="$$HOME/.local/bin" sh; \
	fi
endif
	@printf '%b\n' "${GREEN}install-uv complete${NC}" >&2

install-dev: ## Install all dev dependencies
	@printf '%b\n' "${CYAN}=========> install-dev...${NC}" >&2
	@printf '%b\n' "${YELLOW}=========> Installing dependencies...\n  \
	 Development dependencies (dev & docs) will be installed by install-dev.${NC}"
	@$(UV) sync --all-groups $(UV_SYNC_FLAGS)
	@printf '%b\n' "${GREEN}Dependencies installed.${NC}"
	@printf '%b\n' "${GREEN}install-dev complete${NC}" >&2

install-prod: ## Install prod dependencies only
	@printf '%b\n' "${CYAN}=========> Installing dependencies (PROD)...${NC}" >&2
	@$(UV) sync
	@printf '%b\n' "${GREEN}Dependencies installed.${NC}"
	@printf '%b\n' "${GREEN}install-prod complete${NC}" >&2
