resource "aws_route53_zone" "example_com" {
  name    = "example.com"
  comment = "HostedZone created by Route53 Registrar"
}

resource "aws_route53_zone" "example_net" {
  name    = "example.net"
  comment = "HostedZone created by Route53 Registrar"
}

resource "aws_route53_record" "example_net_mx" {
  zone_id = aws_route53_zone.example_net.zone_id
  name    = "example.net"
  type    = "MX"
  ttl     = 600
  records = ["10 inbound-smtp.us-east-1.amazonaws.com"]
}

resource "aws_route53_record" "example_net_txt" {
  zone_id = aws_route53_zone.example_net.zone_id
  name    = "example.net"
  type    = "TXT"
  ttl     = 300
  records = ["zoho-verification=zb00000000.zmverify.zoho.com"]
}

resource "aws_route53_record" "example_net_ses_txt" {
  zone_id = aws_route53_zone.example_net.zone_id
  name    = "_amazonses.example.net"
  type    = "TXT"
  ttl     = 600
  records = ["REPLACE_WITH_SES_VERIFICATION_TOKEN"]
}

resource "aws_acm_certificate" "wildcard_example_com" {
  domain_name       = "*.example.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "wildcard_example_com_validation" {
  for_each = {
    for dvo in aws_acm_certificate.wildcard_example_com.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = aws_route53_zone.example_com.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "wildcard_example_com" {
  certificate_arn         = aws_acm_certificate.wildcard_example_com.arn
  validation_record_fqdns = [for record in aws_route53_record.wildcard_example_com_validation : record.fqdn]
}
