# MicroK8s Setup

## Prerequisite

Clone this repository:
```shell
git clone git@gitlab.com:trottomv-group/microk8s-setup.git
```
Ensure that the following tools are installed on your machine:

- [Ansible](https://www.ansible.com/)
- [Cosign](https://docs.sigstore.dev/signing/quickstart/)
- [Docker](https://docs.docker.com/build/cloud/)
- [GitLab account](https://gitlab.com)
- [Make](https://www.gnu.org/software/make/)
- [Terraform](https://developer.hashicorp.com/terraform?product_intent=terraform)

## Setting up a Hetzner server (optional)

1. Obtain your Hetzner cloud token.

2. Duplicate the `terraform.tfvars_template` file
```shell
cp terraform/hetzner/terraform.tfvars_template terraform/hetzner/terraform.tfvars
```

3. Edit `terraform/hetzner/terraform.tfvars` and input the necessary variable values.

4. Execute the Hetzner provisioning process.
```shell
make hcloud
```

5. Once the provisioning is complete, retrieve the public IP address of your Hetzner Server (e.g., `12.34.56.78`). This IP address will be used to configure the provisioning of MicroK8s with Ansible.

## Setting up K8s cluster

1. Duplicate the `hosts_template` file
```shell
cp ansible/inventories/hosts_template ansible/inventories/hosts
```

2. Edit `ansible/inventories/hosts` and change values:
- host IP (e.g. `12.34.56.78`)
- ansible_user (e.g. `root`)
- ansible_ssh_private_key_file (e.g. `~/.ssh/id_rsa`)

3. Execute the MicroK8s setting up process with Ansible.
```shell
make install_kubernetes
```

## Configure terraform provisioning

1. Duplicate the `*.tfvars_template` files
```shell
cp terraform/k8s/vars/k8s.tfvars_template terraform/k8s/vars/k8s.tfvars
cp terraform/k8s/vars/regcred.tfvars_template terraform/k8s/vars/regcred.tfvars
cp terraform/k8s/vars/cosign.tfvars_template terraform/k8s/vars/cosign.tfvars
cp terraform/k8s/vars/deployment.tfvars_template terraform/k8s/vars/deployment.tfvars
```

2. Configure the kubernetes provider credentials
Obtain credentials
```shell
ssh root@12.34.56.78
microk8s config
```
Input the following variables with the right credentials in `terraform/k8s/vars/k8s.tfvars` file
```
kubernetes_client_certificate
kubernetes_client_key
kubernetes_cluster_ca_certificate
```

3. Obtain a GitLab personal access token with `api`, `read_api`, `read_registry` and `write_registry` scopes and input the right credentials in `terraform/k8s/vars/regcred.tfvars`
```
registry_password
registry_server
registry_username
```

4. Generate Cosign keys with provider GitLab (optional)
```shell
GITLAB_TOKEN=glpat-123AsD cosign generate-key-pair gitlab://<gitlab-project-id>
```
Input the `cosign_public_key` stored in GitLab CI CD variables in `terraform/k8s/vars/cosign.tfvars`

5. Edit all `terraform/k8s/vars/*.tfvars` files and input the necessary variable values.

## Setting Up Kyverno (optional)

```shell
make setup_kyverno
```

## Deployment

### Build demo app docker image

```shell
cd app
docker build --platform=linux/amd64 -t registry.gitlab.com/<path-to-your-gitlab-project>/app:v.1.0.0
docker login registry.gitlab.com
docker push registry.gitlab.com/<path-to-your-gitlab-project>/app:v.1.0.0
```

### Sign demo app docker image (optional)

If Kyverno and its policies have been installed in the Kubernetes cluster, images need to be signed with Cosign before they can be deployed.

```shell
GITLAB_TOKEN=glpat-123AsD cosign sign -key gitlab://<path-to-your-gitlab-project> registry.gitlab.com/<path-to-your-gitlab-project>/app:v.1.0.0
```

Otherwise, you will receive an error during deployment.

```error
╷
│ Error: Failed to update deployment: admission webhook "mutate.kyverno.svc-fail" denied the request:
│
│ resource Deployment/develop/app was blocked due to the following policies
│
│ check-signed-images:
│   autogen-check-signed-images: 'failed to verify image registry.gitlab.com/<path-to-your-gitlab-project>/app:v.1.0.0:
│     .attestors[0].entries[0].keys: no signatures found'
│
│
│   with kubernetes_deployment_v1.app,
│   on main.tf line 72, in resource "kubernetes_deployment_v1" "app":
│   72: resource "kubernetes_deployment_v1" "app" {
│
```

### Deploy demo app

1. Input the `service_container_image` in `terraform/k8s/vars/deployment.tfvars`
```
e.g.
service_container_image = "registry.gitlab.com/<path-to-your-gitlab-project>/app:v.1.0.0"
```

2. Input the `cosign_public_key` stored in GitLab CI CD variables in `terraform/k8s/vars/cosign.tfvars`
```
e.g.
cosign_public_key = "m2sOg6939F244zoN7QMKrPUFobpBuDePdiWzKbYUDUMqSrAiOBcpEIFa9h9lGEAt6UlbX5NvTRYpdXoBCI08S8X3ttyRSgQCWVLzY7aDiGrjYh3NJBbVvXKYD7/bKBtIbVkYq3LCgS6wTFE4DhxnQUXgySOY=="
```

3. Deploy MicroK8s resources
```shell
make deploy
```
