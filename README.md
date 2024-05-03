# MicroK8s Setup

## Provisioning

### Prerequisite

Clone this repository:
```shell
git clone git@gitlab.com:trottomv-group/microk8s-setup.git
```
Ensure that the following tools are installed on your machine:

- ansible
- cosign
- docker
- Gitlab account
- make
- terraform

### Setting up a Hetzner server (optional)

1. Obtain your Hetzner cloud token.
2. Duplicate the `template.tfvars` file
```shell
cp terraform/hetzner/template.tfvars terraform/hetzner/terraform.tfvars
```
3. Edit `terraform/hetzner/terraform.tfvars` and input the necessary variable values.
4. Execute the Hetzner provisioning process.
```shell
make hcloud
```
5. Once the provisioning is complete, retrieve the public IP address of your Hetzner Server (e.g., `12.34.56.78`). This IP address will be used to configure the provisioning of MicroK8s with Ansible.

### Setting up MicroK8s

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
make setup_microk8s
```

## Deployment

### Configure deployment

1. Duplicate the `template.tfvars` file
```shell
cp terraform/k8s/template.tfvars terraform/k8s/terraform.tfvars
```
2. Edit `terraform/k8s/terraform.tfvars` and input the necessary variable values.

### Build demo app docker image

```shell
cd app
docker build --platform=linux/amd64 -t registry.gitlab.com/<path-to-your-gitlab-project>/app:v.1.0.0
docker login registry.gitlab.com
docker push registry.gitlab.com/<path-to-your-gitlab-project>/app:v.1.0.0
```

### Sign demo app image

```shell
cosign generate-key-pair gitlab://<gitlab-project-id>
cosign sign -key gitlab://<path-to-your-gitlab-project> registry.gitlab.com/<path-to-your-gitlab-project>/app:v.1.0.0
```

### Deploy demo app

1. Input the `service_container_image` in `terraform/k8s/terraform.tfvars`
```
e.g.
service_container_image = "registry.gitlab.com/<path-to-your-gitlab-project>/app:v.1.0.0"
```
2. Input the `cosign_public_key` stored in gitlab CI CD variables in `terraform/k8s/terraform.tfvars`
```
e.g.
cosign_public_key = "m2sOg6939F244zoN7QMKrPUFobpBuDePdiWzKbYUDUMqSrAiOBcpEIFa9h9lGEAt6UlbX5NvTRYpdXoBCI08S8X3ttyRSgQCWVLzY7aDiGrjYh3NJBbVvXKYD7/bKBtIbVkYq3LCgS6wTFE4DhxnQUXgySOY=="
```
3. Deploy microk8s resources
```shell
make deploy
```
