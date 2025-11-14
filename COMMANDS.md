# 🔧 Comandos Úteis - CS Skin GO

Referência rápida de comandos para gerenciar a infraestrutura e aplicação.

## 🚀 Deploy

### Deploy Completo
```bash
cd infra
./scripts/deploy.sh
```

### Deploy Apenas Aplicação
```bash
cd infra/ansible
ansible-playbook playbook.yml --tags application
```

### Deploy Apenas Setup
```bash
cd infra/ansible
ansible-playbook playbook.yml --tags setup
```

## 🔍 Terraform

### Inicializar
```bash
cd infra/terraform
terraform init
```

### Ver Plano
```bash
terraform plan
```

### Aplicar Mudanças
```bash
terraform apply
```

### Ver Outputs
```bash
terraform output
terraform output instance_public_ip
terraform output frontend_url
```

### Destruir Tudo
```bash
terraform destroy
# Ou use o script:
cd ../
./scripts/destroy.sh
```

### Ver Estado
```bash
terraform show
terraform state list
```

## 🎭 Ansible

### Testar Conectividade
```bash
cd infra/ansible
ansible all -m ping
```

### Executar Playbook
```bash
ansible-playbook playbook.yml
```

### Executar com Tags
```bash
ansible-playbook playbook.yml --tags common
ansible-playbook playbook.yml --tags docker
ansible-playbook playbook.yml --tags nginx
ansible-playbook playbook.yml --tags application
```

### Dry Run (Sem Aplicar)
```bash
ansible-playbook playbook.yml --check
```

### Verbose Mode
```bash
ansible-playbook playbook.yml -v
ansible-playbook playbook.yml -vv
ansible-playbook playbook.yml -vvv
```

### Executar Comando Ad-Hoc
```bash
ansible all -a "uptime"
ansible all -a "df -h"
ansible all -a "free -m"
```

## 🐳 Docker (No Servidor)

### Acessar Servidor
```bash
ssh ubuntu@<IP_PUBLICO>
cd /opt/cs-skin-go
```

### Ver Containers
```bash
docker compose ps
docker ps
docker ps -a
```

### Ver Logs
```bash
# Todos
docker compose logs

# Com follow
docker compose logs -f

# Específico
docker compose logs backend
docker compose logs frontend
docker compose logs mysql

# Últimas linhas
docker compose logs --tail=100
```

### Restart
```bash
# Todos
docker compose restart

# Específico
docker compose restart backend
docker compose restart frontend
docker compose restart mysql
```

### Parar/Iniciar
```bash
# Parar todos
docker compose stop

# Iniciar todos
docker compose start

# Parar e remover
docker compose down

# Iniciar (recriar)
docker compose up -d
```

### Rebuild
```bash
# Rebuild e restart
docker compose up -d --build

# Rebuild específico
docker compose up -d --build backend
docker compose up -d --build frontend
```

### Executar Comando em Container
```bash
# Backend
docker compose exec backend npm run migration:run
docker compose exec backend npm run seed
docker compose exec backend npm run migration:revert

# MySQL
docker compose exec mysql mysql -u root -p
docker compose exec mysql mysqldump -u root -p cs_skin_go > backup.sql

# Shell
docker compose exec backend sh
docker compose exec frontend sh
docker compose exec mysql bash
```

### Ver Recursos
```bash
docker stats
docker compose top
```

### Limpar
```bash
# Remover containers parados
docker container prune

# Remover imagens não usadas
docker image prune

# Remover tudo não usado
docker system prune

# Remover TUDO (cuidado!)
docker system prune -a --volumes
```

## 🌐 Nginx

### Status
```bash
sudo systemctl status nginx
```

### Testar Configuração
```bash
sudo nginx -t
```

### Reload
```bash
sudo systemctl reload nginx
```

### Restart
```bash
sudo systemctl restart nginx
```

### Ver Logs
```bash
# Access logs
sudo tail -f /var/log/nginx/cs-skin-go_access.log
sudo tail -f /var/log/nginx/access.log

# Error logs
sudo tail -f /var/log/nginx/cs-skin-go_error.log
sudo tail -f /var/log/nginx/error.log

# Últimas 100 linhas
sudo tail -100 /var/log/nginx/cs-skin-go_error.log
```

### Ver Configuração
```bash
sudo cat /etc/nginx/sites-available/cs-skin-go
```

## 🗄️ MySQL

### Acessar MySQL
```bash
docker compose exec mysql mysql -u root -p
docker compose exec mysql mysql -u cs_user -p cs_skin_go
```

### Backup
```bash
# Dump completo
docker compose exec mysql mysqldump -u root -p cs_skin_go > backup_$(date +%Y%m%d_%H%M%S).sql

# Dump com gzip
docker compose exec mysql mysqldump -u root -p cs_skin_go | gzip > backup_$(date +%Y%m%d_%H%M%S).sql.gz
```

### Restore
```bash
# De arquivo
docker compose exec -T mysql mysql -u root -p cs_skin_go < backup.sql

# De gzip
gunzip < backup.sql.gz | docker compose exec -T mysql mysql -u root -p cs_skin_go
```

### Verificar Banco
```bash
docker compose exec mysql mysql -u root -p -e "SHOW DATABASES;"
docker compose exec mysql mysql -u root -p -e "USE cs_skin_go; SHOW TABLES;"
docker compose exec mysql mysql -u root -p -e "USE cs_skin_go; SELECT COUNT(*) FROM users;"
```

## 📊 Monitoramento

### Uso de Recursos
```bash
# CPU e Memória
top
htop

# Disco
df -h
du -sh /opt/cs-skin-go/*

# Memória
free -h

# Network
netstat -tulpn
ss -tulpn
```

