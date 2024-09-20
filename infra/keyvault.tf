resource "azurerm_key_vault" "keycloak" {
  tenant_id                   = data.azurerm_client_config.primary.tenant_id
  name                        = module.naming.key_vault.name
  location                    = azurerm_resource_group.keycloak.location
  resource_group_name         = azurerm_resource_group.keycloak.name
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  # Purge protection disabled during development
  # But set to enabled in production
  purge_protection_enabled = false
  sku_name                 = "standard"
  access_policy {
    tenant_id = data.azurerm_client_config.primary.tenant_id
    # Whoever runs the terraform apply will get the access permissions 
    # listed below here because of "data.azurerm_client_config.primary.object_id"
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

resource "azurerm_key_vault_secret" "keycloak_psqladmin_password" {
  name         = "${module.naming.key_vault_secret.name}-psqladmin"
  value        = file("./files/postgresql_password")
  key_vault_id = azurerm_key_vault.keycloak.id
}
