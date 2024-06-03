locals {

  routable_azs    = [(data.aws_availability_zones.available.names[0]), (data.aws_availability_zones.available.names[1])]
  nonroutable_azs = [(data.aws_availability_zones.available.names[0]), (data.aws_availability_zones.available.names[1])]

  vpc = {
    vpc_name                = "${var.collection_identifier}-${var.name}"
    routable_cidr           = "${var.vpc_routable_octet1}.${var.vpc_routable_octet2}.${var.vpc_routable_octet3}.${var.vpc_routable_octet4}"
    routable_mask           = var.vpc_routable_mask
    nonroutable_cidr        = "${var.vpc_nonroutable_octet1}.${var.vpc_nonroutable_octet2}.${var.vpc_nonroutable_octet3}.${var.vpc_nonroutable_octet4}"
    nonroutable_mask        = var.vpc_nonroutable_mask
    map_public_ip_on_launch = false
    routable_subnets = [
      cidrsubnet("${var.vpc_routable_octet1}.${var.vpc_routable_octet2}.${var.vpc_routable_octet3}.${var.vpc_routable_octet4}/${var.vpc_routable_mask}", 1, 0),
      cidrsubnet("${var.vpc_routable_octet1}.${var.vpc_routable_octet2}.${var.vpc_routable_octet3}.${var.vpc_routable_octet4}/${var.vpc_routable_mask}", 1, 1)
    ]
    nonroutable_subnets = [
      cidrsubnet("${var.vpc_nonroutable_octet1}.${var.vpc_nonroutable_octet2}.${var.vpc_nonroutable_octet3}.${var.vpc_nonroutable_octet4}/${var.vpc_nonroutable_mask}", 1, 0),
      cidrsubnet("${var.vpc_nonroutable_octet1}.${var.vpc_nonroutable_octet2}.${var.vpc_nonroutable_octet3}.${var.vpc_nonroutable_octet4}/${var.vpc_nonroutable_mask}", 1, 1)
    ]
    vpc_interface_endpoints = [
      #    "com.amazonaws.${var.aws_region}.ec2"
    ]
  }
}
