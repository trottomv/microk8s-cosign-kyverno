locals {
  dev_namespace = "develop"

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

resource "kubernetes_namespace_v1" "dev" {
  metadata {
    name = local.dev_namespace
  }
}

resource "helm_release" "kyverno" {
  name             = "kyverno"
  namespace        = "kyverno"
  repository       = "https://kyverno.github.io/kyverno/"
  chart            = "kyverno"
  create_namespace = true
}

resource "helm_release" "kyverno-policies" {
  name       = "kyverno-policies"
  namespace  = "kyverno"
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno-policies"
  depends_on = [helm_release.kyverno]
}
