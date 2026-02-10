variable "github_pat" {
  description = "GitHub Personal Access Token for Jenkins"
  type        = string
  sensitive   = true
}

provider "aws" {
  region = "us-west-2"
}

# Підключаємо модуль S3 та DynamoDB
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "terraform-state-bucket-001234"
  table_name  = "terraform-locks"
}

# Підключаємо модуль VPC
module "vpc" {
  source              = "./modules/vpc"                                       # Шлях до модуля VPC
  vpc_cidr_block      = "10.0.0.0/16"                                         # CIDR блок для VPC
  public_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]         # Публічні підмережі
  private_subnets     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]         # Приватні підмережі
  availability_zones  = ["us-west-2a", "us-west-2b", "us-west-2c"]            # Зони доступності
  vpc_name            = "vpc"                                                 # Ім'я VPC
}

module "ecr" {
  source          = "./modules/ecr"   # Шлях до модуля
  repository_name = "django-app"        # Назва репозиторію
  environment     = "dev"             # Середовище
  scan_on_push    = true              # Cканування на вразливості після пушу    
}

module "eks" {
  source          = "./modules/eks"          
  cluster_name    = "eks-cluster-demo"            # Назва кластера
  subnet_ids      = module.vpc.public_subnets     # ID підмереж
  instance_type   = "t3.medium"                   # Тип інстансів
  desired_size    = 2                             # Бажана кількість нодів
  max_size        = 3                             # Максимальна кількість нодів
  min_size        = 1                             # Мінімальна кількість нодів
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
}

module "jenkins" {
  source              = "./modules/jenkins"
  cluster_name        = module.eks.cluster_name
  oidc_provider_arn   = module.eks.oidc_provider_arn
  oidc_provider_url   = module.eks.oidc_provider_url
  github_pat          = var.github_pat
  ecr_repository_url  = module.ecr.repository_url

  providers = {
    helm       = helm
    kubernetes = kubernetes
    aws        = aws
  }
}
    
module "argo_cd" {
  source        = "./modules/argo_cd"
  name          = "argo-cd"
  namespace     = "argocd"
  chart_version = "5.46.4"
  github_pat    = var.github_pat

  providers = {
    helm       = helm
    kubernetes = kubernetes
    aws        = aws
  }
}

# RDS (Aurora / Standard)
module "rds" {
  source = "./modules/rds"

  name = "myapp-db"

  # --- Перемикач: Aurora / Standard RDS ---
  use_aurora = true

  # --- Конфігурація Aurora (використовується, коли use_aurora = true) ---
  engine_cluster                = "aurora-postgresql"
  engine_version_cluster        = "15.15"
  parameter_group_family_aurora = "aurora-postgresql15"
  aurora_replica_count          = 1 # 1 Reader + 1 Writer = 2 Instances

  # --- Конфігурація Standard RDS ---
  engine                     = "postgres"
  engine_version             = "14.7"
  parameter_group_family_rds = "postgres14"
  allocated_storage          = 20

  # --- Спільні параметри ---
  instance_class          = "db.t3.medium" 
  db_name                 = "myapp"
  username                = "postgres"
  password                = "admin123AWS23"
  vpc_id                  = module.vpc.vpc_id
  subnet_private_ids      = module.vpc.private_subnets
  subnet_public_ids       = module.vpc.public_subnets
  publicly_accessible     = true
  multi_az                = true
  backup_retention_period = 7

  # Параметри для Parameter Group (працюють для обох типів)
  parameters = {
    max_connections            = "200"
    log_min_duration_statement = "500"
    work_mem                   = "16384" # 16MB in kB
  }

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
