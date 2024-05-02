# K8s

variable "kubernetes_client_certificate" {
  type      = string
  sensitive = true
}

variable "kubernetes_client_key" {
  type      = string
  sensitive = true
}

variable "kubernetes_cluster_ca_certificate" {
  type      = string
  sensitive = true
}

variable "kubernetes_host" {
  type = string
}

# Regcred

variable "registry_password" {
  type = string
}

variable "registry_server" {
  type = string
}

variable "registry_username" {
  type = string
}

# Deployment

variable "deployment_namespace" {
  type    = string
  default = "develop"
}

variable "environment_slug" {
  type    = string
  default = "development"
}

variable "project_slug" {
  type    = string
  default = "app"
}

variable "service_container_image" {
  type = string
}

variable "service_container_port" {
  type    = string
  default = "8000"
}

variable "service_replicas" {
  type    = number
  default = 1
}

variable "service_slug" {
  type    = string
  default = "app"
}
