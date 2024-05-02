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
  }
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

  timeouts {
    create = "1m"
    update = "1m"
  }
}
