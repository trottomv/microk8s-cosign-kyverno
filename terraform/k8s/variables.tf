
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
