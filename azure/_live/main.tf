# ---------------------------------------------------------------------
# Welcome to the TerraFail Azure Deployment Template!
# ---------------------------------------------------------------------

# One of the great things about terraform is how modularized and
# reusable it allows infrastructure as code to be. To configure and
# deploy any of the reusable modules in this repository, simply specify
# the source and provider details and you'll be on your way to failing
# Compliance as Code tests in no time!

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# WARNING: All the terraform contained in this repository is
# intentionally insecure by design. Do not attempt to deploy these
# resources outside of a dedicated testing environment.
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# ---------------------------------------------------------------------
# Module Definition
# ---------------------------------------------------------------------
module "my_azure_module" {
  source = "../_modules/aks" # Replace with any module path
}

# ---------------------------------------------------------------------
# Backend/Provider Details
# ---------------------------------------------------------------------
terraform {
  required_version = ">= 1.7.5" # Configure the minimum Terraform version

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.104.2" # Configure the AWS provider version
    }
  }

  backend "backend" { # Configure a backend to manage .tfstate files
    resource_group_name  = "terraform-rg"
    storage_account_name = "tstate-storage"
    container_name       = "tfstate"
    key                  = "/path/to/my/key"
  }
}

provider "azurerm" {
  features {}
}
