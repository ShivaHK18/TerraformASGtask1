provider "aws" {
  region = "ap-south-1"
}

resource "aws_security_group" "allow_all_traffic" {
  name = "allow_all_traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all_traffic"
  }
}

resource "aws_launch_template" "launch_template" {
  name           = "launch_template"
  image_id       = "ami-0d473344347276854"
  instance_type  = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }

  user_data = base64encode(file("user_data.sh"))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "autoscaling_group_instance"
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.allow_all_traffic.id]
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  desired_capacity     = 2
  max_size             = 2
  min_size             = 2
  vpc_zone_identifier  = ["subnet-05ef57def0be54b6b"]

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "autoscaling_group-instance"
    propagate_at_launch = true
  }
}
