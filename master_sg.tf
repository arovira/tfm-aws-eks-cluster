resource "aws_security_group_rule" "map" {
  for_each = var.worker_sg_rules

  type              = each.value.type
  description       = each.value.description
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  ipv6_cidr_blocks  = each.value.ipv6_cidr_blocks
  prefix_list_ids   = each.value.prefix_list_ids
  security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_security_group" "sg" {
  name        = "${var.cluster_name}-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${var.cluster_name}-sg"
  }
}