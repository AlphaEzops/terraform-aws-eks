variable "stage" {
  type        = string
  description = "environment"
  default = "default"
}

variable "prefix" {
  type = string
  description = "ECR prefix"
  default = "devops"
}

variable "project_name" {
  type = string
  description = "ECR prefix"
  default = "demo"
}

variable "image_tag_mutability" {
  type = string
  description = "Image tag Mutability"
  default = "MUTABLE"
}

variable "scan_on_push" {
  type = bool
  description = "Scan image"
  default = true
}