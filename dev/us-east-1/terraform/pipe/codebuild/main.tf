#===================================================================================================
# IAM ROLE
#===================================================================================================
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "inline_policy" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = format("%s-%s-%s", var.prefix, var.stage, var.project_name)
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  inline_policy {
    name   = "policy-8675309"
    policy = data.aws_iam_policy_document.inline_policy.json
  }
}

#===================================================================================================
# CODEBUILD
#===================================================================================================
data "aws_ssm_parameter" "github_token" {
  name = "/DEV/GH_TOKEN"
}
resource "aws_codebuild_project" "codebuild" {
  name           = format("%s-%s-%s", var.prefix, var.stage, var.project_name)
  description    = "AWS CodeBuild for the app ${var.project_name}"
  build_timeout  = "5"
  queued_timeout = "5"
  service_role   = aws_iam_role.codebuild_role.arn
  #  resource_access_role = var.iam_role_arn

  artifacts {
    type = "NO_ARTIFACTS"

  }

  environment {
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = "true"
    compute_type                = "BUILD_GENERAL1_SMALL"

    environment_variable {
      name  = "STAGE"
      value = var.stage
    }
    environment_variable {
      name  = "GH_TOKEN"
      value = data.aws_ssm_parameter.github_token.value
    }
  }

  source {
    type      = "NO_SOURCE"
    buildspec = file("${path.module}/buildspec.yaml")
  }

  logs_config {
    cloudwatch_logs {
      status     = "ENABLED"
      group_name = aws_cloudwatch_log_group.app.name
    }
  }

  tags = {
    Environment = var.stage
  }
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/codebuild/${var.stage}-codebuild"
  retention_in_days = 7

  tags = {
    Environment = var.stage
  }
}