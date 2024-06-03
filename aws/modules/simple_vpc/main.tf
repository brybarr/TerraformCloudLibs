#
# This local helps us determine if public subnets are needed or not and how many of them
#

locals {
  count_public_subnet = var.create_public_subnet ? length(data.aws_availability_zones.available.names) : 0
}

################################################################################
# VPC
################################################################################

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = (merge(var.tags,
    {
      Name = var.vpc_name
    }
  ))
}

resource "aws_internet_gateway" "gw" {
  count  = var.create_public_subnet ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = (merge(var.tags, {
    Name = "InternetGateway"
    }
  ))

}

################################################################################
# Private Subnet
################################################################################

resource "aws_subnet" "private_subnet" {
  count      = length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index + 1) # /24 subnets, incrementing the third octet

  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = (merge(var.tags, {
    Name = "PrivateSubnet-${count.index + 1}"
    }
  ))
}

resource "aws_route_table" "private_route_table" {
  count = length(aws_subnet.private_subnet)

  vpc_id = aws_vpc.main.id

  tags = (merge(var.tags, {
    Name = "PrivateRouteTable-${count.index + 1}"
    }
  ))
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}

################################################################################
# Public Subnet
################################################################################

resource "aws_subnet" "public_subnet" {
  count      = local.count_public_subnet
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index + 100) # /24 subnets, incrementing the third octet

  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = (merge(var.tags, {
    Name = "PublicSubnet-${count.index + 1}"
    }
  ))
}

resource "aws_route_table" "public_route_table" {
  count  = var.create_public_subnet ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = (merge(var.tags, {
    Name = "PublicRouteTable-${count.index + 1}"
    }
  ))
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = local.count_public_subnet
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table[0].id
}


################################################################################
# NAT GW
################################################################################

resource "aws_eip" "nat_gw_eip" {
  count = length(aws_subnet.public_subnet)

  domain = "vpc"

  tags = (merge(var.tags, {
    Name = "NATgatewayEIP-${count.index + 1}"
    }
  ))
}

resource "aws_nat_gateway" "nat_gw" {
  count = local.count_public_subnet

  subnet_id     = aws_subnet.public_subnet[count.index].id
  allocation_id = aws_eip.nat_gw_eip[count.index].id
}

resource "aws_route" "private_subnet_nat_gateway" {
  count = local.count_public_subnet

  route_table_id         = aws_route_table.private_route_table[count.index].id
  destination_cidr_block = var.create_public_subnet ? "0.0.0.0/0" : null
  nat_gateway_id         = var.create_public_subnet ? aws_nat_gateway.nat_gw[count.index].id : null
}
