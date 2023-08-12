module "ebs_csi_driver" {
  source = "./k8s-ebs-csi-drive"
  cluster_name = var.cluster_name
}

module "metric_server" {
  source = "./metric-server"
}


#module "cert_manager" {
#  source = "./cert-manager"
#  cluster_name = var.cluster_name
#}

#module "metric_server" {
#  source = "./metric-server"
#}
#
#module "ingress_nginx" {
#  source = "./nginx"
#}
#
#module "jenkins" {
#  source = "./jenkins"
#}
#
#module "prometheus" {
#  source = "./prometheus"
#}
#
#module "loki" {
#  source = "./loki"
#}
#
#module "promtail" {
#  source = "./promtail"
#}
#
#module "grafana" {
#    source = "./grafana"
#}
#
#

