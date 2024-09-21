resource "azapi_resource" "ssh_public_key" {
  type = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  # No name available through naming module
  name      = "tech-challenge-wp3"
  location  = azurerm_resource_group.keycloak.location
  parent_id = azurerm_resource_group.keycloak.id
}

resource "azapi_resource_action" "ssh_public_key_gen" {
  type                   = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id            = azapi_resource.ssh_public_key.id
  action                 = "generateKeyPair"
  method                 = "POST"
  response_export_values = ["publicKey", "privateKey"]
}
