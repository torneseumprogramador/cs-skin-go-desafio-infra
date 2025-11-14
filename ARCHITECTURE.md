# 🏗️ Arquitetura da Infraestrutura

## Visão Geral

Esta documentação descreve a arquitetura completa da infraestrutura CS Skin GO deployada na AWS.

## Diagrama de Arquitetura

```
                                    ┌─────────────────────────────────────┐
                                    │         AWS Cloud (us-east-1)       │
                                    │                                     │
                                    │  ┌───────────────────────────────┐ │
┌──────────┐                        │  │     VPC Default               │ │
│          │                        │  │                               │ │
│  Users   │────────HTTP/HTTPS──────┼──│  ┌─────────────────────────┐ │ │
│          │                        │  │  │  EC2 Instance (t2.micro)│ │ │
└──────────┘                        │  │  │                         │ │ │
                                    │  │  │  ┌───────────────────┐  │ │ │
                                    │  │  │  │  Nginx :80        │  │ │ │
                                    │  │  │  │  Reverse Proxy    │  │ │ │
                                    │  │  │  └────────┬──────────┘  │ │ │
                                    │  │  │           │             │ │ │
                                    │  │  │  ┌────────▼────────┐   │ │ │
                                    │  │  │  │  Docker Network │   │ │ │
                                    │  │  │  │                 │   │ │ │
                                    │  │  │  │  ┌───────────┐  │   │ │ │
                                    │  │  │  │  │ Frontend  │  │   │ │ │
                                    │  │  │  │  │ Next.js   │  │   │ │ │
                                    │  │  │  │  │ :3000     │  │   │ │ │
                                    │  │  │  │  └─────┬─────┘  │   │ │ │
                                    │  │  │  │        │        │   │ │ │
                                    │  │  │  │  ┌─────▼─────┐  │   │ │ │
                                    │  │  │  │  │ Backend   │  │   │ │ │
                                    │  │  │  │  │ NestJS    │  │   │ │ │
                                    │  │  │  │  │ :3001     │  │   │ │ │
                                    │  │  │  │  └─────┬─────┘  │   │ │ │
                                    │  │  │  │        │        │   │ │ │
                                    │  │  │  │  ┌─────▼─────┐  │   │ │ │
                                    │  │  │  │  │ MySQL 8.0 │  │   │ │ │
                                    │  │  │  │  │ :3306     │  │   │ │ │
                                    │  │  │  │  └───────────┘  │   │ │ │
                                    │  │  │  └─────────────────┘   │ │ │
                                    │  │  │                         │ │ │
                                    │  │  │  EBS Volume (20 GB gp3) │ │ │
                                    │  │  └─────────────────────────┘ │ │
                                    │  │              │                │ │
                                    │  │        Elastic IP             │ │
                                    │  │      (IP Público Fixo)        │ │
                                    │  │                               │ │
                                    │  └───────────────────────────────┘ │
                                    │                                     │
                                    │  Security Group                     │
                                    │  - SSH :22 (restrito)               │
                                    │  - HTTP :80 (aberto)                │
                                    │  - HTTPS :443 (aberto)              │
                                    │                                     │
                                    └─────────────────────────────────────┘
```

## Componentes

### 1. Infraestrutura AWS (Terraform)

#### EC2 Instance
- **Tipo:** t2.micro (1 vCPU, 1 GB RAM)
- **AMI:** Ubuntu 22.04 LTS
- **Custo:** ~$8.50/mês (FREE no primeiro ano)
- **Região:** us-east-1 (configurável)

#### EBS Volume
- **Tipo:** gp3 (SSD de propósito geral)
- **Tamanho:** 20 GB
- **Custo:** ~$1.60/mês
- **Encrypted:** Sim

#### Elastic IP
- **Custo:** Grátis quando associado à instância rodando
- **Benefício:** IP público fixo que não muda após restarts

#### Security Group
| Porta | Protocolo | Origem | Descrição |
|-------|-----------|--------|-----------|
| 22 | TCP | Configurável | SSH |
| 80 | TCP | 0.0.0.0/0 | HTTP |
| 443 | TCP | 0.0.0.0/0 | HTTPS |
| 3000 | TCP | 0.0.0.0/0 | Frontend (debug) |
| 3001 | TCP | 0.0.0.0/0 | Backend (debug) |

### 2. Servidor (Ansible)

#### Sistema Operacional
- Ubuntu 22.04 LTS
- Timezone: America/Sao_Paulo
- Python 3.10+

#### Software Instalado
- Docker CE + Docker Compose
- Nginx
- Node.js 18
- Git
- Ferramentas de sistema (vim, htop, curl, etc.)

### 3. Aplicação (Docker)

#### Container: MySQL
- **Imagem:** mysql:8.0
- **Porta:** 3306 (localhost apenas)
- **Volume:** mysql_data (persistente)
- **Health Check:** Sim
- **Restart Policy:** unless-stopped

#### Container: Backend (NestJS)
- **Build:** Multi-stage Dockerfile
- **Porta:** 3001 (localhost apenas)
- **Dependências:** MySQL (health check)
- **Health Check:** GET /api/cases
- **Restart Policy:** unless-stopped

#### Container: Frontend (Next.js)
- **Build:** Multi-stage Dockerfile
- **Porta:** 3000 (localhost apenas)
- **Dependências:** Backend (health check)
- **Health Check:** wget localhost:3000
- **Restart Policy:** unless-stopped

