resource "azurerm_storage_account" "keycloak" {
  name                     = "keycloak${substr(sha256(module.naming.storage_account.name), 0, 8)}"
  resource_group_name      = azurerm_resource_group.keycloak.name
  location                 = azurerm_resource_group.keycloak.location
  account_replication_type = "ZRS"
  account_tier             = "Standard"
}

resource "azurerm_data_protection_backup_vault" "keycloak" {
  # Backup vault is not the same as recovery_services_vault
  # recovery_services_vault module name was used only for development
  name                = module.naming.recovery_services_vault.name
  resource_group_name = azurerm_resource_group.keycloak.name
  location            = azurerm_resource_group.keycloak.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
  # Only for development purpose
  # Will be set to AlwaysOn in production
  # In production, the backup vault cannot be deleted by IAC
  # It would have to be first disabled manually before it can be deleted
  soft_delete = "Off"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "keycloack_backupvault_resourcegroup_reader_role" {
  scope                = azurerm_resource_group.keycloak.id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.keycloak.identity.0.principal_id
}

resource "azurerm_role_assignment" "keycloack_backupvault_postgres_server_backup_role" {
  scope                = azurerm_postgresql_flexible_server.keycloak.id
  role_definition_name = "PostgreSQL Flexible Server Long Term Retention Backup Role"
  principal_id         = azurerm_data_protection_backup_vault.keycloak.identity.0.principal_id
}

resource "azurerm_role_assignment" "keycloack_backupvault_storageaccount_blob_contributor_role" {
  scope                = azurerm_storage_account.keycloak.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_protection_backup_vault.keycloak.identity.0.principal_id
}


resource "azurerm_data_protection_backup_policy_postgresql_flexible_server" "keycloak" {
  name     = "keycloak"
  vault_id = azurerm_data_protection_backup_vault.keycloak.id
  backup_repeating_time_intervals = [
    "R/2024-09-22T01:00:00+00:00/P1W",
    "R/2024-09-23T01:00:00+00:00/P1W",
    "R/2024-09-24T01:00:00+00:00/P1W",
    "R/2024-09-25T01:00:00+00:00/P1W",
    "R/2024-09-26T01:00:00+00:00/P1W",
    "R/2024-09-20T01:00:00+00:00/P1W",
    "R/2024-09-21T01:00:00+00:00/P1W"
  ]
  default_retention_rule {
    life_cycle {
      duration        = "P4M"
      data_store_type = "VaultStore"
    }
  }
  time_zone = "Coordinated Universal Time"
  depends_on = [
    azurerm_role_assignment.keycloack_backupvault_resourcegroup_reader_role,
  azurerm_role_assignment.keycloack_backupvault_postgres_server_backup_role]
}

resource "azurerm_data_protection_backup_instance_postgresql_flexible_server" "keycloak" {
  name             = azurerm_postgresql_flexible_server.keycloak.name
  location         = azurerm_resource_group.keycloak.location
  vault_id         = azurerm_data_protection_backup_vault.keycloak.id
  server_id        = azurerm_postgresql_flexible_server.keycloak.id
  backup_policy_id = azurerm_data_protection_backup_policy_postgresql_flexible_server.keycloak.id
}
