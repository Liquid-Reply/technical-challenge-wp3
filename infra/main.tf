data "azurerm_subscription" "primary" {}

data "azurerm_client_config" "primary" {}

resource "azurerm_resource_group" "main" {
  name     = "tech-challenge"
  location = local.location
}


resource "azurerm_key_vault" "tech-challenge-keyvault" {
  name                        = "tech-challenge-kv"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.primary.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.primary.tenant_id
    object_id = data.azurerm_client_config.primary.object_id

    key_permissions = [
      "Get",
      "List",
      "Create"
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete"
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

resource "azurerm_dns_zone" "keycloak-dns-zone" {
  name                = "keycloak.full-coral.cc"
  resource_group_name = azurerm_resource_group.main.name
}

resource "random_pet" "azurerm_kubernetes_cluster_name" {
  prefix = "cluster"
}

resource "random_pet" "azurerm_kubernetes_cluster_dns_prefix" {
  prefix = "dns"
}

# resource "azurerm_container_registry" "tech-challenge-acr" {
#   name                = "tech-challenge-acr"
#   resource_group_name = azurerm_resource_group.main.name
#   location            = azurerm_resource_group.main.location
#   sku                 = "Standard"
#   admin_enabled       = true
# }

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.main.location
  name                = random_pet.azurerm_kubernetes_cluster_name.id
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = random_pet.azurerm_kubernetes_cluster_dns_prefix.id
  kubernetes_version  = "1.30"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D8s_v5"
    node_count = 3
    zones      = local.zones
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
}

resource "azurerm_role_assignment" "acr_k8s_role_assignment" {
  principal_id                     = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.tech-challenge-acr.id
  skip_service_principal_aad_check = true
}
