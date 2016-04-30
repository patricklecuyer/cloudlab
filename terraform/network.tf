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
}

resource "aws_route_table" "nat" {
    vpc_id = "${aws_vpc.cloud-lab.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_nat_gateway.gw.id}"
    }
}

resource "aws_route_table_association" "backend" {
    subnet_id = "${aws_subnet.backend.id}"
    route_table_id = "${aws_route_table.nat.id}"
}

resource "aws_route_table_association" "admin" {
    subnet_id = "${aws_subnet.admin.id}"
    route_table_id = "${aws_route_table.nat.id}"
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
