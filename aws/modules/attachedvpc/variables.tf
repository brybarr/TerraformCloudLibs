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

variable "cloudwatch_flowlog_retention_days" {
  type = number
}

variable "kms_key_arn" {
  type = string
}

variable "interconnect_tgw_id" {
  type = string
}

variable "vpc_routable_octet1" {
  type = number
  # validation {
  #   condition     = var.vpc_routable_octet1 == 10 || var.vpc_routable_octet1 == 172 || var.vpc_routable_octet1 == 192
  #   error_message = "VPC Routable Octet 1 must be a valid value for class A, B, or C private ip range (A=10, B=172, C=192)."
  # }
}

variable "vpc_routable_octet2" {
  type = number
  # validation {
  #   condition     = var.vpc_routable_octet2 >= 0 && var.vpc_routable_octet2 <= 255
  #   error_message = "VPC Routable Octet 2 must be a valid value for class A, B, or C private ip range (A=0-255, B=16-31, C=0-255)."
  # }
}

variable "vpc_routable_octet3" {
  type = number
  # validation {
  #   condition     = var.vpc_routable_octet3 >= 0 || var.vpc_routable_octet3 <= 255
  #   error_message = "VPC Routable Octet 3 must be a valid value for class A, B, or C private ip range (A=0-255, B=16-31, C=0-255)."
  # }
}

variable "vpc_routable_octet4" {
  type = number
  # validation {
  #   condition     = var.vpc_routable_octet4 >= 0 || var.vpc_routable_octet4 <= 16 || var.vpc_rouatbale_octet4 == 32 || var.vpc_routable_octet4 == 48 || var.vpc_routable_octet4 == 64 || var.vpc_routable_octet4 == 80 || var.vpc_routable_octet4 == 96 || var.vpc_routable_octet4 == 112 || var.vpc_routable_octet4 == 128 || var.vpc_routable_octet4 == 144 || var.vpc_routable_octet4 == 160 || var.vpc_routable_octet4 == 176 || var.vpc_routable_octet4 == 192 || var.vpc_routable_octet4 == 208 || var.vpc_routable_octet4 == 224 || var.vpc_routable_octet4 == 240
  #   error_message = "VPC Routable Octet 4 must be a valid value for the CIDR mask (/28) (valid values - 0, 16, 32, 48, 64, 80, 96, 112, 128, 144, 160, 176, 192, 208, 224, 240)."
  # }
}

variable "vpc_routable_mask" {
  type = number
  # validation {
  #   condition     = var.vpc_routable_mask == 28
  #   error_message = "VPC Routable Mask must be a valid value for the CIDR mask (/28) (valid values - 28)."
  # }
}

variable "vpc_nonroutable_octet1" {
  type = number
  # validation {
  #   condition     = var.vpc_octet1 == 10 || var.vpc_octet1 == 172 || var.vpc_octet1 == 192
  #   error_message = "VPC Non-routable Octet 1 must be a valid value for class A, B, or C private ip range (A=10, B=172, C=192)."
  # }
}

variable "vpc_nonroutable_octet2" {
  type = number
  # validation {
  #   condition     = var.vpc_octet2 >= 0 && var.vpc_octet2 <= 255
  #   error_message = "VPC Non-routable Octet 2 must be a valid value for class A, B, or C private ip range (A=0-255, B=16-31, C=0-255)."
  # }
}

variable "vpc_nonroutable_octet3" {
  type = number
  # validation {
  #   condition     = var.vpc_octet3 == 0 || var.vpc_octet3 == 32 || var.vpc_octet3 == 64 || var.vpc_octet3 == 96 || var.vpc_octet3 == 128 || var.vpc_octet3 == 160 || var.vpc_octet3 == 192 || var.vpc_octet3 == 224
  #   error_message = "VPC Non-routable Octet 3 must be a valid value for class A, B, or C private ip range (0-255)."
  # }
}

variable "vpc_nonroutable_octet4" {
  type = number
  # validation {
  #   condition     = var.vpc_octet4 == 0
  #   error_message = "VPC Non-routable Octet 4 must be a valid value for class A, B, or C private ip range (0-255)."
  # }
}

variable "vpc_nonroutable_mask" {
  type = number
  # validation {
  #   condition     = var.vpc_nonroutable_mask == 16
  #   error_message = "VPC Non-routable Mask must be a valid value for the CIDR mask (/16) (valid values - 16)."
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

variable "routable_inbound_acl_rules" {
  type = list(map(string))
  # default = [{ "action" : "allow",
  #   "cidr_block" : "0.0.0.0/0",
  #   "from_port" : 0,
  #   "protocol" : "-1",
  #   "rule_no" : 100,
  #   "to_port" : 0 },
  #   { "action" : "allow",
  #     "from_port" : 0,
  #     "ipv6_cidr_block" : "::/0",
  #     "protocol" : "-1",
  #     "rule_no" : 101,
  #   "to_port" : 0 }
  # ]
}

variable "routable_outbound_acl_rules" {
  type = list(map(string))
  # default = [{ "action" : "allow",
  #   "cidr_block" : "0.0.0.0/0",
  #   "from_port" : 0,
  #   "protocol" : "-1",
  #   "rule_no" : 100,
  #   "to_port" : 0 },
  #   { "action" : "allow",
  #     "from_port" : 0,
  #     "ipv6_cidr_block" : "::/0",
  #     "protocol" : "-1",
  #     "rule_no" : 101,
  #   "to_port" : 0 }
  # ]
}

variable "nonroutable_inbound_acl_rules" {
  type = list(map(string))
  # default = [{ "action" : "allow",
  #   "cidr_block" : "0.0.0.0/0",
  #   "from_port" : 0,
  #   "protocol" : "-1",
  #   "rule_no" : 100,
  #   "to_port" : 0 },
  #   { "action" : "allow",
  #     "from_port" : 0,
  #     "ipv6_cidr_block" : "::/0",
  #     "protocol" : "-1",
  #     "rule_no" : 101,
  #   "to_port" : 0 }
  # ]
}

variable "nonroutable_outbound_acl_rules" {
  type = list(map(string))
  # default = [{ "action" : "allow",
  #   "cidr_block" : "0.0.0.0/0",
  #   "from_port" : 0,
  #   "protocol" : "-1",
  #   "rule_no" : 100,
  #   "to_port" : 0 },
  #   { "action" : "allow",
  #     "from_port" : 0,
  #     "ipv6_cidr_block" : "::/0",
  #     "protocol" : "-1",
  #     "rule_no" : 101,
  #   "to_port" : 0 }
  # ]
}

variable "deploy_role_name" {
  type = string
}

variable "routable_subnet_suffix" {
  type    = string
  default = "Routable"
}

variable "nonroutable_subnet_suffix" {
  type    = string
  default = "Non-routable"
}

variable "org_id" {
  type    = string
  default = "o-7w23f0chfl"
}
