
variable "hcloud_token" {
  sensitive = true
}

variable "ssh_keys" {
  type    = list(string)
  default = []
}