### 4. Nginx

#### Configuração
- **Porta:** 80 (público)
- **Upstream Backend:** localhost:3001
- **Upstream Frontend:** localhost:3000

#### Rotas
```nginx
/              → Frontend (Next.js)
/api/*         → Backend (NestJS)
/_next/static  → Frontend (cache 365d)
/static/*      → Frontend (cache 30d)
```

#### Recursos
- Rate limiting
- Security headers
- Proxy pass com health checks
- Logs customizados

## Fluxo de Requisições

### 1. Requisição de Página
```
User → Nginx:80 → Frontend:3000 → User
```

### 2. Requisição de API
```
User → Nginx:80 → Backend:3001 → MySQL:3306 → Backend → User
```

### 3. Ativos Estáticos
```
User → Nginx:80 → Frontend:3000 (com cache)
```

## Segurança

### Camadas de Segurança

1. **Network Level**
   - Security Group com regras restritivas
   - Elastic IP com DDoS protection básica

2. **Application Level**
   - Rate limiting no Nginx
   - CORS configurado no Backend
   - JWT para autenticação

3. **Container Level**
   - Containers isolados em rede bridge
   - Non-root users nos containers
   - Health checks ativos

4. **Data Level**
   - EBS volume encriptado
   - MySQL passwords em variáveis de ambiente
   - JWT secret em variáveis de ambiente

## Escalabilidade

### Limitações Atuais (Single Server)
- **Max Concurrent Users:** ~100-200
- **Max Requests/sec:** ~50-100
- **Database Size:** ~15 GB útil

### Como Escalar (Futuro)

#### Vertical Scaling (Fácil)
```hcl
# terraform/terraform.tfvars
instance_type = "t3.small"  # 2 vCPU, 2 GB RAM → ~$15/mês
instance_type = "t3.medium" # 2 vCPU, 4 GB RAM → ~$30/mês
```

#### Horizontal Scaling (Complexo)
1. Separar MySQL em RDS
2. Adicionar Application Load Balancer
3. Auto Scaling Group com múltiplas EC2s
4. ElastiCache para sessions
5. S3 + CloudFront para assets estáticos

## Monitoramento

### Logs Disponíveis

```bash
# Nginx
/var/log/nginx/cs-skin-go_access.log
/var/log/nginx/cs-skin-go_error.log

# Docker Containers
/opt/cs-skin-go/logs/backend/
/opt/cs-skin-go/logs/frontend/
/opt/cs-skin-go/logs/mysql/

# Sistema
/var/log/syslog
```

### Métricas Importantes

- CPU Usage
- Memory Usage
- Disk I/O
- Network I/O
- Container Health Status
- Response Times

### Tools Recomendadas (Futuro)

- CloudWatch (AWS nativo)
- Prometheus + Grafana
- ELK Stack
- Datadog / New Relic

## Backup & Disaster Recovery

### Estratégias Recomendadas

#### 1. EBS Snapshots
```bash
# Criar snapshot manual
aws ec2 create-snapshot --volume-id vol-xxx --description "Backup manual"

# Ou automatizar com AWS Backup
```

#### 2. Database Dumps
```bash
# No servidor
docker compose exec mysql mysqldump -u root -p cs_skin_go > backup.sql
```

#### 3. Infrastructure as Code
- Todo código está no Git
- Pode recriar a infra do zero em minutos

### RTO/RPO
- **RTO (Recovery Time Objective):** ~15 minutos
- **RPO (Recovery Point Objective):** Depende da frequência de backup

## Performance

### Otimizações Implementadas

1. **Nginx**
   - Gzip compression
   - Static file caching
   - Connection keep-alive
   - Rate limiting

2. **Docker**
   - Multi-stage builds (imagens menores)
   - Health checks
   - Resource limits (futuro)

3. **Sistema**
   - Sysctl tuning
   - File descriptors aumentados
   - Swappiness reduzido

## Custos Detalhados

| Recurso | Quantidade | Custo Unitário | Total/Mês |
|---------|-----------|----------------|-----------|
| EC2 t2.micro | 750h | $0.0116/h | $8.70 |
| EBS gp3 20GB | 20 GB | $0.08/GB | $1.60 |
| Elastic IP | 1 IP | $0.00* | $0.00 |
| Data Transfer | 1 GB | $0.09/GB | ~$0.50 |
| **TOTAL** | | | **~$10.80** |

*\*Grátis quando associado a instância rodando*

### Free Tier (Primeiro Ano)
- 750h/mês de t2.micro = **$0.00**
- 30 GB de EBS = **$0.00**
- 15 GB de transferência = **$0.00**

**Total com Free Tier: $0.00/mês**

## Manutenção

### Tarefas Regulares

#### Diárias
- Verificar logs de erro
- Monitorar espaço em disco

#### Semanais
- Revisar métricas de performance
- Verificar updates de segurança

#### Mensais
- Fazer backup completo
- Atualizar dependências
- Revisar custos AWS

### Comandos Úteis

```bash
# Espaço em disco
df -h

# Uso de memória
free -h

# Containers rodando
docker ps

# Logs últimas 100 linhas
docker compose logs --tail=100

# Limpar imagens antigas
docker system prune -a
```

## Referências

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

