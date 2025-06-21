
// creating vpc 1

resource "aws_vpc" "create_vpc" {
    cidr_block           = var.gives_cidr_to_vpc
    
    tags = {
        Name = "mad-machine"
    }
    
    # provider = aws.eu-central-1  # Uncomment if you have a specific provider configuration
  
}


// creating 2 subnets in vpc 

resource "aws_subnet" "create_subnet" {
    count = length(var.gives_cidr_to_subnets)
    
    vpc_id            = aws_vpc.create_vpc.id
    cidr_block        = var.gives_cidr_to_subnets[count.index]
    availability_zone = var.gives_availability_zones_subnets[count.index]
    
    tags = {
        Name = "mad-machine-subnet-${count.index + 1}"
    }
    
    # provider = aws.eu-central-1  # Uncomment if you have a specific provider configuration
  
}



//3 creating internet gateway
resource "aws_internet_gateway" "create_igw" {
    vpc_id = aws_vpc.create_vpc.id
    
    tags = {
        Name = "mad-machine-igw"
    }
    
    # provider = aws.eu-central-1  # Uncomment if you have a specific provider configuration
  
}


// 4 creating 2 route tables and associating them with the vpc and internet gateway

resource "aws_route_table" "create_route_table" {
    count = 2
    vpc_id = aws_vpc.create_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.create_igw.id
    }

    tags = {
        Name = "public-RT-table-${count.index + 1}"
    }
}




// 5 subnet associations 

// associate the 2 subnets with 2 route tables

resource "aws_route_table_association" "create_route_table_association" {
    count = length(var.gives_cidr_to_subnets)
    
    subnet_id      = aws_subnet.create_subnet[count.index].id
    route_table_id = aws_route_table.create_route_table[count.index].id  // Assuming both subnets use the first route table
    
}






// 7 need 2 amazon linux ami ids for creating instances in 2 subnets dynamically

data "aws_ami" "amazon_linux_2023" {
    most_recent = true
    owners      = ["amazon"]  # Amazon's official AMIs

    filter {
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]  # Adjust the filter to match your requirements
    }
    filter {
        name   = "architecture"
        values = ["x86_64"]  # Adjust if you need a different architecture
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]  # Ensure the AMI is HVM type
    }
    filter {
        name   = "state"
        values = ["available"]  # Ensure the AMI is available
    }
    filter {
        name   = "root-device-type"
        values = ["ebs"]  # Ensure the AMI uses EBS as the root device
    }
    filter {
        name   = "image-type"
        values = ["machine"]  # Ensure the AMI is a machine image
    }
    filter {
        name   = "owner-alias"
        values = ["amazon"]  # Ensure the AMI is owned by Amazon
    }
    filter {
        name   = "platform-details"
        values = ["Linux/UNIX"]  # Ensure the AMI is for Linux/UNIX
    }
    
}


// 8 creating 2 instances in the first and second subnet with 2 different userdata script to install httpd and display public and private IPs


resource "aws_instance" "create_instance" {
  count = length(var.gives_cidr_to_subnets)
  
  # Instance Configuration
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.create_subnet[count.index].id
  key_name               = "my-ec2-key"
  vpc_security_group_ids = [aws_security_group.create_security_group.id]
  associate_public_ip_address = true

  # Improved User Data Handling
   
user_data = count.index == 0 ? file("user_script.sh") : file("user_script_1.sh")




  # Enhanced Dependencies
  depends_on = [
    aws_security_group.create_security_group,
    aws_internet_gateway.create_igw,  # Explicit dependency
    aws_subnet.create_subnet          # Explicit dependency
  ]

  # Tags
  tags = {
    Name = "mad-machine-instance-${count.index + 1}"
  }
}


// 9 creating security group with port 22 ,80 for instance 

resource "aws_security_group" "create_security_group" {
    name        = "mad-machine-sg"
    description = "Security group for mad machine"
    vpc_id      = aws_vpc.create_vpc.id
    
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # Allow SSH access from anywhere
    }
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP traffic from anywhere
    }   
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # Allow HTTPS traffic from anywhere
    }

    tags = {
        Name = "Sg-for-EC2"  # Tag for the security group
    }

egress {      
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
}


}



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


output "load_balancer_arn" {
    value = aws_lb.create_load_balancer.arn
  
}

