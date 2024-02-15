output "aws_ecr_repository_name" {
  description = "AWS ECR Repository name"
  value = aws_ecr_repository.this.name

}

output "aws_ecr_repository_arn" {
  description = "AWS ECR Repository arn"
  value =aws_ecr_repository.this.arn
}

output "aws_ecr_repository_url" {
  description = "AWS ECR Repository url"
  value = aws_ecr_repository.this.repository_url
}