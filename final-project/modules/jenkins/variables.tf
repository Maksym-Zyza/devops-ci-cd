variable "cluster_name" {
  description = "Назва Kubernetes кластера"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC provider for the EKS cluster."
  type        = string
}

variable "oidc_provider_url" {
  description = "The URL of the OIDC provider for the EKS cluster."
  type        = string
}

variable "github_pat" {
  description = "GitHub Personal Access Token for Jenkins"
  type        = string
  sensitive   = true
}

variable "ecr_repository_url" {
  description = "The URL of the ECR repository"
  type        = string
}
