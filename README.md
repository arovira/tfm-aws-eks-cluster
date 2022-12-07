# Module Name

### External Documentation

Documentation regarding EKS (including EKS managed node group, self managed node group, and Fargate profile) and/or Kubernetes features, usage, etc. are better left up to their respective sources:
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)

### General

* Description: Terraform module to create an EKS cluster with VPN setup
* Created By: arovira

### Usage

* Terraform (basic example):

```hcl
####################
#
# Providers
#
####################
provider "aws" {
  region  = var.region
  profile = var.profile

  default_tags {
    tags = local.common_tags
  }
}
provider "aws" {
  alias   = "vpn"
  region  = local.vpn_settings["aws_region"]
  profile = local.vpn_settings["aws_profile"]

  default_tags {
    tags = local.common_tags
  }
}

####################
#
# Local Variables
#
####################
locals {
  cluster_name             = "cluster-name"
  k8s_version              = "1.24"
  vpc_cidr_block           = "10.0.0.0/16"

  eks_node_pools = [
    {
      name           = "eks-cluster-default-node-group"
      k8s_version    = local.k8s_version
      min_nodes      = 3
      max_nodes      = 6
      capacity_type  = "SPOT"
      disk_size      = 100
      instance_types = ["c5d.2xlarge", "c6i.2xlarge", "c6a.2xlarge", "c5a.2xlarge", "inf1.2xlarge", "c5.2xlarge", "c5ad.2xlarge"]
      shared_tags    = local.common_tags
      additional_tags = {
        "k8s.io/cluster-autoscaler/node-template/label/workloadType" = "normal"
      }

    },
    {
      name           = "eks-cluster-secondary-node-group"
      k8s_version    = local.k8s_version
      min_nodes      = 3
      max_nodes      = 6
      capacity_type  = "SPOT"
      disk_size      = 100
      instance_types = ["i2.2xlarge", "i3.2xlarge", "i3en.2xlarge", "r3.2xlarge", "r4.2xlarge", "r5.2xlarge", "r5a.2xlarge", "r5ad.2xlarge", "r5b.2xlarge", "r5d.2xlarge", "r5dn.2xlarge", "r5n.2xlarge", "r6i.2xlarge", "z1d.2xlarge"]
      shared_tags    = local.common_tags
      additional_tags = {
        "k8s.io/cluster-autoscaler/node-template/label/workloadType" = "secondary"
      }
    }
  ]

  vpn_settings = {
    name                   = "vpn"
    vpc_id                 = "vpc-xxxxxxx"
    cidr                   = "172.0.0.0/24"
    aws_profile            = "vpn-profile"
    aws_account_id         = "111111111111"
    aws_region             = "us-east-1"
    public_route_table_id  = "rtb-xxxxxxx"
    private_route_table_id = "rtb-xxxxxxx"
  }

  common_tags = {
    "department" = "engineering"
  }
}

####################
#
# EKS Cluster
#
####################
module "eks_cluster" {
  source           = "git::git@github.com:arovira/tfm-aws-eks-cluster.git"
  cluster_name     = local.cluster_name
  k8s_version      = local.k8s_version
  ec2_ssh_key_name = "${local.cluster_name}-ssh-key"

  # VPC config
  vpc_cidr_block           = local.vpc_cidr_block
  vpn_settings             = local.vpn_settings
  eks_node_pools           = local.eks_node_pools

  providers = {
    aws        = aws
    aws.vpn    = aws.vpn
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.20.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.20.0 |
| <a name="provider_aws.vpn"></a> [aws.vpn](#provider\_aws.vpn) | >= 4.20.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group_tag.additional_asg_additional_tags](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group_tag) | resource |
| [aws_autoscaling_group_tag.additional_asg_shared_tags](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group_tag) | resource |
| [aws_autoscaling_group_tag.asg_name_tag](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group_tag) | resource |
| [aws_autoscaling_group_tag.default_asg_additional_tags](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group_tag) | resource |
| [aws_autoscaling_group_tag.default_asg_shared_tags](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group_tag) | resource |
| [aws_db_subnet_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_default_route_table.private-route-table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eks_cluster.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_node_group.node_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_instance_profile.instance-profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.master](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.node_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.AmazonEKSClusterPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.AmazonEKSServicePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_internet_gateway.ig](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_key_pair.cluster_ssh_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_kms_alias.cluster_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.cluster_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_nat_gateway.gw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.vpc-vpn-private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.vpc-vpn-public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.vpn-vpc-private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.vpn-vpc-public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.public-route-table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.public-route-table-assoc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ssh-access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.vpn_to_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_subnet.aws_svc_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_peering_connection.vpn_peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource |
| [aws_vpc_peering_connection_accepter.vpn_peer_accepter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter) | resource |
| [tls_private_key.ssh_tls_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of Kubernetes cluster | `string` | n/a | yes |
| <a name="input_ec2_ssh_key_name"></a> [ec2\_ssh\_key\_name](#input\_ec2\_ssh\_key\_name) | SSH Key used to access Kubernetes worker nodes | `string` | `"eks-default-ssh-key"` | no |
| <a name="input_eks_node_pools"></a> [eks\_node\_pools](#input\_eks\_node\_pools) | EKS managed node groups to create | <pre>list(object({<br>    name            = string<br>    k8s_version     = string<br>    min_nodes       = number<br>    max_nodes       = number<br>    capacity_type   = string<br>    disk_size       = number<br>    instance_types  = list(string)<br>    shared_tags     = map(string)<br>    additional_tags = map(string)<br>  }))</pre> | n/a | yes |
| <a name="input_k8s_version"></a> [k8s\_version](#input\_k8s\_version) | Kubernetes version to use | `string` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | CIDR block associated wth new VPC | `string` | n/a | yes |
| <a name="input_vpc_private_subnet_count"></a> [vpc\_private\_subnet\_count](#input\_vpc\_private\_subnet\_count) | Number of private subnets associated with vpc | `number` | `3` | no |
| <a name="input_vpc_public_subnet_count"></a> [vpc\_public\_subnet\_count](#input\_vpc\_public\_subnet\_count) | Number of public subnets associated with vpc | `number` | `5` | no |
| <a name="input_vpc_svc_subnet_count"></a> [vpc\_svc\_subnet\_count](#input\_vpc\_svc\_subnet\_count) | Number of subnets for AWS services associated with vpc | `number` | `4` | no |
| <a name="input_vpn_settings"></a> [vpn\_settings](#input\_vpn\_settings) | Settings to connect VPN with the EKS cluster | <pre>object({<br>    name                   = string<br>    vpc_id                 = string<br>    cidr                   = string<br>    aws_profile            = string<br>    aws_account_id         = string<br>    public_route_table_id  = string<br>    private_route_table_id = string<br>  })</pre> | n/a | yes |
| <a name="input_worker_sg_rules"></a> [worker\_sg\_rules](#input\_worker\_sg\_rules) | Additional rules to apply to EKS worker nodes | <pre>map(object({<br>    type             = string<br>    description      = string<br>    from_port        = number<br>    to_port          = number<br>    protocol         = string<br>    cidr_blocks      = list(string)<br>    ipv6_cidr_blocks = list(string)<br>    prefix_list_ids  = list(string)<br>    }<br>  ))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_subnet_group_name"></a> [db\_subnet\_group\_name](#output\_db\_subnet\_group\_name) | n/a |
| <a name="output_eks_sg"></a> [eks\_sg](#output\_eks\_sg) | n/a |
| <a name="output_private_route_table_id"></a> [private\_route\_table\_id](#output\_private\_route\_table\_id) | n/a |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | n/a |
| <a name="output_public_route_table_id"></a> [public\_route\_table\_id](#output\_public\_route\_table\_id) | n/a |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
