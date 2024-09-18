resource "azurerm_key_vault_secret" "keycloak-postgres-secret" {
  name         = "keycloak-postgres-secret"
  value        = file("./files/postgresql_password")
  key_vault_id = azurerm_key_vault.tech-challenge-keyvault.id
}

resource "random_pet" "postgresql_server_name_random_suffix" {
}

resource "azurerm_postgresql_flexible_server" "keycloak" {
  resource_group_name = local.resource_group_name
  name = "keycloak-postgres-${random_pet.postgresql_server_name_random_suffix.id}"
  location = local.location

  version = "16"

  public_network_access_enabled = true

  administrator_login = "psqladmin"
  administrator_password = azurerm_key_vault_secret.keycloak-postgres-secret.value 

  sku_name   = "GP_Standard_D2s_v3"
  zone       = local.postgres_zone
  
  high_availability {
    mode = "ZoneRedundant"
    standby_availability_zone = local.postgres_standby_availability_zone #to fix error `zone` can only be changed when exchanged with the zone specified in `high_availability.0.standby_availability_zone`
  }

  backup_retention_days        = local.postgres_backup_retention_days
  geo_redundant_backup_enabled = local.postgres_geo_redundant_backup_enabled

  storage_mb = 32768
  storage_tier = "P10"

  #TODO: encryption
  #TODO: out own vnet/subnet?
  #TODO: password in keyvault?
}


resource azurerm_postgresql_flexible_server_database "keycloak-db" {
  name      = "keycloak-db"
  server_id = azurerm_postgresql_flexible_server.keycloak.id
  collation = "en_US.utf8"
  charset   = "utf8"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}