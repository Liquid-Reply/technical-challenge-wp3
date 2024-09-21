resource "azurerm_kubernetes_cluster" "keycloak" {
  name                = module.naming.kubernetes_cluster.name
  location            = azurerm_resource_group.keycloak.location
  resource_group_name = azurerm_resource_group.keycloak.name
  dns_prefix          = module.naming.kubernetes_cluster.name
  kubernetes_version  = "1.30"
  identity {
    type = "SystemAssigned"
  }
  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D8s_v5"
    node_count = local.node_count
    zones      = local.zones
    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }
  linux_profile {
    admin_username = local.admin_username
    ssh_key {
      key_data = azapi_resource_action.ssh_public_key_gen.output.publicKey
    }
  }
  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    load_balancer_sku   = "standard"
    network_policy      = "cilium"
    network_data_plane  = "cilium"
  }
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
}