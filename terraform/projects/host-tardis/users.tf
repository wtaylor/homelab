resource "proxmox_virtual_environment_group" "admins" {
  group_id = "admins"
  comment  = "Full access administrators. Managed by Terraform."

  acl {
    path      = "/"
    propagate = true
    role_id   = "Administrator"
  }
}

data "onepassword_item" "pve_wtaylor" {
  vault = local.vault
  title = "pve-wtaylor-user"
}

resource "proxmox_virtual_environment_user" "wtaylor" {
  user_id  = "wtaylor@pam"
  password = data.onepassword_item.pve_wtaylor.password
  comment  = "Managed by Terraform"

  email      = data.onepassword_item.pve_wtaylor.section_map["personal"].field_map["email"].value
  first_name = "William"
  last_name  = "Taylor"

  groups = ["admins"]
}

