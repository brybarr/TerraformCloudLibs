/*
# Terraform AWS IAM Role Module

## Overview

This Terraform module creates an AWS IAM role along with an associated IAM role policy. The role has a configurable maximum session duration and can be attached to managed policies specified by ARN.

## Requirements

| Name       | Version    |
|------------|------------|
| terraform  | >= 0.14    |
| aws        | >= 4.9     |

## Providers

| Name       | Version    |
|------------|------------|
| aws        | >= 4.9     |

## Features

- IAM Role Management
- Tagging
- KMS key association
- IAM Role session duration

## Inputs

To use this module, the following variables need to be defined:

| Variable Name          | Type       | Description                                              | Default | Required |
|------------------------|------------|----------------------------------------------------------|---------|----------|
| `aws_region`           | string     | AWS region where the resources will be deployed.         | None    | Yes      |
| `environment`          | string     | The environment for which the resources will be deployed.| None    | Yes      |
| `aws_account_id`       | string     | AWS Account ID to assume for deploying resources.        | None    | Yes      |
| `collection_identifier`| string     | Identifier for a collection of related resources.        | None    | Yes      |
| `trust_principal_arn`  | list(string)| List of ARNs that are trusted to assume the IAM role.   | None    | Yes      |
| `role_name`            | string     | Name of the IAM role to be created.                      | None    | Yes      |
| `managed_policy_arns`  | list(string)| List of managed policy ARNs to attach to the IAM role.  | []      | No       |
| `default_tags`         | map(any)   | Default tags to be applied to all resources.             | None    | Yes      |
| `deploy_role_name`     | string     | Name of the AWS IAM role to assume for deploying resources. | None | Yes      |
| `kms_keys`             | list(string)| List of KMS key ARNs that can be used with this IAM role.| []     | No       |
| `max_session_duration` | number     | Maximum session duration for the IAM role.               | 3600    | No       |

## Outputs

| Name                | Description                       |
|---------------------|-----------------------------------|
| `role_id`           | ID of the created AWS IAM role.   |

### Example

#### main.tf
```hcl
module "aws_iam_role" {
  source                = "git::https://github.com/terraform-modules-library.git//aws/modules/identity"

  aws_region            = var.aws_region
  environment           = var.environment
  aws_account_id        = var.aws_account_id
  collection_identifier = var.collection_identifier
  trust_principal_arn   = var.trust_principal_arn
  role_name             = var.role_name
  managed_policy_arns   = var.managed_policy_arns
  default_tags          = var.default_tags
  deploy_role_name      = var.deploy_role_name
  kms_keys              = var.kms_keys
  max_session_duration  = var.max_session_duration
}
```

#### variables.tf
```hcl
variable "aws_region" {
  type = string
  default = "ap-southeast-2"
}

variable "environment" {
  type = string
  default = "dev
}

variable "aws_account_id" {
  type = string
  default = "123456789"
}

variable "collection_identifier" {
  type = string
  default = "example_collection"
}

variable "trust_principal_arn" {
  type = list(string)
  default = ["arn:aws:iam::123456789:role/example_role"]
}

variable "role_name" {
  type = string
  default = "example_role"
}

variable "managed_policy_arns" {
  type    = list(string)
  default = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

variable "default_tags" {
  type = map(any)
  default = { "Project" = "example_project" }
}

variable "deploy_role_name" {
  type = string
  default = "example_deploy_role"
}

variable "kms_keys" {
  type    = list(string)
  default = ["arn:aws:kms:ap-southeast-2:123456789:key/examplekmskey"]
}

variable "max_session_duration" {
  type    = number
  default = 3600
}
```

#### output.tf
```hcl
output "role_id" {
  value = module.aws_iam_role.role_id
}
```

*/

resource "aws_iam_role" "role" {
  name                 = var.role_name
  max_session_duration = var.max_session_duration
  assume_role_policy   = data.aws_iam_policy_document.identity_trust_policy.json
  managed_policy_arns  = var.managed_policy_arns
  tags = merge(var.default_tags, {
  })
}

resource "aws_iam_role_policy" "role_policy" {
  name = "${var.role_name}_policy"
  role = aws_iam_role.role.id

  policy = data.aws_iam_policy_document.identity_role.json
}
