.PHONY: help
.DEFAULT_GOAL := help

# -- global targets--
## This help screen
help:
	@echo "Available targets:"
	@awk '/^[a-zA-Z\-\_0-9%:\\ ]+/ { \
	  helpMessage = match(lastLine, /^## (.*)/); \
	  if (helpMessage) { \
	    helpCommand = $$1; \
	    helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
	    gsub("\\\\", "", helpCommand); \
	    gsub(":+$$", "", helpCommand); \
	    printf "  \x1b[32;01m%-35s\x1b[0m %s\n", helpCommand, helpMessage; \
	  } \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST) | sort -u


# Check if poetry is installed
ensure-poetry:
	@command -v poetry >/dev/null 2>&1 || { echo >&2 "Poetry is not installed. Aborting."; exit 1; }

# Check for uncommitted changes
ensure-clean:
	@if ! git diff-index --quiet HEAD -- || ! git diff --staged --quiet; then \
		echo "Uncommitted or unstaged changes found. Please commit and stage your changes."; \
		exit 1; \
	fi

# Check if current branch is dev
ensure-dev-branch:
	@if [ "$(shell git rev-parse --abbrev-ref HEAD)" != "dev" ]; then \
		echo "Current branch is not dev. Please switch to the dev branch."; \
		exit 1; \
	fi



# -- Dependency --

## Install dependencies
install: ensure-poetry
	poetry install

## Update dependencies
showdeps: ensure-poetry
	@echo "CURRENT:"
	poetry show --tree
	@echo
	@echo "LATEST:"
	poetry show --latest

## Export dependencies to requirements.txt
requirements: ensure-poetry
	@echo "Exporting dependencies to requirements.txt..."
	@poetry export --only main -f requirements.txt --output requirements/requirements.txt --without-hashes
	@poetry export --only dev -f requirements.txt --output requirements/dev-requirements.txt --without-hashes
	@echo "Done!"




# -- Git and Github --
## Run pre-commit hooks
pre-commit:
	@echo "Running pre-commit..."
	@pre-commit run --all-files
	@echo "Done!"


## Push current branch
push: ensure-clean
	@BRANCH_NAME=$(shell git rev-parse --abbrev-ref HEAD); \
	echo "Pushing to $$BRANCH_NAME branch..."; \
	git push origin $$BRANCH_NAME; \
	if [[ $$BRANCH_NAME == release-* ]] || [[ $$BRANCH_NAME == hotfix-* ]]; then \
		TAG_NAME=$(shell git describe --tags --abbrev=0); \
		echo "Pushing $$TAG_NAME tag..."; \
		git push origin $$TAG_NAME --force-with-lease; \
	fi; \
	echo "Done!";




## Create PR to dev branch
prdev: ensure-clean
	@CURRENT_BRANCH=$(shell git rev-parse --abbrev-ref HEAD); \
	if [[ "$$CURRENT_BRANCH" == release/* ]] || [[ "$$CURRENT_BRANCH" == hotfix/* ]]; then \
		read -p "You are on a $$CURRENT_BRANCH branch. It's recommended to PR release and hotfix branches to main. Do you want to continue creating a PR to dev? (y/N): " confirm; \
		[[ -z "$$confirm" ]] && confirm="N"; \
		[[ $$confirm == [yY] || $$confirm == [yY][eE][sS] ]] || exit 1; \
	fi; \
	echo "Creating PR from $$CURRENT_BRANCH to dev branch..."; \
	gh pr create --base dev --head $$CURRENT_BRANCH; \
	echo "Done!";




## Remove current branch and checkout dev
remove-branch: ensure-clean
	@BRANCH_TO_DELETE=$(shell git rev-parse --abbrev-ref HEAD); \
	echo "Branch to delete: $$BRANCH_TO_DELETE"; \
	if [ "$$BRANCH_TO_DELETE" = "main" ] || [ "$$BRANCH_TO_DELETE" = "dev" ] || [ "$$BRANCH_TO_DELETE" = "release" ] || [[ "$$BRANCH_TO_DELETE" == project* ]]; then \
		echo "Cannot delete branch $$BRANCH_TO_DELETE."; \
	elif [ "$$(git rev-list $$BRANCH_TO_DELETE..origin/$$BRANCH_TO_DELETE --count)" != "0" ]; then \
		echo "Unpushed changes found. Please push your changes before deleting the branch."; \
	else \
		git checkout dev; \
		git push origin -d $$BRANCH_TO_DELETE; \
		git branch -D $$BRANCH_TO_DELETE; \
		echo "Branch $$BRANCH_TO_DELETE deleted."; \
		echo "Done!"; \
	fi

## Create PR to main branch from release or hotfix branch
pr: ensure-clean
	@CURRENT_BRANCH=$(shell git rev-parse --abbrev-ref HEAD); \
	if [[ "$$CURRENT_BRANCH" == release/* ]] || [[ "$$CURRENT_BRANCH" == hotfix/* ]]; then \
		echo "Creating PR from $$CURRENT_BRANCH to main branch..."; \
		gh pr create -f --base main --head $$CURRENT_BRANCH; \
		echo "Done!"; \
	else \
		echo "Current branch is not a release or hotfix branch. Please switch to a release or hotfix branch before creating a PR to main."; \
	fi

## Set or bump the version using bv utility
version:
	@if [ ! -f pyproject.toml ]; then \
		echo "Error: pyproject.toml file not found in the current directory."; \
		exit 1; \
	fi; \
	current_version=$$(poetry version -s); \
	echo "Current version: $$current_version"; \
	read -p "Enter new version type (major, minor, micro, a, b, rc, post, dev): " version_type; \
	if [ "$$version_type" ]; then \
		poetry run bv $$version_type; \
		new_version=$$(poetry version -s); \
		echo "Version bumped to: $$new_version"; \
	else \
		echo "No version type provided. Version remains unchanged."; \
	fi




# -- Code Quality --

## Clean Python cache files
clean:
	@echo "Cleaning Python cache files..."
	@find . -type d -name "__pycache__" -exec rm -rf {} +
	@find . -type f -name "*.pyc" -delete
	@find . -type f -name "*.pyo" -delete
	@echo "Done!"

## Linting code (ruff, isort)
lint: ensure-poetry
	@echo "Linting code..."
	@poetry run ruff check .
	@poetry run black .
	@poetry run isort .
	@poetry run flake8 .
	@echo "Done!"

## Test code (pytest)
test-py: ensure-poetry
	@echo "Running pytest..."
	@poetry run python -m pytest
	@echo "Done!"


## Test code (pytest+django)
# we simply call pytest and some other test targets if you have
test: ensure-poetry test-py
