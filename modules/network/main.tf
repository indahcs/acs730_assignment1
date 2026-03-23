data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  default_tags = merge(
    var.default_tags, {"Env" = var.env}
  )
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags       = merge(local.default_tags, {"Name" = "${var.prefix}-vpc"})
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = true
  tags                    = merge(local.default_tags, {"Name" = "${var.prefix}-public-subnet-${count.index + 1}"})
}

resource "aws_subnet" "private_subnet" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = false
  tags                    = merge(local.default_tags, {"Name" = "${var.prefix}-private-subnet-${count.index + 1}"})
}

resource "aws_internet_gateway" "igw" {
  count = length(var.public_subnet_cidrs) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id 
  tags = merge(local.default_tags, {"Name" = "${var.prefix}-igw"})
}

resource "aws_eip" "nat_eip" {
  count = var.enable_nat ? 1 : 0
}

resource "aws_nat_gateway" "nat_gw" {
  count         = var.enable_nat ? 1 : 0
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = aws_subnet.public_subnet[0].id
  tags          = merge(local.default_tags, {"Name" = "${var.prefix}-nat-gw-${count.index + 1}"})
}

resource "aws_route_table" "public_rt" {
  count = length(var.public_subnet_cidrs) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id
  tags   = merge(local.default_tags, {"Name" = "${var.prefix}-public-rt"})
}

resource "aws_route" "public_route" {
  count = length(var.public_subnet_cidrs) > 0 ? 1 : 0
  route_table_id         = aws_route_table.public_rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.default_tags, {"Name" = "${var.prefix}-private-rt"})
}

resource "aws_route" "private_route" {
  count = var.enable_nat ? 1 : 0 
  route_table_id = aws_route_table.private_rt.id 
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gw[0].id
}

resource "aws_route_table_association" "public_routes" {
  count = length(aws_subnet.public_subnet)
  route_table_id = aws_route_table.public_rt[0].id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

resource "aws_route_table_association" "private_routes" {
  count = length(aws_subnet.private_subnet)
  route_table_id = aws_route_table.private_rt[0].id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}