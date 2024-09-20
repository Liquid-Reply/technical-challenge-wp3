terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }

    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }

    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
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
  features {
    key_vault {
         purge_soft_deleted_secrets_on_destroy = true
         recover_soft_deleted_secrets          = true
       }
  }

  skip_provider_registration = true
  subscription_id            = "7b3d4e1a-f9d3-4450-b88e-759cff82af4d"
}
