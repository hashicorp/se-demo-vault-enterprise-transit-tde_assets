# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  default = "example"
}
variable "location" {
  default = "East US"
}

module "azure-env" {
  source   = "./azure-env"
  prefix   = var.prefix
  location = var.location
}

module "vault-server" {
  source                      = "./vault-server"
  prefix                      = var.prefix
  resource_group_name         = module.azure-env.azurerm_resource_group_name
  resource_group_location     = module.azure-env.azurerm_resource_group_location
  resource_group_subnet_id    = module.azure-env.azurerm_resource_group_subnet_id
  network_security_group_name = module.azure-env.network_security_group_name
}

module "mssql-server" {
  source                      = "./mssql-server"
  prefix                      = var.prefix
  resource_group_name         = module.azure-env.azurerm_resource_group_name
  resource_group_location     = module.azure-env.azurerm_resource_group_location
  resource_group_subnet_id    = module.azure-env.azurerm_resource_group_subnet_id
  network_security_group_name = module.azure-env.network_security_group_name
}

output "vault_server_public_ip" {
  value = module.vault-server.azurerm_public_ip
}

output "vault_server_http_url" {
  value = "http://${module.vault-server.azurerm_public_ip}:8200"
}

output "vault_server_ssh_cmd" {
  value = "ssh -i .ssh/id_rsa vadmin@${module.vault-server.azurerm_public_ip}"
}

output "mssql_server_public_ip" {
  value = module.mssql-server.azurerm_public_ip
}

output "password" {
  value     = module.mssql-server.password
  sensitive = true
}

output "start_rdp_session" {
  value = module.mssql-server.start_rdp_session
}
