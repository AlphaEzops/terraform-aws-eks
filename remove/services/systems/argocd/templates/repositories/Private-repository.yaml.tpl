apiVersion: v1
kind: Secret
metadata:
  name: $APP_NAME
  namespace: $ARGO_NAMESPACE
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  url: $PRIVATE_REPO_URL
  sshPrivateKey: |
    $SSH_PRIVATE_KEY
  insecure: "true"
  enableLfs: "true"