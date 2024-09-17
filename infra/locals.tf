locals {
  address_space = "10.0.0.0/16"
  resource_group_name = azurerm_resource_group.main.name
  
  location = "germanywestcentral"
  zones = ["1", "2", "3"]

  admin_username = "adminuser"
}