locals {
  talos_version = "v1.13.3"

  cluster_vip  = "172.28.2.20"
  cluster_name = "single-spicy"

  default_gateway = "172.28.0.1"
  dns_servers     = ["172.28.0.1"]

  host_cluster_name = "tardis"
  host_nodes = {
    "tardis" = {}
  }

  talos_nodes = {
    "single-spicy" = {
      host_node_name = "tardis"
      vm_id          = 107
      node_ip        = "172.28.2.21"
      bootstrap      = true
      role           = "controlplane"
      cpu            = 4
      memory         = 8192
      disk           = 256
    },
  }

  deploy_bootstrap_manifests = true
}

data "talos_image_factory_extensions_versions" "single_spicy" {
  talos_version = local.talos_version
  filters = {
    names = [
      "i915",
      "intel-ucode",
      "iscsi-tools",
      "mei",
      "qemu-guest-agent",
    ]
  }
}

resource "talos_image_factory_schematic" "single_spicy" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.single_spicy.extensions_info.*.name
        }
      }
    }
  )
}

data "talos_image_factory_urls" "single_spicy" {
  talos_version = local.talos_version
  schematic_id  = talos_image_factory_schematic.single_spicy.id
  architecture  = "amd64"
  platform      = "nocloud"
}

resource "proxmox_virtual_environment_download_file" "talos_iso" {
  for_each     = local.host_nodes
  content_type = "iso"
  datastore_id = "local"
  node_name    = each.key
  file_name    = "talos-nocloud-amd64.iso"

  url = data.talos_image_factory_urls.single_spicy.urls.iso
}

resource "talos_machine_secrets" "single_spicy" {}

data "talos_client_configuration" "single_spicy" {
  cluster_name         = local.cluster_name
  client_configuration = talos_machine_secrets.single_spicy.client_configuration
  nodes                = [local.talos_nodes["single-spicy"].node_ip]
  endpoints            = [local.talos_nodes["single-spicy"].node_ip]
}

module "talos_nodes" {
  source   = "../../modules/talos-node"
  for_each = local.talos_nodes

  vm_host_cluster_name = local.host_cluster_name
  vm_host_node_name    = each.value.host_node_name
  vm_id                = each.value.vm_id
  node_name            = each.key
  vm_tags              = [each.value.role, "kubernetes", "talos", "terraform"]
  vm_cpu_cores         = each.value.cpu
  vm_memory            = each.value.memory
  vm_root_disk_size    = each.value.disk

  vm_installer_cdrom_file_id = proxmox_virtual_environment_download_file.talos_iso[each.value.host_node_name].id

  vm_host_pci_mapping_names          = []
  node_talos_oci_installer_image_url = data.talos_image_factory_urls.single_spicy.urls.installer

  node_ip              = each.value.node_ip
  node_default_gateway = local.default_gateway
  node_dns_servers     = local.dns_servers

  node_labels = {}

  node_deploy_bootstrap_manifests         = each.value.bootstrap && local.deploy_bootstrap_manifests
  node_talos_secrets_machine_secrets      = talos_machine_secrets.single_spicy.machine_secrets
  node_talos_secrets_client_configuration = talos_machine_secrets.single_spicy.client_configuration
  node_role                               = each.value.role
  node_enable_scheduling_on_controlplanes = true

  cluster_name = local.cluster_name
  cluster_vip  = local.cluster_vip
  certSANs     = ["single-spicy.willtaylor.info"]

  node_execute_talos_bootstrap = each.value.bootstrap
}

resource "talos_cluster_kubeconfig" "single_spicy" {
  depends_on           = [module.talos_nodes["single-spicy"]]
  client_configuration = talos_machine_secrets.single_spicy.client_configuration
  node                 = local.talos_nodes["single-spicy"].node_ip
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = "kubernetes-single-spicy"
}

resource "vault_kubernetes_auth_backend_config" "single_spicy" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = talos_cluster_kubeconfig.single_spicy.kubernetes_client_configuration.host
  kubernetes_ca_cert     = base64decode(talos_cluster_kubeconfig.single_spicy.kubernetes_client_configuration.ca_certificate)
  disable_local_ca_jwt   = true
  disable_iss_validation = true
  issuer                 = talos_cluster_kubeconfig.single_spicy.kubernetes_client_configuration.host
}

resource "vault_kubernetes_auth_backend_role" "single_spicy" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "external-secrets-css"
  bound_service_account_names      = ["eso-vault-css"]
  bound_service_account_namespaces = ["external-secrets"]
  token_ttl                        = 3600
  token_policies                   = ["kubernetes-external-secrets"]
  alias_name_source                = "serviceaccount_name"
}

module "proxmox_csi_user" {
  source = "../../modules/proxmox-csi-user"

  create_csi_role      = true
  proxmox_csi_username = "single-spicy-talos-csi"
}

resource "vault_kv_secret_v2" "csi_credentials" {
  mount = "kv"
  name  = "services/single-spicy/csi-proxmox/proxmox-credentials"
  data_json = jsonencode(
    {
      api_token_id = module.proxmox_csi_user.api_token_id
      api_token    = module.proxmox_csi_user.api_token
    }
  )
}

