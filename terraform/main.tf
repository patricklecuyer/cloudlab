# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "cloud-lab" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_eip" "nat" {
  vpc = true
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.cloud-lab.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "direct_internet_access" {
  route_table_id         = "${aws_vpc.cloud-lab.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
  nat_gateway_id = "${aws_nat_gateway.gw.id}"
}

resource "aws_nat_gateway" "gw" {
    allocation_id = "${aws_eip.nat.id}"
    subnet_id = "${aws_subnet.frontend.id}"
}

# Create a subnets for different type of resources
resource "aws_subnet" "frontend" {
  vpc_id                  = "${aws_vpc.cloud-lab.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}


resource "aws_subnet" "backend" {
  vpc_id                  = "${aws_vpc.cloud-lab.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "admin" {
  vpc_id                  = "${aws_vpc.cloud-lab.id}"
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = false
}



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


resource "aws_elb" "web" {
  name = "cloudlab-elb-${var.hostname}"

  subnets         = ["${aws_subnet.frontend.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  instances       = ["${aws_instance.web.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "jump" {
    connection {
      user = "ec2-user"
      private_key = "~/.ssh/id_rsa"
  }

  instance_type = "t2.small"

  ami = "ami-08111162"

  key_name = "${aws_key_pair.auth.id}"

  vpc_security_group_ids = ["${aws_security_group.default.id}"]


  subnet_id = "${aws_subnet.frontend.id}"

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
    ]
  }
}


resource "aws_instance" "web" {
    connection {
      user = "ec2-user"
      bastion_host = "${aws_instance.jump.public_ip}"
      private_key = "${file("~/.ssh/id_rsa")}"
  }

  instance_type = "t2.small"

  ami = "ami-08111162"

  key_name = "${aws_key_pair.auth.id}"

  vpc_security_group_ids = ["${aws_security_group.default.id}"]


  subnet_id = "${aws_subnet.backend.id}"

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum -y install nginx",
      "sudo service nginx start"
    ]
  }
}
