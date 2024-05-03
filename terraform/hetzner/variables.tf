variable "hcloud_token" {
  sensitive = true
}

variable "server_image" {
  type    = string
  default = "ubuntu-24.04"
}

variable "server_name" {
  type    = string
  default = "my-server"
}

variable "server_type" {
  type    = string
  default = "cx11"
}

variable "ssh_keys" {
  type    = list(string)
  default = []
}
