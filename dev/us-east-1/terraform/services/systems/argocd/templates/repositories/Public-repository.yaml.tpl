apiVersion: v1
kind: Secret
metadata:
  name: ${APP_NAME}
  namespace: ${ARGO_NAMESPACE}
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  url: ${PUBLIC_REPO_URL}