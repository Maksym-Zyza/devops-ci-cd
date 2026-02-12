# Subnet group (used by both)
resource "aws_db_subnet_group" "default" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.publicly_accessible ? var.subnet_public_ids : var.subnet_private_ids
  tags       = var.tags
}

# Security group (used by both)
resource "aws_security_group" "rds" {
  name        = "${var.name}-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  # Rule for CIDR blocks (e.g. VPN, local IP)
  dynamic "ingress" {
    for_each = length(var.allowed_cidr_blocks) > 0 ? [1] : []
    content {
      from_port   = var.port
      to_port     = var.port
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
    }
  }

  # Rule for other Security Groups (e.g. EKS nodes, Bastion)
  dynamic "ingress" {
    for_each = length(var.allowed_security_groups) > 0 ? [1] : []
    content {
      from_port       = var.port
      to_port         = var.port
      protocol        = "tcp"
      security_groups = var.allowed_security_groups
    }
  }

  # Default rule: Allow access from VPC CIDR (Optional - consider removing for strict security)
  # For now, let's keep it safe by NOT allowing 0.0.0.0/0 by default unless explicitly passed in allowed_cidr_blocks.

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
