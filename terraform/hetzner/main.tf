terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_server" "main" {
  name        = var.server_name
  image       = var.server_image
  server_type = var.server_type
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  ssh_keys = var.ssh_keys
}

output "server_ip_address" {
  value = hcloud_server.main.ipv4_address
}
