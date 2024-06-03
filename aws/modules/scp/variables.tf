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

variable "target_id" {
  type    = string
  default = null
}

variable "scp_name" {
  type = string
}

variable "scp_description" {
  type = string
}

variable "scp_policy" {
  type = string
}

variable "default_tags" {
  type = map(any)
}

variable "deploy_role_name" {
  type = string
}
