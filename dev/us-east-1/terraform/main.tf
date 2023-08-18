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

#module "ci-cd" {
#  source = "./pipe/codebuild"
#  prefix =
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

module "services" {
  count        = var.enable_services && var.enable_cluster && var.enable_network ? 1 : 0
  depends_on   = [module.cluster, module.network]
  source       = "./services/systems"
  cluster_name = var.cluster_name
}
