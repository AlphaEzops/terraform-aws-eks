output "service_account_role_arn" {
  description = "Service account role arn"
  value       = aws_iam_role.ligl_ui_role.arn
}