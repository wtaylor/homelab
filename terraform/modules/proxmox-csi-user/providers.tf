terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.108.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.6.0"
    }
  }
}
