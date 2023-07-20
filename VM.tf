provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "myresourcegroup" {
  name     = "my-resource-group"
  location = "East US"
}

resource "azurerm_virtual_network" "mynetwork" {
  name                = "my-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myresourcegroup.location
  resource_group_name = azurerm_resource_group.myresourcegroup.name
}

resource "azurerm_subnet" "mysubnet" {
  name                 = "my-subnet"
  resource_group_name  = azurerm_resource_group.myresourcegroup.name
  virtual_network_name = azurerm_virtual_network.mynetwork.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "mypublicip" {
  name                = "my-public-ip"
  location            = azurerm_resource_group.myresourcegroup.location
  resource_group_name = azurerm_resource_group.myresourcegroup.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "mynic" {
  name                = "my-network-interface"
  location            = azurerm_resource_group.myresourcegroup.location
  resource_group_name = azurerm_resource_group.myresourcegroup.name

  ip_configuration {
    name                          = "my-ip-configuration"
    subnet_id                     = azurerm_subnet.mysubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mypublicip.id
  }
}

resource "azurerm_linux_virtual_machine" "myvm" {
  name                = "my-vm"
  location            = azurerm_resource_group.myresourcegroup.location
  resource_group_name = azurerm_resource_group.myresourcegroup.name
  size                = "Standard_B1s"
  admin_username      = "myadmin"
  network_interface_ids = [
    azurerm_network_interface.mynic.id,
  ]
  os_disk {
    name              = "my-os-disk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }

  custom_data = <<-EOF
              #!/bin/bash
              apt-get -y update
              apt-get -y install apache2
              EOF
}

output "public_ip_address" {
  value = azurerm_public_ip.mypublicip.ip_address
}

