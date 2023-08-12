#==============================================================================================================
# KUBERNETES RESOURCES - NAMESPACE
#==============================================================================================================
resource "kubernetes_namespace_v1" "metrics_server" {
  count = (var.enabled && var.create_namespace && var.namespace != "kube-system") ? 1 : 0

  metadata {
    name = var.namespace
  }
}
#==============================================================================================================
# HELM CHART - METRIC SERVER
#==============================================================================================================
locals {
  default_set_values = {
    "serviceAccount.create"      = "true"
    "metrics.enabled"            = "true"
    "rbac.create"                = "true"
    "nodeSelector.kube/nodetype" = "system-services"
  }
}
resource "helm_release" "metrics_server" {
  depends_on = [kubernetes_namespace_v1.metrics_server]
  name         = "metrics-server"
  repository   = "https://kubernetes-sigs.github.io/metrics-server/"
  chart        = "metrics-server"
  version      = "3.10.0"
  force_update = false
  namespace    = var.create_namespace ? var.namespace : "metric-server"
  timeout      = 200

  dynamic "set" {
    for_each = try({ for key, value in local.default_set_values : key => value }, {})
    content {
      name  = set.key
      value = set.value
    }
  }
}