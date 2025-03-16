# ╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
# ║ CloudFront Lambda@Edge redirect Stack - Terraform main.tf resource                                                                               ║
# ╠════════════════════════════════════╤═════════════════════════════════════════════════════╤═══════════════════════════════════════════════════════╣
# ║ alb_cert                           │ aws_acm_certificate                                 │ Public Certificate for ALB.                           ║
# ║ alb_cert_cname_record              │ aws_route53_record                                  │ CNAME record for alb certificate.                     ║
# ║ alb_cert_cname_record_valid        │ aws_acm_certificate_validation                      │ Verification of CNAME records for alb certificates.   ║
# ║ cloudfront_cert                    │ aws_acm_certificate                                 │ Public Certificate for CloudFront.                    ║
# ║ cloudfront_cert_cname_record       │ aws_route53_record                                  │ CNAME record for cloudfront certificate.              ║
# ║ cloudfront_cert_cname_record_valid │ aws_acm_certificate_validation                      │ Verification of CNAME records for cloudfront cert.    ║
# ╚════════════════════════════════════╧═════════════════════════════════════════════════════╧═══════════════════════════════════════════════════════╝

# Certificate Issue
resource "aws_acm_certificate" "alb_cert" {
  domain_name       = var.alb_cert_issue_domain_name
  validation_method = "DNS"
  tags = {
    Name = "alb-cert"
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Create certificate validation CNAME record
resource "aws_route53_record" "alb_cert_cname_record" {
  for_each = {
    for dvo in aws_acm_certificate.alb_cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = var.alb_hostzone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 60
}

# Verification of CNAME records for alb certificates
resource "aws_acm_certificate_validation" "alb_cert_cname_record_valid" {
  certificate_arn         = aws_acm_certificate.alb_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.alb_cert_cname_record : record.fqdn]
}

# Certificate Issue
resource "aws_acm_certificate" "cloudfront_cert" {
  domain_name       = var.cloudfront_cert_issue_domain_name
  validation_method = "DNS"
  provider          = aws.global
  tags = {
    Name = "cloudfront-cert"
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Create certificate validation CNAME record
resource "aws_route53_record" "cloudfront_cert_cname_record" {
  for_each = {
    for dvo in aws_acm_certificate.cloudfront_cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = var.cloudfront_hostzone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 60
}

# Verification of CNAME records for alb certificates
resource "aws_acm_certificate_validation" "cloudfront_cert_cname_record_valid" {
  certificate_arn         = aws_acm_certificate.cloudfront_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cloudfront_cert_cname_record : record.fqdn]
  provider                = aws.global
}