// need output for public IPs of instances
output "instance_public_ips" {
    value = aws_instance.create_instance[*].public_ip
}


// need output for Lb DNS name
output "load_balancer_dns_name" {
    value = aws_lb.create_load_balancer.dns_name
}


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


##########################
# 1. Create Route53 Hosted Zone for hydcafe.in
# This will create a DNS zone in Route53 where you can manage DNS records for your domain.
##########################
resource "aws_route53_zone" "hydcafe_zone" {
  name = "hydcafe.in"

  tags = {
    Name = "hydcafe-zone"
  }
}



/* background out put of above 
aws_route53_zone.hydcafe_zone.zone_id       # e.g., "Z04537652EXAMPLEC"
aws_route53_zone.hydcafe_zone.name_servers  # e.g., ["ns-123.awsdns-45.com", "ns-456.awsdns-78.net", ...]
*/


# Output the NS records of the hosted zone
# You will need to update your domain registrar (GoDaddy) with these NS values to delegate your domain to Route53
output "name_servers" {
  value       = aws_route53_zone.hydcafe_zone.name_servers
  description = "NS records to update in GoDaddy"
}


##########################
# 2. Request ACM Certificate for hydcafe.in (DNS Validation)
# This requests an SSL certificate from AWS ACM for your domain.
##########################
resource "aws_acm_certificate" "hydcafe_cert" {
  domain_name       = "hydcafe.in"
  validation_method = "DNS"

  tags = {
    Name = "hydcafe-cert"
  }

  # Ensure the hosted zone is created before certificate request
  depends_on = [aws_route53_zone.hydcafe_zone]
}


/* background out of above 
[
  {
    "domain_name": "hydcafe.in",
    "resource_record_name": "_abc123.hydcafe.in.",
    "resource_record_type": "CNAME",
    "resource_record_value": "_xyz456.acm-validations.aws."
  }
]


*/



##########################
# 3. Create Route53 DNS validation record for ACM
# ACM requires you to prove ownership of the domain by adding specific DNS records.
# This block creates those DNS records automatically.
##########################
locals {
  dvo = tolist(aws_acm_certificate.hydcafe_cert.domain_validation_options)[0]

}


//above line output

/*local.dvo.resource_record_name   # "_abc123.hydcafe.in"
local.dvo.resource_record_type   # "CNAME"
local.dvo.resource_record_value  # "_xyz456.acm-validations.aws"*/


// Creates a CNAME record in Route 53 to validate the SSL certificate.

resource "aws_route53_record" "cert_validation" {
  zone_id = aws_route53_zone.hydcafe_zone.zone_id

  name    = local.dvo.resource_record_name
  type    = local.dvo.resource_record_type
  ttl     = 300
  records = [local.dvo.resource_record_value]

  depends_on = [aws_route53_zone.hydcafe_zone, aws_acm_certificate.hydcafe_cert]

}


// output----- aws_route53_record.cert_validation.fqdn // fully qualified domain name .

//why fdqn here TF automatically generates it to use further.

// what has fqdn

/*Record name: _abc123.hydcafe.in
Type:        CNAME
Value:       _xyz456.acm-validations.aws*/







##########################
# 4. "Here’s the certificate (ARN), and here's the DNS record (FQDN) that proves I own the domain. Now validate it."
##########################

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.hydcafe_cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]     //see here it using the fdqn values 

  depends_on = [aws_route53_record.cert_validation]
}


/*  background output
aws_acm_certificate_validation.cert_validation.certificate_arn  # Returns same ARN as input if success

ssl certificate arn ...........uniq no. for our ssl certificate .

*/






##########################
# 5. Route53 A Record pointing domain to your ALB
# This creates an A record in your hosted zone that points your domain (hydcafe.in) to the Application Load Balancer.
##########################
resource "aws_route53_record" "hydcafe_record" {
  zone_id = aws_route53_zone.hydcafe_zone.zone_id
  name    = "hydcafe.in"
  type    = "A"

  alias {
    name                   = aws_lb.create_load_balancer.dns_name
    zone_id                = aws_lb.create_load_balancer.zone_id
    evaluate_target_health = true
  }

  depends_on = [aws_acm_certificate_validation.cert_validation]

}



