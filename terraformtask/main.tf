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
  org_service_url = "https://dev.azure.com/JeffBrownTech"
  use_oidc        = true
}

resource "azurerm_resource_group" "example" {
  name     = "terraformtaskdemo-rg"
  location = "westus"
}

resource "azuredevops_project" "example" {
  name               = "TerraformTask Example"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
  description        = "TerraformTask Example - Managed by Terraform"
}
