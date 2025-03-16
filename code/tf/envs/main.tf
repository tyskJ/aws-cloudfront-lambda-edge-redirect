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

module "web" {
  source     = "../modules/web"
  depends_on = [module.acm]

  vpc_map           = { "name" = "vpc", "cidr" = "10.0.0.0/16", "dnshost" = true, "dnssupport" = true }
  subnet_map_list   = [{ "name" = "public-subnet-a", "cidr" = "10.0.1.0/24", "az_name" = "${local.region_name}a", "publicip" = true }, { "name" = "public-subnet-c", "cidr" = "10.0.2.0/24", "az_name" = "${local.region_name}c", "publicip" = true }, { "name" = "private-subnet-a", "cidr" = "10.0.3.0/24", "az_name" = "${local.region_name}a", "publicip" = false }, { "name" = "private-subnet-c", "cidr" = "10.0.4.0/24", "az_name" = "${local.region_name}c", "publicip" = false }]
  nacl_assoc_list   = ["public-subnet-a", "public-subnet-c", "private-subnet-a", "private-subnet-c"]
  vpcep_gw_map      = { "name" = "gw-s3", "type" = "Gateway", "service" = "com.amazonaws.${local.region_name}.s3" }
  vpcep_if_map_list = [{ "name" = "if-ec2messages", "type" = "Interface", "service" = "com.amazonaws.${local.region_name}.ec2messages" }, { "name" = "if-ssmmessages", "type" = "Interface", "service" = "com.amazonaws.${local.region_name}.ssmmessages" }, { "name" = "if-ssm", "type" = "Interface", "service" = "com.amazonaws.${local.region_name}.ssm" }]
  partition         = local.partition_name
  ec2_map           = { "name" = "ec2", "instancetype" = "t3.large", "volname" = "ebs-root", "volumesize" = "30" }
  alb_hostzone_id   = var.alb_hostzone_id
  alb_fqdn          = var.alb_fqdn
  alb_cert_arn      = module.acm.alb_cert_arn
}

module "cloudfront_s3" {
  source     = "../modules/cloudfront_s3"
  depends_on = [module.acm]

  bucket_name            = var.bucket_name
  alb_fqdn               = var.alb_fqdn
  cloudfront_cert_arn    = module.acm.cloudfront_cert_arn
  cloudfront_hostzone_id = var.cloudfront_hostzone_id
  cloudfront_fqdn        = var.cloudfront_fqdn
}
