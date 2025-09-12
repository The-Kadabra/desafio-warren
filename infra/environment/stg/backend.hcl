terraform {
  backend "s3" {
    bucket         = "desafio-warren-stg"
    key            = "stg/stg-desafio-warrner.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "dynamo-desafio-warren-stg"
  }
}