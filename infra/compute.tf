#TODO: maybe switch to scale set
resource "azurerm_linux_virtual_machine" "keycloak" {
  for_each = toset(local.zones)
  name                  = "keycloak-${each.key}"
  location              = local.location
  resource_group_name   = local.resource_group_name
  network_interface_ids = [azurerm_network_interface.keycloak[each.key].id]
  size                  = "Standard_D2_v5"
  #TODO: encryption

  os_disk { #TODO: check setting
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" 
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  admin_username = local.admin_username

  admin_ssh_key {
    username   = local.admin_username
    public_key = file("./files/id_rsa_keycloak.pub")
  }
}