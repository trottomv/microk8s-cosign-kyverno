locals {
  service_labels = {
    component   = var.service_slug
    environment = var.environment_slug
    project     = var.project_slug
    terraform   = "true"
  }
}

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.13"
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

resource "kubernetes_deployment_v1" "app" {
  metadata {
    name      = var.service_slug
    namespace = var.deployment_namespace
    annotations = {
      "reloader.stakater.com/auto" = "true"
    }
  }
  spec {
    replicas = var.service_replicas
    selector {
      match_labels = local.service_labels
    }
    template {
      metadata {
        labels = local.service_labels
      }
      spec {
        image_pull_secrets {
          name = "regcred"
        }
        container {
          image = var.service_container_image
          name  = var.service_slug
          port {
            container_port = var.service_container_port
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }

  timeouts {
    create = "1m"
    update = "1m"
  }
}
