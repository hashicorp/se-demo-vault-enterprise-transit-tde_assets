terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.96.0"
    }
  }
}

variable "prefix" {}
variable "resource_group_name" {}
variable "resource_group_location" {}
variable "resource_group_subnet_id" {}
variable "network_security_group_name" {}

provider "azurerm" {
  features {}
}

resource "random_password" "password" {
  length  = 32
  special = false
}

resource "azurerm_windows_virtual_machine" "windows" {
  name                = "${var.prefix}-mssql"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  size                = "Standard_B2s"
  admin_username      = "mssql-tde-dev"
  admin_password      = random_password.password.result
  network_interface_ids = [
    azurerm_network_interface.windows.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "sql2019-ws2019"
    sku       = "sqldev-gen2"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "windows" {
  name                = "${var.prefix}-windows-nic"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.resource_group_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.windows.id
  }
}

resource "azurerm_public_ip" "windows" {
  name                = "${var.prefix}-windows-pip"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_rule" "rdp" {
  name                        = "Allow RDP"
  priority                   = 200
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "3389"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.network_security_group_name
}

resource "azurerm_network_security_rule" "ping" {
  name                        = "Allow ICMP pings"
  priority                   = 202
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Icmp"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.network_security_group_name

  # These don't make sense for ICMP but are still required
  source_port_range      = "*"
  destination_port_range = "*"
}
