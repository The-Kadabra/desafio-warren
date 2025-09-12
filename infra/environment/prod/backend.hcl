terraform {
  backend "s3" {
    bucket         = "desafio-warren-prod"
    key            = "prod/prod-desafio-warrner.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "dynamo-desafio-warren-prod"
  }
}