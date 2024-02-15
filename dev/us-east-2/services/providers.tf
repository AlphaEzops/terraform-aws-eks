provider "kubernetes" {
  host                   = try(data.aws_eks_cluster.cluster_info.endpoint, null)
  token                  = try(base64decode(data.aws_eks_cluster_auth.cluster_auth.token), null)
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster_info.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", try(data.aws_eks_cluster.cluster_info.id, null)]
  }
}

provider "helm" {
  kubernetes {
    host                   = try(data.aws_eks_cluster.cluster_info.endpoint, null)
    token                  = try(base64decode(data.aws_eks_cluster_auth.cluster_auth.token), null)
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster_info.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", try(data.aws_eks_cluster.cluster_info.id, null)]
      command     = "aws"
    }
  }
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster_info.endpoint
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster_info.certificate_authority[0].data)
}