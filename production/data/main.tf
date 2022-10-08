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
  default     = "production"
}

variable "default_region" {
  type        = string
  description = "the region this infrastructure is in"
  default     = "eu-north-1"
}

variable "db_user" {
  type        = string
  description = "the database user"
}

variable "db_pass" {
  type        = string
  description = "the database password"
}

data "aws_vpc" "vpc" {
  tags = {
    Name        = "practice-${var.infra_env}-vpc"
    Project     = "practice.dev"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

data "aws_subnets" "database_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    Name        = "practice-${var.infra_env}-vpc"
    Project     = "practice.dev"
    Environment = var.infra_env
    ManagedBy   = "terraform"
    Role        = "database"
  }
}

module "database" {
  source = "../../modules/rds"

  infra_env       = var.infra_env
  instance_type   = "db.t3.medium"
  subnets         = data.aws_subnets.database_subnets.ids
  vpc_id          = data.aws_vpc.vpc.id
  master_username = var.db_user
  master_password = var.db_pass
}
