# Створюємо ECR репозиторій
resource "aws_ecr_repository" "main" {
  name                 = var.ecr_name           # Ім'я репозиторію (передається через змінні)
  image_tag_mutability = "MUTABLE"              # Дозволяє перезаписувати теги (зручно для dev/staging)

  # Налаштування сканування на вразливості при завантаженні образу
  image_scanning_configuration {
    scan_on_push = var.scan_on_push             # true або false (передається через змінні)
  }

  # Дозволяє видалити репозиторій, навіть якщо в ньому є образи.
  # УВАГА: Для продакшну краще встановити false, щоб випадково не втратити дані.
  force_delete = true

  tags = {
    Name        = var.ecr_name
    Environment = "learning"
  }
}
