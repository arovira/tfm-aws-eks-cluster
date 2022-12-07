# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_availability_zones" "available" {
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name" = "${var.cluster_name}-vpc"
  }
}

resource "aws_subnet" "subnet" {
  count = var.vpc_private_subnet_count

  availability_zone = data.aws_availability_zones.available.names[count.index]
  # Create 3 /18 subnets, skipping the first one since that will be used for public/aws service subnets
  # X.X.64.0/18 - X.X.192.X/18
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 2, 1 + count.index)
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = false

  tags = {
    "Name" = "${var.cluster_name}-private-subnet-${count.index}"
  }
}

resource "aws_subnet" "public_subnet" {
  count = var.vpc_public_subnet_count

  availability_zone = data.aws_availability_zones.available.names[count.index]
  # Create 5 /24 subnets X.X.0.X/24 - X.X.4.0/24
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${var.cluster_name}-public-subnet-${count.index}"
  }
}

resource "aws_subnet" "aws_svc_subnet" {
  count = var.vpc_svc_subnet_count

  availability_zone = data.aws_availability_zones.available.names[count.index]
  # Create 4 /24 subnets X.X.60.X/24 - X.X.64.0/24
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 60 + count.index)
  vpc_id     = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.cluster_name}-service-subnet-${count.index}"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "${var.cluster_name}-db-subnet-group"
  subnet_ids = aws_subnet.aws_svc_subnet.*.id
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.cluster_name}-ig"
  }
}

resource "aws_eip" "nat" {
  vpc              = true
  public_ipv4_pool = "amazon"
  depends_on       = [aws_internet_gateway.ig]
  tags = {
    "Name" = "${var.cluster_name}-eip"
  }
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id
  depends_on = [aws_internet_gateway.ig,
  aws_eip.nat, ]

  tags = {
    "Name" = "${var.cluster_name}-nat-gw"
  }
}

resource "aws_default_route_table" "private-route-table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  lifecycle {
    ignore_changes = [route]
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id
  }

  tags = {
    "Name" = "${var.cluster_name}-private-rt"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id

  lifecycle {
    ignore_changes = [route]
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    "Name" = "${var.cluster_name}-public-rt"
  }
}

resource "aws_route_table_association" "public-route-table-assoc" {
  count = var.vpc_public_subnet_count

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public-route-table.id
}
