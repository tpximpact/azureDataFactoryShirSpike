resource "azurerm_virtual_network" "vnet-lg-shirdfspike" {
  name                = "vnet-lg-shirdfspike"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg-lg-shirdfspike.location
  resource_group_name = azurerm_resource_group.rg-lg-shirdfspike.name
}

resource "azurerm_subnet" "snet-lg-shirdfspike-internal" {
  name                 = "snet-lg-shirdfspike-internal"
  resource_group_name = azurerm_resource_group.rg-lg-shirdfspike.name
  virtual_network_name = azurerm_virtual_network.vnet-lg-shirdfspike.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "nic-lg-shirdfspike" {
  name                = "nic-lg-shirdfspike"
  location            = azurerm_resource_group.rg-lg-shirdfspike.location
  resource_group_name = azurerm_resource_group.rg-lg-shirdfspike.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet-lg-shirdfspike-internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip-lg-shirdfspike-filesource.id
  }
}

resource "azurerm_windows_virtual_machine" "vm-lg-shirdfspike-filesource" {
  name                = "shirdfspike-fs"
  location            = azurerm_resource_group.rg-lg-shirdfspike.location
  resource_group_name = azurerm_resource_group.rg-lg-shirdfspike.name
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = var.vm-lg-shirdfspike-filesource-admin-password
  network_interface_ids = [
    azurerm_network_interface.nic-lg-shirdfspike.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "vm_setup_script" {
  name                 = "install_edge2"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm-lg-shirdfspike-filesource.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

 protected_settings = <<PROT
    {
      "fileUris": ["https://raw.githubusercontent.com/Azure/Azure-DataFactory/main/SamplesV2/SelfHostedIntegrationRuntime/AutomationScripts/InstallGatewayOnLocalMachine.ps1"],
      "commandToExecute": "powershell.exe -noprofile -command '${azurerm_data_factory_integration_runtime_self_hosted.adf-shir-lg-shirdfspike.primary_authorization_key}' | powershell -encodedCommand ${textencodebase64(file("setup.ps1"), "UTF-16LE")}"
    }
    PROT

}

resource "azurerm_public_ip" "pip-lg-shirdfspike-filesource" {
  name                = "pip-lg-shirdfspike-filesource"
  location            = azurerm_resource_group.rg-lg-shirdfspike.location
  resource_group_name = azurerm_resource_group.rg-lg-shirdfspike.name
  allocation_method   = "Static"

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_network_security_group" "nsg-lg-shirdfspike-filesource" {
  name                = "nsg-lg-shirdfspike-filesource"
  location            = azurerm_resource_group.rg-lg-shirdfspike.location
  resource_group_name = azurerm_resource_group.rg-lg-shirdfspike.name

  security_rule {
    name                       = "rdp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "213.31.45.251"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_network_interface_security_group_association" "nsg-acc-lg-shirdfspike-filesource" {
  network_interface_id      = azurerm_network_interface.nic-lg-shirdfspike.id
  network_security_group_id = azurerm_network_security_group.nsg-lg-shirdfspike-filesource.id
}