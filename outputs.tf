#########################
#aws account e role used#
#########################

output "aws_caller_arn" {
  value = data.aws_caller_identity.current.arn
}

#########################################
#Coletando as saidas para usar no código#
#########################################
/*output "vpc" {
  value = module.vpc.*
}*/


output "ec2" {
  value = module.ec2_instance.*
}