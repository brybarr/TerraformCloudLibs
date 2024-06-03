/*
# AWS Organizations Account Terraform Module

## Overview

This Terraform module manages AWS organizational accounts. It creates an AWS account under a specified Organizational Unit (OU) and allows for account management through Terraform.

## Requirements

| Name       | Version    |
|------------|------------|
| terraform  | >= 0.13.1  |
| aws        | >= 4.9     |

## Providers

| Name       | Version    |
|------------|------------|
| aws        | >= 4.9     |

## Features

- Create AWS organizational accounts
- Tagging
- Outputs account ID for further references

## Inputs

To use this module, the following variables need to be defined:

| Variable Name          | Type     | Description                                                                             | Default | Required |
|------------------------|----------|-----------------------------------------------------------------------------------------|---------|----------|
| `aws_region`           | string   | AWS region where the resources will be deployed.                                        | None    | Yes      |
| `environment`          | string   | The environment for which the resources will be deployed (e.g., dev, staging, prod).    | None    | Yes      |
| `aws_account_id`       | string   | AWS Account ID to assume for deploying resources.                                       | None    | Yes      |
| `collection_identifier`| string   | Identifier for a collection of related resources.                                       | None    | Yes      |
| `parent_ou_id`         | string   | Parent Organizational Unit ID where the account will be created.                        | None    | Yes      |
| `account_name`         | string   | Name of the AWS account to be created.                                                  | None    | Yes      |
| `account_email`        | string   | Email associated with the AWS account to be created.                                    | None    | Yes      |
| `default_tags`         | map(any) | Default tags to be applied to all resources.                                            | None    | Yes      |
| `deploy_role_name`     | string   | Name of the AWS IAM role to assume for deploying resources.                             | None    | Yes      |

## Outputs

| Name                | Description                                          |
|---------------------|------------------------------------------------------|
| `account_id`        | The ID of the created AWS organizational account.    |

### Example

#### main.tf
```hcl
module "aws_organizations_account" {
  source                = "git::https://github.com/terraform-modules-library.git//aws/modules/account"

  aws_region            = var.aws_region
  environment           = var.environment
  aws_account_id        = var.aws_account_id
  collection_identifier = var.collection_identifier
  parent_ou_id          = var.parent_ou_id
  account_name          = var.account_name
  account_email         = var.account_email
  default_tags          = var.default_tags
  deploy_role_name      = var.deploy_role_name
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
  default = "example-collection"
}

variable "parent_ou_id" {
  type = string
  default = "example-OU"
}

variable "account_name" {
  type = string
  default = "example-account-name"
}

variable "account_email" {
  type = string
  default = "example-account-email
}

variable "default_tags" {
  type = map(any)
  default = { "Environment" = "Dev" }
}

variable "deploy_role_name" {
  type = string
  default = "Example-Deployment-Role"
}
```
#### outputs.tf
```hcl
output "account_id" {
  value = module.aws_organizations_account.account_id
}
```
*/


resource "aws_organizations_account" "account" {
  name              = var.account_name
  email             = var.account_email
  parent_id         = var.parent_ou_id
  close_on_deletion = true
  tags = merge(var.default_tags, {
    Name = var.account_name
  })
}
