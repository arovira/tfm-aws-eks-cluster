output "private_subnet_ids" {
  value = aws_subnet.subnet.*.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.default.name
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "private_route_table_id" {
  value = aws_default_route_table.private-route-table.id
}

output "public_route_table_id" {
  value = aws_route_table.public-route-table.id
}
