data "hcloud_ssh_key" "nebuchadnezzar" {
  name = "wtaylor@nebuchadnezzar"
}

data "onepassword_item" "backup_server" {
  vault = local.vault
  title = "hetzner-backup-server"
}

data "onepassword_item" "backup_server_ssh" {
  vault = local.vault
  # category = "ssh_key"
  title = "hetzner-backup-server-ssh-rclone"
}

resource "hcloud_ssh_key" "data_backup_server" {
  name       = "rclone@data-backup-server"
  public_key = data.onepassword_item.backup_server_ssh.public_key
}

resource "hcloud_storage_box" "backup_server" {
  name             = "backup-server"
  storage_box_type = "bx21" # 5TB
  location         = "fsn1" # Germany
  password         = data.onepassword_item.backup_server.password

  ssh_keys = [
    hcloud_ssh_key.data_backup_server.public_key,
    data.hcloud_ssh_key.nebuchadnezzar.public_key
  ]

  access_settings = {
    reachable_externally = true
    ssh_enabled          = true
    zfs_enabled          = true
  }

  snapshot_plan = {
    max_snapshots = 14
    hour          = 12
    minute        = 0
  }

  lifecycle {
    ignore_changes  = [ssh_keys]
    prevent_destroy = true
  }
}
