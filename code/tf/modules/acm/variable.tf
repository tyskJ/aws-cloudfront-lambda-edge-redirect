# ╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
# ║ CloudFront Lambda@Edge redirect Stack - Terraform variable.tf variable                                                                           ║
# ╠══════════════════════════════════╤═══════════════════════════════════╤═══════════════════════════════════════════════════════════════════════════╣
# ║ alb_cert_issue_domain_name       │ string                            │ Domain name of the certificate to be issued.                              ║
# ║ alb_hostzone_id                  │ string                            │ Hostzone id.                                                              ║
# ║ cloudfront_cert_issue_domain_name│ string                            │ Domain name of the certificate to be issued.                              ║
# ║ cloudfront_hostzone_id           │ string                            │ Hostzone id.                                                              ║
# ╚══════════════════════════════════╧═══════════════════════════════════╧═══════════════════════════════════════════════════════════════════════════╝

variable "alb_cert_issue_domain_name" {
  type        = string
  description = "Domain name for which the alb certificate should be issued."
}

variable "alb_hostzone_id" {
  type        = string
  description = "Hostzone id for ALB."
}

variable "cloudfront_cert_issue_domain_name" {
  type        = string
  description = "Domain name for which the cloudfront certificate should be issued."
}

variable "cloudfront_hostzone_id" {
  type        = string
  description = "Hostzone id for CloudFront."
}
