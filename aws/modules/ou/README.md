## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider_aws)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aws_organizations_organizational_unit.ou](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) (resource)
- [aws_organizations_organization.organization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) (data source)
- [aws_organizations_organizational_units.organization_ous](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organizational_units) (data source)

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

### <a name="input_ou_name"></a> [ou_name](#input_ou_name)

Description: n/a

Type: `string`

### <a name="input_parent_id"></a> [parent_id](#input_parent_id)

Description: n/a

Type: `string`

## Optional Inputs

No optional inputs.

## Outputs

The following outputs are exported:

### <a name="output_ou_arn"></a> [ou_arn](#output_ou_arn)

Description: n/a

### <a name="output_ou_id"></a> [ou_id](#output_ou_id)

Description: n/a
