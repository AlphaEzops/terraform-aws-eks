data "aws_secretsmanager_secret" "secret_reveal" {
 name = "prod/reveal/ligl-ui"
}

data "aws_secretsmanager_secret_version" "secret_reveal" {
 secret_id = data.aws_secretsmanager_secret.secret_reveal.id
}