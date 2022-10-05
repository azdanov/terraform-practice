terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.33.0"
    }
  }
  backend "s3" {
    bucket  = "azdanov-practice-terraform"
    key     = "practice/terraform.tfstate"
    profile = "default"
    region  = "eu-north-1"
  }
}

variable "infra_env" {
  type        = string
  description = "infrastucture environment"
  default     = "staging"
}

variable "default_region" {
  type        = string
  description = "the region to deploy to"
  default     = "eu-north-1"
}

variable "instance_size" {
  type        = string
  description = "the size of the instance"
  default     = "t3.micro"
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

resource "aws_instance" "practice" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_size
  tags = {
    Name        = "practice-${var.infra_env}-web"
    Project     = "practice.dev"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
  lifecycle {
    create_before_destroy = true
  }
  root_block_device {
    volume_size = 8
  }
}

resource "aws_eip" "practice_eip" {
  vpc = true
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name        = "practice-${var.infra_env}-web-eip"
    Project     = "practice.dev"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

resource "aws_eip_association" "practice_eip_association" {
  instance_id   = aws_instance.practice.id
  allocation_id = aws_eip.practice_eip.id
}
