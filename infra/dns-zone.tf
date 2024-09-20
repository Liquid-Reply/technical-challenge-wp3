resource "azurerm_dns_zone" "keycloak" {
  name                = "keycloak.full-coral.cc"
  resource_group_name = azurerm_resource_group.keycloak.name
}
