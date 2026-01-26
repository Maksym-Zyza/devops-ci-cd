output "repository_url" {
  description = "URL створеного репозиторію (потрібен для docker push)"
  value       = aws_ecr_repository.main.repository_url
}

output "repository_arn" {
  description = "ARN репозиторію"
  value       = aws_ecr_repository.main.arn
}

output "registry_id" {
  description = "ID реєстру"
  value       = aws_ecr_repository.main.registry_id
}
