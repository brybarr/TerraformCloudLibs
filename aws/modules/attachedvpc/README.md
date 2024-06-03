## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider_aws)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aws_cloudwatch_log_group.attachedvpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) (resource)
- [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) (resource)
- [aws_ec2_transit_gateway_vpc_attachment.interconnect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) (resource)
- [aws_flow_log.attachedvpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) (resource)
- [aws_iam_role.attachedvpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)
- [aws_iam_role_policy.attachedvpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) (resource)
- [aws_nat_gateway.attachedvpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) (resource)
- [aws_network_acl.nonroutable](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) (resource)
- [aws_network_acl.routable](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) (resource)
- [aws_network_acl_rule.nonroutable_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) (resource)
- [aws_network_acl_rule.nonroutable_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) (resource)
- [aws_network_acl_rule.routable_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) (resource)
- [aws_network_acl_rule.routable_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) (resource)
- [aws_route.nonroutable_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) (resource)
- [aws_route.routable_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) (resource)
- [aws_route_table.nonroutable](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) (resource)
- [aws_route_table.routable](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) (resource)
- [aws_route_table_association.nonroutable](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) (resource)
- [aws_route_table_association.routable](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) (resource)
- [aws_subnet.nonroutable](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) (resource)
- [aws_subnet.routable](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) (resource)
- [aws_vpc.attachedvpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) (resource)
- [aws_vpc_dhcp_options.attachedvpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options) (resource)
- [aws_vpc_dhcp_options_association.attachedvpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association) (resource)
- [aws_vpc_endpoint.attachedvpc_interface](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) (resource)
- [aws_vpc_endpoint.gateway_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) (resource)
- [aws_vpc_endpoint_route_table_association.attachedvpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) (resource)
- [aws_vpc_ipv4_cidr_block_association.secondary_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipv4_cidr_block_association) (resource)
- [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) (data source)
- [aws_ec2_transit_gateway.interconnect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_transit_gateway) (data source)
- [aws_iam_policy_document.attachedvpc_interface](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
- [aws_iam_policy_document.flowlogs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
- [aws_iam_policy_document.s3_gateway_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
- [aws_iam_policy_document.vpcflowlogs_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_aws_account_id"></a> [aws_account_id](#input_aws_account_id)

Description: n/a

Type: `string`

### <a name="input_aws_region"></a> [aws_region](#input_aws_region)

Description: n/a

Type: `string`

### <a name="input_cloudwatch_flowlog_retention_days"></a> [cloudwatch_flowlog_retention_days](#input_cloudwatch_flowlog_retention_days)

Description: n/a

Type: `number`

### <a name="input_collection_identifier"></a> [collection_identifier](#input_collection_identifier)

Description: n/a

Type: `string`

### <a name="input_default_tags"></a> [default_tags](#input_default_tags)

Description: n/a

Type: `map(any)`

### <a name="input_deploy_role_name"></a> [deploy_role_name](#input_deploy_role_name)

Description: n/a

Type: `string`

### <a name="input_environment"></a> [environment](#input_environment)

Description: n/a

Type: `string`

### <a name="input_interconnect_tgw_id"></a> [interconnect_tgw_id](#input_interconnect_tgw_id)

Description: n/a

Type: `string`

### <a name="input_kms_key_arn"></a> [kms_key_arn](#input_kms_key_arn)

Description: n/a

Type: `string`

### <a name="input_nonroutable_inbound_acl_rules"></a> [nonroutable_inbound_acl_rules](#input_nonroutable_inbound_acl_rules)

Description: n/a

Type: `list(map(string))`

### <a name="input_nonroutable_outbound_acl_rules"></a> [nonroutable_outbound_acl_rules](#input_nonroutable_outbound_acl_rules)

Description: n/a

Type: `list(map(string))`

### <a name="input_routable_inbound_acl_rules"></a> [routable_inbound_acl_rules](#input_routable_inbound_acl_rules)

Description: n/a

Type: `list(map(string))`

### <a name="input_routable_outbound_acl_rules"></a> [routable_outbound_acl_rules](#input_routable_outbound_acl_rules)

Description: n/a

Type: `list(map(string))`

### <a name="input_vpc_nonroutable_mask"></a> [vpc_nonroutable_mask](#input_vpc_nonroutable_mask)

Description: n/a

Type: `number`

### <a name="input_vpc_nonroutable_octet1"></a> [vpc_nonroutable_octet1](#input_vpc_nonroutable_octet1)

Description: n/a

Type: `number`

### <a name="input_vpc_nonroutable_octet2"></a> [vpc_nonroutable_octet2](#input_vpc_nonroutable_octet2)

Description: n/a

Type: `number`

### <a name="input_vpc_nonroutable_octet3"></a> [vpc_nonroutable_octet3](#input_vpc_nonroutable_octet3)

Description: n/a

Type: `number`

### <a name="input_vpc_nonroutable_octet4"></a> [vpc_nonroutable_octet4](#input_vpc_nonroutable_octet4)

Description: n/a

Type: `number`

### <a name="input_vpc_routable_mask"></a> [vpc_routable_mask](#input_vpc_routable_mask)

Description: n/a

Type: `number`

### <a name="input_vpc_routable_octet1"></a> [vpc_routable_octet1](#input_vpc_routable_octet1)

Description: n/a

Type: `number`

### <a name="input_vpc_routable_octet2"></a> [vpc_routable_octet2](#input_vpc_routable_octet2)

Description: n/a

Type: `number`

### <a name="input_vpc_routable_octet3"></a> [vpc_routable_octet3](#input_vpc_routable_octet3)

Description: n/a

Type: `number`

### <a name="input_vpc_routable_octet4"></a> [vpc_routable_octet4](#input_vpc_routable_octet4)

Description: n/a

Type: `number`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_domain_name"></a> [domain_name](#input_domain_name)

Description: n/a

Type: `string`

Default: `"services.local"`

### <a name="input_domain_name_servers"></a> [domain_name_servers](#input_domain_name_servers)

Description: n/a

Type: `list(string)`

Default:

```json
[
  "10.171.32.21",
  "10.171.36.21"
]
```

### <a name="input_name"></a> [name](#input_name)

Description: Name to be used on all the resources as identifier

Type: `string`

Default: `"edp-attachedvpc"`

### <a name="input_netbios_name_servers"></a> [netbios_name_servers](#input_netbios_name_servers)

Description: n/a

Type: `list(string)`

Default:

```json
[
  "10.171.32.21",
  "10.171.36.21"
]
```

### <a name="input_netbios_node_type"></a> [netbios_node_type](#input_netbios_node_type)

Description: n/a

Type: `string`

Default: `"2"`

### <a name="input_nonroutable_subnet_suffix"></a> [nonroutable_subnet_suffix](#input_nonroutable_subnet_suffix)

Description: n/a

Type: `string`

Default: `"Non-routable"`

### <a name="input_ntp_servers"></a> [ntp_servers](#input_ntp_servers)

Description: n/a

Type: `list(string)`

Default:

```json
[
  "10.237.196.100",
  "10.245.196.100"
]
```

### <a name="input_org_id"></a> [org_id](#input_org_id)

Description: n/a

Type: `string`

Default: `"o-7w23f0chfl"`

### <a name="input_routable_subnet_suffix"></a> [routable_subnet_suffix](#input_routable_subnet_suffix)

Description: n/a

Type: `string`

Default: `"Routable"`

## Outputs

The following outputs are exported:

### <a name="output_nonroutable_route_table_ids"></a> [nonroutable_route_table_ids](#output_nonroutable_route_table_ids)

Description: n/a

### <a name="output_nonroutable_subnet_ids"></a> [nonroutable_subnet_ids](#output_nonroutable_subnet_ids)

Description: n/a

### <a name="output_routable_route_table_ids"></a> [routable_route_table_ids](#output_routable_route_table_ids)

Description: n/a

### <a name="output_routable_subnet_ids"></a> [routable_subnet_ids](#output_routable_subnet_ids)

Description: n/a

### <a name="output_vpc_id"></a> [vpc_id](#output_vpc_id)

Description: n/a
