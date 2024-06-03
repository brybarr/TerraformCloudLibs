module "simple_vpc" {
  source = "../.." # Replace with the actual relative or remote path to the module

  vpc_cidr_block       = var.vpc_cidr_block
  create_public_subnet = var.create_public_subnet
  aws_profile          = var.aws_profile
  aws_region           = var.aws_region
  tags                 = var.tags
  # Input variables for the module, if any
}