### Verificar Portas
```bash
# Ver quem está usando porta
sudo lsof -i :80
sudo lsof -i :3000
sudo lsof -i :3001
sudo lsof -i :3306

# Ver todas portas em uso
sudo netstat -tulpn | grep LISTEN
```

### Health Checks
```bash
# Backend
curl http://localhost:3001/api/cases
curl http://localhost:3001/api/health

# Frontend
curl http://localhost:3000

# Via Nginx
curl http://localhost/api/cases
curl http://localhost/
```

## 🔄 Atualização

### Atualizar Aplicação
```bash
# Via script
cd infra
./scripts/update.sh

# Via Ansible
cd infra/ansible
ansible-playbook playbook.yml --tags application
```

### Atualizar Sistema
```bash
ssh ubuntu@<IP>
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
```

### Atualizar Docker Images
```bash
ssh ubuntu@<IP>
cd /opt/cs-skin-go
docker compose pull
docker compose up -d
```

## 🐛 Troubleshooting

### Ver Todos os Logs
```bash
# Sistema
sudo tail -f /var/log/syslog

# Docker
docker compose logs -f

# Nginx
sudo tail -f /var/log/nginx/cs-skin-go_error.log

# Combinado
sudo tail -f /var/log/nginx/*.log /var/log/syslog
```

### Restart Tudo
```bash
# Containers
cd /opt/cs-skin-go
docker compose restart

# Nginx
sudo systemctl restart nginx

# Docker daemon
sudo systemctl restart docker
```

### Verificar Conectividade
```bash
# Internet
ping -c 4 google.com

# Porta específica
nc -zv localhost 3001
nc -zv localhost 3000
nc -zv localhost 3306

# DNS
nslookup google.com
```

### Limpar Espaço
```bash
# Docker
docker system prune -a

# Logs antigos
sudo journalctl --vacuum-time=7d

# Apt cache
sudo apt clean
sudo apt autoremove
```

## 📦 Backup & Restore

### Backup Completo
```bash
ssh ubuntu@<IP>

# Criar diretório
mkdir -p ~/backups/$(date +%Y%m%d)

# Backup MySQL
cd /opt/cs-skin-go
docker compose exec mysql mysqldump -u root -p cs_skin_go | gzip > ~/backups/$(date +%Y%m%d)/database.sql.gz

# Backup volumes
sudo tar czf ~/backups/$(date +%Y%m%d)/volumes.tar.gz /var/lib/docker/volumes/

# Backup aplicação
sudo tar czf ~/backups/$(date +%Y%m%d)/app.tar.gz /opt/cs-skin-go/

# Download backup
exit
scp -r ubuntu@<IP>:~/backups/$(date +%Y%m%d)/ ./backups/
```

### Restore
```bash
# Upload backup
scp -r ./backups/YYYYMMDD/ ubuntu@<IP>:~/backups/

# SSH no servidor
ssh ubuntu@<IP>

# Restore database
cd /opt/cs-skin-go
gunzip < ~/backups/YYYYMMDD/database.sql.gz | docker compose exec -T mysql mysql -u root -p cs_skin_go

# Restart
docker compose restart
```

## 🔐 Segurança

### Ver Logins Recentes
```bash
last
lastb # Failed logins
```

### Ver Processos
```bash
ps aux | grep node
ps aux | grep nginx
ps aux | grep docker
```

### Firewall
```bash
# Status
sudo ufw status

# Habilitar
sudo ufw enable

# Permitir porta
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp
```

## 🔍 Debugging

### Verificar Variáveis de Ambiente
```bash
# Backend
docker compose exec backend env | grep DATABASE
docker compose exec backend env | grep JWT

# Frontend
docker compose exec frontend env | grep NEXT_PUBLIC
```

### Testar API Diretamente
```bash
# Listar cases
curl -X GET http://<IP>/api/cases

# Health check
curl -X GET http://<IP>/api/health

# Com headers
curl -H "Content-Type: application/json" http://<IP>/api/cases
```

### Verificar DNS/Network
```bash
# Do servidor para backend
curl http://localhost:3001/api/cases

# Do servidor para frontend
curl http://localhost:3000

# Do servidor para MySQL
nc -zv localhost 3306
```

## 📊 AWS CLI

### Ver Instância
```bash
aws ec2 describe-instances --instance-ids i-xxxxx
```

### Ver IP Público
```bash
aws ec2 describe-addresses
```

### Ver Security Groups
```bash
aws ec2 describe-security-groups --group-ids sg-xxxxx
```

### Ver Custos
```bash
aws ce get-cost-and-usage --time-period Start=2024-01-01,End=2024-01-31 --granularity MONTHLY --metrics BlendedCost
```

---

## 💡 Dicas

1. **Sempre use `docker compose` ao invés de `docker-compose`** (nova versão)
2. **Faça backup antes de mudanças importantes**
3. **Use `--check` no Ansible para testar antes de aplicar**
4. **Monitore os logs regularmente**
5. **Configure alertas para espaço em disco < 20%**

## 🆘 Comandos de Emergência

### Site fora do ar?
```bash
# 1. Verificar containers
docker compose ps

# 2. Ver logs
docker compose logs --tail=50

# 3. Restart tudo
docker compose restart && sudo systemctl restart nginx

# 4. Se não resolver, rebuild
docker compose down && docker compose up -d --build
```

### Disco cheio?
```bash
# Limpar Docker
docker system prune -a --volumes

# Limpar logs
sudo journalctl --vacuum-size=100M

# Ver o que está usando espaço
du -sh /* | sort -h
```

### Não consigo conectar via SSH?
```bash
# Verificar IP
curl ifconfig.me

# Atualizar Security Group
cd infra/terraform
# Editar terraform.tfvars: allowed_ssh_cidr
terraform apply
```

