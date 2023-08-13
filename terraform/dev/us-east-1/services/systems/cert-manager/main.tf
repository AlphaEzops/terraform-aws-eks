data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
}

#==============================================================================================================
# KUBERNETES RESOURCES - NAMESPACE
#==============================================================================================================
resource "kubernetes_namespace" "cert_manager" {
  depends_on = [var.mod_dependency]
  count      = (var.enabled && var.create_namespace && var.namespace != "kube-system") ? 1 : 0

  metadata {
    name = var.namespace
  }
}
#==============================================================================================================
# HELM CHART - CERT MANAGER
#==============================================================================================================
locals {
  default_set_values = {
#    "serviceAccount.create"                                     = true
#    "securityContext.fsGroup.enabled"                           = true
    "installCRDs"                                               = var.install_crd
#    "serviceAccount.name"                                       = var.service_account_name
#    "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = aws_iam_role.kubernetes_cert_manager[0].arn
#    "securityContext.fsGroup"                                   = 1001
  }
}

resource "helm_release" "cert_manager" {
  depends_on = [var.mod_dependency, kubernetes_namespace.cert_manager]
  count      = var.enabled ? 1 : 0
  name       = var.helm_chart_name
  chart      = var.helm_chart_release_name
  repository = var.helm_chart_repo
  version    = var.helm_chart_version
  namespace  = var.create_namespace ? var.namespace : "cert-manager-system"

  dynamic "set" {
    for_each = try({ for key, value in local.default_set_values : key => value }, {})
    content {
      name  = set.key
      value = set.value
    }
  }

  dynamic "set" {
    for_each = try({ for key, value in var.set_values.values : key => value }, {})
    content {
      name  = set.key
      value = set.value
    }
  }
}
##==============================================================================================================
## KUBECTL MANIFEST - CLUSTER ISSUER
##==============================================================================================================
resource "kubectl_manifest" "cluster_issuer" {
  depends_on = [helm_release.cert_manager]
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: "letsencrypt-prod"
spec:
  acme:
    server: "https://acme-v02.api.letsencrypt.org/directory"
    email: "arthuracs18@gmail.com"
    privateKeySecretRef:
      name: "santos-ops"
    solvers:
      - http01:
          ingress:
            class: nginx
YAML
}
