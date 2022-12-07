resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.master.arn
  version  = var.k8s_version

  vpc_config {
    security_group_ids      = [aws_security_group.sg.id]
    subnet_ids              = aws_subnet.subnet[*].id
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.cluster_kms_key.arn
    }
  }

  tags = {
    "Name" = "${var.cluster_name}-cluster"
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
  ]
}

resource "tls_private_key" "ssh_tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "cluster_ssh_key" {
  key_name   = var.ec2_ssh_key_name
  public_key = tls_private_key.ssh_tls_key.public_key_openssh
}

resource "aws_kms_key" "cluster_kms_key" {
  description             = "KMS key for cluster ${var.cluster_name}"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "cluster_kms_key" {
  name          = "alias/${var.cluster_name}"
  target_key_id = aws_kms_key.cluster_kms_key.key_id
}

output "eks_sg" {
  value = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}
