data "aws_partition" "this" {}
data "aws_caller_identity" "this" {}

module "network" {
  source       = "./network"
  count        = var.enable_network ? 1 : 0
  cluster_name = var.cluster_name
  network_name = var.network_name
  stage        = var.stage
}

module "cluster" {
  source             = "./cluster"
  count              = var.enable_cluster && var.enable_network ? 1 : 0
  vpc_id             = module.network[0].vpc_id
  private_subnet_ids = module.network[0].private_subnet_ids
  project            = var.project
  stage              = var.stage
  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  instance_type      = var.instance_type
  aws_auth_users     = var.aws_auth_users
}

module "external_secret" {
  source = "./external_secrets"
  eks = module.cluster[0]
}


# data "aws_iam_policy_document" "ligl_ui_assume_role_policy" {
#   statement {
#     sid     = "Statement1"
#     effect  = "Allow"
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     condition {
#       test = "StringLike"
#       values = [
#         "system:serviceaccount:ligl-ui:ligl-ui"
#       ]
#       variable = "${module.cluster[0].eks_cluster_identity_oidc_issuer_url}:sub"
#     }
#     principals {
#       type = "Federated"
#       identifiers = [
#         "arn:${data.aws_partition.this.partition}:iam::${data.aws_caller_identity.this.account_id}:oidc-provider/${module.cluster[0].eks_cluster_identity_oidc_issuer_url}",
#       ]
#     }
#   }
# }

# resource "aws_iam_role" "ligl_ui_role" {
#   name               = "ligl-ui-role-sa"
#   assume_role_policy = data.aws_iam_policy_document.ligl_ui_assume_role_policy.json
# }

#module "ci-cd" {
#  source = "./pipe/codebuild"
#  iam_role_arn = module.cluster[0].eks_apps_codepipeline_codebuild_iam_role_arn
#  prefix = "devops"
#  project_name = "python-app"
#  stage = var.stage
#}

#module "ecr" {
#  source               = "./pipe/ecr"
#  image_tag_mutability = "MUTABLE"
#  scan_on_push         = true
#  prefix               = "devops"
#  project_name         = "python-app"
#  stage                = var.stage
#}

#module "services" {
#  source       = ".."
#  count        = var.enable_services && var.enable_cluster && var.enable_network ? 1 : 0
#  project_name = "reveal"
#  cluster_name = var.cluster_name
#
#  depends_on   = [module.cluster, module.network]
#}
