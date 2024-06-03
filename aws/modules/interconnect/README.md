## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider_aws)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aws_cloudwatch_log_group.interconnect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) (resource)
- [aws_ec2_transit_gateway.interconnect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) (resource)
- [aws_ec2_transit_gateway_route.interconnect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) (resource)
- [aws_ec2_transit_gateway_vpc_attachment.interconnect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) (resource)
- [aws_ec2_transit_gateway_vpc_attachment.sharedservices](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) (resource)
- [aws_flow_log.interconnect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) (resource)
- [aws_iam_role.interconnect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)
- [aws_iam_role_policy.interconnect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) (resource)
- [aws_network_acl.interconnect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) (resource)
- [aws_network_acl.sharedservices](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) (resource)
- [aws_network_acl_rule.interconnect_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) (resource)
- [aws_network_acl_rule.interconnect_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) (resource)
- [aws_network_acl_rule.sharedservices_inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) (resource)
- [aws_network_acl_rule.sharedservices_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) (resource)
- [aws_route.interconnect_tgw_attachedvpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) (resource)
- [aws_route.interconnect_tgw_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) (resource)
- [aws_route.sharedservices_tgw_attachedvpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) (resource)
- [aws_route.sharedservices_tgw_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) (resource)
- [aws_route_table.interconnect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) (resource)
- [aws_route_table.sharedservices](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) (resource)
- [aws_route_table_association.interconnect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) (resource)
- [aws_route_table_association.sharedservices](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) (resource)
- [aws_subnet.interconnect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) (resource)
- [aws_subnet.sharedservices](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) (resource)
- [aws_vpc.interconnect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) (resource)
- [aws_vpc_dhcp_options.interconnect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options) (resource)
- [aws_vpc_dhcp_options_association.interconnect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association) (resource)
- [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) (data source)
- [aws_ec2_transit_gateway.sharedservices](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_transit_gateway) (data source)
- [aws_iam_policy_document.flowlogs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
- [aws_iam_policy_document.vpcflowlogs_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_acl_rules"></a> [acl_rules](#input_acl_rules)

Description: n/a

Type: `list(map(string))`

### <a name="input_allowed_external_ranges"></a> [allowed_external_ranges](#input_allowed_external_ranges)

Description: n/a

Type: `list(string)`

### <a name="input_attachedvpc_cidr"></a> [attachedvpc_cidr](#input_attachedvpc_cidr)

Description: n/a

Type: `string`

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

### <a name="input_kms_key_arn"></a> [kms_key_arn](#input_kms_key_arn)

Description: n/a

Type: `string`

### <a name="input_sharedservices_tgw_id"></a> [sharedservices_tgw_id](#input_sharedservices_tgw_id)

Description: n/a

Type: `string`

### <a name="input_vpc_mask"></a> [vpc_mask](#input_vpc_mask)

Description: n/a

Type: `number`

### <a name="input_vpc_octet1"></a> [vpc_octet1](#input_vpc_octet1)

Description: n/a

Type: `number`

### <a name="input_vpc_octet2"></a> [vpc_octet2](#input_vpc_octet2)

Description: n/a

Type: `number`

### <a name="input_vpc_octet3"></a> [vpc_octet3](#input_vpc_octet3)

Description: n/a

Type: `number`

### <a name="input_vpc_octet4"></a> [vpc_octet4](#input_vpc_octet4)

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

### <a name="input_interconnect_subnet_suffix"></a> [interconnect_subnet_suffix](#input_interconnect_subnet_suffix)

Description: n/a

Type: `string`

Default: `"Interconnect"`

### <a name="input_ixtgw_amazon_side_asn"></a> [ixtgw_amazon_side_asn](#input_ixtgw_amazon_side_asn)

Description: n/a

Type: `number`

Default: `64512`

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

### <a name="input_sharedservices_subnet_suffix"></a> [sharedservices_subnet_suffix](#input_sharedservices_subnet_suffix)

Description: n/a

Type: `string`

Default: `"SharedServices"`

### <a name="input_ss_tgw_attachment_state"></a> [ss_tgw_attachment_state](#input_ss_tgw_attachment_state)

Description: n/a

Type: `string`

Default: `"ready"`

## Outputs

The following outputs are exported:

### <a name="output_interconnect_route_table_ids"></a> [interconnect_route_table_ids](#output_interconnect_route_table_ids)

Description: n/a

### <a name="output_interconnect_subnet_ids"></a> [interconnect_subnet_ids](#output_interconnect_subnet_ids)

Description: n/a

### <a name="output_sharedservices_route_table_ids"></a> [sharedservices_route_table_ids](#output_sharedservices_route_table_ids)

Description: n/a

### <a name="output_sharedservices_subnet_ids"></a> [sharedservices_subnet_ids](#output_sharedservices_subnet_ids)

Description: n/a

### <a name="output_tgw_arn"></a> [tgw_arn](#output_tgw_arn)

Description: n/a

### <a name="output_tgw_id"></a> [tgw_id](#output_tgw_id)

Description: n/a

### <a name="output_vpc_id"></a> [vpc_id](#output_vpc_id)

Description: n/a
