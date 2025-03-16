# ╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
# ║ CloudFront Functions redirect Stack - Terraform main.tf module                                                                                   ║
# ╠═════════════════╤═══════════════════════════════════╤════════════════════════════════════════════════════════════════════════════════════════════╣
# ║ acm             │ ../modules/acm                    │ invoke acm module.                                                                         ║
# ║ web             │ ../modules/web                    │ invoke web module.                                                                         ║
# ║ cloudfront_s3   │ ../modules/cloudfront_s3          │ invoke cloudfront and S3 module.                                                           ║
# ╚═════════════════╧═══════════════════════════════════╧════════════════════════════════════════════════════════════════════════════════════════════╝

module "acm" {
  source = "../modules/acm"

  alb_cert_issue_domain_name        = var.alb_cert_issue_domain_name
  alb_hostzone_id                   = var.alb_hostzone_id
  cloudfront_cert_issue_domain_name = var.cloudfront_cert_issue_domain_name
  cloudfront_hostzone_id            = var.cloudfront_hostzone_id
  providers = {
    aws.global = aws.virginia
  }
}
