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
  value       = var.frontend_domain != "" ? "http://${var.frontend_domain}" : "http://${aws_eip.app_eip.public_ip}"
}

output "backend_url" {
  description = "URL do backend"
  value       = var.backend_domain != "" ? "http://${var.backend_domain}" : "http://${aws_eip.app_eip.public_ip}/api"
}

output "frontend_domain" {
  description = "Domínio do frontend"
  value       = var.frontend_domain
}

output "backend_domain" {
  description = "Domínio da API"
  value       = var.backend_domain
}

output "dns_configuration" {
  description = "Configuração DNS necessária"
  value = <<-EOT
    Configure os seguintes registros DNS:
    
    Tipo A (Frontend):
    Nome: ia.daniloaparecido.com.br
    Valor: ${aws_eip.app_eip.public_ip}
    TTL: 3600
    
    Tipo A (Backend):
    Nome: api-ia.daniloaparecido.com.br
    Valor: ${aws_eip.app_eip.public_ip}
    TTL: 3600
    
    Após configurar o DNS, aguarde a propagação (pode levar até 48h).
  EOT
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

