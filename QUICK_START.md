# 🚀 Quick Start - Deploy em 5 Minutos

## Pré-requisitos Rápidos

```bash
# 1. Instalar dependências (macOS)
brew install terraform ansible awscli

# 2. Configurar AWS
aws configure
# Insira: Access Key ID, Secret Access Key, Region (us-east-1)

# 3. Chaves SSH já incluídas!
# As chaves SSH estão em .ssh/ e são usadas automaticamente
# Não precisa configurar nada adicional
```

## Deploy Completo com Makefile 🎯

```bash
# 1. Entrar no diretório infra
cd infra

# 2. Ver comandos disponíveis
make help

# 3. Setup inicial (primeira vez)
make setup
# Edite terraform/terraform.tfvars com suas senhas!

# 4. Deploy completo
make deploy
```

**Pronto!** Sua aplicação estará rodando em ~10 minutos.

## Alternativa: Scripts Shell

```bash
# Se preferir usar scripts ao invés do Makefile
./scripts/deploy.sh
```

## Comandos Úteis com Makefile 🔧

### Ver o que está rodando
```bash
make info      # Ver URLs e informações
make status    # Status dos containers
make health    # Verificar saúde da aplicação
make ssh       # Conectar ao servidor
```

### Logs
```bash
make logs           # Ver logs (últimas 100 linhas)
make logs-follow    # Acompanhar logs em tempo real
make logs-backend   # Apenas backend
make logs-frontend  # Apenas frontend
make logs-nginx     # Apenas Nginx
```

### Gerenciamento
```bash
make update            # Atualizar aplicação
make restart           # Reiniciar containers
make restart-backend   # Reiniciar apenas backend
make rebuild           # Rebuild completo
```

### Banco de Dados
```bash
make db-migrate    # Executar migrações
make db-seed       # Executar seeds
make db-backup     # Fazer backup
```

### Destruir
```bash
make destroy       # Destruir tudo (pede confirmação)
```

### Outros
```bash
make costs         # Ver estimativa de custos
make test-connection  # Testar conectividade
make debug         # Informações de debug
```

## Troubleshooting Rápido

### Erro de conexão SSH
```bash
# Pegar seu IP
curl ifconfig.me

# Adicionar ao terraform.tfvars
allowed_ssh_cidr = ["SEU_IP/32"]

# Aplicar
cd terraform && terraform apply
```

### Container não inicia
```bash
ssh ubuntu@<IP>
cd /opt/cs-skin-go
docker compose logs backend
docker compose restart
```

### Ver logs
```bash
# Nginx
sudo tail -f /var/log/nginx/cs-skin-go_error.log

# Containers
cd /opt/cs-skin-go
docker compose logs -f
```

## URLs Importantes

Depois do deploy, acesse:
- **Frontend:** `http://<IP>/`
- **Backend API:** `http://<IP>/api`
- **Swagger Docs:** `http://<IP>/api/docs` (se habilitado)

## Custos

💰 **~$10/mês** (ou **GRÁTIS** no primeiro ano com AWS Free Tier)

---

📖 **Documentação completa:** [README.md](README.md)

