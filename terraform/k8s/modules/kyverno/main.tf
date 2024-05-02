locals {
  namespace = "kyverno"
}

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }
}

resource "helm_release" "kyverno" {
  name       = "kyverno"
  namespace  = local.namespace
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno"

  create_namespace = true
}

resource "helm_release" "kyverno-policies" {
  name       = "kyverno-policies"
  namespace  = local.namespace
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno-policies"

  depends_on = [helm_release.kyverno]
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
