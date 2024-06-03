## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider_aws)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aws_iam_role.role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)
- [aws_iam_role_policy.role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) (resource)
- [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)
- [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
- [aws_iam_policy_document.identity_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
- [aws_iam_policy_document.identity_trust_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)

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

### <a name="input_role_name"></a> [role_name](#input_role_name)

Description: n/a

Type: `string`

### <a name="input_trust_principal_arn"></a> [trust_principal_arn](#input_trust_principal_arn)

Description: n/a

Type: `list(string)`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_kms_keys"></a> [kms_keys](#input_kms_keys)

Description: n/a

Type: `list(string)`

Default: `[]`

### <a name="input_managed_policy_arns"></a> [managed_policy_arns](#input_managed_policy_arns)

Description: n/a

Type: `list(string)`

Default: `[]`

### <a name="input_max_session_duration"></a> [max_session_duration](#input_max_session_duration)

Description: n/a

Type: `number`

Default: `3600`

## Outputs

No outputs.
