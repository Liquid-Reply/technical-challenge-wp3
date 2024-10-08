locals {
  address_space                         = "10.0.0.0/16"
  location                              = "germanywestcentral"
  zones                                 = ["1", "2", "3"]
  node_count                            = 3
  admin_username                        = "azureuser"
  postgres_zone                         = "1"
  postgres_standby_availability_zone    = "2"
  postgres_backup_retention_days        = "8"
  postgres_geo_redundant_backup_enabled = true
}