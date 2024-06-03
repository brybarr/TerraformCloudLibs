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

variable "cloudwatch_flowlog_retention_days" {
  type = number
}

variable "kms_key_arn" {
  type = string
}

variable "vpc_octet1" {
  type = number
  # validation {
  #   condition     = var.vpc_octet1 == 10 || var.vpc_octet1 == 172 || var.vpc_octet1 == 192
  #   error_message = "VPC Octet 1 must be a valid value for class A, B, or C private ip range (A=10, B=172, C=192)."
  # }
}

variable "vpc_octet2" {
  type = number
  # validation {
  #   condition     = var.vpc_octet2 >= 0 && var.vpc_octet2 <= 255
  #   error_message = "VPC Octet 2 must be a valid value for class A, B, or C private ip range (A=0-255, B=16-31, C=0-255)."
  # }
}

variable "vpc_octet3" {
  type = number
  # validation {
  #   condition     = var.vpc_octet3 >= 224 || var.vpc_octet3 <= 255
  #   error_message = "VPC Octet 3 must be a valid value for class A, B, or C private ip range (A=0-255, B=16-31, C=0-255)."
  # }
}

variable "vpc_octet4" {
  type = number
  # validation {
  #   condition     = var.vpc_octet4 >= 0 || var.vpc_octet4 <= 16 || var.vpc_octet4 == 32 || var.vpc_octet4 == 48 || var.vpc_octet4 == 64 || var.vpc_octet4 == 80 || var.vpc_octet4 == 96 || var.vpc_octet4 == 112 || var.vpc_octet4 == 128 || var.vpc_octet4 == 144 || var.vpc_octet4 == 160 || var.vpc_octet4 == 176 || var.vpc_octet4 == 192 || var.vpc_octet4 == 208 || var.vpc_octet4 == 224 || var.vpc_octet4 == 240
  #   error_message = "VPC Octet 4 must be a valid value for the CIDR mask (/28) (valid values - 0, 16, 32, 48, 64, 80, 96, 112, 128, 144, 160, 176, 192, 208, 224, 240)."
  # }
}

variable "vpc_mask" {
  type = number
  # validation {
  #   condition     = var.vpc_mask == 23
  #   error_message = "VPC Mask must be a valid value for the CIDR mask (/23) (valid values - 23)."
  # }
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = "edp-attachedvpc"
}

variable "domain_name" {
  type    = string
  default = "services.local"
}

variable "domain_name_servers" {
  type    = list(string)
  default = ["10.171.32.21", "10.171.36.21"]
}

variable "ntp_servers" {
  type    = list(string)
  default = ["10.237.196.100", "10.245.196.100"]
}

variable "netbios_node_type" {
  type    = string
  default = "2"
}

variable "netbios_name_servers" {
  type    = list(string)
  default = ["10.171.32.21", "10.171.36.21"]
}

variable "acl_rules" {
  type = list(map(string))
}

variable "allowed_external_ranges" {
  type = list(string)
}

variable "sharedservices_tgw_id" {
  type = string
}

variable "ixtgw_amazon_side_asn" {
  type    = number
  default = 64512
}

variable "attachedvpc_cidr" {
  type = string
}

variable "default_tags" {
  type = map(any)
}

variable "deploy_role_name" {
  type = string
}

variable "sharedservices_subnet_suffix" {
  type    = string
  default = "SharedServices"
}

variable "interconnect_subnet_suffix" {
  type    = string
  default = "Interconnect"
}

variable "ss_tgw_attachment_state" {
  type    = string
  default = "ready"
}
