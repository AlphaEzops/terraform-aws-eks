#==============================================================================================================
# KUBERNETES RESOURCES - NAMESPACE
#==============================================================================================================
resource "kubernetes_namespace" "prometheus" {
  count      = (var.enabled && var.create_namespace && var.namespace != "kube-system") ? 1 : 0

  metadata {
    name = var.namespace
  }
}
#==============================================================================================================
# HELM CHART - PROMETHEUS
#==============================================================================================================
resource "helm_release" "prometheus" {
  depends_on = [kubernetes_namespace.prometheus]

  name             = "prometheus"
  chart            = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  version          = "23.1.0"
  namespace        = var.create_namespace ? var.namespace : "prometheus"

  values = [
    file("${path.module}/manifests/prometheus.yaml")
  ]
}