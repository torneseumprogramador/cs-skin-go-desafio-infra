.PHONY: help setup deploy update destroy clean check ssh logs status

# Variáveis
TERRAFORM_DIR = terraform
ANSIBLE_DIR = ansible
SCRIPTS_DIR = scripts

# Cores para output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

##@ Ajuda

help: ## Mostra esta mensagem de ajuda
	@echo "$(BLUE)╔═══════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║          CS Skin GO - Makefile de Infraestrutura          ║$(NC)"
	@echo "$(BLUE)╚═══════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "$(GREEN)Uso: make $(YELLOW)<comando>$(NC)\n\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(BLUE)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(BLUE)Exemplos:$(NC)"
	@echo "  make setup    # Preparar ambiente pela primeira vez"
	@echo "  make deploy   # Deploy completo (Terraform + Ansible)"
	@echo "  make update   # Atualizar apenas a aplicação"
	@echo "  make ssh      # Conectar ao servidor via SSH"
	@echo "  make logs     # Ver logs da aplicação"
	@echo ""

##@ Setup e Preparação

check-deps: ## Verifica se todas as dependências estão instaladas
	@echo "$(BLUE)Verificando dependências...$(NC)"
	@command -v terraform >/dev/null 2>&1 || { echo "$(RED)✗ Terraform não encontrado. Instale: brew install terraform$(NC)"; exit 1; }
	@echo "$(GREEN)✓ Terraform encontrado$(NC)"
	@command -v ansible >/dev/null 2>&1 || { echo "$(RED)✗ Ansible não encontrado. Instale: brew install ansible$(NC)"; exit 1; }
	@echo "$(GREEN)✓ Ansible encontrado$(NC)"
	@command -v aws >/dev/null 2>&1 || echo "$(YELLOW)⚠ AWS CLI não encontrado (opcional). Instale: brew install awscli$(NC)"
	@test -f .ssh/id_rsa || { echo "$(YELLOW)⚠ Chaves SSH locais não encontradas em .ssh/$(NC)"; echo "$(YELLOW)Gerando chaves SSH locais...$(NC)"; mkdir -p .ssh; ssh-keygen -t rsa -b 4096 -f .ssh/id_rsa -N "" -C "cs-skin-go-deploy"; chmod 600 .ssh/id_rsa; chmod 644 .ssh/id_rsa.pub; }
	@echo "$(GREEN)✓ Chaves SSH encontradas (projeto local)$(NC)"
	@echo "$(GREEN)✓ Todas as dependências OK!$(NC)"

setup: check-deps ## Configuração inicial (primeira vez)
	@echo "$(BLUE)Configurando ambiente...$(NC)"
	@if [ ! -f $(TERRAFORM_DIR)/terraform.tfvars ]; then \
		echo "$(YELLOW)Criando terraform.tfvars...$(NC)"; \
		cp $(TERRAFORM_DIR)/terraform.tfvars.example $(TERRAFORM_DIR)/terraform.tfvars; \
		echo "$(YELLOW)⚠ IMPORTANTE: Edite $(TERRAFORM_DIR)/terraform.tfvars antes de continuar!$(NC)"; \
		echo "$(YELLOW)⚠ Mude: jwt_secret, mysql_password, allowed_ssh_cidr$(NC)"; \
	else \
		echo "$(GREEN)✓ terraform.tfvars já existe$(NC)"; \
	fi
	@cd $(TERRAFORM_DIR) && terraform init
	@echo "$(GREEN)✓ Setup concluído!$(NC)"

##@ Terraform

tf-init: ## Inicializa o Terraform
	@echo "$(BLUE)Inicializando Terraform...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform init

tf-validate: ## Valida configuração do Terraform
	@echo "$(BLUE)Validando Terraform...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform validate

tf-plan: ## Mostra o plano de execução do Terraform
	@echo "$(BLUE)Planejando mudanças...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform plan

tf-apply: ## Aplica mudanças do Terraform
	@echo "$(BLUE)Aplicando mudanças...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform apply

tf-output: ## Mostra outputs do Terraform
	@cd $(TERRAFORM_DIR) && terraform output

tf-show: ## Mostra estado atual do Terraform
	@cd $(TERRAFORM_DIR) && terraform show

