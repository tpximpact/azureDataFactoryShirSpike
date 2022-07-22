data "azurerm_client_config" "current" {
}

resource "azurerm_key_vault" "kv-lg-shirdfspike2" {
  name = "kvlgshirdfspike2"
  location = azurerm_resource_group.rg-lg-shirdfspike.location
  resource_group_name = azurerm_resource_group.rg-lg-shirdfspike.name
  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name = "standard"

timeouts {
    read = "10m"
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  access_policy {
    tenant_id = azurerm_data_factory.adf-lg-shirdfspike.identity[0].tenant_id
    object_id = azurerm_data_factory.adf-lg-shirdfspike.identity[0].principal_id

    secret_permissions = [
        "Get"
    ]
  }

  access_policy {
    tenant_id    = data.azurerm_client_config.current.tenant_id
    object_id    = data.azurerm_client_config.current.object_id

    secret_permissions = [
       "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
    ]
  }
}

resource "azurerm_key_vault_secret" "vm-lg-shirdfspike-filesource-admin-password" {
  name         = "filesource-admin-password"
  value        = var.vm-lg-shirdfspike-filesource-admin-password
  key_vault_id = azurerm_key_vault.kv-lg-shirdfspike2.id
}

resource "azurerm_key_vault_secret" "vm-lg-shirdfspike-sink-access-key" {
  name         = "sink-secret-key"
  value        = azurerm_storage_account.st-lg-shirdfspike-sink.primary_access_key
  key_vault_id = azurerm_key_vault.kv-lg-shirdfspike2.id
}