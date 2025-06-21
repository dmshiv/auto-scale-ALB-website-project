// need output for public IPs of instances
output "instance_public_ips" {
    value = aws_instance.create_instance[*].public_ip
}


// need output for Lb DNS name
output "load_balancer_dns_name" {
    value = aws_lb.create_load_balancer.dns_name
}