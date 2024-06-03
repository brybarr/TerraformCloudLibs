/*
# AWS Organizations Account Terraform Module

# Pending tasks
- cleanup variable.tf validation part
- cleanup default values

## Overview

This Terraform module provisions an AWS VPC with various subnets, NACLs, and route tables. It also sets up AWS Transit Gateway attachments for interconnectivity and VPC Flow Logs for monitoring network traffic.

## Requirements

| Name       | Version    |
|------------|------------|
| terraform  | >= 0.14.x  |
| aws        | >= 4.9     |

## Providers

| Name       | Version    |
|------------|------------|
| aws        | >= 4.9     |

## Features

- Creates a VPC with customizable CIDR ranges
- Provisions SharedServices and Interconnect subnets
- Sets up Network Access Control Lists (NACLs)
- Configures DHCP Options Set
- Creates Transit Gateway Attachments for SharedServices and Interconnect subnets
- Sets up VPC Flow Logs

## Inputs

To use this module, the following variables need to be defined:

| Name                              | Description                                    | Type        | Default                                           | Required |
|-----------------------------------|------------------------------------------------|-------------|---------------------------------------------------|----------|
| `aws_region`                      | AWS Region where resources will be created     | `string`    | none                                              | Yes      |
| `environment`                     | Environment name                               | `string`    | none                                              | Yes      |
| `aws_account_id`                  | AWS Account ID                                 | `string`    | none                                              | Yes      |
| `collection_identifier`           | Collection Identifier                          | `string`    | none                                              | Yes      |
| `cloudwatch_flowlog_retention_days`| Retention days for CloudWatch Flow Logs       | `number`    | none                                              | No       |
| `kms_key_arn`                     | ARN of the KMS key                             | `string`    | none                                              | No       |
| `vpc_octet1`                      | First octet of the VPC CIDR                    | `number`    | none                                              | Yes      |
| `vpc_octet2`                      | Second octet of the VPC CIDR                   | `number`    | none                                              | Yes      |
| `vpc_octet3`                      | Third octet of the VPC CIDR                    | `number`    | none                                              | Yes      |
| `vpc_octet4`                      | Fourth octet of the VPC CIDR                   | `number`    | none                                              | Yes      |
| `vpc_mask`                        | VPC CIDR mask                                  | `number`    | none                                              | Yes      |
| `name`                            | Name to be used as an identifier for resources | `string`    | "edp-attachedvpc"                                 | No       |
| `domain_name`                     | Domain name for the DHCP options set           | `string`    | "services.local"                                  | No       |
| `domain_name_servers`             | Domain name servers for the DHCP options set   | `list(string)` | ["10.171.32.21", "10.171.36.21"]               | No       |
| `ntp_servers`                     | NTP servers for the DHCP options set           | `list(string)` | ["10.237.196.100", "10.245.196.100"]           | No       |
| `netbios_node_type`               | NetBIOS node type for the DHCP options set     | `string`    | "2"                                               | No       |
| `netbios_name_servers`            | NetBIOS name servers for the DHCP options set  | `list(string)` | ["10.171.32.21", "10.171.36.21"]               | No       |
| `acl_rules`                       | Network ACL rules                              | `list(map)`  | none                                             | Yes      |
| `allowed_external_ranges`         | Allowed external CIDR ranges                   | `list(string)` | none                                           | Yes      |
| `sharedservices_tgw_id`           | Shared Services Transit Gateway ID             | `string`    | none                                              | Yes      |
| `ixtgw_amazon_side_asn`           | Amazon Side ASN for the interconnect TGW       | `number`    | 64512                                             | No       |
| `attachedvpc_cidr`                | CIDR block for the attached VPC                | `string`    | none                                              | Yes      |
| `default_tags`                    | Default tags for all resources                 | `map(any)`  | none                                              | No       |
| `deploy_role_name`                | Role name for deployment                       | `string`    | none                                              | Yes      |
| `sharedservices_subnet_suffix`    | Suffix for SharedServices subnet names         | `string`    | "SharedServices"                                  | No       |
| `interconnect_subnet_suffix`      | Suffix for Interconnect subnet names           | `string`    | "Interconnect"                                    | No       |
| `ss_tgw_attachment_state`         | State of the Shared Services TGW attachment    | `string`    | "ready"                                           | No       |

## Outputs

| Name                            | Description                           |
|---------------------------------|---------------------------------------|
| `vpc_id`                        | ID of the created VPC                 |
| `sharedservices_subnet_ids`     | IDs of the SharedServices subnets     |
| `interconnect_subnet_ids`       | IDs of the Interconnect subnets       |
| `sharedservices_route_table_ids`| IDs of the SharedServices route tables|
| `interconnect_route_table_ids`  | IDs of the Interconnect route tables  |
| `tgw_id`                        | ID of the Interconnect Transit Gateway|
| `tgw_arn`                       | ARN of the Interconnect Transit Gateway|

### Example

#### main.tf
```hcl
module "aws_attached_vpc" {
  source                    = "git::https://github.com/terraform-modules-library.git//aws/modules/interconnect"

  aws_region                = var.aws_region
  environment               = var.environment
  aws_account_id            = var.aws_account_id
  collection_identifier     = var.collection_identifier
  vpc_octet1                = var.vpc_octet1
  vpc_octet2                = var.vpc_octet2
  vpc_octet3                = var.vpc_octet3
  vpc_octet4                = var.vpc_octet4
  vpc_mask                  = var.vpc_mask
  name                      = var.name
  domain_name               = var.domain_name
  domain_name_servers       = var.domain_name_servers
  ntp_servers               = var.ntp_servers
  netbios_node_type         = var.netbios_node_type
  netbios_name_servers      = var.netbios_name_servers
  acl_rules                 = var.acl_rules
  allowed_external_ranges   = var.allowed_external_ranges
  sharedservices_tgw_id     = var.sharedservices_tgw_id
  attachedvpc_cidr          = var.attachedvpc_cidr
  default_tags              = var.default_tags
  sharedservices_subnet_suffix = var.sharedservices_subnet_suffix
  interconnect_subnet_suffix = var.interconnect_subnet_suffix
  ss_tgw_attachment_state = var.ss_tgw_attachment_state
  deploy_role_name          = var.deploy_role_name
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

variable "vpc_octet1" {
  type = number
  default = 10
}

variable "vpc_octet2" {
  type = number
  default = 0
}

variable "vpc_octet3" {
  type = number
  default = 0
}

variable "vpc_octet4" {
  type = number
  default =0
}

variable "vpc_mask" {
  type = number
  default = 16
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
  default = [
    {
      rule_no   = 100
      action    = "allow"
      protocol  = "tcp"
      from_port = 22
      to_port   = 22
      cidr_block= "example_cider_block"
    }
  ]
}

variable "allowed_external_ranges" {
  type = list(string)
  default = ["0.0.0.0/0"]
}

variable "sharedservices_tgw_id" {
  type = string
  default = "tgw-example-tgw-id"
}

variable "ixtgw_amazon_side_asn" {
  type    = number
  default = 64512
}

variable "attachedvpc_cidr" {
  type = string
  default = "10.0.1.0/24"
}

variable "default_tags" {
  type = map(any)
  default = { "Project" = "example_project" }
}

variable "deploy_role_name" {
  type = string
  default = "example_deploy_role_name"
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
```

#### output.tf
```hcl
output "vpc_id" {
  value = module.aws_attached_vpc.vpc_id
}

output "routable_subnet_ids" {
  value = module.aws_attached_vpc.routable_subnet_ids
}
```
*/

