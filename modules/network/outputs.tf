output "vpc_id" {
  value = aws_vpc.main.id
}
output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}
output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}
output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

# --- For Peering Connection ---
output "private_route_table_id" {
  value = aws_route_table.private_rt.id
}
output "public_route_table_id" {
  value = var.enable_igw ? aws_route_table.public_rt[0].id : null
}