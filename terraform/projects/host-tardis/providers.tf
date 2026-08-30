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
  }
}

provider "onepassword" {
  account = "NRTCOX6UQZGKPJBH7AUNVSVAUA"
}

provider "proxmox" {
  endpoint = "https://tardis.willtaylor.info:8006"
  insecure = true

  ssh {
    agent = true
  }
}
