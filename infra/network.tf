resource "azurerm_virtual_network" "main" {
  name = "main"

  address_space       = [local.address_space]
  location            = local.location
  resource_group_name = local.resource_group_name
}

resource "azurerm_subnet" "main" {
  for_each = toset(local.zones)

  name = "main-${each.key}"

  address_prefixes     = [cidrsubnet(local.address_space, 8, tonumber(each.key))]
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name

}

resource "azurerm_public_ip" "nat" {
  for_each = toset(local.zones)
  name     = "nat-${each.key}"

  allocation_method   = "Static"
  location            = local.location
  resource_group_name = local.resource_group_name
  sku                 = "Standard"
  zones               = [each.key]
}

resource "azurerm_nat_gateway" "main" {
  for_each = toset(local.zones)
  name     = "nat-gateway-${each.key}"

  location            = local.location
  resource_group_name = local.resource_group_name
  zones               = [each.key]
}

resource "azurerm_nat_gateway_public_ip_association" "main" {
  for_each = toset(local.zones)
  nat_gateway_id       = azurerm_nat_gateway.main[each.key].id
  public_ip_address_id = azurerm_public_ip.nat[each.key].id
}

resource "azurerm_subnet_nat_gateway_association" "main" {
  for_each = toset(local.zones)
  subnet_id      = azurerm_subnet.main[each.key].id
  nat_gateway_id = azurerm_nat_gateway.main[each.key].id
}
