#==============================================================================================================
# KUBERNETES RESOURCES - NAMESPACE
#==============================================================================================================
resource "kubernetes_namespace" "jenkins" {
  count      = (var.enabled && var.create_namespace && var.namespace != "kube-system") ? 1 : 0

  metadata {
    name = var.namespace
  }
}
#==============================================================================================================
# HELM CHART - JENKINS
#==============================================================================================================
locals {
  default_set_values = {
    "nodeSelector.kube/nodetype" = var.node_selector
  }
}

resource "helm_release" "jenkins" {
  depends_on = [kubernetes_namespace.jenkins]
  name             = "jenkins"
  chart            = "jenkins"
  repository       = "https://charts.jenkins.io"
  version          = "4.5.0"
  namespace        = var.create_namespace ? var.namespace : "jenkins-system"

  dynamic "set" {
    for_each = try({ for key, value in local.default_set_values : key => value }, {})
    content {
      name  = set.key
      value = set.value
    }
  }

  values = [
    file("${path.module}/manifests/jenkins.yaml")
  ]
}
