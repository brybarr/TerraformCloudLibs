## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider_aws) (>= 5.0)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) (resource)
- [aws_security_group_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) (resource)
- [aws_vpc_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) (resource)
- [aws_vpc_endpoint_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) (data source)

## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_create"></a> [create](#input_create)

Description: Determines whether resources will be created

Type: `bool`

Default: `true`

### <a name="input_create_security_group"></a> [create_security_group](#input_create_security_group)

Description: Determines if a security group is created

Type: `bool`

Default: `false`

### <a name="input_endpoints"></a> [endpoints](#input_endpoints)

Description: A map of interface and/or gateway endpoints containing their properties and configurations

Type: `any`

Default: `{}`

### <a name="input_security_group_description"></a> [security_group_description](#input_security_group_description)

Description: Description of the security group created

Type: `string`

Default: `null`

### <a name="input_security_group_ids"></a> [security_group_ids](#input_security_group_ids)

Description: Default security group IDs to associate with the VPC endpoints

Type: `list(string)`

Default: `[]`

### <a name="input_security_group_name"></a> [security_group_name](#input_security_group_name)

Description: Name to use on security group created. Conflicts with `security_group_name_prefix`

Type: `string`

Default: `null`

### <a name="input_security_group_name_prefix"></a> [security_group_name_prefix](#input_security_group_name_prefix)

Description: Name prefix to use on security group created. Conflicts with `security_group_name`

Type: `string`

Default: `null`

### <a name="input_security_group_rules"></a> [security_group_rules](#input_security_group_rules)

Description: Security group rules to add to the security group created

Type: `any`

Default: `{}`

### <a name="input_security_group_tags"></a> [security_group_tags](#input_security_group_tags)

Description: A map of additional tags to add to the security group created

Type: `map(string)`

Default: `{}`

### <a name="input_subnet_ids"></a> [subnet_ids](#input_subnet_ids)

Description: Default subnets IDs to associate with the VPC endpoints

Type: `list(string)`

Default: `[]`

### <a name="input_tags"></a> [tags](#input_tags)

Description: A map of tags to use on all resources

Type: `map(string)`

Default: `{}`

### <a name="input_timeouts"></a> [timeouts](#input_timeouts)

Description: Define maximum timeout for creating, updating, and deleting VPC endpoint resources

Type: `map(string)`

Default: `{}`

### <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)

Description: The ID of the VPC in which the endpoint will be used

Type: `string`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_endpoints"></a> [endpoints](#output_endpoints)

Description: Array containing the full resource object and attributes for all endpoints created

### <a name="output_security_group_arn"></a> [security_group_arn](#output_security_group_arn)

Description: Amazon Resource Name (ARN) of the security group

### <a name="output_security_group_id"></a> [security_group_id](#output_security_group_id)

Description: ID of the security group
