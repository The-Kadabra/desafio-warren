#################
#Virtual Machine#
#################
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  depends_on = [module.vpc]
  name                        = "instance-desafio-warren"
  instance_type               = "t3.micro"
  monitoring                  = true
  subnet_id                   = module.vpc.private_subnets[0]
  
  create_security_group       = true
  security_group_name         = format("%s-%s",var.project, var.environment)
  security_group_description  = format("%s-%s",var.project, var.environment)
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  ami                         = data.aws_ami.amazon_linux.id
  get_password_data           = true

security_group_egress_rules = {
  all_egress = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_ipv4   = "0.0.0.0/0"
    description = "Allow all outbound"
    }
  }

user_data = <<-EOT
#!/bin/bash
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
EOT
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