tf-destroy: ## Destrói infraestrutura (CUIDADO!)
	@echo "$(RED)⚠ ATENÇÃO: Isso vai destruir TODA a infraestrutura!$(NC)"
	@echo "$(RED)Esta ação é IRREVERSÍVEL!$(NC)"
	@read -p "Digite 'yes' para confirmar: " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		cd $(TERRAFORM_DIR) && terraform destroy; \
	else \
		echo "$(YELLOW)Operação cancelada.$(NC)"; \
	fi

##@ Ansible

ansible-ping: ## Testa conectividade com o servidor
	@echo "$(BLUE)Testando conectividade...$(NC)"
	@cd $(ANSIBLE_DIR) && ansible all -m ping

ansible-playbook: ## Executa o playbook completo
	@echo "$(BLUE)Executando playbook...$(NC)"
	@cd $(ANSIBLE_DIR) && ansible-playbook playbook.yml

ansible-setup: ## Executa apenas o setup (comum, docker, nginx)
	@echo "$(BLUE)Executando setup...$(NC)"
	@cd $(ANSIBLE_DIR) && ansible-playbook playbook.yml --tags setup

ansible-deploy: ## Executa apenas o deploy da aplicação
	@echo "$(BLUE)Executando deploy da aplicação...$(NC)"
	@cd $(ANSIBLE_DIR) && ansible-playbook playbook.yml --tags application

ansible-check: ## Dry-run do Ansible (sem aplicar mudanças)
	@echo "$(BLUE)Executando dry-run...$(NC)"
	@cd $(ANSIBLE_DIR) && ansible-playbook playbook.yml --check

ansible-verbose: ## Executa playbook com output verbose
	@echo "$(BLUE)Executando playbook (verbose)...$(NC)"
	@cd $(ANSIBLE_DIR) && ansible-playbook playbook.yml -vvv

##@ Deploy e Gerenciamento

deploy: check-deps ## Deploy completo (Terraform + Ansible)
	@echo "$(BLUE)╔═══════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║              Iniciando Deploy Completo                    ║$(NC)"
	@echo "$(BLUE)╚═══════════════════════════════════════════════════════════╝$(NC)"
	@if [ ! -f $(TERRAFORM_DIR)/terraform.tfvars ]; then \
		echo "$(RED)✗ terraform.tfvars não encontrado!$(NC)"; \
		echo "$(YELLOW)Execute: make setup$(NC)"; \
		exit 1; \
	fi
	@echo "\n$(BLUE)1/3 - Provisionando infraestrutura...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform init && terraform apply -auto-approve
	@echo "\n$(BLUE)2/3 - Aguardando servidor ficar pronto...$(NC)"
	@sleep 30
	@echo "\n$(BLUE)3/3 - Configurando servidor e fazendo deploy...$(NC)"
	@cd $(ANSIBLE_DIR) && ansible all -m ping -o || (sleep 30 && ansible all -m ping)
	@cd $(ANSIBLE_DIR) && ansible-playbook playbook.yml
	@echo "\n$(GREEN)╔═══════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(GREEN)║              Deploy Concluído com Sucesso! 🚀             ║$(NC)"
	@echo "$(GREEN)╚═══════════════════════════════════════════════════════════╝$(NC)"
	@make info

update: ## Atualiza apenas a aplicação (sem recriar infraestrutura)
	@echo "$(BLUE)Atualizando aplicação...$(NC)"
	@cd $(ANSIBLE_DIR) && ansible-playbook playbook.yml --tags application
	@echo "$(GREEN)✓ Aplicação atualizada!$(NC)"
	@make info

destroy: tf-destroy ## Destrói toda a infraestrutura

