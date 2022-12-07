###############################
## EKS Variables
###############################
variable "cluster_name" {
  description = "Name of Kubernetes cluster"
  type        = string
}
variable "k8s_version" {
  description = "Kubernetes version to use"
  type        = string
}
variable "ec2_ssh_key_name" {
  default     = "eks-default-ssh-key"
  description = "SSH Key used to access Kubernetes worker nodes"
  type        = string
}

###############################
## VPC Variables
###############################
variable "vpc_cidr_block" {
  description = "CIDR block associated wth new VPC"
  type        = string
}
variable "vpn_settings" {
  description = "Settings to connect VPN with the EKS cluster"
  type = object({
    name                   = string
    vpc_id                 = string
    cidr                   = string
    aws_profile            = string
    aws_account_id         = string
    public_route_table_id  = string
    private_route_table_id = string
  })
}
variable "vpc_private_subnet_count" {
  default     = 3
  description = "Number of private subnets associated with vpc"
  type        = number
}
variable "vpc_public_subnet_count" {
  default     = 5
  description = "Number of public subnets associated with vpc"
  type        = number
}
variable "vpc_svc_subnet_count" {
  default     = 4
  description = "Number of subnets for AWS services associated with vpc"
  type        = number
}

###############################
## Node Group Variables
###############################
variable "eks_node_pools" {
  description = "EKS managed node groups to create"
  type = list(object({
    name            = string
    k8s_version     = string
    min_nodes       = number
    max_nodes       = number
    capacity_type   = string
    disk_size       = number
    instance_types  = list(string)
    shared_tags     = map(string)
    additional_tags = map(string)
  }))
}
variable "worker_sg_rules" {
  description = "Additional rules to apply to EKS worker nodes"
  type = map(object({
    type             = string
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    prefix_list_ids  = list(string)
    }
  ))
  default = {}
}