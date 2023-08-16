provider "kubernetes" {
#  version = "2.22.0"
  host                   = try(module.cluster[0].eks_cluster_endpoint, null)
  token                  = try(module.cluster[0].eks_cluster_token, null)
  cluster_ca_certificate = try(module.cluster[0].eks_cluster_certificate_authority_data, null)
}

provider "helm" {
#  version = "2.10.1"
  kubernetes {
    host                   = try(module.cluster[0].eks_cluster_endpoint, null)
    token                  = try(module.cluster[0].eks_cluster_token, null)
    cluster_ca_certificate = try(module.cluster[0].eks_cluster_certificate_authority_data, null)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", try(module.cluster[0].eks_cluster_name, null)]
      command     = "aws"
    }
  }
}

provider "kubectl" {
  host                   = try(module.cluster[0].eks_cluster_endpoint, null)
  token                  = try(module.cluster[0].eks_cluster_token, null)
  cluster_ca_certificate = try(module.cluster[0].eks_cluster_certificate_authority_data, null)
}