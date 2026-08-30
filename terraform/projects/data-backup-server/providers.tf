terraform {
  required_version = ">= 1.11.1"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.89.1"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "3.3.1"
    }
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

provider "proxmox" {
  endpoint = "https://tardis.willtaylor.info:8006"
  insecure = true

  ssh {
    agent       = false
    private_key = file("~/.ssh/id_ed25519")
  }
}

provider "onepassword" {
  account = "NRTCOX6UQZGKPJBH7AUNVSVAUA"
}
