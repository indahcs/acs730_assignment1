# --- VPC Peering Connection ---
resource "aws_vpc_peering_connection" "peering" {
  vpc_id        = var.nonprod_vpc_id
  peer_vpc_id   = var.prod_vpc_id
  auto_accept   = true 

  tags = {
    Name = "nonprod-prod-peering"
  }
}

# --- Route in Non-Prod private RT pointing to Prod ---
resource "aws_route" "nonprod_to_prod" {
  route_table_id         = var.nonprod_vpc_route_table_id
  destination_cidr_block = var.prod_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}

# --- Route in Prod private RT pointing to Non-Prod ---
resource "aws_route" "prod_to_nonprod" {
  route_table_id         = var.prod_vpc_route_table_id
  destination_cidr_block = var.nonprod_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}