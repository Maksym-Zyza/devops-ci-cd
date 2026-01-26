variable "ecr_name" {
  description = "Ім'я ECR репозиторію"
  type        = string
}

variable "scan_on_push" {
  description = "Чи вмикати сканування образу на вразливості після пушу"
  type        = bool
  default     = true # Значення за замовчуванням, якщо не передано інше
}
