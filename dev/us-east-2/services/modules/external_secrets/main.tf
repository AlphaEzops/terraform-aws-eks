data "aws_caller_identity" "this" {}
data "aws_partition" "this" {}

locals {
  region = "us-east-2"
  application_namespace = var.application_namespace
  service_account_name = var.service_account_name
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
  name        = "ligl-ui-${local.region}-eks-external-secrets-kms-access-irsa"
  description = "External Secrets access policy for EKS"
  policy      = data.aws_iam_policy_document.eks_external_secrets_access_policy.json
}


# -------------------------------------------------------------------
# Lilg-ui Secrets Reader/Writer Role/Policy
# -------------------------------------------------------------------

data "aws_iam_policy_document" "eks_ligl_ui_secrets_access_policy" {
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

resource "aws_iam_policy" "eks_ligl_ui_secrets_access_policy" {
  name        = "ligl-ui-${local.region}-secrets-access-policy-irsa"
  description = "Ligl-ui ReadWrite access policy for EKS"
  policy      = data.aws_iam_policy_document.eks_ligl_ui_secrets_access_policy.json
}

data "aws_iam_policy_document" "ligl_ui_secrets_assume_role_policy" {
  statement {
    sid     = "Statement1"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test = "StringEquals"
      values = [
        "sts.serviceaccount:${local.application_namespace}:${local.service_account_name}"
      ]
      variable = "${var.eks_oidc_issuer}:sub"
    }
    principals {
      type = "Federated"
      identifiers = [
        "arn:${data.aws_partition.this.partition}:iam::${data.aws_caller_identity.this.account_id}:oidc-provider/${var.eks_oidc_issuer}",
      ]
    }
  }
}

resource "aws_iam_role" "eks_ligl_ui_secrets_role" {
  name               = "ligl-ui-${local.region}-eks-secrets-role-irsa"
  assume_role_policy = data.aws_iam_policy_document.ligl_ui_secrets_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_ligl_ui_secrets_access_policy" {
  role       = aws_iam_role.eks_ligl_ui_secrets_role.name
  policy_arn = aws_iam_policy.eks_ligl_ui_secrets_access_policy.arn
}

# Secrets reader user needs to be able to read KMS for secrets
resource "aws_iam_role_policy_attachment" "eks_ligl_ui_secrets_kms_access_policy" {
  role       = aws_iam_role.eks_ligl_ui_secrets_role.name
  policy_arn = aws_iam_policy.eks_external_secrets_access_policy.arn
}