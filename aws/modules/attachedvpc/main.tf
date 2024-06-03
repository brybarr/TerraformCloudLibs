/*
# AWS Attached VPC Terraform Module

# Pending tasks
- cleanup variable.tf validation part
- cleanup default values

## Overview

This Terraform module sets up a VPC along with public and private subnets, route tables, and security groups.

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

- Creates an AWS VPC with customizable CIDR blocks.
- Supports both routable and non-routable subnets.
- Configures Network Access Control Lists (NACLs) and security groups.
- Integrates with AWS Transit Gateway.
- Sets up VPC endpoints for services like S3 and DynamoDB.
- Generates Flow Logs and sends them to a CloudWatch Log Group.

## Inputs

The following inputs are defined in this terraform module:

| Variable                          | Type       | Description                                                                                          | Default           | Required |
| --------------------------------- | ---------- | ---------------------------------------------------------------------------------------------------- | ----------------- | -------- |
| `aws_region`                      | string     | AWS region where resources will be created.                                                           | None             | Yes      |
| `environment`                     | string     | Environment for tagging and naming resources.                                                         | None             | Yes      |
| `aws_account_id`                  | string     | AWS Account ID.                                                                                       | None             | Yes      |
| `collection_identifier`           | string     | Identifier for the collection of resources.                                                           | None             | No       |
| `default_tags`                      | map(any) | Default tags to be added to resources.                                                              | {}               | No       |
| `cloudwatch_flowlog_retention_days` | number   | Number of days to retain CloudWatch flow logs.                                                        | 30               | No       |
| `kms_key_arn`                     | string     | ARN of the KMS key for encryption.                                                                    | None             | No       |
| `interconnect_tgw_id`             | string     | ID of the Transit Gateway for interconnect.                                                           | None             | No       |
| `vpc_routable_octet1`             | number     | First octet of the routable VPC CIDR.                                                                 | 10               | No       |
| `vpc_routable_octet2`             | number     | Second octet of the routable VPC CIDR.                                                                | 0                | No       |
| `vpc_routable_octet3`             | number     | Third octet of the routable VPC CIDR.                                                                 | 0                | No       |
| `vpc_routable_octet4`             | number     | Fourth octet of the routable VPC CIDR.                                                                | 0                | No       |
| `vpc_routable_mask`               | number     | CIDR mask for the routable VPC.                                                                       | 16               | No       |
| `vpc_nonroutable_octet1`          | number     | First octet of the non-routable VPC CIDR.                                                             | 192              | No       |
| `vpc_nonroutable_octet2`          | number     | Second octet of the non-routable VPC CIDR.                                                            | 168              | No       |
| `vpc_nonroutable_octet3`          | number     | Third octet of the non-routable VPC CIDR.                                                             | 0                | No       |
| `vpc_nonroutable_octet4`          | number     | Fourth octet of the non-routable VPC CIDR.                                                            | 0                | No       |
| `vpc_nonroutable_mask`            | number     | CIDR mask for the non-routable VPC.                                                                   | 16               | No       |
| `name`                            | string     | Name to be used as an identifier on all the resources.                                                | None             | Yes      |
| `domain_name`                     | string     | Domain name for the VPC.                                                                              | None             | No       |
| `domain_name_servers`             | list(string) | List of domain name servers.                                                                        | []               | No       |
| `ntp_servers`                     | list(string) | List of NTP servers.                                                                                | []               | No       |
| `netbios_node_type`               | string     | NetBIOS node type.                                                                                    | "2"              | No       |
| `netbios_name_servers`            | list(string) | List of NetBIOS name servers.                                                                       | []               | No       |
| `routable_inbound_acl_rules`      | list(map(string)) | List of maps for inbound ACL rules for the routable subnets.                                   | []               | No       |
| `routable_outbound_acl_rules`     | list(map(string)) | List of maps for outbound ACL rules for the routable subnets.                                  | []               | No       |
| `nonroutable_inbound_acl_rules`   | list(map(string)) | List of maps for inbound ACL rules for the non-routable subnets.                               | []               | No       |
| `nonroutable_outbound_acl_rules`  | list(map(string)) | List of maps for outbound ACL rules for the non-routable subnets.                              | []               | No       |
| `deploy_role_name`                | string     | Name of the AWS IAM role used for deployment.                                                         | None             | No       |
| `routable_subnet_suffix`          | string     | Suffix for the routable subnets.                                                                      | "routable"       | No       |
| `nonroutable_subnet_suffix`       | string     | Suffix for the non-routable subnets.                                                                  | "nonroutable"    | No       |
| `org_id`                          | string     | AWS Organization ID.                                                                                  | None             | No       |

## Outputs

| Name                            | Description                                        |
|---------------------------------|----------------------------------------------------|
| `vpc_id`                        | ID of the created AWS VPC                          |
| `routable_subnet_ids`           | IDs of the routable subnets.                       |
| `non_routable_subnet_ids`       | IDs of the non-routable subnets.                   |
| `routable_route_table_ids`      | IDs of the route tables for routable subnets.      |
| `non_routable_route_table_ids`  | IDs of the route tables for non-routable subnets.  |

### Example

#### main.tf
```hcl
module "aws_vpc" {
  source               = "git::https://github.com/terraform-modules-library.git//aws/modules/attachedvpc"

  aws_region                      = var.aws_region
  environment                     = var.environment
  aws_account_id                  = var.aws_account_id
  collection_identifier           = var.collection_identifier
  default_tags                    = var.default_tags
  cloudwatch_flowlog_retention_days =  var.cloudwatch_flowlog_retention_days
  interconnect_tgw_id             = var.interconnect_tgw_id
  vpc_routable_octet1             = var.vpc_routable_octet1
  vpc_routable_octet2             = var.vpc_routable_octet2
  vpc_routable_octet3             = var.vpc_routable_octet3
  vpc_routable_octet4             = var.vpc_routable_octet4
  vpc_routable_mask               = var.vpc_routable_mask
  vpc_nonroutable_octet1          = var.vpc_nonroutable_octet1
  vpc_nonroutable_octet2          = var.vpc_nonroutable_octet2
  vpc_nonroutable_octet3          = var.vpc_nonroutable_octet3
  vpc_nonroutable_octet4          = var.vpc_nonroutable_octet4
  vpc_nonroutable_mask            = var.vpc_nonroutable_mask
  name                            = var.name
  domain_name                     = var.domain_name
  domain_name_servers             = var.domain_name_servers
  ntp_servers                     = var.ntp_servers
  netbios_node_type               = var.netbios_node_type
  netbios_name_servers            = var.netbios_name_servers
  routable_inbound_acl_rules      = var.routable_inbound_acl_rules
  routable_outbound_acl_rules     = var.routable_outbound_acl_rules
  nonroutable_inbound_acl_rules   = var.nonroutable_inbound_acl_rules
  nonroutable_outbound_acl_rules  = var.nonroutable_outbound_acl_rules
  deploy_role_name                = var.deploy_role_name
  routable_subnet_suffix          = var.routable_subnet_suffix
  nonroutable_subnet_suffix       = var.nonroutable_subnet_suffix
  org_id                          = var. org_id
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
  default = "Example-collection"
}

variable "default_tags" {
  type = map(any)
  default = { "Environment" = "Dev" }
}

variable "cloudwatch_flowlog_retention_days" {
  type = number
  default = 7
}

variable "interconnect_tgw_id" {
  type = string
  default = "tgw-0123456789abcdef0"
}

variable "vpc_routable_octet1" {
  type = number
  default = 10
}

variable "vpc_routable_octet2" {
  type = number
  default = 0
}

variable "vpc_routable_octet3" {
  type = number
  default = 0
}

variable "vpc_routable_octet4" {
  type = number
  default = 0
}

variable "vpc_routable_mask" {
  type = number
  default = 16
}

variable "vpc_nonroutable_octet1" {
  type = number
  default = 192
}

variable "vpc_nonroutable_octet2" {
  type = number
  default = 168
}

variable "vpc_nonroutable_octet3" {
  type = number
  default = 0
}

variable "vpc_nonroutable_octet4" {
  type = number
  default = 0
}

variable "vpc_nonroutable_mask" {
  type = number
  default =16
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = "example-attachedvpc"
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
  default = [{ "action" : "allow",
    "cidr_block" : "0.0.0.0/0",
    "from_port" : 0,
    "protocol" : "-1",
    "rule_no" : 100,
    "to_port" : 0 },
    { "action" : "allow",
      "from_port" : 0,
      "ipv6_cidr_block" : "::/0",
      "protocol" : "-1",
      "rule_no" : 101,
    "to_port" : 0 }
  ]
}

variable "routable_outbound_acl_rules" {
  type = list(map(string))
  default = [{ "action" : "allow",
    "cidr_block" : "0.0.0.0/0",
    "from_port" : 0,
    "protocol" : "-1",
    "rule_no" : 100,
    "to_port" : 0 },
    { "action" : "allow",
      "from_port" : 0,
      "ipv6_cidr_block" : "::/0",
      "protocol" : "-1",
      "rule_no" : 101,
    "to_port" : 0 }
  ]
}

variable "nonroutable_inbound_acl_rules" {
  type = list(map(string))
  default = [{ "action" : "allow",
    "cidr_block" : "0.0.0.0/0",
    "from_port" : 0,
    "protocol" : "-1",
    "rule_no" : 100,
    "to_port" : 0 },
    { "action" : "allow",
      "from_port" : 0,
      "ipv6_cidr_block" : "::/0",
      "protocol" : "-1",
      "rule_no" : 101,
    "to_port" : 0 }
  ]
}

variable "nonroutable_outbound_acl_rules" {
  type = list(map(string))
  default = [{ "action" : "allow",
    "cidr_block" : "0.0.0.0/0",
    "from_port" : 0,
    "protocol" : "-1",
    "rule_no" : 100,
    "to_port" : 0 },
    { "action" : "allow",
      "from_port" : 0,
      "ipv6_cidr_block" : "::/0",
      "protocol" : "-1",
      "rule_no" : 101,
    "to_port" : 0 }
  ]
}

variable "deploy_role_name" {
  type = string
  default = "example-deploy-role"
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
  default = "example-org-id"
}
```

#### output.tf
```hcl
output "vpc_id" {
  value = module.aws_vpc.vpc_id
}
```

*/

