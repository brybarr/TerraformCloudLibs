locals {
  sharedservices_azs = [(data.aws_availability_zones.available.names[0]), (data.aws_availability_zones.available.names[1])]
  interconnect_azs   = [(data.aws_availability_zones.available.names[0]), (data.aws_availability_zones.available.names[1])]
  vpc = {
    vpc_name                = "${var.collection_identifier}-${var.name}"
    vpc_cidr                = "${var.vpc_octet1}.${var.vpc_octet2}.${var.vpc_octet3}.${var.vpc_octet4}"
    vpc_mask                = var.vpc_mask
    map_public_ip_on_launch = false
    sharedservices_subnets = [
      "${var.vpc_octet1}.${var.vpc_octet2}.${tostring(var.vpc_octet3)}.${var.vpc_octet4 + 0}/28",
      "${var.vpc_octet1}.${var.vpc_octet2}.${tostring(var.vpc_octet3)}.${var.vpc_octet4 + 16}/28"

    ]
    interconnect_subnets = [
      "${var.vpc_octet1}.${var.vpc_octet2}.${tostring(var.vpc_octet3)}.${var.vpc_octet4 + 32}/28",
      "${var.vpc_octet1}.${var.vpc_octet2}.${tostring(var.vpc_octet3)}.${var.vpc_octet4 + 48}/28"
    ]
  }
}
