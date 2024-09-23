resource "azurerm_dns_zone" "keycloak" {
  name                = "keycloak.${var.domain_name}"
  resource_group_name = azurerm_resource_group.keycloak.name
}
