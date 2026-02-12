variable "name" {
  description = "Name of the RDS instance or Aurora cluster"
  type        = string
}

variable "use_aurora" {
  description = "Boolean to control whether to deploy Aurora (true) or Standard RDS (false)"
  type        = bool
  default     = false
}

variable "engine" {
  description = "The database engine for Standard RDS (e.g., postgres, mysql)"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "The engine version for Standard RDS"
  type        = string
  default     = "14.20"
}

variable "engine_cluster" {
  description = "The database engine for Aurora Cluster (e.g., aurora-postgresql, aurora-mysql)"
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_version_cluster" {
  description = "The engine version for Aurora Cluster"
  type        = string
  default     = "15.15"
}

variable "instance_class" {
  description = "The instance class (e.g., db.t3.micro for RDS, db.t3.medium for Aurora)"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "The allocated storage in GB (Standard RDS only)"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "The name of the database to create"
  type        = string
}

variable "username" {
  description = "Username for the master DB user"
  type        = string
}

variable "password" {
  description = "Password for the master DB user"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "The VPC ID where resources will be created"
  type        = string
}

variable "subnet_private_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "subnet_public_ids" {
  description = "List of public subnet IDs (used if publicly_accessible is true)"
  type        = list(string)
}

variable "publicly_accessible" {
  description = "Whether the DB should be publicly accessible"
  type        = bool
  default     = false
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  type        = number
  default     = 7
}

variable "parameters" {
  description = "A map of DB parameters to apply to the parameter group (e.g., max_connections, work_mem)"
  type        = map(string)
  default     = {}
}

variable "parameter_group_family_rds" {
  description = "The family of the DB parameter group for Standard RDS (e.g., postgres14)"
  type        = string
  default     = "postgres14"
}

variable "parameter_group_family_aurora" {
  description = "The family of the DB parameter group for Aurora (e.g., aurora-postgresql15)"
  type        = string
  default     = "aurora-postgresql15"
}

variable "aurora_instance_count" {
  description = "Number of instances in the Aurora cluster (1 writer + N readers)"
  type        = number
  default     = 2
}

variable "aurora_replica_count" {
  description = "Number of reader replicas for Aurora (variable used in logic, though aurora_instance_count is usually preferred for total count)"
  type        = number
  default     = 1
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}

variable "port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the DB"
  type        = list(string)
  default     = []
}

variable "allowed_security_groups" {
  description = "List of Security Group IDs allowed to access the DB"
  type        = list(string)
  default     = []
}