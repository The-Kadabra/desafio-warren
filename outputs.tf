# Data source: consulta a identidade atual


output "aws_caller_arn" {
  value = data.aws_caller_identity.current.arn
}

/*output "vpc" {
  value = module.vpc.*
}*/

