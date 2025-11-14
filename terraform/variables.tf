variable "aws_region" {
  description = "Região da AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente de deploy (dev, staging, production)"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "cs-skin-go"
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t2.micro" # Free tier eligible
}

variable "root_volume_size" {
  description = "Tamanho do volume raiz em GB"
  type        = number
  default     = 20
}

variable "ssh_public_key_path" {
  description = "Caminho para a chave pública SSH"
  type        = string
  default     = "../.ssh/id_rsa.pub"
}

variable "ssh_private_key_path" {
  description = "Caminho para a chave privada SSH"
  type        = string
  default     = "../.ssh/id_rsa"
}

variable "ssh_user" {
  description = "Usuário SSH para conexão"
  type        = string
  default     = "ubuntu"
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks permitidos para acesso SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"] # ATENÇÃO: Mude isso para seu IP específico em produção!
}

variable "allowed_http_cidr" {
  description = "CIDR blocks permitidos para acesso HTTP/HTTPS"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Variáveis da aplicação
variable "app_domain" {
  description = "Domínio da aplicação (opcional)"
  type        = string
  default     = ""
}

variable "backend_port" {
  description = "Porta do backend"
  type        = number
  default     = 3001
}

variable "frontend_port" {
  description = "Porta do frontend"
  type        = number
  default     = 3000
}

variable "jwt_secret" {
  description = "Secret do JWT (use uma variável de ambiente ou secrets manager)"
  type        = string
  sensitive   = true
  default     = "change-me-in-production-use-env-var-32-chars-minimum"
}

variable "mysql_root_password" {
  description = "Senha root do MySQL"
  type        = string
  sensitive   = true
  default     = "change-me-strong-password-123"
}

variable "mysql_database" {
  description = "Nome do banco de dados MySQL"
  type        = string
  default     = "cs_skin_go"
}

variable "mysql_user" {
  description = "Usuário do MySQL"
  type        = string
  default     = "cs_user"
}

variable "mysql_password" {
  description = "Senha do usuário MySQL"
  type        = string
  sensitive   = true
  default     = "change-me-user-password-456"
}

# Repositórios
variable "backend_repo" {
  description = "Repositório do backend"
  type        = string
  default     = "" # Deixe vazio para usar cópia local
}

variable "frontend_repo" {
  description = "Repositório do frontend"
  type        = string
  default     = "" # Deixe vazio para usar cópia local
}

variable "git_branch" {
  description = "Branch do git para deploy"
  type        = string
  default     = "main"
}

