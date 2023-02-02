terraform {

  cloud {
    organization = "magicskunk"

    workspaces {
      name = "global-nonprod-cli"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.50.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = ">= 1.3.6"
}
