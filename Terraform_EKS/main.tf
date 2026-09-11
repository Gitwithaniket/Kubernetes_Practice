terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# ============================================================
# AWS PROVIDER
# ============================================================

provider "aws" {
  region = "us-east-1"
}

# ============================================================
# AVAILABLE AVAILABILITY ZONES
# ============================================================

data "aws_availability_zones" "available" {
  state = "available"
}

# ============================================================
# VPC
# ============================================================

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "kubernetes-practice-vpc"

  cidr = "10.0.0.0/16"

  azs = slice(
    data.aws_availability_zones.available.names,
    0,
    3
  )

  # ==========================================================
  # PRIVATE SUBNETS
  # ==========================================================

  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]

  # ==========================================================
  # PUBLIC SUBNETS
  # ==========================================================

  public_subnets = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24"
  ]

  # ==========================================================
  # NAT GATEWAY
  # ==========================================================

  enable_nat_gateway = true
  single_nat_gateway = true

  # ==========================================================
  # DNS
  # ==========================================================

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "kubernetes-practice-vpc"
    Environment = "dev"
    Terraform   = "true"
  }
}

# ============================================================
# EKS CLUSTER
# ============================================================

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  # ==========================================================
  # CLUSTER
  # ==========================================================

  name               = "kubernetes-practice"
  kubernetes_version = "1.34"

  # ==========================================================
  # NETWORKING
  # ==========================================================

  vpc_id = module.vpc.vpc_id

  subnet_ids = module.vpc.private_subnets

  # ==========================================================
  # API ENDPOINT
  # ==========================================================

  endpoint_public_access = true

  # ==========================================================
  # ADMIN ACCESS
  # ==========================================================

  enable_cluster_creator_admin_permissions = true

  # ==========================================================
  # MANAGED NODE GROUP
  # ==========================================================

  eks_managed_node_groups = {
    kubernetes_nodes = {
      name = "k8s-nodes"

      instance_types = ["t3.small"]

      min_size     = 1
      desired_size = 2
      max_size     = 3
    }
  }


  # ==========================================================
  # EKS TAGS
  # ==========================================================

  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "Kubernetes-Practice"
  }
}

# ============================================================
# OUTPUTS
# ============================================================

output "cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_status" {
  description = "EKS Cluster Status"
  value       = module.eks.cluster_status
}

output "cluster_version" {
  description = "EKS Kubernetes Version"
  value       = module.eks.cluster_version
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private Subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public Subnet IDs"
  value       = module.vpc.public_subnets
}