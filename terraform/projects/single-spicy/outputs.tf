output "talos_client_config" {
  sensitive = true
  value     = data.talos_client_configuration.single_spicy.talos_config
}

output "kubeconfig" {
  sensitive = true
  value     = talos_cluster_kubeconfig.single_spicy.kubeconfig_raw
}

