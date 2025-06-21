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

