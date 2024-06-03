## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider_aws)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aws_organizations_policy.scp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) (resource)
- [aws_organizations_policy_attachment.attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) (resource)

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

### <a name="input_scp_description"></a> [scp_description](#input_scp_description)

Description: n/a

Type: `string`

### <a name="input_scp_name"></a> [scp_name](#input_scp_name)

Description: n/a

Type: `string`

### <a name="input_scp_policy"></a> [scp_policy](#input_scp_policy)

Description: n/a

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_target_id"></a> [target_id](#input_target_id)

Description: n/a

Type: `string`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_attached_target_id"></a> [attached_target_id](#output_attached_target_id)

Description: n/a

### <a name="output_scp_id"></a> [scp_id](#output_scp_id)

Description: n/a
