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

variable "trust_principal_arn" {
  type = list(string)
}

variable "role_name" {
  type = string
}

variable "managed_policy_arns" {
  type    = list(string)
  default = []
}

variable "default_tags" {
  type = map(any)
}

variable "deploy_role_name" {
  type = string
}

variable "kms_keys" {
  type    = list(string)
  default = []
}

variable "max_session_duration" {
  type    = number
  default = 3600
}
