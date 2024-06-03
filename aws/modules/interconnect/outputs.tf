
output "vpc_id" {
  value = aws_vpc.interconnect.id
}

output "sharedservices_subnet_ids" {
  value = aws_subnet.sharedservices.*.id
}

output "interconnect_subnet_ids" {
  value = aws_subnet.interconnect.*.id
}

output "sharedservices_route_table_ids" {
  value = aws_route_table.sharedservices.*.id
}

output "interconnect_route_table_ids" {
  value = aws_route_table.interconnect.*.id
}

output "tgw_id" {
  value = aws_ec2_transit_gateway.interconnect.id
}

output "tgw_arn" {
  value = aws_ec2_transit_gateway.interconnect.arn
}
