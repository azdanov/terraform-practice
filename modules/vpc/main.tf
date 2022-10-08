module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.16.0"

  name = "practice-${var.infra_env}-vpc"
  cidr = var.vpc_cidr

  azs = var.azs

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets

  tags = {
    Name        = "practice-${var.infra_env}-vpc"
    Project     = "practice.dev"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }

  private_subnet_tags = {
    Role = "private"
  }

  public_subnet_tags = {
    Role = "public"
  }

  database_subnet_tags = {
    Role = "database"
  }
}
