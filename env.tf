########
#GLOBAL#
########
variable "project" {
  type        = string
  description = "value"
  default     = "desafio-warren"
}


########
#TFVARS#
########
variable "environment" {}
variable "bucket_backend" {}
variable "region" {}
variable "tags" {type = map(string)}
variable "azs" {type  = list(string)}
variable "private_subnets" {type  = list(string)}
variable "public_subnets" {type   = list(string)}


############
#MODULE-VPC#
############
variable "private_subnet_suffix" {
  description = "Nome que se pretende dar a essa SUBNET"
  type        = string
  default     = "private"
}

variable "public_subnet_suffix" {
  description = "Nome que se pretende dar a essa SUBNET"
  type        = string
  default     = "public"
}