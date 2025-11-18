# 🚀 Infraestrutura CS Skin GO - Deploy Automatizado

Este diretório contém toda a configuração de infraestrutura como código (IaC) para deploy automatizado da aplicação CS Skin GO na AWS.

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Requisitos](#requisitos)
- [Custos](#custos)
- [Instalação](#instalação)
- [Deploy](#deploy)
- [Domínios e DNS](#domínios-e-dns)
- [Chaves SSH do Projeto](#chaves-ssh-do-projeto)
- [Workflow de Git da Infra](#workflow-de-git-da-infra)
- [Gerenciamento](#gerenciamento)
- [Troubleshooting](#troubleshooting)

## 🎯 Visão Geral

Stack de deploy totalmente automatizado usando:
- **Terraform**: Provisionamento de infraestrutura na AWS
- **Ansible**: Configuração de servidores e deploy de aplicação
- **Docker**: Containerização das aplicações
- **Nginx**: Proxy reverso e servidor web

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────┐
│              AWS EC2 (t2.micro)                 │
│  ┌───────────────────────────────────────────┐  │
│  │            Nginx (porta 80)               │  │
│  │  ┌─────────────┐  ┌──────────────────┐   │  │
│  │  │  Frontend   │  │  Backend API     │   │  │
│  │  │  Next.js    │  │  NestJS          │   │  │
│  │  │  (porta 3000)│  │  (porta 3001)    │   │  │
│  │  └─────────────┘  └──────────────────┘   │  │
│  │           │                  │            │  │
│  │           └──────────┬───────┘            │  │
│  │                      │                    │  │
│  │              ┌───────▼────────┐           │  │
│  │              │  MySQL 8.0     │           │  │
│  │              │  (porta 3306)  │           │  │
│  │              └────────────────┘           │  │
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
                        │
                        │ HTTP/HTTPS
                        ▼
                   Usuários
```

### Fluxo de Tráfego

1. **Usuário** → `http://IP_PUBLICO/` → Nginx → Frontend (Next.js)
2. **Usuário** → `http://IP_PUBLICO/api` → Nginx → Backend (NestJS)
3. **Backend** → MySQL (localhost:3306)

## 📦 Requisitos

### Software Necessário

- **Terraform** >= 1.0
  ```bash
  brew install terraform  # macOS
  ```

- **Ansible** >= 2.10
  ```bash
  brew install ansible  # macOS
  # ou
  pip3 install ansible
  ```

- **AWS CLI** (configurado)
  ```bash
  brew install awscli
  aws configure
  ```

- **SSH Key Pair**
  ```bash
  ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
  ```

### Credenciais AWS

Configure suas credenciais AWS:

```bash
export AWS_ACCESS_KEY_ID="sua_access_key"
export AWS_SECRET_ACCESS_KEY="sua_secret_key"
export AWS_DEFAULT_REGION="us-east-1"
```

Ou use `aws configure`.

## 💰 Custos

### Estimativa Mensal

| Recurso | Tipo | Custo Mensal |
|---------|------|--------------|
| EC2 | t2.micro | **$8.50** |
| EBS | 20 GB gp3 | $1.60 |
| Elastic IP | 1 IP | $0.00* |
| **TOTAL** | | **~$10.10/mês** |

> **🎉 FREE TIER:** Se sua conta AWS for elegível para o Free Tier (primeiro ano), o custo é **$0.00/mês**!
> - 750 horas/mês de t2.micro (equivale a 1 instância rodando 24/7)
> - 30 GB de EBS
> - 1 Elastic IP (quando associado a instância rodando)

## 🚀 Instalação

### 1. Clone o Repositório

```bash
cd cs-skin-go-desafio/infra
```

### 2. Verifique Dependências

```bash
make check-deps
```

Isso verificará se você tem instalado:
- Terraform
- Ansible
- AWS CLI (opcional)
- Chave SSH (✅ já incluída em `.ssh/`)

### 3. Setup Inicial

```bash
make setup
```

Este comando irá:
- Criar `terraform.tfvars` se não existir
- Inicializar o Terraform
- Verificar configuração

### 4. Configure Variáveis

Edite `terraform/terraform.tfvars` e ajuste os valores:

```hcl
# terraform.tfvars
aws_region = "us-east-1"
instance_type = "t2.micro"

# IMPORTANTE: Mude para seu IP para maior segurança!
allowed_ssh_cidr = ["SEU_IP_AQUI/32"]

# Secrets - MUDE ESTES VALORES!
jwt_secret = "seu-secret-jwt-super-seguro-min-32-caracteres"
mysql_root_password = "SenhaRootMySQL@123"
mysql_password = "SenhaUserMySQL@456"
```

## 🎬 Deploy

### Opção 1: Makefile (Recomendado) 🎯

```bash
cd infra

# Ver todos os comandos disponíveis
make help

# Deploy completo
make deploy
```

O comando `make deploy` irá:
1. Verificar dependências
2. Provisionar infraestrutura (Terraform)
3. Aguardar servidor ficar pronto
4. Configurar servidor (Ansible)
5. Fazer deploy da aplicação
6. Mostrar URLs de acesso

### Opção 2: Scripts Shell

```bash
cd infra
./scripts/deploy.sh
```

### Opção 3: Manual (Passo a Passo)

#### Passo 1: Provisionar Infraestrutura (Terraform)

```bash
make tf-init      # Inicializar
make tf-plan      # Ver o que será criado
make tf-apply     # Criar infraestrutura
make tf-output    # Ver outputs
```

Ou manualmente:
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

#### Passo 2: Configurar e Fazer Deploy (Ansible)

```bash
make ansible-ping      # Testar conectividade
make ansible-playbook  # Executar playbook completo
```

Ou manualmente:
```bash
cd ansible
ansible all -m ping
ansible-playbook playbook.yml
```

### Deploy Incremental (Apenas Aplicação)

Se você já provisionou a infraestrutura e quer apenas atualizar a aplicação:

```bash
make update
```

Ou:
```bash
cd infra/ansible
ansible-playbook playbook.yml --tags application
```

## 🌐 Domínios e DNS

Este projeto já está preparado para usar domínios customizados:

- **Frontend**: `ia.daniloaparecido.com.br`
- **Backend/API**: `api-ia.daniloaparecido.com.br`

Depois do deploy (quando você já tiver o IP público da EC2), configure dois registros **A** no seu provedor de DNS (Registro.br, Cloudflare, etc):

- `ia.daniloaparecido.com.br` → `<IP_PUBLICO_DA_EC2>`
- `api-ia.daniloaparecido.com.br` → `<IP_PUBLICO_DA_EC2>`

Você pode obter o IP público com:

```bash
cd infra/terraform
terraform output instance_public_ip
```

Após a propagação DNS:

- Frontend: `http://ia.daniloaparecido.com.br`
- Backend (API): `http://api-ia.daniloaparecido.com.br/api`

> Para HTTPS, use Certbot/Let's Encrypt diretamente no servidor (instalação padrão com `certbot --nginx`).

## 🔐 Chaves SSH do Projeto

O diretório `infra/.ssh/` contém um par de chaves **exclusivo deste projeto**:

```text
infra/
  .ssh/
    id_rsa      # chave privada (gitignored)
    id_rsa.pub  # chave pública (gitignored)
```

- Essas chaves são usadas automaticamente pelo Terraform/Ansible.
- Elas **não são** commitadas (estão protegidas pelo `.gitignore`).

Se quiser usar suas chaves pessoais:

1. Edite `terraform/terraform.tfvars`:

```hcl
ssh_public_key_path  = "~/.ssh/id_rsa.pub"
ssh_private_key_path = "~/.ssh/id_rsa"
```

2. Ou exporte variáveis de ambiente `TF_VAR_ssh_public_key_path` e `TF_VAR_ssh_private_key_path`.

Para regenerar as chaves do projeto:

```bash
cd infra/.ssh
ssh-keygen -t rsa -b 4096 -f id_rsa -N "" -C "cs-skin-go-deploy"
chmod 600 id_rsa
chmod 644 id_rsa.pub
```

## 🌿 Workflow de Git da Infra

A infra está em um repositório separado:

```text
https://github.com/torneseumprogramador/cs-skin-go-desafio-infra
```

Fluxo recomendado:

```bash
cd infra

# Criar branch de feature
git checkout -b feature/minha-mudanca

# Fazer alterações (Terraform / Ansible)
git add .
git commit -m "feat: descrição da mudança"
git push origin feature/minha-mudanca
```

Depois, abra um **Pull Request** nesse repositório, revise e faça merge em `main`.  
Para atualizar o ambiente após o merge:

```bash
cd infra
git checkout main
git pull origin main
make deploy      # ou make update, se for só aplicação
```

## 🔧 Gerenciamento

### Comandos Rápidos com Makefile

```bash
# Ver informações
make info          # URLs e IPs
make status        # Status dos containers
make health        # Verificar saúde

# Acessar
make ssh           # Conectar via SSH

# Logs
make logs          # Ver logs (últimas 100 linhas)
make logs-follow   # Acompanhar em tempo real
make logs-backend  # Apenas backend
make logs-frontend # Apenas frontend
make logs-nginx    # Apenas Nginx

# Gerenciamento
make restart           # Reiniciar tudo
make restart-backend   # Reiniciar backend
make restart-frontend  # Reiniciar frontend
make rebuild           # Rebuild completo

# Banco de Dados
make db-migrate    # Executar migrações
make db-seed       # Executar seeds
make db-backup     # Fazer backup

# Atualização
make update        # Atualizar aplicação
```

### Comandos Manuais (SSH)

Se preferir acessar diretamente:

```bash
# Acessar servidor
make ssh
# ou
ssh -i ~/.ssh/id_rsa ubuntu@<IP_PUBLICO>

# Verificar containers
cd /opt/cs-skin-go
docker compose ps
docker compose logs -f

# Ver logs
sudo tail -f /var/log/nginx/cs-skin-go_error.log
docker compose logs -f backend

# Restart
docker compose restart
docker compose restart backend

# Migrações
docker compose exec backend npm run migration:run
docker compose exec backend npm run seed
```

## 🧹 Destruir Infraestrutura

**⚠️ ATENÇÃO: Isso vai deletar TUDO!**

```bash
make destroy
```

Ou manualmente:
```bash
cd infra/terraform
terraform destroy
```

## 🔍 Troubleshooting

### Problema: Não consigo conectar via SSH

**Solução:**
1. Verifique se o Security Group permite seu IP:
   ```bash
   # Pegar seu IP
   curl ifconfig.me
   
   # Atualizar terraform.tfvars
   allowed_ssh_cidr = ["SEU_IP/32"]
   terraform apply
   ```

2. Verifique permissões da chave:
   ```bash
   chmod 600 ~/.ssh/id_rsa
   ```

### Problema: Container não inicia

**Solução:**
```bash
ssh ubuntu@<IP_PUBLICO>
cd /opt/cs-skin-go

# Ver logs detalhados
docker compose logs backend
docker compose logs frontend

# Recriar containers
docker compose down
docker compose up -d --build
```

### Problema: Database connection error

**Solução:**
```bash
ssh ubuntu@<IP_PUBLICO>

# Verificar se MySQL está rodando
docker compose ps mysql

# Ver logs do MySQL
docker compose logs mysql

# Restart do MySQL
docker compose restart mysql

# Aguardar ele ficar saudável
docker compose ps
```

### Problema: Frontend não carrega

**Solução:**
1. Verifique se o backend está respondendo:
   ```bash
   curl http://<IP_PUBLICO>/api/cases
   ```

2. Verifique configuração do Nginx:
   ```bash
   sudo nginx -t
   sudo systemctl status nginx
   ```

3. Verifique logs:
   ```bash
   sudo tail -f /var/log/nginx/cs-skin-go_error.log
   ```

### Problema: Ansible falha com "Permission denied"

**Solução:**
```bash
# Aguarde a instância estar 100% pronta
sleep 60

# Tente novamente
ansible-playbook playbook.yml
```

## 📚 Estrutura de Arquivos

```
infra/
├── terraform/
│   ├── main.tf                 # Configuração principal
│   ├── variables.tf            # Variáveis
│   ├── outputs.tf              # Outputs
│   ├── security-groups.tf      # Security Groups
│   ├── terraform.tfvars        # Valores das variáveis (não versionado)
│   └── templates/
│       └── inventory.tpl       # Template do inventário Ansible
├── ansible/
│   ├── playbook.yml            # Playbook principal
│   ├── ansible.cfg             # Configuração do Ansible
│   ├── inventory.ini           # Inventário (gerado pelo Terraform)
│   ├── vars/
│   │   └── main.yml            # Variáveis da aplicação
│   └── roles/
│       ├── common/             # Setup comum do servidor
│       ├── docker/             # Instalação do Docker
│       ├── nginx/              # Configuração do Nginx
│       └── application/        # Deploy da aplicação
├── scripts/
│   ├── deploy.sh               # Script de deploy completo
│   └── update.sh               # Script de atualização
└── README.md                   # Este arquivo
```

## 🔐 Segurança

### Recomendações

1. **Mude todos os secrets em produção!**
   - JWT_SECRET
   - MySQL passwords
   - SSH keys

2. **Restrinja acesso SSH:**
   ```hcl
   allowed_ssh_cidr = ["SEU_IP/32"]  # Apenas seu IP
   ```

3. **Use HTTPS em produção:**
   - Configure um domínio
   - Use Certbot para Let's Encrypt
   - Atualize configuração do Nginx

4. **Habilite firewall:**
   ```bash
   sudo ufw enable
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw allow 22/tcp
   ```

5. **Backups regulares:**
   - Configure snapshots EBS
   - Backup do banco de dados

## 🎯 Próximos Passos

- [ ] Configurar domínio próprio
- [ ] Adicionar HTTPS (Let's Encrypt)
- [ ] Configurar CI/CD
- [ ] Implementar monitoramento (CloudWatch)
- [ ] Configurar backups automáticos
- [ ] Adicionar auto-scaling (quando necessário)

## 📞 Suporte

Em caso de dúvidas ou problemas:
1. Consulte a seção [Troubleshooting](#troubleshooting)
2. Verifique os logs
3. Revise a configuração

---

**Bom deploy! 🚀**

