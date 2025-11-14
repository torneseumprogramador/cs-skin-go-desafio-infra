#!/bin/bash

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções auxiliares
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Verificar requisitos
check_requirements() {
    print_header "Verificando Requisitos"
    
    local missing_deps=0
    
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform não encontrado. Instale: brew install terraform"
        missing_deps=1
    else
        print_success "Terraform encontrado: $(terraform version -json | grep -o '"version":"[^"]*' | cut -d'"' -f4)"
    fi
    
    if ! command -v ansible &> /dev/null; then
        print_error "Ansible não encontrado. Instale: brew install ansible"
        missing_deps=1
    else
        print_success "Ansible encontrado: $(ansible --version | head -n1)"
    fi
    
    if ! command -v aws &> /dev/null; then
        print_warning "AWS CLI não encontrado. Instale: brew install awscli"
    else
        print_success "AWS CLI encontrado"
    fi
    
    if [ ! -f ~/.ssh/id_rsa ]; then
        print_error "Chave SSH não encontrada em ~/.ssh/id_rsa"
        print_warning "Crie uma com: ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa"
        missing_deps=1
    else
        print_success "Chave SSH encontrada"
    fi
    
    if [ $missing_deps -eq 1 ]; then
        print_error "Dependências faltando. Instale-as antes de continuar."
        exit 1
    fi
}

# Verificar variáveis do Terraform
check_terraform_vars() {
    print_header "Verificando Configuração do Terraform"
    
    if [ ! -f terraform/terraform.tfvars ]; then
        print_warning "terraform.tfvars não encontrado. Copiando do exemplo..."
        cp terraform/terraform.tfvars.example terraform/terraform.tfvars
        print_warning "IMPORTANTE: Edite terraform/terraform.tfvars com seus valores!"
        print_warning "Especialmente: jwt_secret, mysql_password, allowed_ssh_cidr"
        
        read -p "Pressione ENTER para continuar depois de editar o arquivo..."
    fi
    
    print_success "terraform.tfvars encontrado"
}

# Provisionar infraestrutura
provision_infrastructure() {
    print_header "Provisionando Infraestrutura AWS"
    
    cd terraform
    
    print_warning "Inicializando Terraform..."
    terraform init
    
    print_warning "Validando configuração..."
    terraform validate
    
    print_warning "Planejando mudanças..."
    terraform plan -out=tfplan
    
    read -p "Deseja aplicar as mudanças? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        print_error "Deploy cancelado pelo usuário"
        exit 1
    fi
    
    print_warning "Aplicando mudanças..."
    terraform apply tfplan
    
    print_success "Infraestrutura provisionada com sucesso!"
    
    # Extrair outputs
    export INSTANCE_IP=$(terraform output -raw instance_public_ip)
    export FRONTEND_URL=$(terraform output -raw frontend_url)
    export BACKEND_URL=$(terraform output -raw backend_url)
    
    cd ..
}

# Aguardar instância ficar pronta
wait_for_instance() {
    print_header "Aguardando Instância Ficar Pronta"
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo -ne "Tentativa $attempt/$max_attempts..."
        
        if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i ~/.ssh/id_rsa ubuntu@$INSTANCE_IP "echo 'ok'" &> /dev/null; then
            echo -e " ${GREEN}✓${NC}"
            print_success "Instância pronta!"
            return 0
        else
            echo -e " ${YELLOW}aguardando...${NC}"
            sleep 10
            attempt=$((attempt + 1))
        fi
    done
    
    print_error "Timeout aguardando instância ficar pronta"
    exit 1
}

# Executar Ansible
run_ansible() {
    print_header "Configurando Servidor e Fazendo Deploy"
    
    cd ansible
    
    # Verificar inventário
    if [ ! -f inventory.ini ]; then
        print_error "Inventário do Ansible não encontrado!"
        print_error "Ele deveria ter sido gerado pelo Terraform."
        exit 1
    fi
    
    print_warning "Testando conectividade..."
    if ! ansible all -m ping; then
        print_error "Não foi possível conectar ao servidor"
        exit 1
    fi
    
    print_success "Conectividade OK!"
    
    print_warning "Executando playbook do Ansible..."
    ansible-playbook playbook.yml
    
    print_success "Deploy concluído com sucesso!"
    
    cd ..
}

# Exibir informações finais
show_final_info() {
    print_header "🎉 Deploy Concluído com Sucesso!"
    
    echo -e "${GREEN}Suas aplicações estão rodando em:${NC}\n"
    echo -e "  ${BLUE}Frontend:${NC}  $FRONTEND_URL"
    echo -e "  ${BLUE}Backend:${NC}   $BACKEND_URL"
    echo -e "  ${BLUE}IP:${NC}        $INSTANCE_IP"
    echo ""
    echo -e "${GREEN}Para acessar o servidor via SSH:${NC}"
    echo -e "  ${YELLOW}ssh -i ~/.ssh/id_rsa ubuntu@$INSTANCE_IP${NC}"
    echo ""
    echo -e "${GREEN}Para ver logs:${NC}"
    echo -e "  ${YELLOW}ssh ubuntu@$INSTANCE_IP 'cd /opt/cs-skin-go && docker compose logs -f'${NC}"
    echo ""
    echo -e "${BLUE}========================================${NC}\n"
}

# Main
main() {
    clear
    echo -e "${BLUE}"
    echo "  ██████╗███████╗    ███████╗██╗  ██╗██╗███╗   ██╗     ██████╗  ██████╗ "
    echo " ██╔════╝██╔════╝    ██╔════╝██║ ██╔╝██║████╗  ██║    ██╔════╝ ██╔═══██╗"
    echo " ██║     ███████╗    ███████╗█████╔╝ ██║██╔██╗ ██║    ██║  ███╗██║   ██║"
    echo " ██║     ╚════██║    ╚════██║██╔═██╗ ██║██║╚██╗██║    ██║   ██║██║   ██║"
    echo " ╚██████╗███████║    ███████║██║  ██╗██║██║ ╚████║    ╚██████╔╝╚██████╔╝"
    echo "  ╚═════╝╚══════╝    ╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝     ╚═════╝  ╚═════╝ "
    echo -e "${NC}"
    echo -e "${BLUE}                    Deploy Automatizado AWS                          ${NC}\n"
    
    # Verificar se está no diretório correto
    if [ ! -d "terraform" ] || [ ! -d "ansible" ]; then
        print_error "Execute este script do diretório infra/"
        exit 1
    fi
    
    check_requirements
    check_terraform_vars
    provision_infrastructure
    wait_for_instance
    run_ansible
    show_final_info
}

# Executar
main "$@"