info: ## Mostra informações sobre o deploy
	@echo "\n$(BLUE)Informações do Deploy:$(NC)"
	@echo "$(YELLOW)═══════════════════════════════════════════════════════════$(NC)"
	@cd $(TERRAFORM_DIR) && terraform output -json | grep -E '(instance_public_ip|frontend_url|backend_url)' || echo "Execute 'make deploy' primeiro"
	@echo ""
	@echo "$(GREEN)Frontend:$(NC)  $$(cd $(TERRAFORM_DIR) && terraform output -raw frontend_url 2>/dev/null || echo 'N/A')"
	@echo "$(GREEN)Backend:$(NC)   $$(cd $(TERRAFORM_DIR) && terraform output -raw backend_url 2>/dev/null || echo 'N/A')"
	@echo "$(GREEN)SSH:$(NC)       $$(cd $(TERRAFORM_DIR) && terraform output -raw ssh_connection_string 2>/dev/null || echo 'N/A')"
	@echo "$(YELLOW)═══════════════════════════════════════════════════════════$(NC)"

##@ Acesso e Monitoramento

ssh: ## Conecta ao servidor via SSH
	@IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw instance_public_ip 2>/dev/null); \
	if [ -z "$$IP" ]; then \
		echo "$(RED)✗ IP não encontrado. Execute 'make deploy' primeiro.$(NC)"; \
		exit 1; \
	fi; \
	echo "$(BLUE)Conectando a $$IP...$(NC)"; \
	ssh -i ~/.ssh/id_rsa ubuntu@$$IP

ssh-cmd: ## Executa comando no servidor (use: make ssh-cmd CMD="comando")
	@IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw instance_public_ip 2>/dev/null); \
	if [ -z "$$IP" ]; then \
		echo "$(RED)✗ IP não encontrado.$(NC)"; \
		exit 1; \
	fi; \
	if [ -z "$(CMD)" ]; then \
		echo "$(RED)✗ Use: make ssh-cmd CMD=\"seu comando\"$(NC)"; \
		exit 1; \
	fi; \
	ssh -i ~/.ssh/id_rsa ubuntu@$$IP "$(CMD)"

logs: ## Mostra logs da aplicação
	@IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw instance_public_ip 2>/dev/null); \
	if [ -z "$$IP" ]; then \
		echo "$(RED)✗ IP não encontrado.$(NC)"; \
		exit 1; \
	fi; \
	echo "$(BLUE)Mostrando logs...$(NC)"; \
	ssh -i ~/.ssh/id_rsa ubuntu@$$IP "cd /opt/cs-skin-go && docker compose logs --tail=100"

logs-follow: ## Mostra logs em tempo real (follow)
	@IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw instance_public_ip 2>/dev/null); \
	if [ -z "$$IP" ]; then \
		echo "$(RED)✗ IP não encontrado.$(NC)"; \
		exit 1; \
	fi; \
	echo "$(BLUE)Acompanhando logs... (Ctrl+C para sair)$(NC)"; \
	ssh -i ~/.ssh/id_rsa ubuntu@$$IP "cd /opt/cs-skin-go && docker compose logs -f"

logs-backend: ## Mostra logs apenas do backend
	@IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw instance_public_ip 2>/dev/null); \
	ssh -i ~/.ssh/id_rsa ubuntu@$$IP "cd /opt/cs-skin-go && docker compose logs backend --tail=100"

logs-frontend: ## Mostra logs apenas do frontend
	@IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw instance_public_ip 2>/dev/null); \
	ssh -i ~/.ssh/id_rsa ubuntu@$$IP "cd /opt/cs-skin-go && docker compose logs frontend --tail=100"

logs-nginx: ## Mostra logs do Nginx
	@IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw instance_public_ip 2>/dev/null); \
	ssh -i ~/.ssh/id_rsa ubuntu@$$IP "sudo tail -100 /var/log/nginx/cs-skin-go_error.log"

status: ## Mostra status dos containers
	@echo "$(BLUE)Status dos containers...$(NC)"
	@IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw instance_public_ip 2>/dev/null); \
	if [ -z "$$IP" ]; then \
		echo "$(RED)✗ IP não encontrado.$(NC)"; \
		exit 1; \
	fi; \
	ssh -i ~/.ssh/id_rsa ubuntu@$$IP "cd /opt/cs-skin-go && docker compose ps"

