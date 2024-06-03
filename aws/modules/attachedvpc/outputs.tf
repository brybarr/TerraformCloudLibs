
output "vpc_id" {
  value = aws_vpc.attachedvpc.id
}

output "routable_subnet_ids" {
  value = aws_subnet.routable.*.id
}

output "nonroutable_subnet_ids" {
  value = aws_subnet.nonroutable.*.id
}

output "routable_route_table_ids" {
  value = aws_route_table.routable.*.id
}

output "nonroutable_route_table_ids" {
  value = aws_route_table.nonroutable.*.id
}
