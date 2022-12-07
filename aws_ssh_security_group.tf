resource "aws_security_group" "ssh-access" {
  name        = "${var.cluster_name}-ssh-access-sg"
  description = "Allow ssh on eks cluster nodes"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH into ${var.cluster_name} EKS cluster nodes"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpn_settings["cidr"]]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"           = "${var.cluster_name}-ssh-access-sg"
    "bs/description" = "SSH into ${var.cluster_name} cluster EKS nodes"
  }
}
