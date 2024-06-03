provider "aws" {
  region = var.aws_region
  assume_role {
    duration     = "15m"
    session_name = var.aws_account_id
    role_arn     = "arn:aws:iam::${var.aws_account_id}:role/${var.deploy_role_name}"
  }
}
