# 🏗️ CS Skin GO - Infraestrutura

Repositório de infraestrutura como código (IaC) para deploy automatizado do CS Skin GO na AWS.

## 🎯 Sobre

Este repositório contém toda a configuração de infraestrutura para deploy automatizado usando:
- **Terraform**: Provisionamento de recursos AWS (EC2, Security Groups, EIP)
- **Ansible**: Configuração de servidores e deploy de aplicações
- **Docker**: Containerização das aplicações

## 🚀 Quick Start

```bash
# 1. Verificar dependências
make check-deps

# 2. Setup inicial
make setup

# 3. Configurar variáveis (IMPORTANTE!)
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
nano terraform/terraform.tfvars

# 4. Deploy completo
make deploy
```

## 💰 Custos

- **EC2 t2.micro**: ~$8.50/mês
- **EBS 20GB**: ~$1.60/mês
- **Total**: ~$10/mês

**🎉 Com AWS Free Tier (1º ano): $0.00/mês**

## 📚 Documentação

- [README Completo](README.md) - Documentação detalhada
- [Quick Start](QUICK_START.md) - Deploy em 5 minutos
- [Architecture](ARCHITECTURE.md) - Arquitetura detalhada
- [Makefile Reference](MAKEFILE_REFERENCE.md) - Comandos do Makefile
- [Commands](COMMANDS.md) - Referência de comandos SSH
- [Checklist](CHECKLIST.md) - Checklist de deploy

## 🛠️ Comandos Principais

```bash
make help            # Ver todos os comandos
make deploy          # Deploy completo
make update          # Atualizar aplicação
make status          # Status dos serviços
make logs            # Ver logs
make ssh             # Conectar ao servidor
make destroy         # Destruir infraestrutura
make costs           # Ver estimativa de custos
```

## ⚙️ Requisitos

- Terraform >= 1.0
- Ansible >= 2.10
- AWS CLI (configurado)
- Chave SSH (~/.ssh/id_rsa)

## 🏗️ Arquitetura

```
┌─────────────────────────────────────┐
│         AWS EC2 (t2.micro)          │
│  ┌───────────────────────────────┐  │
│  │  Nginx :80 (Reverse Proxy)    │  │
│  │    ↓                           │  │
│  │  Frontend (Next.js) :3000     │  │
│  │  Backend (NestJS) :3001       │  │
│  │    ↓                           │  │
│  │  MySQL :3306                  │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

## 🔐 Segurança

**⚠️ IMPORTANTE:**

1. **Nunca commite `terraform.tfvars`** - Contém senhas e secrets
2. **Mude as senhas padrão** - JWT secret, MySQL passwords
3. **Restrinja SSH** - Configure `allowed_ssh_cidr` com seu IP
4. **Use secrets manager** - Em produção, use AWS Secrets Manager

## 🔗 Links

- **Repositório Principal**: [cs-skin-go-desafio](https://github.com/torneseumprogramador/cs-skin-go-desafio)
- **Backend**: Incluído no deploy
- **Frontend**: Incluído no deploy

## 📝 Licença

MIT

