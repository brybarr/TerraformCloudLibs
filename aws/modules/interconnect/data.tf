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

data "aws_ec2_transit_gateway" "sharedservices" {
  id = var.sharedservices_tgw_id
}
