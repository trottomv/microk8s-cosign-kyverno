.DEFAULT_GOAL := help

.PHONY: deploy
deploy:  ## Deploy k8s
	terraform -chdir=./terraform/k8s/ init
	terraform -chdir=./terraform/k8s/ validate
	terraform -chdir=./terraform/k8s/ plan
	terraform -chdir=./terraform/k8s/ apply -auto-approve

.PHONY: fix
fix:  ## Deploy k8s
	terraform -chdir=./terraform/k8s/ fmt

.PHONY: precommit
precommit:  ## Fix code formatting, linting and sorting imports
	pre-commit run --all-files

.PHONY: precommit_update
precommit_update:  ## Update pre_commit
	pre-commit autoupdate

help:
	@echo "[Help] Makefile list commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
