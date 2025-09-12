#################
#Virtual Machine#
#################
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  depends_on = [module.vpc]
  name                        = "instance-desafio-warren"
  instance_type               = "t3.medium"
  monitoring                  = true
  subnet_id                   = module.vpc.private_subnets[0]
  
  create_security_group       = true
  security_group_name         = format("%s-%s",var.project, var.environment)
  security_group_description  = format("%s-%s",var.project, var.environment)
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  ami                         = data.aws_ami.ubuntu.id 
  key_name                    = module.key_pair.key_pair_name

# Regras de saída (egress)
  security_group_egress_rules = {
    all_egress = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all outbound"
    }
  }

  # Regras de entrada (ingress)
  security_group_ingress_rules = {
    http = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow HTTP traffic"
    }

    https = {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow HTTPS traffic"
    }

    Prometheus = {
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow Prometheus traffic"
    }
    Grafana = {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow Grafana traffic"
    }
  }

user_data = templatefile("${path.module}/script/user_data.sh", {PROM_VERSION = "2.53.1", NODE_EXPORTER_VERSION="1.8.2", GRAFANA_VERSION="11.2.0"})
}


#####
#VPC#
#####
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.project
  cidr = "10.0.0.0/16"

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  private_subnet_suffix = var.private_subnet_suffix
  public_subnet_suffix  = var.public_subnet_suffix

  enable_nat_gateway = true
  enable_vpn_gateway = true
  single_nat_gateway = true
  enable_dns_support = true

  tags = var.tags
}


##############
#VPC-ENDPOINT#
##############
resource "aws_vpc_endpoint" "ssm" {
  for_each            = toset(local.ssm_services)
  vpc_id              = module.vpc.vpc_id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [module.ec2_instance.security_group_id]
  private_dns_enabled = true
}

locals {
  ssm_services = [
    "com.amazonaws.us-east-1.ssm",
    "com.amazonaws.us-east-1.ssmmessages",
    "com.amazonaws.us-east-1.ec2messages"
  ]
}