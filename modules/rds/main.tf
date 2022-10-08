resource "aws_rds_cluster_parameter_group" "parameter_group" {
  name   = "practice-${var.infra_env}-pg-aurora-cluster"
  family = "aurora-mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "max_allowed_packet"
    value = "1073741824"
  }

  tags = {
    Name        = "practice ${var.infra_env} RDS Parameter Group - Aurora Cluster"
    Environment = var.infra_env
    Project     = "practice.dev"
    ManagedBy   = "terraform"
    Type        = "aurora"
  }
}

resource "aws_db_parameter_group" "db_parameter_group" {
  # Name is used in aws_rds_cluster::db_parameter_group_name parameter
  name   = "practice-${var.infra_env}-pg-aurora"
  family = "aurora-mysql8.0"

  tags = {
    Name        = "practice ${var.infra_env} RDS Parameter Group - Aurora"
    Environment = var.infra_env
    Project     = "practice.dev"
    ManagedBy   = "terraform"
    Type        = "aurora"
  }
}

module "rds-aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "7.5.1"

  name           = "practice-${var.infra_env}-aurora-mysql"
  engine         = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.02.1"
  instance_class = var.instance_type

  vpc_id  = var.vpc_id
  subnets = var.subnets

  db_parameter_group_name         = aws_db_parameter_group.db_parameter_group.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.parameter_group.name

  create_random_password = false
  master_username        = var.master_username
  master_password        = var.master_password

  tags = {
    Environment = var.infra_env
    Project     = "practice.dev"
    ManagedBy   = "terraform"
    Type        = "aurora"
  }
}
