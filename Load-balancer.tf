// 10 creating load balancer with 2 instances in 2 subnets


resource "aws_lb" "create_load_balancer" {
    name               = "mad-machine-lb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.create_security_group.id]
    subnets            = aws_subnet.create_subnet[*].id  # Use all subnets created

    enable_deletion_protection = false

    tags = {
        Name = "mad-machine-lb"
    }
}



// 11 creating target group for load balancer with 2 instances in 2 subnets

resource "aws_lb_target_group" "create_target_group" {
    name     = "mad-machine-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.create_vpc.id

    health_check {
        path                = "/"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }

    tags = {
        Name = "mad-machine-tg"
    }
}

// 12 registering 2 instances to target group

resource "aws_lb_target_group_attachment" "create_target_group_attachment" {
    count = length(var.gives_cidr_to_subnets)

    target_group_arn = aws_lb_target_group.create_target_group.arn
    target_id        = aws_instance.create_instance[count.index].id
    port             = 80  # Port on which the instances are listening
}


// 13 creating listener for load balancer and redirecting HTTP traffic to HTTPS

# Listener on port 443 to serve HTTPS with certificate
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.create_load_balancer.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.hydcafe_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.create_target_group.arn
  }
}


// whoever hits http must redirected https
resource "aws_lb_listener" "http_redirect" {
  depends_on = [aws_lb.create_load_balancer]

  load_balancer_arn = aws_lb.create_load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}
