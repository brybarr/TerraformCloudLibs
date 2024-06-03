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

# data "aws_iam_policy_document" "ou_policy" {
#   statement {
#     sid    = "DenyNetworkActionsExceptTGWApprovedAttach"
#     effect = "Deny"
#     actions = [
#       "ec2:CreateTransitGatewayVpcAttachment"
#     ]
#     resources = [
#       "arn:${Partition}:ec2:${Region}:${Account}:transit-gateway/*"
#     ]
#     condition {
#       test     = "StringNotEquals"
#       variable = "aws:ResourceTag/access-project"
#       values = [
#         "arn:aws:iam::*:role/${var.mk_core_role_name}*"
#       ]
#     }
#   }
# }
