# ╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
# ║ CloudFront Lambda@Edge redirect Stack - Terraform main.tf resource                                                                               ║
# ╠════════════════════════════════════╤═════════════════════════════════════════════════════╤═══════════════════════════════════════════════════════╣
# ║ vpc                                │ aws_vpc                                             │ VPC.                                                  ║
# ║ subnet                             │ aws_subnet                                          │ Subnet.                                               ║
# ║ nacl                               │ aws_network_acl                                     │ NACL.                                                 ║
# ║ nacl_in_rule100                    │ aws_network_acl_rule                                │ NACL Inbound Rule.                                    ║
# ║ nacl_out_rule100                   │ aws_network_acl_rule                                │ NACL Outbound Rule.                                   ║
# ║ assoc_nacl                         │ aws_network_acl_association                         │ NACL Association Subnet.                              ║
# ║ igw                                │ aws_internet_gateway                                │ IGW.                                                  ║
# ║ rtb_public                         │ aws_route_table                                     │ Public RouteTable.                                    ║
# ║ rtb_private                        │ aws_route_table                                     │ Private RouteTable.                                   ║
# ║ assoc_rtb_pub1                     │ aws_route_table_association                         │ RouteTable Association Subnet.                        ║
# ║ assoc_rtb_pub2                     │ aws_route_table_association                         │ RouteTable Association Subnet.                        ║
# ║ assoc_rtb_pri1                     │ aws_route_table_association                         │ RouteTable Association Subnet.                        ║
# ║ assoc_rtb_pri2                     │ aws_route_table_association                         │ RouteTable Association Subnet.                        ║
# ║ vpcep_gw_s3                        │ aws_vpc_endpoint                                    │ VPC Endpoint Gateway S3.                              ║
# ║ vpcep_sg                           │ aws_security_group                                  │ Security Group for VPC Endpoint.                      ║
# ║ ec2_sg                             │ aws_security_group                                  │ Security Group for EC2.                               ║
# ║ alb_sg                             │ aws_security_group                                  │ Security Group for ALB.                               ║
# ║ vpcep_sg_in1                       │ aws_security_group_rule                             │ Ingress Rule HTTPS from EC2 SG.                       ║
# ║ ec2_sg_in1                         │ aws_security_group_rule                             │ Ingress Rule HTTP from ALB SG.                        ║
# ║ ec2_sg_out1                        │ aws_security_group_rule                             │ Egress Rule HTTPS to VPCEP SG.                        ║
# ║ ec2_sg_out2                        │ aws_security_group_rule                             │ Egress Rule to VPCEP S3 GW.                           ║
# ║ alb_sg_in1                         │ aws_security_group_rule                             │ Ingress Rule HTTPS from unrestricted.                 ║
# ║ alb_sg_out1                        │ aws_security_group_rule                             │ Egress Rule HTTP to EC2 SG.                           ║
# ║ vpcep_if                           │ aws_vpc_endpoint                                    │ VPC Endpoint Interfaces.                              ║
# ║ ec2_role                           │ aws_iam_role                                        │ IAM Role for EC2.                                     ║
# ║ ec2_instance_profile               │ aws_iam_instance_profile                            │ IAM Instance Profile for EC2.                         ║
# ║ ssh_keygen                         │ tls_private_key                                     │ setting SSH keygen algorithm.                         ║
# ║ keypair_pem                        │ local_sensitive_file                                │ create private key file to local.                     ║
# ║ keypair                            │ aws_key_pair                                        │ Key Pair.                                             ║
# ║ ec2_instance                       │ aws_instance                                        │ EC2 Instance.                                         ║
# ║ targetgroup                        │ aws_lb_target_group                                 │ Target Group for ALB.                                 ║
# ║ attach_targetgroup                 │ aws_lb_target_group_attachment                      │ Target Group attachment to EC2.                       ║
# ║ alb                                │ aws_lb                                              │ ALB.                                                  ║
# ║ alb_cert                           │ aws_acm_certificate                                 │ Public Certificate for ALB.                           ║
# ║ alb_cert_cname_record              │ aws_route53_record                                  │ CNAME record for alb certificate.                     ║
# ║ alb_cert_cname_record_valid        │ aws_acm_certificate_validation                      │ Verification of CNAME records for alb certificates.   ║
# ║ listener                           │ aws_lb_listener                                     │ Listener for ALB.                                     ║
# ║ alb_recordset                      │ aws_route53_record                                  │ ALB Alias Record Set.                                 ║
# ╚════════════════════════════════════╧═════════════════════════════════════════════════════╧═══════════════════════════════════════════════════════╝

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_map.cidr
  enable_dns_hostnames = var.vpc_map.dnshost
  enable_dns_support   = var.vpc_map.dnssupport
  tags = {
    Name = var.vpc_map.name
  }
}

resource "aws_subnet" "subnet" {
  for_each                = { for i in var.subnet_map_list : i.name => i }
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = each.value.az_name
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = each.value.publicip
  tags = {
    Name = each.value.name
  }
}

resource "aws_network_acl" "nacl" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "nacl"
  }
}

resource "aws_network_acl_rule" "nacl_in_rule100" {
  network_acl_id = aws_network_acl.nacl.id
  rule_number    = 100
  rule_action    = "allow"
  egress         = false
  protocol       = -1
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "nacl_out_rule100" {
  network_acl_id = aws_network_acl.nacl.id
  rule_number    = 100
  rule_action    = "allow"
  egress         = true
  protocol       = -1
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_association" "assoc_nacl" {
  for_each       = toset(var.nacl_assoc_list)
  network_acl_id = aws_network_acl.nacl.id
  subnet_id      = aws_subnet.subnet[each.value].id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "rtb-public"
  }
}

resource "aws_route_table" "rtb_private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "rtb-private"
  }
}

