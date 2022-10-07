resource "random_shuffle" "subnets" {
  input        = var.subnets
  result_count = 1
}

resource "aws_instance" "practice_web" {
  ami           = var.instance_ami
  instance_type = var.instance_size
  tags = merge(
    {
      Name        = "practice-${var.infra_env}"
      Role        = var.infra_role
      Project     = "practice.dev"
      Environment = var.infra_env
      ManagedBy   = "terraform"
    },
    var.tags
  )
  subnet_id              = random_shuffle.subnets.result[0]
  vpc_security_group_ids = var.security_groups
  lifecycle {
    create_before_destroy = true
  }
  root_block_device {
    volume_size = var.instance_root_device_size
  }
}

resource "aws_eip" "practice_addr" {
  count = (var.create_eip) ? 1 : 0
  vpc   = true
  lifecycle {
    # prevent_destroy = true
  }
  tags = {
    Name        = "practice-${var.infra_env}-web-address"
    Role        = var.infra_role
    Project     = "practice.dev"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

resource "aws_eip_association" "eip_assoc" {
  count         = (var.create_eip) ? 1 : 0
  instance_id   = aws_instance.practice_web.id
  allocation_id = aws_eip.practice_addr[0].id
}
