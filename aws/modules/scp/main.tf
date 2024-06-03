/*
# Terraform AWS Organizations SCP Module

## Overview

This Terraform module manages AWS Organizations Service Control Policies (SCPs) along with their policy attachments. The module creates a new policy and optionally attaches it to an organizational unit, account, or the organization root.

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

- Create a new AWS Organizations SCP.
- Optional policy attachment to a target organizational unit, account, or root.
- Outputs SCP ID and attached target ID.

## Inputs

To use this module, the following variables need to be defined:

| Variable Name          | Type       | Description                                              | Default | Required |
|------------------------|------------|----------------------------------------------------------|---------|----------|
| `aws_region`           | string     | AWS region where the resources will be deployed.         | None    | Yes      |
| `aws_account_id`       | string     | AWS Account ID to assume for deploying resources.        | None    | Yes      |
| `deploy_role_name`     | string     | AWS IAM Role for deployment.                             | None    | Yes      |
| `scp_name`             | string     | SCP name.                                                | None    | Yes      |
| `scp_description`      | string     | SCP description.	                                       | None    | Yes      |
| `scp_policy`           | string     | SCP policy in JSON format.                               | None    | Yes      |
| `target_id`            | string     | Target ID for policy attachment.                         | 'null'  | No       |
| `default_tags`         | map(any)   | Name of the AWS IAM role to assume for deploying resources. | None | Yes      |

## Outputs

| Name                | Description                       |
|---------------------|-----------------------------------|
| `scp_id`            | The ID of the created SCP.        |
| `attached_target_id`| The ID of the attached target.    |

### Example

#### main.tf
```hcl
module "aws_scp" {
  source           = "git::https://github.com/terraform-modules-library.git//aws/modules/scp"

  aws_region       = var.aws_region
  aws_account_id   = var.aws_account_id
  deploy_role_name = var.deploy_role_name
  scp_name        = var.scp_name
  scp_description = var.scp_description
  scp_policy      = var.scp_policy
  target_id     = var.target_id
  default_tags = var.default_tags
}
```

#### variables.tf
```hcl
variable "aws_region" {
  type = string
  default = "ap-southeast-2"
}

variable "aws_account_id" {
  type = string
  default = "123456789"
}

variable "deploy_role_name" {
  type = string
  default = "example_org_collection"
}

variable "scp_name" {
  type = string
  default = "ou-example-parent-id"
}

variable "scp_description" {
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

variable "target_id" {
  type = string
  default = "examplerootid123"
}
```

#### outputs.tf
```hcl
output "scp_id" {
  value = module.aws_organizations_scp.scp_id
}

```
*/

resource "aws_organizations_policy" "scp" {
  name        = var.scp_name
  description = var.scp_description
  content     = var.scp_policy
  tags = merge(var.default_tags, {
    Name = var.scp_name
  })
}

resource "aws_organizations_policy_attachment" "attach" {
  count     = var.target_id == null ? 0 : 1
  policy_id = aws_organizations_policy.scp.id
  target_id = var.target_id
}
