# ╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
# ║ CloudFront Lambda@Edge redirect Stack - Terraform locals.tf locals                                                                               ║
# ╠══════════════════════════╤═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
# ║ accout_id                │ Account ID.                                                                                                           ║
# ║ region_name              │ Region name.                                                                                                          ║
# ║ partition_name           │ AWS Partition name.                                                                                                   ║
# ╚══════════════════════════╧═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝

locals {
  account_id     = data.aws_caller_identity.current.account_id
  region_name    = data.aws_region.current.name
  partition_name = data.aws_partition.current.partition
}
