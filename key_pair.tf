module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name           = format("%s-%s", var.project, var.environment)
  create_private_key = true
}