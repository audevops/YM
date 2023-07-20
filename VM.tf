  /*resource "azurerm_virtual_network" "DB_Vnet" {
    name                = "DB_Vnet"
    address_space       = ["10.0.0.0/16"]
    location            = var.location
    resource_group_name = var.resource_group_name
  }*/

  resource "azurerm_subnet" "DB_sub" {
    name                 = "DB-subnet"
    resource_group_name  = var.resource_group_name
    virtual_network_name = "DB_Vnet"
    address_prefixes     = ["10.0.0.0/24"]
    /*depends_on = [
      azurerm_virtual_network.DB_Vnet
    ]*/
  }

  resource "azurerm_public_ip" "MON_pub_IP_4" {
    name                = "MON-public-ip-4"
    location            = var.location
    resource_group_name = var.resource_group_name
    allocation_method   = "Dynamic"
  }


  resource "azurerm_network_interface" "MON-nic" {
    name                = "MON-nic"
    location            = var.location
    resource_group_name = var.resource_group_name
    ip_configuration {
      name                          = "MON-nic-configuration"
      subnet_id                     = azurerm_subnet.DB_sub.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = azurerm_public_ip.MON_pub_IP_4.id
    }
  }


  resource "azurerm_linux_virtual_machine" "MON1" {
    name                = "MON1"
    location            = var.location
    resource_group_name = var.resource_group_name
    size                = "Standard_D2s_v3"
    admin_username      = "adminuser"
    network_interface_ids = [
      azurerm_network_interface.MON-nic.id,
    ]
    admin_password                  = "Proximus#18"
    disable_password_authentication = false

    os_disk {
      caching              = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    source_image_reference {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-focal"
      sku       = "20_04-lts"
      version   = "latest"
    }
  }
provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apache2",
      "sudo ufw allow 'Apache'",
      "sudo systemctl enable apache2",
      "sudo systemctl start apache2"
    ]
  }