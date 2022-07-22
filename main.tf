terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.14"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-lg-shirdfspike-tf"
    storage_account_name = "stlgshirdfspiketfstate"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "rg-lg-shirdfspike" {
  name     = "rg-lg-shirdfspike"
  location = "UK South"
}