#VPC
resource "aws_vpc" "interconnect" {

  cidr_block           = "${local.vpc.vpc_cidr}/${local.vpc.vpc_mask}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.default_tags, {
    "Name" = format("%s", local.vpc.vpc_name)
  })
}

#DHCP Options Set
resource "aws_vpc_dhcp_options" "interconnect" {
  domain_name          = var.domain_name
  domain_name_servers  = var.domain_name_servers
  ntp_servers          = var.ntp_servers
  netbios_name_servers = var.netbios_name_servers
  netbios_node_type    = var.netbios_node_type

  tags = merge(var.default_tags, {
    Name = var.name
  })
}

resource "aws_vpc_dhcp_options_association" "interconnect" {
  vpc_id          = aws_vpc.interconnect.id
  dhcp_options_id = aws_vpc_dhcp_options.interconnect.id
}

#SUBNETS
resource "aws_subnet" "sharedservices" {
  count = length(local.vpc.sharedservices_subnets) > 0 ? length(local.vpc.sharedservices_subnets) : 0

  vpc_id                  = aws_vpc.interconnect.id
  cidr_block              = element(concat(local.vpc.sharedservices_subnets, [""]), count.index)
  availability_zone       = length(regexall("^[a-z]{2}-", element(local.sharedservices_azs, count.index))) > 0 ? element(local.sharedservices_azs, count.index) : null
  availability_zone_id    = length(regexall("^[a-z]{2}-", element(local.sharedservices_azs, count.index))) == 0 ? element(local.sharedservices_azs, count.index) : null
  map_public_ip_on_launch = false

  tags = merge(var.default_tags, {
    "Name" = format(
      "%s-${var.sharedservices_subnet_suffix}-%s",
      var.name,
      element(local.sharedservices_azs, count.index),
    ),
    "Tier" = "sharedservices"
  })
}

