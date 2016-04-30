variable "public_key_path" {
  description = "Public SSH Keypath"
  default = "~/.ssh/terraform"
}


variable "aws_region" {
  description = "AWS region to launch servers."
  default = "us-east-1"
}
