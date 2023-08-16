apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${APP_NAME}
  namespace: ${ARGO_NAMESPACE}
spec:
  destination:
    namespace: ${APP_NAMESPACE}
    server: https://kubernetes.default.svc
  source:
    path: ${APP_PATH}
    repoURL: ${APP_REPO_URL}
    targetRevision: ${APP_TARGET_REVISION}
    directory:
      recurse: ${APP_DIRECTORY_RECURSE}
      jsonnet:
        tlas: []
  sources: []
  project: ${APP_PROJECT}
  syncPolicy:
    managedNamespaceMetadata:
      labels:
        managed: 'argo-cd'
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true