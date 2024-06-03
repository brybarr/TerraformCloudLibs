/*
# Terraform AWS RAM Resource Share Module

## Overview

This Terraform module provisions and manages AWS RAM Resource Shares along with associated resources and principals. It allows the sharing of AWS resources within your organization. The module supports optional tagging and assumes a specified AWS IAM role for deployment.

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

- Creates an AWS RAM Resource Share with a specified name.
- Associates specified resources with the RAM Resource Share.
- Associates specified principals with the RAM Resource Share.
- Merges default tags with custom tags.
- Assumes a specified AWS IAM role for deployment.

## Inputs

To use this module, the following variables need to be defined:

| Variable Name          | Type       | Description                                              | Default | Required |
|------------------------|------------|----------------------------------------------------------|---------|----------|
| `aws_region`           | string     | AWS region where the resources will be deployed.         | None    | Yes      |
| `environment`          | string     | The environment for which the resources will be deployed.| None    | Yes      |
| `aws_account_id`       | string     | AWS Account ID to assume for deploying resources.        | None    | Yes      |
| `collection_identifier`| string     | Identifier for a collection of related resources.        | None    | Yes      |
| `share_resource_arn`   | string     | ARN of the resource to be shared.                        | None    | Yes      |
| `share_name`           | string     | Name for the RAM Resource Share.                         | None    | Yes      |
| `share_principals`     | list(string)| List of principals to share the resource with.          | None    | No       |
| `default_tags`         | map(any)   | Default tags to be applied to all resources.             | None    | No       |
| `deploy_role_name`     | string     | Name of the AWS IAM role to assume for deploying resources. | None | Yes      |

### Example

#### main.tf
```hcl
module "aws_ram_resource_share" {
  source               = "git::https://github.com/terraform-modules-library.git//aws/modules/ramshare"

  aws_region           = var.aws_region
  environment          = var.environment
  aws_account_id       = var.aws_account_id
  collection_identifier = var.collection_identifier
  default_tags         = var.default_tags
  deploy_role_name     = var.deploy_role_name
  share_resource_arn   = var.share_resource_arn
  share_principals     = var.share_principals
  share_name           = var.share_name
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
  default = "example-resource"
}

variable "default_tags" {
  type = map(any)
  default = { "Environment" = "dev", "Project" = "example-resource-sharing" }
}

variable "deploy_role_name" {
  type = string
  default = "example-deployment-role"
}

variable "share_resource_arn" {
  type = string
  default = "arn:aws:resource_type:ap-southeast-2:123456789:example-resource-id"
}

variable "share_principals" {
  type = list(string)
  default = ["arn:aws:iam::123456789:role/example-Role-Name"]
}

variable "share_name" {
  type = string
  default = "Example-Resource-Share"
}
```
*/

resource "aws_ram_resource_share" "resource" {
  name                      = var.share_name
  allow_external_principals = false

  tags = merge(var.default_tags, {
    Name = var.share_name
  })
}

resource "aws_ram_resource_association" "resource" {
  resource_arn       = var.share_resource_arn
  resource_share_arn = aws_ram_resource_share.resource.arn
}

resource "aws_ram_principal_association" "resource" {
  count              = length(var.share_principals) > 0 ? length(var.share_principals) : 0
  principal          = var.share_principals[count.index]
  resource_share_arn = aws_ram_resource_share.resource.arn
}
