data "azurerm_subscription" "primary" {}

data "azurerm_client_config" "primary" {}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.1"
  suffix = [
    "tech-challenge",
    "wp3"
  ]
}

resource "azurerm_resource_group" "keycloak" {
  name     = module.naming.resource_group.name
  location = local.location
}


