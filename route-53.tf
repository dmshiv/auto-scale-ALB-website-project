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


