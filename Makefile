.DEFAULT_GOAL := help

.PHONY: check
check:  ## Check terraform files and configurations
	terraform -chdir=./terraform/hetzner/ init
	terraform -chdir=./terraform/hetzner/ validate
	terraform -chdir=./terraform/k8s/kyverno/ init
	terraform -chdir=./terraform/k8s/kyverno/ validate
	terraform -chdir=./terraform/k8s/kyverno-policies/ init
	terraform -chdir=./terraform/k8s/kyverno-policies/ validate
	terraform -chdir=./terraform/k8s/deployment/ init
	terraform -chdir=./terraform/k8s/deployment/ validate

.PHONY: deploy
deploy:  ## Deploy k8s
	terraform -chdir=./terraform/k8s/deployment/ init
	terraform -chdir=./terraform/k8s/deployment/ validate
	terraform -chdir=./terraform/k8s/deployment/ plan -var-file=../vars/k8s.tfvars -var-file=../vars/deployment.tfvars -var-file=../vars/regcred.tfvars
	terraform -chdir=./terraform/k8s/deployment/ apply -auto-approve -var-file=../vars/k8s.tfvars -var-file=../vars/deployment.tfvars -var-file=../vars/regcred.tfvars

.PHONY: fix
fix: check  ## Fix terraform files and configurations
	terraform -chdir=./terraform/hetzner/ fmt
	terraform -chdir=./terraform/k8s/kyverno/ fmt
	terraform -chdir=./terraform/k8s/kyverno-policies/ fmt
	terraform -chdir=./terraform/k8s/deploymnet/ fmt

.PHONY: hcloud
hcloud:  ## Provisioning the Hetzner Cloud server
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

.PHONY: setup_kyverno
setup_kyverno:  ## Setting up Kyverno on K8s cluster
	terraform -chdir=./terraform/k8s/kyverno/ init
	terraform -chdir=./terraform/k8s/kyverno/ validate
	terraform -chdir=./terraform/k8s/kyverno/ plan -var-file=../vars/k8s.tfvars
	terraform -chdir=./terraform/k8s/kyverno/ apply -auto-approve -var-file=../vars/k8s.tfvars
	terraform -chdir=./terraform/k8s/kyverno-policies/ init
	terraform -chdir=./terraform/k8s/kyverno-policies/ validate
	terraform -chdir=./terraform/k8s/kyverno-policies/ plan -var-file=../vars/k8s.tfvars -var-file=../vars/regcred.tfvars -var-file=../vars/cosign.tfvars
	terraform -chdir=./terraform/k8s/kyverno-policies/ apply -auto-approve -var-file=../vars/k8s.tfvars -var-file=../vars/regcred.tfvars -var-file=../vars/cosign.tfvars

.PHONY: setup_vault
setup_vault:  ## Setting up Hashicopr Vault on K8s cluster
	terraform -chdir=./terraform/k8s/vault/ init
	terraform -chdir=./terraform/k8s/vault/ validate
	terraform -chdir=./terraform/k8s/vault/ plan -var-file=../vars/k8s.tfvars
	terraform -chdir=./terraform/k8s/vault/ apply -auto-approve -var-file=../vars/k8s.tfvars

.PHONY: setup_kubernetes
setup_kubernetes:  ## Setting up MicroK8s cluster on server
	ansible-playbook -i ./ansible/inventories/hosts ./ansible/playbooks/install_microk8s.yaml

help:
	@echo "[Help] Makefile list commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
