# data "aws_availability_zones" "available" {
#   state = "available"
# }

# locals {
#   default_tags = merge(
#     var.default_tags, {"Env" = var.env}
#   )
# }

# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags       = {"Name" = "${var.env}-vpc"}
}

# --- Public Subnets ---
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags                    = {"Name" = "${var.env}-public-subnet-${count.index + 1}"}
}

# --- Private Subnets ---
resource "aws_subnet" "private_subnet" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false
  tags                    = {"Name" = "${var.env}-private-subnet-${count.index + 1}"}
}

# --- Internet Gateway (only if enable_igw = true) ---
resource "aws_internet_gateway" "igw" {
  count = var.enable_igw && length(var.public_subnet_cidrs) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id 
  tags = {"Name" = "${var.env}-igw"}
}

# --- Elastic IP for NAT Gateway ---
resource "aws_eip" "nat_eip" {
  count = var.enable_nat ? 1 : 0 # Only create an Elastic IP if NAT Gateway is enabled
  domain = "vpc"
  tags = {"Name" = "${var.env}-nat-eip"}
}

# --- NAT Gateway (only if enable_nat_gateway = true) ---
resource "aws_nat_gateway" "nat_gw" {
  count         = var.enable_nat ? 1 : 0
  allocation_id = aws_eip.nat_eip[0].id #NAT GW needs an Elastic IP (a fixed public IP address) attached to it
  subnet_id     = aws_subnet.public_subnet[0].id
  tags          = {"Name" = "${var.env}-nat-gw-${count.index + 1}"}

  depends_on = [aws_internet_gateway.igw] # Ensure IGW is created before NAT GW since NAT GW needs to be in a public subnet which requires IGW for internet access
}

# --- Public Route Table (routes internet traffic through IGW) ---
resource "aws_route_table" "public_rt" {
  count = var.enable_igw && length(var.public_subnet_cidrs) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }

  tags   = {"Name" = "${var.env}-public-rt"}
}

resource "aws_route_table_association" "public_routes" {
  count = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt[0].id
}

# --- Private Route Table (routes internet traffic through NAT GW) ---
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  dynamic "route" { #the NAT route only appears if NAT GW exists, 
  # prod's private route table will have no outbound internet route at all, which is correct since prod has no public subnets.
    for_each = var.enable_nat ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat_gw[0].id
    }
  }

  tags   = {"Name" = "${var.env}-private-rt"}
}

resource "aws_route_table_association" "private_routes" {
  count = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt.id
}