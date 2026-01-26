# devops-ci-cd

#### Опис структури проєкту.

```bash
lesson-5/
│
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB)
├── outputs.tf               # Загальне виведення ресурсів
│
├── modules/                 # Каталог з усіма модулями
│   │
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   │   ├── s3.tf            # Створення S3-бакета
│   │   ├── dynamodb.tf      # Створення DynamoDB
│   │   ├── variables.tf     # Змінні для S3
│   │   └── outputs.tf       # Виведення інформації про S3 та DynamoDB
│   │
│   ├── vpc/                 # Модуль для VPC
│   │   ├── vpc.tf           # Створення VPC, підмереж, Internet Gateway
│   │   ├── routes.tf        # Налаштування маршрутизації
│   │   ├── variables.tf     # Змінні для VPC
│   │   └── outputs.tf       # Виведення інформації про VPC
│   │
│   └── ecr/                 # Модуль для ECR
│       ├── ecr.tf           # Створення ECR репозиторію
│       ├── variables.tf     # Змінні для ECR
│       └── outputs.tf       # Виведення URL репозиторію ECR
│
└── README.md                # Документація проєкту

```

#### Команди для ініціалізації та запуску:
```bash
terraform init
terraform plan
terraform apply
terraform destroy
```


#### Пояснення кожного модуля: s3-backend, vpc, ecr.


![alt text](assets/s3-backend.png)

###### Backend configuration (S3 + DynamoDB)
**backend.tf**

Створіть файл backend.tf у кореневій папці lesson-4.

Цей файл вказує Terraform:

- де зберігати state-файл (Amazon S3)

- як виконувати блокування стану для запобігання паралельним змінам (DynamoDB)

```bash
⚠️ Важливо:
S3-бакет і DynamoDB-таблиця вже створені.
Надалі Terraform буде автоматично зберігати та оновлювати state у цих ресурсах.
```

```bash
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-001001" # Назва S3-бакета
    key            = "lesson-4/terraform.tfstate"    # Шлях до файлу state
    region         = "us-west-2"                     # Регіон AWS
    dynamodb_table = "terraform-locks"               # DynamoDB для state locking
    encrypt        = true                            # Шифрування state-файлу
  }
}
```

###### Ініціалізація Terraform

Після створення backend.tf виконайте повторну ініціалізацію:

```bash
terraform init
```

State-файл з’явився в S3-бакеті та почав використовуватися як remote backend.

![alt text](assets/terraform-state-s3.png)

