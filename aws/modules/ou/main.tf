/*
# Terraform AWS Organizations OU Module

# Pending tasks
- cleanup data.tf

## Overview

This Terraform module creates an OU under a specified parent OU or root. The module also retrieves information about existing OUs and the organization itself. It needs to assume an IAM role for deployment.

## Requirements

| Name       | Version    |
|------------|------------|
| terraform  | >= 0.13    |
| aws        | >= 4.9     |

## Providers

| Name       | Version    |
|------------|------------|
| aws        | >= 4.9     |

## Features

- Creates an AWS Organizations OU with a specified name and parent ID.
- Merges default tags with custom tags for the OU.
- Assumes a specified AWS IAM role for deployment.

## Inputs

To use this module, the following variables need to be defined:

| Variable Name          | Type       | Description                                              | Default | Required |
|------------------------|------------|----------------------------------------------------------|---------|----------|
| `aws_region`           | string     | AWS region where the resources will be deployed.         | None    | Yes      |
| `environment`          | string     | The environment for which the resources will be deployed.| None    | Yes      |
| `aws_account_id`       | string     | AWS Account ID to assume for deploying resources.        | None    | Yes      |
| `collection_identifier`| string     | Identifier for a collection of related resources.        | None    | Yes      |
| `parent_id`            | list(string)| Parent ID for the new OU.                               | None    | Yes      |
| `ou_name`              | string     | Name of the OU to be created.                            | None    | Yes      |
| `default_tags`         | map(any)   | Default tags to be applied to all resources.             | None    | No       |
| `deploy_role_name`     | string     | Name of the AWS IAM role to assume for deploying resources. | None | Yes      |

## Outputs

| Name                | Description                       |
|---------------------|-----------------------------------|
| `ou_id`             | ID of the created OU.             |
| `ou_arn`            | ARN of the created OU.            |

### Example

#### main.tf
```hcl
module "aws_organizations_ou" {
  source                 = "git::https://github.com/terraform-modules-library.git//aws/modules/ou"

  aws_region             = var.aws_region
  environment            = var.environment
  aws_account_id         = var.aws_account_id
  collection_identifier  = var.collection_identifier
  parent_id              = var.parent_id
  ou_name                = var.ou_name
  default_tags           = var.default_tags
  deploy_role_name       = var.deploy_role_name
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
  default = "dev"
}

variable "aws_account_id" {
  type = string
  default = "123456789"
}

variable "collection_identifier" {
  type = string
  default = "example_org_collection"
}

variable "parent_id" {
  type = string
  default = "ou-example-parent-id"
}

variable "ou_name" {
  type = string
  default = "example-new-OU"
}

variable "default_tags" {
  type = map(any)
  default = { "Environment" = "dev", "Project" = "example-project" }
}

variable "deploy_role_name" {
  type = string
  default = "example-deployment-role"
}
```

#### outputs.tf
```hcl
output "ou_id" {
  value = module.aws_organizations_ou.ou_id
}

output "ou_arn" {
  value = module.aws_organizations_ou.ou_arn
}
```
*/

resource "aws_organizations_organizational_unit" "ou" {
  name      = var.ou_name
  parent_id = var.parent_id
  tags = merge(var.default_tags, {
    Name = var.ou_name
  })
}
