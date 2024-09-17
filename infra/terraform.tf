terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate8134"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true
  }

}

provider "azurerm" {
  features {}

  skip_provider_registration = true
  subscription_id            = "7b3d4e1a-f9d3-4450-b88e-759cff82af4d"
}
