.DEFAULT_GOAL := help

.PHONY: check
check:  ## Check terraform files and configurations
	terraform -chdir=./terraform/hetzner/ init
	terraform -chdir=./terraform/hetzner/ validate
	terraform -chdir=./terraform/k8s/ init
	terraform -chdir=./terraform/k8s/ validate

.PHONY: deploy
deploy:  ## Deploy k8s
	terraform -chdir=./terraform/k8s/ init
	terraform -chdir=./terraform/k8s/ validate
	terraform -chdir=./terraform/k8s/ plan
	terraform -chdir=./terraform/k8s/ apply -auto-approve

.PHONY: fix
fix: check ## Fix terraform files and configurations
	terraform -chdir=./terraform/hetzner/ fmt
	terraform -chdir=./terraform/k8s/ fmt

.PHONY: hcloud
hcloud: ## Provisioning on Hetzner Cloud
	terraform -chdir=./terraform/hetzner/ init
	terraform -chdir=./terraform/hetzner/ validate
	terraform -chdir=./terraform/hetzner/ plan
	terraform -chdir=./terraform/hetzner/ apply -auto-approve

.PHONY: precommit
precommit:  ## Fix code formatting, linting and sorting imports
	pre-commit run --all-files

.PHONY: precommit_update
precommit_update:  ## Update pre_commit
	pre-commit autoupdate

.PHONY: setup_microk8s
setup_microk8s: ## Provisioning Setting up of MicroK8s on Hetzner Cloud
	ansible_playbook -i ./ansible/inventories/hosts ./ansible/setup_microk8s.yml

help:
	@echo "[Help] Makefile list commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
