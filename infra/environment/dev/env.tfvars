environment         = "dev"
region              = "us-east-1"
bucket_backend      = "desafio-warren-dev"
azs             = ["us-east-1a", "us-east-1b"]
private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]



tags = {
  Environment = "dev"
  Project     = "desafio-warren"
  Owner       = "SRE"
  BU          = "cards-team"
}