resource "aws_vpc" "cloud-lab" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags {
      Name = "cloud-lab-${var.hostname}"
  }
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
  gateway_id             = "${aws_nat_gateway.gw.id}"
}

resource "aws_route_table" "direct" {
    vpc_id = "${aws_vpc.cloud-lab.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }
}

resource "aws_route_table_association" "direct" {
    subnet_id = "${aws_subnet.frontend.id}"
    route_table_id = "${aws_route_table.direct.id}"
}

resource "aws_nat_gateway" "gw" {
    allocation_id = "${aws_eip.nat.id}"
    subnet_id = "${aws_subnet.frontend.id}"
  #  depends_on = ["${aws_internet_gateway.default}"]
}

# Create a subnets for different type of resources
resource "aws_subnet" "frontend" {
  vpc_id                  = "${aws_vpc.cloud-lab.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}


resource "aws_subnet" "backend-a" {
  vpc_id                  = "${aws_vpc.cloud-lab.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false

}


resource "aws_subnet" "backend-b" {
  vpc_id                  = "${aws_vpc.cloud-lab.id}"
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = false

}

resource "aws_subnet" "backend-c" {
  vpc_id                  = "${aws_vpc.cloud-lab.id}"
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = false

}

resource "aws_subnet" "database" {
  vpc_id                  = "${aws_vpc.cloud-lab.id}"
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = false

}

resource "aws_subnet" "admin" {
  vpc_id                  = "${aws_vpc.cloud-lab.id}"
  cidr_block              = "10.0.200.0/24"
  map_public_ip_on_launch = false

}
