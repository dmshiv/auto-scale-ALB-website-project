
// auto scaling group***************

// need some standard one template for your EC2 instances

/// Template that has preconfigured settings of ec2 

resource "aws_launch_template" "mad_machine_template" {
  name_prefix   = "mad-machine-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"
  key_name      = "my-ec2-key"

  network_interfaces {
    security_groups = [aws_security_group.create_security_group.id]
    associate_public_ip_address = true
  }

  user_data = filebase64("user_script.sh")

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "mad-machine-instance"
    }
  }
}


// now attaching our ALB to the template 

resource "aws_autoscaling_group" "create_ASG" {
  desired_capacity     = 2
  max_size             = 5
  min_size             = 1
  vpc_zone_identifier  = aws_subnet.create_subnet[*].id
  health_check_type    = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.mad_machine_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.create_target_group.arn]


  tag {
    key                 = "Name"
    value               = "mad-machine-asg-instance"
    propagate_at_launch = true
  }
}
