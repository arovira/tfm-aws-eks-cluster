resource "aws_iam_instance_profile" "instance-profile" {
  name = "${var.cluster_name}-instance-profile"
  role = aws_iam_role.master.name
}

resource "aws_iam_role" "master" {
  name = "${var.cluster_name}-iam-master-role"
  tags = {
    "Name" = "${var.cluster_name}-iam-master-role"
  }
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.master.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.master.name
}
