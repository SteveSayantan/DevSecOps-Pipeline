module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "demo"
  kubernetes_version = "1.36"

  
  # Optional
  endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  compute_config = {
    enabled    = false
  }

  # creation of cluster IAM role is automatically handled by this module, as `create_iam_role` is set to true, by default. This role allows the control plane to manage AWS resources on our behalf.

  # creation of node IAM role is also handled by this module, as `create_node_iam_role` is set to true by default. This role is crucial as the worker nodes (EC2 instances) must have secure, authorized permission to make AWS API calls on our behalf to communicate with the EKS control plane and manage underlying AWS resources.

  # The default value of `authentication_mode` is `"API_AND_CONFIG_MAP"`, hence, EKS will automatically create an access entry for the IAM role(s) used by managed node group(s). This cluster identity directly links an AWS IAM principal (user or role) to an EKS cluster. It dictates which AWS identities are allowed to authenticate and interact with our Kubernetes cluster.

  vpc_id     = module.vpc.vpc_id

  subnet_ids = module.vpc.private_subnet_ids

  # EKS automatically creates a cluster security group on cluster creation to facilitate communication between worker nodes and control plane. Here, we shall use that.
  create_node_security_group = false

  # To disable cloudwatch log group creation and logging
  create_cloudwatch_log_group = false
  enabled_log_types = []

  eks_managed_node_groups = {
    mng_primary = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      instance_types = ["t3.medium"]
      attach_cluster_primary_security_group = true
      create_security_group = false
      min_size     = 2
      max_size     = 3
      desired_size = 2
    }
  }

   addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
    }
  }

  access_entries = {
    eks_developer = {
      principal_arn = aws_iam_role.this.arn

      # associating our identity (role/user) with the policy
      policy_associations = {
        eks_edit = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

}

module "vpc" {
  source= "./modules/vpc-with-igw"
  vpc_name= "terraform-vpc"
  vpc_cidr= "10.23.0.0/22"

  subnet_config= [
      {
          name="private-a",
          cidr_block="10.23.3.0/26",
          availability_zone="us-east-1a"
      },
      {
          name="private-b",
          cidr_block="10.23.3.64/26",
          availability_zone="us-east-1b"
      },
      {
          name="public-a",
          cidr_block="10.23.3.128/27",
          is_public=true,
          availability_zone="us-east-1a"
      },
      {
          name="public-b",
          cidr_block="10.23.3.160/27",
          is_public=true,
          availability_zone="us-east-1b"
      }
  ]
}