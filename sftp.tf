resource "azurerm_storage_account" "lg-spike-nike-storage-account" {
  name                     = "lgspikenikestorage"
  location            = azurerm_resource_group.rg-lg-shirdfspike.location
  resource_group_name = azurerm_resource_group.rg-lg-shirdfspike.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "lg-spike-nike-storage-share" {
  name                 = "lgspikenikefileshare"
  storage_account_name = azurerm_storage_account.lg-spike-nike-storage-account.name
  quota                = 50
}

resource "azurerm_container_group" "lg-spike-nike-container-group" {
  name                = "lg-sftp-spike-container-group"
  location            = azurerm_resource_group.rg-lg-shirdfspike.location
  resource_group_name = azurerm_resource_group.rg-lg-shirdfspike.name
  ip_address_type     = "Public"
  os_type             = "Linux"
  dns_name_label = "lgexamplednslabelnike"

  container {
    name   = "lg-sftp-spike"
    image  = "atmoz/sftp:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 22
      protocol = "TCP"
    }

    commands = ["/entrypoint", "sftpadmin:${var.sftp-password}:1001"]

    volume {
      name = "azurefile"
      mount_path = "/home/sftpadmin/upload"
      storage_account_name = azurerm_storage_account.lg-spike-nike-storage-account.name
      storage_account_key = azurerm_storage_account.lg-spike-nike-storage-account.primary_access_key
      share_name = azurerm_storage_share.lg-spike-nike-storage-share.name
      read_only = false
    }
  }
}