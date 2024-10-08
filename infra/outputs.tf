output "resource_group_name" {
  value = azurerm_resource_group.keycloak.name
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.keycloak.name
}

output "ssh_public_key" {
  value = azapi_resource_action.ssh_public_key_gen.output.publicKey
}

output "ssh_private_key" {
  value = azapi_resource_action.ssh_public_key_gen.output.privateKey
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.keycloak.kube_config[0].client_certificate
  sensitive = true
}

output "client_key" {
  value     = azurerm_kubernetes_cluster.keycloak.kube_config[0].client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.keycloak.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "cluster_password" {
  value     = azurerm_kubernetes_cluster.keycloak.kube_config[0].password
  sensitive = true
}

output "cluster_username" {
  value     = azurerm_kubernetes_cluster.keycloak.kube_config[0].username
  sensitive = true
}

output "host" {
  value     = azurerm_kubernetes_cluster.keycloak.kube_config[0].host
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.keycloak.kube_config_raw
  sensitive = true
}

output "database_endpoint" {
  value = azurerm_postgresql_flexible_server.keycloak.fqdn
}