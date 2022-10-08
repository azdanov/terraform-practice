terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.33.0"
    }
  }
  backend "s3" {
    bucket         = "terraform-practice"
    key            = "practice/terraform.tfstate"
    region         = "eu-north-1"
    profile        = "default"
    dynamodb_table = "terraform-practice"
  }
}

locals {
  infra_env = terraform.workspace == "default" ? "dev" : terraform.workspace
}

variable "default_region" {
  type        = string
  description = "the region to deploy to"
  default     = "eu-north-1"
}

provider "aws" {
  region  = var.default_region
  profile = "default"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"] # Canonical
}

module "ec2_app" {
  source = "./modules/ec2"

  infra_env       = local.infra_env
  infra_role      = "web"
  instance_size   = "t3.micro"
  instance_ami    = data.aws_ami.ubuntu.id
  subnets         = module.vpc.vpc_public_subnets
  security_groups = [module.vpc.security_group_public]
  tags = {
    Name = "practice-${local.infra_env}-web"
  }
  create_eip = true
}

module "ec2_worker" {
  source = "./modules/ec2"

  infra_env                 = local.infra_env
  infra_role                = "worker"
  instance_size             = "t3.micro"
  instance_ami              = data.aws_ami.ubuntu.id
  instance_root_device_size = 12
  subnets                   = module.vpc.vpc_private_subnets
  security_groups           = [module.vpc.security_group_private]
  tags = {
    Name = "practice-${local.infra_env}-worker"
  }
  create_eip = false
}

module "vpc" {
  source = "./modules/vpc"

  infra_env       = local.infra_env
  vpc_cidr        = "10.0.0.0/17"
  azs             = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  public_subnets  = slice(cidrsubnets("10.0.0.0/17", 4, 4, 4, 4, 4, 4), 0, 3)
  private_subnets = slice(cidrsubnets("10.0.0.0/17", 4, 4, 4, 4, 4, 4), 3, 6)
}
