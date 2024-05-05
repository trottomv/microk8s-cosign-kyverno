locals {
  namespace = "kyverno"
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

resource "helm_release" "kyverno-policies" {
  name       = "kyverno-policies"
  namespace  = local.namespace
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno-policies"
}

resource "kubernetes_secret_v1" "kyverno-regcred" {
  metadata {
    name      = "kyverno-regcred"
    namespace = local.namespace
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
}

resource "kubernetes_manifest" "check_signed_images_policy" {
  manifest = yamldecode(replace(file("${path.module}/policies/check_signed_images.yaml"), "__COSIGN_PUBLIC_KEY__", var.cosign_public_key))

  depends_on = [kubernetes_secret_v1.kyverno-regcred]
}