#VPC
resource "aws_vpc" "attachedvpc" {

  cidr_block           = "${local.vpc.routable_cidr}/${local.vpc.routable_mask}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.default_tags, {
    Name = format("%s", local.vpc.vpc_name)
  })
}

#DHCP Options Set
resource "aws_vpc_dhcp_options" "attachedvpc" {
  domain_name          = var.domain_name
  domain_name_servers  = var.domain_name_servers
  ntp_servers          = var.ntp_servers
  netbios_name_servers = var.netbios_name_servers
  netbios_node_type    = var.netbios_node_type

  tags = merge(var.default_tags, {
    Name = var.name
  })
}

resource "aws_vpc_dhcp_options_association" "attachedvpc" {
  vpc_id          = aws_vpc.attachedvpc.id
  dhcp_options_id = aws_vpc_dhcp_options.attachedvpc.id
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = aws_vpc.attachedvpc.id
  cidr_block = "${local.vpc.nonroutable_cidr}/${local.vpc.nonroutable_mask}"
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.attachedvpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#SUBNETS
resource "aws_subnet" "routable" {
  count = length(local.vpc.routable_subnets) > 0 ? length(local.vpc.routable_subnets) : 0

  vpc_id                  = aws_vpc.attachedvpc.id
  cidr_block              = element(concat(local.vpc.routable_subnets, [""]), count.index)
  availability_zone       = length(regexall("^[a-z]{2}-", element(local.routable_azs, count.index))) > 0 ? element(local.routable_azs, count.index) : null
  availability_zone_id    = length(regexall("^[a-z]{2}-", element(local.routable_azs, count.index))) == 0 ? element(local.routable_azs, count.index) : null
  map_public_ip_on_launch = false

  tags = merge(var.default_tags, {
    "Name" = format(
      "%s-${var.routable_subnet_suffix}-%s",
      var.name,
      element(local.routable_azs, count.index),
    ),
    "Tier" = "routable"
  })
}

resource "aws_subnet" "nonroutable" {
  count = length(local.vpc.nonroutable_subnets) > 0 ? length(local.vpc.nonroutable_subnets) : 0

  vpc_id                  = aws_vpc_ipv4_cidr_block_association.secondary_cidr.vpc_id
  cidr_block              = local.vpc.nonroutable_subnets[count.index]
  availability_zone       = length(regexall("^[a-z]{2}-", element(local.nonroutable_azs, count.index))) > 0 ? element(local.nonroutable_azs, count.index) : null
  availability_zone_id    = length(regexall("^[a-z]{2}-", element(local.nonroutable_azs, count.index))) == 0 ? element(local.nonroutable_azs, count.index) : null
  map_public_ip_on_launch = false

  tags = merge(var.default_tags, {
    "Name" = format(
      "%s-${var.nonroutable_subnet_suffix}-%s",
      var.name,
      element(local.nonroutable_azs, count.index),
    ),
    "Tier" = "nonroutable"
  })
}

#NACLS
#Routable
resource "aws_network_acl" "routable" {
  count = length(local.vpc.routable_subnets) > 0 ? 1 : 0

  vpc_id     = element(concat(aws_vpc.attachedvpc.*.id, [""]), 0)
  subnet_ids = aws_subnet.routable.*.id

  tags = merge(var.default_tags, {
    "Name" = format("%s-${var.routable_subnet_suffix}", var.name)
  })
}

resource "aws_network_acl_rule" "routable_inbound" {
  count = length(local.vpc.routable_subnets) > 0 ? length(var.routable_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.routable[0].id

  egress          = false
  rule_number     = var.routable_inbound_acl_rules[count.index]["rule_no"]
  rule_action     = var.routable_inbound_acl_rules[count.index]["action"]
  from_port       = lookup(var.routable_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.routable_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.routable_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.routable_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.routable_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.routable_inbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.routable_inbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "routable_outbound" {
  count = length(local.vpc.routable_subnets) > 0 ? length(var.routable_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.routable[0].id

  egress          = true
  rule_number     = var.routable_outbound_acl_rules[count.index]["rule_no"]
  rule_action     = var.routable_outbound_acl_rules[count.index]["action"]
  from_port       = lookup(var.routable_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.routable_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.routable_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.routable_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.routable_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.routable_outbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.routable_outbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

#Non-routable
resource "aws_network_acl" "nonroutable" {
  count = length(local.vpc.nonroutable_subnets) > 0 ? 1 : 0

  vpc_id     = element(concat(aws_vpc.attachedvpc.*.id, [""]), 0)
  subnet_ids = aws_subnet.nonroutable.*.id

  tags = merge(var.default_tags, {
    "Name" = format("%s-${var.nonroutable_subnet_suffix}", var.name)
  })
}

resource "aws_network_acl_rule" "nonroutable_inbound" {
  count = length(local.vpc.nonroutable_subnets) > 0 ? length(var.nonroutable_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.nonroutable[0].id

  egress          = false
  rule_number     = var.nonroutable_inbound_acl_rules[count.index]["rule_no"]
  rule_action     = var.nonroutable_inbound_acl_rules[count.index]["action"]
  from_port       = lookup(var.nonroutable_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.nonroutable_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.nonroutable_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.nonroutable_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.nonroutable_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.nonroutable_inbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.nonroutable_inbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "nonroutable_outbound" {
  count = length(local.vpc.nonroutable_subnets) > 0 ? length(var.nonroutable_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.nonroutable[0].id

  egress          = true
  rule_number     = var.nonroutable_outbound_acl_rules[count.index]["rule_no"]
  rule_action     = var.nonroutable_outbound_acl_rules[count.index]["action"]
  from_port       = lookup(var.nonroutable_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.nonroutable_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.nonroutable_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.nonroutable_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.nonroutable_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.nonroutable_outbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.nonroutable_outbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

#Interconnect TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "interconnect" {
  subnet_ids                                      = aws_subnet.routable.*.id
  transit_gateway_id                              = data.aws_ec2_transit_gateway.interconnect.id
  vpc_id                                          = aws_vpc.attachedvpc.id
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true

  tags = merge(var.default_tags, {
    Name = "${var.name} - Interconnect TGW"
  })
}


#NAT Gateway
resource "aws_nat_gateway" "attachedvpc" {
  count             = 1
  connectivity_type = "private"
  subnet_id         = element(aws_subnet.routable.*.id, count.index)

  tags = merge(var.default_tags, {
    "Name" = format(
      "%s-%s",
      var.name,
    count.index)
  })
}

#Route tables
resource "aws_route_table" "routable" {
  count = length(local.vpc.routable_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.attachedvpc.id

  tags = merge(var.default_tags, {
    "Name" = format("%s-${var.routable_subnet_suffix}-%s",
      var.name,
    count.index)
  })
}

resource "aws_route_table" "nonroutable" {
  count = length(local.vpc.nonroutable_subnets) > 0 ? length(aws_nat_gateway.attachedvpc) : 0

  vpc_id = aws_vpc.attachedvpc.id

  tags = merge(var.default_tags, {
    "Name" = format(
      "%s-${var.nonroutable_subnet_suffix}-%s",
      var.name,
      count.index,
    )
  })
}

#Route table routes
resource "aws_route" "routable_tgw" {
  route_table_id         = aws_route_table.routable[0].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = data.aws_ec2_transit_gateway.interconnect.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "nonroutable_nat_gateway" {
  count                  = length(local.vpc.nonroutable_subnets) > 0 ? length(aws_nat_gateway.attachedvpc) : 0
  route_table_id         = aws_route_table.nonroutable[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.attachedvpc[count.index].id

  timeouts {
    create = "5m"
  }
}

#Route table associations
resource "aws_route_table_association" "routable" {
  count = length(local.vpc.routable_subnets)

  subnet_id = element(aws_subnet.routable.*.id, count.index)
  route_table_id = element(
    aws_route_table.routable.*.id,
    count.index,
  )
}

resource "aws_route_table_association" "nonroutable" {
  count = length(local.vpc.nonroutable_subnets)

  subnet_id = element(aws_subnet.nonroutable.*.id, count.index)
  route_table_id = element(
    aws_route_table.nonroutable.*.id,
    count.index,
  )
}

#VPC Endpoints
#Gateway (S3)
resource "aws_vpc_endpoint" "gateway_s3" {
  service_name = "com.amazonaws.${var.aws_region}.s3"
  vpc_id       = aws_vpc.attachedvpc.id
  policy       = data.aws_iam_policy_document.s3_gateway_policy.json
}

resource "aws_vpc_endpoint_route_table_association" "attachedvpc" {
  count           = length(concat(aws_route_table.routable.*.id, aws_route_table.nonroutable.*.id))
  route_table_id  = concat(aws_route_table.routable.*.id, aws_route_table.nonroutable.*.id)[count.index]
  vpc_endpoint_id = aws_vpc_endpoint.gateway_s3.id
}

#Interface
resource "aws_vpc_endpoint" "attachedvpc_interface" {
  count              = length(local.vpc.vpc_interface_endpoints)
  service_name       = local.vpc.vpc_interface_endpoints[count.index]
  subnet_ids         = aws_subnet.nonroutable.*.id
  vpc_endpoint_type  = "Interface"
  vpc_id             = aws_vpc.attachedvpc.id
  policy             = data.aws_iam_policy_document.attachedvpc_interface[count.index]
  security_group_ids = [aws_default_security_group.default.id]
}

#FlowLogs
resource "aws_flow_log" "attachedvpc" {
  iam_role_arn    = aws_iam_role.attachedvpc.arn
  log_destination = aws_cloudwatch_log_group.attachedvpc.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.attachedvpc.id
}

resource "aws_cloudwatch_log_group" "attachedvpc" {
  name              = "${var.collection_identifier}/VPCFlowLogs-${var.environment}"
  retention_in_days = var.cloudwatch_flowlog_retention_days
  kms_key_id        = var.kms_key_arn
  tags = merge(var.default_tags, {
    name        = "${var.collection_identifier}/VPCFlowLogs-${var.environment}"
    environment = (var.environment)
  })
}

resource "aws_iam_role" "attachedvpc" {
  name = "${var.collection_identifier}-vpc-flowlogs-${var.environment}"

  assume_role_policy = data.aws_iam_policy_document.vpcflowlogs_assume_role.json
}

resource "aws_iam_role_policy" "attachedvpc" {
  name = "${var.collection_identifier}-policy-vpc-flowlogs"
  role = aws_iam_role.attachedvpc.id

  policy = data.aws_iam_policy_document.flowlogs.json
}
