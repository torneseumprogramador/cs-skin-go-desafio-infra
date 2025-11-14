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

# Main
main() {
    clear
    print_header "🔄 Atualizando Aplicação CS Skin GO"
    
    # Verificar se está no diretório correto
    if [ ! -d "ansible" ]; then
        print_error "Execute este script do diretório infra/"
        exit 1
    fi
    
    # Verificar se inventário existe
    if [ ! -f "ansible/inventory.ini" ]; then
        print_error "Inventário não encontrado. Execute o deploy completo primeiro."
        exit 1
    fi
    
    cd ansible
    
    print_warning "Testando conectividade com servidor..."
    if ! ansible all -m ping; then
        print_error "Não foi possível conectar ao servidor"
        exit 1
    fi
    
    print_success "Conectividade OK!"
    
    print_warning "Atualizando aplicação..."
    ansible-playbook playbook.yml --tags application
    
    print_success "Aplicação atualizada com sucesso!"
    
    # Extrair IP do inventário
    INSTANCE_IP=$(grep ansible_host ansible/inventory.ini | awk '{print $2}' | cut -d'=' -f2)
    
    print_header "✅ Atualização Concluída!"
    echo -e "${GREEN}Sua aplicação foi atualizada:${NC}\n"
    echo -e "  ${BLUE}Frontend:${NC}  http://$INSTANCE_IP"
    echo -e "  ${BLUE}Backend:${NC}   http://$INSTANCE_IP/api"
    echo ""
}

# Executar
main "$@"

