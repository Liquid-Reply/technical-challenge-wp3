terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "XXX"
    storage_account_name = "XXX"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true
  }

}

provider "azurerm" {
  features {}
  
  skip_provider_registration = true
  subscription_id = "XXX"
}
