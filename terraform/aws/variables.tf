variable "public_key_path" {
  description = "Public SSH Keypath"
  default = "/Users/plecuyer/.ssh/id_rsa.pub"
}

variable "hostname" {
  description = "hostname for the main ELB"
  default = "www"
}


variable "key_name" {
  description = "Desired name of AWS key pair"
  default = "terraform"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default = "us-east-1"
}
