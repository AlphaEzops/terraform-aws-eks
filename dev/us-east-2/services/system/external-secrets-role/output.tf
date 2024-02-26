output "service_account_role_arn" {
  description = "Service account role arn"
  value       = aws_iam_role.eks_secrets_role.arn
}