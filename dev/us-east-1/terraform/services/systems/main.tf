module "ebs_csi_driver" {
  source       = "./k8s-ebs-csi-drive"
  cluster_name = var.cluster_name
}

module "argo_cd" {
  depends_on = [module.ebs_csi_driver]
  source     = "./argocd"

}
#module "ingress_nginx" {
#  source = "./nginx"
#}

#module "prometheus" {
#  depends_on = [module.ebs_csi_driver]
#  source = "./prometheus"
#}

#module "loki" {
#  depends_on = [module.ebs_csi_driver]
#  source = "./loki"
#}

#module "cert_manager" {
#  depends_on = [module.ingress_nginx]
#  source = "./cert-manager"
#}

#module "jenkins" {
#  depends_on = [module.ingress_nginx]
#  source = "./jenkins"
#}

#module "grafana" {
#  depends_on = [module.ingress_nginx]
#  source = "./grafana"
#}

#module "promtail" {
#  source = "./promtail"
#}


