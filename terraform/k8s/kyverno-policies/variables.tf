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

# Cosign

variable "cosign_public_key" {
  type = string
}
