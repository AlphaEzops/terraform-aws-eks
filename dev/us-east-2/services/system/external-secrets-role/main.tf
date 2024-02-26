data "aws_caller_identity" "this" {}
data "aws_partition" "this" {}
data "aws_eks_cluster" "reveal-cluster" {
  name = "reveal-cluster"
}

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
  name        = "${local.application_namespace}-${local.region}-eks-external-secrets-kms-access-irsa"
  description = "External Secrets access policy for EKS"
  policy      = data.aws_iam_policy_document.eks_external_secrets_access_policy.json
}


# -------------------------------------------------------------------
# Secrets Reader/Writer Role/Policy
# -------------------------------------------------------------------

data "aws_iam_policy_document" "eks_secrets_access_policy" {
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

resource "aws_iam_policy" "eks_secrets_access_policy" {
  name        = "${local.application_namespace}-${local.region}-secrets-access-policy-irsa"
  description = "${local.application_namespace} ReadWrite access policy for EKS"
  policy      = data.aws_iam_policy_document.eks_secrets_access_policy.json
}

data "aws_iam_policy_document" "secrets_assume_role_policy" {
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

resource "aws_iam_role" "eks_secrets_role" {
  name               = "${local.application_namespace}-${local.region}-eks-secrets-role-irsa"
  assume_role_policy = data.aws_iam_policy_document.secrets_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_secrets_access_policy" {
  role       = aws_iam_role.eks_secrets_role.name
  policy_arn = aws_iam_policy.eks_secrets_access_policy.arn
}

# Secrets reader user needs to be able to read KMS for secrets
resource "aws_iam_role_policy_attachment" "eks_secrets_kms_access_policy" {
  role       = aws_iam_role.eks_secrets_role.name
  policy_arn = aws_iam_policy.eks_external_secrets_access_policy.arn
}
