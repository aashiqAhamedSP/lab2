
provider "azurerm" {
  features {}
  subscription_id = var.subid
  client_id       = var.clid
  client_secret   = var.clcr
  tenant_id       = var.tnid
}
terraform {
    backend "azurerm" {
        resource_group_name = var.terra_rg
        storage_account_name = var.trstrgname
        container_name = "terraform"
        key = "terraform.tfstate"
    }
}
resource "azurerm_resource_group" "jenkins_rg" {
  name     = "lab2rg"
  location = "eastus"
}

resource "azurerm_virtual_network" "jenkins_vnet" {
  name                = "lab2vnet"
  location            = azurerm_resource_group.jenkins_rg.location
  resource_group_name = azurerm_resource_group.jenkins_rg.name
  address_space       = ["10.2.0.0/16"]

}
resource "azurerm_subnet" "subnet1" {
  name                 = "lab2subnet"
  resource_group_name  = azurerm_resource_group.jenkins_rg.name
  virtual_network_name = azurerm_virtual_network.jenkins_vnet.name
  address_prefixes     = ["10.2.0.0/24"]

}

resource "azurerm_network_security_group" "nsg" {

  name                = "nsg1"
  location            = azurerm_resource_group.jenkins_rg.location
  resource_group_name = azurerm_resource_group.jenkins_rg.name
}
resource "azurerm_network_security_rule" "ssh-rule" {

  name                        = "ssh"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.jenkins_rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_subnet_network_security_group_association" "NSG_SUB_ASC" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "pubip" {
  name                = "lab2pubip"
  resource_group_name = azurerm_resource_group.jenkins_rg.name
  location            = azurerm_resource_group.jenkins_rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "niclab2"
  location            = azurerm_resource_group.jenkins_rg.location
  resource_group_name = azurerm_resource_group.jenkins_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pubip.id
  }
}

resource "azurerm_linux_virtual_machine" "mysqlvm" {
  name                            = "mysqlvm"
  resource_group_name             = azurerm_resource_group.jenkins_rg.name
  location                        = azurerm_resource_group.jenkins_rg.location
  size                            = "Standard_B2ms"


  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    name              = "mysqlvmosdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  admin_username = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username       = "azureuser"
    public_key     = var.ansssh
  }

}
