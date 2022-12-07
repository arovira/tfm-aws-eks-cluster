resource "aws_eks_node_group" "node_group" {
  count = length(var.eks_node_pools)

  cluster_name           = var.cluster_name
  node_group_name_prefix = var.eks_node_pools[count.index].name
  node_role_arn          = aws_iam_role.node_group.arn
  subnet_ids             = aws_subnet.subnet.*.id
  disk_size              = var.eks_node_pools[count.index].disk_size
  capacity_type          = var.eks_node_pools[count.index].capacity_type
  instance_types         = var.eks_node_pools[count.index].instance_types
  version                = var.eks_node_pools[count.index].k8s_version

  timeouts {
    create = "60m"
    update = "4h"
    delete = "2h"
  }

  tags = {
    "Name"                                          = var.eks_node_pools[count.index].name
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled"             = "enabled"
  }

  scaling_config {
    desired_size = var.eks_node_pools[count.index].min_nodes
    max_size     = var.eks_node_pools[count.index].max_nodes
    min_size     = var.eks_node_pools[count.index].min_nodes
  }

  # Ignore differences between "desired_size" and actual size
  # which may change due to autoscaling.
  lifecycle {
    ignore_changes        = [scaling_config[0].desired_size]
    create_before_destroy = true
  }

  remote_access {
    ec2_ssh_key               = aws_key_pair.cluster_ssh_key.key_name
    source_security_group_ids = [aws_security_group.ssh-access.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_eks_cluster.eks_cluster,
  ]
}

resource "aws_autoscaling_group_tag" "asg_name_tag" {
  count = length(var.eks_node_pools)

  autoscaling_group_name = aws_eks_node_group.node_group[count.index].resources[0].autoscaling_groups[0].name

  tag {
    key                 = "Name"
    value               = var.eks_node_pools[count.index]["name"]
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group_tag" "default_asg_shared_tags" {
  count = length(keys(var.eks_node_pools[0].shared_tags))

  autoscaling_group_name = aws_eks_node_group.node_group[0].resources[0].autoscaling_groups[0].name

  tag {
    key                 = keys(var.eks_node_pools[0].shared_tags)[count.index]
    value               = values(var.eks_node_pools[0].shared_tags)[count.index]
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group_tag" "additional_asg_shared_tags" {
  count = length(keys(var.eks_node_pools[1].shared_tags))

  autoscaling_group_name = aws_eks_node_group.node_group[1].resources[0].autoscaling_groups[0].name

  tag {
    key                 = keys(var.eks_node_pools[1].shared_tags)[count.index]
    value               = values(var.eks_node_pools[1].shared_tags)[count.index]
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group_tag" "default_asg_additional_tags" {
  count = length(keys(var.eks_node_pools[0].additional_tags))

  autoscaling_group_name = aws_eks_node_group.node_group[0].resources[0].autoscaling_groups[0].name

  tag {
    key                 = keys(var.eks_node_pools[0].additional_tags)[count.index]
    value               = values(var.eks_node_pools[0].additional_tags)[count.index]
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group_tag" "additional_asg_additional_tags" {
  count = length(keys(var.eks_node_pools[1].additional_tags))

  autoscaling_group_name = aws_eks_node_group.node_group[1].resources[0].autoscaling_groups[0].name

  tag {
    key                 = keys(var.eks_node_pools[1].additional_tags)[count.index]
    value               = values(var.eks_node_pools[1].additional_tags)[count.index]
    propagate_at_launch = true
  }
}