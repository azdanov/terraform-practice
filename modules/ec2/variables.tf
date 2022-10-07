variable "infra_env" {
  type        = string
  description = "infrastucture environment"
}

variable "infra_role" {
  type        = string
  description = "infrastucture purpose"
}

variable "instance_size" {
  type        = string
  description = "the size of the instance"
  default     = "t3.micro"
}

variable "instance_ami" {
  type        = string
  description = "the AMI to use"
}

variable "instance_root_device_size" {
  type        = number
  description = "the size of the blocks in GB"
  default     = 8
}

variable "subnets" {
  type        = list(string)
  description = "valid subnets to assign to server"
}

variable "security_groups" {
  type        = list(string)
  description = "security groups to assign to server"
  default     = []
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "tags for the ec2 instance"
}

variable "create_eip" {
  type        = bool
  default     = false
  description = "whether to create an EIP for the ec2 instance or not"
}
