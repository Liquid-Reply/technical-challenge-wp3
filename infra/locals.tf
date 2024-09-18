locals {
  address_space = "10.0.0.0/16"
  resource_group_name = azurerm_resource_group.main.name
  
  location = "germanywestcentral"
  zones = ["1", "2", "3"]

  admin_username = "adminuser"
  postgres_zone = "1"
  postgres_standby_availability_zone = "2"
  postgres_backup_retention_days = "8"
  postgres_geo_redundant_backup_enabled = true
}