health: ## Verifica saúde da aplicação
	@echo "$(BLUE)Verificando saúde da aplicação...$(NC)"
	@IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw instance_public_ip 2>/dev/null); \
	if [ -z "$$IP" ]; then \
		echo "$(RED)✗ IP não encontrado.$(NC)"; \
		exit 1; \
	fi; \
	echo "\n$(YELLOW)Frontend:$(NC)"; \
	curl -s -o /dev/null -w "Status: %{http_code}\n" http://$$IP/ || echo "$(RED)Falhou$(NC)"; \
	echo "\n$(YELLOW)Backend API:$(NC)"; \
	curl -s -o /dev/null -w "Status: %{http_code}\n" http://$$IP/api/cases || echo "$(RED)Falhou$(NC)"; \
	echo ""

##@ Gerenciamento de Containers

restart: ## Reinicia todos os containers
	@echo "$(BLUE)Reiniciando containers...$(NC)"
	@IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw instance_public_ip 2>/dev/null); \
	ssh -i ~/.ssh/id_rsa ubuntu@$$IP "cd /opt/cs-skin-go && docker compose restart"
	@echo "$(GREEN)✓ Containers reiniciados!$(NC)"

restart-backend: ## Reinicia apenas o backend
	@IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw instance_public_ip 2>/dev/null); \
	ssh -i ~/.ssh/id_rsa ubuntu@$$IP "cd /opt/cs-skin-go && docker compose restart backend"
	@echo "$(GREEN)✓ Backend reiniciado!$(NC)"

restart-frontend: ## Reinicia apenas o frontend
	@IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw instance_public_ip 2>/dev/null); \
	ssh -i ~/.ssh/id_rsa ubuntu@$$IP "cd /opt/cs-skin-go && docker compose restart frontend"
	@echo "$(GREEN)✓ Frontend reiniciado!$(NC)"

rebuild: ## Rebuild e reinicia os containers
	@echo "$(BLUE)Rebuild dos containers...$(NC)"
	@IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw instance_public_ip 2>/dev/null); \
	ssh -i ~/.ssh/id_rsa ubuntu@$$IP "cd /opt/cs-skin-go && docker compose up -d --build"
	@echo "$(GREEN)✓ Rebuild completo!$(NC)"

##@ Banco de Dados

db-migrate: ## Executa migrações do banco de dados
	@echo "$(BLUE)Executando migrações...$(NC)"
	@IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw instance_public_ip 2>/dev/null); \
	ssh -i ~/.ssh/id_rsa ubuntu@$$IP "cd /opt/cs-skin-go && docker compose exec backend npm run migration:run"
	@echo "$(GREEN)✓ Migrações executadas!$(NC)"

db-seed: ## Executa seeds do banco de dados
	@echo "$(BLUE)Executando seeds...$(NC)"
	@IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw instance_public_ip 2>/dev/null); \
	ssh -i ~/.ssh/id_rsa ubuntu@$$IP "cd /opt/cs-skin-go && docker compose exec backend npm run seed"
	@echo "$(GREEN)✓ Seeds executados!$(NC)"

db-backup: ## Faz backup do banco de dados
	@echo "$(BLUE)Fazendo backup do banco...$(NC)"
	@IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw instance_public_ip 2>/dev/null); \
	TIMESTAMP=$$(date +%Y%m%d_%H%M%S); \
	ssh -i ~/.ssh/id_rsa ubuntu@$$IP "cd /opt/cs-skin-go && docker compose exec -T mysql mysqldump -u root -p cs_skin_go > backup_$$TIMESTAMP.sql" || true; \
	echo "$(GREEN)✓ Backup criado: backup_$$TIMESTAMP.sql$(NC)"

##@ Limpeza e Manutenção

clean-docker: ## Limpa recursos Docker não utilizados no servidor
	@echo "$(BLUE)Limpando Docker...$(NC)"
	@IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw instance_public_ip 2>/dev/null); \
	ssh -i ~/.ssh/id_rsa ubuntu@$$IP "docker system prune -f"
	@echo "$(GREEN)✓ Docker limpo!$(NC)"

