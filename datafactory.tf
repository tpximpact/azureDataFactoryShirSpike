resource "azurerm_data_factory" "adf-lg-shirdfspike" {
  name                = "adf-lg-shirdfspike"
  location            = azurerm_resource_group.rg-lg-shirdfspike.location
  resource_group_name = azurerm_resource_group.rg-lg-shirdfspike.name
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_factory_integration_runtime_self_hosted" "adf-shir-lg-shirdfspike" {
  name            = "adf-shir-lg-shirdfspike"
  data_factory_id = azurerm_data_factory.adf-lg-shirdfspike.id
}

#################
# Linked Services
#################
resource "azurerm_data_factory_linked_service_key_vault" "ls-adf-lg-shirdfspike-keyvault" {
    name            = "ls-adf-lg-shirdfspike-keyvault"
    data_factory_id = azurerm_data_factory.adf-lg-shirdfspike.id
    key_vault_id    = azurerm_key_vault.kv-lg-shirdfspike2.id
}

resource "azurerm_data_factory_linked_service_azure_file_storage" "ls-adf-lg-shirdfspike-storage-sink" {
  name              = "ls-adf-lg-shirdfspike-sink"
  data_factory_id = azurerm_data_factory.adf-lg-shirdfspike.id
  connection_string = "DefaultEndpointsProtocol=https;AccountName=${azurerm_storage_account.st-lg-shirdfspike-sink.name};EndpointSuffix=core.windows.net;"
  file_share = azurerm_storage_share.st-lg-shirdfspike-sink-share.name
  key_vault_password {
    linked_service_name = azurerm_data_factory_linked_service_key_vault.ls-adf-lg-shirdfspike-keyvault.name
    secret_name = azurerm_key_vault_secret.vm-lg-shirdfspike-sink-access-key.name
  }
}

resource "azurerm_data_factory_linked_custom_service" "ls-adf-lg-shirdfspike" {
  name                 = "ls-adf-lg-shirdfspike"
  data_factory_id      = azurerm_data_factory.adf-lg-shirdfspike.id
  type                 = "FileServer"
  integration_runtime {
    name = azurerm_data_factory_integration_runtime_self_hosted.adf-shir-lg-shirdfspike.name
  }
  type_properties_json = <<JSON
    {

        "host": "C:\\\\ExampleSharingFolder",
        "userId": "adminuser",
        "password": {
            "type": "AzureKeyVaultSecret",
            "secretName": "filesource-admin-password",
            "store": {
                "referenceName": "${azurerm_data_factory_linked_service_key_vault.ls-adf-lg-shirdfspike-keyvault.name}",
                "type": "LinkedServiceReference"
            }
        }
    }
    JSON
}

#################
# Data Sets
#################

resource "azurerm_data_factory_custom_dataset" "adfp-lg-shirdfspike-source" {
  name                = "adfp_lg_shirdfspike_source"
  data_factory_id      = azurerm_data_factory.adf-lg-shirdfspike.id
  type = "Binary"
  linked_service {
    name = azurerm_data_factory_linked_custom_service.ls-adf-lg-shirdfspike.name
  }
  type_properties_json = <<JSON
    {
        "location": {
            "type": "FileServerLocation",
            "folderPath": "inputFolder1"
        } 
    }
  JSON
}

resource "azurerm_data_factory_custom_dataset" "adfp-lg-shirdfspike-sink" {
  name            = "adfp_lg_shirdfspike_sink"
  data_factory_id      = azurerm_data_factory.adf-lg-shirdfspike.id
  type            = "Binary"

  linked_service {
    name = azurerm_data_factory_linked_service_azure_file_storage.ls-adf-lg-shirdfspike-storage-sink.name
  }

  type_properties_json = <<JSON
    {
        "location": {
            "container":"${azurerm_storage_container.st-lg-shirdfspike-sink-container.name}",
            "folderPath": "/",
            "type":"AzureFileStorageLocation"
        }
    }
JSON
}


resource "azurerm_data_factory_pipeline" "adfp-lg-shirdfspike" {
  name            = "adfp-lg-shirdfspike"
  data_factory_id      = azurerm_data_factory.adf-lg-shirdfspike.id
  activities_json = <<JSON
    [
        {
            "name": "Copy data1",
            "type": "Copy",
            "dependsOn": [],
            "policy": {
                "timeout": "7.00:00:00",
                "retry": 0,
                "retryIntervalInSeconds": 30,
                "secureOutput": false,
                "secureInput": false
            },
            "typeProperties": {
                "source": {
                    "type": "BinarySource",
                    "storeSettings": {
                        "type": "FileServerReadSettings",
                        "recursive": true,
                        "deleteFilesAfterCompletion": false
                    },
                    "formatSettings": {
                        "type": "BinaryReadSettings"
                    }
                },
                "sink": {
                    "type": "BinarySink",
                    "storeSettings": {
                        "type": "AzureFileStorageWriteSettings"
                    }
                },
                "enableStaging": false
            },
            "inputs": [
                {
                    "referenceName": "${azurerm_data_factory_custom_dataset.adfp-lg-shirdfspike-source.name}",
                    "type": "DatasetReference"
                }
            ],
            "outputs": [
                {
                    "referenceName": "${azurerm_data_factory_custom_dataset.adfp-lg-shirdfspike-sink.name}",
                    "type": "DatasetReference"
                }
            ]
        }
    ]
  JSON
}