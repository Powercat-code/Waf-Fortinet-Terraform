terraform {
  required_version = ">= 0.13.0"

  backend "s3" {
    bucket  = "s37-prod-terraform"
    key     = "msk/wafv2/terraform.tfstate"
    region  = "us-west-2"
    profile = "production"
  }

  required_providers {
    aws  = ">= 3.68.0"
    null = "~>2.0"
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
}