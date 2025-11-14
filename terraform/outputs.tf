output "instance_id" {
  description = "ID da instância EC2"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "IP público da instância EC2"
  value       = aws_eip.app_eip.public_ip
}

output "instance_public_dns" {
  description = "DNS público da instância EC2"
  value       = aws_instance.app_server.public_dns
}

output "ssh_connection_string" {
  description = "String de conexão SSH"
  value       = "ssh -i ${var.ssh_private_key_path} ${var.ssh_user}@${aws_eip.app_eip.public_ip}"
}

output "frontend_url" {
  description = "URL do frontend"
  value       = "http://${aws_eip.app_eip.public_ip}"
}

output "backend_url" {
  description = "URL do backend"
  value       = "http://${aws_eip.app_eip.public_ip}/api"
}

output "security_group_id" {
  description = "ID do Security Group"
  value       = aws_security_group.app_sg.id
}

output "ansible_inventory_path" {
  description = "Caminho do arquivo de inventário do Ansible"
  value       = abspath("${path.module}/../ansible/inventory.ini")
}

output "estimated_monthly_cost" {
  description = "Custo mensal estimado (USD)"
  value       = "~$8.50/mês (t2.micro) - FREE no primeiro ano com AWS Free Tier"
}

