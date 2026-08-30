terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "3.3.1"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.89.1"
    }
  }
}
