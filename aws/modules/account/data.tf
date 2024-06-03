data "aws_organizations_organization" "organization" {
}

data "aws_organizations_organizational_units" "organization_ous" {
  parent_id = data.aws_organizations_organization.organization.roots[0].id
}

locals {
  all_ous = data.aws_organizations_organizational_units.organization_ous.children[*]
}

# locals {
#   filter1          = [for k, v in local.all_ous : v.id if v.name == "test"]
#   aws_parent_ou_id = local.filter1[0]
# }
