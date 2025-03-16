# ╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
# ║ CloudFront Lambda@Edge redirect Stack - Terraform variable.tf variable                                                                           ║
# ╠══════════════════════════════════╤═══════════════════════════════════╤═══════════════════════════════════════════════════════════════════════════╣
# ║ vpc_map                          │ map(string)                       │ VPC settings map.                                                         ║
# ║ subnet_map_list                  │ list(map(string))                 │ Subnet settings map list.                                                 ║
# ║ nacl_assoc_list                  │ list(string)                      │ NACL settings list.                                                       ║
# ║ vpcep_gw_map                     │ map(string)                       │ VPC Endpoint settings map.                                                ║
# ║ vpcep_if_map_list                │ list(map(string))                 │ VPC Endpoint settings map.                                                ║
# ║ partition                        │ string                            │ Partition.                                                                ║
# ║ ec2_map                          │ map(string)                       │ EC2 settings map.                                                         ║
# ║ alb_hostzone_id                  │ string                            │ Hostzone id.                                                              ║
# ║ alb_fqdn                         │ string                            │ ALB FQDN.                                                                 ║
# ║ alb_cert_arn                     │ string                            │ ALB Certificate ARN.                                                      ║
# ╚══════════════════════════════════╧═══════════════════════════════════╧═══════════════════════════════════════════════════════════════════════════╝

variable "vpc_map" {
  type        = map(string)
  description = "VPC settings map."
}

variable "subnet_map_list" {
  type        = list(map(string))
  description = "Subnet settings map."
}

variable "nacl_assoc_list" {
  type        = list(string)
  description = "NACL settings map."
}

variable "vpcep_gw_map" {
  type        = map(string)
  description = "VPC Endpoint settings map."
}

variable "vpcep_if_map_list" {
  type        = list(map(string))
  description = "VPC Endpoint settings map."
}

variable "partition" {
  type        = string
  description = "partition."
}

variable "ec2_map" {
  type        = map(string)
  description = "EC2 settings map."
}

variable "alb_hostzone_id" {
  type        = string
  description = "Hostzone id for ALB."
}

variable "alb_fqdn" {
  type        = string
  description = "ALB FQDN."
}

variable "alb_cert_arn" {
  type        = string
  description = "ALB Certificate ARN."
}
