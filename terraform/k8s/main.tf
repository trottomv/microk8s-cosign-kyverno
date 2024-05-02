terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }
}

provider "kubernetes" {
  host = var.kubernetes_host

  client_certificate     = base64decode(var.kubernetes_client_certificate)
  client_key             = base64decode(var.kubernetes_client_key)
  cluster_ca_certificate = base64decode(var.kubernetes_cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host = var.kubernetes_host

    client_certificate     = base64decode(var.kubernetes_client_certificate)
    client_key             = base64decode(var.kubernetes_client_key)
    cluster_ca_certificate = base64decode(var.kubernetes_cluster_ca_certificate)
  }
}

resource "helm_release" "reloader" {
  name       = "reloader"
  chart      = "reloader"
  repository = "https://stakater.github.io/stakater-charts"
}

resource "kubernetes_namespace_v1" "deployment" {
  metadata {
    name = var.deployment_namespace
  }
}

resource "kubernetes_secret_v1" "regcred" {
  metadata {
    name      = "regcred"
    namespace = var.deployment_namespace
  }
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.registry_server}" = {
          auth = "${base64encode("${var.registry_username}:${var.registry_password}")}"
        }
      }
    })
  }
  type = "kubernetes.io/dockerconfigjson"

  depends_on = [kubernetes_namespace_v1.deployment]
}

module "kyverno" {
  source = "./modules/kyverno"

  cosign_public_key = var.cosign_public_key

  registry_password = var.registry_password
  registry_server   = var.registry_server
  registry_username = var.registry_username
}

module "deployment" {
  source = "./modules/deployment"

  deployment_namespace    = var.deployment_namespace
  environment_slug        = var.environment_slug
  project_slug            = var.project_slug
  service_container_image = var.service_container_image
  service_container_port  = var.service_container_port
  service_replicas        = var.service_replicas
  service_slug            = var.service_slug

  depends_on = [kubernetes_secret_v1.regcred]
}
