


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
