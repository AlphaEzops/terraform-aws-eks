data "aws_caller_identity" "this" {}
data "aws_partition" "this" {}
data "aws_eks_cluster" "reveal-cluster" {
  name = "reveal-cluster"
}

# SINGLE QUOTE ON CONNECTIONSTRINGS.VMDB TO ESCAPE STRINGS AUTOMATICALLY 
locals {
  region = "us-east-2"
  application_namespace = var.application_namespace
  setting_json = jsonencode(<<EOT
    {
        "ConnectionStrings": {
            "VMDB": "Data Source=10.0.0.8\\OPTIMUM_DEV,58081;Initial Catalog=DEV_MASTER;Persist Security Info=True;User ID=DITUser;Password=OptimumDIT@Vertical123;Encrypt=false"
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
                        "path": "/logs/core/log-.txt",
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
            "Audience": "Everyone",
            "AccessTokenExpiry": 10,
            "RefreshTokenExpiry": 60
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
            "Title": "Notification Service"
        },
        "ConnectionStringSettings": {
            "MaxTryCount": 10,
            "MaxDelayTryInSeconds": 30
        },
        "redis": {
            "host": "127.0.0.1",
            "name": "localhost",
            "port": 6379,
            "expiry": 24 
        },
        "Environment": "dev",
        "Origion": "http://10.1.0.13:8081",
        "Service": "NotificationService"
    }
EOT  
)
}


#==============================================================================================================
# APPLICATION - NOTIFICATION SERVICE
#==============================================================================================================


resource "kubectl_manifest" "notification_service" {

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
        - name: "global.namespace"
          value: ${local.application_namespace}
        - name: "application.resources.requests.cpu"
          value: "100m"
        - name: "application.resources.requests.memory"
          value: "100m"
        - name: "configMap.configuration"
          value: ${local.setting_json}
    path: dev/us-east-2/services/apps/notification-service
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
