output "value" {
  value = jsondecode(data.aws_secretsmanager_secret_version.secret_reveal.secret_string)["GATEWAY"]
}