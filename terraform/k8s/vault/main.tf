locals {
  namespace = "vault"
}

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

resource "helm_release" "vault" {
  name             = "vault"
  namespace        = local.namespace
  repository       = "helm.releases.hashicorp.com"
  chart            = "hashicorp/vault"
  version          = "0.27.0"
  create_namespace = true

  values = [
    file("${path.module}/values.yaml"),
    yamlencode(
      {
        global = {
          namespace = local.namespace
        }
      }
    )
  ]
}
