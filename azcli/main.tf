terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7"
    }

    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 1.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

provider "azuredevops" {
  org_service_url = "https://dev.azure.com/<organization name>"
  use_oidc        = true
}

resource "azurerm_resource_group" "example" {
  name     = "azcli-rg"
  location = "westus"
}

resource "azuredevops_project" "example" {
  name               = "AzCLI Example"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
  description        = "AzCLI Example - Managed by Terraform"
}
