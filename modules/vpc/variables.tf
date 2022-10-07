variable "public_subnet_numbers" {
  type = map(number)

  description = "Map of AZ to a number that should be used for public subnets"

  default = {
    "eu-north-1a" = 1
    "eu-north-1b" = 2
    "eu-north-1c" = 3
  }
}

variable "private_subnet_numbers" {
  type = map(number)

  description = "Map of AZ to a number that should be used for private subnets"

  default = {
    "eu-north-1a" = 4
    "eu-north-1b" = 5
    "eu-north-1c" = 6
  }
}

variable "vpc_cidr" {
  type        = string
  description = "The IP range to use for the VPC"
  default     = "10.0.0.0/16"
}

variable "infra_env" {
  type        = string
  description = "infrastructure environment"
}
