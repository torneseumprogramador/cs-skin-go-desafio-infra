# 🔄 Workflow Git - Infraestrutura

## 📦 Repositório Separado

A infraestrutura está versionada em um repositório separado:

**🔗 https://github.com/torneseumprogramador/cs-skin-go-desafio-infra**

## ⚙️ Como Trabalhar com o Repositório

### 1. Clone do Repositório de Infra

```bash
# Clone direto
git clone git@github.com:torneseumprogramador/cs-skin-go-desafio-infra.git
cd cs-skin-go-desafio-infra

# OU como submódulo no projeto principal
cd cs-skin-go-desafio
git submodule add git@github.com:torneseumprogramador/cs-skin-go-desafio-infra.git infra
```

### 2. Fazer Mudanças

```bash
cd infra

# Criar branch para feature
git checkout -b feature/nova-funcionalidade

# Fazer mudanças
vim terraform/main.tf

# Commit
git add .
git commit -m "feat: Adiciona nova configuração"

# Push
git push origin feature/nova-funcionalidade
```

### 3. Pull Request

1. Acesse: https://github.com/torneseumprogramador/cs-skin-go-desafio-infra
2. Clique em "Compare & pull request"
3. Descreva as mudanças
4. Solicite review
5. Merge após aprovação

### 4. Atualizar Local

```bash
cd infra

# Atualizar main
git checkout main
git pull origin main

# Deletar branch merged
git branch -d feature/nova-funcionalidade
```

## 🔐 Arquivos Sensíveis

**⚠️ NUNCA COMMITE:**

```
✗ terraform/terraform.tfvars      # Senhas e secrets
✗ terraform/.terraform/           # Cache do Terraform
✗ terraform/terraform.tfstate     # Estado (use backend remoto)
✗ ansible/inventory.ini           # Gerado automaticamente
✗ *.pem, *.key                    # Chaves SSH
```

**✅ SÃO VERSIONADOS:**

```
✓ terraform/*.tf                  # Configurações
✓ terraform/terraform.tfvars.example
✓ ansible/**/*.yml                # Playbooks e roles
✓ ansible/**/*.j2                 # Templates
✓ scripts/*.sh                    # Scripts
✓ Makefile                        # Comandos
✓ *.md                            # Documentação
```

## 🌿 Branches

### Main (Protegida)
- Código em produção
- Requer PR + Review
- Deploy automático (futuro)

### Feature Branches
```bash
git checkout -b feature/descricao
git checkout -b fix/bug-descricao
git checkout -b docs/atualizacao
```

### Hotfix
```bash
git checkout -b hotfix/problema-critico
# Após merge, fazer deploy imediatamente
```

## 📝 Convenção de Commits

Use [Conventional Commits](https://www.conventionalcommits.org/):

```bash
# Features
git commit -m "feat: adiciona suporte a RDS"

# Correções
git commit -m "fix: corrige security group"

# Documentação
git commit -m "docs: atualiza README"

# Refatoração
git commit -m "refactor: reorganiza roles ansible"

# Performance
git commit -m "perf: otimiza configuração nginx"

# Testes
git commit -m "test: adiciona teste de conectividade"

# Chore (tarefas)
git commit -m "chore: atualiza versão terraform"
```

## 🚀 Deploy após Mudanças

```bash
# 1. Atualizar local
cd infra
git pull origin main

# 2. Testar localmente
make tf-plan

# 3. Aplicar mudanças
make deploy

# OU apenas atualizar aplicação
make update
```

## 🔄 Workflow Completo de Feature

```bash
# 1. Criar branch
git checkout -b feature/adiciona-load-balancer

# 2. Fazer mudanças
vim terraform/load-balancer.tf

# 3. Testar localmente
make tf-plan

# 4. Commit
git add terraform/load-balancer.tf
git commit -m "feat: adiciona Application Load Balancer

- Cria ALB para distribuir tráfego
- Adiciona target group para EC2
- Configura health checks
- Atualiza security groups"

# 5. Push
git push origin feature/adiciona-load-balancer

# 6. Criar PR no GitHub
# 7. Após merge, atualizar local
git checkout main
git pull origin main

# 8. Deploy
make deploy
```

## 📊 Versionamento

### Semantic Versioning

Use tags para versões:

```bash
# Versão inicial
git tag -a v1.0.0 -m "Release inicial"
git push origin v1.0.0

# Feature (minor)
git tag -a v1.1.0 -m "Adiciona RDS"
git push origin v1.1.0

# Bugfix (patch)
git tag -a v1.1.1 -m "Corrige security group"
git push origin v1.1.1

# Breaking change (major)
git tag -a v2.0.0 -m "Migra para Terraform 2.0"
git push origin v2.0.0
```

### Listar Tags

```bash
git tag
git tag -l "v1.*"
```

### Deploy de Tag Específica

```bash
git checkout v1.0.0
make deploy
git checkout main
```

## 🔧 Configuração Inicial (Colaboradores)

```bash
# 1. Clone
git clone git@github.com:torneseumprogramador/cs-skin-go-desafio-infra.git
cd cs-skin-go-desafio-infra

# 2. Configurar
make setup

# 3. Copiar e editar variáveis
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
nano terraform/terraform.tfvars

# 4. Testar
make check-deps
make tf-plan
```

## 📚 Recursos

- [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

## 🆘 Troubleshooting

### Conflitos de Merge

```bash
git pull origin main
# Resolver conflitos manualmente
git add .
git commit -m "fix: resolve conflitos"
git push
```

### Desfazer Último Commit

```bash
# Desfazer mas manter mudanças
git reset --soft HEAD~1

# Desfazer e descartar mudanças (CUIDADO!)
git reset --hard HEAD~1
```

### Ver Histórico

```bash
git log --oneline --graph --all
git log --author="nome"
git log --since="2 weeks ago"
```

## 🔒 Segurança

1. **Habilite MFA** no GitHub
2. **Use SSH keys** ao invés de HTTPS
3. **Proteja branch main** - Requer PR + Review
4. **Scaneie secrets** - Use git-secrets ou similar
5. **Revise PRs** - Sempre revisar antes de merge

---

**Dúvidas?** Consulte a [documentação principal](README.md)

