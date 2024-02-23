data "aws_caller_identity" "this" {}
data "aws_partition" "this" {}
data "aws_eks_cluster" "reveal-cluster" {
  name = "reveal-cluster"
}

data "aws_secretsmanager_secret" "secret_reveal" {
 name = "prod/reveal/taxonomy-service"
}

data "aws_secretsmanager_secret_version" "secret_reveal" {
 secret_id = data.aws_secretsmanager_secret.secret_reveal.id
}


# SINGLE QUOTE ON CONNECTIONSTRINGS.VMDB TO ESCAPE STRINGS AUTOMATICALLY 
locals {
  region = "us-east-2"
  service_account_name = var.service_account_name
  application_namespace = var.application_namespace
  setting_json = jsonencode(<<EOT
    {
      "ConnectionStrings": {
        "VMDB": "Data Source=sql-server-backup-development.sql-server-backup.svc.cluster.local,1433;Initial Catalog=UAT_ENT_VMDB;Persist Security Info=True;User ID=sa;Password=password123@;Encrypt=false"
      },
      "Logging": {
        "LogLevel": {
          "Default": "Information",
          "Microsoft.AspNetCore": "Warning"
        }
      },
      "AllowedHosts": "*",
      "Serilog": {
        "Using": [ "Serilog.Sinks.File", "Serilog.Sinks.Console" ],
        "MinimumLevel": {
          "Default": "Information",
          "Override": {
            "Microsoft": "Warning",
            "System": "Warning"
          }
        },
        "WriteTo": [
          {
            "Name": "Console"
          },
          {
            "Name": "File",
            "Args": {
              "path": "/logs/Taxonomycore/log-.txt",
              "rollOnFileSizeLimit": true,
              "formatter": "Serilog.Formatting.Compact.CompactJsonFormatter,Serilog.Formatting.Compact",
              "rollingInterval": "Day"
            }
          }
        ],
        "Enrich": [ "FromLogContext", "WithThreadId", "WithMachineName" ]
      },
      "Tokens": {
        "Key": "IxrAjDoa2FqEl3RIhrSrUJELhUckePEPVpaePlS_Poa",
        "Issuer": "VerticalAuthority",
        "Audience": "Everyone"
      },
      "SecurityKeys": {
        "EncyKey": "VDev@2016",
        "DefaultPasswordKey": "VerticalPassword#123"
      },
      "WebSocketSetting": {
        "KeepAliveInterval": 120,
        "BufferSize": 4,
        "DefaultBuffer": 1024,
        "TimeOut": 3600000
      },
      "SwaggerSettings": {
        "Version": "V1",
        "Title": "Taxonomy Service"
      },
      "redis": {
        "host": "127.0.0.1",
        "name": "localhost",
        "port": 6379,
        "expiry": 24 
      },
      "Environment": "dev",
      "Origion": "*",
      "Service": "TaxonomyService"
    }
EOT  
)
}

# -------------------------------------------------------------------
# External Secrets Role/Policy
# -------------------------------------------------------------------

data "aws_iam_policy_document" "eks_external_secrets_access_policy" {
  statement {
    sid    = "AllowUseOfTheKey"
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "eks_external_secrets_access_policy" {
  name        = "taxonomy_service-${local.region}-eks-external-secrets-kms-access-irsa"
  description = "External Secrets access policy for EKS"
  policy      = data.aws_iam_policy_document.eks_external_secrets_access_policy.json
}


# -------------------------------------------------------------------
# Lilg-ui Secrets Reader/Writer Role/Policy
# -------------------------------------------------------------------

data "aws_iam_policy_document" "eks_taxonomy_service_secrets_access_policy" {
  statement {
    sid = "Statement1"
    actions = [
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:GetSecretValue",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:DescribeSecret",
      "secretsmanager:PutSecretValue",
      "secretsmanager:CreateSecret",
      "secretsmanager:DeleteSecret",
      "secretsmanager:RotateSecret",
      "secretsmanager:UpdateSecret",
      "secretsmanager:TagResource",
    ]
    effect = "Allow"
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "eks_taxonomy_service_secrets_access_policy" {
  name        = "taxonomy_service-${local.region}-secrets-access-policy-irsa"
  description = "taxonomy_service ReadWrite access policy for EKS"
  policy      = data.aws_iam_policy_document.eks_taxonomy_service_secrets_access_policy.json
}

data "aws_iam_policy_document" "ligl_ui_secrets_assume_role_policy" {
  statement {
    sid     = "Statement1"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test = "StringEquals"
      values = [
        "system:serviceaccount:${local.application_namespace}:${local.service_account_name}",
      ]
      variable = "${replace(data.aws_eks_cluster.reveal-cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"
    }
    condition {
      test = "StringEquals"
      values = [
        "sts.amazonaws.com"
      ]
      variable = "${replace(data.aws_eks_cluster.reveal-cluster.identity[0].oidc[0].issuer, "https://", "")}:aud"
    }
    principals {
      type = "Federated"
      identifiers = [
        "arn:${data.aws_partition.this.partition}:iam::${data.aws_caller_identity.this.account_id}:oidc-provider/${replace(data.aws_eks_cluster.reveal-cluster.identity[0].oidc[0].issuer, "https://", "")}",
      ]
    }
  }
}

resource "aws_iam_role" "eks_taxonomy_service_secrets_role" {
  name               = "taxonomy_service-${local.region}-eks-secrets-role-irsa"
  assume_role_policy = data.aws_iam_policy_document.ligl_ui_secrets_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_taxonomy_service_secrets_access_policy" {
  role       = aws_iam_role.eks_taxonomy_service_secrets_role.name
  policy_arn = aws_iam_policy.eks_taxonomy_service_secrets_access_policy.arn
}

# Secrets reader user needs to be able to read KMS for secrets
resource "aws_iam_role_policy_attachment" "eks_taxonomy_service_secrets_kms_access_policy" {
  role       = aws_iam_role.eks_taxonomy_service_secrets_role.name
  policy_arn = aws_iam_policy.eks_external_secrets_access_policy.arn
}





#==============================================================================================================
# APPLICATION - TAXONOMY SERVICE
#==============================================================================================================


resource "kubectl_manifest" "taxonomy_service" {

  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  labels:
    argocd.argoproj.io/instance: app-of-apps
  name: ${local.application_namespace}-development
  namespace: argocd-system
spec:
  destination:
    namespace: ${local.application_namespace}
    server: 'https://kubernetes.default.svc'
  project: default
  source:
    helm:
      valueFiles:
        - values.yaml
      parameters:
        - name: "secrets.externalSecrets.serviceAccount.name"
          value: ${local.service_account_name}
        - name: "secrets.externalSecrets.serviceAccount.arn"
          value: ${aws_iam_role.eks_taxonomy_service_secrets_role.arn}
        - name: "global.namespace"
          value: ${local.application_namespace}
        - name: "application.resources.requests.cpu"
          value: "100m"
        - name: "application.resources.requests.memory"
          value: "100m"
        - name: "configMap.configuration"
          value: ${local.setting_json}
    path: dev/us-east-2/services/apps/taxonomy-service
    repoURL: 'git@github.com:AlphaEzops/reveal-eks.git'
    targetRevision: HEAD
  syncPolicy:
    automated:
      allowEmpty: false
      prune: false
      selfHeal: true
    retry:
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m0s
      limit: 5
    syncOptions:
      - CreateNamespace=true
      - PruneLast=true
YAML
}
