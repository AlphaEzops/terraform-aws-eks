
variable "project_name" {
  type        = string
  description = "Project name"
  default = "demo"
}

variable "stage" {
  type = string //
  description = "environment"
  default = "default"
}

variable "prefix" {
  type = string
  description = "Prefix name"
  default = "devops"
}

variable "iam_role_arn" {
    type = string
    description = "IAM role"
}