locals {
  exec_args = [
    "--region",
    "us-east-1",
    "eks",
    "get-token",
    "--cluster-name",
    module.eks.cluster_id
  ]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.13.0"

  name = var.cluster_name
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "karpenter.sh/discovery"                    = var.cluster_name
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "<18"

  cluster_version = "1.21"
  cluster_name    = var.cluster_name
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.private_subnets
  enable_irsa     = true

  # Only need one node to get Karpenter up and running
  worker_groups = [
    {
      instance_type = "t3a.medium"
      asg_max_size  = 1
    }
  ]

  tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }
}

module "karpenter" {
  source                  = "./.."
  cluster_endpoint        = module.eks.cluster_endpoint
  cluster_name            = module.eks.cluster_id
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  worker_iam_role_name    = module.eks.worker_iam_role_name
}

data "aws_eks_cluster_auth" "default" {
  name = module.eks.cluster_id
}

provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.default.token

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args        = local.exec_args
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.default.token

    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      command     = "aws"
      args        = local.exec_args
    }
  }
}
