#############
#AWS ACCOUNT#
#############
data "aws_caller_identity" "current" {}

#############
#Data Subnet#
#############

/*variable "vpc_subnet" {
  description = "lista das subnets"
  default     = ["microservices-private-us-east-1a", "microservices-private-us-east-1b"]
}*/