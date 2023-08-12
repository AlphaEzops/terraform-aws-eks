output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "database_subnet_group" {
  description = "The name of the database subnet group"
  value       = module.vpc.database_subnet_group
}

output "database_subnet_group_name" {
  description = "The name of the database subnet group name"
  value       = module.vpc.database_subnet_group_name
}
