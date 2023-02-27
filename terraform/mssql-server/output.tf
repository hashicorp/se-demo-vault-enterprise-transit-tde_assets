# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "azurerm_public_ip" "public_ip_data" {
  name                = azurerm_public_ip.windows.name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_windows_virtual_machine.windows]
}

resource "local_file" "rdp" {
  filename = "mssql-tde-dev.rdp"
  content  = <<EOF
full address:s:${data.azurerm_public_ip.public_ip_data.ip_address}:${azurerm_network_security_rule.rdp.destination_port_range}
username:s:${azurerm_windows_virtual_machine.windows.admin_username}
administrative session:i:1
EOF
}

output "password" {
  description = "SQL Server admin password"
  value       = random_password.password.result
  sensitive   = true
}

output "start_rdp_session" {
  value = <<EOF
# Run these commands and paste the password to connect to the SQL Server

terraform output -raw password | pbcopy
open mssql-tde-dev.rdp
EOF
}

output "azurerm_public_ip" {
  value = data.azurerm_public_ip.public_ip_data.ip_address
}
