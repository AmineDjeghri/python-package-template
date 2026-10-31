# Releases. The release workflows (main-release.yml, dev-release.yml) and a person on a laptop run
# the same targets, so a manual release and a GitHub Actions release are identical.
#
#   make release-version   # semantic-release: bump project.version, CHANGELOG.md, commit, tag v<version>, push, GitHub release
#   make release-assets    # attach dist/ wheel + sdist of that version to the GitHub release
#   make release           # all of it: release-version, then build-package and release-assets
#
# Needs a GitHub login with the repo scope: `gh auth login` once (or GH_TOKEN, which wins), the
# release branch (main or dev) checked out, clean and in sync with origin. Docs: docs/developer/5.release.md.

RED=\033[0;31m

.PHONY: release-version release-assets release

release-version: ## semantic-release on main/dev: version, CHANGELOG, commit, tag, push, GitHub release (nothing if no feat/fix/perf)
	@printf '%b\n' "${CYAN}=========> release-version...${NC}" >&2
	@branch=$$(git rev-parse --abbrev-ref HEAD); \
	case "$$branch" in main|dev) ;; *) printf '%b\n' "${RED}Release from main or dev only (on $$branch)${NC}"; exit 1 ;; esac; \
	if [ -n "$$(git status --porcelain)" ]; then printf '%b\n' "${RED}Uncommitted changes: commit or stash first${NC}"; exit 1; fi; \
	git fetch -q origin "$$branch" || { printf '%b\n' "${RED}git fetch origin $$branch failed${NC}"; exit 1; }; \
	if [ "$$(git rev-parse HEAD)" != "$$(git rev-parse "origin/$$branch")" ]; then printf '%b\n' "${RED}$$branch is not in sync with origin/$$branch: pull or push first${NC}"; exit 1; fi; \
	if [ -z "$$GH_TOKEN" ]; then GH_TOKEN=$$(gh auth token 2>/dev/null) || GH_TOKEN=""; fi; \
	if [ -z "$$GH_TOKEN" ]; then \
		if [ -t 0 ]; then echo "Not logged in: run 'gh auth login', or paste a token now."; printf "GitHub token (repo scope, input hidden): "; stty -echo; read -r GH_TOKEN; stty echo; echo; \
		else printf '%b\n' "${RED}No GitHub token: set GH_TOKEN or run gh auth login${NC}"; exit 1; fi; \
	fi; \
	export GH_TOKEN; \
	[ -n "$$GIT_COMMIT_AUTHOR" ] || GIT_COMMIT_AUTHOR="$$(git config user.name) <$$(git config user.email)>"; \
	export GIT_COMMIT_AUTHOR; \
	version=$$(PYTHONPATH=. $(UV) run --group dev semantic-release version --print 2>/dev/null | tr -d '[:space:]'); \
	if [ -z "$$version" ] || git rev-parse -q --verify "refs/tags/v$$version" >/dev/null; then \
		printf '%b\n' "${YELLOW}No releasable commit since the last tag (only chore/docs/refactor/...)${NC}"; \
		[ -z "$$GITHUB_OUTPUT" ] || echo "released=false" >> "$$GITHUB_OUTPUT"; exit 0; \
	fi; \
	GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=core.hooksPath GIT_CONFIG_VALUE_0=/dev/null \
		PYTHONPATH=. $(UV) run --group dev semantic-release -v version || exit 1; \
	printf '%b\n' "${GREEN}Released v$$version${NC}"; \
	[ -z "$$GITHUB_OUTPUT" ] || { echo "released=true"; echo "version=$$version"; } >> "$$GITHUB_OUTPUT"

release-assets: ## Attach dist/ wheel + sdist of the current version to the GitHub release v<version>
	@printf '%b\n' "${CYAN}=========> release-assets...${NC}" >&2
	@version=$$($(UV) version --short); dist=$$($(UV) version | awk '{print $$1}' | tr - _); \
	files="dist/$$dist-$$version-py3-none-any.whl dist/$$dist-$$version.tar.gz"; \
	for f in $$files; do [ -f "$$f" ] || { printf '%b\n' "${RED}$$f not found: run make build-package${NC}"; exit 1; }; done; \
	if ! gh release view "v$$version" >/dev/null 2>&1; then \
		printf '%b\n' "${YELLOW}No GitHub release v$$version yet: creating it${NC}"; \
		case "$$version" in *-*) pre="--prerelease" ;; *) pre="" ;; esac; \
		gh release create "v$$version" --verify-tag --generate-notes $$pre || exit 1; \
	fi; \
	gh release upload "v$$version" $$files --clobber && printf '%b\n' "${GREEN}Attached to v$$version: $$files${NC}"

release: ## Laptop: release-version, then build-package and release-assets (docs: make deploy-doc-gh)
	@printf '%b\n' "${CYAN}=========> release...${NC}" >&2
	@$(MAKE) -s release-version
	@version=$$($(UV) version --short); \
	if ! git tag --points-at HEAD | grep -qx "v$$version"; then printf '%b\n' "${YELLOW}Nothing released: stopping${NC}"; exit 0; fi; \
	$(MAKE) build-package release-assets && \
	printf '%b\n' "${GREEN}release complete${NC}" >&2
