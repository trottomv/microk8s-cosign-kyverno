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
  name        = "microk8s"
  image       = "ubuntu-24.04"
  server_type = "cx21"
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  ssh_keys = var.ssh_keys
}
