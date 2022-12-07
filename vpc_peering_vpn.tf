# VPC peering connection
resource "aws_vpc_peering_connection" "vpn_peer" {
  vpc_id        = aws_vpc.vpc.id
  peer_owner_id = var.vpn_settings["aws_account_id"]
  peer_vpc_id   = var.vpn_settings["vpc_id"]

  tags = {
    Name = "${var.cluster_name}-vpc-vpn-peering"
  }
}

# VPC peering accepter
resource "aws_vpc_peering_connection_accepter" "vpn_peer_accepter" {
  provider                  = aws.vpn
  vpc_peering_connection_id = aws_vpc_peering_connection.vpn_peer.id
  auto_accept               = true

  lifecycle {
    ignore_changes = [auto_accept]
  }

  tags = {
    Name = "${var.cluster_name}-vpc-vpn-peering"
  }
}

# Routes for routing traffic to VPN peering connection
resource "aws_route" "vpc-vpn-public" {
  route_table_id            = aws_route_table.public-route-table.id
  vpc_peering_connection_id = aws_vpc_peering_connection.vpn_peer.id
  destination_cidr_block    = var.vpn_settings["cidr"]
}
resource "aws_route" "vpc-vpn-private" {
  route_table_id            = aws_vpc.vpc.default_route_table_id
  vpc_peering_connection_id = aws_vpc_peering_connection.vpn_peer.id
  destination_cidr_block    = var.vpn_settings["cidr"]
}

# Routes for routing traffic from VPN to VPC
resource "aws_route" "vpn-vpc-public" {
  provider                  = aws.vpn
  route_table_id            = var.vpn_settings["public_route_table_id"]
  vpc_peering_connection_id = aws_vpc_peering_connection.vpn_peer.id
  destination_cidr_block    = var.vpc_cidr_block
}
resource "aws_route" "vpn-vpc-private" {
  provider                  = aws.vpn
  route_table_id            = var.vpn_settings["private_route_table_id"]
  vpc_peering_connection_id = aws_vpc_peering_connection.vpn_peer.id
  destination_cidr_block    = var.vpc_cidr_block
}

# https Access to EKS control plane
resource "aws_security_group_rule" "vpn_to_cluster" {
  type              = "ingress"
  description       = "HTTPS access from VPN"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.vpn_settings["cidr"]]
  ipv6_cidr_blocks  = []
  prefix_list_ids   = []
  security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}
