resource "azurerm_storage_account" "example" {
  name                     = "yashmdev"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "Dev_YM"
  }
}