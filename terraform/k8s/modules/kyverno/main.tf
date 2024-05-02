locals {
  kyverno_namespace = "kyverno"
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
  name             = "kyverno"
  namespace        = local.kyverno_namespace
  repository       = "https://kyverno.github.io/kyverno/"
  chart            = "kyverno"
  create_namespace = true
}

resource "helm_release" "kyverno-policies" {
  name       = "kyverno-policies"
  namespace  = local.kyverno_namespace
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno-policies"
  depends_on = [helm_release.kyverno]
}
