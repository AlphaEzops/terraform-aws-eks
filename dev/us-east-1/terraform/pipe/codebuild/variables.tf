
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