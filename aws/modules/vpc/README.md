# AWS VPC Module

This is an AWS supported VPC module
- https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/v5.1.1
- https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest

## Usage

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
```

## External NAT Gateway IPs

By default this module will provision new Elastic IPs for the VPC's NAT Gateways.
This means that when creating a new VPC, new IPs are allocated, and when that VPC is destroyed those IPs are released.
Sometimes it is handy to keep the same IPs even after the VPC is destroyed and re-created.
To that end, it is possible to assign existing IPs to the NAT Gateways.
This prevents the destruction of the VPC from releasing those IPs, while making it possible that a re-created VPC uses the same IPs.

To achieve this, allocate the IPs outside the VPC module declaration.

```hcl
resource "aws_eip" "nat" {
  count = 3

  vpc = true
}
```

Then, pass the allocated IPs as a parameter to this module.

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  # The rest of arguments are omitted for brevity

  enable_nat_gateway  = true
  single_nat_gateway  = false
  reuse_nat_ips       = true                    # <= Skip creation of EIPs for the NAT Gateways
  external_nat_ip_ids = "${aws_eip.nat.*.id}"   # <= IPs specified here as input to the module
}
```

Note that in the example we allocate 3 IPs because we will be provisioning 3 NAT Gateways (due to `single_nat_gateway = false` and having 3 subnets).
If, on the other hand, `single_nat_gateway = true`, then `aws_eip.nat` would only need to allocate 1 IP.
Passing the IPs into the module is done by setting two variables `reuse_nat_ips = true` and `external_nat_ip_ids = "${aws_eip.nat.*.id}"`.

## NAT Gateway Scenarios

This module supports three scenarios for creating NAT gateways. Each will be explained in further detail in the corresponding sections.

- One NAT Gateway per subnet (default behavior)
  - `enable_nat_gateway = true`
  - `single_nat_gateway = false`
  - `one_nat_gateway_per_az = false`
- Single NAT Gateway
  - `enable_nat_gateway = true`
  - `single_nat_gateway = true`
  - `one_nat_gateway_per_az = false`
- One NAT Gateway per availability zone
  - `enable_nat_gateway = true`
  - `single_nat_gateway = false`
  - `one_nat_gateway_per_az = true`

If both `single_nat_gateway` and `one_nat_gateway_per_az` are set to `true`, then `single_nat_gateway` takes precedence.

### One NAT Gateway per subnet (default)

By default, the module will determine the number of NAT Gateways to create based on the `max()` of the private subnet lists (`database_subnets`, `elasticache_subnets`, `private_subnets`, and `redshift_subnets`). The module **does not** take into account the number of `intra_subnets`, since the latter are designed to have no Internet access via NAT Gateway. For example, if your configuration looks like the following:

```hcl
database_subnets    = ["10.0.21.0/24", "10.0.22.0/24"]
elasticache_subnets = ["10.0.31.0/24", "10.0.32.0/24"]
private_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
redshift_subnets    = ["10.0.41.0/24", "10.0.42.0/24"]
intra_subnets       = ["10.0.51.0/24", "10.0.52.0/24", "10.0.53.0/24"]
```

Then `5` NAT Gateways will be created since `5` private subnet CIDR blocks were specified.

### Single NAT Gateway

If `single_nat_gateway = true`, then all private subnets will route their Internet traffic through this single NAT gateway. The NAT gateway will be placed in the first public subnet in your `public_subnets` block.

### One NAT Gateway per availability zone

If `one_nat_gateway_per_az = true` and `single_nat_gateway = false`, then the module will place one NAT gateway in each availability zone you specify in `var.azs`. There are some requirements around using this feature flag:

- The variable `var.azs` **must** be specified.
- The number of public subnet CIDR blocks specified in `public_subnets` **must** be greater than or equal to the number of availability zones specified in `var.azs`. This is to ensure that each NAT Gateway has a dedicated public subnet to deploy to.

## "private" versus "intra" subnets

By default, if NAT Gateways are enabled, private subnets will be configured with routes for Internet traffic that point at the NAT Gateways configured by use of the above options.

