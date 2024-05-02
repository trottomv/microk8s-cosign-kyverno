
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
  default = "microk8s-setup"
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
