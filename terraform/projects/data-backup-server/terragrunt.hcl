include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  before_hook "before_hook" {
    commands = ["init", "plan", "apply", "import"]
    execute = ["./scripts/generate-ignition.sh"]
  }

  extra_arguments "extra_vars" {
    commands = ["init", "plan", "apply", "import", "destroy"]
    env_vars = {
      PROXMOX_VE_USERNAME = "${get_env("SECRETS_PVE_TARDIS_USERNAME")}"
      PROXMOX_VE_PASSWORD = "${get_env("SECRETS_PVE_TARDIS_PASSWORD")}"
      PROXMOX_VE_SSH_USERNAME = "${get_env("SECRETS_PVE_TARDIS_SSH_USERNAME")}"
      HCLOUD_TOKEN = "${get_env("SECRETS_HCLOUD_TOKEN")}"
    }
  }
}

