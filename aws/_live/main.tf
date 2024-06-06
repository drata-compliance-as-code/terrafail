# ---------------------------------------------------------------------
# Welcome to the TerraFail AWS Deployment Template!
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
module "my_tf_module" {
  source = "../_modules/api_gateway" # Replace with any module path
}

# ---------------------------------------------------------------------
# Backend/Provider Details
# ---------------------------------------------------------------------
terraform {
  required_version = ">= 1.7.5" # Configure the minimum Terraform version

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.50.0" # Configure the AWS provider version
    }
  }

  backend "backend" { # Configure a backend to manage .tfstate files
    bucket         = "tfstate-bucket"
    key            = "/path/to/my/key"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "terraform-lock"
    profile        = "sandbox"
  }
}

provider "aws" { # Configure CSP region and profile
  region  = "us-east-2"
  profile = "my_profile"
}
