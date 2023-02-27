# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.96.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "prefix" {}
variable "location" {}

resource "azurerm_resource_group" "azenv" {
  name     = "${var.prefix}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "azenv" {
  name                = "${var.prefix}-vn"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.azenv.location
  resource_group_name = azurerm_resource_group.azenv.name
}

resource "azurerm_subnet" "azenv" {
  name                 = "${var.prefix}-sn"
  resource_group_name  = azurerm_resource_group.azenv.name
  virtual_network_name = azurerm_virtual_network.azenv.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "azenv" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.azenv.location
  resource_group_name = azurerm_resource_group.azenv.name
}

output "azurerm_resource_group_name" {
  value = azurerm_resource_group.azenv.name
}

output "azurerm_resource_group_location" {
  value = azurerm_resource_group.azenv.location
}

output "azurerm_resource_group_subnet_id" {
  value = azurerm_subnet.azenv.id
}

output "network_security_group_name" {
  value = azurerm_network_security_group.azenv.name
}