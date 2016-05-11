resource "aws_route53_zone" "cr460" {
  name = "cr460.internal"
  vpc_id = "${aws_vpc.cloud-lab.id}"
}

resource "aws_route53_record" "admin" {
   zone_id = "${aws_route53_zone.cr460.zone_id}"
   name = "admin"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.admin.private_ip}"]

}

resource "aws_route53_record" "salt" {
   zone_id = "${aws_route53_zone.cr460.zone_id}"
   name = "salt"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.admin.private_ip}"]

}

resource "aws_vpc_dhcp_options" "domain-name" {
    domain_name = "cr460.internal"
    domain_name_servers = ["10.0.0.2"]
}
resource "aws_vpc_dhcp_options_association" "domain-name" {
    vpc_id = "${aws_vpc.cloud-lab.id}"
    dhcp_options_id = "${aws_vpc_dhcp_options.domain-name.id}"
}
