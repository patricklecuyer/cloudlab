
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
    ssl_certificate_id = "${aws_iam_server_certificate.temp_cert.arn}"
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

  instance_type = "t2.micro"

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


resource "aws_launch_configuration" "web" {
    image_id = "ami-08111162"
    instance_type = "t2.micro"
    name_prefix = "cloud-lab-web-${var.hostname}-"
    user_data = "${file(\"files/cloud-init-web\")}"
    security_groups = ["${aws_security_group.default.id}"]
    key_name = "${aws_key_pair.auth.id}"


}

resource "aws_autoscaling_group" "web" {
  name = "cloud-lab-web-cluster-${var.hostname}"
  max_size = 10
  min_size = 2
  health_check_grace_period = 300
  health_check_type = "ELB"
  force_delete = true
  load_balancers = ["${aws_elb.web.name}"]
  launch_configuration = "${aws_launch_configuration.web.name}"
  vpc_zone_identifier = ["${aws_subnet.backend-a.id}", "${aws_subnet.backend-b.id}", "${aws_subnet.backend-c.id}"]

}

resource "aws_autoscaling_policy" "web-scaleup" {
  name = "cloud-lab-web-scale"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.web.name}"
}

resource "aws_autoscaling_policy" "web-scaledown" {
  name = "cloud-lab-web-scale"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.web.name}"
}

resource "aws_cloudwatch_metric_alarm" "web-scaleup" {
    alarm_name = "web-scaleup-${var.hostname}"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "120"
    statistic = "Average"
    threshold = "80"
    dimensions {
        AutoScalingGroupName = "${aws_autoscaling_group.web.name}"
    }
    alarm_description = "This metric monitor ec2 cpu utilization for scale up"
    alarm_actions = ["${aws_autoscaling_policy.web-scaleup.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "web-scaledown" {
    alarm_name = "web-scaledown-${var.hostname}"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "120"
    statistic = "Average"
    threshold = "20"
    dimensions {
        AutoScalingGroupName = "${aws_autoscaling_group.web.name}"
    }
    alarm_description = "This metric monitor ec2 cpu utilization for scale down"
    alarm_actions = ["${aws_autoscaling_policy.web-scaledown.arn}"]
}
