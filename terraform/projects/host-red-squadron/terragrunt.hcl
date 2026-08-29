include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  extra_arguments "extra_vars" {
    commands = ["init", "plan", "apply", "import"]
    env_vars = {
      PROXMOX_VE_USERNAME = "${get_env("SECRETS_PVE_RED_SQUADRON_USERNAME")}"
      PROXMOX_VE_PASSWORD = "${get_env("SECRETS_PVE_RED_SQUADRON_PASSWORD")}"
      PROXMOX_VE_SSH_USERNAME = "${get_env("SECRETS_PVE_RED_SQUADRON_SSH_USERNAME")}"
    }
  }
}

