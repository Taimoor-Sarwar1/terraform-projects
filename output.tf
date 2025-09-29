############################################
# outputs.tf - EKS Cluster Outputs
############################################

# VPC ID
output "vpc_id" {
  description = "ID of the VPC created for EKS"
  value       = aws_vpc.eks_vpc.id
}

# Subnet IDs
output "subnet_ids" {
  description = "IDs of the public subnets used for EKS"
  value       = [aws_subnet.eks_subnet1.id, aws_subnet.eks_subnet2.id]
}

# EKS Cluster Name
output "eks_cluster_name" {
  description = "Name of the EKS Cluster"
  value       = aws_eks_cluster.eks_cluster.name
}

# EKS Cluster Endpoint
output "eks_cluster_endpoint" {
  description = "API server endpoint of the EKS Cluster"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

# EKS Cluster Certificate Authority
output "eks_cluster_certificate_authority" {
  description = "Certificate Authority data required for authenticating with the cluster"
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

# Node Group Name
output "eks_node_group_name" {
  description = "Name of the EKS Node Group"
  value       = aws_eks_node_group.eks_nodes.node_group_name
}
