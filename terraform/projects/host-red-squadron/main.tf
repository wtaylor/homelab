locals {
  vault           = "rywytgveqosp6sijtoepddc6ta" #Homelab
  node_name       = "red-one"
  root_disk_store = "local-zfs"
}

module "proxmox-metrics-user" {
  source                  = "../../modules/proxmox-metrics-user"
  credentials_secret_name = "pve-red-squadron-metrics-user"
}
