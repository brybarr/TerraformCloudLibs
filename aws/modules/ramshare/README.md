## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider_aws)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aws_ram_principal_association.resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) (resource)
- [aws_ram_resource_association.resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) (resource)
- [aws_ram_resource_share.resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_aws_account_id"></a> [aws_account_id](#input_aws_account_id)

Description: n/a

Type: `string`

### <a name="input_aws_region"></a> [aws_region](#input_aws_region)

Description: n/a

Type: `string`

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

### <a name="input_share_name"></a> [share_name](#input_share_name)

Description: n/a

Type: `string`

### <a name="input_share_principals"></a> [share_principals](#input_share_principals)

Description: n/a

Type: `list(string)`

### <a name="input_share_resource_arn"></a> [share_resource_arn](#input_share_resource_arn)

Description: n/a

Type: `string`

## Optional Inputs

No optional inputs.

## Outputs

No outputs.
