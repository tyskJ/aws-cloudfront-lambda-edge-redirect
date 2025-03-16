# ╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
# ║ CloudFront Lambda@Edge redirect Stack - Terraform variable.tf variable                                                                           ║
# ╠══════════════════════════════════╤═══════════════════════════════════╤═══════════════════════════════════════════════════════════════════════════╣
# ║ bucket_name                      │ string                            │ S3 Bucket Name.                                                           ║
# ║ alb_fqdn                         │ string                            │ ALB FQDN.                                                                 ║
# ║ cloudfront_cert_arn              │ string                            │ CloudFront Certificate ARN.                                               ║
# ║ cloudfront_hostzone_id           │ string                            │ Hostzone id.                                                              ║
# ║ cloudfront_fqdn                  │ string                            │ CloudFront FQDN.                                                          ║
# ║ lambda_arn                       │ string                            │ Lambda@Edge Arn.                                                          ║
# ╚══════════════════════════════════╧═══════════════════════════════════╧═══════════════════════════════════════════════════════════════════════════╝

variable "bucket_name" {
  type        = string
  description = "S3 Bucket Name."
}

variable "alb_fqdn" {
  type        = string
  description = "ALB FQDN."
}


variable "cloudfront_cert_arn" {
  type        = string
  description = "CloudFront Certificate ARN."
}

variable "cloudfront_hostzone_id" {
  type        = string
  description = "Hostzone id."
}

variable "cloudfront_fqdn" {
  type        = string
  description = "CloudFront FQDN."
}

variable "lambda_arn" {
  type        = string
  description = "Lambda@Edge ARN."
}
