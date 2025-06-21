// 6 need 2 amazon linux ami ids for creating instances in 2 subnets dynamically
// so fetcing those tf does that for us .
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
