# DevOps CI/CD: Jenkins, Argo CD, EKS, Terraform

Цей проект реалізує повний цикл **CI/CD** (Continuous Integration / Continuous Delivery) та **GitOps** підходів для розгортання Django-застосунку в Kubernetes (EKS). 

Інфраструктура керується через **Terraform**, збірка та доставка артефактів — через **Jenkins**, а синхронізація стану кластера — через **Argo CD**.

---

## 📋 Завдання проєкту

1.  **Автоматизація інфраструктури (IaC):** Розгортання EKS, ECR, VPC, Jenkins та Argo CD за допомогою Terraform.
2.  **Continuous Integration (CI):** 
    *   Автоматична збірка Docker-образу Django-застосунку.
    *   Публікація образу в Amazon ECR.
3.  **Continuous Delivery (CD) / GitOps:**
    *   Автоматичне оновлення версії образу (тегу) у Helm-чарті (в Git-репозиторії).
    *   Argo CD автоматично помічає зміни в Git та синхронізує стан кластера (Deployments, Services, ConfigMaps).
4.  **Бази даних:** Розгортання універсального модуля RDS з підтримкою Aurora та Standard RDS.

---

## 🏗 Архітектура та Технології

*   **Cloud Provider:** AWS (EKS, ECR, VPC, S3, DynamoDB, IAM, RDS/Aurora).
*   **Infrastructure as Code:** Terraform.
*   **CI Server:** Jenkins (Running on K8s, using Kubernetes Agent & Kaniko for Docker builds).
*   **CD / GitOps:** Argo CD (App of Apps pattern).
*   **Package Manager:** Helm.
*   **Application:** Python Django.

---

## 📂 Структура проєкту

```bash
Project/
│
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB)
├── outputs.tf               # Загальні виводи ресурсів
│
├── modules/                 # Каталог з усіма модулями
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
│   │   └── outputs.tf  
│   ├── ecr/                 # Модуль для ECR
│   │   ├── ecr.tf           # Створення ECR репозиторію
│   │   ├── variables.tf     # Змінні для ECR
│   │   └── outputs.tf       # Виведення URL репозиторію
│   │
│   ├── eks/                      # Модуль для Kubernetes кластера
│   │   ├── eks.tf                # Створення кластера
│   │   ├── aws_ebs_csi_driver.tf # Встановлення плагіну csi drive
│   │   ├── variables.tf     # Змінні для EKS
│   │   └── outputs.tf       # Виведення інформації про кластер
│   │
│   ├── rds/                 # Модуль для RDS (Universal: RDS + Aurora)
│   │   ├── rds.tf           # Створення RDS бази даних  
│   │   ├── aurora.tf        # Створення aurora кластера бази даних  
│   │   ├── shared.tf        # Спільні ресурси (SG, Subnet Group, PG)
│   │   ├── variables.tf     # Змінні з описами та дефолтами
│   │   └── outputs.tf       # Ендпоінти та порти
│   │ 
│   ├── jenkins/             # Модуль для Helm-установки Jenkins
│   │   ├── jenkins.tf       # Helm release для Jenkins
│   │   ├── variables.tf     # Змінні (ресурси, креденшели, values)
│   │   ├── providers.tf     # Оголошення провайдерів
│   │   ├── values.yaml      # Конфігурація jenkins
│   │   └── outputs.tf       # Виводи (URL, пароль адміністратора)
│   │ 
│   └── argo_cd/             # Mодуль для Helm-установки Argo CD
│       ├── jenkins.tf       # Helm release для Jenkins
│       ├── variables.tf     # Змінні (версія чарта, namespace, repo URL тощо)
│       ├── providers.tf     # Kubernetes+Helm.  переносимо з модуля jenkins
│       ├── values.yaml      # Кастомна конфігурація Argo CD
│       ├── outputs.tf       # Виводи (hostname, initial admin password)
│                   └──charts/                  # Helm-чарт для створення app'ів
│                   ├── Chart.yaml
│                   ├── values.yaml          # Список applications, repositories
│                           └── templates/
│                       ├── application.yaml
│                       └── repository.yaml
├── charts/
│   └── django-app/
│       ├── templates/
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   ├── configmap.yaml
│       │   └── hpa.yaml
│       ├── Chart.yaml
│       └── values.yaml     # ConfigMap зі змінними середовища
```

---

## 💾 Модуль RDS

Універсальний модуль `rds` дозволяє створювати як звичайні RDS інстанси, так і Aurora кластери через змінну `use_aurora`.

### Приклади використання

#### 1. Standard RDS (PostgreSQL)
```hcl
module "rds" {
  source = "./modules/rds"
  name   = "myapp-db"
  use_aurora = false
  
  engine         = "postgres"
  engine_version = "14.20"
  instance_class = "db.t3.micro"
  
  db_name  = "myapp"
  username = "postgres"
  password = "adminpassword"
  
  vpc_id             = module.vpc.vpc_id
  subnet_private_ids = module.vpc.private_subnets
  subnet_public_ids  = module.vpc.public_subnets
}
```

#### 2. Aurora Cluster
```hcl
module "rds" {
  source = "./modules/rds"
  name   = "myapp-aurora"
  use_aurora = true
  
  engine_cluster         = "aurora-postgresql"
  engine_version_cluster = "15.15"
  instance_class         = "db.t3.medium"
  
  db_name  = "myapp"
  username = "postgres"
  password = "adminpassword"
  
  vpc_id             = module.vpc.vpc_id
  subnet_private_ids = module.vpc.private_subnets
}
```

![alt text](db_aurora.png)

### Основні змінні
*   `use_aurora`: Перемикач між RDS (`false`) та Aurora (`true`).
*   `parameters`: Map параметрів для Parameter Group (напр. `max_connections`).
*   `publicly_accessible`: Керує доступом та вибором підмереж (public/private).
*   `aurora_replica_count`: Кількість реплік для Aurora.


