#==============================================================================================================
# KUBERNETES RESOURCES - NAMESPACE
#==============================================================================================================
resource "kubernetes_namespace" "loki" {
  count      = (var.enabled && var.create_namespace && var.namespace != "kube-system") ? 1 : 0

  metadata {
    name = var.namespace
  }
}
#==============================================================================================================
# HELM CHART - LOKI
#==============================================================================================================
locals {
  default_set_values = {
    "nodeSelector.kube/nodetype" = var.node_selector
    "backend.terminationGracePeriodSeconds" = 30
  }
}

resource "helm_release" "loki" {
  depends_on = [kubernetes_namespace.loki]
  name             = "loki"
  chart            = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  version          = "5.10.0"
  namespace        = var.create_namespace ? var.namespace : "loki-system"
  timeout          = 500

  dynamic "set" {
    for_each = try({ for key, value in local.default_set_values : key => value }, {})
    content {
      name  = set.key
      value = set.value
    }
  }

#  values = [
#    file("${path.module}/manifests/loki.yaml")
#  ]
}
