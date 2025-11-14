# Security Group para a aplicação
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-app-sg"
  description = "Security group para a aplicacao CS Skin GO"

  tags = {
    Name = "${var.project_name}-app-sg"
  }
}

# Regras de ingress (entrada)

# SSH (porta 22) - IPv4
resource "aws_vpc_security_group_ingress_rule" "ssh_ipv4" {
  security_group_id = aws_security_group.app_sg.id
  description       = "SSH access IPv4"
  
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"  # Permitir de qualquer lugar por enquanto

  tags = {
    Name = "ssh-access-ipv4"
  }
}

# HTTP (porta 80)
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.app_sg.id
  description       = "HTTP access"
  
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = var.allowed_http_cidr[0]

  tags = {
    Name = "http-access"
  }
}

# HTTPS (porta 443)
resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.app_sg.id
  description       = "HTTPS access"
  
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = var.allowed_http_cidr[0]

  tags = {
    Name = "https-access"
  }
}

# Backend API (porta 3001) - Apenas para debug, em produção use apenas Nginx
resource "aws_vpc_security_group_ingress_rule" "backend" {
  security_group_id = aws_security_group.app_sg.id
  description       = "Backend API direct access (debug only)"
  
  from_port   = var.backend_port
  to_port     = var.backend_port
  ip_protocol = "tcp"
  cidr_ipv4   = var.allowed_http_cidr[0]

  tags = {
    Name = "backend-debug-access"
  }
}

# Frontend (porta 3000) - Apenas para debug
resource "aws_vpc_security_group_ingress_rule" "frontend" {
  security_group_id = aws_security_group.app_sg.id
  description       = "Frontend direct access (debug only)"
  
  from_port   = var.frontend_port
  to_port     = var.frontend_port
  ip_protocol = "tcp"
  cidr_ipv4   = var.allowed_http_cidr[0]

  tags = {
    Name = "frontend-debug-access"
  }
}

# Regras de egress (saída)

# Permitir todo tráfego de saída
resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.app_sg.id
  description       = "Allow all outbound traffic"
  
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "all-outbound"
  }
}

