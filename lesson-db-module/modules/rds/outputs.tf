output "cluster_endpoint" {
  description = "The cluster endpoint for Aurora"
  value       = try(aws_rds_cluster.aurora[0].endpoint, "")
}

output "cluster_reader_endpoint" {
  description = "The cluster reader endpoint for Aurora"
  value       = try(aws_rds_cluster.aurora[0].reader_endpoint, "")
}

output "instance_endpoint" {
  description = "The connection endpoint for the standard RDS instance"
  value       = try(aws_db_instance.standard[0].endpoint, "")
}

output "endpoint" {
  description = "The connection endpoint (Standard or Aurora Writer)"
  value       = var.use_aurora ? try(aws_rds_cluster.aurora[0].endpoint, "") : try(aws_db_instance.standard[0].endpoint, "")
}

output "port" {
  description = "The database port"
  value       = var.use_aurora ? try(aws_rds_cluster.aurora[0].port, "") : try(aws_db_instance.standard[0].port, "")
}

output "database_name" {
  description = "The database name"
  value       = var.db_name
}

output "master_username" {
  description = "The master username"
  value       = var.username
}