resource "aws_subnet" "interconnect" {
  count = length(local.vpc.interconnect_subnets) > 0 ? length(local.vpc.interconnect_subnets) : 0

  vpc_id                  = aws_vpc.interconnect.id
  cidr_block              = local.vpc.interconnect_subnets[count.index]
  availability_zone       = length(regexall("^[a-z]{2}-", element(local.interconnect_azs, count.index))) > 0 ? element(local.interconnect_azs, count.index) : null
  availability_zone_id    = length(regexall("^[a-z]{2}-", element(local.interconnect_azs, count.index))) == 0 ? element(local.interconnect_azs, count.index) : null
  map_public_ip_on_launch = false

  tags = merge(var.default_tags, {
    "Name" = format(
      "%s-${var.interconnect_subnet_suffix}-%s",
      var.name,
      element(local.interconnect_azs, count.index),
    ),
    "Tier" = "interconnect"
  })
}

#NACLS
#SharedServices
resource "aws_network_acl" "sharedservices" {
  count = length(local.vpc.sharedservices_subnets) > 0 ? 1 : 0

  vpc_id     = element(concat(aws_vpc.interconnect.*.id, [""]), 0)
  subnet_ids = aws_subnet.sharedservices.*.id

  tags = merge(var.default_tags, {
    "Name" = format("%s-${var.sharedservices_subnet_suffix}", var.name)
  })
}

resource "aws_network_acl_rule" "sharedservices_inbound" {
  count = length(local.vpc.sharedservices_subnets) > 0 ? length(var.acl_rules) : 0
  depends_on = [
    aws_network_acl.sharedservices[0]
  ]
  network_acl_id = aws_network_acl.sharedservices[0].id

  egress          = false
  rule_number     = var.acl_rules[count.index]["rule_no"]
  rule_action     = var.acl_rules[count.index]["action"]
  from_port       = lookup(var.acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.acl_rules[count.index], "icmp_type", null)
  protocol        = var.acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "sharedservices_outbound" {
  count = length(local.vpc.sharedservices_subnets) > 0 ? length(var.acl_rules) : 0
  depends_on = [
    aws_network_acl.sharedservices[0]
  ]

  network_acl_id = aws_network_acl.sharedservices[0].id

  egress          = true
  rule_number     = var.acl_rules[count.index]["rule_no"]
  rule_action     = var.acl_rules[count.index]["action"]
  from_port       = lookup(var.acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.acl_rules[count.index], "icmp_type", null)
  protocol        = var.acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.acl_rules[count.index], "ipv6_cidr_block", null)
}

#Interconnect
resource "aws_network_acl" "interconnect" {
  count = length(local.vpc.interconnect_subnets) > 0 ? 1 : 0

  vpc_id     = element(concat(aws_vpc.interconnect.*.id, [""]), 0)
  subnet_ids = aws_subnet.interconnect.*.id

  tags = merge(var.default_tags, {
    "Name" = format("%s-${var.interconnect_subnet_suffix}", var.name)
  })
}

resource "aws_network_acl_rule" "interconnect_inbound" {
  count = length(local.vpc.interconnect_subnets) > 0 ? length(var.acl_rules) : 0
  depends_on = [
    aws_network_acl.interconnect[0]
  ]
  network_acl_id = aws_network_acl.interconnect[0].id

  egress          = false
  rule_number     = var.acl_rules[count.index]["rule_no"]
  rule_action     = var.acl_rules[count.index]["action"]
  from_port       = lookup(var.acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.acl_rules[count.index], "icmp_type", null)
  protocol        = var.acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "interconnect_outbound" {
  count = length(local.vpc.interconnect_subnets) > 0 ? length(var.acl_rules) : 0
  depends_on = [
    aws_network_acl.interconnect[0]
  ]
  network_acl_id = aws_network_acl.interconnect[0].id

  egress          = true
  rule_number     = var.acl_rules[count.index]["rule_no"]
  rule_action     = var.acl_rules[count.index]["action"]
  from_port       = lookup(var.acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.acl_rules[count.index], "icmp_type", null)
  protocol        = var.acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.acl_rules[count.index], "ipv6_cidr_block", null)
}

#SharedServices TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "sharedservices" {
  count              = var.ss_tgw_attachment_state == "ready" ? 1 : 0
  subnet_ids         = aws_subnet.sharedservices.*.id
  transit_gateway_id = data.aws_ec2_transit_gateway.sharedservices.id
  vpc_id             = aws_vpc.interconnect.id
}

