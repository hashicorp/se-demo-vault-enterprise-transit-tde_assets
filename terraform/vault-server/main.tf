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

resource "azurerm_linux_virtual_machine" "linux" {
  name                = "${var.prefix}-linux"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  size                = "Standard_B1s"
  admin_username      = "vadmin"
  network_interface_ids = [
    azurerm_network_interface.linux.id,
  ]

  admin_ssh_key {
    username   = "vadmin"
    public_key = file("./.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = "60"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "linux" {
  name                = "${var.prefix}-linux-nic"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.resource_group_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux.id
  }
}

resource "azurerm_public_ip" "linux" {
  name                = "${var.prefix}-linux-pip"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_rule" "ssh_port" {
  name                        = "SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.network_security_group_name
}

resource "azurerm_network_security_rule" "vault_port" {
  name                        = "Vault API"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8200"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.network_security_group_name
}

resource "null_resource" "deploy-vault-instance" {
  depends_on = [
    azurerm_linux_virtual_machine.linux
  ]

  provisioner "file" {
    source      = "./templates/deploy-vault-instance.bash"
    destination = "/tmp/deploy-vault-instance.bash"

    connection {
      type        = "ssh"
      user        = "vadmin"
      private_key = file("./.ssh/id_rsa")
      host        = azurerm_linux_virtual_machine.linux.public_ip_address
    }
  }

  provisioner "file" {
    source      = "./templates/initialize-vault-instance.bash"
    destination = "/tmp/initialize-vault-instance.bash"

    connection {
      type        = "ssh"
      user        = "vadmin"
      private_key = file("./.ssh/id_rsa")
      host        = azurerm_linux_virtual_machine.linux.public_ip_address
    }
  }

  provisioner "file" {
    source      = "/var/vault-license.hclic"
    destination = "/tmp/vault.hclic"

    connection {
      type        = "ssh"
      user        = "vadmin"
      private_key = file("./.ssh/id_rsa")
      host        = azurerm_linux_virtual_machine.linux.public_ip_address
    }
  }

  provisioner "remote-exec" {
    inline = [
      "bash /tmp/deploy-vault-instance.bash",
      "sudo mv /tmp/vault.hclic /etc/vault.d/vault.hclic",
      "bash /tmp/initialize-vault-instance.bash"
    ]
    connection {
      type        = "ssh"
      user        = "vadmin"
      private_key = file("./.ssh/id_rsa")
      host        = azurerm_linux_virtual_machine.linux.public_ip_address
    }
  }

  triggers = {
    always_run = timestamp()
  }
}

output "azurerm_public_ip" {
  value = azurerm_linux_virtual_machine.linux.public_ip_address
}