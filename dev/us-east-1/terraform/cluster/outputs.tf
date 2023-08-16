output "eks_cluster_id" {
  description = "EKS cluster name"
  value       = module.eks_cluster.cluster_id
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks_cluster.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoints"
  value       = module.eks_cluster.cluster_endpoint
}

output "eks_cluster_token" {
  description = "EKS cluster token"
  value       = data.aws_eks_cluster_auth.eks_cluster.token
}

output "eks_cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data"
  value       = base64decode(module.eks_cluster.cluster_certificate_authority_data)
}

output "eks_cluster_identity_oidc_issuer_url" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = module.eks_cluster.oidc_provider
}

output "eks_cluster_oidc_provider_arn" {
  description = "EKS cluster oidc provider arn"
  value       = module.eks_cluster.oidc_provider_arn
}

output "eks_apps_codepipeline_codebuild_iam_role_arn" {
  description = "Amazon Resource Name (ARN) of the AWS IAM Role of the AWS resources, AWS CodePipeline and AWS CodeBuild, for the EKS Cluster and the Apps"
  value       = aws_iam_role.eks_apps_codepipeline_codebuild.arn
}

output "eks_managed_node_groups" {
  description = "EKS managed node groups"
  value       = module.eks_cluster.eks_managed_node_groups
}