#Interconnect TGW
resource "aws_ec2_transit_gateway" "interconnect" {
  description                     = "Interconnect TGW - ${var.name}"
  amazon_side_asn                 = var.ixtgw_amazon_side_asn
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  tags = merge(var.default_tags, {
    Name = "${var.name} - Interconnect TGW"
  })
}

resource "aws_ec2_transit_gateway_vpc_attachment" "interconnect" {
  subnet_ids                                      = aws_subnet.interconnect.*.id
  transit_gateway_id                              = aws_ec2_transit_gateway.interconnect.id
  vpc_id                                          = aws_vpc.interconnect.id
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true
  tags = merge(var.default_tags, {
    Name = "${var.name} - Interconnect TGW"
  })
}

# resource "aws_ec2_transit_gateway_route_table" "interconnect" {
#   transit_gateway_id = aws_ec2_transit_gateway.interconnect.id
# }

resource "aws_ec2_transit_gateway_route" "interconnect" {
  count                          = length(local.vpc.interconnect_subnets) > 0 ? length(var.allowed_external_ranges) : 0
  destination_cidr_block         = var.allowed_external_ranges[count.index]
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.interconnect.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.interconnect.association_default_route_table_id
}

# resource "aws_ec2_transit_gateway_route_table_association" "interconnect" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.interconnect.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway.interconnect.association_default_route_table_id
# }

#Route tables
resource "aws_route_table" "sharedservices" {
  count = length(local.vpc.sharedservices_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.interconnect.id

  tags = merge(var.default_tags, {
    "Name" = format("%s-${var.sharedservices_subnet_suffix}-%s",
      var.name,
    count.index)
  })
}

resource "aws_route_table" "interconnect" {
  count = length(local.vpc.interconnect_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.interconnect.id

  tags = merge(var.default_tags, {
    "Name" = format(
      "%s-${var.interconnect_subnet_suffix}-%s",
      var.name,
      count.index,
    )
  })
}

resource "aws_route" "sharedservices_tgw_default" {
  count                  = var.ss_tgw_attachment_state == "ready" ? 1 : 0
  route_table_id         = aws_route_table.sharedservices[0].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = data.aws_ec2_transit_gateway.sharedservices.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "sharedservices_tgw_attachedvpc" {
  route_table_id         = aws_route_table.sharedservices[0].id
  destination_cidr_block = var.attachedvpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.interconnect.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "interconnect_tgw_default" {
  count                  = var.ss_tgw_attachment_state == "ready" ? 1 : 0
  route_table_id         = aws_route_table.interconnect[0].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = data.aws_ec2_transit_gateway.sharedservices.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "interconnect_tgw_attachedvpc" {
  route_table_id         = aws_route_table.interconnect[0].id
  destination_cidr_block = var.attachedvpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.interconnect.id

  timeouts {
    create = "5m"
  }
}

#Route table associations
resource "aws_route_table_association" "sharedservices" {
  count = length(local.vpc.sharedservices_subnets)

  subnet_id = element(aws_subnet.sharedservices.*.id, count.index)
  route_table_id = element(
    aws_route_table.sharedservices.*.id,
    count.index,
  )
}

resource "aws_route_table_association" "interconnect" {
  count = length(local.vpc.interconnect_subnets)

  subnet_id = element(aws_subnet.interconnect.*.id, count.index)
  route_table_id = element(
    aws_route_table.interconnect.*.id,
    count.index,
  )
}

#FlowLogs
resource "aws_flow_log" "interconnect" {
  iam_role_arn    = aws_iam_role.interconnect.arn
  log_destination = aws_cloudwatch_log_group.interconnect.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.interconnect.id
}

resource "aws_cloudwatch_log_group" "interconnect" {
  name              = "${var.collection_identifier}/VPCFlowLogs-${var.environment}"
  retention_in_days = var.cloudwatch_flowlog_retention_days
  kms_key_id        = var.kms_key_arn
  /*tags not supported and cause incomplete deployment, with no error
  tags = merge(var.default_tags, {
      name = "${var.collection_identifier}/VPCFlowLogs-${var.environment}"
      environment = (var.environment)
  })
*/
}

resource "aws_iam_role" "interconnect" {
  name = "${var.collection_identifier}-vpc-flowlogs-${var.environment}"

  assume_role_policy = data.aws_iam_policy_document.vpcflowlogs_assume_role.json
}

resource "aws_iam_role_policy" "interconnect" {
  name = "${var.collection_identifier}-policy-vpc-flowlogs"
  role = aws_iam_role.interconnect.id

  policy = data.aws_iam_policy_document.flowlogs.json
}
