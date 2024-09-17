resource "azurerm_postgresql_flexible_server" "keycloak" {
  resource_group_name = local.resource_group_name
  name = "keycloak"
  location = local.location

  version = "16"

  public_network_access_enabled = true

  administrator_login = "admin"
  administrator_password = file("./files/postgresql_password")
  
  high_availability {
    mode = "ZoneRedundant"
  }

  storage_mb = 32768
  storage_tier = "P10"

  #TODO: encryption
  #TODO: out own vnet/subnet?
  #TODO: password in keyvault?
}