#################
#Virtual Machine#
#################
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  depends_on = [module.vpc]
  name = "spot-instance-desafio-warren"

  create_spot_instance = true
  spot_price           = "0.60"
  spot_type            = "persistent"

  instance_type         = "t3.micro"
  key_name              = "user1"
  monitoring            = true
  subnet_id             = module.vpc.private_subnets[0]
  
  create_security_group       = true
  security_group_name         = format("sg-%s-%s",var.project, var.environment)
  security_group_description  = format("%s-%s",var.project, var.environment)
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name



security_group_egress_rules = {
  all_egress = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
    }
  }
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