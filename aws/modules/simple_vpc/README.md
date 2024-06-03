## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider_aws) (~> 5.0)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aws_eip.nat_gw_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) (resource)
- [aws_internet_gateway.gw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) (resource)
- [aws_nat_gateway.nat_gw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) (resource)
- [aws_route.private_subnet_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) (resource)
- [aws_route_table.private_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) (resource)
- [aws_route_table.public_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) (resource)
- [aws_route_table_association.private_subnet_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) (resource)
- [aws_route_table_association.public_subnet_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) (resource)
- [aws_subnet.private_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) (resource)
- [aws_subnet.public_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) (resource)
- [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) (resource)
- [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_aws_profile"></a> [aws_profile](#input_aws_profile)

Description: The AWS profile to use

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_aws_region"></a> [aws_region](#input_aws_region)

Description: The AWS region to use

Type: `string`

Default: `"ap-southeast-2"`

### <a name="input_create_public_subnet"></a> [create_public_subnet](#input_create_public_subnet)

Description: Set to true to create public subnets with NAT Gateways.

Type: `bool`

Default: `true`

### <a name="input_tags"></a> [tags](#input_tags)

Description: Tags common to all resources in the module

Type: `map(any)`

Default: `{}`

### <a name="input_vpc_cidr_block"></a> [vpc_cidr_block](#input_vpc_cidr_block)

Description: The CIDR block to use for the VPC

Type: `string`

Default: `"10.0.0.0/16"`

### <a name="input_vpc_name"></a> [vpc_name](#input_vpc_name)

Description: The name of the VPC, used as the Name tag

Type: `string`

Default: `"MyVPC"`

## Outputs

No outputs.
