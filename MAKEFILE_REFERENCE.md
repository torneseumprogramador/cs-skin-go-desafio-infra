# 📖 Referência Rápida do Makefile

Todos os comandos disponíveis no Makefile da infraestrutura CS Skin GO.

## 🎯 Comandos Principais

### Deploy e Setup

```bash
make help           # Mostra ajuda com todos os comandos
make check-deps     # Verifica dependências (Terraform, Ansible, SSH)
make setup          # Setup inicial (primeira vez)
make deploy         # Deploy completo (Terraform + Ansible)
make update         # Atualiza apenas a aplicação
make destroy        # Destrói toda a infraestrutura (pede confirmação)
```

## 🏗️ Terraform

```bash
make tf-init        # Inicializa o Terraform
make tf-validate    # Valida configuração
make tf-plan        # Mostra plano de execução
make tf-apply       # Aplica mudanças
make tf-output      # Mostra outputs (IPs, URLs)
make tf-show        # Mostra estado atual
make tf-destroy     # Destrói infraestrutura
```

## 🎭 Ansible

```bash
make ansible-ping       # Testa conectividade
make ansible-playbook   # Executa playbook completo
make ansible-setup      # Executa apenas setup (comum, docker, nginx)
make ansible-deploy     # Executa apenas deploy da aplicação
make ansible-check      # Dry-run (sem aplicar)
make ansible-verbose    # Executa com output detalhado
```

## 🔌 Acesso e Informações

```bash
make info           # Mostra URLs e IPs
make ssh            # Conecta ao servidor via SSH
make ssh-cmd        # Executa comando remoto (use: make ssh-cmd CMD="comando")
```

## 📊 Monitoramento

```bash
make status         # Status dos containers
make health         # Verifica saúde da aplicação
make costs          # Mostra estimativa de custos
```

## 📝 Logs

```bash
make logs           # Logs de todos os containers (últimas 100 linhas)
make logs-follow    # Acompanha logs em tempo real (Ctrl+C para sair)
make logs-backend   # Logs apenas do backend
make logs-frontend  # Logs apenas do frontend
make logs-nginx     # Logs do Nginx
```

## 🔄 Gerenciamento de Containers

```bash
make restart            # Reinicia todos os containers
make restart-backend    # Reinicia apenas o backend
make restart-frontend   # Reinicia apenas o frontend
make rebuild            # Rebuild e reinicia os containers
```

## 🗄️ Banco de Dados

```bash
make db-migrate     # Executa migrações do banco
make db-seed        # Executa seeds
make db-backup      # Faz backup do banco de dados
```

## 🧹 Limpeza

```bash
make clean-docker   # Limpa recursos Docker não utilizados
make clean-local    # Limpa arquivos locais gerados
make clean          # Limpa arquivos temporários
```

## 🐛 Troubleshooting

```bash
make debug              # Mostra informações de debug
make test-connection    # Testa conexão com aplicação
```

## 📚 Documentação

```bash
make docs           # Abre documentação principal
make quick-start    # Mostra guia rápido
```

---

## 💡 Exemplos de Uso

### Deploy Inicial
```bash
cd infra
make check-deps      # Verificar se tem tudo instalado
make setup           # Setup inicial
# Editar terraform/terraform.tfvars com suas configurações
make deploy          # Deploy completo
```

### Atualizar Código
```bash
# Depois de fazer mudanças no código
cd infra
make update          # Atualiza aplicação sem recriar infra
```

### Ver Logs em Tempo Real
```bash
make logs-follow     # Pressione Ctrl+C para sair
```

### Executar Comando no Servidor
```bash
make ssh-cmd CMD="df -h"                    # Ver espaço em disco
make ssh-cmd CMD="docker compose ps"        # Status dos containers
make ssh-cmd CMD="uptime"                   # Uptime do servidor
```

### Reiniciar Backend
```bash
make restart-backend    # Reinicia apenas o backend
make logs-backend       # Verifica os logs
```

### Fazer Backup do Banco
```bash
make db-backup          # Cria backup no servidor
```

### Verificar Saúde
```bash
make health             # Testa se frontend e backend estão respondendo
make status             # Status dos containers
```

### Destruir Tudo (Cuidado!)
```bash
make destroy            # Pede confirmação antes de destruir
```

---

## 🎨 Cores no Output

O Makefile usa cores para facilitar leitura:
- 🔵 **Azul:** Informações e headers
- 🟢 **Verde:** Sucesso
- 🟡 **Amarelo:** Avisos
- 🔴 **Vermelho:** Erros

---

## 📌 Dicas

1. **Sempre comece com `make help`** para ver comandos disponíveis
2. **Use `make check-deps`** antes do primeiro deploy
3. **Configure `terraform.tfvars`** antes de fazer deploy
4. **Use `make info`** para ver URLs e IPs após deploy
5. **`make update`** é mais rápido que `make deploy` para atualizar código
6. **Use `make logs-follow`** para debug em tempo real
7. **`make health`** verifica se tudo está funcionando

---

## 🔗 Links Úteis

- [README.md](README.md) - Documentação completa
- [QUICK_START.md](QUICK_START.md) - Guia rápido
- [ARCHITECTURE.md](ARCHITECTURE.md) - Arquitetura detalhada
- [COMMANDS.md](COMMANDS.md) - Comandos SSH diretos
- [CHECKLIST.md](CHECKLIST.md) - Checklist de deploy

---

## 🆘 Ajuda

Se algo der errado:
1. `make debug` - Ver informações de debug
2. `make test-connection` - Testar conectividade
3. `make logs` - Ver logs
4. `make health` - Verificar saúde
5. Consultar [README.md#troubleshooting](README.md#troubleshooting)

