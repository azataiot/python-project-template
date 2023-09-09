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

## Set or bump the version
version:
	@if [ ! -f .VERSION ]; then \
		echo "0.0.1" > .VERSION; \
		echo "No current version found. Created version 0.0.1"; \
	fi; \
	echo "Current version: $$(cat .VERSION)"; \
	read -p "Enter new version: " new_version; \
	if [ "$$new_version" ]; then \
		echo "$$new_version" > .VERSION; \
		echo "Version set to $$new_version"; \
		git add .VERSION; \
		git commit -m "Bump version to $$new_version"; \
	else \
		echo "No version input provided. Version remains unchanged."; \
	fi
