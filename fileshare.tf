
resource "azurerm_storage_account" "st-lg-shirdfspike-sink" {
  name                     = "stlgshirdfspikesink"
  location                 = azurerm_resource_group.rg-lg-shirdfspike.location
  resource_group_name      = azurerm_resource_group.rg-lg-shirdfspike.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "st-lg-shirdfspike-sink-share" {
  name                 = "share-sink"
  storage_account_name = azurerm_storage_account.st-lg-shirdfspike-sink.name
  quota                = 2
}