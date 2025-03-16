# ╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
# ║ CloudFront Lambda@Edge redirect Stack - Terraform data.tf data                                                                                   ║
# ╠═══════════════════════╤═══════════════════════════════════╤══════════════════════════════════════════════════════════════════════════════════════╣
# ║ current               │ aws_caller_identity               │ Account ID, User ID, ARN.                                                            ║
# ║ current               │ aws_region                        │ Region.                                                                              ║
# ║ current               │ aws_partition                     │ AWS Partition.                                                                       ║
# ╚═══════════════════════╧═══════════════════════════════════╧══════════════════════════════════════════════════════════════════════════════════════╝

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}