If you need private subnets that should have no Internet routing (in the sense of [RFC1918 Category 1 subnets](https://tools.ietf.org/html/rfc1918)), `intra_subnets` should be specified. An example use case is configuration of AWS Lambda functions within a VPC, where AWS Lambda functions only need to pass traffic to internal resources or VPC endpoints for AWS services.

Since AWS Lambda functions allocate Elastic Network Interfaces in proportion to the traffic received ([read more](https://docs.aws.amazon.com/lambda/latest/dg/vpc.html)), it can be useful to allocate a large private subnet for such allocations, while keeping the traffic they generate entirely internal to the VPC.

You can add additional tags with `intra_subnet_tags` as with other subnet types.

## VPC Flow Log

VPC Flow Log allows to capture IP traffic for a specific network interface (ENI), subnet, or entire VPC. This module supports enabling or disabling VPC Flow Logs for entire VPC. If you need to have VPC Flow Logs for subnet or ENI, you have to manage it outside of this module with [aws_flow_log resource](https://www.terraform.io/docs/providers/aws/r/flow_log.html).

### VPC Flow Log Examples

By default `file_format` is `plain-text`. You can also specify `parquet` to have logs written in Apache Parquet format.

```
flow_log_file_format = "parquet"
```

### Permissions Boundary

If your organization requires a permissions boundary to be attached to the VPC Flow Log role, make sure that you specify an ARN of the permissions boundary policy as `vpc_flow_log_permissions_boundary` argument. Read more about required [IAM policy for publishing flow logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-cwl.html#flow-logs-iam).

## Conditional creation

Prior to Terraform 0.13, you were unable to specify `count` in a module block. If you wish to toggle the creation of the module's resources in an older (pre 0.13) version of Terraform, you can use the `create_vpc` argument.

```hcl
# This VPC will not be created
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  create_vpc = false
  # ... omitted
}
```

## Public access to RDS instances

Sometimes it is handy to have public access to RDS instances (it is not recommended for production) by specifying these arguments:

```hcl
  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_dns_hostnames = true
  enable_dns_support   = true
```

## Network Access Control Lists (ACL or NACL)

This module can manage network ACL and rules. Once VPC is created, AWS creates the default network ACL, which can be controlled using this module (`manage_default_network_acl = true`).

Also, each type of subnet may have its own network ACL with custom rules per subnet. Eg, set `public_dedicated_network_acl = true` to use dedicated network ACL for the public subnets; set values of `public_inbound_acl_rules` and `public_outbound_acl_rules` to specify all the NACL rules you need to have on public subnets (see `variables.tf` for default values and structures).

By default, all subnets are associated with the default network ACL.

## Public access to Redshift cluster

Sometimes it is handy to have public access to Redshift clusters (for example if you need to access it by Kinesis - VPC endpoint for Kinesis is not yet supported by Redshift) by specifying these arguments:

```hcl
  enable_public_redshift = true  # <= By default Redshift subnets will be associated with the private route table
```

## Transit Gateway (TGW) integration

It is possible to integrate this VPC module with [terraform-aws-transit-gateway module](https://github.com/terraform-aws-modules/terraform-aws-transit-gateway) which handles the creation of TGW resources and VPC attachments. See [complete example there](https://github.com/terraform-aws-modules/terraform-aws-transit-gateway/tree/master/examples/complete).

## VPC CIDR from AWS IP Address Manager (IPAM)

It is possible to have your VPC CIDR assigned from an [AWS IPAM Pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipam_pool). However, In order to build subnets within this module Terraform must know subnet CIDRs to properly plan the amount of resources to build. Since CIDR is derived by IPAM by calling CreateVpc this is not possible within a module unless cidr is known ahead of time. You can get around this by "previewing" the CIDR and then using that as the subnet values.

_Note: Due to race conditions with `terraform plan`, it is not possible to use `ipv4_netmask_length` or a pools `allocation_default_netmask_length` within this module. You must explicitly set the CIDRs for a pool to use._

```hcl
# Find the pool RAM shared to your account
# Info on RAM sharing pools: https://docs.aws.amazon.com/vpc/latest/ipam/share-pool-ipam.html
data "aws_vpc_ipam_pool" "ipv4_example" {
  filter {
    name   = "description"
    values = ["*mypool*"]
  }

  filter {
    name   = "address-family"
    values = ["ipv4"]
  }
}

# Preview next CIDR from pool
data "aws_vpc_ipam_preview_next_cidr" "previewed_cidr" {
  ipam_pool_id   = data.aws_vpc_ipam_pool.ipv4_example.id
  netmask_length = 24
}

data "aws_region" "current" {}

# Calculate subnet cidrs from previewed IPAM CIDR
locals {
  partition       = cidrsubnets(data.aws_vpc_ipam_preview_next_cidr.previewed_cidr.cidr, 2, 2)
  private_subnets = cidrsubnets(local.partition[0], 2, 2)
  public_subnets  = cidrsubnets(local.partition[1], 2, 2)
  azs             = formatlist("${data.aws_region.current.name}%s", ["a", "b"])
}

module "vpc_cidr_from_ipam" {
  source            = "terraform-aws-modules/vpc/aws"
  name              = "vpc-cidr-from-ipam"
  ipv4_ipam_pool_id = data.aws_vpc_ipam_pool.ipv4_example.id
  azs               = local.azs
  cidr              = data.aws_vpc_ipam_preview_next_cidr.previewed_cidr.cidr
  private_subnets   = local.private_subnets
  public_subnets    = local.public_subnets
}
```

## Examples

- [Complete VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/complete) with VPC Endpoints.
- [VPC using IPAM](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/ipam)
- [Dualstack IPv4/IPv6 VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/ipv6-dualstack)
- [IPv6 only subnets/VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/ipv6-only)
- [Manage Default VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/manage-default-vpc)
- [Network ACL](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/network-acls)
- [VPC with Outpost](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/outpost)
- [VPC with secondary CIDR blocks](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/secondary-cidr-blocks)
- [VPC with unique route tables](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/separate-route-tables)
- [Simple VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/simple)
- [VPC Flow Logs](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/vpc-flow-logs)
- [Few tests and edge case examples](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/issues)

## Contributing

Report issues/questions/feature requests on in the [issues](https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/new) section.

Full contributing [guidelines are covered here](.github/contributing.md).

## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider_aws) (>= 5.0)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aws_cloudwatch_log_group.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) (resource)
- [aws_customer_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/customer_gateway) (resource)
- [aws_db_subnet_group.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) (resource)
- [aws_default_network_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) (resource)
- [aws_default_route_table.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) (resource)
- [aws_default_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) (resource)
- [aws_default_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) (resource)
- [aws_egress_only_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/egress_only_internet_gateway) (resource)
- [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) (resource)
- [aws_elasticache_subnet_group.elasticache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) (resource)
- [aws_flow_log.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) (resource)
- [aws_iam_policy.vpc_flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) (resource)
- [aws_iam_role.vpc_flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)
- [aws_iam_role_policy_attachment.vpc_flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)
- [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) (resource)
- [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) (resource)
- [aws_network_acl.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) (resource)
- [aws_network_acl.elasticache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) (resource)
- [aws_network_acl.intra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) (resource)
- [aws_network_acl.outpost](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) (resource)
- [aws_network_acl.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) (resource)
- [aws_network_acl.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) (resource)
- [aws_network_acl.redshift](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) (resource)
- [aws_network_acl_rule.database_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) (resource)
- [aws_network_acl_rule.database_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) (resource)
- [aws_network_acl_rule.elasticache_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) (resource)
- [aws_network_acl_rule.elasticache_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) (resource)
- [aws_network_acl_rule.intra_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) (resource)
- [aws_network_acl_rule.intra_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) (resource)
- [aws_network_acl_rule.outpost_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) (resource)
- [aws_network_acl_rule.outpost_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) (resource)
- [aws_network_acl_rule.private_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) (resource)
- [aws_network_acl_rule.private_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) (resource)
- [aws_network_acl_rule.public_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) (resource)
- [aws_network_acl_rule.public_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) (resource)
- [aws_network_acl_rule.redshift_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) (resource)
- [aws_network_acl_rule.redshift_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) (resource)
- [aws_redshift_subnet_group.redshift](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_subnet_group) (resource)
- [aws_route.database_dns64_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) (resource)
- [aws_route.database_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) (resource)
- [aws_route.database_ipv6_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) (resource)
- [aws_route.database_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) (resource)
- [aws_route.private_dns64_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) (resource)
- [aws_route.private_ipv6_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) (resource)
- [aws_route.private_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) (resource)
- [aws_route.public_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) (resource)
- [aws_route.public_internet_gateway_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) (resource)
- [aws_route_table.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) (resource)
- [aws_route_table.elasticache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) (resource)
- [aws_route_table.intra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) (resource)
- [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) (resource)
- [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) (resource)
- [aws_route_table.redshift](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) (resource)
- [aws_route_table_association.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) (resource)
- [aws_route_table_association.elasticache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) (resource)
- [aws_route_table_association.intra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) (resource)
- [aws_route_table_association.outpost](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) (resource)
- [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) (resource)
- [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) (resource)
- [aws_route_table_association.redshift](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) (resource)
- [aws_route_table_association.redshift_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) (resource)
- [aws_subnet.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) (resource)
- [aws_subnet.elasticache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) (resource)
- [aws_subnet.intra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) (resource)
- [aws_subnet.outpost](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) (resource)
- [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) (resource)
- [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) (resource)
- [aws_subnet.redshift](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) (resource)
- [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) (resource)
- [aws_vpc_dhcp_options.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options) (resource)
- [aws_vpc_dhcp_options_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association) (resource)
- [aws_vpc_ipv4_cidr_block_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipv4_cidr_block_association) (resource)
- [aws_vpn_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway) (resource)
- [aws_vpn_gateway_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway_attachment) (resource)
- [aws_vpn_gateway_route_propagation.intra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway_route_propagation) (resource)
- [aws_vpn_gateway_route_propagation.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway_route_propagation) (resource)
- [aws_vpn_gateway_route_propagation.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway_route_propagation) (resource)
- [aws_iam_policy_document.flow_log_cloudwatch_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
- [aws_iam_policy_document.vpc_flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)

## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_amazon_side_asn"></a> [amazon_side_asn](#input_amazon_side_asn)

Description: The Autonomous System Number (ASN) for the Amazon side of the gateway. By default the virtual private gateway is created with the current default Amazon ASN

Type: `string`

Default: `"64512"`

### <a name="input_azs"></a> [azs](#input_azs)

Description: A list of availability zones names or ids in the region

Type: `list(string)`

Default: `[]`

### <a name="input_cidr"></a> [cidr](#input_cidr)

Description: (Optional) The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using `ipv4_netmask_length` & `ipv4_ipam_pool_id`

Type: `string`

Default: `"10.0.0.0/16"`

### <a name="input_create_database_internet_gateway_route"></a> [create_database_internet_gateway_route](#input_create_database_internet_gateway_route)

Description: Controls if an internet gateway route for public database access should be created

Type: `bool`

Default: `false`

### <a name="input_create_database_nat_gateway_route"></a> [create_database_nat_gateway_route](#input_create_database_nat_gateway_route)

Description: Controls if a nat gateway route should be created to give internet access to the database subnets

Type: `bool`

Default: `false`

### <a name="input_create_database_subnet_group"></a> [create_database_subnet_group](#input_create_database_subnet_group)

Description: Controls if database subnet group should be created (n.b. database_subnets must also be set)

Type: `bool`

Default: `true`

### <a name="input_create_database_subnet_route_table"></a> [create_database_subnet_route_table](#input_create_database_subnet_route_table)

Description: Controls if separate route table for database should be created

Type: `bool`

Default: `false`

### <a name="input_create_egress_only_igw"></a> [create_egress_only_igw](#input_create_egress_only_igw)

Description: Controls if an Egress Only Internet Gateway is created and its related routes

Type: `bool`

Default: `true`

### <a name="input_create_elasticache_subnet_group"></a> [create_elasticache_subnet_group](#input_create_elasticache_subnet_group)

Description: Controls if elasticache subnet group should be created

Type: `bool`

Default: `true`

### <a name="input_create_elasticache_subnet_route_table"></a> [create_elasticache_subnet_route_table](#input_create_elasticache_subnet_route_table)

Description: Controls if separate route table for elasticache should be created

Type: `bool`

Default: `false`

### <a name="input_create_flow_log_cloudwatch_iam_role"></a> [create_flow_log_cloudwatch_iam_role](#input_create_flow_log_cloudwatch_iam_role)

Description: Whether to create IAM role for VPC Flow Logs

Type: `bool`

Default: `false`

### <a name="input_create_flow_log_cloudwatch_log_group"></a> [create_flow_log_cloudwatch_log_group](#input_create_flow_log_cloudwatch_log_group)

Description: Whether to create CloudWatch log group for VPC Flow Logs

Type: `bool`

Default: `false`

### <a name="input_create_igw"></a> [create_igw](#input_create_igw)

Description: Controls if an Internet Gateway is created for public subnets and the related routes that connect them

Type: `bool`

Default: `true`

### <a name="input_create_redshift_subnet_group"></a> [create_redshift_subnet_group](#input_create_redshift_subnet_group)

Description: Controls if redshift subnet group should be created

Type: `bool`

Default: `true`

### <a name="input_create_redshift_subnet_route_table"></a> [create_redshift_subnet_route_table](#input_create_redshift_subnet_route_table)

Description: Controls if separate route table for redshift should be created

Type: `bool`

Default: `false`

### <a name="input_create_vpc"></a> [create_vpc](#input_create_vpc)

Description: Controls if VPC should be created (it affects almost all resources)

Type: `bool`

Default: `true`

### <a name="input_customer_gateway_tags"></a> [customer_gateway_tags](#input_customer_gateway_tags)

Description: Additional tags for the Customer Gateway

Type: `map(string)`

Default: `{}`

### <a name="input_customer_gateways"></a> [customer_gateways](#input_customer_gateways)

Description: Maps of Customer Gateway's attributes (BGP ASN and Gateway's Internet-routable external IP address)

Type: `map(map(any))`

Default: `{}`

### <a name="input_customer_owned_ipv4_pool"></a> [customer_owned_ipv4_pool](#input_customer_owned_ipv4_pool)

Description: The customer owned IPv4 address pool. Typically used with the `map_customer_owned_ip_on_launch` argument. The `outpost_arn` argument must be specified when configured

Type: `string`

Default: `null`

### <a name="input_database_acl_tags"></a> [database_acl_tags](#input_database_acl_tags)

Description: Additional tags for the database subnets network ACL

Type: `map(string)`

Default: `{}`

### <a name="input_database_dedicated_network_acl"></a> [database_dedicated_network_acl](#input_database_dedicated_network_acl)

Description: Whether to use dedicated network ACL (not default) and custom rules for database subnets

Type: `bool`

Default: `false`

### <a name="input_database_inbound_acl_rules"></a> [database_inbound_acl_rules](#input_database_inbound_acl_rules)

Description: Database subnets inbound network ACL rules

Type: `list(map(string))`

Default:

```json
[
  {
    "cidr_block": "0.0.0.0/0",
    "from_port": 0,
    "protocol": "-1",
    "rule_action": "allow",
    "rule_number": 100,
    "to_port": 0
  }
]
```

### <a name="input_database_outbound_acl_rules"></a> [database_outbound_acl_rules](#input_database_outbound_acl_rules)

Description: Database subnets outbound network ACL rules

Type: `list(map(string))`

Default:

```json
[
  {
    "cidr_block": "0.0.0.0/0",
    "from_port": 0,
    "protocol": "-1",
    "rule_action": "allow",
    "rule_number": 100,
    "to_port": 0
  }
]
```

### <a name="input_database_route_table_tags"></a> [database_route_table_tags](#input_database_route_table_tags)

Description: Additional tags for the database route tables

Type: `map(string)`

Default: `{}`

### <a name="input_database_subnet_assign_ipv6_address_on_creation"></a> [database_subnet_assign_ipv6_address_on_creation](#input_database_subnet_assign_ipv6_address_on_creation)

Description: Specify true to indicate that network interfaces created in the specified subnet should be assigned an IPv6 address. Default is `false`

Type: `bool`

Default: `false`

### <a name="input_database_subnet_enable_dns64"></a> [database_subnet_enable_dns64](#input_database_subnet_enable_dns64)

Description: Indicates whether DNS queries made to the Amazon-provided DNS Resolver in this subnet should return synthetic IPv6 addresses for IPv4-only destinations. Default: `true`

Type: `bool`

Default: `true`

### <a name="input_database_subnet_enable_resource_name_dns_a_record_on_launch"></a> [database_subnet_enable_resource_name_dns_a_record_on_launch](#input_database_subnet_enable_resource_name_dns_a_record_on_launch)

Description: Indicates whether to respond to DNS queries for instance hostnames with DNS A records. Default: `false`

Type: `bool`

Default: `false`

### <a name="input_database_subnet_enable_resource_name_dns_aaaa_record_on_launch"></a> [database_subnet_enable_resource_name_dns_aaaa_record_on_launch](#input_database_subnet_enable_resource_name_dns_aaaa_record_on_launch)

Description: Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records. Default: `true`

Type: `bool`

Default: `true`

### <a name="input_database_subnet_group_name"></a> [database_subnet_group_name](#input_database_subnet_group_name)

Description: Name of database subnet group

Type: `string`

Default: `null`

### <a name="input_database_subnet_group_tags"></a> [database_subnet_group_tags](#input_database_subnet_group_tags)

Description: Additional tags for the database subnet group

Type: `map(string)`

Default: `{}`

### <a name="input_database_subnet_ipv6_native"></a> [database_subnet_ipv6_native](#input_database_subnet_ipv6_native)

Description: Indicates whether to create an IPv6-only subnet. Default: `false`

Type: `bool`

Default: `false`

### <a name="input_database_subnet_ipv6_prefixes"></a> [database_subnet_ipv6_prefixes](#input_database_subnet_ipv6_prefixes)

Description: Assigns IPv6 database subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list

Type: `list(string)`

Default: `[]`

### <a name="input_database_subnet_names"></a> [database_subnet_names](#input_database_subnet_names)

Description: Explicit values to use in the Name tag on database subnets. If empty, Name tags are generated

Type: `list(string)`

Default: `[]`

### <a name="input_database_subnet_private_dns_hostname_type_on_launch"></a> [database_subnet_private_dns_hostname_type_on_launch](#input_database_subnet_private_dns_hostname_type_on_launch)

Description: The type of hostnames to assign to instances in the subnet at launch. For IPv6-only subnets, an instance DNS name must be based on the instance ID. For dual-stack and IPv4-only subnets, you can specify whether DNS names use the instance IPv4 address or the instance ID. Valid values: `ip-name`, `resource-name`

Type: `string`

Default: `null`

### <a name="input_database_subnet_suffix"></a> [database_subnet_suffix](#input_database_subnet_suffix)

Description: Suffix to append to database subnets name

Type: `string`

Default: `"db"`

### <a name="input_database_subnet_tags"></a> [database_subnet_tags](#input_database_subnet_tags)

Description: Additional tags for the database subnets

Type: `map(string)`

Default: `{}`

### <a name="input_database_subnets"></a> [database_subnets](#input_database_subnets)

Description: A list of database subnets inside the VPC

Type: `list(string)`

Default: `[]`

### <a name="input_default_network_acl_egress"></a> [default_network_acl_egress](#input_default_network_acl_egress)

Description: List of maps of egress rules to set on the Default Network ACL

Type: `list(map(string))`

Default:

```json
[
  {
    "action": "allow",
    "cidr_block": "0.0.0.0/0",
    "from_port": 0,
    "protocol": "-1",
    "rule_no": 100,
    "to_port": 0
  },
  {
    "action": "allow",
    "from_port": 0,
    "ipv6_cidr_block": "::/0",
    "protocol": "-1",
    "rule_no": 101,
    "to_port": 0
  }
]
```

### <a name="input_default_network_acl_ingress"></a> [default_network_acl_ingress](#input_default_network_acl_ingress)

Description: List of maps of ingress rules to set on the Default Network ACL

Type: `list(map(string))`

Default:

```json
[
  {
    "action": "allow",
    "cidr_block": "0.0.0.0/0",
    "from_port": 0,
    "protocol": "-1",
    "rule_no": 100,
    "to_port": 0
  },
  {
    "action": "allow",
    "from_port": 0,
    "ipv6_cidr_block": "::/0",
    "protocol": "-1",
    "rule_no": 101,
    "to_port": 0
  }
]
```

### <a name="input_default_network_acl_name"></a> [default_network_acl_name](#input_default_network_acl_name)

Description: Name to be used on the Default Network ACL

Type: `string`

Default: `null`

### <a name="input_default_network_acl_tags"></a> [default_network_acl_tags](#input_default_network_acl_tags)

Description: Additional tags for the Default Network ACL

Type: `map(string)`

Default: `{}`

### <a name="input_default_route_table_name"></a> [default_route_table_name](#input_default_route_table_name)

Description: Name to be used on the default route table

Type: `string`

Default: `null`

### <a name="input_default_route_table_propagating_vgws"></a> [default_route_table_propagating_vgws](#input_default_route_table_propagating_vgws)

Description: List of virtual gateways for propagation

Type: `list(string)`

Default: `[]`

### <a name="input_default_route_table_routes"></a> [default_route_table_routes](#input_default_route_table_routes)

Description: Configuration block of routes. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table#route

Type: `list(map(string))`

Default: `[]`

### <a name="input_default_route_table_tags"></a> [default_route_table_tags](#input_default_route_table_tags)

Description: Additional tags for the default route table

Type: `map(string)`

Default: `{}`

### <a name="input_default_security_group_egress"></a> [default_security_group_egress](#input_default_security_group_egress)

Description: List of maps of egress rules to set on the default security group

Type: `list(map(string))`

Default: `[]`

### <a name="input_default_security_group_ingress"></a> [default_security_group_ingress](#input_default_security_group_ingress)

Description: List of maps of ingress rules to set on the default security group

Type: `list(map(string))`

Default: `[]`

### <a name="input_default_security_group_name"></a> [default_security_group_name](#input_default_security_group_name)

Description: Name to be used on the default security group

Type: `string`

Default: `null`

### <a name="input_default_security_group_tags"></a> [default_security_group_tags](#input_default_security_group_tags)

Description: Additional tags for the default security group

Type: `map(string)`

Default: `{}`

### <a name="input_default_vpc_enable_dns_hostnames"></a> [default_vpc_enable_dns_hostnames](#input_default_vpc_enable_dns_hostnames)

Description: Should be true to enable DNS hostnames in the Default VPC

Type: `bool`

Default: `true`

### <a name="input_default_vpc_enable_dns_support"></a> [default_vpc_enable_dns_support](#input_default_vpc_enable_dns_support)

Description: Should be true to enable DNS support in the Default VPC

Type: `bool`

Default: `true`

### <a name="input_default_vpc_name"></a> [default_vpc_name](#input_default_vpc_name)

Description: Name to be used on the Default VPC

Type: `string`

Default: `null`

### <a name="input_default_vpc_tags"></a> [default_vpc_tags](#input_default_vpc_tags)

Description: Additional tags for the Default VPC

Type: `map(string)`

Default: `{}`

### <a name="input_dhcp_options_domain_name"></a> [dhcp_options_domain_name](#input_dhcp_options_domain_name)

Description: Specifies DNS name for DHCP options set (requires enable_dhcp_options set to true)

Type: `string`

Default: `""`

### <a name="input_dhcp_options_domain_name_servers"></a> [dhcp_options_domain_name_servers](#input_dhcp_options_domain_name_servers)

Description: Specify a list of DNS server addresses for DHCP options set, default to AWS provided (requires enable_dhcp_options set to true)

Type: `list(string)`

Default:

```json
[
  "AmazonProvidedDNS"
]
```

### <a name="input_dhcp_options_netbios_name_servers"></a> [dhcp_options_netbios_name_servers](#input_dhcp_options_netbios_name_servers)

Description: Specify a list of netbios servers for DHCP options set (requires enable_dhcp_options set to true)

Type: `list(string)`

Default: `[]`

### <a name="input_dhcp_options_netbios_node_type"></a> [dhcp_options_netbios_node_type](#input_dhcp_options_netbios_node_type)

Description: Specify netbios node_type for DHCP options set (requires enable_dhcp_options set to true)

Type: `string`

Default: `""`

### <a name="input_dhcp_options_ntp_servers"></a> [dhcp_options_ntp_servers](#input_dhcp_options_ntp_servers)

Description: Specify a list of NTP servers for DHCP options set (requires enable_dhcp_options set to true)

Type: `list(string)`

Default: `[]`

### <a name="input_dhcp_options_tags"></a> [dhcp_options_tags](#input_dhcp_options_tags)

Description: Additional tags for the DHCP option set (requires enable_dhcp_options set to true)

Type: `map(string)`

Default: `{}`

### <a name="input_elasticache_acl_tags"></a> [elasticache_acl_tags](#input_elasticache_acl_tags)

Description: Additional tags for the elasticache subnets network ACL

Type: `map(string)`

Default: `{}`

### <a name="input_elasticache_dedicated_network_acl"></a> [elasticache_dedicated_network_acl](#input_elasticache_dedicated_network_acl)

Description: Whether to use dedicated network ACL (not default) and custom rules for elasticache subnets

Type: `bool`

Default: `false`

### <a name="input_elasticache_inbound_acl_rules"></a> [elasticache_inbound_acl_rules](#input_elasticache_inbound_acl_rules)

Description: Elasticache subnets inbound network ACL rules

Type: `list(map(string))`

Default:

```json
[
  {
    "cidr_block": "0.0.0.0/0",
    "from_port": 0,
    "protocol": "-1",
    "rule_action": "allow",
    "rule_number": 100,
    "to_port": 0
  }
]
```

### <a name="input_elasticache_outbound_acl_rules"></a> [elasticache_outbound_acl_rules](#input_elasticache_outbound_acl_rules)

Description: Elasticache subnets outbound network ACL rules

Type: `list(map(string))`

Default:

```json
[
  {
    "cidr_block": "0.0.0.0/0",
    "from_port": 0,
    "protocol": "-1",
    "rule_action": "allow",
    "rule_number": 100,
    "to_port": 0
  }
]
```

### <a name="input_elasticache_route_table_tags"></a> [elasticache_route_table_tags](#input_elasticache_route_table_tags)

Description: Additional tags for the elasticache route tables

Type: `map(string)`

Default: `{}`

### <a name="input_elasticache_subnet_assign_ipv6_address_on_creation"></a> [elasticache_subnet_assign_ipv6_address_on_creation](#input_elasticache_subnet_assign_ipv6_address_on_creation)

Description: Specify true to indicate that network interfaces created in the specified subnet should be assigned an IPv6 address. Default is `false`

Type: `bool`

Default: `false`

### <a name="input_elasticache_subnet_enable_dns64"></a> [elasticache_subnet_enable_dns64](#input_elasticache_subnet_enable_dns64)

Description: Indicates whether DNS queries made to the Amazon-provided DNS Resolver in this subnet should return synthetic IPv6 addresses for IPv4-only destinations. Default: `true`

Type: `bool`

Default: `true`

### <a name="input_elasticache_subnet_enable_resource_name_dns_a_record_on_launch"></a> [elasticache_subnet_enable_resource_name_dns_a_record_on_launch](#input_elasticache_subnet_enable_resource_name_dns_a_record_on_launch)

Description: Indicates whether to respond to DNS queries for instance hostnames with DNS A records. Default: `false`

Type: `bool`

Default: `false`

### <a name="input_elasticache_subnet_enable_resource_name_dns_aaaa_record_on_launch"></a> [elasticache_subnet_enable_resource_name_dns_aaaa_record_on_launch](#input_elasticache_subnet_enable_resource_name_dns_aaaa_record_on_launch)

Description: Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records. Default: `true`

Type: `bool`

Default: `true`

### <a name="input_elasticache_subnet_group_name"></a> [elasticache_subnet_group_name](#input_elasticache_subnet_group_name)

Description: Name of elasticache subnet group

Type: `string`

Default: `null`

### <a name="input_elasticache_subnet_group_tags"></a> [elasticache_subnet_group_tags](#input_elasticache_subnet_group_tags)

Description: Additional tags for the elasticache subnet group

Type: `map(string)`

Default: `{}`

### <a name="input_elasticache_subnet_ipv6_native"></a> [elasticache_subnet_ipv6_native](#input_elasticache_subnet_ipv6_native)

Description: Indicates whether to create an IPv6-only subnet. Default: `false`

Type: `bool`

Default: `false`

### <a name="input_elasticache_subnet_ipv6_prefixes"></a> [elasticache_subnet_ipv6_prefixes](#input_elasticache_subnet_ipv6_prefixes)

Description: Assigns IPv6 elasticache subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list

Type: `list(string)`

Default: `[]`

### <a name="input_elasticache_subnet_names"></a> [elasticache_subnet_names](#input_elasticache_subnet_names)

Description: Explicit values to use in the Name tag on elasticache subnets. If empty, Name tags are generated

Type: `list(string)`

Default: `[]`

### <a name="input_elasticache_subnet_private_dns_hostname_type_on_launch"></a> [elasticache_subnet_private_dns_hostname_type_on_launch](#input_elasticache_subnet_private_dns_hostname_type_on_launch)

Description: The type of hostnames to assign to instances in the subnet at launch. For IPv6-only subnets, an instance DNS name must be based on the instance ID. For dual-stack and IPv4-only subnets, you can specify whether DNS names use the instance IPv4 address or the instance ID. Valid values: `ip-name`, `resource-name`

Type: `string`

Default: `null`

### <a name="input_elasticache_subnet_suffix"></a> [elasticache_subnet_suffix](#input_elasticache_subnet_suffix)

Description: Suffix to append to elasticache subnets name

Type: `string`

Default: `"elasticache"`

### <a name="input_elasticache_subnet_tags"></a> [elasticache_subnet_tags](#input_elasticache_subnet_tags)

Description: Additional tags for the elasticache subnets

Type: `map(string)`

Default: `{}`

### <a name="input_elasticache_subnets"></a> [elasticache_subnets](#input_elasticache_subnets)

Description: A list of elasticache subnets inside the VPC

Type: `list(string)`

Default: `[]`

### <a name="input_enable_dhcp_options"></a> [enable_dhcp_options](#input_enable_dhcp_options)

Description: Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type

Type: `bool`

Default: `false`

### <a name="input_enable_dns_hostnames"></a> [enable_dns_hostnames](#input_enable_dns_hostnames)

Description: Should be true to enable DNS hostnames in the VPC

Type: `bool`

Default: `true`

### <a name="input_enable_dns_support"></a> [enable_dns_support](#input_enable_dns_support)

Description: Should be true to enable DNS support in the VPC

Type: `bool`

Default: `true`

### <a name="input_enable_flow_log"></a> [enable_flow_log](#input_enable_flow_log)

Description: Whether or not to enable VPC Flow Logs

Type: `bool`

Default: `false`

### <a name="input_enable_ipv6"></a> [enable_ipv6](#input_enable_ipv6)

Description: Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block

Type: `bool`

Default: `false`

### <a name="input_enable_nat_gateway"></a> [enable_nat_gateway](#input_enable_nat_gateway)

Description: Should be true if you want to provision NAT Gateways for each of your private networks

Type: `bool`

Default: `false`

### <a name="input_enable_network_address_usage_metrics"></a> [enable_network_address_usage_metrics](#input_enable_network_address_usage_metrics)

Description: Determines whether network address usage metrics are enabled for the VPC

Type: `bool`

Default: `null`

### <a name="input_enable_public_redshift"></a> [enable_public_redshift](#input_enable_public_redshift)

Description: Controls if redshift should have public routing table

Type: `bool`

Default: `false`

### <a name="input_enable_vpn_gateway"></a> [enable_vpn_gateway](#input_enable_vpn_gateway)

Description: Should be true if you want to create a new VPN Gateway resource and attach it to the VPC

Type: `bool`

Default: `false`

### <a name="input_external_nat_ip_ids"></a> [external_nat_ip_ids](#input_external_nat_ip_ids)

Description: List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse_nat_ips)

Type: `list(string)`

Default: `[]`

### <a name="input_external_nat_ips"></a> [external_nat_ips](#input_external_nat_ips)

Description: List of EIPs to be used for `nat_public_ips` output (used in combination with reuse_nat_ips and external_nat_ip_ids)

Type: `list(string)`

Default: `[]`

### <a name="input_flow_log_cloudwatch_iam_role_arn"></a> [flow_log_cloudwatch_iam_role_arn](#input_flow_log_cloudwatch_iam_role_arn)

Description: The ARN for the IAM role that's used to post flow logs to a CloudWatch Logs log group. When flow_log_destination_arn is set to ARN of Cloudwatch Logs, this argument needs to be provided

Type: `string`

Default: `""`

### <a name="input_flow_log_cloudwatch_log_group_kms_key_id"></a> [flow_log_cloudwatch_log_group_kms_key_id](#input_flow_log_cloudwatch_log_group_kms_key_id)

Description: The ARN of the KMS Key to use when encrypting log data for VPC flow logs

Type: `string`

Default: `null`

### <a name="input_flow_log_cloudwatch_log_group_name_prefix"></a> [flow_log_cloudwatch_log_group_name_prefix](#input_flow_log_cloudwatch_log_group_name_prefix)

Description: Specifies the name prefix of CloudWatch Log Group for VPC flow logs

Type: `string`

Default: `"/aws/vpc-flow-log/"`

### <a name="input_flow_log_cloudwatch_log_group_name_suffix"></a> [flow_log_cloudwatch_log_group_name_suffix](#input_flow_log_cloudwatch_log_group_name_suffix)

Description: Specifies the name suffix of CloudWatch Log Group for VPC flow logs

Type: `string`

Default: `""`

### <a name="input_flow_log_cloudwatch_log_group_retention_in_days"></a> [flow_log_cloudwatch_log_group_retention_in_days](#input_flow_log_cloudwatch_log_group_retention_in_days)

Description: Specifies the number of days you want to retain log events in the specified log group for VPC flow logs

Type: `number`

Default: `null`

### <a name="input_flow_log_destination_arn"></a> [flow_log_destination_arn](#input_flow_log_destination_arn)

Description: The ARN of the CloudWatch log group or S3 bucket where VPC Flow Logs will be pushed. If this ARN is a S3 bucket the appropriate permissions need to be set on that bucket's policy. When create_flow_log_cloudwatch_log_group is set to false this argument must be provided

Type: `string`

Default: `""`

### <a name="input_flow_log_destination_type"></a> [flow_log_destination_type](#input_flow_log_destination_type)

Description: Type of flow log destination. Can be s3 or cloud-watch-logs

Type: `string`

Default: `"cloud-watch-logs"`

### <a name="input_flow_log_file_format"></a> [flow_log_file_format](#input_flow_log_file_format)

Description: (Optional) The format for the flow log. Valid values: `plain-text`, `parquet`

Type: `string`

Default: `null`

### <a name="input_flow_log_hive_compatible_partitions"></a> [flow_log_hive_compatible_partitions](#input_flow_log_hive_compatible_partitions)

Description: (Optional) Indicates whether to use Hive-compatible prefixes for flow logs stored in Amazon S3

Type: `bool`

Default: `false`

### <a name="input_flow_log_log_format"></a> [flow_log_log_format](#input_flow_log_log_format)

Description: The fields to include in the flow log record, in the order in which they should appear

Type: `string`

Default: `null`

### <a name="input_flow_log_max_aggregation_interval"></a> [flow_log_max_aggregation_interval](#input_flow_log_max_aggregation_interval)

Description: The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds

Type: `number`

Default: `600`

### <a name="input_flow_log_per_hour_partition"></a> [flow_log_per_hour_partition](#input_flow_log_per_hour_partition)

Description: (Optional) Indicates whether to partition the flow log per hour. This reduces the cost and response time for queries

Type: `bool`

Default: `false`

### <a name="input_flow_log_traffic_type"></a> [flow_log_traffic_type](#input_flow_log_traffic_type)

Description: The type of traffic to capture. Valid values: ACCEPT, REJECT, ALL

Type: `string`

Default: `"ALL"`

### <a name="input_igw_tags"></a> [igw_tags](#input_igw_tags)

Description: Additional tags for the internet gateway

Type: `map(string)`

Default: `{}`

### <a name="input_instance_tenancy"></a> [instance_tenancy](#input_instance_tenancy)

Description: A tenancy option for instances launched into the VPC

Type: `string`

Default: `"default"`

### <a name="input_intra_acl_tags"></a> [intra_acl_tags](#input_intra_acl_tags)

Description: Additional tags for the intra subnets network ACL

Type: `map(string)`

Default: `{}`

### <a name="input_intra_dedicated_network_acl"></a> [intra_dedicated_network_acl](#input_intra_dedicated_network_acl)

Description: Whether to use dedicated network ACL (not default) and custom rules for intra subnets

Type: `bool`

Default: `false`

### <a name="input_intra_inbound_acl_rules"></a> [intra_inbound_acl_rules](#input_intra_inbound_acl_rules)

Description: Intra subnets inbound network ACLs

Type: `list(map(string))`

Default:

```json
[
  {
    "cidr_block": "0.0.0.0/0",
    "from_port": 0,
    "protocol": "-1",
    "rule_action": "allow",
    "rule_number": 100,
    "to_port": 0
  }
]
```

### <a name="input_intra_outbound_acl_rules"></a> [intra_outbound_acl_rules](#input_intra_outbound_acl_rules)

Description: Intra subnets outbound network ACLs

Type: `list(map(string))`

Default:

```json
[
  {
    "cidr_block": "0.0.0.0/0",
    "from_port": 0,
    "protocol": "-1",
    "rule_action": "allow",
    "rule_number": 100,
    "to_port": 0
  }
]
```

### <a name="input_intra_route_table_tags"></a> [intra_route_table_tags](#input_intra_route_table_tags)

Description: Additional tags for the intra route tables

Type: `map(string)`

Default: `{}`

### <a name="input_intra_subnet_assign_ipv6_address_on_creation"></a> [intra_subnet_assign_ipv6_address_on_creation](#input_intra_subnet_assign_ipv6_address_on_creation)

Description: Specify true to indicate that network interfaces created in the specified subnet should be assigned an IPv6 address. Default is `false`

Type: `bool`

Default: `false`

### <a name="input_intra_subnet_enable_dns64"></a> [intra_subnet_enable_dns64](#input_intra_subnet_enable_dns64)

Description: Indicates whether DNS queries made to the Amazon-provided DNS Resolver in this subnet should return synthetic IPv6 addresses for IPv4-only destinations. Default: `true`

Type: `bool`

Default: `true`

### <a name="input_intra_subnet_enable_resource_name_dns_a_record_on_launch"></a> [intra_subnet_enable_resource_name_dns_a_record_on_launch](#input_intra_subnet_enable_resource_name_dns_a_record_on_launch)

Description: Indicates whether to respond to DNS queries for instance hostnames with DNS A records. Default: `false`

Type: `bool`

Default: `false`

### <a name="input_intra_subnet_enable_resource_name_dns_aaaa_record_on_launch"></a> [intra_subnet_enable_resource_name_dns_aaaa_record_on_launch](#input_intra_subnet_enable_resource_name_dns_aaaa_record_on_launch)

Description: Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records. Default: `true`

Type: `bool`

Default: `true`

### <a name="input_intra_subnet_ipv6_native"></a> [intra_subnet_ipv6_native](#input_intra_subnet_ipv6_native)

Description: Indicates whether to create an IPv6-only subnet. Default: `false`

Type: `bool`

Default: `false`

### <a name="input_intra_subnet_ipv6_prefixes"></a> [intra_subnet_ipv6_prefixes](#input_intra_subnet_ipv6_prefixes)

Description: Assigns IPv6 intra subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list

Type: `list(string)`

Default: `[]`

### <a name="input_intra_subnet_names"></a> [intra_subnet_names](#input_intra_subnet_names)

Description: Explicit values to use in the Name tag on intra subnets. If empty, Name tags are generated

Type: `list(string)`

Default: `[]`

### <a name="input_intra_subnet_private_dns_hostname_type_on_launch"></a> [intra_subnet_private_dns_hostname_type_on_launch](#input_intra_subnet_private_dns_hostname_type_on_launch)

Description: The type of hostnames to assign to instances in the subnet at launch. For IPv6-only subnets, an instance DNS name must be based on the instance ID. For dual-stack and IPv4-only subnets, you can specify whether DNS names use the instance IPv4 address or the instance ID. Valid values: `ip-name`, `resource-name`

Type: `string`

Default: `null`

### <a name="input_intra_subnet_suffix"></a> [intra_subnet_suffix](#input_intra_subnet_suffix)

Description: Suffix to append to intra subnets name

Type: `string`

Default: `"intra"`

### <a name="input_intra_subnet_tags"></a> [intra_subnet_tags](#input_intra_subnet_tags)

Description: Additional tags for the intra subnets

Type: `map(string)`

Default: `{}`

### <a name="input_intra_subnets"></a> [intra_subnets](#input_intra_subnets)

Description: A list of intra subnets inside the VPC

Type: `list(string)`

Default: `[]`

### <a name="input_ipv4_ipam_pool_id"></a> [ipv4_ipam_pool_id](#input_ipv4_ipam_pool_id)

Description: (Optional) The ID of an IPv4 IPAM pool you want to use for allocating this VPC's CIDR

Type: `string`

Default: `null`

### <a name="input_ipv4_netmask_length"></a> [ipv4_netmask_length](#input_ipv4_netmask_length)

Description: (Optional) The netmask length of the IPv4 CIDR you want to allocate to this VPC. Requires specifying a ipv4_ipam_pool_id

Type: `number`

Default: `null`

### <a name="input_ipv6_cidr"></a> [ipv6_cidr](#input_ipv6_cidr)

Description: (Optional) IPv6 CIDR block to request from an IPAM Pool. Can be set explicitly or derived from IPAM using `ipv6_netmask_length`

Type: `string`

Default: `null`

### <a name="input_ipv6_cidr_block_network_border_group"></a> [ipv6_cidr_block_network_border_group](#input_ipv6_cidr_block_network_border_group)

Description: By default when an IPv6 CIDR is assigned to a VPC a default ipv6_cidr_block_network_border_group will be set to the region of the VPC. This can be changed to restrict advertisement of public addresses to specific Network Border Groups such as LocalZones

Type: `string`

Default: `null`

### <a name="input_ipv6_ipam_pool_id"></a> [ipv6_ipam_pool_id](#input_ipv6_ipam_pool_id)

Description: (Optional) IPAM Pool ID for a IPv6 pool. Conflicts with `assign_generated_ipv6_cidr_block`

Type: `string`

Default: `null`

### <a name="input_ipv6_netmask_length"></a> [ipv6_netmask_length](#input_ipv6_netmask_length)

Description: (Optional) Netmask length to request from IPAM Pool. Conflicts with `ipv6_cidr_block`. This can be omitted if IPAM pool as a `allocation_default_netmask_length` set. Valid values: `56`

Type: `number`

Default: `null`

### <a name="input_manage_default_network_acl"></a> [manage_default_network_acl](#input_manage_default_network_acl)

Description: Should be true to adopt and manage Default Network ACL

Type: `bool`

Default: `true`

### <a name="input_manage_default_route_table"></a> [manage_default_route_table](#input_manage_default_route_table)

Description: Should be true to manage default route table

Type: `bool`

Default: `true`

### <a name="input_manage_default_security_group"></a> [manage_default_security_group](#input_manage_default_security_group)

Description: Should be true to adopt and manage default security group

Type: `bool`

Default: `true`

### <a name="input_manage_default_vpc"></a> [manage_default_vpc](#input_manage_default_vpc)

Description: Should be true to adopt and manage Default VPC

Type: `bool`

Default: `false`

### <a name="input_map_customer_owned_ip_on_launch"></a> [map_customer_owned_ip_on_launch](#input_map_customer_owned_ip_on_launch)

Description: Specify true to indicate that network interfaces created in the subnet should be assigned a customer owned IP address. The `customer_owned_ipv4_pool` and `outpost_arn` arguments must be specified when set to `true`. Default is `false`

Type: `bool`

Default: `false`

### <a name="input_map_public_ip_on_launch"></a> [map_public_ip_on_launch](#input_map_public_ip_on_launch)

Description: Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is `false`

Type: `bool`

Default: `false`

### <a name="input_name"></a> [name](#input_name)

Description: Name to be used on all the resources as identifier

Type: `string`

Default: `""`

### <a name="input_nat_eip_tags"></a> [nat_eip_tags](#input_nat_eip_tags)

Description: Additional tags for the NAT EIP

Type: `map(string)`

Default: `{}`

### <a name="input_nat_gateway_destination_cidr_block"></a> [nat_gateway_destination_cidr_block](#input_nat_gateway_destination_cidr_block)

Description: Used to pass a custom destination route for private NAT Gateway. If not specified, the default 0.0.0.0/0 is used as a destination route

Type: `string`

Default: `"0.0.0.0/0"`

### <a name="input_nat_gateway_tags"></a> [nat_gateway_tags](#input_nat_gateway_tags)

Description: Additional tags for the NAT gateways

Type: `map(string)`

Default: `{}`

### <a name="input_one_nat_gateway_per_az"></a> [one_nat_gateway_per_az](#input_one_nat_gateway_per_az)

Description: Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`

Type: `bool`

Default: `false`

### <a name="input_outpost_acl_tags"></a> [outpost_acl_tags](#input_outpost_acl_tags)

Description: Additional tags for the outpost subnets network ACL

Type: `map(string)`

Default: `{}`

### <a name="input_outpost_arn"></a> [outpost_arn](#input_outpost_arn)

Description: ARN of Outpost you want to create a subnet in

Type: `string`

Default: `null`

### <a name="input_outpost_az"></a> [outpost_az](#input_outpost_az)

Description: AZ where Outpost is anchored

Type: `string`

Default: `null`

### <a name="input_outpost_dedicated_network_acl"></a> [outpost_dedicated_network_acl](#input_outpost_dedicated_network_acl)

Description: Whether to use dedicated network ACL (not default) and custom rules for outpost subnets

Type: `bool`

Default: `false`

### <a name="input_outpost_inbound_acl_rules"></a> [outpost_inbound_acl_rules](#input_outpost_inbound_acl_rules)

Description: Outpost subnets inbound network ACLs

Type: `list(map(string))`

Default:

```json
[
  {
    "cidr_block": "0.0.0.0/0",
    "from_port": 0,
    "protocol": "-1",
    "rule_action": "allow",
    "rule_number": 100,
    "to_port": 0
  }
]
```

### <a name="input_outpost_outbound_acl_rules"></a> [outpost_outbound_acl_rules](#input_outpost_outbound_acl_rules)

Description: Outpost subnets outbound network ACLs

Type: `list(map(string))`

Default:

```json
[
  {
    "cidr_block": "0.0.0.0/0",
    "from_port": 0,
    "protocol": "-1",
    "rule_action": "allow",
    "rule_number": 100,
    "to_port": 0
  }
]
```

### <a name="input_outpost_subnet_assign_ipv6_address_on_creation"></a> [outpost_subnet_assign_ipv6_address_on_creation](#input_outpost_subnet_assign_ipv6_address_on_creation)

Description: Specify true to indicate that network interfaces created in the specified subnet should be assigned an IPv6 address. Default is `false`

Type: `bool`

Default: `false`

### <a name="input_outpost_subnet_enable_dns64"></a> [outpost_subnet_enable_dns64](#input_outpost_subnet_enable_dns64)

Description: Indicates whether DNS queries made to the Amazon-provided DNS Resolver in this subnet should return synthetic IPv6 addresses for IPv4-only destinations. Default: `true`

Type: `bool`

Default: `true`

### <a name="input_outpost_subnet_enable_resource_name_dns_a_record_on_launch"></a> [outpost_subnet_enable_resource_name_dns_a_record_on_launch](#input_outpost_subnet_enable_resource_name_dns_a_record_on_launch)

Description: Indicates whether to respond to DNS queries for instance hostnames with DNS A records. Default: `false`

Type: `bool`

Default: `false`

### <a name="input_outpost_subnet_enable_resource_name_dns_aaaa_record_on_launch"></a> [outpost_subnet_enable_resource_name_dns_aaaa_record_on_launch](#input_outpost_subnet_enable_resource_name_dns_aaaa_record_on_launch)

Description: Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records. Default: `true`

Type: `bool`

Default: `true`

### <a name="input_outpost_subnet_ipv6_native"></a> [outpost_subnet_ipv6_native](#input_outpost_subnet_ipv6_native)

Description: Indicates whether to create an IPv6-only subnet. Default: `false`

Type: `bool`

Default: `false`

### <a name="input_outpost_subnet_ipv6_prefixes"></a> [outpost_subnet_ipv6_prefixes](#input_outpost_subnet_ipv6_prefixes)

Description: Assigns IPv6 outpost subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list

Type: `list(string)`

Default: `[]`

### <a name="input_outpost_subnet_names"></a> [outpost_subnet_names](#input_outpost_subnet_names)

Description: Explicit values to use in the Name tag on outpost subnets. If empty, Name tags are generated

Type: `list(string)`

Default: `[]`

### <a name="input_outpost_subnet_private_dns_hostname_type_on_launch"></a> [outpost_subnet_private_dns_hostname_type_on_launch](#input_outpost_subnet_private_dns_hostname_type_on_launch)

Description: The type of hostnames to assign to instances in the subnet at launch. For IPv6-only subnets, an instance DNS name must be based on the instance ID. For dual-stack and IPv4-only subnets, you can specify whether DNS names use the instance IPv4 address or the instance ID. Valid values: `ip-name`, `resource-name`

Type: `string`

Default: `null`

### <a name="input_outpost_subnet_suffix"></a> [outpost_subnet_suffix](#input_outpost_subnet_suffix)

Description: Suffix to append to outpost subnets name

Type: `string`

Default: `"outpost"`

### <a name="input_outpost_subnet_tags"></a> [outpost_subnet_tags](#input_outpost_subnet_tags)

Description: Additional tags for the outpost subnets

Type: `map(string)`

Default: `{}`

### <a name="input_outpost_subnets"></a> [outpost_subnets](#input_outpost_subnets)

Description: A list of outpost subnets inside the VPC

Type: `list(string)`

Default: `[]`

### <a name="input_private_acl_tags"></a> [private_acl_tags](#input_private_acl_tags)

Description: Additional tags for the private subnets network ACL

Type: `map(string)`

Default: `{}`

### <a name="input_private_dedicated_network_acl"></a> [private_dedicated_network_acl](#input_private_dedicated_network_acl)

Description: Whether to use dedicated network ACL (not default) and custom rules for private subnets

Type: `bool`

Default: `false`

### <a name="input_private_inbound_acl_rules"></a> [private_inbound_acl_rules](#input_private_inbound_acl_rules)

Description: Private subnets inbound network ACLs

Type: `list(map(string))`

Default:

```json
[
  {
    "cidr_block": "0.0.0.0/0",
    "from_port": 0,
    "protocol": "-1",
    "rule_action": "allow",
    "rule_number": 100,
    "to_port": 0
  }
]
```

### <a name="input_private_outbound_acl_rules"></a> [private_outbound_acl_rules](#input_private_outbound_acl_rules)

Description: Private subnets outbound network ACLs

Type: `list(map(string))`

Default:

```json
[
  {
    "cidr_block": "0.0.0.0/0",
    "from_port": 0,
    "protocol": "-1",
    "rule_action": "allow",
    "rule_number": 100,
    "to_port": 0
  }
]
```

### <a name="input_private_route_table_tags"></a> [private_route_table_tags](#input_private_route_table_tags)

Description: Additional tags for the private route tables

Type: `map(string)`

Default: `{}`

### <a name="input_private_subnet_assign_ipv6_address_on_creation"></a> [private_subnet_assign_ipv6_address_on_creation](#input_private_subnet_assign_ipv6_address_on_creation)

Description: Specify true to indicate that network interfaces created in the specified subnet should be assigned an IPv6 address. Default is `false`

Type: `bool`

Default: `false`

### <a name="input_private_subnet_enable_dns64"></a> [private_subnet_enable_dns64](#input_private_subnet_enable_dns64)

Description: Indicates whether DNS queries made to the Amazon-provided DNS Resolver in this subnet should return synthetic IPv6 addresses for IPv4-only destinations. Default: `true`

Type: `bool`

Default: `true`

### <a name="input_private_subnet_enable_resource_name_dns_a_record_on_launch"></a> [private_subnet_enable_resource_name_dns_a_record_on_launch](#input_private_subnet_enable_resource_name_dns_a_record_on_launch)

Description: Indicates whether to respond to DNS queries for instance hostnames with DNS A records. Default: `false`

Type: `bool`

Default: `false`

### <a name="input_private_subnet_enable_resource_name_dns_aaaa_record_on_launch"></a> [private_subnet_enable_resource_name_dns_aaaa_record_on_launch](#input_private_subnet_enable_resource_name_dns_aaaa_record_on_launch)

Description: Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records. Default: `true`

Type: `bool`

Default: `true`

### <a name="input_private_subnet_ipv6_native"></a> [private_subnet_ipv6_native](#input_private_subnet_ipv6_native)

Description: Indicates whether to create an IPv6-only subnet. Default: `false`

Type: `bool`

Default: `false`

### <a name="input_private_subnet_ipv6_prefixes"></a> [private_subnet_ipv6_prefixes](#input_private_subnet_ipv6_prefixes)

Description: Assigns IPv6 private subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list

Type: `list(string)`

Default: `[]`

### <a name="input_private_subnet_names"></a> [private_subnet_names](#input_private_subnet_names)

Description: Explicit values to use in the Name tag on private subnets. If empty, Name tags are generated

Type: `list(string)`

Default: `[]`

### <a name="input_private_subnet_private_dns_hostname_type_on_launch"></a> [private_subnet_private_dns_hostname_type_on_launch](#input_private_subnet_private_dns_hostname_type_on_launch)

Description: The type of hostnames to assign to instances in the subnet at launch. For IPv6-only subnets, an instance DNS name must be based on the instance ID. For dual-stack and IPv4-only subnets, you can specify whether DNS names use the instance IPv4 address or the instance ID. Valid values: `ip-name`, `resource-name`

Type: `string`

Default: `null`

### <a name="input_private_subnet_suffix"></a> [private_subnet_suffix](#input_private_subnet_suffix)

Description: Suffix to append to private subnets name

Type: `string`

Default: `"private"`

### <a name="input_private_subnet_tags"></a> [private_subnet_tags](#input_private_subnet_tags)

Description: Additional tags for the private subnets

Type: `map(string)`

Default: `{}`

### <a name="input_private_subnet_tags_per_az"></a> [private_subnet_tags_per_az](#input_private_subnet_tags_per_az)

Description: Additional tags for the private subnets where the primary key is the AZ

Type: `map(map(string))`

Default: `{}`

### <a name="input_private_subnets"></a> [private_subnets](#input_private_subnets)

Description: A list of private subnets inside the VPC

Type: `list(string)`

Default: `[]`

### <a name="input_propagate_intra_route_tables_vgw"></a> [propagate_intra_route_tables_vgw](#input_propagate_intra_route_tables_vgw)

Description: Should be true if you want route table propagation

Type: `bool`

Default: `false`

### <a name="input_propagate_private_route_tables_vgw"></a> [propagate_private_route_tables_vgw](#input_propagate_private_route_tables_vgw)

Description: Should be true if you want route table propagation

Type: `bool`

Default: `false`

### <a name="input_propagate_public_route_tables_vgw"></a> [propagate_public_route_tables_vgw](#input_propagate_public_route_tables_vgw)

Description: Should be true if you want route table propagation

Type: `bool`

Default: `false`

### <a name="input_public_acl_tags"></a> [public_acl_tags](#input_public_acl_tags)

Description: Additional tags for the public subnets network ACL

Type: `map(string)`

Default: `{}`

### <a name="input_public_dedicated_network_acl"></a> [public_dedicated_network_acl](#input_public_dedicated_network_acl)

Description: Whether to use dedicated network ACL (not default) and custom rules for public subnets

Type: `bool`

Default: `false`

### <a name="input_public_inbound_acl_rules"></a> [public_inbound_acl_rules](#input_public_inbound_acl_rules)

Description: Public subnets inbound network ACLs

Type: `list(map(string))`

Default:

```json
[
  {
    "cidr_block": "0.0.0.0/0",
    "from_port": 0,
    "protocol": "-1",
    "rule_action": "allow",
    "rule_number": 100,
    "to_port": 0
  }
]
```

### <a name="input_public_outbound_acl_rules"></a> [public_outbound_acl_rules](#input_public_outbound_acl_rules)

Description: Public subnets outbound network ACLs

Type: `list(map(string))`

Default:

```json
[
  {
    "cidr_block": "0.0.0.0/0",
    "from_port": 0,
    "protocol": "-1",
    "rule_action": "allow",
    "rule_number": 100,
    "to_port": 0
  }
]
```

### <a name="input_public_route_table_tags"></a> [public_route_table_tags](#input_public_route_table_tags)

Description: Additional tags for the public route tables

Type: `map(string)`

Default: `{}`

### <a name="input_public_subnet_assign_ipv6_address_on_creation"></a> [public_subnet_assign_ipv6_address_on_creation](#input_public_subnet_assign_ipv6_address_on_creation)

Description: Specify true to indicate that network interfaces created in the specified subnet should be assigned an IPv6 address. Default is `false`

Type: `bool`

Default: `false`

### <a name="input_public_subnet_enable_dns64"></a> [public_subnet_enable_dns64](#input_public_subnet_enable_dns64)

Description: Indicates whether DNS queries made to the Amazon-provided DNS Resolver in this subnet should return synthetic IPv6 addresses for IPv4-only destinations. Default: `true`

Type: `bool`

Default: `true`

### <a name="input_public_subnet_enable_resource_name_dns_a_record_on_launch"></a> [public_subnet_enable_resource_name_dns_a_record_on_launch](#input_public_subnet_enable_resource_name_dns_a_record_on_launch)

Description: Indicates whether to respond to DNS queries for instance hostnames with DNS A records. Default: `false`

Type: `bool`

Default: `false`

### <a name="input_public_subnet_enable_resource_name_dns_aaaa_record_on_launch"></a> [public_subnet_enable_resource_name_dns_aaaa_record_on_launch](#input_public_subnet_enable_resource_name_dns_aaaa_record_on_launch)

Description: Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records. Default: `true`

Type: `bool`

Default: `true`

### <a name="input_public_subnet_ipv6_native"></a> [public_subnet_ipv6_native](#input_public_subnet_ipv6_native)

Description: Indicates whether to create an IPv6-only subnet. Default: `false`

Type: `bool`

Default: `false`

### <a name="input_public_subnet_ipv6_prefixes"></a> [public_subnet_ipv6_prefixes](#input_public_subnet_ipv6_prefixes)

Description: Assigns IPv6 public subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list

Type: `list(string)`

Default: `[]`

### <a name="input_public_subnet_names"></a> [public_subnet_names](#input_public_subnet_names)

Description: Explicit values to use in the Name tag on public subnets. If empty, Name tags are generated

Type: `list(string)`

Default: `[]`

### <a name="input_public_subnet_private_dns_hostname_type_on_launch"></a> [public_subnet_private_dns_hostname_type_on_launch](#input_public_subnet_private_dns_hostname_type_on_launch)

Description: The type of hostnames to assign to instances in the subnet at launch. For IPv6-only subnets, an instance DNS name must be based on the instance ID. For dual-stack and IPv4-only subnets, you can specify whether DNS names use the instance IPv4 address or the instance ID. Valid values: `ip-name`, `resource-name`

Type: `string`

Default: `null`

### <a name="input_public_subnet_suffix"></a> [public_subnet_suffix](#input_public_subnet_suffix)

Description: Suffix to append to public subnets name

Type: `string`

Default: `"public"`

### <a name="input_public_subnet_tags"></a> [public_subnet_tags](#input_public_subnet_tags)

Description: Additional tags for the public subnets

Type: `map(string)`

Default: `{}`

### <a name="input_public_subnet_tags_per_az"></a> [public_subnet_tags_per_az](#input_public_subnet_tags_per_az)

Description: Additional tags for the public subnets where the primary key is the AZ

Type: `map(map(string))`

Default: `{}`

### <a name="input_public_subnets"></a> [public_subnets](#input_public_subnets)

Description: A list of public subnets inside the VPC

Type: `list(string)`

Default: `[]`

### <a name="input_putin_khuylo"></a> [putin_khuylo](#input_putin_khuylo)

Description: Do you agree that Putin doesn't respect Ukrainian sovereignty and territorial integrity? More info: https://en.wikipedia.org/wiki/Putin_khuylo!

Type: `bool`

Default: `true`

### <a name="input_redshift_acl_tags"></a> [redshift_acl_tags](#input_redshift_acl_tags)

Description: Additional tags for the redshift subnets network ACL

Type: `map(string)`

Default: `{}`

### <a name="input_redshift_dedicated_network_acl"></a> [redshift_dedicated_network_acl](#input_redshift_dedicated_network_acl)

Description: Whether to use dedicated network ACL (not default) and custom rules for redshift subnets

Type: `bool`

Default: `false`

### <a name="input_redshift_inbound_acl_rules"></a> [redshift_inbound_acl_rules](#input_redshift_inbound_acl_rules)

Description: Redshift subnets inbound network ACL rules

Type: `list(map(string))`

Default:

```json
[
  {
    "cidr_block": "0.0.0.0/0",
    "from_port": 0,
    "protocol": "-1",
    "rule_action": "allow",
    "rule_number": 100,
    "to_port": 0
  }
]
```

### <a name="input_redshift_outbound_acl_rules"></a> [redshift_outbound_acl_rules](#input_redshift_outbound_acl_rules)

Description: Redshift subnets outbound network ACL rules

Type: `list(map(string))`

Default:

```json
[
  {
    "cidr_block": "0.0.0.0/0",
    "from_port": 0,
    "protocol": "-1",
    "rule_action": "allow",
    "rule_number": 100,
    "to_port": 0
  }
]
```

### <a name="input_redshift_route_table_tags"></a> [redshift_route_table_tags](#input_redshift_route_table_tags)

Description: Additional tags for the redshift route tables

Type: `map(string)`

Default: `{}`

### <a name="input_redshift_subnet_assign_ipv6_address_on_creation"></a> [redshift_subnet_assign_ipv6_address_on_creation](#input_redshift_subnet_assign_ipv6_address_on_creation)

Description: Specify true to indicate that network interfaces created in the specified subnet should be assigned an IPv6 address. Default is `false`

Type: `bool`

Default: `false`

### <a name="input_redshift_subnet_enable_dns64"></a> [redshift_subnet_enable_dns64](#input_redshift_subnet_enable_dns64)

Description: Indicates whether DNS queries made to the Amazon-provided DNS Resolver in this subnet should return synthetic IPv6 addresses for IPv4-only destinations. Default: `true`

Type: `bool`

Default: `true`

### <a name="input_redshift_subnet_enable_resource_name_dns_a_record_on_launch"></a> [redshift_subnet_enable_resource_name_dns_a_record_on_launch](#input_redshift_subnet_enable_resource_name_dns_a_record_on_launch)

Description: Indicates whether to respond to DNS queries for instance hostnames with DNS A records. Default: `false`

Type: `bool`

Default: `false`

### <a name="input_redshift_subnet_enable_resource_name_dns_aaaa_record_on_launch"></a> [redshift_subnet_enable_resource_name_dns_aaaa_record_on_launch](#input_redshift_subnet_enable_resource_name_dns_aaaa_record_on_launch)

Description: Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records. Default: `true`

Type: `bool`

Default: `true`

### <a name="input_redshift_subnet_group_name"></a> [redshift_subnet_group_name](#input_redshift_subnet_group_name)

Description: Name of redshift subnet group

Type: `string`

Default: `null`

### <a name="input_redshift_subnet_group_tags"></a> [redshift_subnet_group_tags](#input_redshift_subnet_group_tags)

Description: Additional tags for the redshift subnet group

Type: `map(string)`

Default: `{}`

### <a name="input_redshift_subnet_ipv6_native"></a> [redshift_subnet_ipv6_native](#input_redshift_subnet_ipv6_native)

Description: Indicates whether to create an IPv6-only subnet. Default: `false`

Type: `bool`

Default: `false`

### <a name="input_redshift_subnet_ipv6_prefixes"></a> [redshift_subnet_ipv6_prefixes](#input_redshift_subnet_ipv6_prefixes)

Description: Assigns IPv6 redshift subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list

Type: `list(string)`

Default: `[]`

### <a name="input_redshift_subnet_names"></a> [redshift_subnet_names](#input_redshift_subnet_names)

Description: Explicit values to use in the Name tag on redshift subnets. If empty, Name tags are generated

Type: `list(string)`

Default: `[]`

### <a name="input_redshift_subnet_private_dns_hostname_type_on_launch"></a> [redshift_subnet_private_dns_hostname_type_on_launch](#input_redshift_subnet_private_dns_hostname_type_on_launch)

Description: The type of hostnames to assign to instances in the subnet at launch. For IPv6-only subnets, an instance DNS name must be based on the instance ID. For dual-stack and IPv4-only subnets, you can specify whether DNS names use the instance IPv4 address or the instance ID. Valid values: `ip-name`, `resource-name`

Type: `string`

Default: `null`

### <a name="input_redshift_subnet_suffix"></a> [redshift_subnet_suffix](#input_redshift_subnet_suffix)

Description: Suffix to append to redshift subnets name

Type: `string`

Default: `"redshift"`

### <a name="input_redshift_subnet_tags"></a> [redshift_subnet_tags](#input_redshift_subnet_tags)

Description: Additional tags for the redshift subnets

Type: `map(string)`

Default: `{}`

### <a name="input_redshift_subnets"></a> [redshift_subnets](#input_redshift_subnets)

Description: A list of redshift subnets inside the VPC

Type: `list(string)`

Default: `[]`

### <a name="input_reuse_nat_ips"></a> [reuse_nat_ips](#input_reuse_nat_ips)

Description: Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_ids' variable

Type: `bool`

Default: `false`

### <a name="input_secondary_cidr_blocks"></a> [secondary_cidr_blocks](#input_secondary_cidr_blocks)

Description: List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool

Type: `list(string)`

Default: `[]`

### <a name="input_single_nat_gateway"></a> [single_nat_gateway](#input_single_nat_gateway)

Description: Should be true if you want to provision a single shared NAT Gateway across all of your private networks

Type: `bool`

Default: `false`

### <a name="input_tags"></a> [tags](#input_tags)

Description: A map of tags to add to all resources

Type: `map(string)`

Default: `{}`

### <a name="input_use_ipam_pool"></a> [use_ipam_pool](#input_use_ipam_pool)

Description: Determines whether IPAM pool is used for CIDR allocation

Type: `bool`

Default: `false`

### <a name="input_vpc_flow_log_permissions_boundary"></a> [vpc_flow_log_permissions_boundary](#input_vpc_flow_log_permissions_boundary)

Description: The ARN of the Permissions Boundary for the VPC Flow Log IAM Role

Type: `string`

Default: `null`

### <a name="input_vpc_flow_log_tags"></a> [vpc_flow_log_tags](#input_vpc_flow_log_tags)

Description: Additional tags for the VPC Flow Logs

Type: `map(string)`

Default: `{}`

### <a name="input_vpc_tags"></a> [vpc_tags](#input_vpc_tags)

Description: Additional tags for the VPC

Type: `map(string)`

Default: `{}`

### <a name="input_vpn_gateway_az"></a> [vpn_gateway_az](#input_vpn_gateway_az)

Description: The Availability Zone for the VPN Gateway

Type: `string`

Default: `null`

### <a name="input_vpn_gateway_id"></a> [vpn_gateway_id](#input_vpn_gateway_id)

Description: ID of VPN Gateway to attach to the VPC

Type: `string`

Default: `""`

### <a name="input_vpn_gateway_tags"></a> [vpn_gateway_tags](#input_vpn_gateway_tags)

Description: Additional tags for the VPN gateway

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_azs"></a> [azs](#output_azs)

Description: A list of availability zones specified as argument to this module

### <a name="output_cgw_arns"></a> [cgw_arns](#output_cgw_arns)

Description: List of ARNs of Customer Gateway

### <a name="output_cgw_ids"></a> [cgw_ids](#output_cgw_ids)

Description: List of IDs of Customer Gateway

### <a name="output_database_internet_gateway_route_id"></a> [database_internet_gateway_route_id](#output_database_internet_gateway_route_id)

Description: ID of the database internet gateway route

### <a name="output_database_ipv6_egress_route_id"></a> [database_ipv6_egress_route_id](#output_database_ipv6_egress_route_id)

Description: ID of the database IPv6 egress route

### <a name="output_database_nat_gateway_route_ids"></a> [database_nat_gateway_route_ids](#output_database_nat_gateway_route_ids)

Description: List of IDs of the database nat gateway route

### <a name="output_database_network_acl_arn"></a> [database_network_acl_arn](#output_database_network_acl_arn)

Description: ARN of the database network ACL

### <a name="output_database_network_acl_id"></a> [database_network_acl_id](#output_database_network_acl_id)

Description: ID of the database network ACL

### <a name="output_database_route_table_association_ids"></a> [database_route_table_association_ids](#output_database_route_table_association_ids)

Description: List of IDs of the database route table association

### <a name="output_database_route_table_ids"></a> [database_route_table_ids](#output_database_route_table_ids)

Description: List of IDs of database route tables

### <a name="output_database_subnet_arns"></a> [database_subnet_arns](#output_database_subnet_arns)

Description: List of ARNs of database subnets

### <a name="output_database_subnet_group"></a> [database_subnet_group](#output_database_subnet_group)

Description: ID of database subnet group

### <a name="output_database_subnet_group_name"></a> [database_subnet_group_name](#output_database_subnet_group_name)

Description: Name of database subnet group

### <a name="output_database_subnets"></a> [database_subnets](#output_database_subnets)

Description: List of IDs of database subnets

### <a name="output_database_subnets_cidr_blocks"></a> [database_subnets_cidr_blocks](#output_database_subnets_cidr_blocks)

Description: List of cidr_blocks of database subnets

### <a name="output_database_subnets_ipv6_cidr_blocks"></a> [database_subnets_ipv6_cidr_blocks](#output_database_subnets_ipv6_cidr_blocks)

Description: List of IPv6 cidr_blocks of database subnets in an IPv6 enabled VPC

### <a name="output_default_network_acl_id"></a> [default_network_acl_id](#output_default_network_acl_id)

Description: The ID of the default network ACL

### <a name="output_default_route_table_id"></a> [default_route_table_id](#output_default_route_table_id)

Description: The ID of the default route table

### <a name="output_default_security_group_id"></a> [default_security_group_id](#output_default_security_group_id)

Description: The ID of the security group created by default on VPC creation

### <a name="output_default_vpc_arn"></a> [default_vpc_arn](#output_default_vpc_arn)

Description: The ARN of the Default VPC

### <a name="output_default_vpc_cidr_block"></a> [default_vpc_cidr_block](#output_default_vpc_cidr_block)

Description: The CIDR block of the Default VPC

### <a name="output_default_vpc_default_network_acl_id"></a> [default_vpc_default_network_acl_id](#output_default_vpc_default_network_acl_id)

Description: The ID of the default network ACL of the Default VPC

### <a name="output_default_vpc_default_route_table_id"></a> [default_vpc_default_route_table_id](#output_default_vpc_default_route_table_id)

Description: The ID of the default route table of the Default VPC

### <a name="output_default_vpc_default_security_group_id"></a> [default_vpc_default_security_group_id](#output_default_vpc_default_security_group_id)

Description: The ID of the security group created by default on Default VPC creation

### <a name="output_default_vpc_enable_dns_hostnames"></a> [default_vpc_enable_dns_hostnames](#output_default_vpc_enable_dns_hostnames)

Description: Whether or not the Default VPC has DNS hostname support

### <a name="output_default_vpc_enable_dns_support"></a> [default_vpc_enable_dns_support](#output_default_vpc_enable_dns_support)

Description: Whether or not the Default VPC has DNS support

### <a name="output_default_vpc_id"></a> [default_vpc_id](#output_default_vpc_id)

Description: The ID of the Default VPC

### <a name="output_default_vpc_instance_tenancy"></a> [default_vpc_instance_tenancy](#output_default_vpc_instance_tenancy)

Description: Tenancy of instances spin up within Default VPC

### <a name="output_default_vpc_main_route_table_id"></a> [default_vpc_main_route_table_id](#output_default_vpc_main_route_table_id)

Description: The ID of the main route table associated with the Default VPC

### <a name="output_dhcp_options_id"></a> [dhcp_options_id](#output_dhcp_options_id)

Description: The ID of the DHCP options

### <a name="output_egress_only_internet_gateway_id"></a> [egress_only_internet_gateway_id](#output_egress_only_internet_gateway_id)

Description: The ID of the egress only Internet Gateway

### <a name="output_elasticache_network_acl_arn"></a> [elasticache_network_acl_arn](#output_elasticache_network_acl_arn)

Description: ARN of the elasticache network ACL

### <a name="output_elasticache_network_acl_id"></a> [elasticache_network_acl_id](#output_elasticache_network_acl_id)

Description: ID of the elasticache network ACL

### <a name="output_elasticache_route_table_association_ids"></a> [elasticache_route_table_association_ids](#output_elasticache_route_table_association_ids)

Description: List of IDs of the elasticache route table association

### <a name="output_elasticache_route_table_ids"></a> [elasticache_route_table_ids](#output_elasticache_route_table_ids)

Description: List of IDs of elasticache route tables

### <a name="output_elasticache_subnet_arns"></a> [elasticache_subnet_arns](#output_elasticache_subnet_arns)

Description: List of ARNs of elasticache subnets

### <a name="output_elasticache_subnet_group"></a> [elasticache_subnet_group](#output_elasticache_subnet_group)

Description: ID of elasticache subnet group

### <a name="output_elasticache_subnet_group_name"></a> [elasticache_subnet_group_name](#output_elasticache_subnet_group_name)

Description: Name of elasticache subnet group

### <a name="output_elasticache_subnets"></a> [elasticache_subnets](#output_elasticache_subnets)

Description: List of IDs of elasticache subnets

### <a name="output_elasticache_subnets_cidr_blocks"></a> [elasticache_subnets_cidr_blocks](#output_elasticache_subnets_cidr_blocks)

Description: List of cidr_blocks of elasticache subnets

### <a name="output_elasticache_subnets_ipv6_cidr_blocks"></a> [elasticache_subnets_ipv6_cidr_blocks](#output_elasticache_subnets_ipv6_cidr_blocks)

Description: List of IPv6 cidr_blocks of elasticache subnets in an IPv6 enabled VPC

### <a name="output_igw_arn"></a> [igw_arn](#output_igw_arn)

Description: The ARN of the Internet Gateway

### <a name="output_igw_id"></a> [igw_id](#output_igw_id)

Description: The ID of the Internet Gateway

### <a name="output_intra_network_acl_arn"></a> [intra_network_acl_arn](#output_intra_network_acl_arn)

Description: ARN of the intra network ACL

### <a name="output_intra_network_acl_id"></a> [intra_network_acl_id](#output_intra_network_acl_id)

Description: ID of the intra network ACL

### <a name="output_intra_route_table_association_ids"></a> [intra_route_table_association_ids](#output_intra_route_table_association_ids)

Description: List of IDs of the intra route table association

### <a name="output_intra_route_table_ids"></a> [intra_route_table_ids](#output_intra_route_table_ids)

Description: List of IDs of intra route tables

### <a name="output_intra_subnet_arns"></a> [intra_subnet_arns](#output_intra_subnet_arns)

Description: List of ARNs of intra subnets

### <a name="output_intra_subnets"></a> [intra_subnets](#output_intra_subnets)

Description: List of IDs of intra subnets

### <a name="output_intra_subnets_cidr_blocks"></a> [intra_subnets_cidr_blocks](#output_intra_subnets_cidr_blocks)

Description: List of cidr_blocks of intra subnets

### <a name="output_intra_subnets_ipv6_cidr_blocks"></a> [intra_subnets_ipv6_cidr_blocks](#output_intra_subnets_ipv6_cidr_blocks)

Description: List of IPv6 cidr_blocks of intra subnets in an IPv6 enabled VPC

### <a name="output_name"></a> [name](#output_name)

Description: The name of the VPC specified as argument to this module

### <a name="output_nat_ids"></a> [nat_ids](#output_nat_ids)

Description: List of allocation ID of Elastic IPs created for AWS NAT Gateway

### <a name="output_nat_public_ips"></a> [nat_public_ips](#output_nat_public_ips)

Description: List of public Elastic IPs created for AWS NAT Gateway

### <a name="output_natgw_ids"></a> [natgw_ids](#output_natgw_ids)

Description: List of NAT Gateway IDs

### <a name="output_outpost_network_acl_arn"></a> [outpost_network_acl_arn](#output_outpost_network_acl_arn)

Description: ARN of the outpost network ACL

### <a name="output_outpost_network_acl_id"></a> [outpost_network_acl_id](#output_outpost_network_acl_id)

Description: ID of the outpost network ACL

### <a name="output_outpost_subnet_arns"></a> [outpost_subnet_arns](#output_outpost_subnet_arns)

Description: List of ARNs of outpost subnets

### <a name="output_outpost_subnets"></a> [outpost_subnets](#output_outpost_subnets)

Description: List of IDs of outpost subnets

### <a name="output_outpost_subnets_cidr_blocks"></a> [outpost_subnets_cidr_blocks](#output_outpost_subnets_cidr_blocks)

Description: List of cidr_blocks of outpost subnets

### <a name="output_outpost_subnets_ipv6_cidr_blocks"></a> [outpost_subnets_ipv6_cidr_blocks](#output_outpost_subnets_ipv6_cidr_blocks)

Description: List of IPv6 cidr_blocks of outpost subnets in an IPv6 enabled VPC

### <a name="output_private_ipv6_egress_route_ids"></a> [private_ipv6_egress_route_ids](#output_private_ipv6_egress_route_ids)

Description: List of IDs of the ipv6 egress route

### <a name="output_private_nat_gateway_route_ids"></a> [private_nat_gateway_route_ids](#output_private_nat_gateway_route_ids)

Description: List of IDs of the private nat gateway route

### <a name="output_private_network_acl_arn"></a> [private_network_acl_arn](#output_private_network_acl_arn)

Description: ARN of the private network ACL

### <a name="output_private_network_acl_id"></a> [private_network_acl_id](#output_private_network_acl_id)

Description: ID of the private network ACL

### <a name="output_private_route_table_association_ids"></a> [private_route_table_association_ids](#output_private_route_table_association_ids)

Description: List of IDs of the private route table association

### <a name="output_private_route_table_ids"></a> [private_route_table_ids](#output_private_route_table_ids)

Description: List of IDs of private route tables

### <a name="output_private_subnet_arns"></a> [private_subnet_arns](#output_private_subnet_arns)

Description: List of ARNs of private subnets

### <a name="output_private_subnets"></a> [private_subnets](#output_private_subnets)

Description: List of IDs of private subnets

### <a name="output_private_subnets_cidr_blocks"></a> [private_subnets_cidr_blocks](#output_private_subnets_cidr_blocks)

Description: List of cidr_blocks of private subnets

### <a name="output_private_subnets_ipv6_cidr_blocks"></a> [private_subnets_ipv6_cidr_blocks](#output_private_subnets_ipv6_cidr_blocks)

Description: List of IPv6 cidr_blocks of private subnets in an IPv6 enabled VPC

### <a name="output_public_internet_gateway_ipv6_route_id"></a> [public_internet_gateway_ipv6_route_id](#output_public_internet_gateway_ipv6_route_id)

Description: ID of the IPv6 internet gateway route

### <a name="output_public_internet_gateway_route_id"></a> [public_internet_gateway_route_id](#output_public_internet_gateway_route_id)

Description: ID of the internet gateway route

### <a name="output_public_network_acl_arn"></a> [public_network_acl_arn](#output_public_network_acl_arn)

Description: ARN of the public network ACL

### <a name="output_public_network_acl_id"></a> [public_network_acl_id](#output_public_network_acl_id)

Description: ID of the public network ACL

### <a name="output_public_route_table_association_ids"></a> [public_route_table_association_ids](#output_public_route_table_association_ids)

Description: List of IDs of the public route table association

### <a name="output_public_route_table_ids"></a> [public_route_table_ids](#output_public_route_table_ids)

Description: List of IDs of public route tables

### <a name="output_public_subnet_arns"></a> [public_subnet_arns](#output_public_subnet_arns)

Description: List of ARNs of public subnets

### <a name="output_public_subnets"></a> [public_subnets](#output_public_subnets)

Description: List of IDs of public subnets

### <a name="output_public_subnets_cidr_blocks"></a> [public_subnets_cidr_blocks](#output_public_subnets_cidr_blocks)

Description: List of cidr_blocks of public subnets

### <a name="output_public_subnets_ipv6_cidr_blocks"></a> [public_subnets_ipv6_cidr_blocks](#output_public_subnets_ipv6_cidr_blocks)

Description: List of IPv6 cidr_blocks of public subnets in an IPv6 enabled VPC

### <a name="output_redshift_network_acl_arn"></a> [redshift_network_acl_arn](#output_redshift_network_acl_arn)

Description: ARN of the redshift network ACL

### <a name="output_redshift_network_acl_id"></a> [redshift_network_acl_id](#output_redshift_network_acl_id)

Description: ID of the redshift network ACL

### <a name="output_redshift_public_route_table_association_ids"></a> [redshift_public_route_table_association_ids](#output_redshift_public_route_table_association_ids)

Description: List of IDs of the public redshift route table association

### <a name="output_redshift_route_table_association_ids"></a> [redshift_route_table_association_ids](#output_redshift_route_table_association_ids)

Description: List of IDs of the redshift route table association

### <a name="output_redshift_route_table_ids"></a> [redshift_route_table_ids](#output_redshift_route_table_ids)

Description: List of IDs of redshift route tables

### <a name="output_redshift_subnet_arns"></a> [redshift_subnet_arns](#output_redshift_subnet_arns)

Description: List of ARNs of redshift subnets

### <a name="output_redshift_subnet_group"></a> [redshift_subnet_group](#output_redshift_subnet_group)

Description: ID of redshift subnet group

### <a name="output_redshift_subnets"></a> [redshift_subnets](#output_redshift_subnets)

Description: List of IDs of redshift subnets

### <a name="output_redshift_subnets_cidr_blocks"></a> [redshift_subnets_cidr_blocks](#output_redshift_subnets_cidr_blocks)

Description: List of cidr_blocks of redshift subnets

### <a name="output_redshift_subnets_ipv6_cidr_blocks"></a> [redshift_subnets_ipv6_cidr_blocks](#output_redshift_subnets_ipv6_cidr_blocks)

Description: List of IPv6 cidr_blocks of redshift subnets in an IPv6 enabled VPC

### <a name="output_this_customer_gateway"></a> [this_customer_gateway](#output_this_customer_gateway)

Description: Map of Customer Gateway attributes

### <a name="output_vgw_arn"></a> [vgw_arn](#output_vgw_arn)

Description: The ARN of the VPN Gateway

### <a name="output_vgw_id"></a> [vgw_id](#output_vgw_id)

Description: The ID of the VPN Gateway

### <a name="output_vpc_arn"></a> [vpc_arn](#output_vpc_arn)

Description: The ARN of the VPC

### <a name="output_vpc_cidr_block"></a> [vpc_cidr_block](#output_vpc_cidr_block)

Description: The CIDR block of the VPC

### <a name="output_vpc_enable_dns_hostnames"></a> [vpc_enable_dns_hostnames](#output_vpc_enable_dns_hostnames)

Description: Whether or not the VPC has DNS hostname support

### <a name="output_vpc_enable_dns_support"></a> [vpc_enable_dns_support](#output_vpc_enable_dns_support)

Description: Whether or not the VPC has DNS support

### <a name="output_vpc_flow_log_cloudwatch_iam_role_arn"></a> [vpc_flow_log_cloudwatch_iam_role_arn](#output_vpc_flow_log_cloudwatch_iam_role_arn)

Description: The ARN of the IAM role used when pushing logs to Cloudwatch log group

### <a name="output_vpc_flow_log_destination_arn"></a> [vpc_flow_log_destination_arn](#output_vpc_flow_log_destination_arn)

Description: The ARN of the destination for VPC Flow Logs

### <a name="output_vpc_flow_log_destination_type"></a> [vpc_flow_log_destination_type](#output_vpc_flow_log_destination_type)

Description: The type of the destination for VPC Flow Logs

### <a name="output_vpc_flow_log_id"></a> [vpc_flow_log_id](#output_vpc_flow_log_id)

Description: The ID of the Flow Log resource

### <a name="output_vpc_id"></a> [vpc_id](#output_vpc_id)

Description: The ID of the VPC

### <a name="output_vpc_instance_tenancy"></a> [vpc_instance_tenancy](#output_vpc_instance_tenancy)

Description: Tenancy of instances spin up within VPC

### <a name="output_vpc_ipv6_association_id"></a> [vpc_ipv6_association_id](#output_vpc_ipv6_association_id)

Description: The association ID for the IPv6 CIDR block

### <a name="output_vpc_ipv6_cidr_block"></a> [vpc_ipv6_cidr_block](#output_vpc_ipv6_cidr_block)

Description: The IPv6 CIDR block

### <a name="output_vpc_main_route_table_id"></a> [vpc_main_route_table_id](#output_vpc_main_route_table_id)

Description: The ID of the main route table associated with this VPC

### <a name="output_vpc_owner_id"></a> [vpc_owner_id](#output_vpc_owner_id)

Description: The ID of the AWS account that owns the VPC

### <a name="output_vpc_secondary_cidr_blocks"></a> [vpc_secondary_cidr_blocks](#output_vpc_secondary_cidr_blocks)

Description: List of secondary CIDR blocks of the VPC
