variable "public_key_path" {
  description = "~/.ssh/terraform.pub"
}

variable "key_name" {
  description = "terraform"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default = "us-east-1"
}

# Centos Atomic 8.20160404
variable "aws_amis" {
  default = {
    eu-west-1 = "ami-0b8a0878"
    us-east-1 = "ami-114f5c7b"
    us-west-1 = "ami-e03e4180"
    us-west-2 = "ami-f0e01790"
  }
}
