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

variable "default_tags" {
  type = map(any)
}

variable "deploy_role_name" {
  type = string
}

variable "share_resource_arn" {
  type = string
}

variable "share_principals" {
  type = list(string)
}

variable "share_name" {
  type = string
}
