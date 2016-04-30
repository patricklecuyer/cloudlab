
#Temporary certificate to initialize the ELB. Lambda job will replace with Let's Encrypt
resource "aws_iam_server_certificate" "temp_cert" {
  name = "temp_cert"
  certificate_body = "${file("files/server.crt")}"
  private_key = "${file("files/server.key")}"
}

resource "aws_elb" "web" {
  name = "cloudlab-elb-${var.hostname}"

  subnets         = ["${aws_subnet.frontend.id}"]
  security_groups = ["${aws_security_group.elb.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 443
    lb_protocol       = "https"
    ssl_certificate_id = "${aws_iam_server_certificate.temp_cert.id}"
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

resource "aws_instance" "admin" {
    connection {
      user = "ec2-user"
      private_key = "~/.ssh/id_rsa"
      bastion_host = "${aws_instance.jump.public_ip}"
      private_key = "${file("~/.ssh/id_rsa")}"
  }

  instance_type = "t2.small"

  ami = "ami-08111162"

  key_name = "${aws_key_pair.auth.id}"

  vpc_security_group_ids = ["${aws_security_group.default.id}", "${aws_security_group.admin.id}"]


  subnet_id = "${aws_subnet.admin.id}"

  provisioner "remote-exec" {
    inline = [
      "mkdir /tmp/saltconf"
    ]
  }

  provisioner "file" {
    source = "files/salt-master.conf"
    destination = "/tmp/saltconf/master"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum -y install epel-release",
      "sudo yum -y install pip libgit2",
      "pip install pygit2",
      "sudo yum -y install https://repo.saltstack.com/yum/amazon/salt-amzn-repo-2015.8-1.ami.noarch.rpm",
      "sudo yum -y install salt-master",
      "sudo cp /tmp/saltconf/master /etc/salt/master",
      "sudo /etc/init.d/salt-master start"
    ]
  }
}
