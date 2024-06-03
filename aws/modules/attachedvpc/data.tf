data "aws_availability_zones" "available" {
  state = "available"
}

# tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "flowlogs" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "vpcflowlogs_assume_role" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "vpc-flow-logs.amazonaws.com"
      ]
    }
  }
}

data "aws_ec2_transit_gateway" "interconnect" {
  id = var.interconnect_tgw_id
}

data "aws_iam_policy_document" "s3_gateway_policy" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "*"
      identifiers = [
        "*"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values = [
        var.org_id
      ]
    }
  }
}

data "aws_iam_policy_document" "attachedvpc_interface" {
  count = length(local.vpc.vpc_interface_endpoints)
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "*"
      identifiers = [
        "*"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values = [
        var.org_id
      ]
    }
  }
}
