data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.id
  tags = {
    Terraform   = "true"
    Environment = var.stage
  }
  aws_auth_users = [
    for user in var.aws_auth_users :
    {
      userarn  = "arn:aws:iam::${local.account_id}:user/${user.username}"
      username = user.username
      groups   = user.groups
    }
  ]
}

#==============================================================================
# AWS IAM ROLE
#==============================================================================
resource "aws_iam_role" "eks_apps_codepipeline_codebuild" {
  name               = "${var.stage}-${var.project}-apps-codepipeline-codebuild-iam-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codepipeline.amazonaws.com",
          "codebuild.amazonaws.com"
          ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = merge(var.tags.iam_role, local.tags)
}
resource "aws_iam_role_policy" "eks_apps_codepipeline_codebuild" {
  name = "${var.stage}-${var.project}-apps-codepipeline-codebuild-iam-policy"
  role = aws_iam_role.eks_apps_codepipeline_codebuild.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:*",
        "codestar-connections:*",
        "logs:*",
        "ecr:*",
        "eks:*",
        "lambda:*",
        "s3:*",
        "sns:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}
#==============================================================================
# AWS LAUNCH TEMPLATE
#==============================================================================
resource "aws_launch_template" "eks_cluster" {
  name_prefix            = "${var.cluster_name}-launch-template"
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 64
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }
  monitoring {
    enabled = true
  }
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [module.eks_cluster.node_security_group_id]
  }

  # Supplying custom tags to EKS instances is another use-case for LaunchTemplates
  tag_specifications {
    resource_type = "instance"
    tags          = local.tags
  }

  # Supplying custom tags to EKS instances root volumes is another use-case for LaunchTemplates. (doesnt add tags to dynamically provisioned volumes via PVC)
  tag_specifications {
    resource_type = "volume"
    tags          = local.tags
  }

  # Supplying custom tags to EKS instances ENI's is another use-case for LaunchTemplates
  tag_specifications {
    resource_type = "network-interface"
    tags          = local.tags
  }

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}
#==============================================================================
# EKS CLUSTER
#==============================================================================
module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  create_cloudwatch_log_group     = true
  manage_aws_auth_configmap       = true
  enable_irsa                     = true

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  aws_auth_users = local.aws_auth_users
  aws_auth_roles = [
    {
      rolearn  = aws_iam_role.eks_apps_codepipeline_codebuild.arn
      username = aws_iam_role.eks_apps_codepipeline_codebuild.name
      groups   = ["system:masters"]
    }
  ]

  cluster_addons = {
    kube-proxy = {
      addon_name                  = "kube-proxy"
      addon_version               = "v1.27.4-eksbuild.2"
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    vpc-cni = {
      addon_name                  = "vpc-cni"
      addon_version               = "v1.13.4-eksbuild.1"
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
  }

  cluster_addons_timeouts = {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  eks_managed_node_groups = {
    system-services = {
      name                    = "system-services"
      min_size                = 1
      desired_size            = 2
      max_size                = 3
      create_launch_template  = false
      launch_template_id      = aws_launch_template.eks_cluster.id
      launch_template_version = aws_launch_template.eks_cluster.default_version
      ami_type                = "AL2_x86_64"
      instance_types          = ["t3.medium"]
      labels = {
        "kube/nodetype" = "system-services"
      }
    }

    backend = {
      name                    = "backend"
      min_size                = 1
      desired_size            = 2
      max_size                = 3
      create_launch_template  = false
      launch_template_id      = aws_launch_template.eks_cluster.id
      launch_template_version = aws_launch_template.eks_cluster.default_version
      ami_type                = "AL2_x86_64"
      instance_types          = ["t3.medium"]
      labels = {
        "kube/nodetype" = "backend"
      }
    }
  }

  tags = merge(var.tags.eks, local.tags)
}
#==============================================================================
# EKS ADDONS
#==============================================================================
resource "aws_eks_addon" "eks_cluster_addons" {
  for_each                    = { for addon in var.addons : addon.name => addon }
  cluster_name                = module.eks_cluster.cluster_name
  addon_name                  = each.value.name
  addon_version               = each.value.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  tags                        = merge(var.tags.eks_addon, local.tags)
}
#==============================================================================
# AWS DATA CLUSTER
#==============================================================================
data "aws_eks_cluster_auth" "eks_cluster" {
  depends_on = [module.eks_cluster.cluster_name]
  name = module.eks_cluster.cluster_name
}
