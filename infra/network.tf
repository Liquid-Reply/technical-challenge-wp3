resource "azurerm_virtual_network" "main" {
  name = "main"

  address_space       = [local.address_space]
  location            = local.location
  resource_group_name = local.resource_group_name
}

resource "azurerm_subnet" "keycloak" {
  for_each = toset(local.zones)

  name = "keycloak-${each.key}"

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

# Associate NAT Gateway with Subnet
resource "azurerm_subnet_nat_gateway_association" "main" {
  for_each = toset(local.zones)
  subnet_id      = azurerm_subnet.keycloak[each.key].id
  nat_gateway_id = azurerm_nat_gateway.main[each.key].id
}

resource "azurerm_public_ip" "keycloak" {
  for_each = toset(local.zones)
  name     = "keycloak-${each.key}"

  allocation_method   = "Static"
  location            = local.location
  resource_group_name = local.resource_group_name
  sku                 = "Standard"
  zones               = [each.key]
}

resource "azurerm_network_security_group" "keycloak" {
  name                = "keycloak"
  location            = local.location
  resource_group_name = local.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "keycloak" {
  for_each = toset(local.zones)
  name                = "keycloak-${each.key}"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "keycloak"
    subnet_id                     = azurerm_subnet.keycloak[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.keycloak[each.key].id
  }
}

resource "azurerm_network_interface_security_group_association" "keycloak" {
  for_each = toset(local.zones)
  network_interface_id      = azurerm_network_interface.keycloak[each.key].id
  network_security_group_id = azurerm_network_security_group.keycloak.id
}
