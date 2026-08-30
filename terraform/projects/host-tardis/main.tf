locals {
  vault           = "rywytgveqosp6sijtoepddc6ta" #Homelab
  node_name       = "tardis"
  root_disk_store = "local-zfs"
}

module "proxmox-metrics-user" {
  source                  = "../../modules/proxmox-metrics-user"
  credentials_secret_name = "pve-tardis-metrics-user"
}
