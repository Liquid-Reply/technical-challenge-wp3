resource "azurerm_resource_group" "main" {
  name = "tech-challenge"
  location = local.location
}