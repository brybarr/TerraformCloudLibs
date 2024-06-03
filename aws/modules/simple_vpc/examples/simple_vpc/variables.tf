# # variables.tf

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block to use for the VPC"
  default     = "10.0.0.0/16"
}

variable "create_public_subnet" {
  description = "Set to true to create public subnets with NAT Gateways."
  type        = bool
  default     = false
}

variable "aws_profile" {
  type        = string
  description = "The AWS profile to use"
}

variable "aws_region" {
  type        = string
  description = "The AWS region to use"
  default     = "ap-southeast-2"
}

variable "vpc_name" {
  type        = string
  description = "The name of the VPC, used as the Name tag"
  default     = "MyVPC"
}

variable "tags" {
  type        = map(any)
  description = "Tags common to all resources in the module"
  default     = {}
}