resource "aws_route_table_association" "assoc_rtb_pub1" {
  subnet_id      = aws_subnet.subnet["public-subnet-a"].id
  route_table_id = aws_route_table.rtb_public.id
}

resource "aws_route_table_association" "assoc_rtb_pub2" {
  subnet_id      = aws_subnet.subnet["public-subnet-c"].id
  route_table_id = aws_route_table.rtb_public.id
}

resource "aws_route_table_association" "assoc_rtb_pri1" {
  subnet_id      = aws_subnet.subnet["private-subnet-a"].id
  route_table_id = aws_route_table.rtb_private.id
}

resource "aws_route_table_association" "assoc_rtb_pri2" {
  subnet_id      = aws_subnet.subnet["private-subnet-c"].id
  route_table_id = aws_route_table.rtb_private.id
}

resource "aws_vpc_endpoint" "vpcep_gw_s3" {
  vpc_id            = aws_vpc.vpc.id
  vpc_endpoint_type = var.vpcep_gw_map.type
  service_name      = var.vpcep_gw_map.service
  route_table_ids   = [aws_route_table.rtb_public.id, aws_route_table.rtb_private.id]
  tags = {
    Name = var.vpcep_gw_map.name
  }
}

resource "aws_security_group" "vpcep_sg" {
  name        = "vpcep-sg"
  vpc_id      = aws_vpc.vpc.id
  description = "Security Group for VPC Endpoint."
  tags = {
    Name = "vpcep-sg"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  vpc_id      = aws_vpc.vpc.id
  description = "Security Group for EC2."
  tags = {
    Name = "ec2-sg"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  vpc_id      = aws_vpc.vpc.id
  description = "Security Group for ALB."
  tags = {
    Name = "alb-sg"
  }
}

resource "aws_security_group_rule" "vpcep_sg_in1" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  description              = "Ingress Rule HTTPS from EC2 SG."
  security_group_id        = aws_security_group.vpcep_sg.id
  source_security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_security_group_rule" "ec2_sg_in1" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  description              = "Ingress Rule HTTP from ALB SG."
  security_group_id        = aws_security_group.ec2_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "ec2_sg_out1" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  description              = "Egress Rule HTTPS to VPCEP SG."
  security_group_id        = aws_security_group.ec2_sg.id
  source_security_group_id = aws_security_group.vpcep_sg.id
}

resource "aws_security_group_rule" "ec2_sg_out2" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Egress Rule to VPCEP S3 GW."
  security_group_id = aws_security_group.ec2_sg.id
  prefix_list_ids   = ["pl-61a54008"]
}

resource "aws_security_group_rule" "alb_sg_in1" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  description       = "Ingress Rule HTTPS from unrestricted."
  security_group_id = aws_security_group.alb_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_sg_out1" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  description              = "Egress Rule HTTP to EC2 SG."
  security_group_id        = aws_security_group.alb_sg.id
  source_security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_vpc_endpoint" "vpcep_if" {
  for_each            = { for i in var.vpcep_if_map_list : i.name => i }
  vpc_id              = aws_vpc.vpc.id
  service_name        = each.value.service
  vpc_endpoint_type   = each.value.type
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpcep_sg.id]
  subnet_ids          = [aws_subnet.subnet["private-subnet-c"].id]
  tags = {
    Name = each.value.name
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "iam-role-ec2"
  description        = "IAM Role for EC2."
  assume_role_policy = file("${path.module}/json/ec2-trust-policy.json")
  tags = {
    Name = "iam-role-ec2"
  }
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:${var.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = aws_iam_role.ec2_role.name
  role = aws_iam_role.ec2_role.name
}

resource "tls_private_key" "ssh_keygen" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "keypair_pem" {
  filename        = "./.keypair/keypair.pem"
  content         = tls_private_key.ssh_keygen.private_key_pem
  file_permission = "0600"
}

resource "aws_key_pair" "keypair" {
  key_name   = "keypair"
  public_key = tls_private_key.ssh_keygen.public_key_openssh
  tags = {
    Name = "keypair"
  }
}

resource "aws_instance" "ec2_instance" {
  ami                         = data.aws_ssm_parameter.amazonlinux_2023.value
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  key_name                    = aws_key_pair.keypair.key_name
  instance_type               = var.ec2_map.instancetype
  root_block_device {
    volume_size           = var.ec2_map.volumesize
    volume_type           = "gp3"
    iops                  = 3000
    throughput            = 125
    delete_on_termination = true
    encrypted             = true
    tags = {
      Name = var.ec2_map.volname
    }
  }
  metadata_options {
    http_tokens = "required"
  }
  subnet_id              = aws_subnet.subnet["private-subnet-a"].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  user_data              = file("${path.module}/assets/userdata.sh")
  tags = {
    Name = var.ec2_map.name
  }
  depends_on = [aws_vpc_endpoint.vpcep_if, aws_vpc_endpoint.vpcep_gw_s3]
}

resource "aws_lb_target_group" "targetgroup" {
  name        = "lb-targetgroup"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"
  tags = {
    Name = "lb-targetgroup"
  }
  health_check {
    enabled             = true
    interval            = 10
    path                = "/index.html"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = 200
  }
}

resource "aws_lb_target_group_attachment" "attach_targetgroup" {
  target_group_arn = aws_lb_target_group.targetgroup.arn
  target_id        = aws_instance.ec2_instance.id
}

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.subnet["public-subnet-a"].id, aws_subnet.subnet["public-subnet-c"].id]
  tags = {
    Name = "alb"
  }
}



resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.alb_cert_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targetgroup.arn
  }
}

resource "aws_route53_record" "alb_recordset" {
  zone_id = var.alb_hostzone_id
  name    = var.alb_fqdn
  type    = "A"
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}
