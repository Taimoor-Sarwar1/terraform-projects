variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "tf-eks-demo"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_access_cidrs" {
  description = "Allowed CIDRs for the public API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"] # open for demo, restrict later!
}

variable "key_name" {
  description = "EC2 Key pair name (optional, for SSH to worker nodes)"
  type        = string
  default     = ""
}
