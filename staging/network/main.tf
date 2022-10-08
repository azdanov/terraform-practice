terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.33.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
    # profile = "default"
    # region  = "eu-north-1"
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-north-1"
}

variable "infra_env" {
  type        = string
  description = "infrastructure environment"

  default = "production"
}

variable "default_region" {
  type        = string
  description = "the region this infrastructure is in"
  default     = "eu-north-1"
}

locals {
  cidr_subnets = cidrsubnets("10.0.0.0/17", 4, 4, 4, 4, 4, 4, 4, 4, 4)
}

module "vpc" {
  source = "../../modules/vpc"

  infra_env        = var.infra_env
  vpc_cidr         = "10.0.0.0/17"
  azs              = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  public_subnets   = slice(local.cidr_subnets, 0, 3)
  private_subnets  = slice(local.cidr_subnets, 3, 6)
  database_subnets = slice(local.cidr_subnets, 6, 9)
}
