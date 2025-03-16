# ╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
# ║ CloudFront Lambda@Edge redirect Stack - Terraform variable.tf variable                                                                           ║
# ╠══════════════════════════════════╤═══════════════════════════════════╤═══════════════════════════════════════════════════════════════════════════╣
# ║ alb_cert_issue_domain_name       │ string                            │ Domain name of the certificate to be issued.                              ║
# ║ alb_hostzone_id                  │ string                            │ Hostzone id.                                                              ║
# ║ alb_fqdn                         │ string                            │ ALB FQDN.                                                                 ║
# ║ bucket_name                      │ string                            │ S3 Bucket Name.                                                           ║
# ║ cloudfront_cert_issue_domain_name│ string                            │ Domain name of the certificate to be issued.                              ║
# ║ cloudfront_hostzone_id           │ string                            │ Hostzone id.                                                              ║
# ║ cloudfront_fqdn                  │ string                            │ CloudFront FQDN.                                                          ║
# ╚══════════════════════════════════╧═══════════════════════════════════╧═══════════════════════════════════════════════════════════════════════════╝

variable "alb_cert_issue_domain_name" {
  type        = string
  description = "Domain name for which the alb certificate should be issued."
}

variable "alb_hostzone_id" {
  type        = string
  description = "Hostzone id for ALB."
}

variable "alb_fqdn" {
  type        = string
  description = "ALB FQDN."
}

variable "bucket_name" {
  type        = string
  description = "S3 Bucket Name."
}

variable "cloudfront_cert_issue_domain_name" {
  type        = string
  description = "Domain name for which the cloudfront certificate should be issued."
}

variable "cloudfront_hostzone_id" {
  type        = string
  description = "Hostzone id for CloudFront."
}

variable "cloudfront_fqdn" {
  type        = string
  description = "CloudFront FQDN."
}
