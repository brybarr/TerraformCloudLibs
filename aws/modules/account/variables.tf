variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "collection_identifier" {
  type = string
}

variable "parent_ou_id" {
  type = string
}

variable "account_name" {
  type = string
}

variable "account_email" {
  type = string
}

variable "default_tags" {
  type = map(any)
}

variable "deploy_role_name" {
  type = string
}
