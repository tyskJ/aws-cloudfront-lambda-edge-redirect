# ╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
# ║ CloudFront Lambda@Edge redirect Stack - Terraform output.tf output                                                                               ║
# ╠═════════════════════════════╤════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
# ║ alb_cert_arn                │ ALB Certificate ARN.                                                                                               ║
# ║ cloudfront_cert_arn         │ CloudFront Certificate ARN.                                                                                        ║
# ╚═════════════════════════════╧════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝

output "alb_cert_arn" {
  description = "ALB Certificate ARN."
  value       = aws_acm_certificate.alb_cert.arn
}

output "cloudfront_cert_arn" {
  description = "CloudFront Certificate ARN."
  value       = aws_acm_certificate.cloudfront_cert.arn
}
