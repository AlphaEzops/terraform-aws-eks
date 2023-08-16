#==============================================================================================================
# KUBERNETES RESOURCES - NAMESPACE
#==============================================================================================================
resource "kubernetes_namespace" "promtail" {
  count      = (var.enabled && var.create_namespace && var.namespace != "kube-system") ? 1 : 0

  metadata {
    name = var.namespace
  }
}
#==============================================================================================================
# HELM CHART - PROMTAIL
#==============================================================================================================
resource "helm_release" "promtail" {
  depends_on = [kubernetes_namespace.promtail]
  name             = "promtail"
  chart            = "promtail"
  repository       = "https://grafana.github.io/helm-charts"
  version          = "6.14.1"
  namespace        = var.create_namespace ? var.namespace : "promtail-system"

#  values = [
#    file("${path.module}/manifests/promtail.yaml")
#  ]
}