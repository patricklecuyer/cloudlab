# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb" {
  name        = "cloudlab_elb"
  description = "ELB for the web app"
  vpc_id      = "${aws_vpc.cloud-lab.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "admin" {
  name        = "Security group for admin machine"
  description = "Saltstack master security group"
  vpc_id      = "${aws_vpc.cloud-lab.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 4505
    to_port     = 4505
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 4506
    to_port     = 4506
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}


# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "default security group"
  description = "basic default security group"
  vpc_id      = "${aws_vpc.cloud-lab.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # HTTPS access from the VPC
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
