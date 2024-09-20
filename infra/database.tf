resource "azurerm_postgresql_flexible_server" "keycloak" {
  name                          = module.naming.postgresql_server.name
  resource_group_name           = azurerm_resource_group.keycloak.name
  location                      = azurerm_resource_group.keycloak.location
  version                       = "16"
  public_network_access_enabled = true
  administrator_login           = "psqladmin"
  administrator_password        = azurerm_key_vault_secret.keycloak_psqladmin_password.value
  sku_name                      = "GP_Standard_D2s_v3"
  zone                          = local.postgres_zone
  high_availability {
    mode = "ZoneRedundant"
    # to fix error `zone` can only be changed when exchanged with the zone specified in `high_availability.0.standby_availability_zone`
    standby_availability_zone = local.postgres_standby_availability_zone
  }
  backup_retention_days        = local.postgres_backup_retention_days
  geo_redundant_backup_enabled = local.postgres_geo_redundant_backup_enabled
  storage_mb                   = 32768
  storage_tier                 = "P10"
}

resource "azurerm_postgresql_flexible_server_database" "keycloak-db" {
  name      = module.naming.postgresql_database.name
  server_id = azurerm_postgresql_flexible_server.keycloak.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

# Do not use in production
# Use private endpoints and subnet intergration in production
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_all_internet" {
  name             = "alllow_all_internet"
  server_id        = azurerm_postgresql_flexible_server.keycloak.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}