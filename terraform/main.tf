terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "cs-skin-go"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Buscar AMI mais recente do Ubuntu 22.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Par de chaves SSH
resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-deployer-key"
  public_key = file(var.ssh_public_key_path)

  tags = {
    Name = "${var.project_name}-deployer-key"
  }
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.app_sg.id]
  
  # Volume raiz
  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name = "${var.project_name}-root-volume"
    }
  }

  # User data para instalação inicial básica
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y python3 python3-pip
              EOF

  tags = {
    Name = "${var.project_name}-app-server"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP (IP fixo)
resource "aws_eip" "app_eip" {
  instance = aws_instance.app_server.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-eip"
  }

  depends_on = [aws_instance.app_server]
}

# Gerar arquivo de inventário do Ansible
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    app_server_ip = aws_eip.app_eip.public_ip
    ssh_user      = var.ssh_user
    ssh_key_path  = var.ssh_private_key_path
    backend_repo  = var.backend_repo
    frontend_repo = var.frontend_repo
    git_branch    = var.git_branch
  })
  
  filename        = "${path.module}/../ansible/inventory.ini"
  file_permission = "0644"
}

# Aguardar a instância ficar pronta
resource "null_resource" "wait_for_instance" {
  depends_on = [aws_instance.app_server, aws_eip.app_eip]

  provisioner "local-exec" {
    command = "sleep 30"
  }
}