clean-local: ## Limpa arquivos locais gerados
	@echo "$(BLUE)Limpando arquivos locais...$(NC)"
	@rm -f $(TERRAFORM_DIR)/.terraform.lock.hcl
	@rm -f $(TERRAFORM_DIR)/terraform.tfstate.backup
	@rm -f $(TERRAFORM_DIR)/tfplan
	@rm -f $(ANSIBLE_DIR)/inventory.ini
	@rm -f $(ANSIBLE_DIR)/*.retry
	@echo "$(GREEN)✓ Arquivos locais limpos!$(NC)"

clean: clean-local ## Limpa todos os arquivos temporários

##@ Troubleshooting

debug: ## Mostra informações de debug
	@echo "$(BLUE)Informações de Debug:$(NC)"
	@echo "\n$(YELLOW)Terraform:$(NC)"
	@cd $(TERRAFORM_DIR) && terraform version || echo "Terraform não disponível"
	@echo "\n$(YELLOW)Ansible:$(NC)"
	@cd $(ANSIBLE_DIR) && ansible --version | head -n1 || echo "Ansible não disponível"
	@echo "\n$(YELLOW)Inventário:$(NC)"
	@if [ -f $(ANSIBLE_DIR)/inventory.ini ]; then \
		cat $(ANSIBLE_DIR)/inventory.ini; \
	else \
		echo "Inventário não encontrado"; \
	fi
	@echo "\n$(YELLOW)Outputs Terraform:$(NC)"
	@cd $(TERRAFORM_DIR) && terraform output 2>/dev/null || echo "Nenhum output disponível"

test-connection: ## Testa conexão com a aplicação
	@echo "$(BLUE)Testando conexão...$(NC)"
	@IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw instance_public_ip 2>/dev/null); \
	if [ -z "$$IP" ]; then \
		echo "$(RED)✗ IP não encontrado.$(NC)"; \
		exit 1; \
	fi; \
	echo "\n$(YELLOW)Testando SSH...$(NC)"; \
	ssh -o ConnectTimeout=5 -i ~/.ssh/id_rsa ubuntu@$$IP "echo 'SSH OK'" && echo "$(GREEN)✓$(NC)" || echo "$(RED)✗ Falhou$(NC)"; \
	echo "\n$(YELLOW)Testando Frontend...$(NC)"; \
	curl -s -o /dev/null -w "%{http_code}" http://$$IP/ | grep -q "200" && echo "$(GREEN)✓ OK$(NC)" || echo "$(RED)✗ Falhou$(NC)"; \
	echo "\n$(YELLOW)Testando Backend...$(NC)"; \
	curl -s -o /dev/null -w "%{http_code}" http://$$IP/api/cases | grep -q "200" && echo "$(GREEN)✓ OK$(NC)" || echo "$(RED)✗ Falhou$(NC)"

##@ Documentação

docs: ## Abre a documentação principal
	@if command -v open >/dev/null 2>&1; then \
		open README.md; \
	elif command -v xdg-open >/dev/null 2>&1; then \
		xdg-open README.md; \
	else \
		cat README.md; \
	fi

quick-start: ## Mostra o guia rápido
	@cat QUICK_START.md

costs: ## Mostra estimativa de custos
	@echo "$(BLUE)Estimativa de Custos Mensal:$(NC)"
	@echo "$(YELLOW)═══════════════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)EC2 t2.micro:$(NC)      ~$$8.50/mês"
	@echo "$(GREEN)EBS 20GB gp3:$(NC)      ~$$1.60/mês"
	@echo "$(GREEN)Elastic IP:$(NC)        $$0.00/mês (quando associado)"
	@echo "$(GREEN)Data Transfer:$(NC)     ~$$0.50/mês"
	@echo "$(YELLOW)───────────────────────────────────────────────────────────$(NC)"
	@echo "$(GREEN)TOTAL:$(NC)             ~$$10.60/mês"
	@echo ""
	@echo "$(BLUE)Com AWS Free Tier (1º ano):$(NC)"
	@echo "$(GREEN)✓ 750h/mês de t2.micro = GRÁTIS$(NC)"
	@echo "$(GREEN)✓ 30 GB de EBS = GRÁTIS$(NC)"
	@echo "$(GREEN)✓ 15 GB de transferência = GRÁTIS$(NC)"
	@echo ""
	@echo "$(BLUE)TOTAL COM FREE TIER: $$0.00/mês 🎉$(NC)"
	@echo "$(YELLOW)═══════════════════════════════════════════════════════════$(NC)"

