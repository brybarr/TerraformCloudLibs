## Providers

The following providers are used by this module:

- <a name="provider_external"></a> [external](#provider_external) (2.3.1)

- <a name="provider_null"></a> [null](#provider_null) (~> 3.0)

## Modules

The following Modules are called:

### <a name="module_aws_hashiqube"></a> [aws_hashiqube](#module_aws_hashiqube)

Source: ./modules/aws-hashiqube

Version:

### <a name="module_azure_hashiqube"></a> [azure_hashiqube](#module_azure_hashiqube)

Source: ./modules/azure-hashiqube

Version:

### <a name="module_gcp_hashiqube"></a> [gcp_hashiqube](#module_gcp_hashiqube)

Source: ./modules/gcp-hashiqube

Version:

## Resources

The following resources are used by this module:

- [null_resource.hashiqube](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) (resource)
- [external_external.myipaddress](https://registry.terraform.io/providers/hashicorp/external/2.3.1/docs/data-sources/external) (data source)

## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_aws_credentials"></a> [aws_credentials](#input_aws_credentials)

Description: AWS credentials file location

Type: `string`

Default: `"~/.aws/config"`

### <a name="input_aws_instance_type"></a> [aws_instance_type](#input_aws_instance_type)

Description: AWS instance type

Type: `string`

Default: `"t2.medium"`

### <a name="input_aws_profile"></a> [aws_profile](#input_aws_profile)

Description: AWS profile

Type: `string`

Default: `"default"`

### <a name="input_aws_region"></a> [aws_region](#input_aws_region)

Description: The region in which all AWS resources will be launched

Type: `string`

Default: `"ap-southeast-2"`

### <a name="input_azure_instance_type"></a> [azure_instance_type](#input_azure_instance_type)

Description: Azure instance type

Type: `string`

Default: `"Standard_DS1_v2"`

### <a name="input_azure_region"></a> [azure_region](#input_azure_region)

Description: The region in which all Azure resources will be launched

Type: `string`

Default: `"Australia East"`

### <a name="input_debug_user_data"></a> [debug_user_data](#input_debug_user_data)

Description: Debug Output the User Data of the Cloud instance during Terraform Apply

Type: `bool`

Default: `true`

### <a name="input_deploy_to_aws"></a> [deploy_to_aws](#input_deploy_to_aws)

Description: Deploy Hashiqube on AWS

Type: `bool`

Default: `false`

### <a name="input_deploy_to_azure"></a> [deploy_to_azure](#input_deploy_to_azure)

Description: Deploy Hashiqube on Azure

Type: `bool`

Default: `false`

### <a name="input_deploy_to_gcp"></a> [deploy_to_gcp](#input_deploy_to_gcp)

Description: Deploy Hashiqube on GCP

Type: `bool`

Default: `false`

### <a name="input_gcp_account_id"></a> [gcp_account_id](#input_gcp_account_id)

Description: Account ID

Type: `string`

Default: `"sa-consul-compute-prod"`

### <a name="input_gcp_cluster_description"></a> [gcp_cluster_description](#input_gcp_cluster_description)

Description: the description for the cluster

Type: `string`

Default: `"hashiqube"`

### <a name="input_gcp_cluster_name"></a> [gcp_cluster_name](#input_gcp_cluster_name)

Description: Cluster name

Type: `string`

Default: `"hashiqube"`

### <a name="input_gcp_cluster_size"></a> [gcp_cluster_size](#input_gcp_cluster_size)

Description: size of the cluster

Type: `number`

Default: `1`

### <a name="input_gcp_cluster_tag_name"></a> [gcp_cluster_tag_name](#input_gcp_cluster_tag_name)

Description: Cluster tag to apply

Type: `list(string)`

Default:

```json
[
  "hashiqube"
]
```

### <a name="input_gcp_credentials"></a> [gcp_credentials](#input_gcp_credentials)

Description: GCP project credentials file

Type: `string`

Default: `"~/.gcp/credentials.json"`

### <a name="input_gcp_custom_metadata"></a> [gcp_custom_metadata](#input_gcp_custom_metadata)

Description: A map of metadata key value pairs to assign to the Compute Instance metadata

Type: `map(string)`

Default: `{}`

### <a name="input_gcp_machine_type"></a> [gcp_machine_type](#input_gcp_machine_type)

Description: GCP Machine Type

Type: `string`

Default: `"n1-standard-1"`

### <a name="input_gcp_project"></a> [gcp_project](#input_gcp_project)

Description: GCP project ID

Type: `string`

Default: `"default"`

### <a name="input_gcp_region"></a> [gcp_region](#input_gcp_region)

Description: The region in which all GCP resources will be launched

Type: `string`

Default: `"australia-southeast1"`

### <a name="input_gcp_root_volume_disk_size_gb"></a> [gcp_root_volume_disk_size_gb](#input_gcp_root_volume_disk_size_gb)

Description: The size, in GB, of the root disk volume on each HashiQube node

Type: `number`

Default: `16`

### <a name="input_gcp_root_volume_disk_type"></a> [gcp_root_volume_disk_type](#input_gcp_root_volume_disk_type)

Description: The GCE disk type. Can be either pd-ssd, local-ssd, or pd-standard

Type: `string`

Default: `"pd-standard"`

### <a name="input_gcp_zones"></a> [gcp_zones](#input_gcp_zones)

Description: The zones accross which GCP resources will be launched

Type: `list(string)`

Default:

```json
[
  "australia-southeast1-a",
  "australia-southeast1-b",
  "australia-southeast1-c"
]
```

### <a name="input_ssh_private_key"></a> [ssh_private_key](#input_ssh_private_key)

Description: Path to your SSH private key, matching the public key above

Type: `string`

Default: `"~/.ssh/id_rsa"`

### <a name="input_ssh_public_key"></a> [ssh_public_key](#input_ssh_public_key)

Description: Path to your SSH public key, matching the private key below

Type: `string`

Default: `"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ......"`

### <a name="input_vagrant_provisioners"></a> [vagrant_provisioners](#input_vagrant_provisioners)

Description: The list of services you would like to run in Hashiqube, the more you run, the bigger instance youd need with more RAM

Type: `string`

Default: `"basetools,docker,consul,vault,nomad,boundary,waypoint"`

### <a name="input_whitelist_cidr"></a> [whitelist_cidr](#input_whitelist_cidr)

Description: Additional CIDR to whitelist

Type: `string`

Default: `"20.191.210.171/32"`

## Outputs

The following outputs are exported:

### <a name="output_aaa_welcome"></a> [aaa_welcome](#output_aaa_welcome)

Description: A Welcome message. Your HashiQube instance is busy launching, usually this takes ~5 minutes.  
Below are some links to open in your browser, and commands you can copy and paste in a terminal to login via SSH into your HashiQube instance.  
Thank you for using this module, you are most welcome to fork this repository to make it your own.
** DO NOT USE THIS IN PRODUCTION **

### <a name="output_aab_instructions"></a> [aab_instructions](#output_aab_instructions)

Description: Use the Hashiqube SSH output below to login to your instance  
To get Vault Shamir keys and Root token do "sudo cat /etc/vault/init.file"

### <a name="output_aws_hashiqube_boundary"></a> [aws_hashiqube_boundary](#output_aws_hashiqube_boundary)

Description: Hashiqube on AWS Boundary URL

### <a name="output_aws_hashiqube_consul"></a> [aws_hashiqube_consul](#output_aws_hashiqube_consul)

Description: Hashiqube on AWS Consul URL

### <a name="output_aws_hashiqube_fabio_lb"></a> [aws_hashiqube_fabio_lb](#output_aws_hashiqube_fabio_lb)

Description: Hashiqube on AWS Fabio LB URL

### <a name="output_aws_hashiqube_fabio_ui"></a> [aws_hashiqube_fabio_ui](#output_aws_hashiqube_fabio_ui)

Description: Hashiqube on AWS Fabio UI URL

### <a name="output_aws_hashiqube_ip"></a> [aws_hashiqube_ip](#output_aws_hashiqube_ip)

Description: Hashiqube on AWS IP address

### <a name="output_aws_hashiqube_nomad"></a> [aws_hashiqube_nomad](#output_aws_hashiqube_nomad)

Description: Hashiqube on AWS Nomad URL

### <a name="output_aws_hashiqube_ssh"></a> [aws_hashiqube_ssh](#output_aws_hashiqube_ssh)

Description: Hashiqube on AWS SSH connection string

### <a name="output_aws_hashiqube_traefik_lb"></a> [aws_hashiqube_traefik_lb](#output_aws_hashiqube_traefik_lb)

Description: Hashiqube on AWS Traefik LB URL

### <a name="output_aws_hashiqube_traefik_ui"></a> [aws_hashiqube_traefik_ui](#output_aws_hashiqube_traefik_ui)

Description: Hashiqube on AWS Traefik UI URL

### <a name="output_aws_hashiqube_vault"></a> [aws_hashiqube_vault](#output_aws_hashiqube_vault)

Description: Hashiqube on AWS Vault URL

### <a name="output_aws_hashiqube_waypoint"></a> [aws_hashiqube_waypoint](#output_aws_hashiqube_waypoint)

Description: Hashiqube on AWS Waypoint URL

### <a name="output_azure_hashiqube_boundary"></a> [azure_hashiqube_boundary](#output_azure_hashiqube_boundary)

Description: Hashiqube on Azure Boundary URL

### <a name="output_azure_hashiqube_consul"></a> [azure_hashiqube_consul](#output_azure_hashiqube_consul)

Description: Hashiqube on Azure Consul URL

### <a name="output_azure_hashiqube_fabio_lb"></a> [azure_hashiqube_fabio_lb](#output_azure_hashiqube_fabio_lb)

Description: Hashiqube on Azure Fabio LB URL

### <a name="output_azure_hashiqube_fabio_ui"></a> [azure_hashiqube_fabio_ui](#output_azure_hashiqube_fabio_ui)

Description: Hashiqube on Azure Fabio UI URL

### <a name="output_azure_hashiqube_ip"></a> [azure_hashiqube_ip](#output_azure_hashiqube_ip)

Description: Hashiqube on Azure IP address

### <a name="output_azure_hashiqube_nomad"></a> [azure_hashiqube_nomad](#output_azure_hashiqube_nomad)

Description: Hashiqube on Azure Nomad URL

### <a name="output_azure_hashiqube_ssh"></a> [azure_hashiqube_ssh](#output_azure_hashiqube_ssh)

Description: Hashiqube on Azure SSH connection string

### <a name="output_azure_hashiqube_traefik_lb"></a> [azure_hashiqube_traefik_lb](#output_azure_hashiqube_traefik_lb)

Description: Hashiqube on Azure Traefik LB URL

### <a name="output_azure_hashiqube_traefik_ui"></a> [azure_hashiqube_traefik_ui](#output_azure_hashiqube_traefik_ui)

Description: Hashiqube on Azure Traefik UI URL

### <a name="output_azure_hashiqube_vault"></a> [azure_hashiqube_vault](#output_azure_hashiqube_vault)

Description: Hashiqube on Azure Vault URL

### <a name="output_azure_hashiqube_waypoint"></a> [azure_hashiqube_waypoint](#output_azure_hashiqube_waypoint)

Description: Hashiqube on Azure Waypoint URL

### <a name="output_gcp_hashiqube_boundary"></a> [gcp_hashiqube_boundary](#output_gcp_hashiqube_boundary)

Description: Hashiqube on GCP Boundary URL

### <a name="output_gcp_hashiqube_consul"></a> [gcp_hashiqube_consul](#output_gcp_hashiqube_consul)

Description: Hashiqube on GCP Consul URL

### <a name="output_gcp_hashiqube_fabio_lb"></a> [gcp_hashiqube_fabio_lb](#output_gcp_hashiqube_fabio_lb)

Description: Hashiqube on GCP Fabio LB URL

### <a name="output_gcp_hashiqube_fabio_ui"></a> [gcp_hashiqube_fabio_ui](#output_gcp_hashiqube_fabio_ui)

Description: Hashiqube on GCP Fabio UI URL

### <a name="output_gcp_hashiqube_ip"></a> [gcp_hashiqube_ip](#output_gcp_hashiqube_ip)

Description: Hashiqube on GCP IP address

### <a name="output_gcp_hashiqube_nomad"></a> [gcp_hashiqube_nomad](#output_gcp_hashiqube_nomad)

Description: Hashiqube on GCP Nomad URL

### <a name="output_gcp_hashiqube_ssh"></a> [gcp_hashiqube_ssh](#output_gcp_hashiqube_ssh)

Description: Hashiqube on GCP SSH connection string

### <a name="output_gcp_hashiqube_traefik_lb"></a> [gcp_hashiqube_traefik_lb](#output_gcp_hashiqube_traefik_lb)

Description: Hashiqube on GCP Traefik LB URL

### <a name="output_gcp_hashiqube_traefik_ui"></a> [gcp_hashiqube_traefik_ui](#output_gcp_hashiqube_traefik_ui)

Description: Hashiqube on GCP Traefik UI URL

### <a name="output_gcp_hashiqube_vault"></a> [gcp_hashiqube_vault](#output_gcp_hashiqube_vault)

Description: Hashiqube on GCP Vault URL

### <a name="output_gcp_hashiqube_waypoint"></a> [gcp_hashiqube_waypoint](#output_gcp_hashiqube_waypoint)

Description: Hashiqube on GCP Waypoint URL

### <a name="output_your_ipaddress"></a> [your_ipaddress](#output_your_ipaddress)

Description: Your Public IP Address, used for Whitelisting
