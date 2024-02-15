apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: ${PROJECT_NAME}
  namespace: ${ARGO_NAMESPACE}
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  description: ${PROJECT_DESCRIPTION}
  sourceRepos:
    - '*'
  destinations:
    - namespace: "*"
      server: https://kubernetes.default.svc
      name: in-cluster
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
  namespaceResourceBlacklist:
    - group: ''
      kind: ResourceQuota
    - group: ''
      kind: LimitRange
    - group: ''
      kind: NetworkPolicy
  namespaceResourceWhitelist:
    - group: '*'
      kind: '*'
  orphanedResources:
    warn: false